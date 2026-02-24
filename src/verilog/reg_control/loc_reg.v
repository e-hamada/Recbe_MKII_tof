`timescale 1ns / 1ps
/*******************************************************************************
*                                                                              *
* System      : COTTRI Mother board                                            *
* Module      : LOC_REG                                                        *
* Version     : v 3.2.0 2011/04/04                                             *
*                                                                              *
* Description : Slow control; registers                                        *
*                                                                              *
* Designer    : Tomohisa Uchida                                                *
*                                                                              *
*                Copyright (c) 2011 Tomohisa Uchida                            *
*                All rights reserved                                           *
*                                                                              *
*******************************************************************************/


module loc_reg #(
        FW_VERSION  = 8'd0,
        YEAR        = 8'd26,
        MONTH       = 8'd01,
        DAY         = 8'd10
    )(
        input               i_clk,              // Clock
        input               i_rst,              // System reset
        // Register I/F
        input     [31:0]    i_loc_addr,         // Address[31:0]
        input     [7:0]     i_loc_wd,           // Data[7:0]
        input               i_loc_we,           // Write enable
        input               i_loc_re,           // Read enable
        output              o_loc_ack,          // Access acknowledge
        output    [7:0]     o_loc_rd,           // Read data[7:0]
        // Register MAP
        output              o_run_reset,
        // monitor
        output              o_mon_rst,
        input     [15:0]    i_seu_en_cnt,
        input     [15:0]    i_seu_dis_cnt,
        input               i_mbe,
        output    [7:0]     o_seu_mon_rx,
        output              o_seu_mon_cmd,
        output              o_seu_cnt_rst,
        input     [7:0]     i_seu_mon_dout,
        input               i_sem_emergency,
        output              o_sem_inj_strobe,
        output    [31:0]    o_sem_inj_cmd_addr,
        input     [15:0]    i_sem_heartbeat,
        input               i_stat_observation,
        input               i_stat_init,
        input               i_stat_seu,
        input               i_stat_mbe,
        input               i_stat_simack,
        input     [11:0]    i_temperature,      // FPGA temperature
        input     [11:0]    i_vccint,           // FPGA VCCINT [V] 
        input     [11:0]    i_vccaux,           // FPGA VCCAUX [V] 
        input     [11:0]    i_vccbram,          // FPGA VCCBRAM [V]
        input     [11:0]    i_vpvn,             // FPGA VPVN [V]   
        input     [11:0]    i_vrefp,            // FPGA VREFP [V]  
        input     [11:0]    i_vrefn,             // FPGA VREFN [V]
        output              start,
        output [7:0]        insert_err_count  
    );

//------------------------------------------------------------------------------
//    Input buffer
//------------------------------------------------------------------------------
    reg     [2:0]   regCs;
    reg     [10:0]  irAddr;
    reg             irWe;
    reg             irRe;
    reg     [7:0]   irWd;

    always@ (posedge i_clk) begin                                 
        regCs[0]     <= (i_loc_addr[31:4]==28'h0);    // 0x0000:  System  
        regCs[1]     <= (i_loc_addr[31:4]==28'h1);    // 0x0010:  SEM
        regCs[2]     <= (i_loc_addr[31:4]==28'h2);    // 0x0020:  SEM

        irAddr[10:0] <= i_loc_addr[10:0];
        irWe         <= i_loc_we;
        irRe         <= i_loc_re;
        irWd[7:0]    <= i_loc_wd[7:0];
    end

//------------------------------------------------------------------------------
//    Receive
//------------------------------------------------------------------------------
    // System
    reg              x04_Reg   ;  // Run reset
    // Monitor
    reg              x10_Reg   ;  // Monitor reset
    reg              x11_Reg   ;  // Reset soft-error counter
    reg              x12_Reg   ;  // SEM command {o_seu_mon_cmd, o_seu_mon_rx[7:0]}
    reg     [7:0]    x13_Reg   ;  // SEM command {o_seu_mon_cmd, o_seu_mon_rx[7:0]}
    reg              x1B_Reg   ;  // Injection strobe
    reg     [7:0]    x1C_Reg   ;  // Injection command and address [31:24]
    reg     [7:0]    x1D_Reg   ;  // Injection command and address [23:16]
    reg     [7:0]    x1E_Reg   ;  // Injection command and address [15:8]
    reg     [7:0]    x1F_Reg   ;  // Injection command and address [7:0]
    reg     [7:0]    x2E_Reg   ;
    reg     [7:0]    x2F_Reg   ;

    always@ (posedge i_clk or posedge i_rst) begin
        ///////////////////////////////////////////////////////
        // Default Setup
        ///////////////////////////////////////////////////////
        if(i_rst)begin
            // System
            x04_Reg         <= 8'h00; // Run reset
            // Monitor
            x10_Reg         <= 1'b0;
            x11_Reg         <= 1'b0;
            x12_Reg         <= 1'b0;
            x13_Reg[7:0]    <= 9'b0;
            x1B_Reg         <= 1'b0;
            x1C_Reg[7:0]    <= 8'd0;
            x1D_Reg[7:0]    <= 8'd0;
            x1E_Reg[7:0]    <= 8'd0;
            x1F_Reg[7:0]    <= 8'd0;
            x2E_Reg[7:0]    <= 8'h0;
            x2F_Reg[7:0]    <= 8'd0;

        ///////////////////////////////////////////////////////
        // Write Registers
        ///////////////////////////////////////////////////////
        end else begin
            if(irWe)begin
                // System
                x04_Reg         <= (regCs[0] & (irAddr[3:0]==4'h4) ? irWd[0]   : x04_Reg     );
                // Monitor
                x10_Reg         <= (regCs[1] & (irAddr[3:0]==4'h0) ? irWd[0]   : x10_Reg     );
                x11_Reg         <= (regCs[1] & (irAddr[3:0]==4'h1) ? irWd[0]   : x11_Reg     );
                x12_Reg         <= (regCs[1] & (irAddr[3:0]==4'h2) ? irWd[0]   : x12_Reg     );
                x13_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x13_Reg[7:0]);
                x1B_Reg         <= (regCs[1] & (irAddr[3:0]==4'hB) ? irWd[0]   : x1B_Reg     );
                x1C_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x1C_Reg[7:0]);
                x1D_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x1D_Reg[7:0]);
                x1E_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x1E_Reg[7:0]);
                x1F_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x1F_Reg[7:0]);
                
                x2E_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x2E_Reg[7:0]); 
                x2F_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x2F_Reg[7:0]); 
            end else begin
                x04_Reg <= 1'b0;
                x10_Reg <= 1'b0;
                x11_Reg <= 1'b0;
            end
        end
    end

    reg      [7:0]    rdDataA ;
    reg      [7:0]    rdDataB ;
    reg      [7:0]    rdDataC ;
        
    reg      [15:0]   regRv   ;
    reg               regAck  ;


///////////////////////////////////////////////////////
// Setup Read Registers
///////////////////////////////////////////////////////
    always@ (posedge i_clk) begin
        // System
        case(irAddr[3:0])
            4'h0:    rdDataA[7:0]     <= FW_VERSION;      // FW version
            4'h1:    rdDataA[7:0]     <= YEAR;            // Year
            4'h2:    rdDataA[7:0]     <= MONTH;           // Month
            4'h3:    rdDataA[7:0]     <= DAY;             // Day
            4'h4:    rdDataA[7:0]     <= {7'd0, x04_Reg}; //
            4'h5:    rdDataA[7:0]     <= 8'h5;            //
            4'h6:    rdDataA[7:0]     <= 8'h6;            //
            4'h7:    rdDataA[7:0]     <= 8'h7;            //
            4'h8:    rdDataA[7:0]     <= 8'h8;            //
            4'h9:    rdDataA[7:0]     <= 8'h9;            //
            4'hA:    rdDataA[7:0]     <= 8'hA;            //
            4'hB:    rdDataA[7:0]     <= 8'hB;            //
            4'hC:    rdDataA[7:0]     <= 8'hC;            //
            4'hD:    rdDataA[7:0]     <= 8'hD;            //
            4'hE:    rdDataA[7:0]     <= 8'hE;            //
            4'hF:    rdDataA[7:0]     <= 8'hF;            //
        endcase
        // Monitor
        case(irAddr[3:0])
            4'h0:    rdDataB[7:0]     <= {7'd0, x10_Reg};         // Monitor reset
            4'h1:    rdDataB[7:0]     <= {7'd0, x11_Reg};         // Reset for soft-error counter
            4'h2:    rdDataB[7:0]     <= {7'd0, x12_Reg};         // SEU Monitor command
            4'h3:    rdDataB[7:0]     <= x13_Reg[7:0];            // SEU Monitor RX
            4'h4:    rdDataB[7:0]     <= i_seu_en_cnt[15:8];
            4'h5:    rdDataB[7:0]     <= i_seu_en_cnt[7:0];
            4'h6:    rdDataB[7:0]     <= i_seu_dis_cnt[7:0];                                    
            4'h7:    rdDataB[7:0]     <= i_seu_mon_dout[7:0];                                   
            4'h8:    rdDataB[7:0]     <= i_sem_heartbeat[15:8];                                   
            4'h9:    rdDataB[7:0]     <= i_sem_heartbeat[7:0];                                   
            4'hA:    rdDataB[7:0]     <= {1'd0, i_mbe, i_stat_observation, i_stat_init,
                                          i_stat_seu, i_stat_mbe, i_stat_simack, i_sem_emergency}; //                            
            4'hB:    rdDataB[7:0]     <= {7'd0, x1B_Reg};         // injection strobe           
            4'hC:    rdDataB[7:0]     <= x1C_Reg[7:0];            // injeection address [31:24] 
            4'hD:    rdDataB[7:0]     <= x1D_Reg[7:0];            // injeection address [23:16] 
            4'hE:    rdDataB[7:0]     <= x1E_Reg[7:0];            // injeection address [15:8]  
            4'hF:    rdDataB[7:0]     <= x1F_Reg[7:0];            // injeection address [7:0]   
        endcase        
        case(irAddr[3:0])
            4'h0:    rdDataC[7:0]     <= {4'd0, i_temperature[11:8]};
            4'h1:    rdDataC[7:0]     <= i_temperature[7:0];
            4'h2:    rdDataC[7:0]     <= {4'd0, i_vccint[11:8]};
            4'h3:    rdDataC[7:0]     <= i_vccint[7:0];
            4'h4:    rdDataC[7:0]     <= {4'd0, i_vccaux[11:8]};
            4'h5:    rdDataC[7:0]     <= i_vccaux[7:0];
            4'h6:    rdDataC[7:0]     <= {4'd0, i_vccbram[11:8]};
            4'h7:    rdDataC[7:0]     <= i_vccbram[7:0];
            4'h8:    rdDataC[7:0]     <= {4'd0,i_vpvn[11:8]};
            4'h9:    rdDataC[7:0]     <= i_vpvn[7:0];
            4'hA:    rdDataC[7:0]     <= {4'd0, i_vrefp[11:8]}; 
            4'hB:    rdDataC[7:0]     <= i_vrefp[7:0];           
            4'hC:    rdDataC[7:0]     <= {4'd0, i_vrefn[11:8]};
            4'hD:    rdDataC[7:0]     <= i_vrefn[7:0];
            4'hE:    rdDataC[7:0]     <= x2E_Reg[7:0];
            4'hF:    rdDataC[7:0]     <= x2F_Reg[7:0]; 
        endcase        
        
        regRv[2:0]   <= (irRe    ? regCs[2:0] : 3'd0);
        regAck       <= (|regCs[2:0]) & (irWe | irRe);
    end

    reg     [7:0]    orRd    ;
    reg              orAck   ;

    always@ (posedge i_clk) begin
        orRd[7:0]  <=   (regRv[0]   ? rdDataA[7:0]     : 8'd0)|
                        (regRv[1]   ? rdDataB[7:0]     : 8'd0)|
                        (regRv[2]   ? rdDataC[7:0]     : 8'd0);
        orAck      <=   regAck;
    end

    assign  o_loc_ack        = orAck     ;
    assign  o_loc_rd[7:0]    = orRd[7:0] ;

    // System
    assign  o_run_reset       = x04_Reg;
    // Monitor 
    assign  o_mon_rst         = x10_Reg;
    assign  o_seu_cnt_rst     = x11_Reg;
    assign  o_seu_mon_cmd     = x12_Reg;
    assign  o_seu_mon_rx[7:0] = x13_Reg[7:0];
    assign  o_sem_inj_strobe  = x1B_Reg;
    assign  o_sem_inj_cmd_addr[31:0] = {x1C_Reg[7:0], x1D_Reg[7:0], x1E_Reg[7:0], x1F_Reg[7:0]};
    assign  start = x2E_Reg[0];
    assign  insert_err_count = x2F_Reg[7:0];

endmodule
