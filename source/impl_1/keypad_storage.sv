// keypad_storage.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Stores the last key pressed on the keypad into sw_input
// whenever a new key press is detected (key_onebit_db goes high)
// Utilizes D flip-flops to store both values on every clock cycle.

module keypad_storage(
    input  logic       clk, reset, newNum,
    input  logic [3:0] num, 
    output logic [3:0] num_left, num_right
);
    always_ff @(posedge clk, negedge reset) begin
        if (~reset) begin
			num_left  <= 4'b0000;
            num_right <= 4'b0000;
        end else if (newNum) begin
			num_left  <= num_right;
            num_right <= num;
        end
    end
endmodule
