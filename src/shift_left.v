// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação do Deslocador à Esquerda de 2 bits (Shift Left 2)

module shift_left (
    input [31:0] in,    // Endereço ou offset de entrada
    output [31:0] out   // Saída multiplicada por 4
);
    // Realiza o deslocamento descartando os 2 bits mais significativos
    // e inserindo 2 zeros nas posições menos significativas (LSB).
    // Efeito prático: Multiplicação por 4 para alinhamento de palavra.
    assign out = {in[29:0], 2'b00};
    
endmodule