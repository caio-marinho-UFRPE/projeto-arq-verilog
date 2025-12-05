// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação do registrador PC (Program Counter)

module PC (
    input clk,                  // Clock
    input reset,                // Sinal de reset
    input [31:0] nextPC,        // Próximo valor do PC]
    output reg [31:0] pcOUT     // Output do PC


);

    // O PC inicializa zerado
    initial begin
        pcOUT = 32'h00000000; 
    end

    // Sempre que houver uma atualização no clock ou no reset roda o bloco abaixo
    always @(posedge clk or posedge reset) begin
        // se foi o reset, zera o PC
        if (reset) begin
            pcOUT <= 32'h00000000;
        // se foi o clock, carrega o próximo valor para o PC
        end else begin
            pcOUT <= nextPC;
        end
    end
    
endmodule


