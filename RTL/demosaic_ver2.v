module demosaic(clk, reset, in_en, data_in, wr_r, addr_r, wdata_r, rdata_r, wr_g, addr_g, wdata_g, rdata_g, wr_b, addr_b, wdata_b, rdata_b, done);
input clk;
input reset;
input in_en;
input [7:0] data_in;
output reg wr_r;
output reg [13:0] addr_r;
output reg [7:0] wdata_r;
input [7:0] rdata_r;
output reg wr_g;
output reg [13:0] addr_g;
output reg [7:0] wdata_g;
input [7:0] rdata_g;
output reg wr_b;
output reg [13:0] addr_b;
output reg [7:0] wdata_b;
input [7:0] rdata_b;
output reg done;

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
		READ_DATA: nextState = (center == 14'd16383)? FINISH : READ_DATA;
		FINISH: nextState = INIT;
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
				if (in_en) begin
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
			FINISH: begin
				done <= 1'd1;
			end
		endcase
	end
end

endmodule
