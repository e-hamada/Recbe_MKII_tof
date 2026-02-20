`timescale 1ns / 1ps
module monitor(
    input               i_clk63p5m,
    input               i_clk127m,
    input               i_rst,        // <-- this rst is made by clk127m
    // Soft Error Mitigation
    output    [15:0]    o_seu_enable_count,        
    output    [15:0]    o_seu_disable_count,       
    output              o_mbe,
    input     [7:0]     i_seu_monitor_rx,          
    input               i_seu_monitor_send_command,
    input               i_seu_count_reset,
    input               i_seu_monitor_rd_en,
    output    [7:0]     o_seu_monitor_dout,
    output    [12:0]    o_seu_monitor_rd_data_count,
    // Soft Error Mitigation  status
    output              o_status_heartbeat,
    output              o_status_observation,
    output              o_status_initialization,
    output              o_status_correction,
    output              o_status_uncorrectable,
    output              o_status_injection,
    output              o_sem_emergency,
    // Soft Error Mitigation  error injecton
    input               i_inject_strobe,
    input     [31:0]    i_inject_cmd_addr,
    // xadc
    output    [11:0]    o_temperature,
    output    [11:0]    o_vccint,
    output    [11:0]    o_vccaux,
    output    [11:0]    o_vccbram,
    output    [11:0]    o_vpvn,
    output    [11:0]    o_vrefp,
    output    [11:0]    o_vrefn 
    
);
    //`define DEBUG

    //reset 127m --> 63.5m
    reg reg_rst1;
    reg reg_rst2;
    always@(posedge i_clk127m)begin
        reg_rst1 <= i_rst;
        reg_rst2 <= reg_rst1;
    end
    wire rst_63p5m;
    wire rst_63p5m_level1;
    assign rst_63p5m_level1 = reg_rst1 | reg_rst2;

    //prevent timing err
    reg reg_rst_63p5m;
    always@(posedge i_clk63p5m)begin
        reg_rst_63p5m <= rst_63p5m_level1;
    end
    assign rst_63p5m = reg_rst_63p5m;
    
