// debouncer_timer.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Timer module that generates a timer_done signal after a specified delay (10 ms).
// The timer is reset whenever timer_reset is high.

module debouncer_timer (
    input  logic clk, timer_reset, 
    output logic timer_done
);

    // Hardcoded for 100Hz clk: 1 cycle = 10ms
    // timer_done (active high) goes high 10ms after timer_reset becomes low

    logic  timer_done_register;
    assign timer_done = timer_done_register;

    always_ff @(posedge clk) begin
        if (timer_reset) begin
            timer_done_register <= 0;
        end else begin
            timer_done_register <= 1;
        end
    end

    // timer_done will stay high until timer_reset is asserted again
endmodule