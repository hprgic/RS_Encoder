--------------------------------------------------------------------------------
-- Project      : Reed-Solomon Encoder
-- File         : rs_composite_parity_gen.vhd
-- Author       : Hrvoje Prgic
-- Company      :
-- Email        : hrvoje.prgic@gmail.com
-- Created      : 2026-07-24
-- Last Updated : 2026-07-24
-- Version      : 1.0.1
-- License      :
--
-- Description:
-- -----------------------------------------------------------------------------
-- Reed-Solomon Composite-Field Parity Generator
--
-- This module implements a systematic Reed-Solomon (RS) parity generation
-- engine using composite-field arithmetic. The encoder operates over
-- GF(2^m) and computes the parity symbols required for an RS(N,K) codeword.
--
-- The implementation internally decomposes the original field GF(2^m) into
-- a composite representation:
--
--      GF(2^m) = GF((2^r)^k)
--
-- where r is the width of the subfield and k is the extension degree.
-- This representation enables efficient finite-field multiplication and can
-- significantly reduce hardware complexity for larger symbol widths.
--
-- The encoder accepts K information symbols through a streaming input
-- interface and updates an internal parity LFSR based on the RS generator
-- polynomial:
--
--      g(x) = Π (x + α^(FIRST_ROOT + i))
--
-- for i = 0 .. (N-K-1).
--
-- Generator polynomial coefficients are precomputed during elaboration and
-- transformed into the selected composite-field basis. Incoming symbols are
-- converted from the original GF(2^m) representation into composite-field
-- coordinates before being processed by the parity engine.
--
-- After all information symbols have been received, the module outputs the
-- complete parity vector consisting of (N-K) Reed-Solomon parity symbols.
--
-- Supported Features:
-- -----------------------------------------------------------------------------
-- • Configurable symbol width from 4 to 32 bits
-- • Arbitrary RS(N,K) code parameters
-- • Composite-field arithmetic acceleration
-- • Multiple finite-field multiplier architectures:
--
--     0 - Schoolbook multiplication
--     1 - Karatsuba multiplication
--     2 - Composite-field multiplication
--
-- • Automatic generator polynomial construction
-- • Automatic basis transformation generation
-- • Streaming ready/valid input interface
-- • Single-cycle parity output generation
--
-- Composite-Field Construction:
-- -----------------------------------------------------------------------------
-- During elaboration, the module automatically:
--
-- 1. Determines a suitable composite-field decomposition.
-- 2. Computes the subfield generator Ω.
-- 3. Finds an irreducible extension polynomial.
-- 4. Determines the extension basis element β.
-- 5. Generates forward and inverse basis transformation matrices.
-- 6. Computes the RS generator polynomial coefficients.
--
-- These values are used to perform all parity calculations in composite
-- coordinates while preserving compatibility with the original GF(2^m)
-- symbol representation.
--
-- Operation:
-- -----------------------------------------------------------------------------
-- 1. Apply reset to clear the parity registers.
-- 2. Present K information symbols on the input interface.
-- 3. For every accepted symbol:
--      - Convert the symbol into composite representation.
--      - Compute the parity feedback value.
--      - Update the parity LFSR state.
-- 4. After K symbols are received:
--      - Assert out_valid.
--      - Output all (N-K) parity symbols.
-- 5. Start a new block after reset or reinitialization.
--
-- This module generates parity symbols only. Construction of the complete
-- systematic codeword [data | parity] is expected to be performed by the
-- surrounding encoder datapath.
--
-- Dependencies:
-- -----------------------------------------------------------------------------
-- IEEE:
--   - ieee.std_logic_1164
--   - ieee.numeric_std
--   - ieee.std_logic_arith
--   - ieee.std_logic_unsigned
--
-- Internal:
--   - rs_pkg
--   - rs_math_pkg
--
-- References:
-- -----------------------------------------------------------------------------
-- W. Wesley Peterson and E. J. Weldon
-- Error-Correcting Codes, Second Edition
--
-- Shu Lin and Daniel J. Costello
-- Error Control Coding: Fundamentals and Applications
--
-- R. E. Blahut
-- Theory and Practice of Error Control Codes
--
-- Revision History:
-- -----------------------------------------------------------------------------
-- Version  Date         Author          Description
-- -------  ----------   --------------  ---------------------------------------
-- 1.0.1    2026-07-24   Hrvoje Prgic    Initial release.
--
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
library rs_enc_lib;
use rs_enc_lib.rs_pkg.all;
use rs_enc_lib.rs_math_pkg.all;

