`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2025 21:44:48
// Design Name: 
// Module Name: fix_parser
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


module fix_parser (
    input        clk,
    input        rst,
    input  [7:0] data_in,
    input        valid_in,
    output reg   msg_complete,
    output reg [7:0] tag,
    output reg tag_valid,
    output reg value_valid,
    output reg [7:0] value,
    output reg [7:0] checksum,
    output reg checksum_valid
);
reg [7:0]LENGTH[0:4];
wire [16:0]body_length_value,temp0,temp1,temp2,temp3,temp4,temp_sum2,temp_sum1,temp_sum3;
localparam IDLE    = 3'b000;
localparam TAG     = 3'b100;
localparam EQUAL   = 3'b101;
localparam VALUE   = 3'b111;
localparam CONTROL = 3'b110; 
localparam DONE    = 3'b010;

reg [2:0]c_state,n_state;
reg body_length_value_en;

reg [16:0]body_length_counter;
reg body_length_done;

reg [2:0]c_s,n_s;
localparam RESET       = 3'b000;
localparam BEGINSTRING = 3'b001;
localparam BODY_LENGTH = 3'b011;
localparam BODY        = 3'b010;
localparam CHECKSUM    = 3'b110;

always@(*) begin
body_length_value_en = (c_s==BODY_LENGTH)&(n_state==VALUE)? 1'b1:1'b0;
tag_valid = (n_state == TAG);
value_valid = (n_state == VALUE);
checksum_valid = (n_state == VALUE)&(c_s == CHECKSUM);
end

assign temp4=17'd10000*{9'b000000000,LENGTH[4]};
assign temp3=17'd1000*{9'b000000000,LENGTH[3]};
assign temp2=17'd100*{9'b000000000,LENGTH[2]};
assign temp1=17'd10*{9'b000000000,LENGTH[1]};
assign temp0={9'b000000000,LENGTH[0]};
assign temp_sum1 = temp4+temp0;
assign temp_sum2 = temp3+temp1;
assign temp_sum3 = temp_sum2+temp2;
assign body_length_value=temp_sum3+temp_sum1;

always@(posedge clk or posedge rst) begin : body_length_stack
if(rst) begin
LENGTH[0] <= 0;
LENGTH[1] <= 0;
LENGTH[2] <= 0;
LENGTH[3] <= 0;
LENGTH[4] <= 0;
end 
else begin
if(body_length_value_en) begin
LENGTH[0] <= data_in - 8'h30;
LENGTH[1] <= LENGTH[0];
LENGTH[2] <= LENGTH[1];
LENGTH[3] <= LENGTH[2];
LENGTH[4] <= LENGTH[3];
end 
else if(c_s==BODY_LENGTH | c_s==BODY) begin
LENGTH[0] <= LENGTH[0];
LENGTH[1] <= LENGTH[1];
LENGTH[2] <= LENGTH[2];
LENGTH[3] <= LENGTH[3];
LENGTH[4] <= LENGTH[4];
end 
else begin
LENGTH[0] <= 0;
LENGTH[1] <= 0;
LENGTH[2] <= 0;
LENGTH[3] <= 0;
LENGTH[4] <= 0;
end 
end
end


always@(posedge clk or posedge rst) begin
if(rst) begin
body_length_counter <= 0;
body_length_done <=0;
end
else begin
if(body_length_counter == body_length_value+1) begin
body_length_counter <= 0;
body_length_done <= 1;
end 

else if(c_s == BODY) begin
body_length_counter <= body_length_counter + 1;
body_length_done <= 0;
end 

else begin
body_length_counter <= 0;
body_length_done <= 0;
end
end
end

always@(posedge clk or posedge rst) begin 
  if(rst) c_state <=0;
  else c_state <= n_state;
end

always@(posedge clk or posedge rst) begin 
if(rst) tag <= 0;
else begin
if(tag_valid) tag <= data_in ;
else tag<=0;
end
end

always@(posedge clk or posedge rst) begin
if(rst) value <= 0;
else begin
if(value_valid) value <= data_in ;
else value <= 0;
end
end

always@(posedge clk or posedge rst) begin
if(rst) checksum <= 0;
else begin
if(checksum_valid) checksum <= data_in ;
else checksum <= 0;
end
end

always@(*) begin
n_state = c_state;
msg_complete =0;
case(c_state)
IDLE : begin
if((n_s == BEGINSTRING) | (n_s == BODY) |(n_s == BODY_LENGTH))
n_state = TAG;
end
TAG : begin
if(data_in == 8'h3d)
n_state = EQUAL;
end
EQUAL : begin
n_state = VALUE;
end
VALUE : begin
if(data_in == 8'h01) begin
  if(c_s == CHECKSUM)
  n_state = DONE;
  else
  n_state = CONTROL;
end
end
CONTROL : begin
n_state = TAG;
end
DONE : begin
msg_complete = 1;
n_state = IDLE;
end
endcase
end 


always@(posedge clk or posedge rst) begin
  if(rst)
   c_s <= 0;
  else
   c_s <= n_s;
end 

always@(*) begin
n_s=c_s;
case(c_s)
RESET : begin
if(data_in == 8'h38)
n_s = BEGINSTRING;
end
BEGINSTRING : begin
if(data_in == 8'h01)
n_s = BODY_LENGTH;
end 
BODY_LENGTH : begin
if(data_in == 8'h01)
n_s = BODY;
end
BODY : begin
if(body_length_done)
n_s = CHECKSUM;
end
CHECKSUM :  begin
if(data_in == 8'h01)
n_s = RESET;
end 
endcase
end
   
endmodule
