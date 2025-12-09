// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação de um Multiplexador 4 para 1 (Mux4)

module mux4 #(parameter WIDTH = 32) ( // Parâmetro de largura (padrão 32 bits)
    input [WIDTH-1:0] d0, // Entrada 00 (ex: Saída da ULA)
    input [WIDTH-1:0] d1, // Entrada 01 (ex: Saída da Memória)
    input [WIDTH-1:0] d2, // Entrada 10 (ex: PC + 8 para JAL)
    input [WIDTH-1:0] d3, // Entrada 11 (Não utilizada/Reserva)
    input [1:0] s,        // Sinal de controle de 2 bits (vem da Unidade de Controle)
    output reg [WIDTH-1:0] y // Saída do dado selecionado (reg pois é atribuído em bloco always)
);
    // Bloco combinacional que reage a qualquer mudança nas entradas ou seleção
    always @(*) begin
        case(s)
            2'b00: y = d0; // Seleciona a entrada 0
            2'b01: y = d1; // Seleciona a entrada 1
            2'b10: y = d2; // Seleciona a entrada 2
            2'b11: y = d3; // Seleciona a entrada 3
            default: y = d0; // Segurança: define padrão d0
        endcase
    end
endmodule