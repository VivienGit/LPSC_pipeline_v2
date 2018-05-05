// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Thu Mar  1 19:51:19 2018
// Host        : t450s-debian running 64-bit Debian GNU/Linux testing (buster)
// Command     : write_verilog -force -mode synth_stub -rename_top clk_mandelbrot -prefix
//               clk_mandelbrot_ clk_mandelbrot_stub.v
// Design      : clk_mandelbrot
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_mandelbrot(ClkMandelxC, reset, PllLockedxSO, 
  ClkSys100MhzxC)
/* synthesis syn_black_box black_box_pad_pin="ClkMandelxC,reset,PllLockedxSO,ClkSys100MhzxC" */;
  output ClkMandelxC;
  input reset;
  output PllLockedxSO;
  input ClkSys100MhzxC;
endmodule
