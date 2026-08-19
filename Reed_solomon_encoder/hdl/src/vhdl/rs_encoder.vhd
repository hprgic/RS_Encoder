--------------------------------------------------------------------------------
-- Project      : Reed-Solomon Encoder Library
-- File         : rs_encoder.vhd
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
-- Reed-Solomon AXI4-Stream Encoder Front-End
--
-- This module provides an AXI4-Stream wrapper and buffering layer for the
-- Reed-Solomon parity generation engine. It converts incoming AXI4-Stream
-- data into the symbol-oriented interface required by the
-- rs_composite_parity_gen module and manages the transfer of parity data back
-- to the AXI4-Stream output interface.
--
-- The module accepts a stream of information symbols through an AXI4-Stream
-- slave interface, buffers the received payload, and forwards symbols to the
-- underlying Reed-Solomon parity generator. Once all message symbols have
-- been processed, the generated parity symbols are serialized and transmitted
-- through the AXI4-Stream master interface.
--
-- This block serves as the protocol adaptation layer between external AXI4-
-- Stream systems and the internal Reed-Solomon encoder datapath.
--
-- Features:
-- -----------------------------------------------------------------------------
-- • AXI4-Stream compliant input interface
-- • AXI4-Stream compliant output interface
-- • Input buffering and flow control
-- • Automatic conversion between AXI4-Stream transfers and RS symbols
-- • Support for configurable symbol widths
-- • Support for configurable RS(N,K) code parameters
-- • Support for multiple symbols per clock cycle
-- • Integration with the composite-field parity generator
--
-- Data Flow:
-- -----------------------------------------------------------------------------
-- AXI4-Stream Input
--         │
--         ▼
--   Input Buffering
--         │
--         ▼
-- rs_composite_parity_gen
--         │
--         ▼
--  Parity Serialization
--         │
--         ▼
-- AXI4-Stream Output
--
-- Operation:
-- -----------------------------------------------------------------------------
-- 1. Receive information symbols through the AXI4-Stream input interface.
-- 2. Buffer incoming data as required by the selected processing rate.
-- 3. Feed symbols to the Reed-Solomon parity generator.
-- 4. Wait for parity generation to complete.
-- 5. Serialize the generated parity symbols.
-- 6. Transmit parity symbols through the AXI4-Stream output interface.
--
-- The module does not implement the finite-field arithmetic directly.
-- All Reed-Solomon encoding calculations are performed by the underlying
-- rs_composite_parity_gen engine.
--
-- AXI4-Stream Signals:
-- -----------------------------------------------------------------------------
-- Input:
--   axis_in_tvalid  - Input data valid
--   axis_in_tready  - Encoder ready to accept data
--   axis_in_tdata   - Input symbols
--   axis_in_tlast   - End-of-frame indication
--   axis_in_tuser   - User-defined sideband information
--
-- Output:
--   axis_out_tvalid - Output parity valid
--   axis_out_tready - Downstream ready
--   axis_out_tdata  - Generated parity symbols
--   axis_out_tlast  - End-of-frame indication
--   axis_out_tuser  - User-defined sideband information
--
-- Dependencies:
-- -----------------------------------------------------------------------------
-- IEEE:
--   - ieee.std_logic_1164
--   - ieee.numeric_std
--
-- Internal:
--   - rs_math_pkg
--   - rs_composite_parity_gen
--
-- References:
-- -----------------------------------------------------------------------------
-- AMBA AXI4-Stream Protocol Specification
--
-- W. Wesley Peterson and E. J. Weldon
-- Error-Correcting Codes, Second Edition
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
use rs_enc_lib.rs_math_pkg.all;

entity rs_encoder is
   generic (
      C_MUL_ARCH        : integer range 0 to 2 := 1;     -- Multiplier architecture: 0-> SCHOOLBOOK; 1-> Karatsuba; 2-> Composite
      C_USE_COMP        : boolean := true;
      C_X_CLK           : integer range 1 to 4 := 1;     -- Use multiple clock rate for processing
      C_DPC             : integer range 1 to 32 := 1;    -- Paralel data per clock.
      C_USE_CUST_POLY   : integer range 0 to 1 := 0;     -- Use custom polynomial: 0 = predefined; 1 = custom
      C_CUSTOM_POLY     : std_logic_vector(32 downto 0) := "00000000010000000000000000000111"; -- Use custom polynomial: 0 = predefined; 1 = custom
      C_SYMB_W          : integer range 2 to 32 := 8; -- Symbol width (m) in bits. Supported range: 4 to 32.
      C_CODE_N          : integer := 255;        -- Codeword length (N) in symbols. Must satisfy: C_CODE_N <= (2**C_SYMB_W - 1).
      C_SYMB_K          : integer := 223         -- Number of information symbols (K).
                                             -- Number of parity symbols = C_CODE_N - C_SYMB_K must satisfy: 0 < C_SYMB_K < C_CODE_N.
   );
   
   port (
      clk               : in std_logic;   -- System clock.
      rst               : in std_logic;   -- Active-high synchronous reset.
   
      axis_in_tvalid    : in  std_logic;  -- AXI4-Sream input tvalid
      axis_in_tready    : out std_logic;  -- AXI4-Sream input tready
      axis_in_tlast     : in  std_logic;  -- AXI4-Sream input tlast
      axis_in_tuser     : in  std_logic;  -- AXI4-Sream input tuser
      axis_in_tdata     : in  std_logic_vector(C_X_CLK * C_SYMB_W - 1 downto 0); -- AXI4-Sream input tdata
   
      axis_out_tvalid   : out std_logic;  -- AXI4-Sream output tvalid
      axis_out_tready   : in  std_logic;  -- AXI4-Sream output tready
      axis_out_tlast    : out std_logic;  -- AXI4-Sream output tlast
      axis_out_tuser    : out std_logic;  -- AXI4-Sream output tuser
      axis_out_tdata    : out std_logic_vector(C_SYMB_W - 1 downto 0)   -- AXI4-Sream input tdata
   );
end entity rs_encoder;

architecture rtl of rs_encoder is
   
   ----------------------------------------------------------------------------
   -- CONSTANTS
   ----------------------------------------------------------------------------
   
   ----------------------------------------------------------------------------
   -- TYPES
   ----------------------------------------------------------------------------
   
   ----------------------------------------------------------------------------
   -- SIGNALS
   ----------------------------------------------------------------------------
   
begin
   
   u_parity_gen : entity rs_enc_lib.rs_composite_parity_gen
      generic map (
         C_MUL_ARCH   => C_MUL_ARCH,
         C_USE_COMP   => C_USE_COMP,
         C_SYMB_W     => C_SYMB_W,
         C_FIRST_ROOT => 0,
         C_CODE_N     => C_CODE_N,
         C_SYMB_K     => C_SYMB_K
      )
      port map (
         clk         => clk,
         rst         => rst,
         in_valid    => in_valid,
         in_ready    => in_ready,
         in_data     => in_data,
         
         out_valid   => out_valid,
         out_ready   => out_ready,
         out_data    => out_data,
      );
end rtl;