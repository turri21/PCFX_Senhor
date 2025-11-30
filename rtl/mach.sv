// Computer assembly
//
// Copyright (c) 2025 David Hunter
//
// This program is GPL licensed. See COPYING for the full license.

module mach
  (
   input         CLK,
   input         CE,
   input         RESn,

   output        CPU_BCYSTn,

   output [19:0] ROM_A,
   input [15:0]  ROM_DO,
   output        ROM_CEn,
   input         ROM_READYn,

   output [20:0] RAM_A,
   output [31:0] RAM_DI,
   input [31:0]  RAM_DO,
   output        RAM_CEn,
   output        RAM_WEn,
   output [3:0]  RAM_BEn,
   input         RAM_READYn,

   output [31:0] A
   );

wire [31:0]     cpu_a;
logic [31:0]    cpu_d_i;
wire [31:0]     cpu_d_o;
wire [3:0]      cpu_ben;
wire [1:0]      cpu_st;
wire            cpu_dan;
wire            cpu_mrqn;
wire            cpu_rw;
wire            cpu_bcystn;
wire            cpu_readyn;
wire            cpu_szrqn;

logic           rom_cen;
logic [15:0]    rom_do;
logic           rom_readyn;

logic           ram_cen;
wire [31:0]     ram_do;
logic           ram_readyn;

logic           io_cen;
wor [15:0]      io_do;

logic           unk_cen;

logic           huc6261_cen;
logic [15:0]    huc6261_do;

v810 cpu
    (
     .RESn(RESn),
     .CLK(CLK),
     .CE(CE),

     .A(cpu_a),
     .D_I(cpu_d_i),
     .D_O(cpu_d_o),
     .BEn(cpu_ben),
     .ST(cpu_st),
     .DAn(cpu_dan),
     .MRQn(cpu_mrqn),
     .RW(cpu_rw),
     .BCYSTn(cpu_bcystn),
     .READYn(cpu_readyn),
     .SZRQn(cpu_szrqn)
     );

huc6261 huc6261
    (
     .RESn(RESn),
     .CLK(CLK),
     .CE(CE),

     .CSn(huc6261_cen),
     .WRn(cpu_dan | cpu_rw),
     .RDn(cpu_dan | ~cpu_rw),
     .A2(cpu_a[2]),
     .DI(cpu_d_o[15:0]),
     .DO(io_do)
     );

always @* begin
    if (~rom_cen)
        cpu_d_i = {16'b0, rom_do};
    else if (~ram_cen)
        cpu_d_i = ram_do;
    else if (~io_cen)
        cpu_d_i = {16'b0, io_do};
    else
        cpu_d_i = '0;
end

assign cpu_readyn = unk_cen & rom_readyn & ram_readyn & io_cen;
assign cpu_szrqn = ~unk_cen | (rom_cen & io_cen);

assign rom_do = ROM_DO;
assign rom_readyn = rom_cen | ROM_READYn;

assign ram_do = RAM_DO;
assign ram_readyn = ram_cen | RAM_READYn;

assign ram_cen = ~(~cpu_mrqn & ~cpu_a[31]);
assign rom_cen = ~(~cpu_mrqn & (cpu_a[31:20] == 12'hFFF));
assign io_cen = ~(cpu_mrqn & (~cpu_bcystn | ~cpu_dan) & (cpu_st == 2'b10));
assign unk_cen = ~(ram_cen & rom_cen & io_cen);

assign huc6261_cen = ~(~io_cen & (cpu_a[31:8] == 24'h000003));

assign CPU_BCYSTn = cpu_bcystn;

assign ROM_CEn = rom_cen;
assign ROM_A = cpu_a[19:0];

assign RAM_CEn = ram_cen;
assign RAM_A = cpu_a[20:0];
assign RAM_DI = cpu_d_o;
assign RAM_WEn = cpu_rw;
assign RAM_BEn = cpu_ben;

assign A = cpu_a;

always @(posedge CLK) if (1 && CE) begin
    if (~io_cen & ~cpu_dan)
        $display("%x %s %x", A, (cpu_rw ? "R" : "w"),
                 (cpu_rw ? cpu_d_i[15:0] : cpu_d_o[15:0]));
end

endmodule
