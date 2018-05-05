-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Thu Mar  1 19:51:19 2018
-- Host        : t450s-debian running 64-bit Debian GNU/Linux testing (buster)
-- Command     : write_vhdl -force -mode synth_stub -rename_top clk_mandelbrot -prefix
--               clk_mandelbrot_ clk_mandelbrot_stub.vhdl
-- Design      : clk_mandelbrot
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tsbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_mandelbrot is
  Port ( 
    ClkMandelxC : out STD_LOGIC;
    reset : in STD_LOGIC;
    PllLockedxSO : out STD_LOGIC;
    ClkSys100MhzxC : in STD_LOGIC
  );

end clk_mandelbrot;

architecture stub of clk_mandelbrot is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "ClkMandelxC,reset,PllLockedxSO,ClkSys100MhzxC";
begin
end;
