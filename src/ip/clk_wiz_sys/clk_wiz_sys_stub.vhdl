-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
-- Date        : Tue Jan 13 16:22:21 2026
-- Host        : daqmwpc4.kek.jp running 64-bit CentOS Linux release 7.8.2003 (Core)
-- Command     : write_vhdl -force -mode synth_stub -rename_top clk_wiz_sys -prefix
--               clk_wiz_sys_ clk_wiz_sys_stub.vhdl
-- Design      : clk_wiz_sys
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wiz_sys is
  Port ( 
    clk_sys : out STD_LOGIC;
    clk_spi : out STD_LOGIC;
    clk_indep_gtx : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1_p : in STD_LOGIC;
    clk_in1_n : in STD_LOGIC
  );

end clk_wiz_sys;

architecture stub of clk_wiz_sys is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_sys,clk_spi,clk_indep_gtx,reset,locked,clk_in1_p,clk_in1_n";
begin
end;
