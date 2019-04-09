module dphy_settle_ignore #(
  parameter int T_SETTLE = 300_000,
  parameter int T_CLK    = 5_000
)(
  input  clk_i,
  input  srst_i,
  input  lp_data_p_i,
  input  lp_data_n_i,
  (* mark_debug = "true" *) output hs_data_valid_o
);

localparam int IGNORE_TICKS = T_SETTLE / T_CLK;
localparam int CNT_WIDTH    = $clog2( IGNORE_TICKS );

(* mark_debug = "true" *) logic [CNT_WIDTH - 1 : 0] ignore_cnt;
logic lp_data_p_d1;
(* mark_debug = "true" *) logic lp_data_p_d2;
logic lp_data_n_d1;
(* mark_debug = "true" *) logic lp_data_n_d2;

always_ff @( posedge clk_i, posedge srst_i )
  if( srst_i )
    begin
      lp_data_p_d1 <= '0;
      lp_data_p_d2 <= '0;
      lp_data_n_d1 <= '0;
      lp_data_n_d2 <= '0;
    end
  else
    begin
      lp_data_p_d1 <= lp_data_p_i;
      lp_data_p_d2 <= lp_data_p_d1;
      lp_data_n_d1 <= lp_data_n_i;
      lp_data_n_d2 <= lp_data_n_d1;
    end

(* mark_debug = "true" *)enum logic [2 : 0] { IDLE_S,
                     LP_11_S,
                     LP_01_S,
                     LP_00_S,
                     HS_S } state, next_state;

always_ff @( posedge clk_i, posedge srst_i )
  if( srst_i )
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S:
        begin
          if( lp_data_p_d2 && lp_data_n_d2 )
            next_state = LP_11_S;
        end
      LP_11_S:
        begin
          if( !lp_data_p_d2 && lp_data_n_d2 )
            next_state = LP_01_S;
        end
      LP_01_S:
        begin
          if( !lp_data_p_d2 && !lp_data_n_d2 )
            next_state = LP_00_S;
        end
      LP_00_S:
        begin
          if( ignore_cnt == IGNORE_TICKS )
            next_state = HS_S;
        end
      HS_S:
        begin
          if( lp_data_p_d2 && lp_data_n_d2 )
            next_state = LP_11_S;
        end
    endcase
  end

always_ff @( posedge clk_i, posedge srst_i )
  if( srst_i )
    ignore_cnt <= '0;
  else
    if( state == LP_00_S )
      ignore_cnt <= ignore_cnt + 1'b1;
    else
      ignore_cnt <= '0;

assign hs_data_valid_o = state == HS_S;

endmodule
