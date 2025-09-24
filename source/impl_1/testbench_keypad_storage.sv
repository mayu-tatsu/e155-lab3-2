// testbench_keypad_storage.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-23

`timescale 1 ns / 1 ps

module testbench_keypad_storage();

	logic       clk, reset;
	logic       key_onebit_db;
	logic [4:0] keypad_val;
	logic [3:0] sw_input, sw_prev_input;
	int errors = 0;

	keypad_storage dut(clk, reset, key_onebit_db, keypad_val, sw_input, sw_prev_input);

	// Clock generation
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	// Reset
	initial begin
		reset = 1; key_onebit_db = 0; keypad_val = 5'b11111;
		#22 reset = 0;
	end

	// Task to check expected values
	task check_storage(input [3:0] exp_input, exp_prev_input, string msg);
		#10;
		if (sw_input !== exp_input || sw_prev_input !== exp_prev_input) begin
			$display("Fail: %s. Outputs: sw_input=%h sw_prev_input=%h, expected sw_input=%h sw_prev_input=%h at time %0t", msg, sw_input, sw_prev_input, exp_input, exp_prev_input, $time);
			errors = errors + 1;
		end
	endtask

	// Stimulus
	initial begin
		#30;
		check_storage(4'h0, 4'h0, "After reset; no key press");

		keypad_val = 5'h6; key_onebit_db = 1;
		#10 key_onebit_db = 0;
		check_storage(4'h6, 4'h0, "First key press. Input: 6, Prev: 0");

		keypad_val = 5'hc; key_onebit_db = 1;
		#10 key_onebit_db = 0;
		check_storage(4'hc, 4'h6, "Second key press. Input: C, Prev: 6");

		keypad_val = 5'h2; key_onebit_db = 1;
		#10 key_onebit_db = 0;
		check_storage(4'h2, 4'hc, "Third key press. Input: 2, Prev: C");

		keypad_val = 5'b11111; key_onebit_db = 0;
		#10;
		check_storage(4'h2, 4'hc, "No key press. Input and Prev should remain the same");

		keypad_val = 5'hf; key_onebit_db = 1;
		#10 key_onebit_db = 0;
		check_storage(4'hf, 4'h2, "Fourth key press. Input: F, Prev: 2");

		$display("Testbench completed with %0d errors.", errors);
		$stop;
	end

	// Timeout
	initial begin
		#1000;
		$error("Simulation did not complete in time.");
		$stop;
	end

endmodule