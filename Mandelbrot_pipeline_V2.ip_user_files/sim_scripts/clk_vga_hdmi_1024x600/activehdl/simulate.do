onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+clk_vga_hdmi_1024x600 -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clk_vga_hdmi_1024x600 xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {clk_vga_hdmi_1024x600.udo}

run -all

endsim

quit -force
