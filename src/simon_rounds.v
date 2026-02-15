//`timescale 1ns/1ps

/*
implementace  Feistalovy šifry, s přenosovou funkcí SIMON 32/64
výhoda Feistalovy šifry je že odšifrování je jen inverzní běh šifrování
-> stačí jen jeden mechanismus, ale musí se generovat inverzní pořadí klíčů
*/

module simon_rounds (
    input wire clk,
    input wire rst,
    input wire mode,         // 0=Encrypt, 1=Decrypt
    input wire [31:0] block, // plaintext
    input wire [63:0] key,   // hlavní klíč
    output reg [31:0] ciphertext,
    output reg done          // 1=hotovo
);
    reg [5:0] round_ctr;
    reg [15:0] Lx, Rx;       // rozdělení bloku s plaintextem
    wire [15:0] subkey;

    localparam S_IDLE = 0, S_PRECOMP = 1, S_CALC = 2;
    reg [1:0] state;
    
    reg key_dir; //řízení generace subklíčů
    
    //instance generátoru subklíču
    simon_key key_gen_inst (
        .clk(clk),
        .rst(rst),
        .key(key),
        .round_ctr(round_ctr),
        .dir(key_dir),
        .subkey(subkey)
    );

    // kombinančí logika pro SIMON
    wire [15:0] Lx_rol1 = {Lx[14:0], Lx[15]};
    wire [15:0] Lx_rol8 = {Lx[7:0], Lx[15:8]};
    wire [15:0] Lx_rol2 = {Lx[13:0], Lx[15:14]};   
    wire [15:0] f_out = (Lx_rol1 & Lx_rol8) ^ Lx_rol2;

    //pravá a levá strana po roundu
    wire [15:0] next_Lx = Rx ^ f_out ^ subkey;
    wire [15:0] next_Rx = Lx;

    always @(posedge clk) begin
        if (rst) begin
            // Inicializace 
            //pro decrypt musíme do PRECOMP propočíst poslední subklíč
            state <= (mode) ? S_PRECOMP : S_CALC;
            done <= 0;
            round_ctr <= 0;
            key_dir <= 0; 
            ciphertext <= 0;

            // načtení vstupu do registrů
            if (mode) begin Lx <= block[15:0];  Rx <= block[31:16]; end
            else      begin Lx <= block[31:16]; Rx <= block[15:0];  end

        end else begin
            case (state)
                S_IDLE: begin
                    // čekej na reset
                    done <= 1; 
                end

                S_PRECOMP: begin
                    // propočítání posledního subklíče
                    if (round_ctr < 27) begin
                        round_ctr <= round_ctr + 1;
                    end else begin
                        state <= S_CALC; // subklíč dopočítán -> můžeme rožifrovat 
                        round_ctr <= 31; // začínáme od posledního kola
                        key_dir <= 1;    // klíče generovat pozpátku
                    end
                end

                S_CALC: begin
                    if (!mode) begin // šifrování 0 -> 31
                        if (round_ctr < 31) begin
                            Lx <= next_Lx;
                            Rx <= next_Rx;
                            round_ctr <= round_ctr + 1;
                        end else begin
                            done <= 1;
                            ciphertext <= {next_Lx, next_Rx}; 
                            state <= S_IDLE; // stop
                        end
                    end else begin   // odšifrování 31 -> 0
                        if (round_ctr > 0) begin
                            Lx <= next_Lx;
                            Rx <= next_Rx;
                            round_ctr <= round_ctr - 1;
                        end else begin
                            done <= 1;
                            ciphertext <= {next_Rx, next_Lx}; 
                            state <= S_IDLE; // stop
                        end
                    end
                end
            endcase
        end
    end
endmodule