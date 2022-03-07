module top(
           input  CLK,
           
           output P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10,
           output P1B1, P1B2, P1B3, P1B4, P1B7, P1B8, P1B9, P1B10           
           );

   wire           reset;
   wire           clk;
   wire [3:0]     r;
   wire [3:0]     g;
   wire [3:0]     b;
   wire           de;
   wire           hs;
   wire           vs;

   reg [10:0]      x;
   reg [ 9:0]      y;
   reg [24:0]     color;
   
   assign reset = 0;
   

   // PLL
   SB_PLL40_PAD #(
                  .DIVR                           (4'b0000),
                  // 40MHz ish to be exact it is 39.750MHz
                  .DIVF                           (7'b0110100), // 39.750MHz
                  .DIVQ                           (3'b100),
                  .FILTER_RANGE                   (3'b001),
                  .FEEDBACK_PATH                  ("SIMPLE"),
                  .DELAY_ADJUSTMENT_MODE_FEEDBACK ("FIXED"),
                  .FDA_FEEDBACK                   (4'b0000),
                  .DELAY_ADJUSTMENT_MODE_RELATIVE ("FIXED"),
                  .FDA_RELATIVE                   (4'b0000),
                  .SHIFTREG_DIV_MODE              (2'b00),
                  .PLLOUT_SELECT                  ("GENCLK"),
                  .ENABLE_ICEGATE                 (1'b0)
                  ) pll_inst (
                              .PACKAGEPIN      (CLK),
                              .PLLOUTCORE      (),
                              .PLLOUTGLOBAL    (clk),
                              .EXTFEEDBACK     (),
                              .DYNAMICDELAY    (),
                              .RESETB          (1'b1),
                              .BYPASS          (1'b0),
                              .LATCHINPUTVALUE (),
                              .LOCK            (),
                              .SDI             (),
                              .SDO             (),
                              .SCLK            ()
                              );

   vga_core u_vga_core (
                        .reset         (reset),
                        .clk_dot       (clk),
                        .vga_pixel_rgb ({r, g, b}),
                        .vga_active    (de),
                        .vga_hsync     (hs),
                        .vga_vsync     (vs),
                        .x             (x),
                        .y             (y),
                        .color         (color)
                        );

   always @(posedge clk) begin
      if (y < 400) begin
         if (x < 114) begin
            color <= 12'b101110111011;
         end else if (x < 228) begin
            color <= 12'b101110110001;
         end else if (x < 342) begin
            color <= 12'b000110111011;
         end else if (x < 456) begin
            color <= 12'b000111010001;
         end else if (x < 570) begin
            color <= 12'b101100011101;
         end else if (x < 684) begin
            color <= 12'b101100010001;
         end else begin
            color <= 12'b000100011011;
         end 
      end else if (y < 450) begin
         if (x < 114) begin
            color <= 12'b000100011011;
         end else if (x >= 228 && x < 342) begin
            color <= 12'b101100011101;
         end else if (x >= 456 && x < 570) begin
            color <= 12'b000110111011;
         end else if (x >= 684) begin
            color <= 12'b101110111011;
         end else begin
            color <= 12'b000000000000;
         end                    
      end else begin
         if (x < 142) begin
            color <= 12'b000000100100;
         end else if (x < 285) begin
            color <= 12'b111111111111;
         end else if (x < 427) begin
            color <= 12'b001100000110;
         end else if (x >= 570 && x < 608) begin
            color <= 12'b000000000000;
         end else if (x >= 646 && x < 684) begin
            color <= 12'b001000100010;
         end else begin
            color <= 12'b000100010001;
         end              
      end
   end
   

   SB_IO #(
           .PIN_TYPE(6'b01_0000) // PIN_OUTPUT_DDR
           ) dvi_clk_iob (
                          .PACKAGE_PIN (P1B2),
                          .D_OUT_0     (1'b0),
                          .D_OUT_1     (1'b1),
                          .OUTPUT_CLK  (clk)
                          );

   SB_IO #(
           .PIN_TYPE(6'b01_0100) // PIN_OUTPUT_REGISTERED
           ) dvi_data_iob[14:0] (
                                 .PACKAGE_PIN ({P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10,
                                                P1B1,       P1B3, P1B4, P1B7, P1B8, P1B9, P1B10}),
                                 .D_OUT_0     ({r[3], r[1], g[3], g[1], r[2], r[0], g[2], g[0], 
                                                b[3],       b[0],   hs, b[2], b[1],   de,   vs}),
                                 .OUTPUT_CLK  (clk)
                                 );
endmodule // top