-- ==============================================================
-- RS COMPOSITE FIELD ENCODER
-- GF((2^m)^N) Reed–Solomon parity generator
-- ==============================================================

entity rs_composite_parity_gen is
   generic (
      C_SPARE_FF     : boolean := true;   -- lowers cost of FF, increases LUT utilization
      C_MUL_ARCH     : integer range 0 to 2 := 0;  -- 0: SCHOOLBOOK; 1: Karatsuba; 2: Composite
      C_USE_COMP     : boolean := true;
      C_SYMB_W       : integer range 4 to 32 := 16; -- Symbol width (m) in bits. Supported range: 4 to 32.
      C_FIRST_ROOT   : integer := 0;   -- 
      C_CODE_N       : integer := 255; -- Codeword length (N) in symbols. Must satisfy: C_N <= (2**C_SYMB_W - 1).
      C_SYMB_K       : integer := 223  -- Number of information symbols (K).
                                       -- Number of parity symbols = C_N - C_K must satisfy: 0 < C_K < C_N.
   );
   port (
      clk         : in std_logic;            -- System clock.
      rst         : in std_logic;            -- Active-high synchronous reset.
      
      in_valid    : in  std_logic;                             -- input valid
      in_ready    : out std_logic;                             -- input ready
      in_data     : in  std_logic_vector(C_SYMB_W - 1 downto 0); -- input data
      
      out_valid   : out std_logic;                             -- output valid
      out_ready   : in  std_logic;                             -- output ready
      out_data    : out std_logic_vector((C_CODE_N - C_SYMB_K) * C_SYMB_W - 1 downto 0)  -- output data
   );
end entity rs_composite_parity_gen;

