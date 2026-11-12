`timescale 1ns / 1ps
module relin_tb
#(   
    parameter L        = 4   , // Number of primes
    parameter LOGQ     = 60  ,
    parameter LOGQH    = 17  ,
    parameter LOGN     = 12  , //16
    parameter LOGTP    = 5   ,
    parameter NUMPSI   = 1 << LOGN
)();

`include "relin_if.svh"
`include "relin_mem.svh"

localparam LOGL = $rtoi($ceil($clog2(L + 1)));

localparam TP = 1 << LOGTP;
localparam HP = 2.5; // 200 MHz clock
localparam N_x = 1 << 3;

reg clk, rst, start;
wire done;

relin_t #(
  .LOGL(LOGL),    // From tb parameters
  .LOGQ(LOGQ),    // From tb parameters
  .TP(TP)// TP = 2^LOGTP
) relin_t_inst ();

relin #(
    .L      (L)     ,
    .LOGQ   (LOGQ)  ,
    .LOGQH  (LOGQH) ,
    .LOGN   (LOGN)  ,
    .LOGTP  (LOGTP) 
) relin_inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .relin_t(relin_t_inst)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
end

// Reset logic
initial begin
    rst = 1;
    start = 0;
    #20;
    rst = 0;
    #20;
    start = 1;
    #10;
    start = 0;
end
parameter ID_WIDTH = 4;
// Random driver for i_p0

localparam LOGK = LOGN -  $rtoi($ceil($clog2(TP)));
localparam K    = 128;//1 << LOGK;
localparam LAT  = 1;

localparam N    = 1 << LOGN;
localparam N1   = 1 << 5;
localparam N2   = 1 << 2;
localparam depth =  $rtoi($ceil(N/TP));
localparam N_over_TP =  $rtoi($ceil(N/TP));
localparam size0        = N1*N2;

localparam MAX_LINES = N*3;

integer file;
integer status;
string line;
logic [LOGQ-1:0] ntt_data_ [0:L*N-1];
logic [LOGQ-1:0] ntt_data [0:L*N-1];
// logic [LOGQ-1:0] psi_data [0:MAX_LINES-1];
logic [LOGQ-1:0] data_array [0:MAX_LINES-1];

logic [LOGQ-1:0] rlk [0:L][0:L-1][0:1][0:N-1];
logic [LOGQ-1:0] rlk_data0 [0:N-1];
logic [LOGQ-1:0] rlk_data1 [0:N-1];

logic [LOGQ-1:0] ct0 [0:L-1][0:N-1];
logic [LOGQ-1:0] ct1 [0:L-1][0:N-1];

int ntt_len; 
int psi_len;
int data_len;
int offset;
int num_cycles;
int opmode;
int ntt_input_TP;

int i,j,k, idx_here;

initial begin : respond_to_i_p0_en
    relin_t_inst.i_p0_valid = 0;
    relin_t_inst.i_p0_done  = 0;
    relin_t_inst.i_p0_ready = 1;

    // Preload both files into memory

    ntt_len = 0; 
    psi_len = 0; 
    data_len = 0;


    // --- Load ntt_in.txt ---
    for (i = 0; i < L ; i = i + 1) begin
        file = $fopen($sformatf("../../../../../model/BFV/test_vectors/ct2_%0d.txt", i), "r");
        if (!file) $fatal("Failed to open ntt_in.txt");
        while (!$feof(file)) begin
            status = $fgets(line, file);
            if (status > 0) begin
                status = $sscanf(line, "%h", ntt_data_[ntt_len]);
                if (status == 1) ntt_len++;
            end
        end
        $fclose(file);
    end

    for (k = 0; k < L; k = k + 1) begin
        for (i = 0; i < depth ; i = i + 1) begin
            for ( j = 0; j < TP; j = j + 1) begin // For every stage
                idx_here = ((j*N_over_TP) + ((i & (size0/TP-1)) * (N/size0)) + (i/(size0/TP))) & (N-1);
                ntt_data[TP - j - 1 + k*N + i*TP] = ntt_data_[idx_here + k*N];
            end
        end
    end

    // --- Load relinkey.txt ---
    for (i = 0; i < L + 1; i = i + 1) begin
        for (j = 0; j < L; j = j + 1) begin
            for (k = 0; k < 2; k = k + 1) begin
                ntt_len = 0;
                file = $fopen($sformatf("../../../../../model/BFV/test_vectors/relinkey_%0d_%0d_%0d.txt", j, i, k), "r");
                if (!file) $fatal("Failed to open relinkey.txt");
                while (!$feof(file)) begin
                    status = $fgets(line, file);
                    if (status > 0) begin
                        status = $sscanf(line, "%h", rlk[i][j][k][ntt_len]);
                        if (status == 1) ntt_len++;
                    end
                end
                $fclose(file);
            end
        end
    end

    // --- Load ct0.txt ---
    for (j = 0; j < L; j = j + 1) begin
        ntt_len = 0;
        file = $fopen($sformatf("../../../../../model/BFV/test_vectors/ct0_%0d.txt", j), "r");
        if (!file) $fatal("Failed to open ct0.txt");
        while (!$feof(file)) begin
            status = $fgets(line, file);
            if (status > 0) begin
                status = $sscanf(line, "%h", ct0[j][ntt_len]);
                if (status == 1) ntt_len++;
            end
        end
        $fclose(file);
    end

    // --- Load ct1.txt ---
    for (j = 0; j < L; j = j + 1) begin
        ntt_len = 0;
        file = $fopen($sformatf("../../../../../model/BFV/test_vectors/ct1_%0d.txt", j), "r");
        if (!file) $fatal("Failed to open ct1.txt");
        while (!$feof(file)) begin
            status = $fgets(line, file);
            if (status > 0) begin
                status = $sscanf(line, "%h", ct1[j][ntt_len]);
                if (status == 1) ntt_len++;
            end
        end
        $fclose(file);
    end


    // --- Load psi.txt ---
    // file = $fopen("../../../../../test_vectors/ntt/psi.txt", "r");
    // if (!file) $fatal("Failed to open psi.txt");
    // while (!$feof(file)) begin
    //     status = $fgets(line, file);
    //     if (status > 0) begin
    //         status = $sscanf(line, "%h", psi_data[psi_len]);
    //         if (status == 1) psi_len++;
    //     end
    // end
    // $fclose(file);

    // --- Main Response Loop ---
    forever begin
        @(posedge clk);

        if (relin_t_inst.i_p0_en && relin_t_inst.i_p0_ready) begin
            relin_t_inst.i_p0_ready <= 0;

            opmode = relin_t_inst.i_p0_id;

            if (relin_t_inst.i_p0_id == `PSI || relin_t_inst.i_p0_id == `PSI_INV) begin
                num_cycles = 3*N_over_TP;//psi_len / ntt_input_TP + ((psi_len % ntt_input_TP) ? 1 : 0);
                data_len = num_cycles*TP;
                for (int i = 0; i < data_len; i++) begin
                    if (relin_t_inst.i_p0_idx == 0)
                        data_array[i] = 60'h7ffa7ffffffffff;//psi_data[i];
                    else if (relin_t_inst.i_p0_idx == 1)
                        data_array[i] = 60'h7ff7fffffffffff;//psi_data[i];
                    else if (relin_t_inst.i_p0_idx == 2)
                        data_array[i] = 60'h7fe57ffffffffff;//psi_data[i];
                    else if (relin_t_inst.i_p0_idx == 3)
                        data_array[i] = 60'h7fdafffffffffff;//psi_data[i];
                    else if (relin_t_inst.i_p0_idx == 4)
                        data_array[i] = 60'h7fcdfffffffffff;//psi_data[i];    
                    end
            end
            else if (relin_t_inst.i_p0_id == `POLY_2) begin
                data_len = N;
                num_cycles = 1 << (LOGN - LOGTP);
                for (int i = 0; i < N; i++) 
                    data_array[i] = ntt_data[i + relin_t_inst.i_p0_idx * N];
            end

            //num_cycles = LAT + K;
            
            repeat (LAT) @(posedge clk);
            // Pulse valid
            relin_t_inst.i_p0_valid = 1;
 
            // Feed data
            for (int cycle = 0; cycle < num_cycles; cycle++) begin
                for (int j = 0; j < TP; j++) begin
                    relin_t_inst.i_p0_data[j] = data_array[cycle*TP + j];// % 60'h800580000000001;
                end
                @(posedge clk);
                relin_t_inst.i_p0_valid = 0;
            end

            // Pulse done
            relin_t_inst.i_p0_done = 1;
            @(posedge clk);
            relin_t_inst.i_p0_done = 0;

            // Re-enable ready
            relin_t_inst.i_p0_ready = 1;
        end
    end
