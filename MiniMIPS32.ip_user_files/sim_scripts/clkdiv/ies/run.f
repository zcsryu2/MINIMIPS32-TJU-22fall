-makelib ies_lib/xpm -sv \
  "D:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../MiniMIPS32.srcs/sources_1/ip/clkdiv/clkdiv_clk_wiz.v" \
  "../../../../MiniMIPS32.srcs/sources_1/ip/clkdiv/clkdiv.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