architecture rtl of rs_composite_parity_gen is
   ---------------------------------------------------------------------------
   -- CONSTANTS
   ---------------------------------------------------------------------------
   -- Number of parity symbols in the RS code: R = N-K.
   constant C_PARITY_SYMB        : integer      := C_CODE_N - C_SYMB_K;
   -- Width of one composite-field coefficient: GF(2^r).
   constant C_COMP_SYMB_W        : integer      := f_find_gcd(C_SYMB_W, C_USE_COMP);
   -- Extension degree of the composite field: GF(2^m) = GF((2^r)^k).
   constant C_COMP_DEG           : integer      := C_SYMB_W / C_COMP_SYMB_W;
   -- Primitive element alpha = x of the original GF(2^m) polynomial basis.
   -- constant C_ALPHA              : std_logic_vector(C_SYMB_W - 1 downto 0) := (1 => '1', others => '0');
   constant C_ALPHA              : std_logic_vector(C_SYMB_W - 1 downto 0) := conv_std_logic_vector(2, C_SYMB_W);
   -- Primitive polynomial of the original field GF(2^m).
   constant C_GF_POLY            : std_logic_vector(C_SYMB_W downto 0) := CP_PRIMITIVE_POLYNOMIAL(C_SYMB_W - 2)(C_SYMB_W downto 0);
   -- Generator of the GF(2^r) subfield represented inside GF(2^m).
   constant C_OMEGA              : std_logic_vector(C_SYMB_W - 1 downto 0) := f_calc_omega(C_COMP_DEG, C_COMP_SYMB_W, C_ALPHA, C_GF_POLY);
   -- Primitive polynomial of the subfield GF(2^r).
   constant C_SUBFIELD_POLY      : std_logic_vector(C_COMP_SYMB_W downto 0) := CP_PRIMITIVE_POLYNOMIAL(C_COMP_SYMB_W - 2)(C_COMP_SYMB_W downto 0);
   -- Irreducible extension polynomial defining: GF((2^r)^k) = GF(2^r)[beta].
   constant C_EXTENSION_POLY     : t_ext_poly   := f_find_extension_polynomial(C_COMP_DEG, C_ALPHA, C_SUBFIELD_POLY, C_GF_POLY, C_OMEGA);
   -- constant C_EXTENSION_POLY     : t_ext_poly(C_COMP_DEG - 1 downto 0)(C_SYMB_W downto 0) := (others => (others => '0'));  -- testing width only
   -- Composite-field generator beta used for the extension basis.
   constant C_BETA               : std_logic_vector(C_SYMB_W - 1 downto 0) := f_find_beta(C_EXTENSION_POLY, C_ALPHA, C_OMEGA, C_GF_POLY);
   -- constant C_BETA               : std_logic_vector(C_SYMB_W - 1 downto 0) := (others => '0');
   -- Basis transformation matrix: composite-field coordinates -> original GF(2^m) coordinates.
   constant C_BASIS_COMP_TO_GF   : t_basis_matrix := f_find_comp_to_gf_basis(C_BETA, C_OMEGA, C_COMP_SYMB_W, C_COMP_DEG, C_GF_POLY);
   -- constant C_BASIS_COMP_TO_GF   : t_basis_matrix(C_SYMB_W - 1 downto 0)(C_SYMB_W - 1 downto 0) := (others => (others => '0'));  -- testing width only
   -- Inverse basis transformation matrix: original GF(2^m) coordinates -> composite-field coordinates.
   constant C_BASIS_GF_TO_COMP   : t_basis_matrix := f_invert_gf2_matrix(C_BASIS_COMP_TO_GF);
   -- constant C_BASIS_GF_TO_COMP   : t_basis_matrix(C_SYMB_W - 1 downto 0)(C_SYMB_W - 1 downto 0) := (others => (others => '0'));  -- testing width only
   -- RS generator polynomial: g(x)=Π(x+alpha^(FIRST_ROOT+i)), i=0..R-1. Coefficients are stored in composite representatio
   constant C_GENERATOR_POLY     : t_gen_poly := f_find_generator_poly(C_PARITY_SYMB, C_ALPHA, C_GF_POLY, C_BASIS_GF_TO_COMP, C_EXTENSION_POLY, C_SUBFIELD_POLY, C_FIRST_ROOT);
   -- constant C_GENERATOR_POLY     : t_gen_poly(0 to C_PARITY_SYMB)(0 to C_COMP_DEG-1)(C_COMP_SYMB_W -1 downto 0) := (others => (others => (others => '0')));  -- testing width only
   
   constant C_COUNT_W : integer := f_log2(C_SYMB_K + 1);
   ---------------------------------------------------------------------------
   -- SIGNALS
   ---------------------------------------------------------------------------
   -- Input symbol converted to composite representation.
   signal data_comp  : t_symbol(0 to C_COMP_DEG - 1)(C_COMP_SYMB_W - 1 downto 0);
   -- Feedback value used by the parity LFSR.
   signal parity_fb  : t_symbol(0 to C_COMP_DEG - 1)(C_COMP_SYMB_W - 1 downto 0);
   -- Parity LFSR registers.
   signal parity_reg    : t_parity_state(0 to C_PARITY_SYMB - 1)(0 to C_COMP_DEG - 1)(C_COMP_SYMB_W - 1 downto 0);
   signal parity_reg_i  : t_parity_state(0 to C_PARITY_SYMB - 1)(0 to C_COMP_DEG - 1)(C_COMP_SYMB_W - 1 downto 0);
   -- Number of received message symbols.
   signal symbol_count : std_logic_vector(C_COUNT_W - 1 downto 0);
   signal out_valid_i  : std_logic := '0';
