`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2025 18:31:43
// Design Name: 
// Module Name: fix_to_order_book
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


module fix_to_order_book(
    input   clk,
    input   rst,
    input   msg_complete,
    input [7:0] tag,
    input tag_valid,
    input value_valid,
    input [7:0] value,
    input [7:0] checksum,
    input checksum_valid,
    output reg msg_valid,
    output reg msg_type,
    output reg [47:0]symbol_id,
    output reg side,
    output reg [63:0]price,
    output reg [63:0]orig_price,
    output reg [63:0]quantity,
    output reg [31:0]orig_order_id,
    output reg [31:0]order_id
    //output reg ready
    );
    
    reg [7:0]tag_stack[0:4];
    reg [7:0]value_stack[0:14];
    reg [7:0]checksum_stack[0:2];
    wire [39:0]tag_data;
    reg  [39:0]tag_data2;
    wire [119:0]value_data;
    reg [119:0]value_data2;
    wire [23:0]checksum_data;
    reg msg_complete_delay1,msg_complete_delay2,msg_complete_delay3,msg_complete_delay4,msg_complete_delay5;
    reg tag_valid_delay1,value_valid_delay1,checksum_valid_delay1;
    
     reg [2:0]tag_cs,tag_ns,value_cs,value_ns;
     //// STATES FOR THE TAG DATA FSM ///////
     localparam TAG_IDLE  = 3'b000 ;
     localparam TAG_START = 3'b001;
     localparam TAG_END   = 3'b011;
     localparam TAG_WAIT  = 3'b010;
     //// STATES FOR THE VALUE DATA FSM ///////
     localparam VALUE_IDLE  = 3'b000 ;
     localparam VALUE_START = 3'b001;
     localparam VALUE_END   = 3'b011;
     localparam VALUE_WAIT  = 3'b010;
     
          /// The necessary tags to use for the order book update /////////
     reg [119:0]MsgType,ClOrdID,OrigClOrdID,OrderID,ExecType,OrdStatus,Price,OrderQty,Side,CumQty,LeavesQty,Symbol,LastPx;
     wire [39:0]MsgType_tag,ClOrdID_tag,OrigClOrdID_tag,OrderID_tag,ExecType_tag,OrdStatus_tag,Price_tag,OrderQty_tag,Side_tag,CumQty_tag,LeavesQty_tag,Symbol_tag,LastPx_tag;

     reg [2:0] MsgType_encode;
     localparam NEW_SINGLE_ORDER     = 3'b001;
     localparam ORDER_MODIFY_REQUEST = 3'b010;
     localparam ORDER_CANCEL_REQUEST = 3'b011;
     localparam EXECUTION            = 3'b100;
     localparam ORDER_CANCEL_REJECT  = 3'b101;
     
     wire [7:0]  ExecType_temp,OrdStatus_temp;
     wire [31:0] ClOrdID_temp,OrigClOrdID_temp;
     wire [47:0] Symbol_temp;
     wire [7:0] Side_temp;
     wire [63:0] Price_temp;
     wire [63:0] Quantity_temp_leave;
     wire [63:0] LastPx_temp;
     reg  [63:0] orig_Price_temp;
       
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    msg_complete_delay1   <= 1'b0;
    msg_complete_delay2   <= 1'b0;
    msg_complete_delay3   <= 1'b0;
    msg_complete_delay4   <= 1'b0;
    msg_complete_delay5   <= 1'b0;
    tag_valid_delay1      <= 1'b0;
    value_valid_delay1    <= 1'b0;
    checksum_valid_delay1 <= 1'b0;
    
    end
    else begin
    msg_complete_delay1   <= msg_complete;
    msg_complete_delay2   <= msg_complete_delay1;
    msg_complete_delay3   <= msg_complete_delay2;
    msg_complete_delay4   <= msg_complete_delay3;
    msg_complete_delay5   <= msg_complete_delay4;
    tag_valid_delay1      <= tag_valid;
    value_valid_delay1    <= value_valid;
    checksum_valid_delay1 <= checksum_valid;
    
    end 
    end
    
    assign tag_data = {tag_stack[4],tag_stack[3],tag_stack[2],tag_stack[1],tag_stack[0]};
    assign value_data = {value_stack[14],value_stack[13],value_stack[12],value_stack[11],value_stack[10],value_stack[9],value_stack[8],value_stack[7],value_stack[6],value_stack[5],value_stack[4],value_stack[3],value_stack[2],value_stack[1],value_stack[0]};
    assign checksum_data = {checksum_stack[2],checksum_stack[1],checksum_stack[0]};
    
    always@(posedge clk or posedge rst) begin
    if(rst) begin
    tag_data2 <= 0;
    value_data2 <=0;
    end
    else begin
    if(tag_cs == TAG_END) tag_data2 <= tag_data;
    if(value_cs == VALUE_END) value_data2 <= value_data;
    end
    end
    integer i;
    always@(posedge clk or posedge rst) begin :tag_data_assiging
       if(rst) begin
        for(i=0;i<5;i=i+1) begin
        tag_stack[i] <= 0;
        end
        end
       else begin
         if(tag_valid_delay1) begin
          for(i=1;i<5;i=i+1) begin
           tag_stack[i] <= tag_stack[i-1];
          end
         tag_stack[0] <= tag;
         end 
         else if(value_valid_delay1) begin
          for(i=0;i<5;i=i+1) begin
           tag_stack[i] <= 0;
          end
         end
      end
     end
     
     
      always@(posedge clk or posedge rst) begin :value_data_assiging
       if(rst) begin
        for(i=0;i<15;i=i+1) begin
        value_stack[i] <= 0;
        end
        end
       else begin
         if(value_valid_delay1) begin
          for(i=1;i<14;i=i+1) begin
           value_stack[i] <= value_stack[i-1];
          end
         value_stack[0] <= value;
         end 
         else if(tag_valid_delay1) begin
          for(i=0;i<14;i=i+1) begin
           value_stack[i] <= 0;
          end
         end
      end
     end
     
    
     
     always@(posedge clk or posedge rst) begin : TAG_FSM
     if(rst) 
     tag_cs <= TAG_IDLE;
     else
     tag_cs <= tag_ns;
     end 
     
     always@(*) begin
     tag_ns = tag_cs;
     case(tag_cs)
      TAG_IDLE : begin
        if(tag_valid_delay1) tag_ns = TAG_START;
      end
      TAG_START : begin
        if(~tag_valid_delay1) tag_ns = TAG_END;
      end 
      TAG_END : begin
       tag_ns = TAG_WAIT;
      end 
      TAG_WAIT : begin
       tag_ns = TAG_IDLE;
      end 
      endcase
     end 
    
    always@(posedge clk or posedge rst) begin : VALUE_FSM
     if(rst) 
     value_cs <= VALUE_IDLE;
     else
     value_cs <= value_ns;
     end 
     
     always@(*) begin
     value_ns = value_cs;
     case(value_cs)
      VALUE_IDLE : begin
        if(value_valid_delay1) value_ns = VALUE_START;
      end
      VALUE_START : begin
        if(~value_valid_delay1) value_ns = VALUE_END;
      end 
      VALUE_END : begin
       value_ns = VALUE_WAIT;
      end 
      VALUE_WAIT : begin
       value_ns = VALUE_IDLE;
      end 
      endcase
     end 

     assign MsgType_tag     = {{24{1'b0}},16'h3335};
     assign ClOrdID_tag     = {{24{1'b0}},16'h3131};
     assign OrigClOrdID_tag = {{24{1'b0}},16'h3431};
     assign OrderID_tag     = {{24{1'b0}},16'h3337};
     assign ExecType_tag    = {{16{1'b0}},24'h313530};
     assign OrdStatus_tag   = {{24{1'b0}},16'h3339};
     assign Price_tag       = {{24{1'b0}},16'h3434};
     assign OrderQty_tag    = {{24{1'b0}},16'h3338};
     assign Side_tag        = {{24{1'b0}},16'h3534};
     assign CumQty_tag      = {{24{1'b0}},16'h3134};
     assign LeavesQty_tag   = {{16{1'b0}},24'h313531};
     assign Symbol_tag      = {{24{1'b0}},16'h3535};
     assign LastPx_tag      = {{24{1'b0}},16'h3331};
     always@(posedge clk or posedge rst) begin
     if(rst) begin
     MsgType     <= 0;
     ClOrdID     <= 0;
     OrigClOrdID <= 0;
     OrderID     <= 0;
     ExecType    <= 0;
     OrdStatus   <= 0;
     Price       <= 0;
     OrderQty    <= 0;
     Side        <= 0;
     CumQty      <= 0;
     LeavesQty   <= 0;
     Symbol      <= 0;
     LastPx      <= 0;
     end
     else begin
     if(tag_cs == TAG_END) begin
      if( tag_data2 == MsgType_tag )          MsgType <= value_data2;
      else if( tag_data2 == Price_tag )       Price <= value_data2;
      else if( tag_data2 == ClOrdID_tag )     ClOrdID <= value_data2;
      else if( tag_data2 == OrigClOrdID_tag ) OrigClOrdID <= value_data2;
      else if( tag_data2 == OrderID_tag )     OrderID <= value_data2;
      else if( tag_data2 == ExecType_tag )    ExecType <= value_data2;
      else if( tag_data2 == OrdStatus_tag )   OrdStatus <= value_data2;
      else if( tag_data2 == OrderQty_tag )    OrderQty <= value_data2;
      else if( tag_data2 == Side_tag )        Side <= value_data2;
      else if( tag_data2 == CumQty_tag)       CumQty <= value_data2;
      else if( tag_data2 == LeavesQty_tag)    LeavesQty <= value_data2;
      else if( tag_data2 == Symbol_tag)       Symbol <= value_data2;
      else if( tag_data2 == LastPx_tag)       LastPx <= value_data2;
     end 
     else if(msg_complete_delay5) begin
      MsgType     <= 0;
      ClOrdID     <= 0;
      OrigClOrdID <= 0;
      OrderID     <= 0;
      ExecType    <= 0;
      OrdStatus   <= 0;
      Price       <= 0;
      OrderQty    <= 0;
      Side        <= 0;
      CumQty      <= 0;
      LeavesQty   <= 0;
      Symbol      <= 0;
      LastPx      <= 0;
     end
     end
     end
    reg [31:0]orig_clordID;
     always@(posedge clk or posedge rst) begin
     if(rst) begin
     orig_Price_temp <= 0;
     end
     else begin
     if((MsgType_encode == NEW_SINGLE_ORDER) | (MsgType_encode == ORDER_MODIFY_REQUEST))
     begin
     orig_Price_temp <= Price_temp;
     end
     end
     end
     
     always@(posedge clk or posedge rst) begin
     if(rst) begin
     orig_clordID <= 0;
     end
     else begin
     if((MsgType_encode == NEW_SINGLE_ORDER)| (MsgType_encode == ORDER_CANCEL_REQUEST) | (MsgType_encode == ORDER_MODIFY_REQUEST))
     begin
     orig_clordID <= OrigClOrdID_temp;
     end
     end
     end
     
     
     always@(posedge clk or posedge rst) begin 
       if(rst) begin
       MsgType_encode <= 0;
       end
       else begin
       if(msg_complete) begin
       case(MsgType[7:0])
        8'h44 : begin MsgType_encode <= NEW_SINGLE_ORDER; end      //// NEW SINGLE ORDER
        8'h46 : begin MsgType_encode <= ORDER_CANCEL_REQUEST; end  //// ORDER CANCEL/REPLACE REQUEST(ORDER MODIFY REQUEST)
        8'h47 : begin MsgType_encode <= ORDER_MODIFY_REQUEST; end  //// ORDER CANCEL REQUEST
        8'h38 : begin MsgType_encode <= EXECUTION; end             //// EXECUTION REPORT
        8'h39 : begin MsgType_encode <= ORDER_CANCEL_REJECT; end   //// ORDER CANCEL REJECT
        default : begin MsgType_encode <= 3'b000; end
       endcase
       end
       else if(msg_complete_delay4) begin MsgType_encode <= 3'b000;
       end
       end
       end
       
       
       assign ExecType_temp       = ExecType[7:0];
       assign OrdStatus_temp      = OrdStatus[7:0];
       assign ClOrdID_temp        = ClOrdID[31:0];
       assign OrigClOrdID_temp    = OrigClOrdID[31:0];
       assign Symbol_temp         = Symbol[47:0];
       assign Side_temp           = Side[7:0];
       assign Price_temp          = Price[63:0];
       assign Quantity_temp_leave = LeavesQty[63:0];
       assign LastPx_temp         = LastPx[63:0];      
       
   always@(*) begin
   msg_valid     = 0;
   msg_type      = 1;
   symbol_id     = 0;
   side          = 0;
   price         = 0;
   quantity      = 0;
   order_id      = 0;
   orig_price    = 0;
   orig_order_id = 0;
   if((msg_complete|msg_complete_delay1|msg_complete_delay2) && (MsgType_encode==EXECUTION)) begin
   msg_valid = 1;
     casex({ExecType_temp,OrdStatus_temp})
       16'h3030 : begin  //new
       msg_type      = 1;
       symbol_id     = Symbol_temp;
       side          = Side_temp;
       price         = LastPx_temp;
       orig_price    = orig_Price_temp;
       quantity      = Quantity_temp_leave;
       order_id      = ClOrdID_temp;
       orig_order_id = orig_clordID;
       end 
       16'h4631 : begin  // partial fill
       msg_type  = 0;
       symbol_id = Symbol_temp;
       side      = Side_temp;
       price     = LastPx_temp;
       orig_price = orig_Price_temp;
       quantity  = Quantity_temp_leave;
       order_id  = ClOrdID_temp;
       orig_order_id = orig_clordID;
       end
       16'h4632 : begin   // fully filled
       msg_type  = 0;
       symbol_id = Symbol_temp;
       side      = Side_temp;
       price     = LastPx_temp;
       orig_price = orig_Price_temp;
       quantity  = Quantity_temp_leave;
       order_id  = ClOrdID_temp;
       orig_order_id = orig_clordID;
       end
       16'h3434 : begin  // cancelled
       msg_type  = 0;
       symbol_id = Symbol_temp;
       side      = Side_temp;
       price     = LastPx_temp;
       orig_price = orig_Price_temp;
       quantity  = Quantity_temp_leave;
       order_id  = ClOrdID_temp;
       orig_order_id = orig_clordID;
       end 
       16'h35xx : begin
       msg_type  = 0;
       symbol_id = Symbol_temp;
       side      = Side_temp;
       price     = LastPx_temp;
       orig_price = orig_Price_temp;
       quantity  = Quantity_temp_leave;
       order_id  = ClOrdID_temp;
       orig_order_id = orig_clordID;
       end 
       
     endcase
    end 
  end   
endmodule
