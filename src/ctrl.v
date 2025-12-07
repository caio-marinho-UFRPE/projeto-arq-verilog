// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade de controle

module control (
	input wire [5:0] opcode, // bits 31-26 da instrução 
	input wire [5:0] funct, // bits 5-0 da instrução
	
	// define em qual registrador será escrito o resultado
	output reg [1:0] regDst,
	
	// Sinais de jump
	output reg jump,
	output reg jumpReg,
	
	// Sinais de jump condicionais (branches)
	output reg branch,
	output reg bne,
	
	// Acesso a RAM					
	output reg memRead,
	output reg memWrite,
	
	// define qual dado será escrito no banco de registradores
	output reg [1:0] memToReg,
	
	// Sinal de extensão para os imediatos
	output reg zeroExt,
	
	// Controle da ULA
	output reg [3:0] ALUOp,
	output reg ALUSrc,
	
	// Permissão de write
	output reg regWrite
);

	// Bloco de constantes para legibilidade do switch statement abaixo

	// Instruções de tipo R
	localparam OP_R_TYPE = 6'b000000;
	
	// Instruções de tipo J
	localparam OP_J = 6'b000010;
	localparam OP_JAL = 6'b000011;
	
	// Instruções de tipo I (aceso a memória e branches)
	localparam OP_LW = 6'b100011;
	localparam OP_SW = 6'b101011;
	localparam OP_BEQ = 6'b000100;
	localparam OP_BNE = 6'b000101;
	
	// Instruções de tipo I (operações matemáticas e lógica)
	localparam OP_ADDI = 6'b001000;
	localparam OP_ANDI = 6'b001100;
	localparam OP_ORI = 6'b001101;
	localparam OP_XORI = 6'b001110;
	localparam OP_LUI = 6'b001111;
	localparam OP_SLTI = 6'b001010;
	localparam OP_SLTIU = 6'b001011;
	
	// definição do funct espécifico
	localparam FUNCT_JR = 6'b001000;

	always @(*) begin
		
		// Valores padrão
		regDst = 2'b00;
		jump = 1'b0;
		jumpReg = 1'b0;
		branch = 1'b0;
		bne = 1'b0; 
		memRead = 1'b0;
		memToReg = 2'b00;
		memWrite = 1'b0;
		ALUSrc = 1'b0;
		regWrite = 1'b0;
		ALUOp = 4'b0000;
		
        zeroExt  = 1'b0; // 0 = sign extend 1 = zero extend
		
		// Switch (case) statement do opcode
		case (opcode)
			
			// Instruções de tipo R (OPCODE 0)
			OP_R_TYPE: begin
				// caso especial: JR (Jump Register) (jump tipo R)
				if (funct == FUNCT_JR) begin
					jumpReg = 1'b1;
				end
				// Instruções "normais" de tipo R
				else begin
					regDst = 2'b01;
					regWrite = 1'b1;
					ALUOp = 4'b0010;
				end
			end

			// Load Word
			OP_LW: begin
				ALUSrc = 1'b1;
				memRead = 1'b1;
				memToReg = 2'b01;
				regWrite =  1'b1;
				regDst = 2'b00;
				ALUOp = 4'b0000;
				
			end

			// Store Word
			OP_SW: begin
				ALUSrc = 1'b1;
				memWrite = 1'b1;
				ALUOp = 4'b0000;
		
			end

			// Branch if equal
			OP_BEQ: begin
				ALUSrc = 1'b0;
				branch = 1'b1;
				ALUOp = 4'b0001;
				
			end

			// Branch if not equal
			OP_BNE: begin
				ALUSrc = 1'b0;
				bne = 1'b1;
				ALUOp = 4'b0001;
		
			end
			
			// Jump
			OP_J: begin
				jump = 1'b1;
		
			end

			// Jump and link
			OP_JAL: begin
				jump = 1'b1;
				regWrite = 1'b1;
				regDst = 2'b10;
				memToReg = 2'b10;
		
			end
	
			// Bloco dos operadores aritméticos imediatos (só o ADDI mesmo)
			OP_ADDI: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b0000;
		
			end
	
			// Bloco dos operadores lógicos imediatos
			OP_ANDI: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b0011;
				zeroExt = 1'b1;
				
			end

		
			OP_ORI: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b0100;
				zeroExt = 1'b1;
		
			end

		
			OP_XORI: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b0101;
				zeroExt = 1'b1;
		
			end

		
			OP_LUI: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b0110;
			end

		
			OP_SLTI: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b0111;
		
			end

		
			OP_SLTIU: begin
				ALUSrc = 1'b1;
				regWrite = 1'b1;
				ALUOp = 4'b1000;
				zeroExt = 1'b0;
		
			end
			
			// Mantem os valores padrão
			default: begin
				regWrite = 1'b0;
		
			end
			
		endcase
		
	end
	
endmodule