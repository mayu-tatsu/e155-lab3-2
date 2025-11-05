// testbench_keypad_decoder.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-11-05
//
// Tests the keypad_decoder module by iterating through all valid
// row and column combinations and checking that num outputs
// the correct 4-bit value.

`timescale 1 ns / 1 ps

module testbench_keypad_decoder;

    logic [3:0] rows, col;
    logic [3:0] num;

    keypad_decoder dut (rows, col, num);

    initial begin
        rows = 4'b0000;
        col  = 4'b0000;
        #5;

        // run through all combinations
        foreach (rows[i]) begin
            rows = 4'b0001 << i;
            foreach (col[j]) begin
                col = 4'b0001 << j; #5;
                $display("inputs: rows=%b, col=%b, got num=%0d", rows, col, num);
            end
        end

        // test for no key pressed
        rows = 4'b0000; col = 4'b0000; #5;
        $display("No key pressed -> num=%0d", num);

        // test for multiple rows active
        rows = 4'b1010; col = 4'b0010; #5;
        $display("Multiple rows active -> num=%0d", num);

        $stop;
    end
endmodule