begin

   process(in_data) is
   begin
      data_comp <= f_gf_to_composite(
                  in_data,
                  C_BASIS_GF_TO_COMP,
                  C_COMP_SYMB_W
                  );
   end process;
   
   g_spare_ff: if(C_SPARE_FF = true) generate
      process(data_comp, parity_reg_i) is
      begin
         parity_fb <=
            f_composite_add(
               data_comp,
               parity_reg_i(C_PARITY_SYMB-1)
            );
      end process;
      
      process(symbol_count, parity_reg) is
      begin
         if(symbol_count = 0) then
            parity_reg_i <= (others => (others => (others => '0')));
         else
            parity_reg_i <= parity_reg;
         end if;
      end process;
      
      process(clk) is
         variable v_mult : t_symbol(0 to C_COMP_DEG-1)(C_COMP_SYMB_W-1 downto 0);
         variable v_next : t_parity_state(0 to C_PARITY_SYMB-1)(0 to C_COMP_DEG-1)(C_COMP_SYMB_W-1 downto 0);
      begin
         if rising_edge(clk) then
            v_next := (others => (others => (others => '0')));
            if rst = '1' then
               parity_reg     <= (others => (others => (others => '0')));
            -- while no valid output data, input can be updated. If output data is not ready, and valid is on output, wait until pipeline is enabled
            else
               if (in_valid = '1' and (out_valid_i = '0' or (out_valid_i = '1' and out_ready = '1'))) then
                  -----------------------------------------------------------------
                  -- Compute next parity state from current state
                  -----------------------------------------------------------------
                  v_next := parity_reg_i;
                  -----------------------------------------------------------------
                  -- Stage 0
                  -----------------------------------------------------------------
                  v_mult :=
                     f_composite_mul(
                        parity_fb,
                        C_GENERATOR_POLY(0),
                        C_EXTENSION_POLY,
                        C_SUBFIELD_POLY,
                        C_MUL_ARCH
                     );
                  v_next(0) :=
                     f_composite_add(
                        v_mult,
                        parity_reg_i(1)
                     );
                  -----------------------------------------------------------------
                  -- Intermediate stages
                  -----------------------------------------------------------------
                  for I in 1 to C_PARITY_SYMB-2 loop
                     v_mult :=
                        f_composite_mul(
                           parity_fb,
                           C_GENERATOR_POLY(I),
                           C_EXTENSION_POLY,
                           C_SUBFIELD_POLY,
                           C_MUL_ARCH
                        );
                     v_next(I) :=
                        f_composite_add(
                           v_mult,
                           parity_reg_i(I+1)
                        );
                  end loop;
                  -----------------------------------------------------------------
                  -- Last stage
                  -----------------------------------------------------------------
                  v_mult :=
                     f_composite_mul(
                        parity_fb,
                        C_GENERATOR_POLY(C_PARITY_SYMB-1),
                        C_EXTENSION_POLY,
                        C_SUBFIELD_POLY,
                        C_MUL_ARCH
                     );
                  v_next(C_PARITY_SYMB-1) := v_mult;
                  -----------------------------------------------------------------
                  -- Update registers
                  -----------------------------------------------------------------
                  -- Prepare for next block
                  parity_reg   <= v_next;
               end if;
            end if;
         end if;
      end process;
      gen_output : for I in 0 to C_PARITY_SYMB-1 generate
      begin
         out_data((I+1)*C_SYMB_W-1 downto I*C_SYMB_W) <= f_composite_to_gf(parity_reg(I), C_BASIS_COMP_TO_GF);
      end generate;
   end generate;
   
   g_spare_luts: if(C_SPARE_FF = false) generate
      process(data_comp, parity_reg) is
      begin
         parity_fb <=
            f_composite_add(
               data_comp,
               parity_reg(C_PARITY_SYMB-1)
            );
      end process;
   
      process(clk) is
         variable v_mult : t_symbol(0 to C_COMP_DEG-1)(C_COMP_SYMB_W-1 downto 0);
         variable v_next : t_parity_state(0 to C_PARITY_SYMB-1)(0 to C_COMP_DEG-1)(C_COMP_SYMB_W-1 downto 0);
      begin
         if rising_edge(clk) then
            v_next := (others => (others => (others => '0')));
            if rst = '1' then
               parity_reg     <= (others => (others => (others => '0')));
               parity_reg_i   <= (others => (others => (others => '0')));
            -- while no valid output data, input can be updated. If output data is not ready, and valid is on output, wait until pipeline is enabled
            else
               if (in_valid = '1' and (out_valid_i = '0' or (out_valid_i = '1' and out_ready = '1'))) then
                  -----------------------------------------------------------------
                  -- Compute next parity state from current state
                  -----------------------------------------------------------------
                  v_next := parity_reg;
                  -----------------------------------------------------------------
                  -- Stage 0
                  -----------------------------------------------------------------
                  v_mult :=
                     f_composite_mul(
                        parity_fb,
                        C_GENERATOR_POLY(0),
                        C_EXTENSION_POLY,
                        C_SUBFIELD_POLY,
                        C_MUL_ARCH
                     );
                  v_next(0) :=
                     f_composite_add(
                        v_mult,
                        parity_reg(1)
                     );
                  -----------------------------------------------------------------
                  -- Intermediate stages
                  -----------------------------------------------------------------
                  for I in 1 to C_PARITY_SYMB-2 loop
                     v_mult :=
                        f_composite_mul(
                           parity_fb,
                           C_GENERATOR_POLY(I),
                           C_EXTENSION_POLY,
                           C_SUBFIELD_POLY,
                           C_MUL_ARCH
                        );
                     v_next(I) :=
                        f_composite_add(
                           v_mult,
                           parity_reg(I+1)
                        );
                  end loop;
                  -----------------------------------------------------------------
                  -- Last stage
                  -----------------------------------------------------------------
                  v_mult :=
                     f_composite_mul(
                        parity_fb,
                        C_GENERATOR_POLY(C_PARITY_SYMB-1),
                        C_EXTENSION_POLY,
                        C_SUBFIELD_POLY,
                        C_MUL_ARCH
                     );
                  v_next(C_PARITY_SYMB-1) := v_mult;
                  -----------------------------------------------------------------
                  -- Update registers
                  -----------------------------------------------------------------
               end if;
               if (out_valid_i = '1' and out_ready = '1') then
                  -- Save final parity
                  parity_reg_i <= v_next;
                  -- Prepare for next block
                  parity_reg   <= (others => (others => (others => '0')));
               else
                  parity_reg   <= v_next;
               end if;
            end if;
         end if;
      end process;
      
      gen_output : for I in 0 to C_PARITY_SYMB-1 generate
      begin
         out_data((I+1)*C_SYMB_W-1 downto I*C_SYMB_W) <= f_composite_to_gf(parity_reg_i(I), C_BASIS_COMP_TO_GF);
      end generate;
   end generate;
   
   
   process(clk) is
   begin
      if rising_edge(clk) then
         if rst = '1' then
            symbol_count   <= (others => '0');
         elsif (out_valid_i = '1' and out_ready = '1') then
            symbol_count <= (others => '0');
         elsif(in_valid = '1' and in_ready = '1') then
            symbol_count <= symbol_count + 1;
         end if;
      end if;
   end process;
   
   
   out_valid_i <= '1' when (symbol_count = C_SYMB_K-1) else '0';
   out_valid   <= out_valid_i;
   in_ready    <= '0' when out_valid_i = '1' and out_ready = '0' else '1';
   
end rtl;