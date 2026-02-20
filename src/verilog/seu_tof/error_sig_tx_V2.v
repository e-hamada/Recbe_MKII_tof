`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/07/2025 01:39:13 PM
// Design Name: 
// Module Name: error_sig_tx_V2
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


module error_sig_tx_V2(
    i_clk,      // System clock
    i_rst,      // System reset
    error_A,  // 
    error_B,       // Error signal
    output_err_sig,
    debug_sig
    );

    parameter ERRSIG_ID_num = 3; 
    parameter ARRAY_SIZE = 40;
    parameter X_ARRAY_interval = 4;
    //parameter FIRST_X_MAX = 8;

    input   i_clk;      // System clock
    input   i_rst;      // System reset
    input  [ERRSIG_ID_num-1:0] error_A;  // 
    input  [ERRSIG_ID_num-1:0] error_B;       // Error signal
    output output_err_sig;
    output debug_sig;
    
    wire total_error_A;
    assign total_error_A = |error_A;
    wire total_error_B;
    assign total_error_B = |error_B;    
    
    
    reg total_error_A_old;
    reg total_error_B_old;
    always@(posedge i_clk)begin
        total_error_A_old <= total_error_A;
        total_error_B_old <= total_error_B;
    end    
    
    wire error_A_level2;
    assign error_A_level2 = (total_error_A != total_error_A_old);
    wire error_B_level2;
    assign error_B_level2 = (total_error_B != total_error_B_old);    
    
    reg [7:0] shift_error_A_level2;
    reg [7:0] shift_error_B_level2;
    always@(posedge i_clk)begin
        shift_error_A_level2[7:0] <= {shift_error_A_level2[6:0], error_A_level2};
        shift_error_B_level2[7:0] <= {shift_error_B_level2[6:0], error_B_level2};
    end    
    
    wire error_A_level3;
    wire error_B_level3;
    assign error_A_level3 = (shift_error_A_level2[7:0] == 8'hFF) ? 1'b1 : 1'b0;
    assign error_B_level3 = (shift_error_B_level2[7:0] == 8'hFF) ? 1'b1 : 1'b0;
    
    wire lut_out;
    
    (* LOC = "SLICE_X0Y136" *)      //--> X162Y75 is the closest LUT to the IOB.
    LUT6 #(
        .INIT (64'h0000_0000_0000_0008)     //--> lut_out = error_A_level3 & error_B_level3
    ) LUT6_A (
        .O(lut_out),
        .I0(error_A_level3),
        .I1(error_B_level3),
        .I2(0),
        .I3(0),
        .I4(0),
        .I5(0) 
    );    
    
    
    (* IOB = "TRUE" *) reg reg_output_err_sig;
    always@(posedge i_clk)begin
        reg_output_err_sig <= lut_out;          
    end     
    
    assign output_err_sig = reg_output_err_sig;
    
    
    assign debug_sig = lut_out;
    
endmodule
