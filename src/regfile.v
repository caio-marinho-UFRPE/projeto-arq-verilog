// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação do banco de registradores

module regfile (
	input clk, // clock
	input reset, // reset (seta tudo para 0)
	input regWrite, // Permissão de escrita, 0 para read only 1 para permitido
	input [4:0] readAddr1, // Qual registrador ler para a saída 1
	input [4:0] readAddr2, // Qual registrador ler para  saída 2
	input [4:0] writeAddr, // Em qual registrador salvar o dado
	input [31:0] writeData, // O valor númerico a ser salvo
	output [31:0] readData1, // O valor que estava em readAddr1
	output [31:0] readData2 // O valor que estava em readAddr2
	
);

	reg[31:0] registers [0:31]; // Banco de 32 registradores de 32 bits
	integer i; // variável auxiliar para o loop do reset
	
	
	// Leitura assíncrona
	// O registrador $zero deve ser sempre 0, então usamos o operado "?" para garantir isso
	assign readData1 = (readAddr1 == 5'd0) ? 32'd0 : registers[readAddr1];
	assign readData2 = (readAddr2 == 5'd0) ? 32'd0 : registers[readAddr2];
	
	
	// Escrita síncrona e reset
	always @(posedge clk, posedge reset) begin
		
		// Bloco de reset (assíncrono)
		if (reset) begin
			for (i = 0; i < 32; i = i + 1) begin // Loopa por todos os 32 registradores
				registers[i] <= 32'd0; // Seta para 0 o registrador de indice "I" dentro do loop
			end
		end

		// Bloco de escrita normal (no tempo do clock)
		else begin
			if (regWrite && (writeAddr != 5'd0)) begin // Se tiver permissão de escrita e se writeAddrfor diferente de 0
				registers[writeAddr] <= writeData; // Escreve o writeData no registrador de endereço writeAddr
			end
		end 
	end
endmodule