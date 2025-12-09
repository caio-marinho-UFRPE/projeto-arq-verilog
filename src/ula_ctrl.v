// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade de controle da ULA

module ula_ctrl (
    input wire [3:0] ALUOp,   // Código reduzido vindo da Control Unit
    input wire [5:0] funct,   // Campo funct (somente para instruções R)
    output reg [3:0] ALUControl // Operação final enviada para a ULA
);

    // Códigos de operação que a ULA entende diretamente
    // (Esses valores são escolhidos por nós — não são padrão MIPS)
    localparam OP_ADD  = 4'b0000;
    localparam OP_SUB  = 4'b0001;
    localparam OP_AND  = 4'b0010;
    localparam OP_OR   = 4'b0011;
    localparam OP_XOR  = 4'b0100;
    localparam OP_NOR  = 4'b0101;
    localparam OP_SLT  = 4'b0110;
    localparam OP_SLTU = 4'b0111;
    localparam OP_SLL  = 4'b1000;
    localparam OP_SRL  = 4'b1001;
    localparam OP_SRA  = 4'b1010;
    localparam OP_LUI  = 4'b1011;

    // Códigos ALUOp vindos da Control Unit
    // Cada um indica diretamente uma operação, exceto o RTYPE, que
    // obriga a olhar o funct.
    localparam ALUOP_RTYPE = 4'b0000; // Usa funct para decidir
    localparam ALUOP_ADD   = 4'b1000; // addi, lw, sw
    localparam ALUOP_SUB   = 4'b1001; // beq, bne
    localparam ALUOP_AND   = 4'b1010;
    localparam ALUOP_OR    = 4'b1011;
    localparam ALUOP_XOR   = 4'b1100;
    localparam ALUOP_LUI   = 4'b1111;
    localparam ALUOP_SLT   = 4'b1101;
    localparam ALUOP_SLTU  = 4'b1110;

    // Códigos funct padrão do MIPS (aparecem apenas no tipo R)
    localparam FUNCT_ADD  = 6'h20;
    localparam FUNCT_SUB  = 6'h22;
    localparam FUNCT_AND  = 6'h24;
    localparam FUNCT_OR   = 6'h25;
    localparam FUNCT_XOR  = 6'h26;
    localparam FUNCT_NOR  = 6'h27;
    localparam FUNCT_SLT  = 6'h2A;
    localparam FUNCT_SLTU = 6'h2B;

    // Shifts (com e sem variável)
    localparam FUNCT_SLL  = 6'h00;
    localparam FUNCT_SRL  = 6'h02;
    localparam FUNCT_SRA  = 6'h03;
    localparam FUNCT_SLLV = 6'h04;
    localparam FUNCT_SRLV = 6'h06;
    localparam FUNCT_SRAV = 6'h07;

    // jr — não gera operação da ULA, mas aparece no funct
    localparam FUNCT_JR   = 6'h08;

    always @(*) begin
        // Valor padrão (fallback)
        // Definimos ADD como padrão porque é seguro e não causa danos
        ALUControl = OP_ADD;

        case (ALUOp)
            // Tipo R — precisa olhar o funct
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

                    // Shifts diretos
                    FUNCT_SLL : ALUControl = OP_SLL;
                    FUNCT_SRL : ALUControl = OP_SRL;
                    FUNCT_SRA : ALUControl = OP_SRA;

                    // Versões com shamt vindo do registrador
                    FUNCT_SLLV: ALUControl = OP_SLL;
                    FUNCT_SRLV: ALUControl = OP_SRL;
                    FUNCT_SRAV: ALUControl = OP_SRA;

                    // Qualquer funct não reconhecido volta ao padrão
                    default   : ALUControl = OP_ADD;
                endcase
            end

            // Instruções tipo I ou específicas (já decididas pela Control Unit)
            ALUOP_ADD : ALUControl = OP_ADD;
            ALUOP_SUB : ALUControl = OP_SUB;
            ALUOP_AND : ALUControl = OP_AND;
            ALUOP_OR  : ALUControl = OP_OR;
            ALUOP_XOR : ALUControl = OP_XOR;
            ALUOP_SLT : ALUControl = OP_SLT;
            ALUOP_SLTU: ALUControl = OP_SLTU;
            ALUOP_LUI : ALUControl = OP_LUI;

            // Segurança: assume ADD se algo vier errado
            default   : ALUControl = OP_ADD;
        endcase
    end
endmodule