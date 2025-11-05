// sev_seg_sel.sv
// Mayu Tatsumi; mtatsumi@g.hmc.edu
// 2025-09-23

// Alternates the output between the two seven segment display
// by enabling either seg1en or seg2en. These connect to the
// PNP transistors which activate the common anodes of either
// display. The output sw changes based on this clk-based
// toggle, but both displays use the same output pins. Has a
// clk divider to slow down clk from 6 MHz to 100 Hz.

module sev_seg_sel(
    input  logic       clk, reset,
    input  logic [3:0] onboard_sw, bboard_sw,
    output logic       seg1en, seg2en,
    output logic [3:0] sw
);

    logic alternate_led;

    // alternate_led toggles at 100Hz
    always_ff @(posedge clk) begin
        if (~reset)
            alternate_led <= 1'b0;
        else
            alternate_led <= ~alternate_led;
    end

    always_comb begin
        if (alternate_led) begin
            seg2en = 1'b0;
            seg1en = 1'b1;
            sw = onboard_sw;
        end else begin
            seg1en = 1'b0;
            seg2en = 1'b1;
            sw = bboard_sw;
        end
    end

endmodule