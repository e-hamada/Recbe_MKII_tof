`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/06/30 20:56:00
// Design Name: 
// Module Name: monitor_control
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


module monitor_control2(
    clk,
    rst,
    send_monitor_value,
    send_monitor_start,
    monitor_rx
    );
    
    parameter divide_p = 48;  //divide clock (= 100M / 2083343)
    input clk;
    input rst;
    input [7:0] send_monitor_value;
    input send_monitor_start;
    output monitor_rx;
    
    
    //make clock 
    reg [13:0] reg_rs232c_counter;
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            reg_rs232c_counter <= 14'h0;
        end
        else if(reg_rs232c_counter == divide_p)begin
            reg_rs232c_counter <= 14'h0;
        end
        else begin
            reg_rs232c_counter <= reg_rs232c_counter + 1;
        end
    end
    
    reg [3:0] counter;
    
    
    //make start_signal
    reg reg_send_monitor_start1;
    reg reg_send_monitor_start2;
    wire start_signal;
    always@(posedge clk)begin
        reg_send_monitor_start1 <= send_monitor_start;
        reg_send_monitor_start2 <= reg_send_monitor_start1;
    end
    assign start_signal = reg_send_monitor_start1 & ~reg_send_monitor_start2;
    
    reg send_en;
    always@(posedge clk)begin
        if(start_signal)begin
            send_en <= 1'b1;
        end
        else if(counter == 4'd10)begin
            send_en <= 1'b0;
        end
    
    end
    
    
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            counter <= 4'h0; 
        end
        else if(send_en)begin
            if(reg_rs232c_counter == 4'h0)begin
                counter <= counter + 1'b1;
            end
        end
        else begin
            counter <= 4'h0;
        end
    end

    assign monitor_rx = counter == 4'd1 ? 1'b0 :
                        counter == 4'd2 ? send_monitor_value[0] :
                        counter == 4'd3 ? send_monitor_value[1] :
                        counter == 4'd4 ? send_monitor_value[2] :
                        counter == 4'd5 ? send_monitor_value[3] :
                        counter == 4'd6 ? send_monitor_value[4] :
                        counter == 4'd7 ? send_monitor_value[5] :
                        counter == 4'd8 ? send_monitor_value[6] :
                        counter == 4'd9 ? send_monitor_value[7] :
                        counter == 4'd10 ? 1'b1 : 1'b1;
    

    
    
endmodule
