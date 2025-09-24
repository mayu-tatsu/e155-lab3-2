// keypad_storage.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Stores the last key pressed on the keypad into sw_input
// whenever a new key press is detected (key_onebit_db goes high)
// Utilizes D flip-flops to store both values on every clock cycle.

module keypad_storage(
    input  logic       clk, reset, key_onebit_db,
    input  logic [4:0] keypad_val, 
    output logic [3:0] sw_input, sw_prev_input
);

    always_ff @(posedge clk) begin
        if (~reset) begin
            sw_input      <= 4'b0000;
            sw_prev_input <= 4'b0000;
        end else if (key_onebit_db) begin   
            sw_prev_input <= sw_input;
            sw_input      <= keypad_val[3:0];
        end
    end

    // no need to check keypad_val != 11111 since key_onebit_db only
    // goes high when a valid key is pressed

endmodule