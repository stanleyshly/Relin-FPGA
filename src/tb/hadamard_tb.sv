`timescale 1ns / 1ps
module hadamard_tb;

parameter LOGQ     = 64;
parameter LOGQH    = 48;
parameter FF_IN    = 1 ;
parameter FF_MUL   = 1 ;
parameter FF_SUM   = 1 ;
parameter FF_SUB   = 1 ;
parameter FF_OUT   = 1 ;
parameter USE_CSA  = 1 ;
parameter FF_CSA   = 1 ;
parameter MORE_DSP = 1 ;
parameter NON_STD  = 0 ;
parameter TP       = 32;

localparam W    = LOGQ - LOGQH;

reg               clk   ;
reg               rst   ;
reg               load_q;
reg  [LOGQ  -1:0] A  [TP-1:0];
reg  [LOGQ  -1:0] B  [TP-1:0];
reg  [LOGQH -1:0] qH    ;
wire [LOGQ - 1:0] C  [TP-1:0];

localparam HP = 5;   
localparam FP = 2 * HP; 

hadamard #(
    .LOGQ    (LOGQ)   ,
    .LOGQH   (LOGQH   ),
    .FF_IN   (FF_IN   ),
    .FF_MUL  (FF_MUL  ),
    .FF_SUM  (FF_SUM  ),
    .FF_SUB  (FF_SUB  ),
    .FF_OUT  (FF_OUT  ),
    .USE_CSA (USE_CSA ),
    .FF_CSA  (FF_CSA  ),
    .MORE_DSP(MORE_DSP),
    .NON_STD (NON_STD ),
    .TP      (TP      )
) hadamard_inst (
    .clk   (clk   ),
    .rst   (rst   ),
    .load_q(load_q),
    .A     (A     ),
    .B     (B     ),
    .qH    (qH    ),
    .T     (C     )
);

always #HP clk = ~clk;

integer idx;
integer file_A, file_B, file_q, file_python;
integer status_A, status_B, status_q, status_python;
integer rewind_status_A, rewind_status_B;

reg [LOGQ-1:0] C_python [0:TP-1];
reg [LOGQ-1:0] q;

integer num_lines_A = 0;
integer num_lines_B = 0;
integer min_num_lines;
integer current_set = 0;
integer result_mismatch = 0;
integer num_sets = 0;
integer num_elements_C = 0;
integer done_set = 0;
integer latency = hadamard_inst.LAT;

function integer count_lines;
    input integer file;
    integer char;
    integer lines;
    begin
        lines = 0;
        while (!$feof(file)) begin
            char = $fgetc(file);
            if (char == "\n") begin
                lines = lines + 1;
            end
        end
        count_lines = lines;
        $display("Lines %0d", count_lines);
    end
endfunction

initial begin
    $display("Starting simulation.");
    
    clk = 1'b0;
    load_q = 1'b1;
    #HP;
    
    file_A = $fopen("../../../../../test_vectors/hadamard/A.txt", "r");
    file_B = $fopen("../../../../../test_vectors/hadamard/B.txt", "r");
    file_q = $fopen("../../../../../test_vectors/hadamard/q.txt", "r");
    file_python = $fopen("../../../../../test_vectors/hadamard/T.txt", "r");
    
    if (file_A == 0 || file_B == 0 || file_q == 0 || file_python == 0) begin
        $display("Error: One of the files could not be opened.");
        $finish;
    end

    num_lines_A = count_lines(file_A);
    num_lines_B = count_lines(file_B);

    min_num_lines = (num_lines_A < num_lines_B) ? num_lines_A : num_lines_B;
    $display("min_num_lines%0d", min_num_lines);

    num_sets = min_num_lines / TP;
    num_elements_C = num_sets * TP;
    
    num_lines_A = count_lines(file_A);
    
    rewind_status_A = $fseek(file_A, 0, 0);
    if (rewind_status_A != 0) begin
        $display("Error: Could not rewind file_A.");
    end
    
    rewind_status_B = $fseek(file_B, 0, 0);
    if (rewind_status_B != 0) begin
        $display("Error: Could not rewind file_B.");
    end

    
    for (current_set = 0; current_set < num_sets; current_set = current_set + 1) begin
        $display("Processing input set %0d", current_set);
        
        for (idx = 0; idx < TP; idx = idx + 1) begin
            status_A = $fscanf(file_A, "%h\n", A[idx]);
            status_B = $fscanf(file_B, "%h\n", B[idx]);
            
            if (idx == 0 && current_set == 0) begin
                status_q = $fscanf(file_q, "%h\n", q);
                qH = q[LOGQ-1:W];
            end
         
            if (status_A != 1 || status_B != 1 || status_q != 1) begin
                $display("Error while reading inputs for set %0d at index %0d", current_set, idx);
                $finish;
            end
        end
        
        #FP;
        
        if (current_set >= (latency - 1)) begin
            for (idx = 0; idx < TP; idx = idx + 1) begin
                status_python = $fscanf(file_python, "%h\n", C_python[idx]); 
                if (status_python != 1) begin
                    $display("Error while reading from file python_results.txt at index %0d", idx);
                    $finish;
                end
            end
            
            for (idx = 0; idx < TP; idx = idx + 1) begin
                if (C[idx] == C_python[idx]) begin
                    $display("Test Passed -> Set[%0d] C[%0d] = %x", done_set, idx, C[idx]);
                end else begin
                    result_mismatch = result_mismatch + 1;
                    $display("Test Failed -> Set[%0d] C[%0d] = %x, Expected C[%0d] = %x", 
                              done_set, idx, C[idx], idx, C_python[idx]);
                end
            end
            
            done_set = done_set + 1;
        end
    end
    
    
    
    if (num_sets <= latency) begin
        for (current_set = 0; current_set < num_sets; current_set = current_set + 1) begin
            for (idx = 0; idx < TP; idx = idx + 1) begin
                status_python = $fscanf(file_python, "%h\n", C_python[idx]); 
                if (status_python != 1) begin
                    $display("Error while reading from file python_results.txt at index %0d", idx);
                    $finish;
                end
            end
            
            if (num_sets < latency) begin
                if (current_set == 0) begin
                    #(FP * (latency - num_sets));
                end
                
                if (current_set != 0) begin
                    #FP;  
                end
            end
            
            
            for (idx = 0; idx < TP; idx = idx + 1) begin
                if (C[idx] == C_python[idx]) begin
                    $display("Test Passed -> Set[%0d] C[%0d] = %x", current_set, idx, C[idx]);
                end else begin
                    result_mismatch = result_mismatch + 1;
                    $display("Test Failed -> Set[%0d] C[%0d] = %x, Expected C[%0d] = %x", 
                              current_set, idx, C[idx], idx, C_python[idx]);
                end
            end
            
            if (num_sets == latency) begin
                #FP;
            end
        end
        
        if (result_mismatch == 0) begin
            $display("All test sets passed.");
        end else begin
            $display("There were %0d mismatches in the results.", result_mismatch);
        end
    
        $fclose(file_A);
        $fclose(file_B);
        $fclose(file_q);
        $fclose(file_python);
    
        $finish;
    end

    if (num_sets > latency) begin
        for (current_set = done_set; current_set < num_sets ; current_set = current_set + 1) begin
            for (idx = 0; idx < TP; idx = idx + 1) begin
                status_python = $fscanf(file_python, "%h\n", C_python[idx]); 
                if (status_python != 1) begin
                    $display("Error while reading from file python_results.txt at index %0d", idx);
                    $finish;
                end
            end
            
            #FP
      
            for (idx = 0; idx < TP; idx = idx + 1) begin
                if (C[idx] == C_python[idx]) begin
                    $display("Test Passed -> Set[%0d] C[%0d] = %x", current_set, idx, C[idx]);
                end else begin
                    result_mismatch = result_mismatch + 1;
                    $display("Test Failed -> Set[%0d] C[%0d] = %x, Expected C[%0d] = %x", 
                              current_set, idx, C[idx], idx, C_python[idx]);
                end
            end

        end
        
        if (result_mismatch == 0) begin
            $display("All test sets passed.");
        end else begin
            $display("There were %0d mismatches in the results.", result_mismatch);
        end
    
        $fclose(file_A);
        $fclose(file_B);
        $fclose(file_q);
        $fclose(file_python);
    
        $finish;
    end
    
end

endmodule
