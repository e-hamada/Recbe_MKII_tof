`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/07/01 14:09:39
// Design Name: 
// Module Name: monitor_decode
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


module monitor_decode2(
        clk,
        rst,
        monitor_tx,
        read_monitor_tx,
        get_data_en
    );
    
    parameter divide_p = 31;  //divide clock 100MHz --> 2083343
    input clk;
    input rst;
    input monitor_tx;
    output [7:0] read_monitor_tx;
    output get_data_en;
    reg send_en;
    
    
    reg send_en_old;
    always@(posedge clk)begin
        send_en_old <= send_en;
    end
   
    //make clock 
    reg [13:0] reg_rs232c_counter;
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            reg_rs232c_counter <= 14'h0;
        end
        else if(send_en && ~send_en_old)begin
            reg_rs232c_counter <= 14'd10;
        end
        else if(reg_rs232c_counter == divide_p)begin
            reg_rs232c_counter <= 14'h0;
        end
        else begin
            reg_rs232c_counter <= reg_rs232c_counter + 1;
        end
    end
    

    
    reg [3:0] counter;
    reg [12:0] counter_get_data;
    reg [9:0] reg_read_monitor_tx;


    reg first_frag;
    always@(posedge clk)begin
        if(~monitor_tx)begin
            send_en <= 1'b1;
            
        end
        else if(counter == 4'h1 && monitor_tx && first_frag)begin
            send_en <= 1'b0;
        end
    end  
 
    reg reg_get_data_en;
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            counter <= 15'h0;
            reg_get_data_en <= 1'b0;
            reg_read_monitor_tx <= 10'd0;
            counter_get_data <= 13'd0;
            first_frag <= 1'b0;
        end
        else if(send_en)begin
            if(reg_rs232c_counter == 4'h0 && counter == 4'd10)begin
                counter <= 4'd1;
                //reg_get_data_en <= 1'b1;
                counter_get_data <= counter_get_data + 1'b1;
                first_frag <= 1'b1;
            end
            else if(reg_rs232c_counter == 4'd15 && counter == 4'd10)begin
                reg_get_data_en <= 1'b1;
            end
            else if(reg_rs232c_counter == 4'h0)begin
                counter <= counter + 1'b1;
                reg_read_monitor_tx[counter] <= monitor_tx;
                first_frag <= 1'b1;
            end
            else begin
                reg_get_data_en <= 1'b0;
                first_frag <= 1'b0;
            end
        end
        else begin
            counter <= 4'h0;
        end
    end  
    
    //wire [7:0] read_monitor_tx;
    reg [7:0] reg_read_monitor_tx2;
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            reg_read_monitor_tx2[7:0] <= 8'h0;
        end
        else if(reg_get_data_en)begin
            reg_read_monitor_tx2[7:0] <= reg_read_monitor_tx[8:1];
        end 
    end
    
    assign read_monitor_tx[7:0] = reg_read_monitor_tx2[7:0];
    assign get_data_en = reg_get_data_en;
       
endmodule
