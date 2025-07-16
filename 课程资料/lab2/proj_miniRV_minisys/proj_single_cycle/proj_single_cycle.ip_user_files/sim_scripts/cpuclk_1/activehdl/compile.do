vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../ipstatic" \
"D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../ipstatic" \
"../../../../../../../../lab2/proj_miniRV_minisys/proj_single_cycle/proj_single_cycle.srcs/sources_1/i/cpuclk_1/cpuclk_clk_wiz.v" \
"../../../../../../../../lab2/proj_miniRV_minisys/proj_single_cycle/proj_single_cycle.srcs/sources_1/i/cpuclk_1/cpuclk.v" \

vlog -work xil_defaultlib \
"glbl.v"

