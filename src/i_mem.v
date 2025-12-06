// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da memória de instruções (I_MEM)

module i_mem #(
    parameter TEXT_FILE = "instruction.list", // Arquivo com as instruções
    parameter MEM_DEPTH = 256 // Número parametrizável de instruções na memória
)(
    input [31:0] address, // Endereço da instrução
    output reg [31:0] i_out // A instrução que foi lida
);

    reg [31:0] mem [0:MEM_DEPTH - 1]; // Definição da matriz de memória definida pelo parâmetro MEM_DEPTH

    // Carrega o arquivo definido em TEXT_FILE para a memória
    initial begin
        $readmemb(TEXT_FILE, mem);
    end

    // Quando o endereço mudar, executa o bloco abaixo
    always @(*) begin
        // verifica se o endereço está dentro do limite
        if ((address >> 2) < MEM_DEPTH)
            i_out = mem[address[31:2]]; // bitshift para dividir por 4 e acessar a memória no "endereço/4"
        else
            i_out = 32'h00000000; // Da NOP (No Operation) se o endereço sair do limite
    end

endmodule
