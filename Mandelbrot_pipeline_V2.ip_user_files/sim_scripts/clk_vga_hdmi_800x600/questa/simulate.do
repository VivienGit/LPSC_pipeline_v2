onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib clk_vga_hdmi_800x600_opt

do {wave.do}

view wave
view structure
view signals

do {clk_vga_hdmi_800x600.udo}

run -all

quit -force
