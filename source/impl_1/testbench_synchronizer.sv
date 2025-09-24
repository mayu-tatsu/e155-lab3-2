// testbench_synchronizer.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-23

// Checks if output of 

`timescale 1 ns / 1 ps

module testbench_synchronizer();

	logic       clk, reset;
	logic [3:0] async_col, sync_col;
	logic [3:0] async_history [0:1];
	int errors = 0;

	synchronizer dut(clk, reset, async_col, sync_col);

	// generate a 100 Hz clk (10ns period)
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	// reset and initial values
	initial begin
		reset = 1;
		async_col = 4'b0000;
		async_history[0] = 4'b0000;
		async_history[1] = 4'b0000;
		#22 reset = 0;
	end

	// Task to check synchronizer output
	task check_sync(input [3:0] expected, string msg);
		#10;
		if (sync_col !== expected) begin
			$display("Fail: %s. Output: sync_col=%b, expected=%b at time %0t", msg, sync_col, expected, $time);
			errors = errors + 1;
		end
	endtask

	// Stimulus
	initial begin
		#30;
		check_sync(4'b0000, "After reset, sync_col should be 0");

		async_col = 4'b1010;
		async_history[0] = 4'b1010;
		async_history[1] = 4'b0000;
		#10; // 1 cycle
		check_sync(4'b0000, "First cycle after async_col=1010");
		#10; // wait 2
		check_sync(4'b1010, "Second cycle after async_col=1010");

		async_col = 4'b1100;
		async_history[1] = async_history[0];
		async_history[0] = 4'b1100;
		#10;
		check_sync(4'b1010, "First cycle after async_col=1100");
		#10;
		check_sync(4'b1100, "Second cycle after async_col=1100");

		async_col = 4'b0111;
		async_history[1] = async_history[0];
		async_history[0] = 4'b0111;
		#10;
		check_sync(4'b1100, "First cycle after async_col=0111");
		#10;
		check_sync(4'b0111, "Second cycle after async_col=0111");

		// re-test reset
		reset = 1;
		#10;
		check_sync(4'b0000, "After second reset");
		reset = 0;

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