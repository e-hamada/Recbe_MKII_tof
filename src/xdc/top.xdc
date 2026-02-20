
# Pin assign --
#  ---------------------------------------------------------------------

# System ---------------------------------------------------------------
set_property PACKAGE_PIN E11 [get_ports i_lc_sckp]
set_property PACKAGE_PIN D11 [get_ports i_lc_sckn]
set_property PACKAGE_PIN H22 [get_ports i_pushsw]
set_property PACKAGE_PIN D25 [get_ports {o_led[1]}]
set_property PACKAGE_PIN E25 [get_ports {o_led[2]}]
set_property PACKAGE_PIN E23 [get_ports {o_led[3]}]
set_property PACKAGE_PIN F23 [get_ports {o_led[4]}]
#set_property PACKAGE_PIN J24 [get_ports {i_lemoin}]
#set_property PACKAGE_PIN J25 [get_ports {o_lemo}]
#
## GTX ------------------------------------------------------------------
set_property PACKAGE_PIN R3 [get_ports i_sfp_rx_n]
set_property PACKAGE_PIN R4 [get_ports i_sfp_rx_p]
set_property PACKAGE_PIN P1 [get_ports o_sfp_tx_n]
set_property PACKAGE_PIN P2 [get_ports o_sfp_tx_p]
set_property PACKAGE_PIN H6 [get_ports i_gtref_156mp]
set_property PACKAGE_PIN H5 [get_ports i_gtref_156mn]
#
##  ---------------------------------------------------------------------
## Port attribute --
##  ---------------------------------------------------------------------
#
## System ---------------------------------------------------------------
set_property IOSTANDARD LVDS_25 [get_ports i_lc_sckp]
set_property IOSTANDARD LVCMOS33 [get_ports i_pushsw]
set_property IOSTANDARD LVCMOS33 [get_ports {o_led[*]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {i_lemoin}]
#set_property IOSTANDARD LVCMOS33 [get_ports {o_lemo}]

## tof seu---------------------------------------------------------
set_property PACKAGE_PIN J24 [get_ports TRIG_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports TRIG_OUT]



set_property PACKAGE_PIN E26 [get_ports {dip[0]}]
set_property PACKAGE_PIN F25 [get_ports {dip[1]}]
set_property PACKAGE_PIN F24 [get_ports {dip[2]}]
set_property PACKAGE_PIN G26 [get_ports {dip[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dip[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dip[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dip[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dip[0]}]
set_property PULLUP true [get_ports {dip[3]}]
set_property PULLUP true [get_ports {dip[2]}]
set_property PULLUP true [get_ports {dip[1]}]
set_property PULLUP true [get_ports {dip[0]}]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys]
