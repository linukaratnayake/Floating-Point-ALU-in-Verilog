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
    input input_en,
    output reg tx,
    output reg result_ready
    );

    parameter NUM_BITS = 32;

    wire clk, Rxclk_en, Txclk_en;
    wire [7:0] rx_data_out;
    wire receiver_ready;

    reg [NUM_BITS - 1:0] operand_a, operand_b;
    reg [NUM_BITS - 1:0] result;
    reg [3:0] operation;
    reg exception, overflow, underflow;

    reg [NUM_BITS - 1:0] data_received;

    enum [2:0] {IDLE, GET_OP_A, GET_OP_B, GET_OP, DONE} state_t;
    state_t state = IDLE, next_state;

    // Floating point ALU
    ALU ALU_inst(
        .a_operand(operand_a),
        .b_operand(operand_b),
        .Operation(operation),
        .ALU_Output(result),
        .Exception(exception),
        .Overflow(overflow),
        .Underflow(underflow)
    );

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
        .data_out(data_received)
    );

    always @(*) begin
        next_state = state;

        if (input_en) begin
            case (state)
                IDLE: begin
                    if (receiver_ready) begin
                        next_state <= GET_OP_A;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end

                GET_OP_A: begin
                    if (~receiver_ready) begin
                        next_state <= GET_OP_B;
                    end
                    else begin
                        next_state <= GET_OP_A;
                    end
                end

                GET_OP_B: begin
                    if (~receiver_ready) begin
                        next_state <= GET_OP;
                    end
                    else begin
                        next_state <= GET_OP_B;
                    end
                end

                GET_OP: begin
                    if (~receiver_ready) begin
                        next_state <= DONE;
                    end
                    else begin
                        next_state <= GET_OP;
                    end
                end

                DONE: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        state <= next_state;

        case (state)
            IDLE: begin
                result_ready <= 1;
            end

            GET_OP_A: begin
                operand_a <= data_received;
                result_ready <= 0;
            end

            GET_OP_B: begin
                operand_b <= data_received;
                result_ready <= 0;
            end

            GET_OP: begin
                operation <= data_received[3:0];
                result_ready <= 0;
            end

            DONE: begin
                // Do nothing
            end
        endcase
    end
endmodule
