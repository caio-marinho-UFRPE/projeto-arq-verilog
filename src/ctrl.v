// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade de controle
//
// Este módulo decodifica o opcode (e ocasionalmente o funct) e gera todos
// os sinais de controle usados no datapath (regDst, memRead, ALUSrc, etc).
// Comentários explicam rapidamente o propósito de cada bloco/linha.

module control (
    input wire [5:0] opcode,    // opcode da instrução (bits 31:26)
    input wire [5:0] funct,     // campo funct (usado para R-type / jr)
    output reg [1:0] regDst,    // 00=rt, 01=rd, 10=$31 (jal)
    output reg jump,            // jump incondicional (j, jal)
    output reg jumpReg,         // jump via registrador (jr)
    output reg branch,          // beq
    output reg bne,             // bne
    output reg memRead,         // habilita leitura de memória (lw)
    output reg memWrite,        // habilita escrita na memória (sw)
    output reg [1:0] memToReg,  // 00=ALU, 01=Mem, 10=PC+8 (jal)
    output reg zeroExt,         // estende imediato com zero (andi, ori, xori)
    output reg [3:0] ALUOp,     // sinal para ula_ctrl (decide operação)
    output reg ALUSrc,          // 0=reg, 1=imediato (I-type que usa imediato)
    output reg regWrite         // habilita escrita no banco de registradores
);

    // Opcodes padrão MIPS (comentário com hex opcional)
    localparam OP_R_TYPE = 6'b000000; // R-type (decodifica funct)
    localparam OP_J      = 6'b000010; // j
    localparam OP_JAL    = 6'b000011; // jal
    localparam OP_BEQ    = 6'b000100; // beq
    localparam OP_BNE    = 6'b000101; // bne
    localparam OP_ADDI   = 6'b001000; // addi
    localparam OP_SLTI   = 6'b001010; // slti
    localparam OP_SLTIU  = 6'b001011; // sltiu
    localparam OP_ANDI   = 6'b001100; // andi
    localparam OP_ORI    = 6'b001101; // ori
    localparam OP_XORI   = 6'b001110; // xori
    localparam OP_LUI    = 6'b001111; // lui
    localparam OP_LW     = 6'b100011; // lw
    localparam OP_SW     = 6'b101011; // sw

    // Códigos ALUOp (4 bits) — combinam com ula_ctrl.v
    localparam ALUOP_RTYPE = 4'b0000; // R-type -> usar funct
    localparam ALUOP_ADD   = 4'b1000; // add / address calc (lw/sw/addi)
    localparam ALUOP_SUB   = 4'b1001; // sub (beq/bne)
    localparam ALUOP_AND   = 4'b1010; // andi
    localparam ALUOP_OR    = 4'b1011; // ori
    localparam ALUOP_XOR   = 4'b1100; // xori
    localparam ALUOP_LUI   = 4'b1111; // lui
    localparam ALUOP_SLT   = 4'b1101; // slti
    localparam ALUOP_SLTU  = 4'b1110; // sltiu

    // Funct específico para jr (usado para detectar jumpReg)
    localparam FUNCT_JR = 6'b001000;

    always @(*) begin
        // Valores padrão (estado neutro)
        // Começamos com sinais que representam "não fazer nada" — a maioria é zero
        regDst   = 2'b00;   // por padrão escreve em rt (I-type) se houver
        jump     = 1'b0;
        jumpReg  = 1'b0;
        branch   = 1'b0;
        bne      = 1'b0;
        memRead  = 1'b0;
        memToReg = 2'b00;   // por padrão escreve ALU result
        memWrite = 1'b0;
        ALUSrc   = 1'b0;    // por padrão usa registrador como segundo operando
        regWrite = 1'b0;    // escrita no regfile desabilitada por padrão
        ALUOp    = ALUOP_ADD; // fallback para ADD (seguro)
        zeroExt  = 1'b0;    // por padrão estende por sinal

        case (opcode)
            // R-Type: se for jr, habilita jumpReg; caso contrário configura para escrever em rd
            OP_R_TYPE: begin
                if (funct == FUNCT_JR) begin
                    // jr: não escreve em registrador, apenas faz PC <- R[rs]
                    jumpReg = 1'b1;
                end else begin
                    // instruções R normais escrevem em rd e usam ALUOp = RTYPE
                    regDst   = 2'b01;  // escolha rd
                    regWrite = 1'b1;   // habilita escrita no regfile
                    ALUOp    = ALUOP_RTYPE; // ula_ctrl usará funct para decidir
                end
            end

            // LW: carregar da memória para registrador
            OP_LW: begin
                ALUSrc   = 1'b1;    // endereço = rs + immediate
                memRead  = 1'b1;    // ativa leitura de memória
                memToReg = 2'b01;   // write-back vem da memória
                regWrite = 1'b1;    // escreve no regfile
                regDst   = 2'b00;   // escreve em rt
                ALUOp    = ALUOP_ADD; // ALU faz soma para endereçamento
            end

            // SW: escrever na memória (não escreve no regfile)
            OP_SW: begin
                ALUSrc   = 1'b1;    // endereço = rs + immediate
                memWrite = 1'b1;    // ativa escrita na memória
                ALUOp    = ALUOP_ADD; // ALU calcula endereço
            end

            // BEQ: branch se igual (usa SUB para comparar)
            OP_BEQ: begin
                ALUSrc = 1'b0;      // compara registradores
                branch = 1'b1;      // sinal de branch (beq)
                ALUOp  = ALUOP_SUB; // ALU fará sub; se zero => equal
            end

            // BNE: branch se diferente (usa SUB + bne sinal)
            OP_BNE: begin
                ALUSrc = 1'b0;
                bne    = 1'b1;      // sinal específico para bne
                ALUOp  = ALUOP_SUB;
            end

            // J: salto absoluto (endereço no campo address)
            OP_J: begin
                jump = 1'b1;
            end

            // JAL: salto + salvar retorno em $31
            OP_JAL: begin
                jump     = 1'b1;
                regWrite = 1'b1;    // escreve $ra
                regDst   = 2'b10;   // escolha $31 como destino
                memToReg = 2'b10;   // write-back vem de PC+8 (codificado no top-level)
            end

            // ADDI: usa imediato, escreve em rt
            OP_ADDI: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_ADD;
            end

            // ANDI: imediato tratado como zero-extend
            OP_ANDI: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_AND;
                zeroExt  = 1'b1;    // estende imediato com zeros
            end

            // ORI: idem ANDI
            OP_ORI: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_OR;
                zeroExt  = 1'b1;
            end

            // XORI: idem ANDI/ORI
            OP_XORI: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_XOR;
                zeroExt  = 1'b1;
            end

            // LUI: imediato deslocado para cima (realizado pelo ALU via ALUOp_LUI)
            OP_LUI: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_LUI;
            end

            // SLTI: comparador com sinal
            OP_SLTI: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_SLT;
            end

            // SLTIU: comparador sem sinal
            OP_SLTIU: begin
                ALUSrc   = 1'b1;
                regWrite = 1'b1;
                ALUOp    = ALUOP_SLTU;
            end

            // Qualquer opcode não tratado mantém regWrite=0 (não escreve)
            default: begin
                regWrite = 1'b0;
            end
        endcase
    end
endmodule
