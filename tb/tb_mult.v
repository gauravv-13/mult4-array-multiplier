`timescale 1ns/1ns

module tb_mult;
    reg [3:0] A, B;
    reg clk, rst_n;
    wire [7:0] P;
    reg  [7:0] expected; // full 8-bit product; A*B alone is only 4 bits wide in $display

    integer checked_count = 0;
    integer error_count = 0;

    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate the 4-bit array multiplier
    mult_array uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(A),
        .b(B),
        .p(P)
    );
    
    integer i, j;
    

    // Stimulus Block
    initial begin
        clk   = 0;
        rst_n = 0;
        A     = 0;
        B     = 0;
        
        // Hold reset for 2 clock cycles
        #20;
        
        // Verify Reset State
        if (P !== 8'h00) begin
            $display("ERROR: Output not zero during reset!");
            error_count = error_count + 1;
        end
        
        // Release Reset
        @(posedge clk);
        #1 rst_n = 1; // Release slightly after edge to avoid race conditions
        
        $display("Verification...");
        
        // Loop
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                
                // Drive inputs on the falling edge to satisfy setup times
                // @(negedge clk);
                A = i;
                B = j;
                
                // Wait for the next rising edge where UUT samples inputs,
                @(posedge clk); 
                @(posedge clk); 
                #2; // Settle past the 1ns flip-flop delay in gate-level sim
                checked_count = checked_count + 1;
                expected = A * B;

                // 4. Self-Checking Verification
                if (P !== expected) begin
                    $display("Mismatch at A=%0d, B=%0d: got %0d, expected %0d", A, B, P, expected);
                    error_count = error_count + 1;
                end
            end
        end
        
        if (error_count == 0) begin
            $display("PASS: %0d vectors checked, 0 errors", checked_count);
        end else begin
            $display("FAIL: %0d vectors checked, %0d errors", checked_count, error_count);
        end

        $finish;
    end
endmodule
