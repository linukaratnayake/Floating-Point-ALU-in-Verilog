`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/29/2024 01:38:08 PM
// Design Name: 
// Module Name: fpu
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


module fpu(
    input clk,
    input rx,
    output tx,
    );

    wire clk, Rxclk_en, Txclk_en;
    wire [7:0] rx_data_out;
    wire receiver_ready;

    // Baudrate generator for UART communication
    baudrate baudrate_inst(
        .clk_50m(clk),
        .Rxclk_en(Rxclk_en),
        .Txclk_en(Txclk_en)
    );    

    // UART receiver wrapper
    receiver_wrapper receiver_wrapper_inst #(4)
    (
        .clk(clk),
        .rx(rx),
        .Rxclk_en(Rxclk_en),
        .ready(receiver_ready),
        .data_out()
    );



endmodule
