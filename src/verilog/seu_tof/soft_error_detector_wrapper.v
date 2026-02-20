`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/01/06 00:34:36
// Design Name: 
// Module Name: soft_error_detector_wrapper
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


module soft_error_detector_wrapper(
    input   i_clk,      // System clock
    input   i_rst,      // System reset
    //output  o_flk,
    output  error_A,  // 
    output  error_B       // Error signal
    );
    
    parameter origin = "X0Y0";

    (* RLOC_ORIGIN = origin, KEEP = "true" *)
     soft_error_detector_V2  soft_error_detector_V2(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .error_A(error_A),
        .error_B(error_B)
     );


endmodule