//*******************************************************************************
//                                 SEU
//*******************************************************************************    
    //clock
    //seu_monitor_send_command --> 127MHz 
    reg reg_seu_monitor_send_command1;
    reg reg_seu_monitor_send_command2;
    reg reg_seu_monitor_send_command3;
    reg reg_seu_monitor_send_command4;
    always@(posedge i_clk127m)begin
        reg_seu_monitor_send_command1 <= i_seu_monitor_send_command;
        reg_seu_monitor_send_command2 <= reg_seu_monitor_send_command1;
        reg_seu_monitor_send_command3 <= reg_seu_monitor_send_command2;
        reg_seu_monitor_send_command4 <= reg_seu_monitor_send_command3;
    end
    wire seu_monitor_send_command3;
    assign seu_monitor_send_command3 =  reg_seu_monitor_send_command1 | 
                                        reg_seu_monitor_send_command2 |
                                        reg_seu_monitor_send_command3 |
                                        reg_seu_monitor_send_command4;
    
    
    //control SEM
    wire monitor_rx;
    monitor_control2 monitor_control(
        .clk(i_clk63p5m),
        .rst(rst_63p5m),
        .send_monitor_value(i_seu_monitor_rx),
        .send_monitor_start(seu_monitor_send_command3),
        .monitor_rx(monitor_rx)
    );

    wire status_heartbeat;     
    wire status_initialization; 
    wire status_correction;    
    wire status_classification;
    wire status_injection;     
    wire status_essential;     
    wire status_uncorrectable; 
    wire monitor_tx;
    
    wire        inject_strobe;
    wire [39:0] inject_cmd_addr;
    
    `ifdef DEBUG
        
            wire        vio_1_strobe1;
            wire        vio_1_strobe2;
            wire        vio_1_strobe3;
            wire [39:0] vio_1_address1;
            wire [39:0] vio_1_address2;
            wire [39:0] vio_1_address3;
            wire        inject_start;
        
            vio_0 vio_0 (
                .clk(i_clk63p5m),
                .probe_out0(vio_1_strobe1),
                .probe_out1(vio_1_strobe2),
                .probe_out2(vio_1_strobe3),
                .probe_out3(vio_1_address1[39:0]),
                .probe_out4(vio_1_address2[39:0]),
                .probe_out5(vio_1_address3[39:0]),
                .probe_out6(inject_start)
            ); 
        
            wire    inject_start2;
            reg     inject_start_old;
            
            always@(posedge i_clk63p5m)begin
                inject_start_old <= inject_start;
            end
            
            assign inject_start2 = inject_start & ~inject_start_old;
            
            reg [18:0]   inject_shift_register;
            always@(posedge i_clk63p5m or posedge rst_63p5m)begin
                if(rst_63p5m)begin
                    inject_shift_register[18:0] <= 19'h0;
                end
                else begin    
                    inject_shift_register[0] <= inject_start2;
                    inject_shift_register[18:1] <= inject_shift_register[17:0];
                end
            end
        
            assign inject_strobe =  (|inject_shift_register[4:1]) ? 1'b0 :
                                    (|inject_shift_register[6:5]) ? vio_1_strobe1 :
                                    (|inject_shift_register[10:7]) ? 1'b0 :
                                    (|inject_shift_register[12:11]) ? vio_1_strobe2 :
                                    (|inject_shift_register[16:13]) ? 1'b0 :
                                    (|inject_shift_register[18:17]) ? vio_1_strobe3 : 1'b0;
        
            assign inject_cmd_addr[39:0] =   (|inject_shift_register[6:1]) ? vio_1_address1[39:0] :
                                            (|inject_shift_register[12:7]) ? vio_1_address2[39:0] :
                                            (|inject_shift_register[18:13]) ? vio_1_address3[39:0] : 40'h0;
            
        
    `else
        reg   [1:0]   inject_strobe_edgedet;
        reg   [1:0]   inject_strobe_edge;
        always@(posedge i_clk63p5m) begin
            if (i_rst) begin
                inject_strobe_edgedet[1:0] <= 2'd0;
                inject_strobe_edge[1:0]    <= 2'd0;
            end else begin
                inject_strobe_edgedet[1:0] <= {inject_strobe_edgedet[0], i_inject_strobe};
                if (inject_strobe_edgedet[1:0]==2'b01) begin
                    inject_strobe_edge[1:0] <= {inject_strobe_edge[0], 1'b1};
                end else begin
                    inject_strobe_edge[1:0] <= {inject_strobe_edge[0], 1'b0};
                end
            end
        end

        assign inject_strobe = (|inject_strobe_edge[1:0]) ? 1'b1 : 1'b0;
        assign inject_cmd_addr[39:0] = {i_inject_cmd_addr[31:28],8'd0,i_inject_cmd_addr[27:0]};
    `endif    
    
    wire        status_observation_level1;
    
    //SEM IP
    sem_example sem_example(
        .clk                    (i_clk63p5m                 ), // in :  
        .status_heartbeat       (status_heartbeat           ), // out:
        .status_initialization  (status_initialization      ), // out:
        .status_observation     (status_observation_level1  ), // out:
        .status_correction      (status_correction          ), // out:
        .status_classification  (status_classification      ), // out:
        .status_injection       (status_injection           ), // out:
        .status_essential       (status_essential           ), // out:
        .status_uncorrectable   (status_uncorrectable       ), // out:
        .inject_strobe          (inject_strobe              ), // in :
        .inject_address         (inject_cmd_addr[39:0]      ), // in :  
        .monitor_rx             (monitor_rx                 ), // in :
        .monitor_tx             (monitor_tx                 )  // out:
    );    

    assign o_status_heartbeat      = status_heartbeat;
    assign o_status_initialization = status_injection;
    assign o_status_correction     = status_correction;
    assign o_status_uncorrectable  = status_uncorrectable;
    assign o_status_injection      = status_injection;

    //SEM output 
    wire [7:0]  read_monitor_tx;
    wire        get_data_en;
    monitor_decode2 monitor_decode(
        .clk(i_clk63p5m),
        .rst(rst_63p5m),
        .monitor_tx(monitor_tx),
        .read_monitor_tx(read_monitor_tx),
        .get_data_en(get_data_en)
    );    
    
    //FIFO
    monitor_seu_fifo monitor_seu_fifo(
        .rst          (rst_63p5m), 
        .wr_clk       (i_clk63p5m),
        .rd_clk       (i_clk127m),
        .din          (read_monitor_tx),
        .wr_en        (get_data_en),
        .rd_en        (i_seu_monitor_rd_en),
        .dout         (o_seu_monitor_dout),
        .full         (),
        .empty        (),
        .rd_data_count(o_seu_monitor_rd_data_count)
    );
        
    //status counter
    reg reg_status_correction1;
    reg reg_status_correction2;
    reg reg_status_uncorrectable1;
    reg reg_status_uncorrectable2;
        
    always@(posedge i_clk63p5m)begin
        reg_status_correction1 <= status_correction;
        reg_status_correction2 <= reg_status_correction1;
        reg_status_uncorrectable1 <= status_uncorrectable;
        reg_status_uncorrectable2 <= reg_status_uncorrectable1;
    end
    wire count_status_correction;
    wire count_status_uncorrectable;
    assign count_status_correction = reg_status_correction1 & ~reg_status_correction2;
    assign count_status_uncorrectable = reg_status_uncorrectable1 & ~reg_status_uncorrectable2;
    
    
    //because i_seu_count_reset --> 127MHz and i_clk63p5m --> 63.5MHz
    reg reg_seu_count_reset1;
    reg reg_seu_count_reset2;
    always@(posedge i_clk127m)begin
        reg_seu_count_reset1 <= i_seu_count_reset;
        reg_seu_count_reset2 <= reg_seu_count_reset1;
    end
    wire seu_count_reset2;
    assign seu_count_reset2 = reg_seu_count_reset1 | reg_seu_count_reset2;
    
    //counter
    reg [31:0]  reg_seu_error_count;
    always@(posedge i_clk63p5m)begin
        if(seu_count_reset2)begin
            reg_seu_error_count <= 32'h0;
        end
        else if(count_status_correction)begin
            reg_seu_error_count <= reg_seu_error_count + 1'b1;
        end
    end

        reg [31:0]  reg_seu_disable_count;
    always@(posedge i_clk63p5m)begin
        if(seu_count_reset2)begin
            reg_seu_disable_count <= 32'h0;
        end
        else if(count_status_uncorrectable)begin
            reg_seu_disable_count <= reg_seu_disable_count + 1'b1;
        end
    end    
    
    reg [31:0] reg_seu_error_count2;
    reg [31:0] reg_seu_disable_count2;
    always@(posedge i_clk63p5m)begin 
        reg_seu_error_count2 <= reg_seu_error_count;
        reg_seu_disable_count2 <= reg_seu_disable_count;
    end
    assign o_mbe = count_status_uncorrectable;
    assign o_seu_enable_count = reg_seu_error_count2;
    assign o_seu_disable_count = reg_seu_disable_count2;


//*******************************************************************************
//                            SEM Emergency
//*******************************************************************************   

    reg [26:0]   observation_counter;

    always@(posedge i_clk63p5m or posedge rst_63p5m)begin
        if(rst_63p5m)begin
            observation_counter[26:0] <= 27'h0;
        end
        else if(status_observation_level1 | status_correction | status_classification)begin
            observation_counter[26:0] <= 27'h0;
        end
        else if(observation_counter[26] != 1'b1)begin
            observation_counter[26:0] <= observation_counter[26:0] + 1'b1;
        end
    end

    assign o_status_observation = observation_counter[26];


//*******************************************************************************
//                            SEM Emergency
//*******************************************************************************   

    reg [8:0]   hearbeat_counter;

    always@(posedge i_clk63p5m or posedge rst_63p5m)begin
        if(rst_63p5m)begin
            hearbeat_counter[8:0] <= 9'h0;
        end
        else if(status_heartbeat)begin
            hearbeat_counter[8:0] <= 9'h0;
        end
        else if(hearbeat_counter[8] != 1'b1)begin
            hearbeat_counter[8:0] <= hearbeat_counter[8:0] + 1'b1;
        end
    end

    assign o_sem_emergency = hearbeat_counter[8];
    
//*******************************************************************************
//                     Temperature & Voltage Monitor
//*******************************************************************************    
    wire [6:0]      daddr_in;            // Address bus for the dynamic reconfiguration port
    wire            dclk_in;             // Clock input for the dynamic reconfiguration port
    wire            den_in;              // Enable Signal for the dynamic reconfiguration port
    wire [15:0]     di_in;               // Input data bus for the dynamic reconfiguration port
    wire            dwe_in;              // Write Enable for the dynamic reconfiguration port
    wire            reset_in;            // Reset signal for the System Monitor control logic
    wire            busy_out;            // ADC Busy signal
    wire [4:0]      channel_out;         // Channel Selection Outputs
    wire [15:0]     do_out;              // Output data bus for dynamic reconfiguration port
    wire            drdy_out;            // Data ready signal for the dynamic reconfiguration port
    wire            eoc_out;             // End of Conversion Signal
    wire            eos_out;             // End of Sequence Signal
    wire            ot_out;              // Over-Temperature alarm output
    wire            vccaux_alarm_out;    // VCCAUX-sensor alarm output
    wire            vccint_alarm_out;    //  VCCINT-sensor alarm output
    wire            user_temp_alarm_out; // Temperature-sensor alarm output
    wire            alarm_out;   


    //clock divider
    reg [15:0]  clock_divider_counter;
    always@(posedge i_clk63p5m or posedge rst_63p5m)begin
        if(rst_63p5m)begin
            clock_divider_counter <= 16'h0;
        end
        else begin
            clock_divider_counter <= clock_divider_counter + 1'b1;
        end
    end
    
    reg [2:0] xadc_addr;
    always@(posedge i_clk63p5m or posedge rst_63p5m)begin
        if(rst_63p5m)begin
            xadc_addr <= 3'b000;
        end
        else if(clock_divider_counter[15:0] == 16'h0)begin
            xadc_addr <= xadc_addr + 1'b1;
        end
    end
    assign daddr_in =   (xadc_addr == 3'b000) ? 6'h0 :
                        (xadc_addr == 3'b001) ? 6'h1 :
                        (xadc_addr == 3'b010) ? 6'h2 :
                        (xadc_addr == 3'b011) ? 6'h6 :
                        (xadc_addr == 3'b100) ? 6'h3 :
                        (xadc_addr == 3'b101) ? 6'h4 :
                        (xadc_addr == 3'b110) ? 6'h5 :6'h0;
    assign den_in = (clock_divider_counter[15:0] == 16'h00ff) ? 1'b1 : 1'b0;
     
    assign di_in = 16'h0;
    assign dwe_in = 1'b0;
    //assign reset_in = 1'b0;
    

        
    xadc xadc
        (
        .daddr_in              (daddr_in           ),            // Address bus for the dynamic reconfiguration port
        .dclk_in               (i_clk63p5m            ),             // Clock input for the dynamic reconfiguration port
        .den_in                (den_in             ),              // Enable Signal for the dynamic reconfiguration port
        .di_in                 (di_in              ),               // Input data bus for the dynamic reconfiguration port
        .dwe_in                (dwe_in             ),              // Write Enable for the dynamic reconfiguration port
        .reset_in              (rst_63p5m           ),            // Reset signal for the System Monitor control logic
        .busy_out              (busy_out           ),            // ADC Busy signal
        .channel_out           (channel_out        ),            // Channel Selection Outputs
        .do_out                (do_out             ),              // Output data bus for dynamic reconfiguration port
        .drdy_out              (drdy_out           ),            // Data ready signal for the dynamic reconfiguration port
        .eoc_out               (eoc_out            ),             // End of Conversion Signal
        .eos_out               (eos_out            ),             // End of Sequence Signal
        .ot_out                (ot_out             ),              // Over-Temperature alarm output
        .vccaux_alarm_out      (vccaux_alarm_out   ),    // VCCAUX-sensor alarm output
        .vccint_alarm_out      (vccint_alarm_out   ),    //  VCCINT-sensor alarm output
        .user_temp_alarm_out   (user_temp_alarm_out), // Temperature-sensor alarm output
        .alarm_out             (alarm_out          ),           
        .vp_in                 (                   ),               // Dedicated Analog Input Pair
        .vn_in                 (                   )
        );

    reg [11:0]     reg_temperature;
    reg [11:0]     reg_vccint;
    reg [11:0]     reg_vccaux;
    reg [11:0]     reg_vccbram;
    reg [11:0]     reg_vpvn;
    reg [11:0]     reg_vrefp;
    reg [11:0]     reg_vrefn;
    
    always@(posedge i_clk63p5m or posedge rst_63p5m)begin
        if(rst_63p5m)begin
            reg_temperature[11:0] <= 12'h0;
            reg_vccint[11:0] <= 12'h0;
            reg_vccaux[11:0] <= 12'h0;
            reg_vccbram[11:0] <= 12'h0;
        end
        else if(drdy_out && xadc_addr == 3'b000)begin
            reg_temperature[11:0] <= do_out[15:4];
        end
        else if(drdy_out && xadc_addr == 3'b001)begin
            reg_vccint[11:0] <= do_out[15:4];
        end
        else if(drdy_out && xadc_addr == 3'b010)begin
            reg_vccaux[11:0] <= do_out[15:4];
        end
        else if(drdy_out && xadc_addr == 3'b011)begin
            reg_vccbram[11:0] <= do_out[15:4];
        end
        else if(drdy_out && xadc_addr == 3'b100)begin
            reg_vpvn[11:0] <= do_out[15:4];
        end
        else if(drdy_out && xadc_addr == 3'b101)begin
            reg_vrefp[11:0] <= do_out[15:4];
        end
        else if(drdy_out && xadc_addr == 3'b110)begin
            reg_vrefn[11:0] <= do_out[15:4];
        end
    end

    assign o_temperature = reg_temperature;
    assign o_vccint      = reg_vccint;
    assign o_vccaux      = reg_vccaux;
    assign o_vccbram     = reg_vccbram;
    assign o_vpvn        = reg_vpvn;
    assign o_vrefp       = reg_vrefp;
    assign o_vrefn       = reg_vrefn;

endmodule
