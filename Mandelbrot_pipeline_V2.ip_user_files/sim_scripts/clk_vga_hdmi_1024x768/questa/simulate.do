onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib clk_vga_hdmi_1024x768_opt

do {wave.do}

view wave
view structure
view signals

do {clk_vga_hdmi_1024x768.udo}

run -all

quit -force
