`timescale 1ns / 1ps
module pattern_gen
   #(
        parameter FEED = 2,
        parameter POLL = 2
    )
    (   
        input      clk    ,
        input      rst    ,
        input      i_en   ,
        output reg o_en   ,
        input      i_valid,
        output reg o_valid  
    );


localparam LOGSR = (FEED > POLL) ? FEED : POLL;

typedef enum reg[2:0] {
    ST_FEED0 = 3'b001,
    ST_FEED1 = 3'b010,
    ST_POLL  = 3'b100
} t_state;


(* fsm_encoding = "none" *) t_state state;
t_state next_state;


reg [FEED-1:0] sr;
reg sr_inc;
reg sr_set;
reg sr_clr_feed;
reg sr_clr_poll;


for (genvar i = 0; i < FEED; i = i + 1) begin
    always @(posedge clk) begin
        if (rst) begin
            sr[i] <= 0;
        end 
        else if (sr_set) begin
            sr[i] <= (i == 0) ? 1 : sr[i];
        end 
        else if (sr_inc) begin
            sr[i] <= (i == 0) ? 0 : sr[i - 1];
        end
        else if (sr_clr_feed) begin
            sr[i] <= (i == (FEED - 1)) ? 0 : sr[i];
        end 
        else if (sr_clr_poll) begin
            sr[i] <= (i == (POLL - 1)) ? 0 : sr[i];
        end
    end
end


always @(posedge clk) begin
    if (rst) begin
        state <= ST_FEED0;
    end
    else begin
        state <= next_state;
    end
end



always @(*) begin

    next_state = state;
    sr_inc = 1'b0;
    sr_set = 1'b0;
    sr_clr_feed = 1'b0;
    sr_clr_poll = 1'b0;
    o_valid = 1'b0;
    o_en = 1'b0;


    case (state)
        ST_FEED0: begin
            if (i_en) begin
                if (sr[0] == 1'b0) begin
                    sr_set = 1'b1;
                end
                else begin
                    sr_inc = 1'b1;
                end
                next_state = ST_FEED1;
            end
        end
        ST_FEED1: begin
            o_valid = 1'b1;
            if (sr[FEED-1] == 1'b1) begin
                if (POLL == 0) begin
                    next_state = ST_FEED0;
                end
                else begin
                    next_state = ST_POLL;                    
                end
                sr_clr_feed = 1'b1;
            end
            else begin
                next_state = ST_FEED0;
            end
        end
        ST_POLL: begin
            o_valid = i_valid;
            o_en = i_en;
            if (i_valid) begin
                if (POLL == 1) begin
                    next_state = ST_FEED0;
                end
                else if (sr[POLL-1] == 1'b1) begin
                    next_state = ST_FEED0;
                    sr_clr_poll = 1'b1;
                end
                else if (sr[0] == 1'b0) begin
                    sr_set = 1'b1;
                end
                else begin
                    sr_inc = 1'b1;
                end
            end
        end
    endcase

end

endmodule