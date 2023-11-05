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
localparam type_a = 3;
localparam type_b = 4;
localparam type_c = 5;
localparam type_d = 6;
localparam dobeter = 7;
localparam FINISH = 8;

//regs
reg [3:0] state, nextState;
reg [13:0] center; // Coordinate (row, column) = (center[13:7], center[6:0])
reg [2:0] counter; 
reg [9:0] r_Sum, g_Sum, b_Sum; // {add_integer(10bits)}

//wire constants
wire [6:0] x_add1,x_minus1,y_add1,y_minus1;
wire [13:0] center_delay;
assign center_delay = center - 14'd1;
assign x_add1 = center_delay[13:7] + 7'd1;
assign x_minus1 = center_delay[13:7] - 7'd1;
assign y_add1 = center_delay[6:0] + 7'd1 ;
assign y_minus1 = center_delay[6:0] - 7'd1;

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
		Bilinear:begin
			if ( center==14'd16383 ) begin 
				nextState = FINISH;
			end
			else if ( center[13:7]==7'd0 || center[13:7]==7'd127 || center[6:0]==7'd0 || center[6:0]==7'd127 ) begin 
				nextState = Bilinear;
			end
			else if ( center[7]==1'd1 && center[0]==1'd0 ) begin 
				nextState = type_b;
			end
			else if ( center[7]==1'd0 && center[0]==1'd0 ) begin 
				nextState = type_d;
			end
			else if ( center[7]==1'd1 && center[0]==1'd1 ) begin 
				nextState = type_a;
			end
			else if ( center[7]==1'd0 && center[0]==1'd1 ) begin 
				nextState = type_c;
			end
			else begin
				nextState = Bilinear;
			end
		end
		type_b: nextState = (counter == 3'd5)? Bilinear : type_b;
		type_d: nextState = (counter == 3'd3)? Bilinear : type_d;
		type_a: nextState = (counter == 3'd3)? Bilinear : type_a;
		type_c: nextState = (counter == 3'd5)? Bilinear : type_c;
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
				if (in_en) begin
					done <= 1'd0;
				end
				wr_g <= 1'd1;
				addr_g <= 14'd0;
				wdata_g <= data_in;
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

				if (center==14'd0) begin
					center <= 14'd2;
					wr_r <= 1'd1;
					addr_r <= 14'd1;
					wdata_r <= data_in;
				end
				else begin
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
			end
			Bilinear: begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;

				counter <= 3'd0;
				center = center + 14'd1;

				r_Sum <= 10'd0;
				g_Sum <= 10'd0;
				b_Sum <= 10'd0;
			end
			type_b: begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;
				addr_r <= 14'd0;
				addr_g <= 14'd0;
				addr_b <= 14'd0;
				wdata_r <= 8'd0;
				wdata_g <= 8'd0;
				wdata_b <= 8'd0;

				if ( counter==3'd0 ) begin
					r_Sum <= 1'd0;
					g_Sum <= 1'd0;

					addr_r <= {x_minus1, y_minus1};
					addr_g <= {x_minus1, center_delay[6:0]};
				end
				else if ( counter==3'd1 ) begin
					r_Sum <= rdata_r;
					g_Sum <= rdata_g;

					addr_r <= {x_add1, y_minus1};
					addr_g <= {x_add1, center_delay[6:0]};
				end
				else if ( counter==3'd2 ) begin
					r_Sum <= r_Sum + rdata_r;
					g_Sum <= g_Sum + rdata_g;

					addr_r <= {x_minus1, y_add1};
					addr_g <= {center_delay[13:7], y_minus1};
				end
				else if ( counter==3'd3 ) begin
					r_Sum <= r_Sum + rdata_r;
					g_Sum <= g_Sum + rdata_g;

					addr_r <= {x_add1, y_add1};
					addr_g <= {center_delay[13:7], y_add1};
				end
				else if ( counter==3'd4 ) begin
					wr_r <= 1'd1;
					addr_r <= center_delay;
					wdata_r <= (r_Sum + rdata_r)>>2;
					wr_g <= 1'd1;
					addr_g <= center_delay;
					wdata_g <= (g_Sum + rdata_g)>>2;
				end

				counter <= counter + 3'd1;
			end
			type_d: begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;
				addr_r <= 14'd0;
				addr_g <= 14'd0;
				addr_b <= 14'd0;
				wdata_r <= 8'd0;
				wdata_g <= 8'd0;
				wdata_b <= 8'd0;

				if ( counter==3'd0 ) begin
					r_Sum <= 1'd0;
					b_Sum <= 1'd0;

					addr_r <= {center_delay[13:7], y_minus1};
					addr_b <= {x_minus1, center_delay[6:0]};
				end
				else if ( counter==3'd1 ) begin
					r_Sum <= rdata_r;
					b_Sum <= rdata_b;

					addr_r <= {center_delay[13:7], y_add1};
					addr_b <= {x_add1, center_delay[6:0]};
				end
				else if ( counter==3'd2 ) begin
					wr_r <= 1'd1;
					addr_r <= center_delay;
					wdata_r <= (r_Sum + rdata_r)>>1;
					wr_b <= 1'd1;
					addr_b <= center_delay;
					wdata_b <= (b_Sum + rdata_b)>>1;
				end

				counter <= counter + 3'd1;
			end
			type_a: begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;
				addr_r <= 14'd0;
				addr_g <= 14'd0;
				addr_b <= 14'd0;
				wdata_r <= 8'd0;
				wdata_g <= 8'd0;
				wdata_b <= 8'd0;

				if ( counter==3'd0 ) begin
					r_Sum <= 1'd0;
					b_Sum <= 1'd0;

					addr_r <= {x_minus1, center_delay[6:0]};
					addr_b <= {center_delay[13:7], y_minus1};
				end
				else if ( counter==3'd1 ) begin
					r_Sum <= rdata_r;
					b_Sum <= rdata_b;

					addr_r <= {x_add1, center_delay[6:0]};
					addr_b <= {center_delay[13:7], y_add1};
				end
				else if ( counter==3'd2 ) begin
					wr_r <= 1'd1;
					addr_r <= center_delay;
					wdata_r <= (r_Sum + rdata_r)>>1;
					wr_b <= 1'd1;
					addr_b <= center_delay;
					wdata_b <= (b_Sum + rdata_b)>>1;
				end

				counter <= counter + 3'd1;
			end
			type_c: begin
				wr_r <= 1'd0;
				wr_g <= 1'd0;
				wr_b <= 1'd0;
				addr_r <= 14'd0;
				addr_g <= 14'd0;
				addr_b <= 14'd0;
				wdata_r <= 8'd0;
				wdata_g <= 8'd0;
				wdata_b <= 8'd0;

				if ( counter==3'd0 ) begin
					g_Sum <= 1'd0;
					b_Sum <= 1'd0;

					addr_g <= {x_minus1, center_delay[6:0]};
					addr_b <= {x_minus1, y_minus1};
				end
				else if ( counter==3'd1 ) begin
					g_Sum <= rdata_g;
					b_Sum <= rdata_b;

					addr_g <= {x_add1, center_delay[6:0]};
					addr_b <= {x_add1, y_minus1};
				end
				else if ( counter==3'd2 ) begin
					g_Sum <= g_Sum + rdata_g;
					b_Sum <= b_Sum + rdata_b;

					addr_g <= {center_delay[13:7], y_minus1};
					addr_b <= {x_minus1, y_add1};
				end
				else if ( counter==3'd3 ) begin
					g_Sum <= g_Sum + rdata_g;
					b_Sum <= b_Sum + rdata_b;

					addr_g <= {center_delay[13:7], y_add1};
					addr_b <= {x_add1, y_add1};
				end
				else if ( counter==3'd4 ) begin
					wr_g <= 1'd1;
					addr_g <= center_delay;
					wdata_g <= (g_Sum + rdata_g)>>2;
					wr_b <= 1'd1;
					addr_b <= center_delay;
					wdata_b <= (b_Sum + rdata_b)>>2;
				end

				counter <= counter + 3'd1;
			end
			FINISH: begin
				done <= 1'd1;
			end
		endcase
	end
end

endmodule
