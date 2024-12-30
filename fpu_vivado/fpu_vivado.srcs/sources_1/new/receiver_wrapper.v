`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2024 09:11:02 PM
// Design Name: 
// Module Name: receiver_wrapper
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


module receiver_wrapper
    # (
        parameter NUM_BYTES = 32
    )
    (
        input clk,
        input rx,
        input Rxclk_en,
        output reg ready,
        output reg [8 * NUM_BYTES - 1:0] data_out
    );

    wire rx_ready;
    wire [7:0] rx_data_out;

    reg [8 * NUM_BYTES - 1:0] data;

    parameter log2_NUM_BYTES = $clog2(NUM_BYTES);
    reg [log2_NUM_BYTES - 1:0] counter = 0;

    typedef enum logic [1:0] {IDLE, RECEIVE_BYTE, BYTE_RECEIVED, DATA_RECEIVED} state_t;
    state_t state = IDLE, next_state;

    // UART receiver
    receiver receiver_inst(
        .Rx(rx),
        .ready(rx_ready),
        .clk_50m(clk),
        .clken(Rxclk_en),
        .data_out(rx_data_out)
    );


    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (rx_ready) begin
                    next_state = RECEIVE_BYTE;
                end
                else begin
                    next_state = IDLE;
                end
            end

            RECEIVE_BYTE: begin
                next_state = BYTE_RECEIVED;
            end

            BYTE_RECEIVED: begin
                // Checks if 'rx_ready' goes low after receiving a byte.
                if (~rx_ready) begin
                    if (counter == NUM_BYTES - 1) begin
                        next_state = DATA_RECEIVED;
                    end
                    else begin
                        next_state = RECEIVE_BYTE;
                    end
                end
                else begin
                    next_state = BYTE_RECEIVED;
                end
            end

            DATA_RECEIVED: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        state <= next_state;

        case (state)
            IDLE: begin
                counter <= 0;
                ready <= 0;
            end

            RECEIVE_BYTE: begin
                data[8 * counter +: 8] <= rx_data_out;
                counter <= counter + 1;
                ready <= 0;
            end

            BYTE_RECEIVED: begin
                ready <= 0;
            end

            DATA_RECEIVED: begin
                data_out <= data;
                ready <= 1;
            end
        endcase
    end
endmodule
