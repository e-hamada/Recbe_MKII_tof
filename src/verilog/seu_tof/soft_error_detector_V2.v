`timescale 1ns / 1ps
module soft_error_detector_V2 (
        input   i_clk,      // System clock
        input   i_rst,      // System reset
        //output  o_flk,
        output  error_A,  // 
        output  error_B       // Error signal
    );
    parameter origin = "X0Y0";


    wire          flicker;
    wire          flicker_inv;
   // (* RLOC_ORIGIN = origin, RLOC = "X0Y0", BEL = "B6LUT" *)
    (* RLOC = "X0Y0", BEL = "B6LUT" *)
    LUT6 #(
        .INIT (64'hFFFF_FFFF_FFFF_FFFD)
    ) LUT6_flicker (
        .O(flicker_inv),
        .I0(flicker),
        .I1(0),
        .I2(0),
        .I3(0),
        .I4(0),
        .I5(0)
    );


    wire   [2:0]  register1, register2;
    //assign o_flk = flicker;

   // (* RLOC = "X1Y0", BEL = "A5FF" *) FDRE #(.INIT(1'b0)) FDRE_FLAG (.Q(flicker),    .C(i_clk), .CE(1'b1), .R(i_rst), .D(~flicker));
   (* RLOC = "X1Y0", BEL = "A5FF" *) FDRE #(.INIT(1'b0)) FDRE_FLAG (.Q(flicker),    .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker_inv));

    (* RLOC = "X0Y0", BEL = "AFF"  *) FDRE #(.INIT(1'b0)) FDRE_0A (.Q(register1[0]), .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker));
    (* RLOC = "X0Y0", BEL = "BFF"  *) FDRE #(.INIT(1'b0)) FDRE_0B (.Q(register1[1]), .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker));
    (* RLOC = "X0Y0", BEL = "B5FF" *) FDRE #(.INIT(1'b0)) FDRE_0C (.Q(register1[2]), .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker));

    (* RLOC = "X0Y0", BEL = "CFF"  *) FDRE #(.INIT(1'b0)) FDRE_1A (.Q(register2[0]), .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker));
    (* RLOC = "X0Y0", BEL = "C5FF" *) FDRE #(.INIT(1'b0)) FDRE_1B (.Q(register2[1]), .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker));
    (* RLOC = "X0Y0", BEL = "DFF"  *) FDRE #(.INIT(1'b0)) FDRE_1C (.Q(register2[2]), .C(i_clk), .CE(1'b1), .R(i_rst), .D(flicker));



    wire          lut_outA, lut_outB, lut_outC, lut_outD;
    wire          lut_out_tmpA, lut_out_tmpB, lut_out_tmpC, lut_out_tmpD;

    (* RLOC = "X1Y0", BEL = "A6LUT" *)
    LUT6 #(
        .INIT (64'h7FFF_FFFF_FFFF_FFFE)
    ) LUT6_A (
        .O(lut_outA),
        .I0(register1[0]),
        .I1(register1[1]),
        .I2(register1[2]),
        .I3(register2[0]),
        .I4(register2[1]),
        .I5(register2[2])
    );

    (* RLOC = "X1Y0", BEL = "B6LUT" *)
    LUT6 #(
        .INIT (64'h7FFF_FFFF_FFFF_FFFE)
    ) LUT6_B (
        .O(lut_outB),
        .I0(register1[0]),
        .I1(register1[1]),
        .I2(register1[2]),
        .I3(register2[0]),
        .I4(register2[1]),
        .I5(register2[2])
    );

    (* RLOC = "X1Y0", BEL = "C6LUT" *)
    LUT6 #(
        .INIT (64'h7FFF_FFFF_FFFF_FFFE)
    ) LUT6_C (
        .O(lut_outC),
        .I0(register1[0]),
        .I1(register1[1]),
        .I2(register1[2]),
        .I3(register2[0]),
        .I4(register2[1]),
        .I5(register2[2])
    );

    (* RLOC = "X1Y0", BEL = "D6LUT" *)
    LUT6 #(
        .INIT (64'h7FFF_FFFF_FFFF_FFFE)
    ) LUT6_D (
        .O(lut_outD),
        .I0(register1[0]),
        .I1(register1[1]),
        .I2(register1[2]),
        .I3(register2[0]),
        .I4(register2[1]),
        .I5(register2[2])
    );


    (* RLOC = "X1Y0", BEL = "AFF" *) FDRE #(.INIT(1'b0)) FDRE_OUTA (.Q(lut_out_tmpA), .C(i_clk), .CE(1'b1), .R(i_rst), .D(lut_outA));
    (* RLOC = "X1Y0", BEL = "BFF" *) FDRE #(.INIT(1'b0)) FDRE_OUTB (.Q(lut_out_tmpB), .C(i_clk), .CE(1'b1), .R(i_rst), .D(lut_outB));
    (* RLOC = "X1Y0", BEL = "CFF" *) FDRE #(.INIT(1'b0)) FDRE_OUTC (.Q(lut_out_tmpC), .C(i_clk), .CE(1'b1), .R(i_rst), .D(lut_outC));
    (* RLOC = "X1Y0", BEL = "DFF" *) FDRE #(.INIT(1'b0)) FDRE_OUTD (.Q(lut_out_tmpD), .C(i_clk), .CE(1'b1), .R(i_rst), .D(lut_outD));


    wire          lut_out0, lut_out1;



    (* RLOC = "X0Y0", BEL = "A6LUT" *)
    LUT6_2 #(
        .INIT (64'hFFFFE)
    ) LUT6_lut_out (
        .O5(error_A),
        .O6(error_B),
        .I0(lut_out_tmpA),
        .I1(lut_out_tmpB),
        .I2(lut_out_tmpC),
        .I3(lut_out_tmpD),
        .I4(1'b0),
        .I5(1'b0)
    );




endmodule
