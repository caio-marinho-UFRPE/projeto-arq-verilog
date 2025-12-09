// Grupo composto pelos alunos Gabriel Leal de Queiroz e Caio Vinicius Marinho
// Atividade da segunda VA de 2025.2 de Arquitetura e Organização de Computadores
// Testbench para validar o funcionamento do núcleo MIPS (tb_mips_core)

`timescale 1ns / 1ps

module tb_mips_core;

    // Sinais que vamos injetar no processador (entradas)
    reg clk;
    reg reset;

    // Fios para observar o que está acontecendo lá dentro (saídas de debug)
    wire [31:0] debug_pc_out;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_d_mem_read_data;

    // Conecta nosso testbench ao núcleo do MIPS (Device Under Test)
    mips_core dut (
        .clk(clk),
        .reset(reset),
        .debug_pc_out(debug_pc_out),
        .debug_alu_result(debug_alu_result),
        .debug_d_mem_read_data(debug_d_mem_read_data)
    );

    // Gera o sinal de clock oscilando
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Inverte o clock a cada 5ns (período total 10ns)
    end

    // Configuração principal da simulação
    initial begin
        // Prepara o arquivo de ondas para abrir no GTKWave depois
        $dumpfile("mips_waves.vcd");
        $dumpvars(0, tb_mips_core);

        // Sequência de reset inicial
        $display("--- Inicio da Simulacao ---");
        reset = 1;  // Liga o reset para zerar o PC e registradores
        #10;        // Espera estabilizar
        reset = 0;  // Solta o reset para o processador começar a rodar

        // Roda a simulação por tempo suficiente para executar todas as instruções da lista
        #200;

        // Termina a execução e fecha o simulador automaticamente
        $display("--- Fim da Simulacao ---");
        $finish; 
    end

    // Mostra os valores no terminal a cada clock para acompanhar sem abrir o GTKWave
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %0t | PC: %d | ALU Out: %d | Mem Read: %d", 
                     $time, debug_pc_out, debug_alu_result, debug_d_mem_read_data);
        end
    end

endmodule