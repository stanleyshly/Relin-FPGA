`timescale 1ns / 1ps
/*

    outputs q[i]

*/


module relin_q_mux
   #(   
        parameter LOGN     = 16,
        parameter LOGL     = 30, // number of primes
        parameter LOGQ     = 64,
        parameter LOGQH    = 17
    )
    (
        input                  clk,
        input                  rst,
        input  [LOGL -1:0]     i  ,
        output [LOGQH-1:0]     qH
    );


reg [ LOGQ-1:0] qH_int;

if (LOGQ == 60) begin
    if (LOGN == 12) begin
        always @(*) begin
            case (i)
                0      : qH_int = 60'h800580000000001;
                1      : qH_int = 60'h800800000000001;
                2      : qH_int = 60'h801a80000000001;
                default: qH_int = 60'h800580000000001; // default to first prime
            endcase
        end
    end
    else if (LOGN == 13) begin
        always @(*) begin
            case (i)
                0      : qH_int = 60'h800580000000001;
                1      : qH_int = 60'h800800000000001;
                2      : qH_int = 60'h801a80000000001;
                3      : qH_int = 60'h802500000000001;
                4      : qH_int = 60'h803200000000001;
                default: qH_int = 60'h800580000000001; // default to first prime
            endcase
        end
    end
    else if (LOGN == 14) begin
        always @(*) begin
            case (i)
                0      : qH_int = 60'h800580000000001;
                1      : qH_int = 60'h800800000000001;
                2      : qH_int = 60'h801a80000000001;
                3      : qH_int = 60'h802500000000001;
                4      : qH_int = 60'h803200000000001;
                5      : qH_int = 60'h805080000000001;
                6      : qH_int = 60'h805a80000000001;
                7      : qH_int = 60'h805c80000000001;
                default: qH_int = 60'h800580000000001; // default to first prime
            endcase
        end
    end
    else if (LOGN == 15) begin
        always @(*) begin
            case (i)
                0      : qH_int = 60'h800580000000001;
                1      : qH_int = 60'h800800000000001;
                2      : qH_int = 60'h801a80000000001;
                3      : qH_int = 60'h802500000000001;
                4      : qH_int = 60'h803200000000001;
                5      : qH_int = 60'h805080000000001;
                6      : qH_int = 60'h805a80000000001;
                7      : qH_int = 60'h805c80000000001;
                8      : qH_int = 60'h806e00000000001;
                9      : qH_int = 60'h807a80000000001;
                10     : qH_int = 60'h807f00000000001;
                11     : qH_int = 60'h809080000000001;
                12     : qH_int = 60'h809500000000001;
                13     : qH_int = 60'h80a580000000001;
                14     : qH_int = 60'h80ba80000000001;
                default: qH_int = 60'h800580000000001; // default to first prime
            endcase
        end
    end
    else if (LOGN == 16) begin
        always @(*) begin
            case (i)
                0      : qH_int = 60'h800580000000001;
                1      : qH_int = 60'h800800000000001;
                2      : qH_int = 60'h801a80000000001;
                3      : qH_int = 60'h802500000000001;
                4      : qH_int = 60'h803200000000001;
                5      : qH_int = 60'h805080000000001;
                6      : qH_int = 60'h805a80000000001;
                7      : qH_int = 60'h805c80000000001;
                8      : qH_int = 60'h806e00000000001;
                9      : qH_int = 60'h807a80000000001;
                10     : qH_int = 60'h807f00000000001;
                11     : qH_int = 60'h809080000000001;
                12     : qH_int = 60'h809500000000001;
                13     : qH_int = 60'h80a580000000001;
                14     : qH_int = 60'h80ba80000000001;
                15     : qH_int = 60'h80c200000000001;
                16     : qH_int = 60'h80c280000000001;
                17     : qH_int = 60'h80ee00000000001;
                18     : qH_int = 60'h80ef00000000001;
                19     : qH_int = 60'h80fd00000000001;
                20     : qH_int = 60'h810100000000001;
                21     : qH_int = 60'h810900000000001;
                22     : qH_int = 60'h810b80000000001;
                23     : qH_int = 60'h810c00000000001;
                24     : qH_int = 60'h811b00000000001;
                25     : qH_int = 60'h813000000000001;
                26     : qH_int = 60'h813880000000001;
                27     : qH_int = 60'h813d80000000001;
                28     : qH_int = 60'h814000000000001;
                29     : qH_int = 60'h814480000000001;
                default: qH_int = 60'h800580000000001; // default to first prime
            endcase
        end
    end

end else if (LOGQ == 32) begin
    if (LOGN == 12) begin
        always @(*) begin
            case (i)
                0      : qH_int = 32'h80140001;
                1      : qH_int = 32'h80320001;
                2      : qH_int = 32'h80340001;
                default: qH_int = 32'h80140001; // default to first prime
            endcase
        end
    end
    else if (LOGN == 13) begin
        always @(*) begin
            case (i)
                // 0      : qH_int = 60'h80140001;
                // 1      : qH_int = 60'h80320001;
                // 2      : qH_int = 60'h80340001;
                // 3      : qH_int = 60'h80400001;
                // 4      : qH_int = 60'h80460001;
                // default: qH_int = 60'h80140001; // default to first prime
                0      : qH_int = 60'h80140001;
                1      : qH_int = 60'h80320001;
                2      : qH_int = 60'h80340001;
                3      : qH_int = 60'h80400001;
                4      : qH_int = 60'h80460001;
                5      : qH_int = 60'h80580001;
                6      : qH_int = 60'h80700001;
                7      : qH_int = 60'h80760001;
                8      : qH_int = 60'h807c0001;
                9      : qH_int = 60'h80860001;
                default: qH_int = 60'h80140001; // default to first prime
            endcase
        end
    end
    else if (LOGN == 14) begin
        always @(*) begin
            case (i)
                0  : qH_int = 32'h80140001;
                1  : qH_int = 32'h80320001;
                2  : qH_int = 32'h80340001;
                3  : qH_int = 32'h80400001;
                4  : qH_int = 32'h80460001;
                5  : qH_int = 32'h80580001;
                6  : qH_int = 32'h80700001;
                7  : qH_int = 32'h80760001;
                8  : qH_int = 32'h807C0001;
                9  : qH_int = 32'h80860001;
                10 : qH_int = 32'h80A40001;
                11 : qH_int = 32'h80D60001;
                12 : qH_int = 32'h81160001;
                13 : qH_int = 32'h81240001;
                14 : qH_int = 32'h812A0001;
                15 : qH_int = 32'h81400001;

                default: qH_int = 32'h80140001;
            endcase
        end
    end
    else if (LOGN == 15) begin
        always @(*) begin
            case (i)
                0  : qH_int = 32'h80140001;
                1  : qH_int = 32'h80320001;
                2  : qH_int = 32'h80340001;
                3  : qH_int = 32'h80400001;
                4  : qH_int = 32'h80460001;
                5  : qH_int = 32'h80580001;
                6  : qH_int = 32'h80700001;
                7  : qH_int = 32'h80760001;
                8  : qH_int = 32'h807C0001;
                9  : qH_int = 32'h80860001;
                10 : qH_int = 32'h80A40001;
                11 : qH_int = 32'h80D60001;
                12 : qH_int = 32'h81160001;
                13 : qH_int = 32'h81240001;
                14 : qH_int = 32'h812A0001;
                15 : qH_int = 32'h81400001;
                16 : qH_int = 32'h816A0001;
                17 : qH_int = 32'h81700001;
                18 : qH_int = 32'h817E0001;
                19 : qH_int = 32'h81B20001;
                20 : qH_int = 32'h81D60001;
                21 : qH_int = 32'h821A0001;
                22 : qH_int = 32'h82200001;
                23 : qH_int = 32'h82300001;
                24 : qH_int = 32'h82480001;
                25 : qH_int = 32'h82600001;
                26 : qH_int = 32'h82740001;
                27 : qH_int = 32'h827E0001;
                28 : qH_int = 32'h828A0001;
                29 : qH_int = 32'h82980001;

                default: qH_int = 32'h80140001;
            endcase
        end
    end
    else if (LOGN == 16) begin
        always @(*) begin
            case (i)
                0  : qH_int = 32'h80140001;
                1  : qH_int = 32'h80320001;
                2  : qH_int = 32'h80340001;
                3  : qH_int = 32'h80400001;
                4  : qH_int = 32'h80460001;
                5  : qH_int = 32'h80580001;
                6  : qH_int = 32'h80700001;
                7  : qH_int = 32'h80760001;
                8  : qH_int = 32'h807C0001;
                9  : qH_int = 32'h80860001;
                10 : qH_int = 32'h80A40001;
                11 : qH_int = 32'h80D60001;
                12 : qH_int = 32'h81160001;
                13 : qH_int = 32'h81240001;
                14 : qH_int = 32'h812A0001;
                15 : qH_int = 32'h81400001;
                16 : qH_int = 32'h816A0001;
                17 : qH_int = 32'h81700001;
                18 : qH_int = 32'h817E0001;
                19 : qH_int = 32'h81B20001;
                20 : qH_int = 32'h81D60001;
                21 : qH_int = 32'h821A0001;
                22 : qH_int = 32'h82200001;
                23 : qH_int = 32'h82300001;
                24 : qH_int = 32'h82480001;
                25 : qH_int = 32'h82600001;
                26 : qH_int = 32'h82740001;
                27 : qH_int = 32'h827E0001;
                28 : qH_int = 32'h828A0001;
                29 : qH_int = 32'h82980001;
                30 : qH_int = 32'h82AA0001;
                31 : qH_int = 32'h82C60001;
                32 : qH_int = 32'h82C80001;
                33 : qH_int = 32'h82F80001;
                34 : qH_int = 32'h82FC0001;
                35 : qH_int = 32'h83100001;
                36 : qH_int = 32'h83160001;
                37 : qH_int = 32'h83380001;
                38 : qH_int = 32'h833E0001;
                39 : qH_int = 32'h834C0001;
                40 : qH_int = 32'h83500001;
                41 : qH_int = 32'h83640001;
                42 : qH_int = 32'h83A00001;
                43 : qH_int = 32'h83AA0001;
                44 : qH_int = 32'h83C20001;
                45 : qH_int = 32'h83CA0001;
                46 : qH_int = 32'h83E00001;
                47 : qH_int = 32'h83F40001;
                48 : qH_int = 32'h83FE0001;
                49 : qH_int = 32'h84040001;
                50 : qH_int = 32'h84300001;
                51 : qH_int = 32'h843C0001;
                52 : qH_int = 32'h84420001;
                53 : qH_int = 32'h84600001;
                54 : qH_int = 32'h84760001;
                55 : qH_int = 32'h84900001;
                56 : qH_int = 32'h84A60001;
                57 : qH_int = 32'h84FA0001;
                58 : qH_int = 32'h85120001;
                59 : qH_int = 32'h851E0001;

                default: qH_int = 32'h80140001;
            endcase
        end
    end
end


assign qH = qH_int[LOGQ-1 : LOGQ - LOGQH];  // take MSB LOGQH bits

endmodule