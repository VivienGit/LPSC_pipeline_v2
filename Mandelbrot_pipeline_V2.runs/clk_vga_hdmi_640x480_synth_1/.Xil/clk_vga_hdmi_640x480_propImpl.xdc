set_property SRC_FILE_INFO {cfile:/home/joco/Documents/cours/FPGA/master/nexys_video/mse_mandelbrot/mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_640x480/clk_vga_hdmi_640x480.xdc rfile:../../../mse_mandelbrot.srcs/sources_1/ip/clk_vga_hdmi_640x480/clk_vga_hdmi_640x480.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports ClkSys100MhzxC]] 0.1
