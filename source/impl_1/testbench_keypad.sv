// testbench_keypad.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// Troy Kaufman
// 2025-09-23

// Testbench for keypad.sv module.
// Simulates key presses and releases on a 4x4 matrix keypad.

`timescale 1 ns/1 ns

module testbench_keypad();

	logic       clk;
	logic       reset;
	tri   [3:0] row, col;
	logic [4:0] keypad_val;
	logic       key_onebit;

	logic [3:0] [3:0] keys; // matrix of key presses: keys[row][col]

	// Device Under Test
	keypad dut(clk, reset, col, row, keypad_val, key_onebit);

	// Pullups for rowsâ€” defaults to high if not pressed
	pullup(row[0]);
	pullup(row[1]);
	pullup(row[2]);
	pullup(row[3]);

	// Keypad model using tranif1 & loop
	genvar r, c;
	generate
		for (r = 0; r < 4; r++) begin : row_loop
			for (c = 0; c < 4; c++) begin : col_loop
				tranif1 key_switch(row[r], col[c], keys[r][c]);
			end
		end
	endgenerate

	// Generate clock
	always begin
		clk = 0; #5;
		clk = 1; #5;
	end

	// Task to check expected keypad_val and key_onebit
	task check_key(input [4:0] exp_val, input exp_onebit, string msg);
      #100;
		assert (keypad_val == exp_val && key_onebit == exp_onebit) 
            $display("PASSED!: %s -- got keypad_val=%b key_onebit=%b expected keypad_val=%b key_onebit=%b at time %0t.", msg, keypad_val, key_onebit, exp_val, exp_onebit, $time);
        else 
        $error("FAILED!: %s -- got keypad_val=%b key_onebit=%b expected keypad_val=%b key_onebit=%b at time %0t.", msg, keypad_val, key_onebit, exp_val, exp_onebit, $time); #50;
    endtask

	// Apply stimuli and check outputs
	initial begin
		reset = 1;
		keys = '{default:0};
		#22 reset = 0;

		// No key pressed
		check_key(5'b11111, 1'b0, "No key pressed");

		// Press key at row=1, col=2 (should be key 6)
		#50 keys[1][2] = 1;
		check_key(5'h6, 1'b1, "First key press (row=1,col=2)");

		// Release button
		#50 keys[1][2] = 0;
		check_key(5'b11111, 1'b0, "Key released");

		// Press another key at row=2, col=3 (should be key C)
		#50 keys[2][3] = 1;
		check_key(5'hc, 1'b1, "Second key press (row=2,col=3)");

		// Release button
		#50 keys[2][3] = 0;
		check_key(5'b11111, 1'b0, "Key released");

		// Press two keys at once (row=0,col=0 and row=3,col=3)
		#50 keys[0][0] = 1; keys[3][3] = 1;
		check_key(5'h1, 1'b1, "Multiple keys pressed (should register first in priority)");

		// Release all
		#50 keys = '{default:0};
		check_key(5'b11111, 1'b0, "All keys released");

		#100 $display("Completed keypad testbench.");
		$stop;
	end

	// Timeout
	initial begin
		#5000;
		$error("Simulation did not complete in time.");
		$stop;
	end
endmodule