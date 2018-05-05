// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Mon Feb 26 16:04:43 2018
// Host        : t450s-debian running 64-bit Debian GNU/Linux testing (buster)
// Command     : write_verilog -force -mode synth_stub -rename_top bram_video_memory_d786432_w9_rdclk1_wrclk1 -prefix
//               bram_video_memory_d786432_w9_rdclk1_wrclk1_ bram_memory_video_stub.v
// Design      : bram_memory_video
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tsbg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2017.4" *)
module bram_video_memory_d786432_w9_rdclk1_wrclk1(clka, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[19:0],dina[8:0],douta[8:0],clkb,web[0:0],addrb[19:0],dinb[8:0],doutb[8:0]" */;
  input clka;
  input [0:0]wea;
  input [19:0]addra;
  input [8:0]dina;
  output [8:0]douta;
  input clkb;
  input [0:0]web;
  input [19:0]addrb;
  input [8:0]dinb;
  output [8:0]doutb;
endmodule
