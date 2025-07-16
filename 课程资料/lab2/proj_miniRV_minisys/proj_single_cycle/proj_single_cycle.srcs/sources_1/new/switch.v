module switch(
    input  wire         rst,
    input  wire         clk,
    input  wire [11:0]  addr,
    input  wire [23:0]  sw,
    output reg  [31:0]  rdata
);
    always @(*) begin
        if(rst) begin
            rdata = 32'd0;
        end else begin
            rdata = {8'd0, sw};
        end
    end

endmodule