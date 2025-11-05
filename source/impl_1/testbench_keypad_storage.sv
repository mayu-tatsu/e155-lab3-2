// testbench_keypad_storage.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-10-29
//
// Tests that sw_input and sw_prev_input correctly store the current and previous
// keypad values whenever newKey goes high, and reset clears both outputs. 
// Outputs total number of tests and errors to the terminal.

`timescale 1 ns / 1 ps

module testbench_keypad_storage();

	logic       clk, reset, newKey;
	logic [3:0] keypad_val;
	logic [3:0] sw_input, sw_prev_input;
	logic [3:0] sw_input_expected, sw_prev_input_expected;

	logic [31:0] test_idx, errors;

	keypad_storage dut(clk, reset, newKey, keypad_val, sw_prev_input, sw_input);

	always begin
		clk = 1; #5; clk = 0; #5;
	end

	initial begin
		test_idx = 0; errors = 0;
		reset = 0; newKey = 0; keypad_val = 4'b0000;
		#12; reset = 1;
	end

	initial begin
		#30;
		
sw_input_expected = 4'b0000;
		sw_prev_input_expected = 4'b0000; #5;
		if (sw_input !== sw_input_expected) begin
			$display("Fail: sw_input = %b, expected %b", sw_input, sw_input_expected);
			errors = errors + 1;
		end
		if (sw_prev_input !== sw_prev_input_expected) begin
			$display("Fail: sw_prev_input = %b, expected %b", sw_prev_input, sw_prev_input_expected);
			errors = errors + 1;
		end
		test_idx++;

		keypad_val = 4'h3; newKey = 1; #10; newKey = 0; #10;
		sw_prev_input_expected = 4'b0000; sw_input_expected = 4'h3;
		if (sw_input !== sw_input_expected || sw_prev_input !== sw_prev_input_expected) begin
			$display("Fail: sw_input=%b sw_prev_input=%b, expected %b %b", sw_input, sw_prev_input, sw_input_expected, sw_prev_input_expected);
			errors = errors + 1;
		end
		test_idx++;

        keypad_val = 4'hA; newKey = 1; #10; newKey = 0; #10;
		sw_prev_input_expected = 4'h3; sw_input_expected = 4'hA;
		if (sw_input !== sw_input_expected || sw_prev_input !== sw_prev_input_expected) begin
			$display("Fail: sw_input=%b sw_prev_input=%b, expected %b %b", sw_input, sw_prev_input, sw_input_expected, sw_prev_input_expected);
			errors = errors + 1;
		end
		test_idx++;

		// no newkey pulse, no change
        keypad_val = 4'h5; newKey = 0; #20;
        if (sw_input !== sw_input_expected || sw_prev_input !== sw_prev_input_expected) begin
			$display("Fail: got %b %b when it wasn't supposed to change", sw_input, sw_prev_input);
			errors = errors + 1;
		end
		test_idx++;

        keypad_val = 4'h5; newKey = 1; #10; newKey = 0; #10;
		sw_prev_input_expected = 4'hA; sw_input_expected = 4'h5;
		if (sw_input !== sw_input_expected || sw_prev_input !== sw_prev_input_expected) begin
			$display("Fail: sw_input=%b sw_prev_input=%b, expected %b %b", sw_input, sw_prev_input, sw_input_expected, sw_prev_input_expected);
			errors = errors + 1;
		end
		test_idx++;

		// reset
		reset = 0; #15; reset = 1; #10;
		sw_input_expected = 4'b0000; sw_prev_input_expected = 4'b0000;
		if (sw_input !== sw_input_expected || sw_prev_input !== sw_prev_input_expected) begin
			$display("Fail: reset did not clear outputs. Got %b %b", sw_input, sw_prev_input);
			errors = errors + 1;
		end
		test_idx++;

		$display("Completed %d tests with %d errors", test_idx, errors);
		$stop;
	end

endmodule
