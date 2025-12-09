// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação de um Somador de 32 bits (Adder)

module adder (
    input [31:0] a,    // Primeiro operando (ex: PC atual)
    input [31:0] b,    // Segundo operando (ex: constante 4 ou offset de branch)
    output [31:0] y    // Resultado da soma
);
    // Atribuição contínua da soma aritmética dos dois vetores de 32 bits
    assign y = a + b;
    
endmodule