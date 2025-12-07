// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da memória de dados

module d_mem #(
	parameter MEM_DEPTH = 256 // Número parametrizável de instruções na memória
)(
	input clk, // clock
	input [31:0] address, // endereço calculado pela ULA
	input [31:0] writeData,  // dado que vem do registrador B (rt)
	input memWrite, // habilita escrita (writeWord)
	input memRead, // habilita leitura (loadWord)
	output [31:0] readData // dado lido (vai para o mux	de writeBack)
);
	
	reg [31:0] ram [0:MEM_DEPTH - 1]; // Definição da matriz de memória definida pelo parâmetro MEM_DEPTH
	
	// leitura de alta impedância
	// Se memRead for 1, solta o dado. Se for 0, solta 'Z'
	// Usamos assign pois a leitura deve ser independente do clock (assíncrona)
	assign readData = (memRead) ? ram[address[31:2]] : 32'bz; 
	
	// Escrita sincrona
	always @(posedge clk) begin
		if (memWrite) begin
			// prteção de limite
			if ((address >> 2) < MEM_DEPTH)
				// Escrita em si
				ram[address[31:2]] <= writeData;
		end
	end
endmodule