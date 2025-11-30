// Placeholder for HuC6261 (NEW Iron Guanyin)
//
// Implement enough of the chip to appease the BIOS.
//
// Copyright (c) 2025 David Hunter
//
// This program is GPL licensed. See COPYING for the full license.

module huc6261
    (
     input         CLK,
     input         CE,
     input         RESn,

     input         CSn,
     input         WRn,
     input         RDn,
     input         A2,
     input [15:0]  DI,
     output [15:0] DO
     );

logic [4:0]     rsel;
logic [8:0]     row, col;

logic [15:0]    dout;

//////////////////////////////////////////////////////////////////////
// Register interface

always @(posedge CLK) if (CE) begin
    if (~RESn) begin
        rsel <= '0;
    end
    else begin
        if (~CSn & ~WRn) begin
            case (A2)
                1'b0: begin
                    rsel <= DI[4:0];
                end
                1'b1: begin
                end                
            endcase
        end
    end
end

always @* begin
    dout = '0;
    case (A2)
        1'b0: begin
            dout[4:0] = rsel;
            dout[13:5] = row;
        end
        1'b1: begin
        end
    endcase
end

assign DO = (~CSn & ~RDn) ? dout : '0;

//////////////////////////////////////////////////////////////////////
// Video counter

always @(posedge CLK) if (CE) begin
    if (~RESn) begin
        col <= '0;
        row <= '0;
    end
    else begin
        if (col < 9'd390)
            col <= col + 1'd1;
        else begin
            col <= '0;
            if (row < 9'd263)
                row <= row + 1'd1;
            else
                row <= '0;
        end
    end
end

endmodule
