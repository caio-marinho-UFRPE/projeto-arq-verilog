// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade lógica e aritmética (ULA)

module ula (
    input [31:0] In1,         // Operando 1
    input [31:0] In2,         // Operando 2
    input [3:0] OP,           // Operação a ser realizada
    output reg [31:0] result, // Resultado da operação
    output wire Zero_flag     // Flag para o resultado 0
);

    // Nós preferimos usar parâmetros locais ao definir os códigos de operação
    // para tornar o código mais legível

    // Definição dos códigos de operação
    // A escolha dos valores foi feita com base na ordem que as instruções estão
    // expostas no documento do projeto. Também foi decidido reutilizar instuções
    // que utilizam de operações similares para que não precisásemos escrever
    // todas elas uma a uma
    localparam  ADD  = 4'b0000;
    localparam  SUB  = 4'b0001;
    localparam  AND  = 4'b0010;
    localparam  OR   = 4'b0011;
    localparam  XOR  = 4'b0100;
    localparam  NOR  = 4'b0101;
    localparam  SLT  = 4'b0110;
    localparam  SLTU = 4'b0111;
    // No casos das operações de deslocamento, assume-se que o primeiro operando
    // terá a distância a ser deslocada e o segundo o valor que será deslocado
    localparam  SLL  = 4'b1000;
    localparam  SRL  = 4'b1001;
    localparam  SRA  = 4'b1010;
    localparam  LUI  = 4'b1011;

    always @(*) begin
        case (OP)
            // Aqui o resultado é definido com base no código de operação que foi
            // passado, com as devidas reciclgagens nas funções que compartilham
            //o mesmo operador
            ADD : result = In1 + In2;    // Soma (addi, lw, sw)
            SUB : result = In1 - In2;    // Subtração (beq, bne)
            AND : result = In1 & In2;    // E (andi)
            OR  : result = In1 | In2;    // Ou (ori)
            XOR : result = In1 ^ In2;    // Ou exclusivo (xori)
            NOR : result = ~(In1 | In2); // Negação do Ou
            // Comparação com sinal
            // É necessário converter os operandos para $signed antes de realizar
            // a operação
            SLT : result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;
            SLTU: result = (In1 < In2) ? 32'd1 : 32'd0; // Comparação sem sinal
            // Deslocamentos
            // Tanto em SLL, quanto SRL a gente considerou os 5 bits meenos significativos
            // do operando 1 como a distência a ser deslocada
            SLL : result = In2 << In1[4:0];             // (sllv)
            SRL : result = In2 >> In1[4:0];             // (srlv)
            // Este deslocamente preserva o sinal, para tal é preciso que o segundo
            // operador seja tratado como signed para usar o operador >>>
            SRA : result = $signed(In2) >>> In1[4:0];  // (srav)
            
            // Pega os 16 bits inferiores de In2 (o imediato) e joga para o topo.
            LUI : result = {In2[15:0], 16'b0};
            
            default : result = 32'd0; // Segurança, explicada com mais detalhes
            // no ula_ctrl
        endcase
    end
    // Garante que o resultado quando a ula retornar 0 sempre será 1
    assign Zero_flag = (result == 32'd0) ? 1'b1 : 1'b0;

endmodule