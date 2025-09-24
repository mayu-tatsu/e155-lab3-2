`timescale 1 ns / 1 ps

module testbench_debouncer_timer();

    logic clk, timer_reset, timer_done;
    int   errors = 0;

    debouncer_timer dut(clk, timer_reset, timer_done);

    // generate a 100 Hz clk (10ns period)
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // Task to check timer_done
    task check_timer_done(input bit expected, string msg);
        #1; // small delay to sample after clock edge
        if (timer_done !== expected) begin
            $display("Fail: %s. Output: timer_done=%b, expected=%b at time %0t", msg, timer_done, expected, $time);
            errors = errors + 1;
        end
    endtask

    // Stimulus
    initial begin
        // Initial state: timer_done should be 0
        timer_reset = 0;
        #12;
        check_timer_done(0, "After power-on, timer_done should be 0");

        // Start timer: timer_done should go 0, then 1 after timer elapses
        timer_reset = 1;
        #10; // pulse timer_reset
        timer_reset = 0;
        check_timer_done(0, "Immediately after timer_reset, timer_done should be 0");

        // Wait for timer to finish (simulate 10 cycles, adjust if timer is longer)
        repeat (12) @(posedge clk);
        check_timer_done(1, "After timer duration, timer_done should be 1");

        // Start timer again
        timer_reset = 1;
        #10;
        timer_reset = 0;
        check_timer_done(0, "Second timer_reset, timer_done should be 0");
        repeat (12) @(posedge clk);
        check_timer_done(1, "After second timer duration, timer_done should be 1");

        $display("Testbench completed with %0d errors.", errors);
        $stop;
    end

    // Timeout
    initial begin
        #1000;
        $error("Simulation did not complete in time.");
        $stop;
    end

endmodule