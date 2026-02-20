`timescale 1ns / 1ps
module top
    #(  parameter   ARRAY_SIZE    = 40,
        parameter   ERRSIG_ID_num = 11) 

(
        // System
        input             i_lc_sckp,      // from on-board oscillator 127.216MHz
        input             i_lc_sckn,      // from on-board oscillator 127.216MHz
        input             i_pushsw,
        output    [4:1]   o_led, 
        input [3:0]       dip,
    
        // GTX (SiTCP)
        output            o_sfp_tx_p,
        output            o_sfp_tx_n,
        input             i_sfp_rx_p,
        input             i_sfp_rx_n,
        input             i_gtref_156mp,  // GT reference clock from on-board osci.
        input             i_gtref_156mn,   // GT reference clock from on-board osci.
        
        //seu 
        output            TRIG_OUT
    );    

    //------------------------------------------------------------------------------
    //  Clocking 
    //------------------------------------------------------------------------------
    wire  clk_sys;
    wire  clk_spi;
    wire  clk_sys_locked;
    wire  clk_gbe;
    clk_wiz_sys clk_wiz_sys (
        .clk_sys      (clk_sys        ), // out: 127 MHz
        .clk_spi      (clk_spi        ), // out: 63.5 MHz
        .clk_indep_gtx(clk_gbe        ), // out: 190.5 MHz
        .reset        (1'b0           ), // in : reset
        .locked       (clk_sys_locked ), // out: locked
        .clk_in1_p    (i_lc_sckp      ), // in : input clock 127 MHz
        .clk_in1_n    (i_lc_sckn      )  // in : input clock 127 MHz
    );


    //------------------------------------------------------------------------------
    //  Reset
    //------------------------------------------------------------------------------
    wire  sitcp_rst;
    wire  pushsw_rst = ~i_pushsw;


    //------------------------------------------------------------------------------
    //  Network (SiTCP)
    //------------------------------------------------------------------------------
    //
    wire            timer_1ms;
    // TCP
    wire            tcp_open_ack;
    // RBCP
    wire            rbcp_active;
    wire    [31:0]  rbcp_addr;
    wire     [7:0]  rbcp_wd;
    wire            rbcp_we;
    wire            rbcp_re;
    wire            rbcp_ack;
    wire     [7:0]  rbcp_rd;

    network network (
        .i_sysclk         (clk_sys        ), // System clock
        .i_sysrst         (pushsw_rst     ),
        .i_gbeindepclk    (clk_gbe        ), // Gbe independent clock
        .o_timer_1ms      (timer_1ms      ), // Timer 1ms interval
        .i_gtrefclk_p     (i_gtref_156mp  ), // 
        .i_gtrefclk_n     (i_gtref_156mn  ), // 
        .i_sysclk_clocked (clk_sys_locked ),
        .o_sfp_tx_n       (o_sfp_tx_n     ),
        .o_sfp_tx_p       (o_sfp_tx_p     ),
        .i_sfp_rx_n       (i_sfp_rx_n     ),
        .i_sfp_rx_p       (i_sfp_rx_p     ),
        .o_reset_pulse    (),
        //
        .o_sitcp_rst      (sitcp_rst      ), // Reset for SiTCP and related circuits
        .o_tcp_open_ack   (tcp_open_ack   ), // (unused?) TCP Acknowledge for open (=Socket busy)
        .o_tcp_close_req  (               ), // (unused?) TCP Connection close request
        .o_tcp_rx_wr      (               ), // (unused) TCP Read enable
        .o_tcp_rx_wd      (               ), // (unused) TCP Read data [7:0]
        .o_tcp_tx_full    (               ), // TCP Almost full flag
        .i_tcp_tx_wr      (1'b0           ), // TCP Write enable
        .i_tcp_tx_wd      (8'd0           ), // TCP Write data [7:0]
        .o_rbcp_active    (rbcp_active    ), // (unused) RBCP active
        .o_rbcp_addr      (rbcp_addr[31:0]), // RBCP Address [31:0]
        .o_rbcp_wd        (rbcp_wd[7:0]   ), // RBCP Data [7:0]
        .o_rbcp_we        (rbcp_we        ), // RBCP Write enable
        .o_rbcp_re        (rbcp_re        ), // RBCP Read enable
        .i_rbcp_ack       (rbcp_ack       ), // RBCP Access acknowledge
        .i_rbcp_rd        (rbcp_rd[7:0]   ),  // RBCP Read data [7:0]
        .dip              (dip[3:0]       )        
    );

    
    //------------------------------------------------------------------------------
    //  UDP communication
    //------------------------------------------------------------------------------
    // SEM
    wire          mon_rst;
    wire  [15:0]  seu_en_cnt;
    wire  [15:0]  seu_dis_cnt;
    wire          sem_mbe;
    wire  [7:0]   seu_mon_rx;
    wire          seu_mon_cmd;
    wire          seu_cnt_rst;
    wire  [7:0]   seu_mon_dout;
    wire          sem_inj_strobe;
    wire  [31:0]  sem_inj_cmd_addr;
    reg   [15:0]  sem_heartbeat;
    wire          sem_emergency;
    wire          stat_heatbeat;
    wire          stat_observation;
    wire          stat_init;
    wire          stat_seu;
    wire          stat_mbe;
    wire          stat_simack;
    wire  [11:0]  temperature;
    wire  [11:0]  vccint;
    wire  [11:0]  vccaux;
    wire  [11:0]  vccbram;
    wire  [11:0]  vpvn;
    wire  [11:0]  vrefp;
    wire  [11:0]  vrefn;

    loc_reg loc_reg (
        .i_clk              (clk_sys            ), // in : Clock
        .i_rst              (sitcp_rst          ), // in : System reset
        // Register I/F()
        .i_loc_addr         (rbcp_addr[31:0]    ), // in : Address[31:0]
        .i_loc_wd           (rbcp_wd[7:0]       ), // in : Data[7:0]
        .i_loc_we           (rbcp_we            ), // in : Write enable
        .i_loc_re           (rbcp_re            ), // in : Read enable
        .o_loc_ack          (rbcp_ack           ), // out: Access acknowledge
        .o_loc_rd           (rbcp_rd[7:0]       ), // out: Read data[7:0]
        // Register MAP
        .o_run_reset        (                   ), // out: reset signal
        // Monitor
        .o_mon_rst          (mon_rst          ), // out: monitor reset
        .i_seu_en_cnt       (seu_en_cnt       ), // in :
        .i_seu_dis_cnt      (seu_dis_cnt      ), // in :
        .i_mbe              (sem_mbe          ), // in :
        .o_seu_mon_rx       (seu_mon_rx       ), // out:
        .o_seu_mon_cmd      (seu_mon_cmd      ), // out:
        .o_seu_cnt_rst      (seu_cnt_rst      ), // out:
        .i_seu_mon_dout     (seu_mon_dout     ), // in :
        .i_sem_emergency    (sem_emergency    ), // in :
        .o_sem_inj_strobe   (sem_inj_strobe   ), // out:
        .o_sem_inj_cmd_addr (sem_inj_cmd_addr ), // out:
        .i_sem_heartbeat    (sem_heartbeat    ), // in :
        .i_stat_observation (stat_observation ), // in :
        .i_stat_init        (stat_init        ), // in :
        .i_stat_seu         (stat_seu         ), // in :
        .i_stat_mbe         (stat_mbe         ), // in :
        .i_stat_simack      (stat_simack      ), // in :
        .i_temperature      (temperature      ), // in : FPGA temperature
        .i_vccint           (vccint           ), // in : FPGA VCCINT [V]
        .i_vccaux           (vccaux           ), // in : FPGA VCCAUX [V]
        .i_vccbram          (vccbram          ), // in : FPGA VCCBRAM [V]
        .i_vpvn             (vpvn             ), // in : FPGA VPVN [V]
        .i_vrefp            (vrefp            ), // in : FPGA VREFP [V]
        .i_vrefn            (vrefn            )  // in : FPGA VREFN [V]
    );

    
    //------------------------------------------------------------------------------
    //  Monitor
    //------------------------------------------------------------------------------
    wire [12:0] seu_mon_rd_data_cnt;

    reg  clk_en;
    always @(posedge clk_sys)begin
        if (clk_sys_locked) begin
            clk_en <= 1'b0;
        end else begin
            clk_en <= ~clk_en;
        end
    end

    reg [1:0]   sig_sembeat;
    always @(posedge clk_sys) begin
        if (mon_rst) begin
            sig_sembeat <= 1'b0;
            sem_heartbeat <= 15'd0;
        end else begin
            sig_sembeat[1:0] <= {sig_sembeat[0], stat_heatbeat};
            if (sig_sembeat[1:0]==2'b01) begin
                sem_heartbeat[15:0] <= sem_heartbeat[15:0] + 16'd1;
            end
        end
    end

    monitor monitor(
        .i_clk127m                    (clk_sys             ), // in : 127MHz clock
        .i_clk63p5m                   (clk_spi             ), // in : 63.5MHz clock
        .i_rst                        (mon_rst             ), // in : reset generated by 127MHz
        // soft error mitigation
        .o_seu_enable_count           (seu_en_cnt          ), // out: # of SEUs [15:0]
        .o_seu_disable_count          (seu_dis_cnt         ), // out: # of MBUs [15:0]
        .o_mbe                        (sem_mbe             ), // out: MBU flag
        .i_seu_monitor_rx             (seu_mon_rx          ), // in :
        .i_seu_monitor_send_command   (seu_mon_cmd         ), // in :
        .i_seu_count_reset            (seu_cnt_rst         ), // in :
        .i_seu_monitor_rd_en          (1'b1                ), // in : Read enable  FIXME
        .o_seu_monitor_dout           (seu_mon_dout        ), // out: [7:0]
        .o_seu_monitor_rd_data_count  (seu_mon_rd_data_cnt ), // out: [12:0]
        .o_status_heartbeat           (stat_heatbeat       ), // out:
        .o_status_observation         (stat_observation    ), // out: (unuse)
        .o_status_initialization      (stat_init           ), // out: (unuse)
        .o_status_correction          (stat_seu            ), // out:
        .o_status_uncorrectable       (stat_mbe            ), // out:
        .o_status_injection           (stat_simack         ), // out:
        .o_sem_emergency              (sem_emergency       ), // out:
        .i_inject_strobe              (sem_inj_strobe      ), // in :
        .i_inject_cmd_addr            (sem_inj_cmd_addr    ), // in : 4-bit cmd, (8-bit unuse), 28-bit address
        // xadc
        .o_temperature                (temperature         ), // out: temperature [11:0]
        .o_vccint                     (vccint              ), // out: vccint [11:0]
        .o_vccaux                     (vccaux              ), // out: vccaux [11:0]
        .o_vccbram                    (vccbram             ), // out: vccbram [11:0]
        .o_vpvn                       (vpvn                ), // out: vpvn [11:0]
        .o_vrefp                      (vrefp               ), // out: vrefp [11:0]
        .o_vrefn                      (vrefn               )  // out: vrefn [11:0]
    );


//------------------------------------------------------------------------------
//    Soft-error detection
//------------------------------------------------------------------------------

	reg [15:0]    err_flag_count;


    wire  [ARRAY_SIZE-1:0]  det_error;
    wire  [ARRAY_SIZE-1:0]  error;
    //wire  [ARRAY_SIZE-1:0]  flicker;
    
    wire [ERRSIG_ID_num-1:0] error_A;
    wire [ERRSIG_ID_num-1:0] error_B;
    
    
    soft_error_HUB 
        #(.ARRAY_SIZE(ARRAY_SIZE),
            .ERRSIG_ID_num(ERRSIG_ID_num)
        )
    soft_error_HUB(
        .i_clk(clk_sys),
        .i_rst(sitcp_rst),
        .error_A(error_A[ERRSIG_ID_num-1:0]),
        .error_B(error_B[ERRSIG_ID_num-1:0])
    );
    
    
    //assign error_A = 0;
    //assign error_B = 0;

    wire output_err_sig;
    wire debug_sig;

    error_sig_tx_V2 
        #(.ARRAY_SIZE(ARRAY_SIZE),
        .ERRSIG_ID_num(ERRSIG_ID_num)
    )    
    error_sig_tx(
        .i_clk(clk_sys),      // System clock
        .i_rst(sitcp_rst),      // System reset
        .error_A(error_A),  // 
        .error_B(error_B),       // Error signal
        .output_err_sig(output_err_sig),
        .debug_sig(debug_sig)
    );

    assign TRIG_OUT = output_err_sig;
    
    reg [2:0] error_flag_out_DEBUG_old;
    always@(posedge clk_sys)begin
        error_flag_out_DEBUG_old[0] <= debug_sig;
        error_flag_out_DEBUG_old[1] <= error_flag_out_DEBUG_old[0];
        error_flag_out_DEBUG_old[2] <= error_flag_out_DEBUG_old[1];
    end
    
    wire err_flag_out_countup;
    assign err_flag_out_countup = error_flag_out_DEBUG_old[1] & ~error_flag_out_DEBUG_old[2];

    always@(posedge clk_sys)begin 
        if(sitcp_rst)begin
            err_flag_count[15:0] <= 16'h0;
        end 
        else if(err_flag_out_countup)begin
            err_flag_count[15:0] <= err_flag_count[15:0] + 1'b1;
        end
    end     
    


    
    //------------------------------------------------------------------------------
    //  Debug
    //------------------------------------------------------------------------------
    //wire  led_rst_out = sitcp_rst | srst | brst | trst;
    wire  led_lck_out = clk_sys_locked;
    assign o_led[4:1] = {led_lck_out, 1'b1, 1'b1, tcp_open_ack};

    ila_top ila_top (
        .clk      (clk_sys              ),
        //
        .probe0   (tcp_open_ack         ) 
    );


endmodule
