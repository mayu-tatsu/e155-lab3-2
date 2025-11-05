// testbench_synchronizer.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-10-29
//
// Tests that sync_col correctly follows async_col with a one-cycle delay,
// and that reset clears both temp_col and sync_col. Outputs total number of
// tests and errors to the terminal.

`timescale 1 ns / 1 ps

module testbench_synchronizer();

	logic       clk, reset;
	logic [3:0] async_col;
	logic [3:0] sync_col;

	logic [3:0] expected_temp_col, expected_sync_col;
	logic [31:0] test_idx, errors;

	synchronizer dut(clk, reset, async_col, sync_col);

	always begin
		clk = 1; #5; clk = 0; #5;
	end

	initial begin
		test_idx = 0; errors = 0;
		reset = 0; async_col = 4'b0000;
		#12; reset = 1;
	end

	initial begin
		#20;

		// reset
		expected_sync_col = 4'b0000; #5;
		if (sync_col !== expected_sync_col) begin
			$display("Fail: sync_col = %b, expected %b after reset", sync_col, expected_sync_col);
			errors = errors + 1;
		end
		test_idx++;

		async_col = 4'b1010; #10;
		expected_sync_col = 4'b0000;	// stays 0 now
		if (sync_col !== expected_sync_col) begin
			$display("Fail: Got %b, expected %b", sync_col, expected_sync_col);
			errors = errors + 1;
		end
		#10; expected_sync_col = 4'b1010;	// updates after 1 clock cycle
		if (sync_col !== expected_sync_col) begin
			$display("Fail: sync_col = %b, expected %b",sync_col, expected_sync_col);
			errors = errors + 1;
		end
		test_idx++;

		async_col = 4'b1100; #10;
		expected_sync_col = 4'b1010;
		if (sync_col !== expected_sync_col) begin
			$display("Fail: got %b, expected %b", sync_col, expected_sync_col);
			errors = errors + 1;
		end #10;
		expected_sync_col = 4'b1100;
		if (sync_col !== expected_sync_col) begin
			$display("Fail: Got %b, expected %b", sync_col, expected_sync_col);
			errors = errors + 1;
		end
		test_idx++;

		async_col = 4'b0111; #10;
		expected_sync_col = 4'b1100;
		if (sync_col !== expected_sync_col) begin
			$display("Fail: Got %b, expected %b",sync_col, expected_sync_col);
			errors = errors + 1;
		end #10;
		expected_sync_col = 4'b0111;
		if (sync_col !== expected_sync_col) begin
			$display("Fail: Got %b, expected %b", sync_col, expected_sync_col);
			errors = errors + 1;
		end
		test_idx++;

		// reset
		reset = 0; #10; reset = 1; #10;
		expected_sync_col = 4'b0000;
		if (sync_col !== expected_sync_col) begin
			$display("Fail: sync_col not cleared on reset. Got %b", sync_col);
			errors = errors + 1;
		end
		test_idx++;

		$display("Completed %d tests with %d errors", test_idx, errors);
		$stop;
	end

endmodule
