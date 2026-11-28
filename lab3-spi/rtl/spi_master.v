// =============================================================================
// spi_master.v — SPI Master (Verilog-2005)
// Лабораторна робота №3, варіант 30 (SPI, Verilog)
// Яремчук К. В., КІ-404
//
// Модуль верхнього рівня SPI Master. Містить:
//   * дільник тактової частоти, що формує SCK: f_SCK = f_clk / (2 * CLK_DIV);
//   * скінченний автомат (FSM) керування передачею: IDLE -> SETUP -> TRANSFER
//     -> HOLD -> DONE -> IDLE;
//   * екземпляр передавача spi_tx (зсувний регістр MOSI);
//   * екземпляр приймача spi_rx (зсувний регістр MISO).
// Підтримуються всі чотири режими SPI (CPOL/CPHA), повний дуплекс,
// передача старшим бітом уперед (MSB first), слово DATA_W біт.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module spi_master #(
    parameter integer DATA_W  = 8,  // розрядність слова
    parameter integer CLK_DIV = 4,  // півперіод SCK у тактах clk (>= 2)
    parameter integer CPOL    = 0,  // рівень SCK у стані спокою
    parameter integer CPHA    = 0   // 0: вибірка на передньому фронті, 1: на задньому
) (
    input  wire              clk,      // системний тактовий сигнал
    input  wire              rst_n,    // асинхронне скидання, активний 0
    input  wire              start,    // імпульс запуску передачі (1 такт)
    input  wire [DATA_W-1:0] tx_data,  // слово для передачі (фіксується по start)
    output reg  [DATA_W-1:0] rx_data,  // прийняте слово (дійсне по done)
    output reg               busy,     // 1 — триває передача
    output reg               done,     // імпульс завершення передачі (1 такт)
    output wire              sck,      // тактовий сигнал SPI
    output wire              mosi,     // Master Out Slave In
    input  wire              miso,     // Master In Slave Out
    output reg               cs_n      // вибір веденого (Slave Select), активний 0
);

    // ---------------------------------------------------------------------
    // Кодування станів FSM
    // ---------------------------------------------------------------------
    localparam [2:0] S_IDLE     = 3'd0,  // очікування start, CS неактивний
                     S_SETUP    = 3'd1,  // CS активний, витримка півперіоду до 1-го фронту
                     S_TRANSFER = 3'd2,  // генерація 2*DATA_W фронтів SCK
                     S_HOLD     = 3'd3,  // витримка півперіоду після останнього фронту
                     S_DONE     = 3'd4;  // зняття CS, видача rx_data і done

    localparam integer EDGES = 2 * DATA_W;  // кількість фронтів SCK за слово

    reg [2:0]  state;     // поточний стан FSM
    reg [15:0] div_cnt;   // лічильник дільника частоти
    reg [7:0]  edge_cnt;  // номер поточного фронту SCK (0 .. EDGES-1)
    reg        sck_int;   // внутрішній SCK без урахування CPOL (0 у спокої)

    // tick — кінець півперіоду SCK (момент формування фронту)
    wire tick = (div_cnt == CLK_DIV - 1);

    // ---------------------------------------------------------------------
    // Дільник частоти: працює лише в станах SETUP / TRANSFER / HOLD
    // ---------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            div_cnt <= 16'd0;
        else if (state == S_IDLE || state == S_DONE || tick)
            div_cnt <= 16'd0;
        else
            div_cnt <= div_cnt + 16'd1;
    end

    // ---------------------------------------------------------------------
    // Стробы фронтів: передній (lead) — парний номер фронту, задній (trail) — непарний.
    // Для CPHA=0: вибірка MISO на передньому, зсув MOSI на задньому.
    // Для CPHA=1: зсув MOSI на передньому (крім першого — старший біт уже
    // виставлено під час SETUP), вибірка MISO на задньому.
    // ---------------------------------------------------------------------
    wire in_xfer   = (state == S_TRANSFER);
    wire lead      = in_xfer && tick && (edge_cnt[0] == 1'b0);
    wire trail     = in_xfer && tick && (edge_cnt[0] == 1'b1);
    wire sample_en = (CPHA != 0) ? trail : lead;
    wire shift_en  = (CPHA != 0) ? (lead && (edge_cnt != 8'd0)) : trail;
    wire load      = (state == S_IDLE) && start;  // завантаження слова в Tx, очищення Rx

    wire [DATA_W-1:0] rx_word;  // поточний вміст зсувного регістра приймача

    // ---------------------------------------------------------------------
    // FSM керування передачею
    // ---------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            cs_n     <= 1'b1;
            busy     <= 1'b0;
            done     <= 1'b0;
            sck_int  <= 1'b0;
            edge_cnt <= 8'd0;
            rx_data  <= {DATA_W{1'b0}};
        end else begin
            done <= 1'b0;  // done — однотактовий імпульс
            case (state)
                S_IDLE: begin
                    sck_int  <= 1'b0;
                    edge_cnt <= 8'd0;
                    if (start) begin
                        cs_n  <= 1'b0;
                        busy  <= 1'b1;
                        state <= S_SETUP;
                    end
                end
                S_SETUP: begin
                    if (tick) state <= S_TRANSFER;
                end
                S_TRANSFER: begin
                    if (tick) begin
                        sck_int <= ~sck_int;  // формування фронту SCK
                        if (edge_cnt == EDGES - 1) begin
                            edge_cnt <= 8'd0;
                            state    <= S_HOLD;
                        end else begin
                            edge_cnt <= edge_cnt + 8'd1;
                        end
                    end
                end
                S_HOLD: begin
                    if (tick) state <= S_DONE;
                end
                S_DONE: begin
                    cs_n    <= 1'b1;
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    rx_data <= rx_word;
                    state   <= S_IDLE;
                end
                default: state <= S_IDLE;
            endcase
        end
    end

    // Полярність SCK: у спокої SCK = CPOL
    assign sck = (CPOL != 0) ? ~sck_int : sck_int;

    // ---------------------------------------------------------------------
    // Передавач (Tx) і приймач (Rx)
    // ---------------------------------------------------------------------
    spi_tx #(.DATA_W(DATA_W)) u_tx (
        .clk   (clk),
        .rst_n (rst_n),
        .load  (load),
        .shift (shift_en),
        .data  (tx_data),
        .mosi  (mosi)
    );

    spi_rx #(.DATA_W(DATA_W)) u_rx (
        .clk    (clk),
        .rst_n  (rst_n),
        .clear  (load),
        .sample (sample_en),
        .miso   (miso),
        .data   (rx_word)
    );

endmodule

`default_nettype wire
