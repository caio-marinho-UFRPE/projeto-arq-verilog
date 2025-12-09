// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação do NÚCLEO MIPS (TOP-LEVEL)

module mips_core (
    // Sinais de controle globais
    input clk,                // Clock
    input reset,              // Sinal de reset

    // Saídas de Debug
    output [31:0] debug_pc_out,          // Output do PC
    output [31:0] debug_alu_result,      // Resultado da ALU
    output [31:0] debug_d_mem_read_data  // Dado lido da memória
);

    // ==================== DECLARAÇÃO DE TODOS OS FIOS ====================
    
    // ----- PC e Cálculo de Endereços -----
    reg [31:0] PC_reg;                    // Registrador do PC
    wire [31:0] PC_out = PC_reg;          // Saída do PC
    wire [31:0] pc_plus_4;                // PC + 4
    wire [31:0] pc_plus_8;                // PC + 8 (para jal)
    wire [31:0] extended_imm;             // Imediato extendido
    wire [31:0] branch_offset;            // Imediato x 4 (para branch)
    wire [31:0] branch_target;            // PC+4 + (imm x 4)
    wire [31:0] jump_target;              // Endereço de jump
    wire [31:0] next_pc;                  // Próximo valor do PC
    
    // ----- Memória de Instruções -----
    wire [31:0] instruction;
    
    // ----- Campos da Instrução -----
    wire [5:0]  opcode    = instruction[31:26];
    wire [4:0]  rs        = instruction[25:21];
    wire [4:0]  rt        = instruction[20:16];
    wire [4:0]  rd        = instruction[15:11];
    wire [4:0]  shamt     = instruction[10:6];
    wire [5:0]  funct     = instruction[5:0];
    wire [15:0] immediate = instruction[15:0];
    wire [25:0] address_j = instruction[25:0];
    
    // ----- Sinais da Control Unit -----
    wire [1:0] reg_dst;
    wire       jump;
    wire       jump_reg;
    wire       branch;
    wire       bne;
    wire       mem_read;
    wire [1:0] mem_to_reg;
    wire       mem_write;
    wire       alu_src;
    wire       reg_write;
    wire       zero_ext;
    wire [3:0] alu_op;
    
    // ----- Banco de Registradores -----
    wire [4:0]  write_register_addr;      // Endereço de escrita (saída do mux)
    wire [31:0] write_data;               // Dado a escrever (saída do mux)
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;
    
    // ----- Extensão de Imediato -----
    wire [31:0] sign_extended_imm;
    wire [31:0] zero_extended_imm;
    wire [31:0] selected_ext_imm;         // Saída do mux sign/zero
    
    // ----- ALU e ALU Control -----
    wire [3:0]  alu_control_out;
    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    
    // ----- Memória de Dados -----
    wire [31:0] d_mem_read_data;
    
    // ----- Lógica de Branch/Jump -----
    wire        branch_condition;
    wire [31:0] pc_branch_mux_out;
    wire [31:0] pc_jump_mux_out;
    
    // ----- Saídas de Debug -----
    assign debug_pc_out = PC_out;
    assign debug_alu_result = alu_result;
    assign debug_d_mem_read_data = d_mem_read_data;
    
    // ==================== CÁLCULOS COMBINACIONAIS ====================
    
    // PC + 4 e PC + 8
    assign pc_plus_4 = PC_out + 32'd4;
    assign pc_plus_8 = PC_out + 32'd8;
    
    // Extensão de Imediato
    assign sign_extended_imm = {{16{immediate[15]}}, immediate};
    assign zero_extended_imm = {16'b0, immediate};
    assign selected_ext_imm = zero_ext ? zero_extended_imm : sign_extended_imm;
    
    // Cálculo de Branch
    assign branch_offset = selected_ext_imm << 2;  // x4
    assign branch_target = pc_plus_4 + branch_offset;
    
    // Cálculo de Jump
    assign jump_target = {pc_plus_4[31:28], address_j, 2'b00};
    
    // Condição de Branch
    assign branch_condition = (branch & alu_zero) | (bne & ~alu_zero);
    
    // ==================== MULTIPLEXADORES ====================
    
    // Mux para regDst
    assign write_register_addr = (reg_dst == 2'b00) ? rt :
                                 (reg_dst == 2'b01) ? rd :
                                 5'b11111;  // $31 para jal
    
    // Mux para ALUSrc
    assign alu_operand_b = alu_src ? selected_ext_imm : read_data_2;
    
    // Mux para MemToReg
    assign write_data = (mem_to_reg == 2'b00) ? alu_result :
                        (mem_to_reg == 2'b01) ? d_mem_read_data :
                        (mem_to_reg == 2'b10) ? pc_plus_8 :  // PC+8 para jal
                        32'b0;
    
    // Mux para Branch
    assign pc_branch_mux_out = branch_condition ? branch_target : pc_plus_4;
    
    // Mux para Jump
    assign pc_jump_mux_out = jump ? jump_target : pc_branch_mux_out;
    
    // Mux para Jump Register
    assign next_pc = jump_reg ? read_data_1 : pc_jump_mux_out;
    
    // ==================== INSTANCIAÇÃO DOS MÓDULOS ====================
    
    // ----- PC -----
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_reg <= 32'b0;
        end else begin
            PC_reg <= next_pc;
        end
    end
    
    // ----- Memória de Instruções -----
    i_mem instruction_memory (
        .address(PC_out),
        .i_out(instruction)
    );
    
    // ----- Control Unit -----
    control control_unit (
        .opcode(opcode),
        .funct(funct),
        .regDst(reg_dst),
        .jump(jump),
        .jumpReg(jump_reg),
        .branch(branch),
        .bne(bne),
        .memRead(mem_read),
        .memToReg(mem_to_reg),
        .memWrite(mem_write),
        .zeroExt(zero_ext),
        .ALUOp(alu_op),
        .ALUSrc(alu_src),
        .regWrite(reg_write)
    );
    
    // ----- Banco de Registradores -----
    regfile register_file (
        .clk(clk),
        .reset(reset),
        .regWrite(reg_write),

        .readAddr1(rs),
        .readAddr2(rt),

        .writeAddr(write_register_addr),
        .writeData(write_data),

        .readData1(read_data_1),
        .readData2(read_data_2)
    );


    
    // ----- ALU Control -----
    ula_ctrl alu_control (
        .ALUOp(alu_op),
        .funct(funct),
        .ALUControl(alu_control_out)
    );
    
    // ----- ULA -----
    ula alu_unit (
        .In1(read_data_1),        // Operando A vem de rs
        .In2(alu_operand_b),      // Operando B (mux)
        .OP(alu_control_out),
        .result(alu_result),
        .Zero_flag(alu_zero)
    );
    
    // ----- Memória de Dados -----
    d_mem data_memory (
        .clk(clk),
        .address(alu_result),
        .writeData(read_data_2),
        .memWrite(mem_write),
        .memRead(mem_read),
        .readData(d_mem_read_data)
    );

endmodule