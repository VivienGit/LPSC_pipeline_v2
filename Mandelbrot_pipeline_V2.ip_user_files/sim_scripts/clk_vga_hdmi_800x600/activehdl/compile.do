vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_800x600" "+incdir+../../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_800x600" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_800x600/clk_vga_hdmi_800x600_sim_netlist.vhdl" \


vlog -work xil_defaultlib \
"glbl.v"

