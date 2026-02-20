`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2022 12:51:39 PM
// Design Name: 
// Module Name: gig_ethernet_pcs_pma_0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wrap_gig_eth (
        input           i_gtrefclk_p,
        input           i_gtrefclk_n,
        output          o_gtrefclk_bufg_out,
        output          o_txn,
        output          o_txp,
        input           i_rxn,
        input           i_rxp,
        output          o_userclk_out,
        output          o_userclk2_out,
        output          o_rxuserclk_out,
        output          o_rxuserclk2_out,
        input           i_independent_clk_bufg,
        output          o_resetdone,
        input           i_gmii_tx_clk,
        output          o_gmii_rx_clk,
        input   [7:0]   i_gmii_txd,
        input           i_gmii_tx_en,
        input           i_gmii_tx_er,
        output  [7:0]   o_gmii_rxd,
        output          o_gmii_rx_dv,
        output          o_gmii_rx_er,
        input           i_mdc,
        input           i_mdio_i,
        output          o_mdio_o,
        output          o_mdio_t,
        //output          o_an_interrupt,
        input           i_reset 
    );

    wire            cplllock  ; // reset done indication from transceiver
    wire            pma_reset ; // reset synchronised to system clock
    wire            txoutclk  ; // txoutclk from GT transceiver (62.5MHz)
    wire            rxoutclk  ; // txoutclk from GT transceiver (62.5MHz)
    wire            userclk   ;
    wire            userclk2  ;
    wire            rxuserclk ;
    wire            rxuserclk2;
    wire            gtrefclk  ;
    wire            gtrefclk_bufg;

    wire            mmcm_reset ;
    wire            mmcm_locked;

    wire            gt0_qplloutclk;
    wire            gt0_qplloutrefclk;

    wire    [7:0]   gmii_txd_fifo;
    wire            gmii_tx_en_fifo;
    wire            gmii_tx_er_fifo;
    wire    [7:0]   gmii_rxd_int;
    wire            gmii_rx_dv_int;
    wire            gmii_rx_er_int;

    //----------------------------------------------------------------------------
    // Instantiate the clocking module.
    //----------------------------------------------------------------------------
    gig_ethernet_pcs_pma_0_clocking core_clocking_i(
        .gtrefclk_p     (i_gtrefclk_p   ), // in :
        .gtrefclk_n     (i_gtrefclk_n   ), // in :
        .txoutclk       (txoutclk       ), // in :
        .rxoutclk       (rxoutclk       ), // in :
        .mmcm_reset     (mmcm_reset     ), // in :
        .gtrefclk       (gtrefclk       ), // out:
        .gtrefclk_bufg  (gtrefclk_bufg  ), // out:
        .mmcm_locked    (mmcm_locked    ), // out: 
        .userclk        (userclk        ), // out:
        .userclk2       (userclk2       ), // out:
        .rxuserclk      (rxuserclk      ), // out:
        .rxuserclk2     (rxuserclk2     )  // out:
    );

    gig_ethernet_pcs_pma_0 gig_ethernet_pcs_pma_0 (
        .gtrefclk               (gtrefclk               ), // input  wire gtrefclk
        .gtrefclk_bufg          (gtrefclk_bufg          ), // input  wire gtrefclk
        .txn                    (o_txn                  ), // output wire txn
        .txp                    (o_txp                  ), // output wire txp
        .rxn                    (i_rxn                  ), // input  wire rxn
        .rxp                    (i_rxp                  ), // input  wire rxp
        .resetdone              (o_resetdone            ), // output wire resetdone
        .cplllock               (cplllock               ), //
        .mmcm_reset             (mmcm_reset             ), //
        .txoutclk               (txoutclk               ), // output wire txoutclk
        .rxoutclk               (rxoutclk               ), // output wire rxoutclk
        .userclk                (userclk                ), // input  wire userclk
        .userclk2               (userclk2               ), // input  wire userclk2
        .rxuserclk              (rxuserclk              ), // input
        .rxuserclk2             (rxuserclk2             ), // input
        .independent_clock_bufg (i_independent_clk_bufg ), // input  wire independent_clock_bufg
        .pma_reset              (pma_reset              ), // transceiver PMA reset signal
        .mmcm_locked            (mmcm_locked            ), // input
        // GMII Interface
        // --------------
        .gmii_txd               (gmii_txd_fifo[7:0]     ), // input  wire [7 : 0] gmii_txd
        .gmii_tx_en             (gmii_tx_en_fifo        ), // input  wire gmii_tx_en
        .gmii_tx_er             (gmii_tx_er_fifo        ), // input  wire gmii_tx_er
        .gmii_rxd               (gmii_rxd_int[7:0]      ), // output wire [7 : 0] gmii_rxd
        .gmii_rx_dv             (gmii_rx_dv_int         ), // output wire gmii_rx_dv
        .gmii_rx_er             (gmii_rx_er_int         ), // output wire gmii_rx_er
        .gmii_isolate           (                       ), // output wire gmii_isolate
        // Management: MDIO Interface
        // --------------------------
        .mdc                    (i_mdc                  ), // input  wire mdc
        .mdio_i                 (i_mdio_i               ), // input  wire mdio_i
        .mdio_o                 (o_mdio_o               ), // output wire mdio_o
        .mdio_t                 (o_mdio_t               ), // output wire mdio_t
        .phyaddr                (5'd1                   ), // input  wire physical address [4:0]
        .configuration_vector   (5'b00000               ), // input  wire [4 : 0] configuration_vector
        .configuration_valid    (1'b0                   ), // input  wire configuration_valid
        //.an_interrupt(o_an_interrupt),                   //
        //.an_adv_config_vector(16'b0000_0000_0010_0001),  // Alternate interface to program REG4 (AN ADV)
        //.an_adv_config_val(1'b0),                        // Validation signal for AN ADV
        //.an_restart_config(1'b0),                        // Alternate signal to modify AN restart bit in REG0
        // General IO's
        // ------------
        .status_vector          (),                        // output wire [15 : 0] status_vector
        .reset                  (i_reset                ), // input wire reset
        .signal_detect          (1'b1                   ), // input wire signal_detect
        .gt0_qplloutclk_in      (gt0_qplloutclk         ), // input
        .gt0_qplloutrefclk_in   (gt0_qplloutrefclk      )  // input
    );

    assign o_gtrefclk_bufg_out = gtrefclk_bufg;
    assign o_userclk_out       = userclk;
    assign o_userclk2_out      = userclk2;
    assign o_rxuserclk_out     = rxuserclk;
    assign o_rxuserclk2_out    = rxuserclk2;

    //---------------------------------------------------------------------------
    // Transceiver PMA reset circuitry
    //---------------------------------------------------------------------------
    gig_ethernet_pcs_pma_0_resets core_resets_i(
        .reset                  (i_reset),
        .independent_clock_bufg (i_independent_clk_bufg),
        .pma_reset              (pma_reset)
    );
    
    gig_ethernet_pcs_pma_0_gt_common core_gt_common_i(
        .GTREFCLK0_IN       (gtrefclk               ), // in :
        .QPLLLOCK_OUT       (), // out: (unused)
        .QPLLLOCKDETCLK_IN  (i_independent_clk_bufg ), // in :
        .QPLLOUTCLK_OUT     (gt0_qplloutclk         ), // out:
        .QPLLOUTREFCLK_OUT  (gt0_qplloutrefclk      ), // out:
        .QPLLREFCLKLOST_OUT (), // out: (unused)
        .QPLLRESET_IN       (pma_reset              )  // in :
    );

    
    //-----------------------------------------------------------------------------
    //-- GMII transmitter data logic
    //-----------------------------------------------------------------------------
  
    reg   [7:0]   gmii_txd_reg;
    reg           gmii_tx_en_reg;
    reg           gmii_tx_er_reg;
    always@(posedge i_gmii_tx_clk) begin
        gmii_txd_reg <= i_gmii_txd;
        gmii_tx_en_reg <= i_gmii_tx_en;
        gmii_tx_er_reg <= i_gmii_tx_er;
    end
   
    // Component Instantiation for the Transmitter Elastic Buffer
    gig_ethernet_pcs_pma_0_tx_elastic_buffer tx_elastic_buffer_inst
    (
       .reset            (reset             ), // in :
       .gmii_tx_clk_wr   (i_gmii_tx_clk     ), // in :
       .gmii_txd_wr      (gmii_txd_reg      ), // in :
       .gmii_tx_en_wr    (gmii_tx_en_reg    ), // in :
       .gmii_tx_er_wr    (gmii_tx_er_reg    ), // in :
       .gmii_tx_clk_rd   (userclk2          ), // in :
       .gmii_txd_rd      (gmii_txd_fifo     ), // out:
       .gmii_tx_en_rd    (gmii_tx_en_fifo   ), // out:
       .gmii_tx_er_rd    (gmii_tx_er_fifo   )
    );


    //-----------------------------------------------------------------------------
    //-- GMII receiver data logic
    //-----------------------------------------------------------------------------
    assign o_gmii_rx_clk = userclk2;

    // Drive Rx GMII signals through IOB output flip-flops (inferred).
    reg   [7:0]   gmii_rxd_reg;
    reg           gmii_rx_dv_reg;
    reg           gmii_rx_er_reg;
    always @ (posedge userclk2)
    begin
       gmii_rxd_reg    <= gmii_rxd_int;
       gmii_rx_dv_reg  <= gmii_rx_dv_int;
       gmii_rx_er_reg  <= gmii_rx_er_int;
    end

    assign o_gmii_rxd = gmii_rxd_reg;
    assign o_gmii_rx_dv = gmii_rx_dv_reg;
    assign o_gmii_rx_er = gmii_rx_er_reg;

endmodule
