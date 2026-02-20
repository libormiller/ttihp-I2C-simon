module SPI_slave (
    input wire clk,          // System clock
    input wire ss,          // Slave Select
    input wire mosi,        // Master Out Slave In
    input wire sclk,        // Serial Clock
    output reg miso,        // Master In Slave Out
    output reg [7:0] data_out  // Data received
);
    
endmodule