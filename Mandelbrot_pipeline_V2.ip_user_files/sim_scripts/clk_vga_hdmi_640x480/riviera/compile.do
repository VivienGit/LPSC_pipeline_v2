vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_640x480" "+incdir+../../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_640x480" \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_640x480/clk_vga_hdmi_640x480_sim_netlist.vhdl" \


vlog -work xil_defaultlib \
"glbl.v"

