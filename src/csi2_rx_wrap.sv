module csi2_rx_wrap
(
  input           dphy_clk_p_i,
  input           dphy_clk_n_i,
  input           dphy_lp_clk_p_i,
  input           dphy_lp_clk_n_i,
  input  [1 : 0]  dphy_data_p_i,
  input  [1 : 0]  dphy_lp_data_p_i,
  input  [1 : 0]  dphy_data_n_i,
  input  [1 : 0]  dphy_lp_data_n_i,
  input           ref_clk_i,
  input           px_clk_i,
  input           ref_srst_i,
  input           px_srst_i,

(* mark_debug = "true" *)  input           video_tready_i,
(* mark_debug = "true" *)  output [15 : 0] video_tdata_o,
(* mark_debug = "true" *)  output          video_tvalid_o,
  output [1 : 0]  video_tstrb_o,
  output [1 : 0]  video_tkeep_o,
(* mark_debug = "true" *)  output          video_tuser_o,
  output          video_tid_o,
  output          video_tdest_o,
(* mark_debug = "true" *)  output          video_tlast_o
);

axi4_stream_if #(
  .DATA_WIDTH ( 16         ),
  .ID_WIDTH   ( 1          ),
  .DEST_WIDTH ( 1          )
) video (
  .aclk       ( px_clk_i   ),
  .aresetn    ( !px_srst_i )
);

assign video.tready   = video_tready_i;
assign video_tdata_o  = video.tdata;
assign video_tvalid_o = video.tvalid;
assign video_tstrb_o  = video.tstrb;
assign video_tkeep_o  = video.tkeep;
assign video_tuser_o  = video.tuser;
assign video_tid_o    = video.tid;
assign video_tdest_o  = video.tuser;
assign video_tlast_o  = video.tlast;

csi2_rx #(
  .DATA_LANES    ( 2                )
) csi2_rx (
  .dphy_clk_p_i  ( dphy_clk_p_i     ),
  .dphy_clk_n_i  ( dphy_clk_n_i     ),
  .dphy_data_p_i ( dphy_data_p_i    ),
  .dphy_data_n_i ( dphy_data_n_i    ),
  .lp_data_p_i   ( dphy_lp_data_p_i ),
  .lp_data_n_i   ( dphy_lp_data_n_i ),
  .ref_clk_i     ( ref_clk_i        ),
  .px_clk_i      ( px_clk_i         ),
  .ref_srst_i    ( ref_srst_i       ),
  .px_srst_i     ( px_srst_i        ),
  .enable_i      ( 1'b1             ),
  .video_o       ( video            )
);

(* mark_debug = "true" *) logic [10 : 0] px_cnt;
(* mark_debug = "true" *) logic [10 : 0] px_cnt_lock;
(* mark_debug = "true" *) logic [10 : 0] ln_cnt;
(* mark_debug = "true" *) logic [10 : 0] ln_cnt_lock;

always_ff @( posedge px_clk_i, posedge px_srst_i )
  if( px_srst_i )
    begin
      px_cnt      <= '0;
      px_cnt_lock <= '0;
    end
  else
    if( video.tvalid && video.tready )
      if( video.tlast )
        begin
          px_cnt      <= '0;
          px_cnt_lock <= px_cnt;
        end
      else
        px_cnt <= px_cnt + 1'b1;

always_ff @( posedge px_clk_i, posedge px_srst_i )
  if( px_srst_i )
    begin
      ln_cnt      <= '0;
      ln_cnt_lock <= '0;
    end
  else
    if( video.tvalid && video.tready )
      if( video.tuser )
        begin
          ln_cnt      <= '0;
          ln_cnt_lock <= ln_cnt;
        end
      else
        if( video.tlast )
          ln_cnt <= ln_cnt + 1'b1;

endmodule
