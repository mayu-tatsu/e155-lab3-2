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

    // instantiate DUT with shorter HOLD_TIME to speed up simulation
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


        for (int r = 0; r < 4; r++) begin
            wait (rows == (4'b0001 << r)); #2;
            for (int c = 0; c < 4; c++) begin
                col = (4'b0001 << c);    // simulate keypress
                wait (num_new);          // wait for detection pulse
                $display("Pass: row %0d, col %0d detected.", r+1, c+1);
                @(posedge clk);
                col = 4'b0000;           		// release key
                repeat (400) @(posedge clk); 	// let FSM return to scan mode
            end
        end

        repeat (50) @(posedge clk);
        if (num_new !== 1'b0)
            $display("Fail: num_new high with no key pressed");
        else
            $display("Pass: no key pressed, num_new=0");


        wait (rows == 4'b0100); #2; 	// row 3 scanning
        col = 4'b0100; #10; 			// shorter than debounce
        col = 4'b0000;
        repeat (50) @(posedge clk);
        if (num_new)
            $display("Fail: debounce triggered");
        else
            $display("Pass: debounce working");

        $display("Completed testbench.");
        $stop;
    end

endmodule
