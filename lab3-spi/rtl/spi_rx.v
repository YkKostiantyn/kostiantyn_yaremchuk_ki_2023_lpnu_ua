// =============================================================================
// spi_rx.v — приймач SPI (Rx): послідовно-паралельний зсувний регістр.
// По sample фіксує поточне значення MISO у молодший біт із зсувом уліво,
// тому після DATA_W вибірок перший прийнятий біт стає старшим (MSB first).
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module spi_rx #(
    parameter integer DATA_W = 8
) (
    input  wire              clk,     // системний тактовий сигнал
    input  wire              rst_n,   // асинхронне скидання, активний 0
    input  wire              clear,   // очищення регістра перед передачею
    input  wire              sample,  // строб вибірки MISO від FSM
    input  wire              miso,    // послідовний вхід
    output wire [DATA_W-1:0] data     // прийняте слово
);

    reg [DATA_W-1:0] shreg;  // зсувний регістр приймача

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            shreg <= {DATA_W{1'b0}};
        else if (clear)
            shreg <= {DATA_W{1'b0}};
        else if (sample)
            shreg <= {shreg[DATA_W-2:0], miso};
    end

    assign data = shreg;

endmodule

`default_nettype wire
