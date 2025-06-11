`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2025 15:01:37
// Design Name: 
// Module Name: test_bench
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


module test_bench;

    reg clk = 0, rst = 1, valid_in = 0;
    reg [7:0] data_in;
     wire  msg_valid;
    wire  msg_type;
    wire  [47:0]symbol_id;
    wire  side;
    wire  [63:0]price;
    wire  [63:0]quantity;
    wire  [31:0]order_id;
    
   
    
    udp_plus_fix udp_fix(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .valid_in(valid_in),
    .fix_packet_done_in(packet_done),
    .msg_valid(msg_valid),
    .msg_type(msg_type),
    .symbol_id(symbol_id),
    .side(side),
    .price(price),
    .quantity(quantity),
    .order_id(order_id)
    );

    reg [7:0] packet_mem [0:8400];
    integer i, n;

    always #5 clk = ~clk;

    initial begin
        // Load test data
        $readmemh("C:/Users/krish/FIX_4_4_UDP_bytes_per_line.hex", packet_mem); // hex text file

        #10 rst = 0;
        #5;
        for (i = 0; i < 8400; i = i + 1) begin
            data_in = packet_mem[i];
            valid_in = 1;
            #10;
            if (packet_done) begin
                $display("? Packet completed");
                valid_in = 0;
                #20;
                
            end
        end

        $finish;
    end

endmodule

