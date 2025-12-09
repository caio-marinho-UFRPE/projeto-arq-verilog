// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade de controle da ULA

module ula_ctrl (
    // Detalhe, pessoalmente eu preferiria deixar o nome da entrada como ULAOp e ULAContral
    // para que todo o código fosse em português, mas como no documento está "ALUOp"
    // deixei assim e mantive a mesma lógica para o ALUControl
    input wire [3:0] ALUOp,     // Sinal ALUOp vindo da unidade central
    input wire [5:0] funct,     // 6 bits menos significativos da instrução
    output reg [3:0] ALUControl // Código da operação a sera realizada
);
    // Nem sei quantos parâmetros locais a gente definiu aqui, mas o motivo foi
    // o mesmo da ULA em termos de legibilidade

    // Códigos de operação da ULA, de acordo com a mesma
    localparam  OP_ADD      = 4'b0000;
    localparam  OP_SUB      = 4'b0001;
    localparam  OP_AND      = 4'b0010;
    localparam  OP_OR       = 4'b0011;
    localparam  OP_XOR      = 4'b0100;
    localparam  OP_NOR      = 4'b0101;
    localparam  OP_SLT      = 4'b0110;
    localparam  OP_SLTU     = 4'b0111;
    localparam  OP_SLL      = 4'b1000;
    localparam  OP_SRL      = 4'b1001;
    localparam  OP_SRA      = 4'b1010;
    localparam  OP_LUI      = 4'b1011;
    // Códigos de operação da unidade central, de acordo com a mesma
    localparam  ALUOP_RTYPE = 6'b000000;
    localparam  ALUOP_ADDI  = 6'b000001;
    localparam  ALUOP_ANDI  = 6'b000010;
    localparam  ALUOP_ORI   = 6'b000011;
    localparam  ALUOP_XORI  = 6'b000100;
    localparam  ALUOP_BEQ   = 6'b000101;
    localparam  ALUOP_BNE   = 6'b000110;
    localparam  ALUOP_SLTI  = 6'b000111;
    localparam  ALUOP_SLTIU = 6'b001000;
    localparam  ALUOP_LUI   = 6'b001001;
    localparam  ALUOP_LW    = 6'b001010;
    localparam  ALUOP_SW    = 6'b001011;
    localparam  ALUOP_J     = 6'b001100;
    localparam  ALUOP_JAL   = 6'b001101;

    localparam  FUNCT_ADD   = 6'h20;
    localparam  FUNCT_SUB   = 6'h22;
    localparam  FUNCT_AND   = 6'h24;
    localparam  FUNCT_OR    = 6'h25;
    localparam  FUNCT_XOR   = 6'h26;
    localparam  FUNCT_NOR   = 6'h27;
    localparam  FUNCT_SLT   = 6'h2A;
    localparam  FUNCT_SLTU  = 6'h2B;

    localparam  FUNCT_SLL   = 6'h00;
    localparam  FUNCT_SRL   = 6'h02;
    localparam  FUNCT_SRA   = 6'h03;
    localparam  FUNCT_SLLV  = 6'h04;
    localparam  FUNCT_SRLV  = 6'h06;
    localparam  FUNCT_SRAV  = 6'h07;

    localparam  FUNCT_JR    = 6'h08;

    always @(*) begin
        case (ALUOp)
            ALUOP_RTYPE: begin
                case (funct)
                    FUNCT_ADD : ALUControl = OP_ADD;
                    FUNCT_SUB : ALUControl = OP_SUB;
                    FUNCT_AND : ALUControl = OP_AND;
                    FUNCT_OR  : ALUControl = OP_OR;
                    FUNCT_XOR : ALUControl = OP_XOR;
                    FUNCT_NOR : ALUControl = OP_NOR;
                    FUNCT_SLT : ALUControl = OP_SLT;
                    FUNCT_SLTU: ALUControl = OP_SLTU;
                    FUNCT_SLL : ALUControl = OP_SLL;
                    FUNCT_SRL : ALUControl = OP_SRL;
                    FUNCT_SRA : ALUControl = OP_SRA;

                    FUNCT_SLLV: ALUControl = OP_SLL;
                    FUNCT_SRLV: ALUControl = OP_SRL;
                    FUNCT_SRAV: ALUControl = OP_SRA;

                    default  : ALUControl = OP_ADD;
                endcase
            end

            ALUOP_LW_SW : ALUControl = OP_ADD;
            ALUOP_BRANCH: ALUControl = OP_SUB;
            ALUOP_AND   : ALUControl = OP_AND;
            ALUOP_OR    : ALUControl = OP_OR;
            ALUOP_XOR   : ALUControl = OP_XOR;
            ALUOP_SLT   : ALUControl = OP_SLT;
            ALUOP_SLTU  : ALUControl = OP_SLTU;
            ALUOP_LUI   : ALUControl = OP_LUI;

            default   : ALUControl = OP_ADD;
        endcase
    end

endmodule