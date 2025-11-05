// testbench_keypad_scan.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-11-05
//
// Tests the keypad_scan FSM by simulating realistic key presses and releases.
// Checks for correct row scanning and detection of new key presses.

`timescale 1ns/1ps

module testbench_keypad_scan();

    logic clk, reset;
    logic [3:0] col;
    logic [3:0] rows;
    logic num_new;

    keypad_scan dut (clk, reset, col, rows, num_new);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 0; col = 4'b0000; #20;
        reset = 1;
    end

    initial begin
        @(posedge reset);
        repeat (10) @(posedge clk);

        // Row 1, Col 2
        wait (rows == 4'b0001); #2;  // FSM scanning row 0
        col = 4'b0010;  	// simulate pressing key in column 1 of row 0
        wait (num_new);		// Wait for num_new pulse
        $display("Pass: num_new asserted for keypress");
        @(posedge clk);
        col = 4'b0000; 		// release key

        // Row 3, Col 4
        wait (rows == 4'b1000); #2;	 // FSM scanning row 3
        col = 4'b1000;  // simulate key in row 3, col 3
        wait (num_new);
        $display("Pass: num_new asserted for keypress");
        @(posedge clk);
        col = 4'b0000; // release key

        // no pressed key
        repeat (50) @(posedge clk);
        if (num_new !== 1'b0)
            $display("Fail: num_new high");
        else
            $display("Pass: no key pressed, num_new=0");

        // debouncing
        wait (rows == 4'b0100); // row 2
        col = 4'b0100;
        #10; // shorter than debounce time (should not register)
        col = 4'b0000;
        repeat (20) @(posedge clk);
        if (num_new)
            $display("Fail: debounce bad, num_new triggered");
        else
            $display("Pass: debounce good");
			
		$display("Completed testbench\n");
        $stop;
    end
endmodule


/*

    task wait_for_row(input logic [3:0] target_row);
        while (rows !== target_row) @(posedge clk);
    endtask

    // test fxn for 1 key input
    task press_key(input logic [3:0] row_val, input logic [3:0] col_val, input int key_num);
        begin
            wait_for_row(row_val); #2;
            col = col_val;
            $display("Simulating keypress, row=%b col=%b", row_val, col_val);

            // Wait for num_new
            wait (num_new === 1'b1);
            $display("Pass: num_new detected", key_num);

            @(posedge clk);
            col = 4'b0000;
            repeat (10) @(posedge clk);
        end
    endtask

    initial begin
        @(posedge reset);
        repeat (10) @(posedge clk);

		// matrix
        logic [3:0] row_vals [3:0] = '{4'b0001, 4'b0010, 4'b0100, 4'b1000};
        logic [3:0] col_vals [3:0] = '{4'b0001, 4'b0010, 4'b0100, 4'b1000};

        int test_num = 1;

        // test all 16 keys via fxn
        foreach (row_vals[i]) begin
            foreach (col_vals[j]) begin
                press_key(row_vals[i], col_vals[j], test_num);
                test_num++;
            end
        end

        // idle check, no key should be pressed
        col = 4'b0000;
        repeat (20) @(posedge clk);
        if (num_new)
            $display("Fail: num_new asserted unexpectedly when idle");
        else
            $display("Pass: FSM stable, no false keypress detected");

        $display("Completed testbench\n");
        $stop;
    end

*/