end


initial begin : respond_to_i_p1_en
    relin_t_inst.i_p1_valid = 0;
    relin_t_inst.i_p1_done  = 0;
    relin_t_inst.i_p1_ready = 1;

    for (int j = 0; j < TP; j++) begin
        relin_t_inst.i_p1_data[j] = '0;
    end

    forever begin
        @(posedge clk);

        if (relin_t_inst.i_p1_en && relin_t_inst.i_p1_ready) begin
            relin_t_inst.i_p1_ready <= 0;
            if (relin_t_inst.i_p1_id == `POLY_0) begin
                for (int i = 0; i < N; i++) 
                    rlk_data0[i] = ct0[relin_t_inst.i_p1_idx][i];
            end
            else if (relin_t_inst.i_p1_id == `POLY_1) begin
                for (int i = 0; i < N; i++) 
                    rlk_data0[i] = ct1[relin_t_inst.i_p1_idx][i];
            end
            else if (relin_t_inst.i_p1_id == `RLK_0) begin
                for (int i = 0; i < N; i++) 
                    rlk_data0[i] = rlk[relin_t_inst.i_p1_idx][relin_t_inst.i_p1_idy][0][i];
            end

            repeat (LAT) @(posedge clk);
            relin_t_inst.i_p1_valid <= 1;

            for (int cycle = 0; cycle < K + LAT; cycle++) begin
                for (int j = 0; j < TP; j++) begin
                    relin_t_inst.i_p1_data[j] <= rlk_data0[cycle*TP + j];
                end
                @(posedge clk);
                relin_t_inst.i_p1_valid <= 0;
            end

            relin_t_inst.i_p1_done <= 1;
            @(posedge clk);
            relin_t_inst.i_p1_done <= 0;

            relin_t_inst.i_p1_ready <= 1;
        end
    end
end


initial begin : respond_to_i_p2_en
    relin_t_inst.i_p2_valid = 0;
    relin_t_inst.i_p2_done  = 0;
    relin_t_inst.i_p2_ready = 1;

    for (int j = 0; j < TP; j++) begin
        relin_t_inst.i_p2_data[j] = '0;
    end

    forever begin
        @(posedge clk);

        if (relin_t_inst.i_p2_en && relin_t_inst.i_p2_ready) begin
            relin_t_inst.i_p2_ready <= 0;
            for (int i = 0; i < N; i++) 
                rlk_data1[i] = rlk[relin_t_inst.i_p2_idx][relin_t_inst.i_p2_idy][1][i];

            repeat (LAT) @(posedge clk);
            relin_t_inst.i_p2_valid <= 1;

            for (int cycle = 0; cycle < K + LAT; cycle++) begin
                for (int j = 0; j < TP; j++) begin
                    relin_t_inst.i_p2_data[j] <= rlk_data1[cycle*TP + j];
                end
                @(posedge clk);
                relin_t_inst.i_p2_valid <= 0;
            end

            relin_t_inst.i_p2_done <= 1;
            @(posedge clk);
            relin_t_inst.i_p2_done <= 0;

            relin_t_inst.i_p2_ready <= 1;
        end
    end
end


// // Random driver for i_p2
// initial begin : respond_to_i_p2_en
//     relin_t_inst.i_p2_valid = 0;
//     relin_t_inst.i_p2_done  = 0;
//     relin_t_inst.i_p2_ready = 1;

//     for (int j = 0; j < TP; j++) begin
//         relin_t_inst.i_p2_data[j] = '0;
//     end

//     forever begin
//         @(posedge clk);

//         if (relin_t_inst.i_p2_en && relin_t_inst.i_p2_ready) begin
//             relin_t_inst.i_p2_ready <= 0;

//             relin_t_inst.i_p2_valid <= 1;
//             @(posedge clk);
//             relin_t_inst.i_p2_valid <= 0;

//             for (int cycle = 0; cycle < K + LAT; cycle++) begin
//                 for (int j = 0; j < TP; j++) begin
//                     relin_t_inst.i_p2_data[j] <= 32'd30000 + j + cycle * TP;
//                 end
//                 @(posedge clk);
//             end

//             relin_t_inst.i_p2_done <= 1;
//             @(posedge clk);
//             relin_t_inst.i_p2_done <= 0;

//             relin_t_inst.i_p2_ready <= 1;
//         end
//     end
// end

initial begin : accept_o_p3_write
    relin_t_inst.o_p3_done  = 0;
    relin_t_inst.o_p3_ready = 1;

    forever begin
        @(posedge clk);

        if (relin_t_inst.o_p3_en && relin_t_inst.o_p3_ready) begin
            //$display("[TB] o_p3_en received at %0t (idx=%0d, idy=%0d)", 
                      //$time, relin_t_inst.o_p3_idx, relin_t_inst.o_p3_idy);

            // Optionally: log or verify o_p3_data here
            for (int cycle = 0; cycle < K + LAT; cycle++) begin
                for (int j = 0; j < TP; j++) begin
                    //$display("[TB][o_p3] data[%0d] = %h", j, relin_t_inst.o_p3_data[j]);
                end
                @(posedge clk);
            end

            // Simulate data accepted: pulse done
            relin_t_inst.o_p3_done <= 1;
            @(posedge clk);
            relin_t_inst.o_p3_done <= 0;
        end
    end
end



// Monitor Done
initial begin
    wait (done == 1);
    $display("[relin_tb] DONE signal asserted at time %0t", $time);
    #50;//
    $finish;
end


endmodule