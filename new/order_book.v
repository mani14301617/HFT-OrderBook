`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.05.2025 10:13:18
// Design Name: 
// Module Name: order_book
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


module order_book(
    input clk,
    input rst,
    input msg_valid,
    input msg_type,
    input [47:0]symbol_id,
    input side,
    input [63:0]price,
    input [63:0]orig_price,
    input [63:0]quantity,
    input [31:0]orig_order_id,
    input [31:0]order_id
    );
    
    localparam FOO =  48'h000000464f4f;
    localparam ABC =  48'h000000414243;
    localparam XYZ =  48'h00000058595A;
    localparam BAR =  48'h000000424152;
    localparam MSFT = 48'h00004D534654;
    
    
    
    
    reg [2:0]Symbol_encode ;
    
    always@(*) begin
    Symbol_encode = 3'b000;
    case(symbol_id)
    ABC : 
    begin
    Symbol_encode = 3'b001;
    end
    FOO : 
    begin
    Symbol_encode = 3'b010;
    end
    XYZ :
    begin
    Symbol_encode = 3'b011;
    end
    BAR : 
    begin
    Symbol_encode = 3'b111;
    end
    MSFT :
    begin
    Symbol_encode = 3'b101;
    end
    endcase
    end
    
    reg [2:0] foo_b;
    reg [63:0]FOO_bid_order[7:0];
    reg [7:0]foo_b_place;
    reg [31:0]FOO_bid_orderID[7:0];
    reg [2:0] foo_a;
    reg [63:0]FOO_ask_order[7:0];
    reg [31:0]FOO_ask_orderID[7:0];
    reg [7:0]foo_a_place;
    
    reg [2:0] abc_b;
    reg [63:0]ABC_bid_order[7:0];
    reg [31:0]ABC_bid_orderID[7:0];
    reg [7:0]abc_b_place;
    reg [2:0] abc_a;
    reg [63:0]ABC_ask_order[7:0];
    reg [31:0]ABC_ask_orderID[7:0];
    reg [7:0]abc_a_place;
    
    reg [2:0] xyz_b;
    reg [63:0]XYZ_bid_order[7:0];
    reg [31:0]XYZ_bid_orderID[7:0];
    reg [7:0]xyz_b_place;
    reg [2:0] xyz_a;
    reg [63:0]XYZ_ask_order[7:0];
    reg [31:0]XYZ_ask_orderID[7:0];
    reg [7:0]xyz_a_place;
    
    reg [2:0] bar_b;
    reg [63:0]BAR_bid_order[7:0];
    reg [31:0]BAR_bid_orderID[7:0];
    reg [7:0]bar_b_place;
    reg [2:0] bar_a;
    reg [63:0]BAR_ask_order[7:0];
    reg [31:0]BAR_ask_orderID[7:0];
    reg [7:0]bar_a_place;
    
    reg [2:0] msft_b;
    reg [63:0]MSFT_bid_order[7:0];
    reg [31:0]MSFT_bid_orderID[7:0];
    reg [7:0]msft_b_place;
    reg [2:0] msft_a;
    reg [63:0]MSFT_ask_order[7:0];
    reg [31:0]MSFT_ask_orderID[7:0];
    reg [7:0]msft_a_place;
    
    integer i;
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    foo_b <= 0;
    foo_a <= 0;
    abc_b <= 0;
    abc_a <= 0;
    xyz_b <= 0;
    xyz_a <= 0;
    bar_b <= 0;
    bar_a <= 0;
    msft_b <= 0;
    msft_a <= 0;
    foo_b_place <= 0;
    foo_a_place <= 0;
    abc_b_place <= 0;
    abc_a_place <= 0;
    xyz_b_place <= 0;
    xyz_a_place <= 0;
    bar_b_place <= 0;
    bar_a_place <= 0;
    msft_b_place <= 0;
    msft_a_place <= 0;
    end
    else begin
    if(msg_valid) begin
    case(Symbol_encode)
    
    3'b001:
    begin
    if(side) begin
     abc_b<=abc_b+1;
    ABC_bid_order[abc_b] <= ;
    ABC_bid_orderID;
    end
    
    end
    3'b010:
    begin
    
    end
    3'b011:
    begin
    
    end
    3'b111:
    begin
    
    end
    3'b101:
    begin
    
    end
    endcase
    end
    end
    end
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    
    for(i=0;i<8;i=i+1) begin
    FOO_bid_order[i]  <=0;
    FOO_bid_orderID[i]<=0;
    FOO_ask_order[i]  <=0;
    FOO_ask_orderID[i]<=0;
    ABC_bid_order[i]  <=0;
    ABC_bid_orderID[i]<=0;
    ABC_ask_order[i]  <=0;
    ABC_ask_orderID[i]<=0;
    XYZ_bid_order[i]  <=0;
    XYZ_bid_orderID[i]<=0;
    XYZ_ask_order[i]  <=0;
    XYZ_ask_orderID[i]<=0;
    BAR_bid_order[i]  <=0;
    BAR_bid_orderID[i]<=0;
    BAR_ask_order[i]  <=0;
    BAR_ask_orderID[i]<=0;
    MSFT_bid_order[i]  <=0;
    MSFT_bid_orderID[i]<=0;
    MSFT_ask_order[i]  <=0;
    MSFT_ask_orderID[i]<=0;
    
    end
    end
    else begin
    if(msg_valid) begin
    case(Symbol_encode)
    
    3'b001:
    begin
    
    end
    3'b010:
    begin
    
    end
    3'b011:
    begin
    
    end
    3'b111:
    begin
    
    end
    3'b101:
    begin
    
    end
    endcase
    end
    end
    end
    
    
    
    
    
endmodule
