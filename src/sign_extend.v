// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação do Extensor de Sinal (Sign Extend)

module sign_extend (
    input [15:0] in,       // Entrada: Imediato de 16 bits (vem da instrução)
    input zeroExt,         // Sinal de controle: 0 faz extensão de sinal, 1 faz extensão de zero
    output [31:0] out      // Saída: Imediato estendido para 32 bits
);
    // Operação de extensão:
    // Se zeroExt for 1 (Instruções lógicas como ANDI, ORI):
    //    Concatena 16 zeros à esquerda do imediato ({16'b0, in}).
    // Se zeroExt for 0 (Instruções aritméticas como ADDI, LW, SW):
    //    Repete o bit de sinal (in[15]) 16 vezes e concatena com o imediato.
    assign out = zeroExt ? {16'b0, in} : {{16{in[15]}}, in};

endmodule