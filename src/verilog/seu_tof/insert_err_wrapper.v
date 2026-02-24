module insert_err_wrapper(
        clk,
        rst,
        error_A,
        error_B,
        start,
        insert_err_count
    );

    parameter counter_bit_num = 6;

    input   clk;
    input   rst;
    output  error_A;
    output  error_B;
    input   start;
    input   [7:0] insert_err_count;

    reg out_sig;

    // internal signals
    reg        start_d;
    reg        start_pulse;

    reg        active;
    reg [7:0]  cnt16;      // 8-bit counter (0..255)
    reg [7:0]  turn_cnt;   // number of wraps counted

    // always #1 : start edge detect
    always @(posedge clk) begin
        if (rst) begin
            start_d     <= 1'b0;
            start_pulse <= 1'b0;
        end else begin
            start_d     <= start;
            start_pulse <= (!start_d && start); // 1clk pulse
        end
    end

    // always #2 : active & out_sig
    always @(posedge clk) begin
        if (rst) begin
            active  <= 1'b0;
            out_sig <= 1'b0;
        end else begin
            if (start_pulse) begin
                active  <= 1'b1;
                out_sig <= 1'b1;
            end else if (active && (turn_cnt >= insert_err_count)) begin
                // stop after insert_err_count wraps
                active  <= 1'b0;
                out_sig <= 1'b0;
            end
        end
    end

    // always #3 : counter runs only when active
    always @(posedge clk) begin
        if (rst) begin
            cnt16 <= 8'd0;
        end else if (start_pulse) begin
            cnt16 <= 8'd0;
        end else if (active) begin
            cnt16 <= cnt16 + 8'd1;
        end
    end

    // always #4 : wrap counter
    always @(posedge clk) begin
        if (rst) begin
            turn_cnt <= 8'd0;
        end else if (start_pulse) begin
            turn_cnt <= 8'd0;
        end else if (active && (cnt16 == 8'hFF)) begin
            turn_cnt <= turn_cnt + 8'd1;
        end
    end

//--------------------------------------
//debug
//--------------------------------------
    //debug
    wire insert_err_sig_A;
    wire insert_err_sig_B;
     insert_err  insert_err(
        .i_clk(clk),
        .i_rst(rst),
        .error_A(insert_err_sig_A),
        .error_B(insert_err_sig_B)
     );   


    assign error_A = active ? insert_err_sig_A : 1'b0;
    assign error_B = active ? insert_err_sig_B : 1'b0;


endmodule