// lab3_mt.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-11-05

// Top-level module that inverts the main input and output signals
// row and col to fit with the internal pullup resistor configuration
// which leads to an active-low setup. Instantiates all modules for
// this lab.

module lab3_mt (
  input  logic       reset,
  input  logic [3:0] async_col,
  output logic [3:0] row,
  output logic [6:0] seg,
  output logic       seg_left_en, seg_right_en
);

	// active low setup
    logic [3:0] uninverted_async_col, uninverted_row;
	assign uninverted_async_col = ~async_col;
	assign row = ~uninverted_row;
	
	// timing
	logic clk_100hz, clk_10khz;
	logic [3:0] sync_col;
	
	clk_gen		 clock(reset, clk_100hz, clk_10khz);
	synchronizer sync(clk_10khz, reset, uninverted_async_col, sync_col);
	
	// keypad
	logic num_new;
	logic [3:0] num, num_left, num_right;
	
	keypad_scan	   scan(clk_10khz, reset, sync_col, num_new, uninverted_row);
	keypad_decoder decoder(uninverted_row, sync_col, num);
	keypad_storage storage(clk_10khz, reset, num_new, num, num_left, num_right);
	
	// display
	logic [3:0] val;
	
	sev_seg_sel selector(clk_100hz, reset, num_left, num_right, val, seg_left_en, seg_right_en);
    sev_seg     display(val, seg);

endmodule
