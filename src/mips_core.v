// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação do NÚCLEO MIPS (TOP-LEVEL)

module mips_core (
    // Entradas do sistema
    input clk,                // Clock principal
    input reset,              // Reset para zerar o processador

    // Saídas para debug e visualização de ondas
    output [31:0] debug_pc_out,          // Valor atual do PC
    output [31:0] debug_alu_result,      // Resultado da operação na ULA
    output [31:0] debug_d_mem_read_data  // Dado lido da memória de dados
);

    // Declaração dos fios internos
    
    // PC e fios de endereço
    reg [31:0] PC_reg;          // Registrador físico do PC
    wire [31:0] PC_out = PC_reg;// Saída do PC ligada ao resto
    wire [31:0] pc_plus_4;      // Endereço da próxima instrução
    wire [31:0] pc_plus_8;      // Endereço de retorno para o jal
    wire [31:0] branch_offset;  // Deslocamento calculado do branch
    wire [31:0] branch_target;  // Endereço de destino do branch
    wire [31:0] jump_target;    // Endereço de destino do jump
    wire [31:0] next_pc;        // Próximo valor a entrar no PC
    
    // Fio de instrução vindo da memória
    wire [31:0] instruction;
    
    // Separação dos bits da instrução
    wire [5:0]  opcode    = instruction[31:26]; // Opcode da instrução
    wire [4:0]  rs        = instruction[25:21]; // Registrador fonte 1
    wire [4:0]  rt        = instruction[20:16]; // Registrador fonte 2 ou destino
    wire [4:0]  rd        = instruction[15:11]; // Registrador destino (tipo R)
    wire [4:0]  shamt     = instruction[10:6];  // Quantidade de deslocamento (shift)
    wire [5:0]  funct     = instruction[5:0];   // Código de função
    wire [15:0] immediate = instruction[15:0];  // Valor imediato de 16 bits
    wire [25:0] address_j = instruction[25:0];  // Endereço para o jump
    
    // Sinais de controle vindos da control unit
    wire [1:0] reg_dst;       // Escolhe o registrador de destino
    wire       jump;          // Sinal de salto incondicional
    wire       jump_reg;      // Sinal para salto via registrador (jr)
    wire       branch;        // Sinal para instrução beq
    wire       bne;           // Sinal para instrução bne
    wire       mem_read;      // Habilita leitura da memória
    wire [1:0] mem_to_reg;    // Escolhe a fonte do dado para escrita
    wire       mem_write;     // Habilita escrita na memória
    wire       alu_src;       // Escolhe a origem do segundo operando da ULA
    wire       reg_write;     // Habilita escrita no banco de registradores
    wire       zero_ext;      // Define extensão de zero ou sinal
    wire [3:0] alu_op;        // Operação enviada para o controle da ULA
    
    // Fios do banco de registradores
    wire [4:0]  write_register_addr; // Endereço de escrita selecionado
    wire [31:0] write_data;          // Dado a ser escrito no registrador
    wire [31:0] read_data_1;         // Valor lido do primeiro registrador
    wire [31:0] read_data_2;         // Valor lido do segundo registrador
    
    // Extensões de imediato
    wire [31:0] sign_extended_imm;   // Extensão de sinal
    wire [31:0] zero_extended_imm;   // Extensão com zeros
    wire [31:0] selected_ext_imm;    // Imediato estendido selecionado
    
    // Fios da unidade lógica e aritmética
    wire [3:0]  alu_control_out;     // Controle da ULA decodificado
    wire [31:0] alu_operand_b;       // Segundo operando da ULA
    wire [31:0] alu_result;          // Resultado da operação
    wire        alu_zero;            // Flag zero da ULA
    
    // Fio de saída da memória de dados
    wire [31:0] d_mem_read_data;
    
    // Fios lógicos para decisão de desvio
    wire        branch_condition;    // Resultado da decisão de branch
    wire [31:0] pc_branch_mux_out;   // Saída do mux de branch
    wire [31:0] pc_jump_mux_out;     // Saída do mux de jump
    
    // Lógica combinacional e atribuições
    
    // Conecta saídas de debug
    assign debug_pc_out = PC_out;
    assign debug_alu_result = alu_result;
    assign debug_d_mem_read_data = d_mem_read_data;
    
    // Soma 4 ao PC atual
    assign pc_plus_4 = PC_out + 32'd4;
    // Soma 8 ao PC para salvar retorno no jal
    assign pc_plus_8 = PC_out + 32'd8;
    
    // Extensão de sinal verifica bit 15, senão preenche com zero
    assign sign_extended_imm = {{16{immediate[15]}}, immediate};
    assign zero_extended_imm = {16'b0, immediate};
    // Seleciona qual extensão usar baseado no sinal zero_ext
    assign selected_ext_imm = zero_ext ? zero_extended_imm : sign_extended_imm;
    
    // Calcula endereço de branch deslocando imediato e somando ao PC+4
    assign branch_offset = selected_ext_imm << 2; 
    assign branch_target = pc_plus_4 + branch_offset;
    // Concatena bits superiores do PC com endereço do jump
    assign jump_target = {pc_plus_4[31:28], address_j, 2'b00};
    
    // Lógica para decidir se branch ocorre (beq ou bne)
    assign branch_condition = (branch & alu_zero) | (bne & ~alu_zero);
    
    // Multiplexadores do caminho de dados
    
    // Seleciona registrador de escrita: rt, rd ou $31 (ra)
    assign write_register_addr = (reg_dst == 2'b00) ? rt :
                                 (reg_dst == 2'b01) ? rd :
                                 5'b11111;
    
    // Seleciona entrada B da ULA: registrador ou imediato
    assign alu_operand_b = alu_src ? selected_ext_imm : read_data_2;
    
    // Seleciona dado para escrita no reg: ULA, memória ou PC+8
    assign write_data = (mem_to_reg == 2'b00) ? alu_result :
                        (mem_to_reg == 2'b01) ? d_mem_read_data :
                        (mem_to_reg == 2'b10) ? pc_plus_8 : 
                        32'b0;
    
    // Mux para escolher próximo PC entre sequencial e branch
    assign pc_branch_mux_out = branch_condition ? branch_target : pc_plus_4;
    // Mux para escolher entre resultado anterior e jump
    assign pc_jump_mux_out = jump ? jump_target : pc_branch_mux_out;
    // Mux final para suportar jump register (jr)
    assign next_pc = jump_reg ? read_data_1 : pc_jump_mux_out;
    
    // Instanciação dos módulos
    
    // Processo do PC (única parte sequencial)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_reg <= 32'b0; // Reseta PC para zero
        end else begin
            PC_reg <= next_pc; // Atualiza PC na borda de subida
        end
    end
    
    // Memória de instruções
    i_mem instruction_memory (
        .address(PC_out),
        .i_out(instruction)
    );
    
    // Unidade de controle
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
    
    // Banco de registradores
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

    // Controle da ULA
    ula_ctrl alu_control (
        .ALUOp(alu_op),
        .funct(funct),
        .ALUControl(alu_control_out)
    );
    
    // Unidade lógica e aritmética
    ula alu_unit (
        .In1(read_data_1),
        .In2(alu_operand_b),
        .shamt(shamt),
        .OP(alu_control_out),
        .result(alu_result),
        .Zero_flag(alu_zero)
    );
    
    // Memória de dados
    d_mem data_memory (
        .clk(clk),
        .address(alu_result),
        .writeData(read_data_2),
        .memWrite(mem_write),
        .memRead(mem_read),
        .readData(d_mem_read_data)
    );

endmodule