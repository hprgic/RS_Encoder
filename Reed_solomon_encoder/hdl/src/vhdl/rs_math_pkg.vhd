--------------------------------------------------------------------------------
-- Project      : Reed-Solomon Encoder Library
-- File         : rs_math_pkg.vhd
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
-- Reed-Solomon Mathematical Support Package
--
-- This package contains utility functions, finite-field arithmetic
-- operations, composite-field transformations, polynomial manipulation
-- routines, and Reed-Solomon generator construction functions used by the
-- Reed-Solomon encoder library.
--
-- The package provides support for arithmetic in GF(2^m) and
-- GF((2^r)^k), including:
--
--   • Polynomial arithmetic over GF(2)
--   • GF(2^m) multiplication, inversion, exponentiation, and reduction
--   • Karatsuba multiplication
--   • Composite-field arithmetic
--   • Extension polynomial operations
--   • Basis transformation generation
--   • Composite/GF representation conversion
--   • Reed-Solomon generator polynomial construction
--   • RS parity LFSR update functions
--
-- All algorithms are implemented as elaboration-time and simulation-time
-- functions to support automatic construction of composite-field
-- representations and generator polynomials for arbitrary RS(N,K)
-- configurations.
--
-- Dependencies:
-- -----------------------------------------------------------------------------
-- IEEE:
--   - ieee.std_logic_1164
--   - ieee.numeric_std
--
-- Internal:
--   - rs_pkg
--
-- References:
-- -----------------------------------------------------------------------------
-- R. Lidl and H. Niederreiter
-- Finite Fields
--
-- R. E. Blahut
-- Theory and Practice of Error Control Codes
--
-- Shu Lin and Daniel J. Costello
-- Error Control Coding: Fundamentals and Applications
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
use ieee.numeric_std.all;
library rs_enc_lib;
use rs_enc_lib.rs_pkg.all;

package rs_math_pkg is
   -------------------------------------------------------------------------------
   -- Ceiling base-2 logarithm.
   -------------------------------------------------------------------------------
   function f_log2(
      constant N : positive
   ) return integer;
   
   -------------------------------------------------------------------------------
   -- Greatest common divider of number A (not including A)
   -------------------------------------------------------------------------------
   function f_find_gcd(
      constant A     : integer;
      constant COMP  : boolean
   ) return integer;

   -------------------------------------------------------------------------------
   -- trim polynomial to the 
   -------------------------------------------------------------------------------
   function f_poly_trim(
      constant A : std_logic_vector
   ) return std_logic_vector;

   -------------------------------------------------------------------------------
   -- Return polynomial degree
   -------------------------------------------------------------------------------
   function f_poly_degree(
      constant A : std_logic_vector
   ) return integer;

   -------------------------------------------------------------------------------
   -- Return max of two
   -------------------------------------------------------------------------------
   function f_max(
      constant A : integer := 0;
      constant B : integer := 0
   ) return integer;
   -------------------------------------------------------------------------------
