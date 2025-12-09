// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade de controle da ULA

module ula_ctrl (
    // Pessoalmente, eu preferiria deixar tudo como "ULA" e "ULAControl" por ser
    // a sigla em português, mas como no documento cita explicitamente "ALU" e
    // "ALUControl" eu vou deixar assim
    input wire [3:0] ALUOp,     // opcode vindo da unidade de controle central
    input wire [5:0] funct,     // function, dos 6 bits menos significativos da instrução
    output reg [3:0] ALUControl // Sinal de controle enviado para ULA
);

    // Códigos de operação da ULA, de acordo as definições de lá
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
	localparam ALUOP_R_TYPE = 3'b000;
	localparam ALUOP_ADD  	= 3'b000;
	localparam ALUOP_SUB  	= 3'b001;
	localparam ALUOP_AND  	= 3'b010;
	localparam ALUOP_OR   	= 3'b011;
	localparam ALUOP_XOR  	= 3'b101;
	localparam ALUOP_SLT  	= 3'b110;
	localparam ALUOP_SLTU 	= 3'b111;

    // Códigos do funct, valores decididos com base nas ordem em que as instruções
    // estão dispostas no documento
    localparam  FUNCT_ADD   = 6'h01;
    localparam  FUNCT_SUB   = 6'h02;
    localparam  FUNCT_AND   = 6'h03;
    localparam  FUNCT_OR    = 6'h04;
    localparam  FUNCT_XOR   = 6'h05;
    localparam  FUNCT_NOR   = 6'h06;
    localparam  FUNCT_SLT   = 6'h07;
    localparam  FUNCT_SLTU  = 6'h08;
    // Deslocamentos, tipo R
    localparam  FUNCT_SLL   = 6'h09;
    localparam  FUNCT_SRL   = 6'h0A;
    localparam  FUNCT_SRA   = 6'h0B;
    localparam  FUNCT_SLLV  = 6'h0C;
    localparam  FUNCT_SRLV  = 6'h0D;
    localparam  FUNCT_SRAV  = 6'h0E;

    localparam  FUNCT_JR    = 6'h0F;

    always @(*) begin
        case (ALUOp)
            // Instrução tipo R, a operação depende do valor em funct
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
                    // Deslocamentos
                    FUNCT_SLLV: ALUControl = OP_SLL;
                    FUNCT_SRLV: ALUControl = OP_SRL;
                    FUNCT_SRAV: ALUControl = OP_SRA;
                    // Padrão de segurança, "na dúvida some"
                    default  : ALUControl = OP_ADD;
                endcase
            end
            
            // Instruções tipo I, a operação é definida aqui mesmo
            ALUOP_ADD : ALUControl = OP_ADD;
            ALUOP_SUB : ALUControl = OP_SUB;
            ALUOP_AND : ALUControl = OP_AND;
            ALUOP_OR  : ALUControl = OP_OR;
            ALUOP_XOR : ALUControl = OP_XOR;
            ALUOP_SLT : ALUControl = OP_SLT;
            ALUOP_SLTU: ALUControl = OP_SLTU;
            ALUOP_LUI : ALUControl = OP_LUI;

             // Padrão de segurança, "na dúvida some"
            default   : ALUControl = OP_ADD;
        endcase
    end

endmodule