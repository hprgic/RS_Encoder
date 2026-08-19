--------------------------------------------------------------------------------
-- Project      : Reed-Solomon Encoder Library
-- File         : rs_pkg.vhd
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
-- Reed-Solomon Package
--
-- This package contains constants, type definitions, and field-related data
-- structures used throughout the Reed-Solomon encoder library.
--
-- The package provides:
--
--   • Primitive polynomial definitions for GF(2^m), m = 2..32
--   • Composite-field data types
--   • Generator polynomial storage types
--   • Parity-state storage types
--   • Generic finite-field arithmetic support structures
--
-- The definitions in this package are shared by the Reed-Solomon encoder,
-- parity generator, finite-field arithmetic modules, and composite-field
-- transformation functions.
--
-- Primitive Polynomials:
-- -----------------------------------------------------------------------------
-- A table of primitive (reduction) polynomials for extension fields
-- GF(2^m) is provided for field sizes ranging from 2 to 32 bits.
--
-- Polynomials are stored including the leading coefficient x^m.
--
-- Example:
--
--      p(x) = x^8 + x^4 + x^3 + x^2 + 1
--
-- is represented as:
--
--      "100011101"
--
-- where bit i corresponds to the coefficient of x^i.
--
-- These polynomials are used for:
--
--   • Finite-field multiplication reduction
--   • Primitive element generation
--   • Generator polynomial construction
--   • Composite-field decomposition
--   • Basis transformation generation
--
-- Composite-Field Support:
-- -----------------------------------------------------------------------------
-- The package defines generic unconstrained array types used to represent
-- elements of:
--
--      GF(2^m)
--
-- and composite fields:
--
--      GF((2^r)^k)
--
-- Composite-field elements are stored as arrays of subfield coefficients,
-- enabling arithmetic implementations based on:
--
--   • Schoolbook multiplication
--   • Karatsuba multiplication
--   • Composite-field multiplication
--
-- These types are intentionally unconstrained to support arbitrary field
-- sizes and extension degrees determined during elaboration.
--
-- Type Overview:
-- -----------------------------------------------------------------------------
-- t_symbol
--      Composite-field symbol represented as an array of subfield elements.
--
-- t_parity_arr
--      Array of parity-state symbols used by Reed-Solomon encoders.
--
-- t_mult_arr
--      Array used for intermediate multiplication results.
--
-- t_gen_poly
--      Generator polynomial coefficient storage.
--
-- t_composite_poly
--      Polynomial represented in composite-field coordinates.
--
-- Constants:
-- -----------------------------------------------------------------------------
-- C_KARATSUBA_LIMIT
--      Threshold used by arithmetic generators to determine when Karatsuba
--      multiplication becomes advantageous.
--
-- CP_PRIMITIVE_POLYNOMIAL
--      Lookup table containing primitive polynomials for GF(2^m),
--      m = 2..32.
--
-- Dependencies:
-- -----------------------------------------------------------------------------
-- IEEE:
--   - ieee.std_logic_1164
--   - ieee.numeric_std
--
-- References:
-- -----------------------------------------------------------------------------
-- R. Lidl and H. Niederreiter
-- Introduction to Finite Fields and Their Applications
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

