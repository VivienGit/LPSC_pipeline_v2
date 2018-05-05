-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Mon Feb 26 16:04:44 2018
-- Host        : t450s-debian running 64-bit Debian GNU/Linux testing (buster)
-- Command     : write_vhdl -force -mode synth_stub -rename_top bram_video_memory_d786432_w9_rdclk1_wrclk1 -prefix
--               bram_video_memory_d786432_w9_rdclk1_wrclk1_ bram_memory_video_stub.vhdl
-- Design      : bram_memory_video
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a200tsbg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram_video_memory_d786432_w9_rdclk1_wrclk1 is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 19 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 8 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 8 downto 0 );
    clkb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 19 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 8 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 8 downto 0 )
  );

end bram_video_memory_d786432_w9_rdclk1_wrclk1;

architecture stub of bram_video_memory_d786432_w9_rdclk1_wrclk1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[19:0],dina[8:0],douta[8:0],clkb,web[0:0],addrb[19:0],dinb[8:0],doutb[8:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_1,Vivado 2017.4";
begin
end;
