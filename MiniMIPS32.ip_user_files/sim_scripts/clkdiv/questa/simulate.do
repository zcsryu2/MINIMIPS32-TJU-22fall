onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib clkdiv_opt

do {wave.do}

view wave
view structure
view signals

do {clkdiv.udo}

run -all

quit -force
