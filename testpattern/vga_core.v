module vga_core (
                 input wire         reset,
                 input wire         clk_dot,
                 output wire [11:0] vga_pixel_rgb,
                 output wire        vga_active,
                 output wire        vga_hsync,
                 output wire        vga_vsync,
                 output      [10:0] x,
                 output      [ 9:0] y,
                 input       [11:0] color
                 );
   wire                      u0_vid_new_frame;
   wire                      u0_vid_new_line;
   
   assign vga_pixel_rgb = color;

   vga_timing u0_vga_timing (
                             .reset         (reset),
                             .clk_dot       (clk_dot),
                             .vid_new_frame (u0_vid_new_frame),
                             .vid_new_line  (u0_vid_new_line),
                             .vid_active    (vga_active),
                             .vga_hsync     (vga_hsync),
                             .vga_vsync     (vga_vsync)
                             );

   always @(posedge clk_dot) begin
      if (u0_vid_new_frame) begin
         x <= 0;
         y <= 0;
      end else if (u0_vid_new_line) begin
         x <= 0;
         y <= y + 1;
      end else begin
         x <= x + 1;
      end
   end
endmodule // vga_core
