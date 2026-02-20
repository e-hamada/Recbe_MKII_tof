`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2025 05:18:22 PM
// Design Name: 
// Module Name: soft_error_HUB
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


module soft_error_HUB(
    i_clk,      // System clock
    i_rst,      // System reset
    error_A,  // 
    error_B       // Error signal
    );
    
    parameter ERRSIG_ID_num = 11; 
    parameter ARRAY_SIZE = 46;
    parameter X_ARRAY_interval = 4;
    
    //parameter FIRST_X_MAX = 8;
 
    input   i_clk;      // System clock
    input   i_rst;      // System reset
    output  [ERRSIG_ID_num-1:0] error_A;  // 
    output  [ERRSIG_ID_num-1:0] error_B;       // Error signal
 
 
 //---------------------------------------------------------------------   
 //BANK12 (X0Y0)
 //---------------------------------------------------------------------   

    parameter BANK12_ID = 0;
    parameter X_MAX_BANK12 = 80;

    parameter FIRST_X_ORIGIN_BANK12 = 0;
    parameter FIRST_Y_ORIGIN_BANK12 = 0;

    wire [X_MAX_BANK12/X_ARRAY_interval-1:0] error_A_BANK12;
    wire [X_MAX_BANK12/X_ARRAY_interval-1:0] error_B_BANK12;
    
    reg [X_MAX_BANK12/X_ARRAY_interval-1:0] error_A_BANK12_old;
    reg [X_MAX_BANK12/X_ARRAY_interval-1:0] error_B_BANK12_old;

    genvar i_BANK12;
    generate
        for (i_BANK12 = 0; i_BANK12 < (X_MAX_BANK12/X_ARRAY_interval) ; i_BANK12 = i_BANK12 + 1) begin : X_BANK12_for
                
            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK12*X_ARRAY_interval + FIRST_X_ORIGIN_BANK12),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK12)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK12[i_BANK12] ),
                .o_err_B  (error_B_BANK12[i_BANK12] )
            );            
        end
    endgenerate    
    
    always@(posedge i_clk)begin
        error_A_BANK12_old <= error_A_BANK12;
        error_B_BANK12_old <= error_B_BANK12;
    end
    
    assign error_A[BANK12_ID] = |error_A_BANK12_old;
    assign error_B[BANK12_ID] = |error_B_BANK12_old;
    
    
    
 //---------------------------------------------------------------------   
 //BANK13 (X0Y1)
 //---------------------------------------------------------------------   
    parameter BANK13_ID = 1;
    parameter X_MAX_BANK13 = 80;
 
    parameter FIRST_X_ORIGIN_BANK13 = 0;
    parameter FIRST_Y_ORIGIN_BANK13 = 50;
 
    wire [X_MAX_BANK13/X_ARRAY_interval-1:0] error_A_BANK13;
    wire [X_MAX_BANK13/X_ARRAY_interval-1:0] error_B_BANK13;
    
    reg [X_MAX_BANK13/X_ARRAY_interval-1:0] error_A_BANK13_old;
    reg [X_MAX_BANK13/X_ARRAY_interval-1:0] error_B_BANK13_old;
 
    genvar i_BANK13;
    generate
        for (i_BANK13 = 0; i_BANK13 < (X_MAX_BANK13/X_ARRAY_interval) ; i_BANK13 = i_BANK13 + 1) begin : X_BANK13_for
                
            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK13*X_ARRAY_interval + FIRST_X_ORIGIN_BANK13),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK13)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK13[i_BANK13] ),
                .o_err_B  (error_B_BANK13[i_BANK13] )
            );            
        end
    endgenerate    
    
    always@(posedge i_clk)begin
        error_A_BANK13_old <= error_A_BANK13;
        error_B_BANK13_old <= error_B_BANK13;
    end
    
    assign error_A[BANK13_ID] = |error_A_BANK13_old;
    assign error_B[BANK13_ID] = |error_B_BANK13_old;    
    
    
 //---------------------------------------------------------------------   
 //BANK16 (X1Y0)
 //---------------------------------------------------------------------   
    parameter BANK16_ID = 2;
    parameter X_MAX_BANK16 = 80;
 
    parameter FIRST_X_ORIGIN_BANK16 = 0;
    parameter FIRST_Y_ORIGIN_BANK16 = 200;
 
    wire [(X_MAX_BANK16-FIRST_X_ORIGIN_BANK16)/X_ARRAY_interval-1:0] error_A_BANK16;
    wire [(X_MAX_BANK16-FIRST_X_ORIGIN_BANK16)/X_ARRAY_interval-1:0] error_B_BANK16;
    
    reg [(X_MAX_BANK16-FIRST_X_ORIGIN_BANK16)/X_ARRAY_interval-1:0] error_A_BANK16_old;
    reg [(X_MAX_BANK16-FIRST_X_ORIGIN_BANK16)/X_ARRAY_interval-1:0] error_B_BANK16_old;

 
    genvar i_BANK16;
    generate
        for (i_BANK16 = 0; i_BANK16 < ((X_MAX_BANK16-FIRST_X_ORIGIN_BANK16)/X_ARRAY_interval) ; i_BANK16 = i_BANK16 + 1) begin : X_BANK16_for
                
            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK16*X_ARRAY_interval + FIRST_X_ORIGIN_BANK16),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK16)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK16[i_BANK16] ),
                .o_err_B  (error_B_BANK16[i_BANK16] )
            );            
        end
    endgenerate    
    
    always@(posedge i_clk)begin
        error_A_BANK16_old <= error_A_BANK16;
        error_B_BANK16_old <= error_B_BANK16;
    end
    
    assign error_A[BANK16_ID] = |error_A_BANK16_old;
    assign error_B[BANK16_ID] = |error_B_BANK16_old;        
    
 //---------------------------------------------------------------------   
 //BANK17 (X1Y1)
 //---------------------------------------------------------------------   
    parameter BANK17_ID = 3;
    parameter X_MAX_BANK17 = 80;

    parameter FIRST_X_ORIGIN_BANK17 = 0;
    parameter FIRST_Y_ORIGIN_BANK17 = 250;

    wire [(X_MAX_BANK17-FIRST_X_ORIGIN_BANK17)/X_ARRAY_interval-1:0] error_A_BANK17;
    wire [(X_MAX_BANK17-FIRST_X_ORIGIN_BANK17)/X_ARRAY_interval-1:0] error_B_BANK17;

    reg [(X_MAX_BANK17-FIRST_X_ORIGIN_BANK17)/X_ARRAY_interval-1:0] error_A_BANK17_old;
    reg [(X_MAX_BANK17-FIRST_X_ORIGIN_BANK17)/X_ARRAY_interval-1:0] error_B_BANK17_old;


    genvar i_BANK17;
    generate
        for (i_BANK17 = 0; i_BANK17 < ((X_MAX_BANK17-FIRST_X_ORIGIN_BANK17)/X_ARRAY_interval) ; i_BANK17 = i_BANK17 + 1) begin : X_BANK17_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK17*X_ARRAY_interval + FIRST_X_ORIGIN_BANK17),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK17)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK17[i_BANK17] ),
                .o_err_B  (error_B_BANK17[i_BANK17] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK17_old <= error_A_BANK17;
        error_B_BANK17_old <= error_B_BANK17;
    end

    assign error_A[BANK17_ID] = |error_A_BANK17_old;
    assign error_B[BANK17_ID] = |error_B_BANK17_old;

 //---------------------------------------------------------------------   
 //BANK18 (X1Y2)
 //---------------------------------------------------------------------   
    parameter BANK18_ID = 4;
    parameter X_MAX_BANK18 = 80;

    parameter FIRST_X_ORIGIN_BANK18 = 0;
    parameter FIRST_Y_ORIGIN_BANK18 = 300;

    wire [(X_MAX_BANK18-FIRST_X_ORIGIN_BANK18)/X_ARRAY_interval-1:0] error_A_BANK18;
    wire [(X_MAX_BANK18-FIRST_X_ORIGIN_BANK18)/X_ARRAY_interval-1:0] error_B_BANK18;

    reg [(X_MAX_BANK18-FIRST_X_ORIGIN_BANK18)/X_ARRAY_interval-1:0] error_A_BANK18_old;
    reg [(X_MAX_BANK18-FIRST_X_ORIGIN_BANK18)/X_ARRAY_interval-1:0] error_B_BANK18_old;


    genvar i_BANK18;
    generate
        for (i_BANK18 = 0; i_BANK18 < ((X_MAX_BANK18-FIRST_X_ORIGIN_BANK18)/X_ARRAY_interval) ; i_BANK18 = i_BANK18 + 1) begin : X_BANK18_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK18*X_ARRAY_interval + FIRST_X_ORIGIN_BANK18),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK18)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK18[i_BANK18] ),
                .o_err_B  (error_B_BANK18[i_BANK18] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK18_old <= error_A_BANK18;
        error_B_BANK18_old <= error_B_BANK18;
    end

    assign error_A[BANK18_ID] = |error_A_BANK18_old;
    assign error_B[BANK18_ID] = |error_B_BANK18_old;


 //---------------------------------------------------------------------   
 //BANK32 (X1Y3)
 //---------------------------------------------------------------------   
    parameter BANK32_ID = 5;
    parameter X_MAX_BANK32 = 154;

    parameter FIRST_X_ORIGIN_BANK32 = 80;
    parameter FIRST_Y_ORIGIN_BANK32 = 0;

    wire [(X_MAX_BANK32-FIRST_X_ORIGIN_BANK32)/X_ARRAY_interval-1:0] error_A_BANK32;
    wire [(X_MAX_BANK32-FIRST_X_ORIGIN_BANK32)/X_ARRAY_interval-1:0] error_B_BANK32;

    reg [(X_MAX_BANK32-FIRST_X_ORIGIN_BANK32)/X_ARRAY_interval-1:0] error_A_BANK32_old;
    reg [(X_MAX_BANK32-FIRST_X_ORIGIN_BANK32)/X_ARRAY_interval-1:0] error_B_BANK32_old;


    genvar i_BANK32;
    generate
        for (i_BANK32 = 0; i_BANK32 < ((X_MAX_BANK32-FIRST_X_ORIGIN_BANK32)/X_ARRAY_interval) ; i_BANK32 = i_BANK32 + 1) begin : X_BANK32_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK32*X_ARRAY_interval + FIRST_X_ORIGIN_BANK32),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK32)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK32[i_BANK32] ),
                .o_err_B  (error_B_BANK32[i_BANK32] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK32_old <= error_A_BANK32;
        error_B_BANK32_old <= error_B_BANK32;
    end

    assign error_A[BANK32_ID] = |error_A_BANK32_old;
    assign error_B[BANK32_ID] = |error_B_BANK32_old;

 //---------------------------------------------------------------------   
 //BANK33 (X1Y4)
 //---------------------------------------------------------------------   
    parameter BANK33_ID = 6;
    parameter X_MAX_BANK33 = 154;

    parameter FIRST_X_ORIGIN_BANK33 = 80;
    parameter FIRST_Y_ORIGIN_BANK33 = 50;

    wire [(X_MAX_BANK33-FIRST_X_ORIGIN_BANK33)/X_ARRAY_interval-1:0] error_A_BANK33;
    wire [(X_MAX_BANK33-FIRST_X_ORIGIN_BANK33)/X_ARRAY_interval-1:0] error_B_BANK33;

    reg [(X_MAX_BANK33-FIRST_X_ORIGIN_BANK33)/X_ARRAY_interval-1:0] error_A_BANK33_old;
    reg [(X_MAX_BANK33-FIRST_X_ORIGIN_BANK33)/X_ARRAY_interval-1:0] error_B_BANK33_old;


    genvar i_BANK33;
    generate
        for (i_BANK33 = 0; i_BANK33 < ((X_MAX_BANK33-FIRST_X_ORIGIN_BANK33)/X_ARRAY_interval) ; i_BANK33 = i_BANK33 + 1) begin : X_BANK33_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK33*X_ARRAY_interval + FIRST_X_ORIGIN_BANK33),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK33)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK33[i_BANK33] ),
                .o_err_B  (error_B_BANK33[i_BANK33] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK33_old <= error_A_BANK33;
        error_B_BANK33_old <= error_B_BANK33;
    end

    assign error_A[BANK33_ID] = |error_A_BANK33_old;
    assign error_B[BANK33_ID] = |error_B_BANK33_old;

 //---------------------------------------------------------------------   
 //BANK34 (X1Y4)
 //---------------------------------------------------------------------   
    parameter BANK34_ID = 7;
    parameter X_MAX_BANK34 = 154;

    parameter FIRST_X_ORIGIN_BANK34 = 104;
    parameter FIRST_Y_ORIGIN_BANK34 = 100;

    wire [(X_MAX_BANK34-FIRST_X_ORIGIN_BANK34)/X_ARRAY_interval-1:0] error_A_BANK34;
    wire [(X_MAX_BANK34-FIRST_X_ORIGIN_BANK34)/X_ARRAY_interval-1:0] error_B_BANK34;

    reg [(X_MAX_BANK34-FIRST_X_ORIGIN_BANK34)/X_ARRAY_interval-1:0] error_A_BANK34_old;
    reg [(X_MAX_BANK34-FIRST_X_ORIGIN_BANK34)/X_ARRAY_interval-1:0] error_B_BANK34_old;


    genvar i_BANK34;
    generate
        for (i_BANK34 = 0; i_BANK34 < ((X_MAX_BANK34-FIRST_X_ORIGIN_BANK34)/X_ARRAY_interval) ; i_BANK34 = i_BANK34 + 1) begin : X_BANK34_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK34*X_ARRAY_interval + FIRST_X_ORIGIN_BANK34),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK34)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK34[i_BANK34] ),
                .o_err_B  (error_B_BANK34[i_BANK34] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK34_old <= error_A_BANK34;
        error_B_BANK34_old <= error_B_BANK34;
    end

    assign error_A[BANK34_ID] = |error_A_BANK34_old;
    assign error_B[BANK34_ID] = |error_B_BANK34_old;

      
 //---------------------------------------------------------------------   
 //QUAD116 (X1Y4)
 //---------------------------------------------------------------------   
    parameter BANK116_ID = 8;
    parameter X_MAX_BANK116 = 144;

    parameter FIRST_X_ORIGIN_BANK116 = 80;
    parameter FIRST_Y_ORIGIN_BANK116 = 200;

    wire [(X_MAX_BANK116-FIRST_X_ORIGIN_BANK116)/X_ARRAY_interval-1:0] error_A_BANK116;
    wire [(X_MAX_BANK116-FIRST_X_ORIGIN_BANK116)/X_ARRAY_interval-1:0] error_B_BANK116;

    reg [(X_MAX_BANK116-FIRST_X_ORIGIN_BANK116)/X_ARRAY_interval-1:0] error_A_BANK116_old;
    reg [(X_MAX_BANK116-FIRST_X_ORIGIN_BANK116)/X_ARRAY_interval-1:0] error_B_BANK116_old;


    genvar i_BANK116;
    generate
        for (i_BANK116 = 0; i_BANK116 < ((X_MAX_BANK116-FIRST_X_ORIGIN_BANK116)/X_ARRAY_interval) ; i_BANK116 = i_BANK116 + 1) begin : X_BANK116_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK116*X_ARRAY_interval + FIRST_X_ORIGIN_BANK116),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK116)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK116[i_BANK116] ),
                .o_err_B  (error_B_BANK116[i_BANK116] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK116_old <= error_A_BANK116;
        error_B_BANK116_old <= error_B_BANK116;
    end

    assign error_A[BANK116_ID] = |error_A_BANK116_old;
    assign error_B[BANK116_ID] = |error_B_BANK116_old;      
      
 //---------------------------------------------------------------------   
 //QUAD117 (X1Y5)
 //---------------------------------------------------------------------   
    parameter BANK117_ID = 9;
    parameter X_MAX_BANK117 = 144;

    parameter FIRST_X_ORIGIN_BANK117 = 80;
    parameter FIRST_Y_ORIGIN_BANK117 = 250;

    wire [(X_MAX_BANK117-FIRST_X_ORIGIN_BANK117)/X_ARRAY_interval-1:0] error_A_BANK117;
    wire [(X_MAX_BANK117-FIRST_X_ORIGIN_BANK117)/X_ARRAY_interval-1:0] error_B_BANK117;

    reg [(X_MAX_BANK117-FIRST_X_ORIGIN_BANK117)/X_ARRAY_interval-1:0] error_A_BANK117_old;
    reg [(X_MAX_BANK117-FIRST_X_ORIGIN_BANK117)/X_ARRAY_interval-1:0] error_B_BANK117_old;


    genvar i_BANK117;
    generate
        for (i_BANK117 = 0; i_BANK117 < ((X_MAX_BANK117-FIRST_X_ORIGIN_BANK117)/X_ARRAY_interval) ; i_BANK117 = i_BANK117 + 1) begin : X_BANK117_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK117*X_ARRAY_interval + FIRST_X_ORIGIN_BANK117),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK117)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK117[i_BANK117] ),
                .o_err_B  (error_B_BANK117[i_BANK117] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK117_old <= error_A_BANK117;
        error_B_BANK117_old <= error_B_BANK117;
    end

    assign error_A[BANK117_ID] = |error_A_BANK117_old;
    assign error_B[BANK117_ID] = |error_B_BANK117_old;        
      
 //---------------------------------------------------------------------   
 //QUAD118 (X1Y5)
 //---------------------------------------------------------------------   
    parameter BANK118_ID = 10;
    parameter X_MAX_BANK118 = 144;

    parameter FIRST_X_ORIGIN_BANK118 = 80;
    parameter FIRST_Y_ORIGIN_BANK118 = 300;

    wire [(X_MAX_BANK118-FIRST_X_ORIGIN_BANK118)/X_ARRAY_interval-1:0] error_A_BANK118;
    wire [(X_MAX_BANK118-FIRST_X_ORIGIN_BANK118)/X_ARRAY_interval-1:0] error_B_BANK118;

    reg [(X_MAX_BANK118-FIRST_X_ORIGIN_BANK118)/X_ARRAY_interval-1:0] error_A_BANK118_old;
    reg [(X_MAX_BANK118-FIRST_X_ORIGIN_BANK118)/X_ARRAY_interval-1:0] error_B_BANK118_old;


    genvar i_BANK118;
    generate
        for (i_BANK118 = 0; i_BANK118 < ((X_MAX_BANK118-FIRST_X_ORIGIN_BANK118)/X_ARRAY_interval) ; i_BANK118 = i_BANK118 + 1) begin : X_BANK118_for

            soft_error_detector_top_V2 #(
                .ARRAY_SIZE (ARRAY_SIZE),
                .ORIGIN_POSITION_X(i_BANK118*X_ARRAY_interval + FIRST_X_ORIGIN_BANK118),
                .FIRST_Y_ORIGIN(FIRST_Y_ORIGIN_BANK118)
            ) soft_error_detector_top(
                .i_clk      (i_clk              ),
                .i_rst      (i_rst                ),
                .o_err_A  (error_A_BANK118[i_BANK118] ),
                .o_err_B  (error_B_BANK118[i_BANK118] )
            );
        end
    endgenerate

    always@(posedge i_clk)begin
        error_A_BANK118_old <= error_A_BANK118;
        error_B_BANK118_old <= error_B_BANK118;
    end

    assign error_A[BANK118_ID] = |error_A_BANK118_old;
    assign error_B[BANK118_ID] = |error_B_BANK118_old;        
      
      
endmodule
