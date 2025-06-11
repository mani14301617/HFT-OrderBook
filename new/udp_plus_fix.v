`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.05.2025 23:59:28
// Design Name: 
// Module Name: udp_plus_fix
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


module udp_plus_fix(
    input        clk,
    input        rst,
    input [7:0]  data_in,
    input        valid_in,
    output       fix_packet_done_in,
    output  msg_valid,
    output  msg_type,
    output  [47:0]symbol_id,
    output  side,
    output  [63:0]price,
    output  [63:0]quantity,
    output  [31:0]order_id
    );
    
    wire [7:0]fix_data_in;
    wire fix_valid_in;
    wire  msg_complete;
    wire [7:0]tag;
    wire tag_valid;
    wire value_valid;
    wire [7:0]value;
    wire [7:0]checksum;
    wire checksum_valid;
    udp_parser udp(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .valid_in(valid_in),
    .payload_data(fix_data_in),
    .payload_valid(fix_valid_in),
    .packet_done(fix_packet_done_in)
    );
    
    fix_parser fp(
    .clk(clk),
    .rst(rst),
    .data_in(fix_data_in),
    .valid_in(fix_valid_in),
    .msg_complete(msg_complete),
    .tag(tag),
    .tag_valid(tag_valid),
    .value_valid(value_valid),
    .value(value),
    .checksum(checksum),
    .checksum_valid(checksum_valid)
);
    
    fix_to_order_book fto(
    .clk(clk),
    .rst(rst),
    .msg_complete(msg_complete),
    .tag(tag),
    .tag_valid(tag_valid),
    .value_valid(value_valid),
    .value(value),
    .checksum(checksum),
    .checksum_valid(checksum_valid),
    .msg_valid(msg_valid),
    .msg_type(msg_type),
    .symbol_id(symbol_id),
    .side(side),
    .price(price),
    .quantity(quantity),
    .order_id(order_id)
    );
    
    

endmodule