package rs_pkg is
   
   ----------------------------------------------------------------------------
   -- Primitive (reduction) polynomials.
   --
   -- The leading coefficient x^m is is NOT omitted here.
   --
   -- Example:
   --      x^8 + x^4 + x^3 + x^2 + 1
   --
   -- is stored as:
   --
   --      "100011101"
   --
   -- where bit i corresponds to coefficient of x^i.
   ----------------------------------------------------------------------------
   constant C_KARATSUBA_LIMIT : integer := 8;
   constant CP_PRIM_POLY_MAX : integer := 32;
   type t_pol_arr is array (0 to 30) of std_logic_vector(CP_PRIM_POLY_MAX downto 0);
   constant CP_PRIMITIVE_POLYNOMIAL : t_pol_arr := ("000000000000000000000000000000111",  -- x^2  + x^1  + 1
                                                    "000000000000000000000000000001011",  -- x^3  + x^1  + 1
                                                    "000000000000000000000000000010011",  -- x^4  + x^1  + 1
                                                    "000000000000000000000000000100101",  -- x^5  + x^2  + 1
                                                    "000000000000000000000000001000011",  -- x^6  + x^1  + 1
                                                    "000000000000000000000000010001001",  -- x^7  + x^3  + 1
                                                    "000000000000000000000000100011101",  -- x^8  + x^4  + x3 + x2 + 1
                                                    "000000000000000000000001000010001",  -- x^9  + x^4  + 1
                                                    "000000000000000000000010000001001",  -- x^10 + x^3  + 1
                                                    "000000000000000000000100000000101",  -- x^11 + x^2  + 1
                                                    "000000000000000000001000001010011",  -- x^12 + x^6  + x^4 + x^1 + 1
                                                    "000000000000000000010000000011011",  -- x^13 + x^4  + x^3 + x^1 + 1
                                                    "000000000000000000100000101000011",  -- x^14 + x^8  + x^6 + x^1 + 1
                                                    "000000000000000001000000000000011",  -- x^15 + x^1  + 1
                                                    "000000000000000010000001111011101",  -- x^16 + x^9  + x^8 + x^7 + x^6 + x^4 + x^3 + x^2 + 1
                                                    "000000000000000100000000000001001",  -- x^17 + x^3  + 1
                                                    "000000000000001000000000000111111",  -- x^18 + x^5  + x^4 + x^3 + x^2 + x^1 + 1
                                                    "000000000000010000000000000100111",  -- x^19 + x^5  + x^2 + x^1 + 1
                                                    "000000000000100000000000000001001",  -- x^20 + x^3  + 1
                                                    "000000000001000000000000000000101",  -- x^21 + x^2  + 1
                                                    "000000000010000000000000000000011",  -- x^22 + x^1  + 1
                                                    "000000000100000000000000000100001",  -- x^23 + x^5  + 1
                                                    "000000001000000000000000010000111",  -- x^24 + x^7  + x^2 + x^1 + 1
                                                    "000000010000000000000000000001001",  -- x^25 + x^3  + 1
                                                    "000000100000000000000000001000111",  -- x^26 + x^6  + x^2 + x^1 + 1 
                                                    "000001000000000000000000000100111",  -- x^27 + x^5  + x^2 + x^1 + 1
                                                    "000010000000000000000000000001001",  -- x^28 + x^3  + 1
                                                    "000100000000000000000000000000101",  -- x^29 + x^2  + 1
                                                    "001000000100000000000000000000111",  -- x^30 + x^23 + x^2 + x^1 + 1
                                                    "010000000000000000000000000001001",  -- x^31 + x^3  + 1
                                                    "100000000010000000000000000000111"); -- x^32 + x^22 + x^2 + x^1 + 1


   ----------------------------------------------------------------
   -- COMPOSITE SYMBOL TYPE
   ----------------------------------------------------------------
   type t_symbol           is array (natural range <>) of std_logic_vector;
   type t_parity_arr       is array (natural range <>) of t_symbol;
   type t_mult_arr         is array (natural range <>) of t_symbol;
   type t_gen_poly         is array (natural range <>) of t_symbol;
   type t_composite_poly   is array (natural range <>) of std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Extension field polynomial types
   -------------------------------------------------------------------------------
   type t_ext_poly is array (natural range <>) of std_logic_vector;
   type t_basis_matrix is array (natural range <>) of std_logic_vector;
   type t_gf2_aug_matrix is array(natural range <>) of std_logic_vector;
   
   -------------------------------------------------------------------------------
   -- Parity types
   -------------------------------------------------------------------------------
   type t_parity_state is array (natural range <>) of t_symbol;
   
end package rs_pkg;
   
package body rs_pkg is
end package body rs_pkg;