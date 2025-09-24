// lab3_mt.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-14

// Top-level module instantiating all necessary modules to create desired
// outputs from keypad inputs.

module lab3_mt(
	input  logic       reset,
	input  logic [3:0] async_col,
	output logic [3:0] row,
	output logic       seg1en, seg2en,
	output logic [6:0] seg
);

	logic       clk, key_onebit, timer_reset, timer_done, key_onebit_db;
	logic [3:0] sw_input, sw_prev_input, sw, sync_col;
	logic [4:0] keypad_val;

	clk_gen         clk_generation(reset, clk);
	synchronizer    sync(clk, reset, async_col, sync_col);

	keypad	        keypad_input(clk, reset, sync_col, row, keypad_val, key_onebit);

	debouncer_timer timer(clk, timer_reset, timer_done);
	debouncer       debounce(clk, reset, key_onebit, timer_done, timer_reset, key_onebit_db);

	keypad_storage  storage(clk, reset, key_onebit_db, keypad_val, sw_input, sw_prev_input);

	sev_seg_sel     selector(clk, reset, sw_input, sw_prev_input, seg1en, seg2en, sw);
	sev_seg         dual_segs(sw, seg);
endmodule