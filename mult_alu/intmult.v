module intmult (
    input [31:0] a = 128,       // 8-bit multiplier
    input [31:0] b = 128,       // 8-bit multiplicand
    output reg [31:0] product // 16-bit product
);
    reg [31:0] multiplicand; // Extended version of the multiplicand
    reg [15:0] multiplier;    // Copy of the multiplier
    reg [31:0] result;       // Accumulator for the result
    integer i;

    always @(*) begin
        multiplicand = {8'b0, b}; // Extend the multiplicand to 16 bits
        multiplier = a;           // Copy the multiplier
        result = 16'b0;           // Initialize the result accumulator
        
        // Shift-and-add loop
        for (i = 0; i < 32; i = i + 1) begin
            if (multiplier[0] == 1'b1) begin
                result = result + multiplicand; // Add multiplicand if LSB of multiplier is 1
            end
            multiplicand = multiplicand << 1; // Shift multiplicand left
            multiplier = multiplier >> 1;     // Shift multiplier right
        end
        
        product = result; // Assign the final result to the output
    end
endmodule