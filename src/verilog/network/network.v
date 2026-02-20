`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2022 07:48:08 PM
// Design Name: 
// Module Name: network
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


module network(
    // System
    input           i_sysclk,       // System clock
    input           i_sysrst,
    input           i_gbeindepclk,  // GbE independent clock
    output          o_timer_1ms,    // Timer 1 ms
    // SFP 
    input           i_gtrefclk_p,   // 
    input           i_gtrefclk_n,   // 
    input           i_sysclk_clocked,
    output          o_sfp_tx_n,
    output          o_sfp_tx_p,
    input           i_sfp_rx_n,
    input           i_sfp_rx_p,
    // SiTCP
    output          o_reset_pulse,
    output          o_sitcp_rst,      // Reset for SiTCP and related circuits
    output          o_tcp_open_ack,   // TCP Acknowledge for open (=Socket busy)
    //output          o_tcp_error,      // TCP error, its active period is equal to MSL
    output          o_tcp_close_req,  // TCP Connection close request
    output          o_tcp_rx_wr,      // TCP Read enable
    output  [ 7:0]  o_tcp_rx_wd,      // TCP Read data [7:0]
    output          o_tcp_tx_full,    // TCP Almost full flag
    input           i_tcp_tx_wr,      // TCP Write enable
    input   [ 7:0]  i_tcp_tx_wd,      // TCP Write data [7:0]
    output          o_rbcp_active,    // RBCP active
    output  [31:0]  o_rbcp_addr,      // RBCP Address [31:0]
    output  [ 7:0]  o_rbcp_wd,        // RBCP Data [7:0]
    output          o_rbcp_we,        // RBCP Write enable
    output          o_rbcp_re,        // RBCP Read enable
    input           i_rbcp_ack,       // RBCP Access acknowledge
    input   [ 7:0]  i_rbcp_rd,         // RBCP Read data [7:0]
    input [3:0]     dip
    );

//*******************************************************************************
//     SFP to SiTCP Interface
//*******************************************************************************
    wire            resetdone;
    reg             sfp_reset_pulse;
    wire    [7:0]   gmii_txd;
    wire            gmii_tx_en;
    wire            gmii_tx_er;
    wire    [7:0]   gmii_rxd;
    wire            gmii_rx_dv;
    wire            gmii_rx_er;
    wire            gtRxTxCLK;
    wire            sfp_mdc;
    wire            sfp_mdio_i;
    wire            gmii_clk;
    
    wrap_gig_eth wrap_gig_eth(
        .i_gtrefclk_p             (i_gtrefclk_p   ), // in :
        .i_gtrefclk_n             (i_gtrefclk_n   ), // in :
        .o_gtrefclk_bufg_out      (               ), // out: gtrefclk
        .o_txn                    (o_sfp_tx_n     ), // out: txn
        .o_txp                    (o_sfp_tx_p     ), // out: txp
        .i_rxn                    (i_sfp_rx_n     ), // in : rxn
        .i_rxp                    (i_sfp_rx_p     ), // in : rxp
        .o_userclk_out            (               ), // out: userclk
        .o_userclk2_out           (gtRxTxCLK      ), // out: userclk2
        .o_rxuserclk_out          (               ),
        .o_rxuserclk2_out         (               ),
        .i_independent_clk_bufg   (i_gbeindepclk  ), // in : independent_clock_bufg
        .o_resetdone              (resetdone      ), // out: resetdone
        .i_gmii_tx_clk            (gmii_clk       ), // in :
        .o_gmii_rx_clk            (gmii_clk       ), // out:
        .i_gmii_txd               (gmii_txd[7:0]  ), // in : gmii_txd [7:0] 
        .i_gmii_tx_en             (gmii_tx_en     ), // in : gmii_tx_en
        .i_gmii_tx_er             (gmii_tx_er     ), // in : gmii_tx_er
        .o_gmii_rxd               (gmii_rxd[7:0]  ), // out: gmii_rxd [7:0]
        .o_gmii_rx_dv             (gmii_rx_dv     ), // out: gmii_rx_dv
        .o_gmii_rx_er             (gmii_rx_er     ), // out: gmii_rx_er
        //.o_gmii_isolate           (               ), // out: gmii_isolate
        .i_mdc                    (sfp_mdc        ), // in : mdc
        .i_mdio_i                 (sfp_mdio_i     ), // in : mdio_i
        .o_mdio_o                 (               ), // out: mdio_o
        .o_mdio_t                 (               ), // out: mdio_t
        //.o_an_interrupt           (               ), // out:
        .i_reset                  (sfp_reset_pulse)  // in : reset
    );
    
    //reg     sitcp_reset ;
    //always@(posedge gtRxTxCLK) begin
    //    sitcp_reset  <= (~i_sysclk_clocked);
    //end
    wire    sitcp_reset = (~i_sysclk_clocked) || i_sysrst;
    
    wire            sfpFds;
    wire    [3:0]   sfpFd;
    reg             reset_pulse;
    
    FDS SFP_FDS(.Q(sfpFds),   .C(gtRxTxCLK), .D(1'b0), .S(1'b0));
    FD  SFP_FD0(.Q(sfpFd[0]), .C(gtRxTxCLK), .D(sfpFds));
    FD  SFP_FD1(.Q(sfpFd[1]), .C(gtRxTxCLK), .D(sfpFd[0]));
    FD  SFP_FD2(.Q(sfpFd[2]), .C(gtRxTxCLK), .D(sfpFd[1]));
    FD  SFP_FD3(.Q(sfpFd[3]), .C(gtRxTxCLK), .D(sfpFd[2]));
    
    always@(posedge gtRxTxCLK) begin
        reset_pulse <= (|sfpFd[3:0]);
    end
    assign o_reset_pulse = reset_pulse;
    
    reg             sfp_reset_enable;
    reg     [4:0]   shift_sfp_reset_enable;
    reg             resetdone_pos;

    always@(posedge gtRxTxCLK) begin
        if (reset_pulse) begin
            sfp_reset_enable <= 1'b0;
        end else if (resetdone_pos) begin
            sfp_reset_enable <= 1'b1;
        end
    end

    //reg     [2:0]   dly_resetdone;
    (* ASYNC_REG = "TRUE" *) reg  async_dly_resetdone0, async_dly_resetdone1;
    reg       dly_resetdone;

    always@(posedge gtRxTxCLK) begin
        shift_sfp_reset_enable[4:0] <= {shift_sfp_reset_enable[3:0],sfp_reset_enable};
        sfp_reset_pulse             <= (~shift_sfp_reset_enable[4]) & shift_sfp_reset_enable[0];
        async_dly_resetdone0        <= resetdone;
        async_dly_resetdone1        <= async_dly_resetdone0;
        dly_resetdone               <= async_dly_resetdone1;
        resetdone_pos               <= (~dly_resetdone) & async_dly_resetdone1;
        //dly_resetdone[0]            <= resetdone;
        //dly_resetdone[1]            <= dly_resetdone[0];
        //resetdone_pos               <= (~dly_resetdone[2]) & dly_resetdone[1];
    end
    
    wire    sfp_gmii_comp;

    mii_initializer mii_initializer(
        .CLK      (gtRxTxCLK        ),  // in : system clock (125M)
        .RST      (sfp_reset_pulse  ),  // in : system reset
        .PHYAD    (5'b00001         ),  // in : [4:0] PHY address
        .MDC      (sfp_mdc          ),  // out: clock (1/128 system clock)
        .MDIO_OUT (sfp_mdio_i       ),  // out: connect this to "PCS/PMA + RocketIO" module .mdio?_i()
        .COMPLETE (sfp_gmii_comp    )   // out: initializing sequence has completed (active H)
    );
    
//*******************************************************************************
//                                   SiTCP
//*******************************************************************************
    wire [31:0]     SiTCP_IP_ADDR;
    wire [15:0]     SiTCP_TCP_PORT;
    wire [15:0]     SiTCP_RBCP_PORT;

    assign SiTCP_IP_ADDR[31:0] = 32'hc0_a8_0a_32 + dip[3:0];
    assign SiTCP_TCP_PORT[15:0] = 16'd24;
    assign SiTCP_RBCP_PORT[15:0] = 16'd4660;


    WRAP_SiTCP_GMII_XC7A_32K
        #(200) // = System clock frequency(MHz), integer only
    SiTCP(
        .CLK            (i_sysclk         ), // in : System Clock >129MHz
        .RST            (sitcp_reset      ), // in : System reset (Asynchronous)
        //.TIM_1US        (                 ), // out: (unuse) Timer 1us  interval
        //.TIM_1MS        (o_timer_1ms      ), // out: Timer 1ms  interval
        //.TIM_1S         (                 ), // out: (unuse) Timer 1sec interval
        //.TIM_1MIN       (                 ), // out: (unuse) Timer 1min interval
        .MAC_SELECT     ({2'h0, dip[3:0]}   ),
        // Configuration parameters
       // .FORCE_DEFAULTn (1'b0             ), // in : Load default parameters
       .EXT_IP_ADDR    (SiTCP_IP_ADDR[31:0]  ),
       .EXT_TCP_PORT   (SiTCP_TCP_PORT[15:0] ),  // in  : TCP port[15:0]
       .EXT_RBCP_PORT  (SiTCP_RBCP_PORT[15:0]),  // in  : RBCP port[15:0]
        .MY_MAC_ADDR    (),
        .PHY_ADDR       (5'b00000         ), // in : PHY-device MIF address[4:0]
        // EEPROM
        //.EEPROM_CS      (    ), // out: Chip select
        //.EEPROM_SK      (    ), // out: Serial data clock
        //.EEPROM_DI      (    ), // out: Serial write data
        //.EEPROM_DO      (1'b0), // in : Serial read data
        // user data, initial values are stored in the EEPROM, 0xFFFF_FC3C-3F
        //.USR_REG_X3C    (    ), // out: Stored at 0xFFFF_FF3C
        //.USR_REG_X3D    (    ), // out: Stored at 0xFFFF_FF3D
        //.USR_REG_X3E    (    ), // out: Stored at 0xFFFF_FF3E
        //.USR_REG_X3F    (    ), // out: Stored at 0xFFFF_FF3F
  
         // MII interface
        .GMII_RSTn      (                 ), // out: PHY reset
        .GMII_1000M     (1'b1             ), // in : GMII mode (0:MII, 1:GMII)
        // TX
        .GMII_TX_CLK    (gmii_clk         ), // in : Tx clock
        .GMII_TX_EN     (gmii_tx_en       ), // out: Tx enable
        .GMII_TXD       (gmii_txd[7:0]    ), // out: Tx data[7:0]
        .GMII_TX_ER     (gmii_tx_er       ), // out: TX error
        // RX
        .GMII_RX_CLK    (gmii_clk         ), // in : Rx clock
        .GMII_RX_DV     (gmii_rx_dv       ), // in : Rx data valid
        .GMII_RXD       (gmii_rxd[7:0]    ), // in : Rx data[7:0]
        .GMII_RX_ER     (gmii_rx_er       ), // in : Rx error
        .GMII_CRS       (1'b0             ), // in : Carrier sense
        .GMII_COL       (1'b0             ), // in : Collision detected
        // Management IF
        .GMII_MDC       (                 ), // out: Clock for MDIO
        .GMII_MDIO_IN   (1'b1             ), // in : Data
        .GMII_MDIO_OUT  (                 ), // out: Data
        .GMII_MDIO_OE   (                 ), // out: MDIO output enable
        // User I/F
        .SiTCP_RST      (o_sitcp_rst      ), // out: Reset for SiTCP and related circuits
        // TCP connection control
        .TCP_OPEN_REQ   (1'b0             ), // in : Reserved input, shoud be 0
        .TCP_OPEN_ACK   (o_tcp_open_ack   ), // out: Acknowledge for open (=Socket busy)
        //.TCP_ERROR      (o_tcp_error      ), // out: TCP error, its active period is equal to MSL
        .TCP_CLOSE_REQ  (o_tcp_close_req  ), // out: Connection close request
        .TCP_CLOSE_ACK  (o_tcp_close_req  ), // in : Acknowledge for closing
        // FIFO I/F
        .TCP_RX_WC      (16'd0            ), // in : Rx FIFO write count[15:0] (Unused bits should be set 1)
        .TCP_RX_WR      (o_tcp_rx_wr      ), // out: Write enable
        .TCP_RX_DATA    (o_tcp_rx_wd[7:0] ), // out: Write data[7:0]
        .TCP_TX_FULL    (o_tcp_tx_full    ), // out: Almost full flag
        .TCP_TX_WR      (i_tcp_tx_wr      ), // in : Write enable
        .TCP_TX_DATA    (i_tcp_tx_wd[7:0] ), // in : Write data[7:0]
        // RBCP
        .RBCP_ACT       (o_rbcp_active    ), // out: RBCP active
        .RBCP_ADDR      (o_rbcp_addr[31:0]), // out: Address[31:0]
        .RBCP_WD        (o_rbcp_wd[7:0]   ), // out: Data[7:0]
        .RBCP_WE        (o_rbcp_we        ), // out: Write enable
        .RBCP_RE        (o_rbcp_re        ), // out: Read enable
        .RBCP_ACK       (i_rbcp_ack       ), // in : Access acknowledge
        .RBCP_RD        (i_rbcp_rd[7:0]   )  // in : Read data[7:0]
    );

endmodule
