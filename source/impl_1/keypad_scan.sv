// keypad_scan.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-11-05

// FSM that scans the 4x4 matrix keypad to detect any keys pressed.
// Cycles through each row, checks column signals, and applies
// debouncing logic. num_new is a one-cycle pulse to signal a newly
// detected key press.

module keypad_scan(
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] col,
    output logic [3:0] rows,
	output logic       num_new
);

	typedef enum logic [3:0] { 
        S0_IDLE, 
		S1_R0, S2_R1, S3_R2, S4_R3, 
        S5_CHECK_R0, S6_CHECK_R1, S7_CHECK_R2, S8_CHECK_R3, 
        S9_CHECKING, S10_PRESSED, S11_WAIT 
    } statetype;
    statetype state, nextstate;

    // state register
    always_ff @(posedge clk, negedge reset)
        if (~reset) state <= S0_IDLE;
        else        state <= nextstate;

    // row register
	logic [3:0] newRows;
	logic		rowChange;
    always_ff @(posedge clk, negedge reset)
        if      (~reset)    rows <= 4'b0000;
        else if (rowChange) rows <= newRows;
	
	logic [3:0] last_col, last_row;
	always_ff @(posedge clk, negedge reset)
		if (~reset) begin
			last_col <= 4'b0000;
			last_row <= 4'b0000;
		end else if (state == S10_PRESSED) begin
			last_col <= col;
			last_row <= rows;
		end


    // counter for delays, mini timer
	logic [31:0] counter;
	logic        increment, clear;
    always_ff @(posedge clk)
        if      (clear)		counter <= 0;
        else if (increment) counter <= counter + 1;

    // next state logic
	parameter integer SCAN_DELAY = 2;
	parameter integer DEBOUNCE   = 15;
	parameter integer HOLD_TIME  = 300;
	
    always_comb
        case(state)
            S0_IDLE: nextstate = S1_R0;
            S1_R0:   nextstate = S5_CHECK_R0;
			S2_R1: 	 nextstate = S6_CHECK_R1;
			S3_R2:	 nextstate = S7_CHECK_R2;
			S4_R3:	 nextstate = S8_CHECK_R3;
            S5_CHECK_R0: begin
                if      (|col)					nextstate = S9_CHECKING;
                else if (counter >= SCAN_DELAY) nextstate = S2_R1;
                else							nextstate = S5_CHECK_R0;
			end
            S6_CHECK_R1: begin
                if 		(|col)					nextstate = S9_CHECKING;
                else if (counter >= SCAN_DELAY) nextstate = S3_R2;
                else							nextstate = S6_CHECK_R1;
			end
            S7_CHECK_R2: begin
                if 		(|col)					nextstate = S9_CHECKING;
                else if (counter >= SCAN_DELAY) nextstate = S4_R3;
                else							nextstate = S7_CHECK_R2;
			end
            S8_CHECK_R3: begin
                if 		(|col)					nextstate = S9_CHECKING;
                else if (counter >= SCAN_DELAY) nextstate = S1_R0;
                else							nextstate = S8_CHECK_R3;
			end
            S9_CHECKING: begin
                if (counter >= DEBOUNCE) begin
                    if   (|col) nextstate = S10_PRESSED;
                    else		nextstate = S0_IDLE;
				end else		nextstate = S9_CHECKING;
			end
            S10_PRESSED: 		nextstate = S11_WAIT;
            S11_WAIT: begin
				if (~|col && counter >= HOLD_TIME) nextstate = S0_IDLE;
				else if ( (|col) && ((col & last_col) == 0 || (rows & last_row) == 0) && (counter >= DEBOUNCE) ) begin
					nextstate = S9_CHECKING;
				end	else nextstate = S11_WAIT;
			end
            default: nextstate = S0_IDLE;
        endcase

    // output logic
    always_comb begin
        newRows   = 4'b0000;
        num_new   = 0;
        increment = 0;
        clear 	  = 0;
        rowChange = 0;

        case(state)
            S0_IDLE: clear = 1;
            S1_R0: begin newRows = 4'b0001; rowChange = 1; clear = 1; end
            S2_R1: begin newRows = 4'b0010; rowChange = 1; clear = 1; end
            S3_R2: begin newRows = 4'b0100; rowChange = 1; clear = 1; end
            S4_R3: begin newRows = 4'b1000; rowChange = 1; clear = 1; end
            S5_CHECK_R0: increment = 1;
			S6_CHECK_R1: increment = 1;
			S7_CHECK_R2: increment = 1;
			S8_CHECK_R3: increment = 1;
			S9_CHECKING: increment = 1;
            S10_PRESSED: num_new   = 1;
			S11_WAIT: 	 increment = 1;
        endcase
    end
endmodule