-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../../../../lab2/proj_miniRV_minisys/proj_single_cycle/proj_single_cycle.srcs/sources_1/i/cpuclk_1/cpuclk_clk_wiz.v" \
  "../../../../../../../../lab2/proj_miniRV_minisys/proj_single_cycle/proj_single_cycle.srcs/sources_1/i/cpuclk_1/cpuclk.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

