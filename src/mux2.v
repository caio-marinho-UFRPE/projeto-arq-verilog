// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação de um Multiplexador 2 para 1 (Mux2)

module mux2 #(parameter WIDTH = 32) ( // Parâmetro de largura (padrão 32 bits)
    input [WIDTH-1:0] d0, // Entrada de dados 0 (selecionada se s = 0)
    input [WIDTH-1:0] d1, // Entrada de dados 1 (selecionada se s = 1)
    input s,              // Sinal de controle (seleção) de 1 bit
    output [WIDTH-1:0] y  // Saída do dado selecionado
);
    // Lógica combinacional do multiplexador
    // Se o sinal 's' for 1, a saída 'y' recebe 'd1'. Caso contrário, recebe 'd0'.
    assign y = s ? d1 : d0;
    
endmodule