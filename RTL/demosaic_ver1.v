module demosaic(clk, reset, in_en, data_in, wr_r, addr_r, wdata_r, rdata_r, wr_g, addr_g, wdata_g, rdata_g, wr_b, addr_b, wdata_b, rdata_b, done);
input clk;
input reset;
input in_en;
input [7:0] data_in;
output wr_r;
output [13:0] addr_r;
output [7:0] wdata_r;
input [7:0] rdata_r;
output wr_g;
output [13:0] addr_g;
output [7:0] wdata_g;
input [7:0] rdata_g;
output wr_b;
output [13:0] addr_b;
output [7:0] wdata_b;
input [7:0] rdata_b;
output done;

//state param
localparam INIT = 0;
localparam READ_DATA = 1;
localparam Bilinear = 2;
localparam type_0 = 3;
localparam type_1 = 4;
localparam type_2 = 5;
localparam type_3 = 6;
localparam type_5 = 7;
localparam type_6 = 8;
localparam type_7 = 9;
localparam type_8 = 10;
localparam type_a = 11;
localparam type_b = 12;
localparam type_c = 13;
localparam type_d = 14;
localparam FINISH = 15;

//regs
reg [3:0] state, nextState;
reg [13:0] center; // Coordinate (row, column) = (center[13:7], center[6:0])
reg [2:0] counter; 
reg signed [9:0] r_Sum, g_Sum, b_Sum; // {add_integer(10bits)}

//constant param
localparam LENGTH = 7'd127;
localparam ZERO = 7'd0; 

//wire constants
wire [6:0] cx_add1,cx_minus1,cy_add1,cy_minus1;
assign cy_add1 = center[13:7] + 7'd1;
assign cy_minus1 = center[13:7] - 7'd1;
assign cx_add1 = center[6:0] + 7'd1 ;
assign cx_minus1 = center[6:0] - 7'd1;

//state ctrl
always @(posedge clk or posedge reset) begin
	if(reset) state <= INIT;
	else state <= nextState;
end

//next state logic
always @(*) begin
	case (state)
		INIT: nextState = (in_en)? READ_DATA : INIT;
		READ_DATA: nextState = (center == 14'd16383)? Bilinear : READ_DATA;
		Bilinear:
			if( center==14'd0 ) begin
				nextState = type_0;
			end
			else if ( center==14'd127 ) begin 
				nextState = type_2;
			end
			else if ( center==14'd16256 ) begin 
				nextState = type_6;
			end	
			else if ( center==14'd16383 ) begin 
				nextState = type_8;
			end	
			else if ( center[13:7]==7'd0 ) begin 
				nextState = type_1;
			end
			else if ( center[6:0]==7'd0 ) begin 
				nextState = type_3;
			end
			else if ( center[6:0]==7'd127 ) begin 
				nextState = type_5;
			end
			else if ( center[13:7]==7'd127 ) begin 
				nextState = type_7;
			end
			else if ( center[7]==1'd0 && center[0]==1'd0 ) begin 
				nextState = type_d;
			end
			else if ( center[7]==1'd1 && center[0]==1'd1 ) begin 
				nextState = type_a;
			end
			else if ( center[7]==1'd1 && center[0]==1'd0 ) begin 
				nextState = type_b;
			end
			else if ( center[7]==1'd0 && center[0]==1'd1 ) begin 
				nextState = type_c;
			end
			else begin
				nextState = Bilinear;
			end
		type_0: nextState = (counter == 3'd1)? Bilinear : type_0;
		type_1: nextState = (counter == 3'd3)? Bilinear : type_1;
		type_2: nextState = (counter == 3'd2)? Bilinear : type_2;
		type_3: nextState = (counter == 3'd3)? Bilinear : type_3;
		type_5: nextState = (counter == 3'd3)? Bilinear : type_5;
		type_6: nextState = (counter == 3'd2)? Bilinear : type_6;
		type_7: nextState = (counter == 3'd3)? Bilinear : type_7;
		type_8: nextState = (counter == 3'd1)? Bilinear : type_8;
		type_a: nextState = (counter == 3'd3)? Bilinear : type_a;
		type_b: nextState = (counter == 3'd5)? Bilinear : type_b;
		type_c: nextState = (counter == 3'd5)? Bilinear : type_c;
		type_d: nextState = (counter == 3'd3)? Bilinear : type_d;
		FINISH: nextState = FINISH;
		default: nextState = INIT;
	endcase
end

//main sequential circuit
always @(posedge clk or posedge reset) begin
	if (reset) begin
		done <= 1'd0;
		wr_r <= 1'd0;
		wr_g <= 1'd0;
		wr_b <= 1'd0;
		addr_r <= 14'd0;
		addr_g <= 14'd0;
		addr_b <= 14'd0;
		wdata_r <= 8'd0;
		wdata_g <= 8'd0;
		wdata_b <= 8'd0;

		center <= {7'd0 , 7'd0};
		counter <= 3'd0;
		r_Sum <= 9'd0; 
		g_Sum <= 9'd0; 
		b_Sum <= 9'd0; 
	end
	else begin
		case (state)
			INIT:begin
				if (ready) begin
					done <= 1'd0;
				end
			end
			READ_DATA:begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;
				addr_r <= 14'd0;
				addr_g <= 14'd0;
				addr_b <= 14'd0;
				wdata_r <= 8'd0;
				wdata_g <= 8'd0;
				wdata_b <= 8'd0;

				if ( (center[7]==1'd0 && center[0]==1'd0) || (center[7]==1'd1 && center[0]==1'd1) ) begin
					wr_g <= 1'd1;
					addr_g <= center;
					wdata_g <= data_in;
				end
				else if ( center[7]==1'd1 ) begin
					wr_b <= 1'd1;
					addr_b <= center;
					wdata_b <= data_in;
				end
				else begin
					wr_r <= 1'd1;
					addr_r <= center;
					wdata_r <= data_in;
				end

				center <= center + 14'd1;
			end
			Bilinear: begin

			end
			type_0: begin

			end
			type_1: begin

			end
			type_2: begin

			end
			type_3: begin

			end
			type_5: begin

			end
			type_6: begin

			end
			type_7: begin

			end
			type_8: begin

			end
			type_a: begin

			end
			type_b: begin

			end
			type_c: begin

			end
			type_d: begin

			end
			FINISH: begin

			end
		endcase
	end
end

endmodule
