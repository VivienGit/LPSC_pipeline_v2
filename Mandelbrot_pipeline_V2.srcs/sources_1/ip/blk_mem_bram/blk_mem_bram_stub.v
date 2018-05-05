// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Tue Apr 17 17:51:11 2018
// Host        : Vivien-HP running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Vivien/Documents/Master/S2/LPSC/Section11/mse_mandelbrot_no_bram/mse_mandelbrot.srcs/sources_1/ip/blk_mem_bram/blk_mem_bram_stub.v
// Design      : blk_mem_bram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2017.4" *)
module blk_mem_bram(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[19:0],dina[6:0],douta[6:0],clkb,web[0:0],addrb[19:0],dinb[6:0],doutb[6:0]" */;
  input clka;
  input [0:0]wea;
  input [19:0]addra;
  input [6:0]dina;
  output [6:0]douta;
  input clkb;
  input [0:0]web;
  input [19:0]addrb;
  input [6:0]dinb;
  output [6:0]doutb;
endmodule
