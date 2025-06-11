`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2025 14:34:31
// Design Name: 
// Module Name: udp_parser
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


module udp_parser (
    input        clk,
    input        rst,
    input [7:0]  data_in,
    input        valid_in,

    output reg [7:0] payload_data,
    output reg       payload_valid,
    output reg       packet_done
);

    reg [15:0] byte_count,delay_byte_count;
    reg [15:0] udp_length;
    reg [1:0] c_state,n_state;
    reg [7:0] temp_payload_data;
    reg temp_payload_valid,temp_packet_done;

    localparam IDLE   = 2'd0;
    localparam HEADER = 2'd1;
    localparam PAYLOAD = 2'd2;
    
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    c_state <= IDLE;
    end
    else begin
    c_state <= n_state;
    end
    end
    
    
    always@(posedge clk or posedge rst) begin
    if(rst) byte_count <=0;
    else begin 
     if(valid_in) byte_count<=byte_count+1;
    else byte_count<=0;
    end
    end

    always@(posedge clk or posedge rst) begin
    if(rst) udp_length <=0;
    else begin
     if(c_state != IDLE) begin
       if(byte_count == 4)
          udp_length[15:8] <=  data_in;
       else if(byte_count == 5)
          udp_length[7:0] <= data_in;
       else
          udp_length <= udp_length;
      end 
      else udp_length <=0 ;
     end
    end
    
    always@(*) begin 
    if((byte_count==udp_length)&(c_state==IDLE)) packet_done = 1;
    else packet_done = 0;
    end
    
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    payload_data  <= 0;
    payload_valid <= 0;
    end
    else begin
     payload_data  <= temp_payload_data;
    payload_valid <= temp_payload_valid;
    end
    end
    
    
 
    always@(posedge clk or posedge rst) begin
    if(rst) begin 
      temp_payload_data <= 0; 
      temp_payload_valid <= 0; 
    end
    else begin
    if(c_state == PAYLOAD) begin
       if(valid_in) begin
         temp_payload_data <= data_in;
         temp_payload_valid <= 1;
       end 
       else begin
         temp_payload_data <= 0;
         temp_payload_valid <= 0;
       end
    end
    else begin
      temp_payload_data  <= 0;
      temp_payload_valid <= 0;
    end 
   end
   end       
    
    always@(*) begin
    n_state = c_state;
    case(c_state)
    IDLE: begin
     if(valid_in) begin
        n_state = HEADER;
        end
     end
     HEADER: begin
     if(byte_count == 7)
     n_state = PAYLOAD;
     end
     PAYLOAD: begin
       if(byte_count == (udp_length -1)) begin 
        n_state = IDLE; 
       end 
     end 
   endcase
 end
       
     
    
    
    
    
    
endmodule
