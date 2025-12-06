// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Implementação da unidade lógica e aritmética (ULA)

module ula (
    input [31:0] In1,
    input [31:0] In2,
    input [3:0] OP,
    output reg [31:0] result,
    output wire Zero_flag
);

    localparam  ADD  = 4'b0000;
    localparam  SUB  = 4'b0001;
    localparam  AND  = 4'b0010;
    localparam  OR   = 4'b0011;
    localparam  XOR  = 4'b0100;
    localparam  NOR  = 4'b0101;
    localparam  SLT  = 4'b0110;
    localparam  SLTU = 4'b0111;
    localparam  SLL  = 4'b1000;
    localparam  SRL  = 4'b1001;
    localparam  SRA  = 4'b1010;

    always @(*) begin
        case (OP)
            ADD : result = In1 + In2;
            SUB : result = In1 - In2;
            AND : result = In1 & In2;
            OR  : result = In1 | In2;
            XOR : result = In1 ^ In2;
            NOR : result = ~(In1 | In2);
            SLT : result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;
            SLTU: result = (In1 < In2) ? 32'd1 : 32'd0;
            SLL : result = In2 << In1[4:0];
            SRL : result = In2 >> In1[4:0];
            SRA : result = $signedd(In2) >>> In1[4:0];
            
            default : result = 32'd0;
        endcase
    end

    assign Zero_flag = (result == 32'd0) ? 1'b1 : 1'b0;

endmodule