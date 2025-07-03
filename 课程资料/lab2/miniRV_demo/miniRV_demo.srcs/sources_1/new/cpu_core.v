`timescale 1ns / 1ps

module cpu_core(
    input  wire cpu_rst,
    input  wire cpu_clk
);

    wire [31:0] PC_pc;
    wire [31:0] NPC_npc;
    wire [31:0] IROM_inst;
    wire [31:0] RF_rD1;
    wire [31:0] RF_rD2;
    wire [31:0] SEXT_ext;
    wire [31:0] ALU_C;

    wire        Ctrl_rf_we;
    wire [ 0:0] Ctrl_alu_op;
    wire        Ctrl_alub_sel;
    wire        Ctrl_ram_we;

    PC U_PC (
        .rst        (cpu_rst),              // input  wire
        .clk        (cpu_clk),              // input  wire
        .din        (NPC_npc),              // input  wire [31:0]
        .pc         (PC_pc)                 // output reg  [31:0]
    );

    NPC U_NPC (
        .PC         (PC_pc),                // input  wire [31:0]
        .npc        (NPC_npc)               // output wire [31:0]
    );

    IROM U_IROM (
        .adr        (PC_pc),                // input  wire [31:0]
        .inst       (IROM_inst)             // output wire [31:0]
    );

    RF U_RF (
        .clk        (cpu_clk),              // input  wire

        .rR1        (IROM_inst[19:15]),     // input  wire [ 4:0]
        .rD1        (RF_rD1),               // output reg  [31:0]
        
        .rR2        (IROM_inst[24:20]),     // input  wire [ 4:0]
        .rD2        (RF_rD2),               // output reg  [31:0]
        
        .we         (Ctrl_rf_we),           // input  wire
        .wR         (IROM_inst[11:7]),      // input  wire [ 4:0]
        .wD         (ALU_C)                 // input  wire [31:0]
    );

    SEXT U_SEXT (
        .imm        ({IROM_inst[31:25], IROM_inst[11:7]}),  // input  wire [31:7]
        .ext        (SEXT_ext)              // output wire [31:0]
    );

    ALU U_ALU (
        .op         (Ctrl_alu_op),          // input  wire [ 0:0]
        .A          (RF_rD1),               // input  wire [31:0]
        .B          (Ctrl_alub_sel ? SEXT_ext : RF_rD2),     // input  wire [31:0]
        .C          (ALU_C)                 // output wire [31:0]
    );

    DRAM U_DRAM (
        .clk        (cpu_clk),              // input  wire
        .adr        (ALU_C),                // input  wire [31:0]
        .we         (Ctrl_ram_we),          // input  wire
        .wdin       (RF_rD2)                // input  wire [31:0]
    );

    Ctrl U_Ctrl (
        .opcode     (IROM_inst[6:0]),       // input  wire [6:0]
        .funct7     (IROM_inst[31:25]),     // input  wire [6:0]
        .funct3     (IROM_inst[14:12]),     // input  wire [2:0]

        .rf_we      (Ctrl_rf_we),           // output wire

        .alu_op     (Ctrl_alu_op),          // output wire
        .alub_sel   (Ctrl_alub_sel),        // output wire
        
        .ram_we     (Ctrl_ram_we)           // output wire
    );

endmodule
