// synchronizer.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-14

// Two-stage flip flop aka synchronizer that prevents metastability.
// temp_col is the temporary register that holds the async_col input
// for one clk cycle before passing it to sync_col, the output.

module synchronizer(
	input  logic       clk, reset,
	input  logic [3:0] async_col,
	output logic [3:0] sync_col
);

	logic [3:0] temp_col;

    always_ff @(posedge clk, negedge reset) begin
        if (~reset) begin
            temp_col <= 4'b0;
            sync_col <= 4'b0;
        end else begin
            temp_col <= async_col;
            sync_col <= temp_col;
        end
    end
endmodule