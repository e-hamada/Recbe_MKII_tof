// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Tue Jan 13 16:22:21 2026
// Host        : daqmwpc4.kek.jp running 64-bit CentOS Linux release 7.8.2003 (Core)
// Command     : write_verilog -force -mode synth_stub -rename_top clk_wiz_sys -prefix
//               clk_wiz_sys_ clk_wiz_sys_stub.v
// Design      : clk_wiz_sys
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_sys(clk_sys, clk_spi, clk_indep_gtx, reset, locked, 
  clk_in1_p, clk_in1_n)
/* synthesis syn_black_box black_box_pad_pin="clk_sys,clk_spi,clk_indep_gtx,reset,locked,clk_in1_p,clk_in1_n" */;
  output clk_sys;
  output clk_spi;
  output clk_indep_gtx;
  input reset;
  output locked;
  input clk_in1_p;
  input clk_in1_n;
endmodule
