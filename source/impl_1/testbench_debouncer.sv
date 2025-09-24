// debouncer.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-22

// Debouncer module that uses an FSM to filter out noise from a button press.

// The module takes in a single bit input_signal (from a button) and timer_done
// (from debouncer_timer, 10 ms). output_signal is a delayed version of input_signal,
// but without the noise. timer_reset output is used to reset the timer whenever
// the input signal changes state.

module debouncer(
    input  logic clk, reset,
    input  logic input_signal, timer_done,
    output logic timer_reset,
    output logic output_signal
);

    typedef enum logic [2:0] {
        S0_WAIT_ZERO, S1_CHECK_ONE, S2_WAIT_ONE, S3_CHECK_ZERO
    } statetype;
    statetype state, nextstate;

    // state register
    always_ff @(posedge clk)
        if   (reset) state <= S0_WAIT_ZERO;
        else         state <= nextstate;

    // next state logic
    always_comb begin
        case (state)
            S0_WAIT_ZERO: begin
                if (input_signal == 1'b1) nextstate = S1_CHECK_ONE;
                else                      nextstate = S0_WAIT_ZERO;
            end
            S1_CHECK_ONE: begin
                if      (input_signal == 1'b1 && timer_done == 1'b1) nextstate = S2_WAIT_ONE;
                else if (input_signal == 1'b0)                       nextstate = S0_WAIT_ZERO;
                else                                                 nextstate = S1_CHECK_ONE;
            end
            S2_WAIT_ONE: begin
                if (input_signal == 1'b0) nextstate = S3_CHECK_ZERO;
                else                      nextstate = S2_WAIT_ONE;
            end
            S3_CHECK_ZERO: begin
                if      (input_signal == 1'b0 && timer_done == 1'b1) nextstate = S0_WAIT_ZERO;
                else if (input_signal == 1'b1)                       nextstate = S2_WAIT_ONE;
                else                                                 nextstate = S3_CHECK_ZERO;
            end
            default: nextstate = S0_WAIT_ZERO;
        endcase
    end

    // output logic
    always_comb begin
        case (state)
            S0_WAIT_ZERO:  begin timer_reset = 1'b1; output_signal = 1'b0; end
            S1_CHECK_ONE:  begin timer_reset = 1'b0; output_signal = 1'b0; end
            S2_WAIT_ONE:   begin timer_reset = 1'b1; output_signal = 1'b1; end
            S3_CHECK_ZERO: begin timer_reset = 1'b0; output_signal = 1'b1; end
            default:       begin timer_reset = 1'b1; output_signal = 1'b0; end
        endcase
    end

endmodule