-- Polynomial addition over GF(2)
   -------------------------------------------------------------------------------
   function f_poly_add(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector;

   -------------------------------------------------------------------------------
   -- Polynomial multiply by x^SHIFT
   -------------------------------------------------------------------------------
   function f_poly_shift_left(
      constant A     : std_logic_vector;
      constant SHIFT : integer
   ) return std_logic_vector;

   -------------------------------------------------------------------------------
   -- Polynomial multiplication over GF(2)
   -------------------------------------------------------------------------------
   procedure f_poly_multiply(
      constant A       : in  std_logic_vector;
      constant B       : in  std_logic_vector;
      variable PRODUCT : out std_logic_vector
   );

   -------------------------------------------------------------------------------
   -- Polynomial division over GF(2)
   -------------------------------------------------------------------------------
   procedure f_poly_divide(
       constant DIVIDEND  : in  std_logic_vector;
       constant DIVISOR   : in  std_logic_vector;
       variable QUOTIENT  : out std_logic_vector;
       variable REMAINDER : out std_logic_vector
   );

   -------------------------------------------------------------------------------
   -- Polynomial modulo
   -------------------------------------------------------------------------------
   function f_poly_mod(
       constant A : std_logic_vector;
       constant B : std_logic_vector
   ) return std_logic_vector;

   -------------------------------------------------------------------------------
   -- Greatest common divisor of two GF(2) polynomials
   -------------------------------------------------------------------------------
   function f_poly_gcd(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector;


   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   -- GF(2^m) arithmetic
   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------

   -------------------------------------------------------------------------------
   -- Addition in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_add(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Multiplication with architecture selection
   -------------------------------------------------------------------------------
   function f_gf_mul(
      constant A        : std_logic_vector;
      constant B        : std_logic_vector;
      constant PRIM_POLY: std_logic_vector;
      constant MUL_ARCH  : integer := 0
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Ordinary multiplication in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_mul_schoolbook(
      constant A        : std_logic_vector;
      constant B        : std_logic_vector;
      constant PRIM_POLY: std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Polynomial multiplication over GF(2) without modular reduction.
   -------------------------------------------------------------------------------
   function f_poly_mul(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Karatsuba multiplication in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_mul_karatsuba(
      constant A         : std_logic_vector;
      constant B         : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Karatsuba polynomial multiplication over GF(2).
   -------------------------------------------------------------------------------
   function f_poly_mul_karatsuba(
      constant A         : std_logic_vector;
      constant B         : std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Polynomial reduction modulo the primitive polynomial.
   -------------------------------------------------------------------------------
   function f_gf_reduce(
      constant PRODUCT   : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Squaring in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_square(
      constant A        : std_logic_vector;
      constant PRIM_POLY: std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Frobenius map in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_frobenius(
      constant A         : std_logic_vector;
      constant R         : integer;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector;
   -------------------------------------------------------------------------------
   -- Exponentiation in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_power(
      constant A        : std_logic_vector;
      constant POWER    : integer;
      constant PRIM_POLY: std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Multiplicative inverse in GF(2^m)
   -------------------------------------------------------------------------------
   function f_gf_inverse(
      constant A        : std_logic_vector;
      constant PRIM_POLY: std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Extension polynomial operations
   -------------------------------------------------------------------------------
   function f_ext_poly_degree(
      constant A : t_ext_poly
   ) return integer;

   -------------------------------------------------------------------------------
   -- Extension polynomial addition
   -------------------------------------------------------------------------------
   function f_ext_poly_add(
      constant A : t_ext_poly;
      constant B : t_ext_poly
   ) return t_ext_poly;

   -------------------------------------------------------------------------------
   -- Extension polynomial multiplication
   -------------------------------------------------------------------------------
   function f_ext_poly_multiply(
      constant A       : in t_ext_poly;
      constant B       : in t_ext_poly;
      constant PRIM_GF : in std_logic_vector
   ) return t_ext_poly;
   
   -------------------------------------------------------------------------------
   -- Extension polynomial modulo
   -------------------------------------------------------------------------------
   function f_ext_poly_mod(
      constant A       : t_ext_poly;
      constant B       : t_ext_poly;
      constant PRIM_GF : std_logic_vector
   ) return t_ext_poly;
   
   -------------------------------------------------------------------------------
   -- Extension polynomial GCD
   -------------------------------------------------------------------------------
   function f_ext_poly_gcd(
      constant A       : t_ext_poly;
      constant B       : t_ext_poly;
      constant PRIM_GF : std_logic_vector
   ) return t_ext_poly;
   
   -------------------------------------------------------------------------------
   -- Extension polynomial search
   -------------------------------------------------------------------------------
   function f_find_extension_polynomial(
      constant EXTENSION_DEGREE : integer;
      constant ALPHA            : std_logic_vector;
      constant BASE_POLY        : std_logic_vector;
      constant ORIG_POLY        : std_logic_vector;
      constant OMEGA            : std_logic_vector
   ) return t_ext_poly;
   
   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   -- Extension polynomial irreducibility
   -------------------------------------------------------------------------------
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- Extension polynomial is zero
   -------------------------------------------------------------------------------
   function f_ext_poly_is_zero(
      constant A : t_ext_poly
   ) return boolean;
   
   -------------------------------------------------------------------------------
   -- Extension polynomials are equal
   -------------------------------------------------------------------------------
   function f_ext_poly_equal(
      constant A : t_ext_poly;
      constant B : t_ext_poly
   ) return boolean;
   
   function f_ext_poly_monic(
      constant A : t_ext_poly;
      constant PRIM_GF : std_logic_vector
   ) return t_ext_poly;
   
   function f_ext_poly_power_mod(
      constant A       : t_ext_poly;
      constant POWER   : unsigned;
      constant MOD_POLY: t_ext_poly;
      constant PRIM_GF : std_logic_vector
   ) return t_ext_poly;
   
   function f_increment_array(
       constant A : t_ext_poly
   ) return t_ext_poly;
   
   function f_ext_poly_is_irreducible(
      constant POLY    : t_ext_poly;
      constant PRIM_GF : std_logic_vector
   ) return boolean;
   
   -------------------------------------------------------------------------------
   -- Beta element of original polynomial
   -------------------------------------------------------------------------------
   function f_find_beta(
      constant EXT_POLY  : t_ext_poly;
      constant ALPHA     : std_logic_vector;
      constant OMEGA     : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector;

   -------------------------------------------------------------------------------
   -- Find beta
   -- Searches beta = alpha^k such that:
   --    Q(beta) = 0
   -- where Q is the extension polynomial.
   -------------------------------------------------------------------------------
   function f_embed_subfield_element(
      constant COEFF     : std_logic_vector;
      constant OMEGA     : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector;
      
   -------------------------------------------------------------------------------
   -- Find composite field basis matrix
   -------------------------------------------------------------------------------
   function f_find_comp_to_gf_basis(
      constant BETA      : std_logic_vector;
      constant OMEGA     : std_logic_vector;
      constant COMP_W    : integer;
      constant COMP_N    : integer;
      constant PRIM_POLY : std_logic_vector
   ) return t_basis_matrix;
      
      /* 
   -------------------------------------------------------------------------------
   -- Find composite field basis matrix
   -------------------------------------------------------------------------------
   function f_find_basis_matrix(
      constant BETA      : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return t_basis_matrix;
    */
   -------------------------------------------------------------------------------
   -- Find composite field basis matrix inverse
   -------------------------------------------------------------------------------
   function f_invert_gf2_matrix(
      constant MATRIX : t_basis_matrix
   ) return t_basis_matrix;
   
   -------------------------------------------------------------------------------
   -- Convert a GF(2^m) element into composite field coefficients.
   -------------------------------------------------------------------------------
   function f_gf_to_composite(
      constant DATA_IN  : std_logic_vector;
      constant BASIS    : t_basis_matrix;
      constant C_COMP_W : integer
   ) return t_symbol;
   
   -------------------------------------------------------------------------------
   -- Composite polynomial multiplication.
   -------------------------------------------------------------------------------
   function f_composite_poly_mul(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH : integer := 0
   ) return t_composite_poly;
   
   -------------------------------------------------------------------------------
   -- Composite multiplication
   -------------------------------------------------------------------------------
   function f_composite_mul(
      constant A          : t_symbol;
      constant B          : t_symbol;
      constant EXT_POLY   : t_ext_poly;
      constant SUB_POLY   : std_logic_vector;
      constant MUL_ARCH   : integer := 0
   ) return t_symbol;
   
   -------------------------------------------------------------------------------
   -- Composite addition
   -------------------------------------------------------------------------------
   function f_composite_add(
      constant A : t_symbol;
      constant B : t_symbol
   ) return t_symbol;
   
   -------------------------------------------------------------------------------
   -- Convert composite field representation to GF(2^m)
   -------------------------------------------------------------------------------
   function f_composite_to_gf(
      constant DATA_IN : t_symbol;
      constant MATRIX  : t_basis_matrix
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Find generator polynomial for calculating parity.
   -------------------------------------------------------------------------------
   function f_find_generator_poly(
      constant R                 : integer;
      constant ALPHA             : std_logic_vector;   
      constant ORIG_POLY         : std_logic_vector;
      constant C_GF_TO_COMP      : t_basis_matrix;
      constant EXT_POLY          : t_ext_poly;
      constant SUB_POLY          : std_logic_vector;
      constant FIRST_ROOT        : integer
   ) return t_gen_poly;
   
   -------------------------------------------------------------------------------
   -- Calculate sum of (2^r−1)/(2^m−1) in way as 1+2^m+2^(2*m)+⋯+2^((k−1)*m)
   -------------------------------------------------------------------------------
   function f_exponent_sum(
      k    : integer;
      r    : integer
    ) return unsigned;
    
   -------------------------------------------------------------------------------
   -- Calculate subfield generator omega.
   -------------------------------------------------------------------------------
    function f_calc_omega(
      constant K         : integer;
      constant R         : integer;
      constant ALPHA     : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Execute one RS encoder LFSR step.
   -------------------------------------------------------------------------------
   function f_rs_lfsr_step(
      constant DATA_IN  : t_symbol;
      constant PARITY   : t_parity_state;
      constant GEN_POLY : t_gen_poly;
      constant EXT_POLY : t_ext_poly;
      constant SUB_POLY : std_logic_vector
   ) return t_parity_state;
   
   -------------------------------------------------------------------------------
   -- Composite-field multiplication using the Karatsuba algorithm.
   -------------------------------------------------------------------------------
   function f_composite_poly_mul_karatsuba_2(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH : integer := 0
   ) return t_composite_poly;
   
   -------------------------------------------------------------------------------
   -- Composite-field multiplication using the Karatsuba algorithm.
   -------------------------------------------------------------------------------
   function f_composite_poly_mul_karatsuba(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH : integer := 0
   ) return t_composite_poly;

end package rs_math_pkg;


package body rs_math_pkg is
   -------------------------------------------------------------------------------
   -- Ceiling base-2 logarithm.
   --
   -- Computes:
   --
   --   ceil(log2(N))
   --
   -- which is the minimum number of bits required to represent
   -- values in the range:
   --
   --   0 .. N-1
   --
   -- Examples:
   --   N = 1   -> 0
   --   N = 2   -> 1
   --   N = 3   -> 2
   --   N = 4   -> 2
   --   N = 5   -> 3
   -------------------------------------------------------------------------------
   function f_log2(
      constant N : positive
   ) return integer is
      variable VALUE : integer := 1;
      variable RESULT : integer := 0;
   begin
      while VALUE < N loop
         VALUE := VALUE * 2;
         RESULT := RESULT + 1;
      end loop;

      return RESULT;
   end function;
   
   -------------------------------------------------------------------------------
   -- Find Greatest Common Divider smaller than A if exists, excluding 1
   -------------------------------------------------------------------------------
   function f_find_gcd(constant A : integer; constant COMP : boolean) return integer is
      variable GCD : integer := A;
   begin
      GCD := A;
      if(COMP = true and A > C_KARATSUBA_LIMIT) then
         if(A > 2) then
            for i in 2 to A - 1 loop
               if A mod i = 0 then
                  GCD := A / i;
                  exit;
               end if;
            end loop;
         end if;
      end if;
      return GCD;
   end function;
   
-------------------------------------------------------------------------------
-- Remove leading zeros
-------------------------------------------------------------------------------
   function f_poly_trim(
      constant A : std_logic_vector
   ) return std_logic_vector is
   begin
      for i in A'range loop
         if A(i) = '1' then
            return A(i downto A'right);
         end if;
      end loop;
      -- No '1' found
      return "0";
   end function;
   
   -------------------------------------------------------------------------------
   -- Return polynomial degree
   --
   -- Example:
   -- 10011 -> degree 4
   -- 00100 -> degree 2
   -------------------------------------------------------------------------------
   function f_poly_degree(
      constant A : std_logic_vector
   ) return integer is
      variable DEG : integer := -1;
   begin
      for i in A'high downto 0 loop
         if A(i) = '1' then
            DEG := i;
            exit;
         end if;
      end loop;
      return DEG;
   end function;

   -------------------------------------------------------------------------------
   -- Return max of two
   -------------------------------------------------------------------------------
   function f_max(
      constant A : integer := 0;
      constant B : integer := 0
   ) return integer is
   begin
      if A < B then
         return B;
      else
         return A;
      end if;
   end function;

   -------------------------------------------------------------------------------
   -- Polynomial addition over GF(2)
   --
   -- Addition = XOR
   -------------------------------------------------------------------------------
   function f_poly_add(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector is
      constant MAX_LEN : integer := f_max(A'length, B'length);
      variable AA : std_logic_vector(MAX_LEN-1 downto 0) := (others=>'0');
      variable BB : std_logic_vector(MAX_LEN-1 downto 0) := (others=>'0');
      variable RESULT : std_logic_vector(MAX_LEN-1 downto 0);
   begin
      AA(A'length-1 downto 0) := A;
      BB(B'length-1 downto 0) := B;
      RESULT := AA xor BB;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Polynomial multiply by x^SHIFT
   --
   -- Example:
   -- A = 1011 (x^3+x+1)
   -- SHIFT=2
   --
   -- result = 101100 (x^5+x^3+x^2)
   -------------------------------------------------------------------------------
   function f_poly_shift_left(
      constant A       : std_logic_vector;
      constant SHIFT   : integer
   ) return std_logic_vector is
      variable RESULT  : std_logic_vector(A'length+SHIFT-1 downto 0);
   begin
      RESULT := (others=>'0');
      RESULT(RESULT'left downto SHIFT) := A;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Polynomial multiplication over GF(2)
   --
   -- Example:
   -- (x+1)(x^2+1)
   --
   -- 011 * 101 = 1111
   -------------------------------------------------------------------------------
   procedure f_poly_multiply(
       constant A       : in  std_logic_vector;
       constant B       : in  std_logic_vector;
       variable PRODUCT : out std_logic_vector
   ) is
      variable TEMP     : std_logic_vector(PRODUCT'range) := (others=>'0');
      variable SHIFTED  : std_logic_vector(PRODUCT'range);
      variable A_EXT    : std_logic_vector(PRODUCT'range);
   begin
      A_EXT := (others=>'0');
      A_EXT(A'length-1 downto 0) := A;
      for i in B'reverse_range loop
         if B(i) = '1' then
            SHIFTED := (others=>'0');
            SHIFTED := std_logic_vector(
                shift_left(
                    unsigned(A_EXT),
                    B'right-i
                )
            );
            TEMP := TEMP xor SHIFTED;
         end if;
      end loop;
      PRODUCT := TEMP;
   end procedure;

   -------------------------------------------------------------------------------
   -- Polynomial division over GF(2)
   --
   -- DIVIDEND = DIVISOR * QUOTIENT + REMAINDER
   --
   -- Example:
   --
   -- x^4+x^3+x+1
   -- ----------------
   -- x^2+x+1
   --
   -- returns quotient and remainder
   -------------------------------------------------------------------------------
   procedure f_poly_divide(
       constant DIVIDEND  : in  std_logic_vector;
       constant DIVISOR   : in  std_logic_vector;
       variable QUOTIENT  : out std_logic_vector;
       variable REMAINDER : out std_logic_vector
   ) is
      variable TEMP     : std_logic_vector(DIVIDEND'range);
      variable DIV      : std_logic_vector(DIVIDEND'range);
      variable QUOT     : std_logic_vector(QUOTIENT'range);
      constant ZERO_QUOT   : std_logic_vector(QUOTIENT'range) := (others => '0');
      constant ZERO_REMD   : std_logic_vector(REMAINDER'range) := (others => '0');
      variable DEG_TEMP : integer;
      variable DEG_DIV  : integer;
      variable SHIFT : integer;
   begin
      TEMP := DIVIDEND;
      DIV := (others => '0');
      DIV(DIVISOR'length-1 downto 0) := DIVISOR;
      QUOT := (others=>'0');
      DEG_DIV := f_poly_degree(DIV);
      -- division by zero protection
      if DEG_DIV < 0 then
         QUOTIENT  := ZERO_QUOT;
         REMAINDER := ZERO_REMD;
         return;
      end if;
      while f_poly_degree(TEMP) >= DEG_DIV loop
         DEG_TEMP := f_poly_degree(TEMP);
         SHIFT := DEG_TEMP - DEG_DIV;
         QUOT(QUOT'right+SHIFT) := '1';
         TEMP :=
               TEMP xor
               std_logic_vector(
                  shift_left(
                     unsigned(DIV),
                     SHIFT
                  )
               );
      end loop;
      QUOTIENT := QUOT;
      REMAINDER := TEMP(REMAINDER'range);
   end procedure;

   -------------------------------------------------------------------------------
   -- Polynomial modulo
   --
   -- returns A mod B
   -------------------------------------------------------------------------------
   function f_poly_mod(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector is
      variable Q : std_logic_vector(A'range);
      variable R : std_logic_vector(A'range);
   begin
      f_poly_divide(
         A,
         B,
         Q,
         R
      );
      return R;
   end function;

   -------------------------------------------------------------------------------
   -- Greatest common divisor of two GF(2) polynomials
   --
   -- Euclidean algorithm
   -------------------------------------------------------------------------------
   function f_poly_gcd(constant A : std_logic_vector; constant B : std_logic_vector) return std_logic_vector is
      constant WIDTH : integer := f_max(A'length,B'length);
      variable X : std_logic_vector(WIDTH-1 downto 0);
      variable Y : std_logic_vector(WIDTH-1 downto 0);
      variable R : std_logic_vector(WIDTH-1 downto 0);
   begin
      X := (others=>'0');
      Y := (others=>'0');
      X(A'length-1 downto 0) := A;
      Y(B'length-1 downto 0) := B;
      while f_poly_degree(Y) >= 0 loop
         R := f_poly_mod(X,Y);
         X := Y;
         Y := R;
      end loop;
      return X;
   end function;

   -------------------------------------------------------------------------------
   -- Addition in GF(2^m)
   --
   -- Same as polynomial addition:
   -- XOR
   -------------------------------------------------------------------------------
   function f_gf_add(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector is
   begin
      return A xor B;
   end function;

   -------------------------------------------------------------------------------
   -- Multiplication architecture selection.
   --
   -- Performs multiplication in GF(2^m) using the selected multiplication
   -- architecture followed by polynomial reduction modulo PRIM_POLY.
   --
   -- Architectures:
   --   0: Schoolbook polynomial multiplication followed by reduction.
   --   1: Karatsuba polynomial multiplication followed by reduction.
   --
   -- Inputs:
   --   A         - First GF(2^m) field element.
   --   B         - Second GF(2^m) field element.
   --   PRIM_POLY - Primitive polynomial defining the finite field.
   --   MUL_ARCH  - Selection of multiplication architecture.
   --
   -- Returns:
   --   Product A*B reduced into GF(2^m).
   -------------------------------------------------------------------------------
   function f_gf_mul(
      constant A         : std_logic_vector;
      constant B         : std_logic_vector;
      constant PRIM_POLY : std_logic_vector;
      constant MUL_ARCH  : integer := 0
   ) return std_logic_vector is
   begin
      case MUL_ARCH is
         ------------------------------------------------------------------------
         -- Karatsuba multiplier
         ------------------------------------------------------------------------
         when 1 =>
            return f_gf_mul_karatsuba(
               A,
               B,
               PRIM_POLY
            );
         ------------------------------------------------------------------------
         -- Default Schoolbook multiplier
         ------------------------------------------------------------------------
         when others =>
            return f_gf_mul_schoolbook(
               A,
               B,
               PRIM_POLY
            );
      end case;
   end function;

   -------------------------------------------------------------------------------
   -- Schoolbook GF(2^m) multiplication.
   --
   -- Performs finite field multiplication using conventional polynomial
   -- multiplication followed by reduction modulo the primitive polynomial.
   --
   -- The multiplication is performed over GF(2), where addition corresponds
   -- to XOR and multiplication corresponds to polynomial convolution.
   --
   -- Inputs:
   --   A         - First GF(2^m) field element.
   --   B         - Second GF(2^m) field element.
   --   PRIM_POLY - Primitive polynomial defining the finite field.
   --
   -- Returns:
   --   Product A*B reduced into GF(2^m).
   -------------------------------------------------------------------------------
   function f_gf_mul_schoolbook(
      constant A         : std_logic_vector;
      constant B         : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
   begin
      return f_gf_reduce(
         f_poly_mul(A,B),
         PRIM_POLY
      );
   end function;
   
   -------------------------------------------------------------------------------
   -- Polynomial multiplication over GF(2).
   --
   -- Performs carry-less polynomial multiplication without modular reduction.
   --
   -- The input vectors are interpreted as polynomial coefficients over GF(2).
   -- Multiplication is performed using XOR accumulation:
   --
   --   PRODUCT = A(x) * B(x)
   --
   -- The returned polynomial may have degree up to:
   --
   --   deg(A) + deg(B)
   --
   -- and must be reduced separately to obtain a GF(2^m) field element.
   --
   -- Returns:
   --   Raw polynomial product before field reduction.
   -------------------------------------------------------------------------------
   function f_poly_mul(
      constant A : std_logic_vector;
      constant B : std_logic_vector
   ) return std_logic_vector is
      constant W : integer := A'length + B'length - 1;
      variable PRODUCT : std_logic_vector(W-1 downto 0);
   begin
      PRODUCT := (others => '0');
      for I in A'range loop
         if A(I)='1' then
            for J in B'range loop
               if B(J)='1' then
                  PRODUCT(I+J) := PRODUCT(I+J) xor '1';
               end if;
            end loop;
         end if;
      end loop;
      return PRODUCT;
   end function;
   
   -------------------------------------------------------------------------------
   -- Karatsuba GF(2^m) multiplication.
   --
   -- Performs finite field multiplication using the Karatsuba algorithm for
   -- polynomial multiplication followed by reduction modulo the primitive
   -- polynomial.
   --
   -- Karatsuba reduces the number of recursive polynomial multiplications by
   -- exploiting the identity:
   --
   --   (A_H + A_L)(B_H + B_L)
   --
   -- instead of calculating all four partial products directly.
   --
   -- Inputs:
   --   A         - First GF(2^m) field element.
   --   B         - Second GF(2^m) field element.
   --   PRIM_POLY - Primitive polynomial defining the finite field.
   --
   -- Returns:
   --   Product A*B reduced into GF(2^m).
   -------------------------------------------------------------------------------
   function f_gf_mul_karatsuba(
      constant A         : std_logic_vector;
      constant B         : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
   begin
      return f_gf_reduce(
         f_poly_mul_karatsuba(A, B),
         PRIM_POLY
      );
   end function;
   
   -------------------------------------------------------------------------------
   -- Karatsuba polynomial multiplication over GF(2).
   --
   -- Performs recursive carry-less polynomial multiplication using the
   -- Karatsuba divide-and-conquer algorithm for length > C_KARATSUBA_LIMIT.
   --
   -- The input polynomials are split into high and low halves:
   --
   --   A(x) = A_H*x^n + A_L
   --   B(x) = B_H*x^n + B_L
   --
   -- and combined using:
   --
   --   Z0 = A_L*B_L
   --   Z2 = A_H*B_H
   --   Z1 = (A_H+A_L)(B_H+B_L)
   --
   -- The output is a raw polynomial product and does not include reduction.
   --
   -- Returns:
   --   Polynomial product before GF(2^m) modular reduction.
   -------------------------------------------------------------------------------
   function f_poly_mul_karatsuba(
      constant A         : std_logic_vector;
      constant B         : std_logic_vector
   ) return std_logic_vector is
      constant M : integer := A'length;
      constant HALF : integer := M/2;
      variable A_LO : std_logic_vector(HALF-1 downto 0);
      variable A_HI : std_logic_vector(HALF-1 downto 0);
      variable B_LO : std_logic_vector(HALF-1 downto 0);
      variable B_HI : std_logic_vector(HALF-1 downto 0);
      variable Z0 : std_logic_vector(M-2 downto 0);
      variable Z1 : std_logic_vector(M-2 downto 0);
      variable Z2 : std_logic_vector(M-2 downto 0);
      variable PRODUCT : std_logic_vector(2*M-2 downto 0);
   begin
      --------------------------------------------------------------------
      -- Base case
      --------------------------------------------------------------------
      if (M <= C_KARATSUBA_LIMIT) or ((M mod 2) /= 0) then
         return f_poly_mul(A, B);
      else
         --------------------------------------------------------------------
         -- Split operands
         --------------------------------------------------------------------
         A_LO := A(HALF - 1 downto 0);
         A_HI := A(M - 1 downto HALF);
         B_LO := B(HALF - 1 downto 0);
         B_HI := B(M - 1 downto HALF);
         --------------------------------------------------------------------
         -- Recursive products
         --------------------------------------------------------------------
         Z0 := f_poly_mul_karatsuba(A_LO,B_LO);
         Z2 := f_poly_mul_karatsuba(A_HI,B_HI);
         Z1 := f_poly_mul_karatsuba(
                  f_gf_add(A_LO,A_HI),
                  f_gf_add(B_LO,B_HI)
               );
         --------------------------------------------------------------------
         -- Combine
         --------------------------------------------------------------------
         PRODUCT := (others => '0');
         PRODUCT(M - 2 downto 0) := PRODUCT(M - 2 downto 0) xor Z0;
         PRODUCT(2 * M - 2 downto M) := PRODUCT(2 * M - 2 downto M) xor Z2;
         PRODUCT(HALF + M - 2 downto HALF) := PRODUCT(HALF + M - 2 downto HALF) xor (Z1 xor Z0 xor Z2);
         --------------------------------------------------------------------
         -- Reduce
         --------------------------------------------------------------------
         return PRODUCT;
      end if;
   end function;
   
   -------------------------------------------------------------------------------
   -- Polynomial reduction modulo the primitive polynomial.
   --
   -- Reduces an unreduced polynomial product into a valid GF(2^m) field element
   -- by repeatedly eliminating the highest-degree terms using the primitive
   -- polynomial.
   --
   -- Reduction performs polynomial division over GF(2):
   --
   --   PRODUCT mod PRIM_POLY
   --
   -- Inputs:
   --   PRODUCT   - Raw polynomial product before reduction.
   --   PRIM_POLY - Primitive polynomial defining GF(2^m).
   --
   -- Returns:
   --   Reduced field element represented with m bits.
   -------------------------------------------------------------------------------
   function f_gf_reduce(
      constant PRODUCT   : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
      constant M : integer := PRIM_POLY'length - 1;
      variable TEMP      : std_logic_vector(PRODUCT'range);
      variable RESULT    : std_logic_vector(M-1 downto 0);
      variable POLY_EXT : std_logic_vector(PRODUCT'range);
   begin
      TEMP := PRODUCT;
      ---------------------------------------------------------------------------
      -- Align primitive polynomial to the highest possible product degree.
      -- The maximum degree of PRODUCT is 2M-2, therefore the maximum shift is:
      --
      -- (2M-2) - M = M-2
      --
      -- Work from highest degree down.
      ---------------------------------------------------------------------------
      for I in PRODUCT'high downto M loop
         if TEMP(I) = '1' then
            POLY_EXT := (others => '0');
            -- Shift primitive polynomial so that its highest term aligns with I.
            POLY_EXT(I downto I-M) := PRIM_POLY;
            TEMP := TEMP xor POLY_EXT;
         end if;
      end loop;
      RESULT := TEMP(M-1 downto 0);
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Squaring in GF(2^m)
   --
   -- Computes:
   --
   --   A(x)^2 mod PRIM_POLY
   --
   -- In GF(2):
   --
   --   (a+b)^2 = a^2+b^2
   --
   -- Therefore, each input coefficient is simply moved to an even position:
   --
   --   A[i] -> PRODUCT[2*i]
   --
   -- No XOR accumulation is required.
   --
   -- Returns:
   --   Squared field element reduced into GF(2^m).
   -------------------------------------------------------------------------------
   function f_gf_square(
      constant A         : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
      constant M : integer := A'length;
      variable PRODUCT : std_logic_vector(2*M-2 downto 0);
   begin
      PRODUCT := (others => '0');
      ---------------------------------------------------------------------------
      -- Polynomial squaring:
      --
      -- A(x)^2 = sum(A(i) * x^(2i))
      --
      -- Insert zero coefficients between every bit.
      ---------------------------------------------------------------------------
      for I in A'range loop
         PRODUCT(2*I) := A(I);
      end loop;
      ---------------------------------------------------------------------------
      -- Modular reduction:
      ---------------------------------------------------------------------------
      return f_gf_reduce(
         PRODUCT,
         PRIM_POLY
      );
   end function;
   
   -------------------------------------------------------------------------------
   -- Frobenius map in GF(2^m)
   --
   -- Computes:
   --
   --   A^(2^R)
   --
   -- by applying the Frobenius automorphism R times:
   --
   --   A -> A^2 -> A^(2^2) -> ... -> A^(2^R)
   --
   -- In GF(2^m), squaring is an automorphism, therefore repeated squaring
   -- implements exponentiation by powers of two.
   --
   -- Inputs:
   --   A         - GF(2^m) field element.
   --   R         - Number of Frobenius iterations.
   --   PRIM_POLY - Primitive polynomial defining GF(2^m).
   --
   -- Returns:
   --   A^(2^R).
   -------------------------------------------------------------------------------
   function f_gf_frobenius(
      constant A         : std_logic_vector;
      constant R         : integer;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is

      variable RESULT : std_logic_vector(A'range);

   begin

      RESULT := A;

      for I in 1 to R loop
         RESULT := f_gf_square(
                      RESULT,
                      PRIM_POLY
                   );
      end loop;

      return RESULT;

   end function;
   -------------------------------------------------------------------------------
   -- Exponentiation
   --
   -- Binary exponentiation
   -------------------------------------------------------------------------------
   function f_gf_power(constant A : std_logic_vector; constant POWER : integer; constant PRIM_POLY : std_logic_vector) return std_logic_vector is
      variable RESULT   : std_logic_vector(A'range);
      variable BASE     : std_logic_vector(A'range);
      variable P        : integer;
   begin
      RESULT := (others=>'0');
      -- multiplicative identity
      RESULT(RESULT'right) := '1';
      BASE := A;
      P := POWER;
      while P > 0 loop
         if (P mod 2)=1 then
            RESULT := f_gf_mul(RESULT, BASE, PRIM_POLY, 0);
         end if;
         BASE := f_gf_square(BASE, PRIM_POLY);
         P := P / 2;
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Multiplicative inverse
   --
   -- For non-zero a:
   --
   -- a^-1 = a^(2^m-2)
   -------------------------------------------------------------------------------
   function f_gf_inverse(constant A : std_logic_vector; constant PRIM_POLY : std_logic_vector) return std_logic_vector is
      constant M : integer := A'length;
      variable RESULT : std_logic_vector(A'range);
   begin
      if A = (A'range => '0') then
         return (A'range => '0');
      end if;
      RESULT := f_gf_power(A, (2**M)-2, PRIM_POLY);
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomial degree
   -------------------------------------------------------------------------------
   function f_ext_poly_degree(constant A : t_ext_poly) return integer is
   begin
      for i in A'reverse_range loop
         if A(i) /= (A(i)'range => '0') then
            return i;
         end if;
      end loop;
      return -1;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomial addition
   -------------------------------------------------------------------------------
   function f_ext_poly_add(
      constant A : t_ext_poly;
      constant B : t_ext_poly
   ) return t_ext_poly is
      variable RESULT : t_ext_poly(A'range)(A(0)'range);
   begin
      RESULT := (others => (others=>'0'));
      for i in RESULT'range loop
         if i <= A'high and i <= B'high then
            RESULT(i) := A(i) xor B(i);
         elsif i <= A'high then
            RESULT(i) := A(i);
         elsif i <= B'high then
            RESULT(i) := B(i);
         end if;
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomial multiplication
   -------------------------------------------------------------------------------
   function f_ext_poly_multiply(constant A : in t_ext_poly; constant B : in t_ext_poly; constant PRIM_GF : in std_logic_vector) return t_ext_poly is
        constant C_POLY_N : integer := A'length;
        constant C_COEFF_W : integer := A(0)'length;
        variable TEMP : t_ext_poly(0 to C_POLY_N-1)(C_COEFF_W-1 downto 0);
   begin
      TEMP := (others=>(others=>'0'));
      for i in A'range loop
         for j in B'range loop
            if (i+j) <= A'high then
               TEMP(i+j) := TEMP(i+j) xor f_gf_mul(A(i), B(j), PRIM_GF, 0);
            end if;
         end loop;
      end loop;
      return TEMP;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomial modulo
   -------------------------------------------------------------------------------
   function f_ext_poly_mod(constant A       : t_ext_poly; constant B       : t_ext_poly; constant PRIM_GF : std_logic_vector) return t_ext_poly is
      variable TEMP : t_ext_poly(A'range)(A(0)'range);
      variable DEG_B : integer;
      variable DEG_A : integer;
      variable SCALE : std_logic_vector(PRIM_GF'length-2 downto 0);
   begin
      TEMP := A;
      DEG_B := f_ext_poly_degree(B);
      while f_ext_poly_degree(TEMP) >= DEG_B loop
         DEG_A := f_ext_poly_degree(TEMP);
         SCALE := f_gf_mul(TEMP(DEG_A), f_gf_inverse(B(DEG_B), PRIM_GF), PRIM_GF, 0);
         for i in 0 to DEG_B loop
            TEMP(DEG_A-DEG_B+i) := TEMP(DEG_A-DEG_B+i) xor f_gf_mul(SCALE, B(i), PRIM_GF, 0);
         end loop;
      end loop;
      return TEMP;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomial GCD
   -------------------------------------------------------------------------------
   function f_ext_poly_gcd(constant A : t_ext_poly; constant B : t_ext_poly; constant PRIM_GF : std_logic_vector) return t_ext_poly is
      variable X : t_ext_poly(A'range)(A(0)'range);
      variable Y : t_ext_poly(A'range)(A(0)'range);
      variable R : t_ext_poly(A'range)(A(0)'range);
   begin
      X := A;
      Y := B;
      while f_ext_poly_degree(Y) >= 0 loop
         R := f_ext_poly_mod(X, Y, PRIM_GF);
         X := Y;
         Y := R;
      end loop;
      return X;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomial is zero
   -------------------------------------------------------------------------------
   function f_ext_poly_is_zero(constant A : t_ext_poly) return boolean is
   begin
      for i in A'range loop
         if A(i) /= (A(i)'range=>'0') then
            return false;
         end if;
      end loop;
      return true;
   end function;

   -------------------------------------------------------------------------------
   -- Extension polynomials A equal to polynomial B
   -------------------------------------------------------------------------------
   function f_ext_poly_equal(constant A : t_ext_poly; constant B : t_ext_poly) return boolean is
   begin
      for i in A'range loop
         if A(i) /= B(i) then
            return false;
         end if;
      end loop;
      return true;
   end function;
   
   -------------------------------------------------------------------------------
   -- Normalize an extension-field polynomial to monic form.
   --
   -- Multiplies every coefficient of the polynomial by the multiplicative
   -- inverse of its leading (highest-degree) non-zero coefficient, making the
   -- leading coefficient equal to one. If the input is the zero polynomial,
   -- it is returned unchanged.
   --
   -- Inputs:
   --   A        - Polynomial over the extension field.
   --   PRIM_GF  - Primitive polynomial defining the finite field arithmetic.
   --
   -- Returns:
   --   A monic polynomial representing the same polynomial scaled by a
   --   non-zero field element.
   -------------------------------------------------------------------------------
   function f_ext_poly_monic(constant A : t_ext_poly; constant PRIM_GF : std_logic_vector) return t_ext_poly is
      variable RESULT : t_ext_poly(A'range)(A(0)'range);
      variable DEG : integer;
      variable INV : std_logic_vector(PRIM_GF'length-2 downto 0);
   begin
      RESULT := A;
      DEG := f_ext_poly_degree(A);
      if DEG < 0 then
         return RESULT;
      end if;
      INV := f_gf_inverse(RESULT(DEG), PRIM_GF);
      for i in RESULT'range loop
         RESULT(i) := f_gf_mul(RESULT(i), INV, PRIM_GF, 0);
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Raise a polynomial to an integer power modulo a polynomial.
   --
   -- Computes:
   --
   --    RESULT = A^POWER mod MOD_POLY
   --
   -- using the square-and-multiply (binary exponentiation) algorithm. All
   -- polynomial arithmetic is performed over the extension field defined by
   -- PRIM_GF, and intermediate results are reduced modulo MOD_POLY to prevent
   -- polynomial growth.
   --
   -- Inputs:
   --   A         - Base polynomial.
   --   POWER     - Non-negative integer exponent.
   --   MOD_POLY  - Modulus polynomial.
   --   PRIM_GF   - Primitive polynomial defining the finite field arithmetic.
   --
   -- Returns:
   --   A^POWER reduced modulo MOD_POLY.
   -------------------------------------------------------------------------------
   function f_ext_poly_power_mod(A : t_ext_poly; POWER : unsigned; MOD_POLY : t_ext_poly; PRIM_GF : std_logic_vector) return t_ext_poly is
      variable RESULT   : t_ext_poly(A'range)(A(0)'range);
      variable BASE     : t_ext_poly(A'range)(A(0)'range);
      variable TEMP     : t_ext_poly(A'range)(A(0)'range);
      variable P        : unsigned(POWER'range);
   begin
      assert POWER >= 0
      report "f_ext_poly_power_mod: negative exponent"
      severity failure;
      RESULT := (others=>(others=>'0'));
      RESULT(0)(RESULT(0)'right) := '1';
      BASE := A;
      P := POWER;
      while P /= 0 loop
         if P(0) = '1' then
            TEMP :=
               f_ext_poly_multiply(
                  RESULT,
                  BASE,
                  PRIM_GF
               );

            RESULT :=
               f_ext_poly_mod(
                  TEMP,
                  MOD_POLY,
                  PRIM_GF
               );
         end if;
         TEMP :=
            f_ext_poly_multiply(
               BASE,
               BASE,
               PRIM_GF
            );
         BASE :=
            f_ext_poly_mod(
               TEMP,
               MOD_POLY,
               PRIM_GF
            );
         P := shift_right(P, 1);
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Test whether a polynomial is irreducible over GF(2^m).
   --
   -- Implements Rabin's irreducibility test. For a polynomial f(x) of degree n,
   -- the function verifies that
   --
   --    gcd(f(x), x^(q^i) - x) = 1
   --
   -- for all i = 1 .. floor(n/2), where q = 2^m and m is determined by PRIM_GF.
   -- If any GCD has degree greater than zero, the polynomial is reducible.
   --
   -- Inputs:
   --   POLY     - Polynomial to test.
   --   PRIM_GF  - Primitive polynomial defining the extension field GF(2^m).
   --
   -- Returns:
   --   TRUE if POLY is irreducible over GF(2^m), FALSE otherwise.
   -------------------------------------------------------------------------------
   function f_ext_poly_is_irreducible(
      constant POLY : t_ext_poly;
      constant PRIM_GF : std_logic_vector
   ) return boolean is
      -- constant Q : integer := 2**(PRIM_GF'length-1);
      variable X : t_ext_poly(POLY'range)(POLY(0)'range);
      variable TEMP : t_ext_poly(POLY'range)(POLY(0)'range);
      variable G : t_ext_poly(POLY'range)(POLY(0)'range);
      variable DEG : integer;
      variable EXP : unsigned(255 downto 0);
   begin
      assert ((PRIM_GF'length-1)*DEG) <= EXP'high
      report "f_ext_poly_is_irreducible: exponent too large"
      severity failure;
      DEG := f_ext_poly_degree(POLY);
      if DEG <= 0 then
         return false;
      end if;
      X := (others=>(others=>'0'));
      X(1)(0) := '1';
      EXP := (others => '0');
      EXP((PRIM_GF'length-1)) := '1';
      TEMP :=
         f_ext_poly_power_mod(
            X,
            -- Q,
            EXP,
            POLY,
            PRIM_GF
         );
      TEMP(1)(0) := TEMP(1)(0) xor '1';
      G :=
         f_ext_poly_gcd(
            POLY,
            TEMP,
            PRIM_GF
         );
      if f_ext_poly_degree(G) /= 0 then
         return false;
      end if;
      EXP := (others => '0');
      EXP((PRIM_GF'length-1)*DEG) := '1';
      TEMP :=
         f_ext_poly_power_mod(
            X,
            -- Q**DEG,
            EXP,
            POLY,
            PRIM_GF
         );
      TEMP(1)(0) := TEMP(1)(0) xor '1';
      if f_ext_poly_degree(TEMP) /= -1 then
         return false;
      end if;
      return true;
   end function;

   -------------------------------------------------------------------------------
   -- Increment an extension polynomial treated as a binary counter.
   --
   -- Treats the entire t_ext_poly array as one contiguous binary value and
   -- increments it by one. The least significant bit is the rightmost bit of
   -- the first coefficient (RESULT(RESULT'low)), with carries propagating
   -- through each coefficient and then to subsequent coefficients.
   --
   -- No polynomial or finite-field arithmetic is performed; this is purely a
   -- bitwise binary increment operation. If the input is all ones, the result
   -- wraps around to all zeros.
   --
   -- Input:
   --   A - Binary value represented as a t_ext_poly.
   --
   -- Returns:
   --   A incremented by one.
   -------------------------------------------------------------------------------
   function f_increment_array(constant A : t_ext_poly) return t_ext_poly is
      variable RESULT   : t_ext_poly(A'range)(A(0)'range);
      variable CARRY    : std_logic := '1';
   begin
      RESULT := A;
      for i in RESULT'range loop
         for b in RESULT(i)'reverse_range loop
            if CARRY='1' then
               if RESULT(i)(b)='0' then
                  RESULT(i)(b) := '1';
                  CARRY := '0';
               else
                  RESULT(i)(b) := '0';
               end if;
            end if;
         end loop;
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Find an irreducible extension polynomial over GF(2^r).
   --
   -- Performs an exhaustive search for a monic polynomial of degree
   -- EXTENSION_DEGREE over the field defined by BASE_POLY. Candidate
   -- coefficients are enumerated until a polynomial is found that:
   --
   --   1. Is irreducible over GF(2^r).
   --   2. Has a root in the larger field GF(2^m) defined by ORIG_POLY.
   --
   -- The search fixes the leading coefficient to one and requires the constant
   -- coefficient to be non-zero. Remaining coefficients are enumerated in binary
   -- order.
   --
   -- Inputs:
   --   EXTENSION_DEGREE - Degree of the desired extension polynomial.
   --   BASE_POLY        - Primitive polynomial defining GF(2^r).
   --   ORIG_POLY        - Primitive polynomial defining GF(2^m), where m is a
   --                      multiple of r.
   --
   -- Returns:
   --   The first extension polynomial satisfying the above conditions.
   --   If no suitable polynomial is found, returns an all-zero polynomial.
   -------------------------------------------------------------------------------
   function f_find_extension_polynomial(
      constant EXTENSION_DEGREE  : integer;
      constant ALPHA             : std_logic_vector;
      constant BASE_POLY         : std_logic_vector;
      constant ORIG_POLY         : std_logic_vector;
      constant OMEGA             : std_logic_vector
   ) return t_ext_poly is
      constant C_COMP_W          : integer := BASE_POLY'length - 1;
      constant C_DATA_W          : integer := ORIG_POLY'length - 1;
      variable TEST_POLY         : t_ext_poly(0 to EXTENSION_DEGREE)(C_COMP_W - 1 downto 0);
      variable COEFF             : t_ext_poly(0 to EXTENSION_DEGREE)(C_COMP_W - 1 downto 0);
      variable ZERO_RET          : t_ext_poly(0 to EXTENSION_DEGREE)(C_COMP_W - 1 downto 0) := (others => (others => '0'));
      variable FOUND             : boolean := false;
      variable MAX_COUNT         : integer;
      constant C_ZERO_VEC        : std_logic_vector(C_COMP_W - 1 downto 0) := (others => '0');
      constant C_ZERO_ORIG       : std_logic_vector(C_DATA_W - 1 downto 0) := (others => '0');
   begin
      ---------------------------------------------------------------------------
      -- Degenerate case:
      --
      -- GF((2^m)^1) = GF(2^m)
      --
      -- No extension polynomial is required.
      -- Return a dummy degree-1 polynomial because the composite multiplier
      -- bypasses reduction when EXTENSION_DEGREE = 1.
      ---------------------------------------------------------------------------
      if EXTENSION_DEGREE = 1 then
         TEST_POLY := (others => (others => '0'));
         -- x + 1
         TEST_POLY(0)(0) := '1';
         TEST_POLY(1)(0) := '1';
      else
         ---------------------------------------------------------------------------
         -- u^s + ...
         ---------------------------------------------------------------------------
         TEST_POLY := (others => (others => '0'));
         TEST_POLY(EXTENSION_DEGREE)(0) := '1';
         ---------------------------------------------------------------------------
         -- coefficient search
         ---------------------------------------------------------------------------
         COEFF := (others => (others => '0'));
         -- MAX_COUNT :=
            -- (2**C_COMP_W - 1) *
            -- (2**(C_COMP_W * (EXTENSION_DEGREE - 1)));
         loop
            -- A0 must not be zero
            if COEFF(0) = C_ZERO_VEC then
               COEFF(0)(0) := '1';
            end if;
            for I in 0 to EXTENSION_DEGREE-1 loop
               TEST_POLY(I) := COEFF(I);
            end loop;
            if f_ext_poly_is_irreducible(TEST_POLY, BASE_POLY) then
               FOUND := true;
               exit;
            end if;
            COEFF := f_increment_array(COEFF);
            -- all coefficients exhausted?
            exit when COEFF = ZERO_RET;
         end loop;
         if not FOUND then
            return ZERO_RET;
         end if;
      end if;
      return TEST_POLY;
   end function;

   -------------------------------------------------------------------------------
   -- Find a root of an extension polynomial in GF(2^m).
   --
   -- Searches all non-zero elements of the field GF(2^m), represented as powers
   -- of the primitive element α, for a root β satisfying
   --
   --    EXT_POLY(β) = 0.
   --
   -- The coefficients of EXT_POLY belong to the subfield GF(2^r) and are first
   -- embedded into GF(2^m) using the subfield generator OMEGA before polynomial
   -- evaluation.
   --
   -- Inputs:
   --   EXT_POLY  - Polynomial over GF(2^r).
   --   OMEGA     - Generator of the embedded GF(2^r) subfield within GF(2^m).
   --   PRIM_POLY - Primitive polynomial defining GF(2^m).
   --
   -- Returns:
   --   A root β of EXT_POLY in GF(2^m), if one exists.
   --   If no root is found, returns the all-zero field element.
   -------------------------------------------------------------------------------
   -- -- function f_find_beta(
      -- -- constant EXT_POLY  : t_ext_poly;
      -- -- constant ALPHA     : std_logic_vector;
      -- -- constant OMEGA     : std_logic_vector;
      -- -- constant PRIM_POLY : std_logic_vector
   -- -- ) return std_logic_vector is
      -- -- constant C_DATA_W : integer := PRIM_POLY'length - 1;
      -- -- variable BETA     : std_logic_vector(C_DATA_W-1 downto 0);
      -- -- variable SUM      : std_logic_vector(C_DATA_W-1 downto 0);
      -- -- variable COEFF    : std_logic_vector(C_DATA_W-1 downto 0);
      -- -- variable ZERO_RET : std_logic_vector(C_DATA_W-1 downto 0) := (others => '0');
      -- -- -- Search counter, represents 0 ... 2^C_DATA_W-1
      -- -- variable K        : unsigned(C_DATA_W-1 downto 0);
   -- -- begin
      -- -- K := (others => '0');
      -- -- loop
         -- -- -- Skip zero element
         -- -- if K /= 0 then
            -- -- BETA := std_logic_vector(K);
            -- -- ---------------------------------------------------------------
            -- -- -- Evaluate Q(beta) using Horner's rule
            -- -- ---------------------------------------------------------------
            -- -- SUM := (others => '0');
            -- -- for I in EXT_POLY'reverse_range loop
               -- -- SUM := f_gf_mul(
                  -- -- SUM,
                  -- -- BETA,
                  -- -- PRIM_POLY,
                  -- -- 0
               -- -- );
               -- -- COEFF :=
                  -- -- f_embed_subfield_element(
                     -- -- EXT_POLY(I),
                     -- -- OMEGA,
                     -- -- PRIM_POLY
                  -- -- );
               -- -- SUM := SUM xor COEFF;
            -- -- end loop;
            -- -- ---------------------------------------------------------------
            -- -- -- Root found
            -- -- ---------------------------------------------------------------
            -- -- if SUM = ZERO_RET then
               -- -- return BETA;
            -- -- end if;
         -- -- end if;
         -- -- -------------------------------------------------------------------
         -- -- -- Increment search value
         -- -- -------------------------------------------------------------------
         -- -- K := K + 1;
         -- -- -------------------------------------------------------------------
         -- -- -- All possible values tested?
         -- -- -------------------------------------------------------------------
         -- -- exit when K = 0;
      -- -- end loop;
      -- -- return ZERO_RET;
   -- -- end function;
   function f_find_beta(
      constant EXT_POLY  : t_ext_poly;
      constant ALPHA     : std_logic_vector;
      constant OMEGA     : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
      constant C_COMP_W : integer := EXT_POLY(0)'length;
      constant C_DEG    : integer := EXT_POLY'length - 1;
      variable BETA : std_logic_vector(PRIM_POLY'length - 2 downto 0);
   begin
      BETA := (others => '0');
      -- No extension: GF(2^m)
      if C_DEG = 1 then
         return ALPHA;  -- or whatever your convention requires
      end if;
      -- beta = 0 + 1*beta + 0*beta^2 + ... + 0*beta^(k-1)
      BETA(C_COMP_W) := '1';
      return BETA;
   end function;

   -------------------------------------------------------------------------------
   -- Embed a GF(2^r) element into GF(2^m).
   --
   -- Converts an element from the subfield GF(2^r) into its equivalent
   -- representation in the larger field GF(2^m).
   --
   -- The input element is interpreted as:
   --
   --    COEFF = a0 + a1*w + a2*w^2 + ...
   --
   -- where w is the subfield generator represented by OMEGA in GF(2^m).
   -- The result is calculated as:
   --
   --    RESULT = sum(ai * OMEGA^i)
   --
   -- Since ai belongs to GF(2), multiplication by ai is equivalent to selecting
   -- the corresponding power of OMEGA.
   --
   -- Inputs:
   --   COEFF     - Element represented in GF(2^r) polynomial basis.
   --   OMEGA     - Representation of the GF(2^r) generator inside GF(2^m).
   --   PRIM_POLY - Primitive polynomial defining GF(2^m).
   --
   -- Returns:
   --   The same field element represented in GF(2^m).
   -------------------------------------------------------------------------------
   function f_embed_subfield_element(
      constant COEFF     : std_logic_vector;
      constant OMEGA     : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
      constant M : integer := OMEGA'length;
      variable RESULT : std_logic_vector(M-1 downto 0);
      variable POWER  : std_logic_vector(M-1 downto 0);
   begin
      ---------------------------------------------------------------------------
      -- Start with zero
      ---------------------------------------------------------------------------
      RESULT := (others => '0');
      ---------------------------------------------------------------------------
      -- Current power = omega^0 = 1
      ---------------------------------------------------------------------------
      POWER := (others => '0');
      POWER(0) := '1';
      ---------------------------------------------------------------------------
      -- Sum selected powers of omega
      ---------------------------------------------------------------------------
      for I in COEFF'range loop
         if COEFF(I) = '1' then
            RESULT := RESULT xor POWER;
         end if;
         ------------------------------------------------------------------------
         -- Next power of omega
         ------------------------------------------------------------------------
         if I /= COEFF'high then
            POWER := f_gf_mul(
                        POWER,
                        OMEGA,
                        PRIM_POLY,
                        0
                     );
         end if;
      end loop;
      return RESULT;
   end function;

/*    -------------------------------------------------------------------------------
   -- Find composite field basis matrix
   --
   -- Creates the basis transformation matrix between:
   --
   --   Composite basis:
   --
   --       {1, β, β², ..., β^(m-1)}
   --
   -- and the original GF(2^m) polynomial basis:
   --
   --       {1, α, α², ..., α^(m-1)}
   --
   -- Each matrix row contains one basis vector represented in GF(2^m).
   --
   -- Input:
   --   BETA      - extension field generator β represented in GF(2^m)
   --   PRIM_POLY - primitive polynomial of GF(2^m)
   --
   -- Output:
   --   BASIS_MATRIX
   --
   --   Row i contains:
   --
   --       β^i
   --
   --   expressed in the original polynomial basis.
   --
   -- Matrix size:
   --
   --       m x m
   --
   -- where m = BETA'length
   --
   -------------------------------------------------------------------------------
   function f_find_basis_matrix(
      constant BETA      : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return t_basis_matrix is
      constant M : integer := BETA'length;
      variable MATRIX : t_basis_matrix;
      variable POWER  : std_logic_vector(M-1 downto 0);
   begin
      MATRIX := (others => (others => '0'));
      ---------------------------------------------------------------------------
      -- β^0 = 1
      ---------------------------------------------------------------------------
      POWER := (others => '0');
      POWER(0) := '1';
      ---------------------------------------------------------------------------
      -- Generate:
      --
      -- 1, β, β², ...
      --
      ---------------------------------------------------------------------------
      for I in 0 to M-1 loop
         MATRIX(I) := POWER;
         POWER :=
            f_gf_mul(
               POWER,
               BETA,
               PRIM_POLY,
               0
            );
      end loop;
      return MATRIX;
   end function;
 */

   -------------------------------------------------------------------------------
   -- GF(2) matrix inversion
   --
   -- Calculates inverse of binary matrix:
   --
   --        A * A^-1 = I
   --
   -- Operations:
   --
   --        addition       -> XOR
   --        multiplication -> AND
   --
   -- Uses Gauss-Jordan elimination.
   --
   -- Input:
   --
   --        MATRIX
   --
   --        m x m binary matrix
   --
   -- Output:
   --
   --        inverse matrix
   --
   -------------------------------------------------------------------------------
   function f_invert_gf2_matrix(
      constant MATRIX : t_basis_matrix
   ) return t_basis_matrix is
      constant M        : integer := MATRIX'length;
      variable AUG      : t_gf2_aug_matrix(0 to M - 1)(2*M - 1 downto 0);
      variable TEMP     : std_logic;
      variable RESULT   : t_basis_matrix(0 to M - 1)(M - 1 downto 0);
      variable PIVOT    : integer;
   begin
      ---------------------------------------------------------------------------
      -- Build [A | I]
      ---------------------------------------------------------------------------
      for ROW in 0 to M-1 loop
         for COL in 0 to M-1 loop
            AUG(ROW)(COL) := MATRIX(ROW)(COL);
         end loop;
         for COL in 0 to M-1 loop
            if ROW = COL then
               AUG(ROW)(M+COL) := '1';
            else
               AUG(ROW)(M+COL) := '0';
            end if;
         end loop;
      end loop;
      ---------------------------------------------------------------------------
      -- Gauss-Jordan elimination
      ---------------------------------------------------------------------------
      for COL in 0 to M-1 loop
         ------------------------------------------------------------------------
         -- Find pivot
         ------------------------------------------------------------------------
         PIVOT := COL;
         while (PIVOT < M) and (AUG(PIVOT)(COL)='0') loop
            PIVOT := PIVOT + 1;
         end loop;
         ------------------------------------------------------------------------
         -- Matrix must be invertible
         ------------------------------------------------------------------------
         if PIVOT = M then
            RESULT := (others => (others => '0'));
            return RESULT;
         end if;
         ------------------------------------------------------------------------
         -- Swap rows
         ------------------------------------------------------------------------
         if PIVOT /= COL then
            for I in 0 to 2*M-1 loop
               TEMP := AUG(COL)(I);
               AUG(COL)(I) := AUG(PIVOT)(I);
               AUG(PIVOT)(I) := TEMP;
            end loop;
         end if;
         ------------------------------------------------------------------------
         -- Eliminate other rows
         ------------------------------------------------------------------------
         for ROW in 0 to M-1 loop
            if ROW /= COL then
               if AUG(ROW)(COL)='1' then
                  for I in 0 to 2*M-1 loop
                     AUG(ROW)(I) :=
                        AUG(ROW)(I) xor AUG(COL)(I);
                  end loop;
               end if;
            end if;
         end loop;
      end loop;
      ---------------------------------------------------------------------------
      -- Extract right side
      ---------------------------------------------------------------------------
      for ROW in 0 to M-1 loop
         for COL in 0 to M-1 loop
            RESULT(ROW)(COL) := AUG(ROW)(M+COL);
         end loop;
      end loop;
      return RESULT;
   end function;



   -------------------------------------------------------------------------------
   -- Convert a GF(2^m) element into composite field coefficients.
   --
   -- Applies a basis transformation matrix to convert the input GF(2^m) element
   -- from its standard binary representation into a composite-field
   -- representation consisting of multiple GF(2^r) coefficients.
   --
   -- The transformation is:
   --
   --    FLAT_RESULT = BASIS * DATA_IN
   --
   -- over GF(2), where multiplication is AND and addition is XOR.
   --
   -- The transformed binary vector is then split into C_COMP_W-bit subfield
   -- coefficients:
   --
   --    RESULT = (a0, a1, ..., an-1)
   --
   -- where each coefficient belongs to GF(2^r).
   --
   -- Inputs:
   --   DATA_IN  - GF(2^m) element in binary basis representation.
   --   BASIS    - Basis conversion matrix over GF(2).
   --   C_COMP_W - Width of each composite-field coefficient.
   --
   -- Returns:
   --   The equivalent composite-field representation.
   -------------------------------------------------------------------------------
   function f_gf_to_composite(
      constant DATA_IN  : std_logic_vector;
      constant BASIS    : t_basis_matrix;
      constant C_COMP_W : integer
   ) return t_symbol is
      variable TEMP   : std_logic;
      constant C_DATA_W : integer := DATA_IN'length;
      constant C_COMP_N : integer := C_DATA_W / C_COMP_W;
      variable FLAT_RESULT : std_logic_vector(C_DATA_W-1 downto 0);
      variable RESULT : t_symbol(0 to C_COMP_N-1)(C_COMP_W-1 downto 0);
   begin
      FLAT_RESULT := (others => '0');
      for ROW in 0 to C_DATA_W-1 loop
         for COL in 0 to C_DATA_W-1 loop
            if BASIS(ROW)(COL)='1' then
               FLAT_RESULT(ROW) := FLAT_RESULT(ROW) xor DATA_IN(COL);
            end if;
         end loop;
      end loop;
      ----------------------------------------------------------------
      -- Split flat vector into subfield coefficients
      ----------------------------------------------------------------
      for I in 0 to C_COMP_N-1 loop
         RESULT(I) := FLAT_RESULT((I+1)*C_COMP_W-1 downto I*C_COMP_W);
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Composite polynomial multiplication.
   --
   -- Performs carry-less polynomial multiplication over GF(2^r) without
   -- reduction by the extension polynomial.
   --
   -- The input operands are interpreted as polynomials in β:
   --
   --   A(β) = A0 + A1β + ... + A(k-1)β^(k-1)
   --   B(β) = B0 + B1β + ... + B(k-1)β^(k-1)
   --
   -- where each coefficient belongs to GF(2^r).
   --
   -- Returns:
   --   Unreduced polynomial product of degree up to 2k-2.
   ------------------------------------------------------------------------------- 
   function f_composite_poly_mul(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH : integer := 0
   ) return t_composite_poly is
      constant COEFF_N : integer := A'length;
      constant COEFF_W : integer := A(0)'length;
      variable PRODUCT : t_composite_poly(0 to 2*COEFF_N-2)(COEFF_W-1 downto 0);
   begin
      ---------------------------------------------------------------------------
      -- Width checks
      ---------------------------------------------------------------------------
      PRODUCT := (others => (others => '0'));
      for I in 0 to COEFF_N-1 loop
         for J in 0 to COEFF_N-1 loop
            PRODUCT(I+J) :=
               PRODUCT(I+J)
               xor
               f_gf_mul(
                  A(I),
                  B(J),
                  SUB_POLY,
                  MUL_ARCH
               );
         end loop;
      end loop;
      return PRODUCT;
   end function;

   -------------------------------------------------------------------------------
   -- Multiply two elements in a composite extension field GF((2^r)^s).
   --
   -- Treats the input symbols as polynomials in β:
   --
   --    A(β) = a0 + a1β + ... + a(s-1)β^(s-1)
   --    B(β) = b0 + b1β + ... + b(s-1)β^(s-1)
   --
   -- Performs polynomial multiplication using convolution, where coefficient
   -- multiplication is performed in GF(2^r). The resulting polynomial is then
   -- reduced modulo the extension polynomial:
   --
   --    Q(β) = β^s + q(s-1)β^(s-1) + ... + q0
   --
   -- Inputs:
   --   A        - First composite-field element.
   --   B        - Second composite-field element.
   --   EXT_POLY - Extension polynomial coefficients q0..q(s-1).
   --   SUB_POLY - Primitive polynomial defining GF(2^r).
   --
   -- Returns:
   --   The product A(β)*B(β) reduced to degree less than s.
   -------------------------------------------------------------------------------
   function f_composite_mul(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant EXT_POLY : t_ext_poly;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH  : integer := 0
   ) return t_symbol is
      constant COEFF_N  : integer := A'length;     -- number of coefficients (s)
      constant COEFF_W  : integer := A(0)'length;  -- coefficient width (r)
      variable PRODUCT  : t_composite_poly(0 to 2 * COEFF_N - 2)(COEFF_W - 1 downto 0);
      variable RESULT   : t_symbol(0 to COEFF_N - 1)(COEFF_W - 1 downto 0);
      variable TEMP     : std_logic_vector(COEFF_W - 1 downto 0);
   begin
      ---------------------------------------------------------------------------
      -- Initialise
      ---------------------------------------------------------------------------
      PRODUCT := (others=>(others=>'0'));
      ---------------------------------------------------------------------------
      -- Polynomial multiplication
      --
      -- convolution:
      --
      -- C[k] += A[i]*B[j]
      --
      ---------------------------------------------------------------------------
      case MUL_ARCH is
         when 1 =>
            if(COEFF_N mod 2 = 0) then
               -- PRODUCT := f_composite_poly_mul_karatsuba_2(
               PRODUCT := f_composite_poly_mul_karatsuba(
                              A,
                              B,
                              SUB_POLY,
                              MUL_ARCH
                           );
            else
               PRODUCT := f_composite_poly_mul(
                              A,
                              B,
                              SUB_POLY,
                              MUL_ARCH
                           );
            end if;
         when others =>
            PRODUCT := f_composite_poly_mul(
                           A,
                           B,
                           SUB_POLY,
                           MUL_ARCH
                        );
      end case;
      PRODUCT := f_composite_poly_mul(
              A,
              B,
              SUB_POLY,
              MUL_ARCH
           );
      ---------------------------------------------------------------------------
      -- Polynomial reduction
      --
      -- Q(x)=x^S + q(S-1)x^(S-1)+...+q0
      --
      ---------------------------------------------------------------------------
      if COEFF_N > 1 then
         for DEG in 2 * COEFF_N - 2 downto COEFF_N loop
            if PRODUCT(DEG) /= (PRODUCT(DEG)'range=>'0') then
               for I in 0 to COEFF_N - 1 loop
                  PRODUCT(DEG - COEFF_N + I) :=
                     PRODUCT(DEG - COEFF_N + I)
                     xor
                     f_gf_mul(
                        PRODUCT(DEG),
                        EXT_POLY(I),
                        SUB_POLY,
                        MUL_ARCH
                     );
               end loop;
            end if;
         end loop;
      end if;
      ---------------------------------------------------------------------------
      -- Output coefficients
      ---------------------------------------------------------------------------
      for I in 0 to COEFF_N - 1 loop
         RESULT(I) := PRODUCT(I);
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Add two elements in a composite extension field GF((2^r)^s).
   --
   -- Performs coefficient-wise addition of two composite-field elements.
   -- Since the field characteristic is two, addition is equivalent to XOR:
   --
   --    C(i) = A(i) xor B(i)
   --
   -- No polynomial reduction is required because addition does not increase the
   -- polynomial degree.
   --
   -- Inputs:
   --   A - First composite-field element.
   --   B - Second composite-field element.
   --
   -- Returns:
   --   The sum A + B in GF((2^r)^s).
   -------------------------------------------------------------------------------
   function f_composite_add(
      constant A : t_symbol;
      constant B : t_symbol
   ) return t_symbol is
      constant COEFF_N  : integer := A'length;     -- number of coefficients (s)
      constant COEFF_W  : integer := A(0)'length;  -- coefficient width (r)
      variable RESULT : t_symbol(0 to COEFF_N - 1)(COEFF_W - 1 downto 0);
   begin
      for I in 0 to COEFF_N - 1 loop
         RESULT(I) := A(I) xor B(I);
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Convert a composite-field element into GF(2^m) polynomial basis.
   --
   -- Converts an element represented in the composite field:
   --
   --    A0 + A1*β + ... + A(s-1)*β^(s-1)
   --
   -- into its equivalent representation in the original GF(2^m) polynomial basis.
   --
   -- The conversion is performed using a basis transformation matrix:
   --
   --    RESULT = MATRIX * COMP_FLAT
   --
   -- over GF(2), where multiplication is AND and addition is XOR.
   --
   -- Inputs:
   --   DATA_IN - Composite-field element:
   --             DATA_IN(0) = A0
   --             DATA_IN(1) = A1
   --             ...
   --
   --   MATRIX  - Basis transformation matrix generated for the composite field.
   --
   -- Returns:
   --   Equivalent GF(2^m) polynomial basis representation.
   -------------------------------------------------------------------------------
   function f_composite_to_gf(
      constant DATA_IN : t_symbol;
      constant MATRIX  : t_basis_matrix
   ) return std_logic_vector is
      constant S : integer := DATA_IN'length;
      constant R : integer := DATA_IN(0)'length;
      constant M : integer := S*R;
      variable COMP_FLAT : std_logic_vector(M-1 downto 0);
      variable RESULT : std_logic_vector(M-1 downto 0);
   begin
      ---------------------------------------------------------------------------
      -- Flatten composite coefficients
      --
      -- bit 0 .. R-1       = A0
      -- bit R .. 2R-1      = A1
      -- ...
      ---------------------------------------------------------------------------
      for I in 0 to S-1 loop
         COMP_FLAT(
            (I+1)*R-1 downto I*R
         ) := DATA_IN(I);
      end loop;
      RESULT := (others=>'0');
      ---------------------------------------------------------------------------
      -- Matrix multiply over GF(2)
      ---------------------------------------------------------------------------
      for ROW in 0 to M-1 loop
         RESULT(ROW) := '0';
         for COL in 0 to M-1 loop
            if MATRIX(ROW)(COL)='1' then
               RESULT(ROW) := RESULT(ROW) xor COMP_FLAT(COL);
            end if;
         end loop;
      end loop;
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Generate a Reed-Solomon generator polynomial in composite-field format.
   --
   -- Constructs the generator polynomial:
   --
   --    g(x) = Π (x + α^(FIRST_ROOT+i))
   --
   --       i = 0 .. R-1
   --
   -- where α is a primitive element of GF(2^m).
   --
   -- The roots are generated in GF(2^m), converted into the composite-field
   -- representation, and the polynomial multiplication is performed in
   -- GF((2^r)^s).
   --
   -- Polynomial coefficients are stored as:
   --
   --    g(0), g(1), ..., g(R)
   --
   -- where each coefficient is represented as:
   --
   --    (A0, A1, ..., A(s-1))
   --
   -- Inputs:
   --   R                  - Number of roots / number of parity symbols.
   --   ALPHA              - Primitive element of GF(2^m).
   --   C_GF_TO_COMP       - Matrix converting GF(2^m) basis to composite basis
   --   EXT_POLY           - Composite extension polynomial.
   --   SUB_POLY           - Primitive polynomial defining GF(2^r).
   --   FIRST_ROOT         - Starting exponent of the generator roots.
   --
   -- Returns:
   --   RS generator polynomial coefficients in composite representation.
   -------------------------------------------------------------------------------
   function f_find_generator_poly(
      constant R                 : integer;
      constant ALPHA             : std_logic_vector;   
      constant ORIG_POLY         : std_logic_vector;
      constant C_GF_TO_COMP      : t_basis_matrix;
      constant EXT_POLY          : t_ext_poly;
      constant SUB_POLY          : std_logic_vector;
      constant FIRST_ROOT        : integer
   ) return t_gen_poly is
      constant DATA_W            : integer := ALPHA'length;
      constant C_COMP_W          : integer := SUB_POLY'length - 1;
      constant C_COMP_N          : integer := DATA_W / C_COMP_W;
      variable POLY              : t_gen_poly(0 to R)(0 to C_COMP_N-1)(C_COMP_W-1 downto 0);
      variable NEW_POLY          : t_gen_poly(0 to R)(0 to C_COMP_N-1)(C_COMP_W-1 downto 0);
      variable ROOT_GF           : std_logic_vector(DATA_W-1 downto 0);
      variable ROOT_COMP         : t_symbol(0 to C_COMP_N-1)(C_COMP_W-1 downto 0);
      variable ZERO_COMP         : t_symbol(0 to C_COMP_N-1)(C_COMP_W-1 downto 0);
      variable ONE_COMP          : t_symbol(0 to C_COMP_N-1)(C_COMP_W-1 downto 0);
   begin
      ---------------------------------------------------------------------------
      -- Initialise polynomial:
      --
      -- g(x)=1
      --
      ---------------------------------------------------------------------------
      ZERO_COMP := (others => (others=>'0'));
      ONE_COMP  := ZERO_COMP;
      -- coefficient = 1 in GF(2^r)
      ONE_COMP(0)(0) := '1';
      POLY := (others => ZERO_COMP);
      POLY(0) := ONE_COMP;
      ---------------------------------------------------------------------------
      -- Multiply by:
      --
      -- (x + root)
      --
      ---------------------------------------------------------------------------
      for N in 0 to R-1 loop
         ------------------------------------------------------------------------
         -- root = alpha^(FIRST_ROOT+N)
         ------------------------------------------------------------------------
         ROOT_GF :=
            f_gf_power(
               ALPHA,
               FIRST_ROOT + N,
               ORIG_POLY
            );
         ROOT_COMP :=
            f_gf_to_composite(
               ROOT_GF,
               C_GF_TO_COMP,
               C_COMP_W
            );
         NEW_POLY := (others => ZERO_COMP);
         ------------------------------------------------------------------------
         -- Polynomial multiplication:
         --
         -- (a0+a1x+...)
         --
         -- *
         --
         -- (root+x)
         --
         ------------------------------------------------------------------------
         for I in 0 to N loop
            ---------------------------------------------------------------------
            -- x term
            ---------------------------------------------------------------------
            NEW_POLY(I+1) :=
               f_composite_add(
                  NEW_POLY(I+1),
                  POLY(I)
               );
            ---------------------------------------------------------------------
            -- constant root term
            ---------------------------------------------------------------------
            NEW_POLY(I) :=
               f_composite_add(
                  NEW_POLY(I),
                  f_composite_mul(
                     POLY(I),
                     ROOT_COMP,
                     EXT_POLY,
                     SUB_POLY,
                     0
                  )
               );
         end loop;
         POLY := NEW_POLY;
      end loop;
      return POLY;
   end function;
   
   -------------------------------------------------------------------------------
   -- Calculate sum of (2^kr−1)/(2^r−1) in way as 1+2^k+2^(2*k)+⋯+2^((r−1)*k)
   -------------------------------------------------------------------------------
   function f_exponent_sum(
      k    : integer;
      r    : integer
   ) return unsigned is
      variable result : unsigned(k * r - 1 downto 0) := (others => '0');
      variable term   : unsigned(k * r - 1 downto 0) := (others => '0');
   begin
      -- First term: 2^(0*r) = 1
      term(0) := '1';
      for i in 0 to k-1 loop
         -- Add 2^(i*r)
         result := result + term;
         -- Next term: multiply by 2^r
         term := shift_left(term, r);
      end loop;
      return result;
   end function;
   
   -------------------------------------------------------------------------------
   -- Calculate subfield generator omega.
   --
   -- Computes:
   --
   --    omega = alpha^((2^(k*r)-1)/(2^r-1))
   --
   -- which is equivalent to:
   --
   --    omega = alpha * alpha^(2^r) * alpha^(2^(2r)) * ... *
   --            alpha^(2^((k-1)r))
   --
   -- The computation avoids storing the large exponent explicitly.
   --
   -- Inputs:
   --   K         - Number of extension steps (C_COMP_DEG).
   --   R         - Subfield symbol width.
   --   ALPHA     - Primitive element of GF(2^(k*r)).
   --   PRIM_POLY - Primitive polynomial of GF(2^(k*r)).
   --
   -- Returns:
   --   Generator of GF(2^r) represented inside GF(2^(k*r)).
   -------------------------------------------------------------------------------
   function f_calc_omega(
      constant K         : integer;
      constant R         : integer;
      constant ALPHA     : std_logic_vector;
      constant PRIM_POLY : std_logic_vector
   ) return std_logic_vector is
      variable OMEGA : std_logic_vector(ALPHA'range);
      variable TEMP  : std_logic_vector(ALPHA'range);
   begin
      OMEGA := ALPHA;
      TEMP  := ALPHA;
      -- Generate:
      -- alpha, alpha^(2^r), alpha^(2^(2r)), ...
      if (K > 1) then
         for I in 1 to K-1 loop
            -- Frobenius map: x -> x^(2^r)
            TEMP := f_gf_frobenius(TEMP, R, PRIM_POLY);
            -- for J in 1 to R loop
               -- TEMP :=  f_gf_square(
                           -- TEMP,
                           -- PRIM_POLY
                        -- );
            -- end loop;
            OMEGA := f_gf_mul(
                        OMEGA,
                        TEMP,
                        PRIM_POLY,
                        0
                     );
         end loop;
      end if;
      return OMEGA;
   end function;


   -------------------------------------------------------------------------------
   -- Construct the composite-field basis matrix.
   --
   -- Builds the basis transformation matrix from the composite basis
   --
   --    {ω^j β^i}
   --
   -- into the polynomial basis of GF(2^m).
   --
   -- Basis ordering follows the composite representation:
   --
   --    A0 + A1β + ... + A(k-1)β^(k-1)
   --
   -- where each coefficient is stored as
   --
   --    a0 + a1ω + ... + a(r-1)ω^(r-1)
   --
   -- Consequently the basis vectors are generated in the order
   --
   --    1
   --    ω
   --    ω²
   --    ...
   --    β
   --    ωβ
   --    ...
   -------------------------------------------------------------------------------
   function f_find_comp_to_gf_basis(
      constant BETA      : std_logic_vector;
      constant OMEGA     : std_logic_vector;
      constant COMP_W    : integer;
      constant COMP_N    : integer;
      constant PRIM_POLY : std_logic_vector
   ) return t_basis_matrix is
      constant M : integer := BETA'length;
      variable MATRIX      : t_basis_matrix(0 to M-1)(M-1 downto 0);
      variable BETA_POWER  : std_logic_vector(M-1 downto 0);
      variable OMEGA_POWER : std_logic_vector(M-1 downto 0);
      variable BASIS       : std_logic_vector(M-1 downto 0);
      variable INDEX       : integer;
   begin
      if COMP_N = 1 then
         for I in 0 to M-1 loop
            MATRIX(I)(I) := '1';
         end loop;
      else
         ---------------------------------------------------------------------------
         -- β^0
         ---------------------------------------------------------------------------
         BETA_POWER := (others => '0');
         BETA_POWER(0) := '1';
         INDEX := 0;
         for I in 0 to COMP_N-1 loop
            ------------------------------------------------------------------------
            -- ω^0
            ------------------------------------------------------------------------
            OMEGA_POWER := (others => '0');
            OMEGA_POWER(0) := '1';
            for J in 0 to COMP_W-1 loop
               ---------------------------------------------------------------------
               -- Basis vector = β^i · ω^j
               ---------------------------------------------------------------------
               BASIS :=
                  f_gf_mul(
                     BETA_POWER,
                     OMEGA_POWER,
                     PRIM_POLY,
                     0
                  );

               for ROW in 0 to M-1 loop
                  MATRIX(ROW)(INDEX) := BASIS(ROW);
               end loop;
               INDEX := INDEX + 1;
               ---------------------------------------------------------------------
               -- ω^(j+1)
               ---------------------------------------------------------------------
               if J /= COMP_W-1 then
                  OMEGA_POWER :=
                     f_gf_mul(
                        OMEGA_POWER,
                        OMEGA,
                        PRIM_POLY,
                        0
                     );
               end if;
            end loop;
            ------------------------------------------------------------------------
            -- β^(i+1)
            ------------------------------------------------------------------------
            if I /= COMP_N-1 then
               BETA_POWER :=
                  f_gf_mul(
                     BETA_POWER,
                     BETA,
                     PRIM_POLY,
                     0
                  );
            end if;
         end loop;
      end if;
      return MATRIX;
   end function;
   
   
   -------------------------------------------------------------------------------
   -- Execute one RS encoder LFSR step.
   --
   -- Input:
   --   DATA_IN   - input symbol in composite representation
   --   PARITY    - current parity register contents
   --   GEN_POLY  - generator polynomial in composite representation
   --
   -- Returns:
   --   Updated parity registers.
   -------------------------------------------------------------------------------
   function f_rs_lfsr_step(
      constant DATA_IN     : t_symbol;
      constant PARITY      : t_parity_state;
      constant GEN_POLY    : t_gen_poly;
      constant EXT_POLY    : t_ext_poly;
      constant SUB_POLY    : std_logic_vector
   ) return t_parity_state is
      constant R : integer := PARITY'length;
      variable RESULT      : t_parity_state(0 to R-1)(DATA_IN'range)(DATA_IN(0)'range);
      variable FEEDBACK    : t_symbol(DATA_IN'range)(DATA_IN(0)'range);
      variable TEMP        : t_symbol(DATA_IN'range)(DATA_IN(0)'range);
   begin
      ---------------------------------------------------------------------------
      -- feedback = input + highest parity register
      ---------------------------------------------------------------------------
      FEEDBACK :=
         f_composite_add(
            DATA_IN,
            PARITY(R-1)
         );
      ---------------------------------------------------------------------------
      -- Shift LFSR
      ---------------------------------------------------------------------------
      for I in R-1 downto 1 loop
         TEMP :=
            f_composite_mul(
               FEEDBACK,
               GEN_POLY(I),
               EXT_POLY,
               SUB_POLY,
               0
            );
         RESULT(I) :=
            f_composite_add(
               PARITY(I-1),
               TEMP
            );
      end loop;
      ---------------------------------------------------------------------------
      -- Lowest register
      ---------------------------------------------------------------------------
      RESULT(0) :=
         f_composite_mul(
            FEEDBACK,
            GEN_POLY(0),
            EXT_POLY,
            SUB_POLY,
            0
         );
      return RESULT;
   end function;

   -------------------------------------------------------------------------------
   -- Composite polynomial multiplication using recursive Karatsuba.
   --
   -- Performs multiplication of polynomials over GF(2^r).
   --
   -- The coefficients are elements of the subfield GF(2^r), while the polynomial
   -- variable is the composite-field extension variable β.
   --
   -- Uses:
   --
   --   Z0 = A_LOW * B_LOW
   --   Z2 = A_HIGH * B_HIGH
   --   Z1 = (A_LOW+A_HIGH)*(B_LOW+B_HIGH)
   --
   -- and combines:
   --
   --   PRODUCT =
   --      Z0
   --      xor (Z1 xor Z0 xor Z2) shifted by HALF
   --      xor Z2 shifted by 2*HALF
   --
   -- For odd polynomial lengths or small sizes, schoolbook multiplication is used.
   -------------------------------------------------------------------------------
   function f_composite_poly_mul_karatsuba(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH : integer := 0
   ) return t_composite_poly is
      constant COEFF_N  : integer := A'length;
      constant COEFF_W  : integer := A(0)'length;
      constant LIMIT    : integer := 2;
      constant HALF     : integer := COEFF_N/2;
      variable RESULT   : t_composite_poly(0 to 2*COEFF_N-2)(COEFF_W-1 downto 0);
      variable A_LOW    : t_symbol(0 to HALF-1)(COEFF_W-1 downto 0);
      variable A_HIGH   : t_symbol(0 to HALF-1)(COEFF_W-1 downto 0);
      variable B_LOW    : t_symbol(0 to HALF-1)(COEFF_W-1 downto 0);
      variable B_HIGH   : t_symbol(0 to HALF-1)(COEFF_W-1 downto 0);
      variable A_SUM    : t_symbol(0 to HALF-1)(COEFF_W-1 downto 0);
      variable B_SUM    : t_symbol(0 to HALF-1)(COEFF_W-1 downto 0);
      variable Z0       : t_composite_poly(0 to 2*HALF-2)(COEFF_W-1 downto 0);
      variable Z1       : t_composite_poly(0 to 2*HALF-2)(COEFF_W-1 downto 0);
      variable Z2       : t_composite_poly(0 to 2*HALF-2)(COEFF_W-1 downto 0);
   begin

      ---------------------------------------------------------------------------
      -- Base case
      ---------------------------------------------------------------------------
      if (COEFF_N <= LIMIT) or ((COEFF_N mod 2) /= 0) then
         return f_composite_poly_mul(
            A,
            B,
            SUB_POLY,
            MUL_ARCH
         );
      else
         ------------------------------------------------------------------------
         -- Split operands
         ------------------------------------------------------------------------
         for I in 0 to HALF-1 loop
            A_LOW(I)  := A(I);
            A_HIGH(I) := A(I+HALF);
            B_LOW(I)  := B(I);
            B_HIGH(I) := B(I+HALF);
            A_SUM(I) := A_LOW(I) xor A_HIGH(I);
            B_SUM(I) := B_LOW(I) xor B_HIGH(I);
         end loop;
         ------------------------------------------------------------------------
         -- Recursive multiplications
         ------------------------------------------------------------------------
         Z0 :=
            f_composite_poly_mul_karatsuba(
               A_LOW,
               B_LOW,
               SUB_POLY,
               MUL_ARCH
            );
         Z2 :=
            f_composite_poly_mul_karatsuba(
               A_HIGH,
               B_HIGH,
               SUB_POLY,
               MUL_ARCH
            );
         Z1 :=
            f_composite_poly_mul_karatsuba(
               A_SUM,
               B_SUM,
               SUB_POLY,
               MUL_ARCH
            );
         ------------------------------------------------------------------------
         -- Combine
         ------------------------------------------------------------------------
         RESULT := (others => (others => '0'));
         for I in 0 to 2*HALF-2 loop
            RESULT(I) := RESULT(I) xor Z0(I);
            RESULT(I+HALF) := RESULT(I+HALF) xor Z1(I) xor Z0(I) xor Z2(I);
            RESULT(I+2*HALF) := RESULT(I+2*HALF) xor Z2(I);
         end loop;
         return RESULT;
      end if;
   end function;

   -------------------------------------------------------------------------------
   -- Composite polynomial multiplication using Karatsuba for k=2.
   --
   -- Multiplies two degree-1 polynomials over GF(2^r):
   --
   --   A(β)=A0+A1β
   --   B(β)=B0+B1β
   --
   -- using:
   --
   --   Z0 = A0*B0
   --   Z2 = A1*B1
   --   Z1 = (A0+A1)*(B0+B1)
   --
   -- The middle coefficient is:
   --
   --   Z1 + Z0 + Z2
   --
   -- Returns the unreduced polynomial:
   --
   --   Z0 + (Z1+Z0+Z2)β + Z2β²
   --
   -- Reduction by EXT_POLY is performed separately.
   -------------------------------------------------------------------------------
   function f_composite_poly_mul_karatsuba_2(
      constant A        : t_symbol;
      constant B        : t_symbol;
      constant SUB_POLY : std_logic_vector;
      constant MUL_ARCH : integer := 0
   ) return t_composite_poly is
      constant COEFF_W  : integer := A(0)'length;
      variable RESULT   : t_composite_poly(0 to 2)(COEFF_W-1 downto 0);
      variable Z0       : std_logic_vector(COEFF_W-1 downto 0);
      variable Z1       : std_logic_vector(COEFF_W-1 downto 0);
      variable Z2       : std_logic_vector(COEFF_W-1 downto 0);
      variable A_SUM : std_logic_vector(COEFF_W-1 downto 0);
      variable B_SUM : std_logic_vector(COEFF_W-1 downto 0);
   begin
      A_SUM := A(0) xor A(1);
      B_SUM := B(0) xor B(1);
      Z0 :=
         f_gf_mul(
            A(0),
            B(0),
            SUB_POLY,
            MUL_ARCH
         );
      Z2 :=
         f_gf_mul(
            A(1),
            B(1),
            SUB_POLY,
            MUL_ARCH
         );
      Z1 :=
         f_gf_mul(
            A_SUM,
            B_SUM,
            SUB_POLY,
            MUL_ARCH
         );
      RESULT(0) := Z0;
      RESULT(1) := Z1 xor Z0 xor Z2;
      RESULT(2) := Z2;
      return RESULT;
   end function;

end package body rs_math_pkg;
