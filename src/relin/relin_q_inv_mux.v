`timescale 1ns / 1ps
module relin_q_inv_mux
   #(   
        parameter LOGN     = 16,
        parameter LOGL     = 30, // number of primes
        parameter LOGQ     = 64
    )
    (
        input                 clk,
        input                 rst,
        input      [LOGL-1:0] i  ,
        output reg [LOGQ-1:0] q_inv
    );


if (LOGQ == 60) begin
    if (LOGN == 12) begin
        always @(*) begin
            case (i)
                0      : q_inv = 60'h0c3149249249e7a;
                1      : q_inv = 60'h0375d67c8a61bad;
                default: q_inv = 60'h0c3149249249e7a;
            endcase
        end
    end
    else if (LOGN == 13) begin
        always @(*) begin
            case (i)
                0      : q_inv = 60'h0fd2a84508a1703;
                1      : q_inv = 60'h67a4f3cf3cf430d;
                2      : q_inv = 60'h6792b3bea3682ba;
                3      : q_inv = 60'h764989d89d8b13c;
                default: q_inv = 60'h0fd2a84508a1703;
            endcase
        end
    end
    else if (LOGN == 14) begin
        always @(*) begin
            case (i)
                0      : q_inv = 60'h75b88d3dcb09030;
                1      : q_inv = 60'h42aacafb74a3c98;
                2      : q_inv = 60'h6cb1a2e8ba2ec9c;
                3      : q_inv = 60'h274060dd67c8efe;
                4      : q_inv = 60'h28b88a8a8a8aeaf;
                5      : q_inv = 60'h558b00000001556;
                6      : q_inv = 60'h000000000008000;
                default: q_inv = 60'h75b88d3dcb09030;
            endcase
        end
    end
    else if (LOGN == 15) begin
        always @(*) begin
            case (i)
                0      : q_inv = 60'h6305ab235bef1dc;
                1      : q_inv = 60'h54a30c30c30c47c;
                2      : q_inv = 60'h667b99999999b34;
                3      : q_inv = 60'h690059e6507b65f;
                4      : q_inv = 60'h29cae88e88e8ac9;
                5      : q_inv = 60'h32d771826a43c61;
                6      : q_inv = 60'h5591aaaaaaaad56;
                7      : q_inv = 60'h08317a8d9df546d;
                8      : q_inv = 60'h707b1c71c71ca76;
                9      : q_inv = 60'h000000000000400;
                10     : q_inv = 60'h7e5624924924d73;
                11     : q_inv = 60'h681373cf3cf430d;
                12     : q_inv = 60'h12dbd3a06d3a741;
                13     : q_inv = 60'h4fa3679e79e8619;
                default: q_inv = 60'h6305ab235bef1dc;
            endcase
        end
    end
    else if (LOGN == 16) begin
        always @(*) begin
            case (i)
                0      : q_inv = 60'h5a4c1ae24ea55df;
                1      : q_inv = 60'h318dd0472db335d;
                2      : q_inv = 60'h165a87bb4671732;
                3      : q_inv = 60'h0877fb8c3e54a5a;
                4      : q_inv = 60'h596ee38e38e39d3;
                5      : q_inv = 60'h34968000000010d;
                6      : q_inv = 60'h6b828118118129a;
                7      : q_inv = 60'h2c4334f72c23612;
                8      : q_inv = 60'h3af9d2a5e48ce79;
                9      : q_inv = 60'h764d4fd7720f499;
                10     : q_inv = 60'h7fd8716aefcc3bb;
                11     : q_inv = 60'h58910e38e38e4fb;
                12     : q_inv = 60'h0f0501756cac377;
                13     : q_inv = 60'h61e699c2d14efe7;
                14     : q_inv = 60'h521676b981db03c;
                15     : q_inv = 60'h40a02545a3cd1e7;
                16     : q_inv = 60'h0dddcec4ec4ee47;
                17     : q_inv = 60'h023c5bbee3e296f;
                18     : q_inv = 60'h40d802fe80bfd02;
                19     : q_inv = 60'h30b577f1ada6b6a;
                20     : q_inv = 60'h40fad097b42629c;
                21     : q_inv = 60'h5e562d2d2d2d721;
                22     : q_inv = 60'h6159847dc11fb83;
                23     : q_inv = 60'h75a075ce28c7a57;
                24     : q_inv = 60'h398d940c565cea7;
                25     : q_inv = 60'h5e87063e7064aee;
                26     : q_inv = 60'h2b12d5555556aab;
                27     : q_inv = 60'h5c5080000002493;
                28     : q_inv = 60'h47ce38e38e3c71d;
                default: q_inv = 60'h5a4c1ae24ea55df;

            endcase
        end
    end
end else if(LOGQ == 32) begin
    if (LOGN == 12) begin
        // L=2, p=0x80340001; p^-1 in Montgomery representation (R=2^32).
        always @(*) begin
            case (i)
                0: q_inv = 32'h00000800;
                1: q_inv = 32'h00008000;
                default: q_inv = {LOGQ{1'bx}};
            endcase
        end
    end else if (LOGN == 13) begin
        always @(*) begin
            case (i)
                0 : q_inv = 32'h0B3C262D;
                1 : q_inv = 32'h61AC33D0;
                2 : q_inv = 32'h73B20F9D;
                3 : q_inv = 32'h0EA83E2C;
                4 : q_inv = 32'h00000400;
                5 : q_inv = 32'h647169BE;
                6 : q_inv = 32'h74C2F45E;
                7 : q_inv = 32'h00001000;
                8 : q_inv = 32'h66C9B334;

                default: q_inv = 32'h0F5E947B;
            endcase
        end
    end
    else if (LOGN == 14) begin
        always @(*) begin
            case (i)
                0  : q_inv = 32'h6D4B18C0;
                1  : q_inv = 32'h15D737F1;
                2  : q_inv = 32'h524795F9;
                3  : q_inv = 32'h00000100;
                4  : q_inv = 32'h1CBBB74C;
                5  : q_inv = 32'h0D46E69F;
                6  : q_inv = 32'h58EB14ED;
                7  : q_inv = 32'h5CD91815;
                8  : q_inv = 32'h789E358E;
                9  : q_inv = 32'h305E7A7F;
                10 : q_inv = 32'h20FC1BE6;
                11 : q_inv = 32'h41A2290F;
                12 : q_inv = 32'h312CF9E8;
                13 : q_inv = 32'h49CB76DC;
                14 : q_inv = 32'h0BBE0BA3;
                
                default: q_inv = 32'h6D4B18C0; // Updated default to match index 0
            endcase
        end
    end
    else if (LOGN == 15) begin
        always @(*) begin
            case (i)
                0  : q_inv = 32'h71C2432F;
                1  : q_inv = 32'h266AB634;
                2  : q_inv = 32'h2EEC8CF8;
                3  : q_inv = 32'h684F5C97;
                4  : q_inv = 32'h305F5AF0;
                5  : q_inv = 32'h721555C8;
                6  : q_inv = 32'h44DF4E61;
                7  : q_inv = 32'h416827DB;
                8  : q_inv = 32'h01E74A6E;
                9  : q_inv = 32'h3C23A79C;
                10 : q_inv = 32'h305E6F1B;
                11 : q_inv = 32'h35D3261E;
                12 : q_inv = 32'h20C5EB71;
                13 : q_inv = 32'h0B1BDFA8;
                14 : q_inv = 32'h730C3B75;
                15 : q_inv = 32'h4220BF42;
                16 : q_inv = 32'h1723E91D;
                17 : q_inv = 32'h76F14CFA;
                18 : q_inv = 32'h4B4EBA1A;
                19 : q_inv = 32'h591855B5;
                20 : q_inv = 32'h201FD718;
                21 : q_inv = 32'h1AD8ACB3;
                22 : q_inv = 32'h08ACCEEF;
                23 : q_inv = 32'h782C513C;
                24 : q_inv = 32'h4E2B3667;
                25 : q_inv = 32'h5D200493;
                26 : q_inv = 32'h1CFD5C72;
                27 : q_inv = 32'h5A5744ED;
                28 : q_inv = 32'h6FE4124A;

                default: q_inv = 32'h71C2432F;
            endcase
        end
    end
    else if (LOGN == 16) begin
        always @(*) begin
            case (i)
                0  : q_inv = 32'h5AF205C2;
                1  : q_inv = 32'h20268BFD;
                2  : q_inv = 32'h51BB672D;
                3  : q_inv = 32'h7CC01A82;
                4  : q_inv = 32'h22C20A1E;
                5  : q_inv = 32'h7EDF94F4;
                6  : q_inv = 32'h2D07367E;
                7  : q_inv = 32'h59A9FCC8;
                8  : q_inv = 32'h6148BC71;
                9  : q_inv = 32'h2BB72846;
                10 : q_inv = 32'h072F22A0;
                11 : q_inv = 32'h10ED6702;
                12 : q_inv = 32'h32088732;
                13 : q_inv = 32'h2A5ECC73;
                14 : q_inv = 32'h1986C89A;
                15 : q_inv = 32'h06016C59;
                16 : q_inv = 32'h696348A5;
                17 : q_inv = 32'h65F4C1C5;
                18 : q_inv = 32'h7D06E5CC;
                19 : q_inv = 32'h8082C95B;
                20 : q_inv = 32'h71C2D1FC;
                21 : q_inv = 32'h102DAE18;
                22 : q_inv = 32'h181F5539;
                23 : q_inv = 32'h07FC1E61;
                24 : q_inv = 32'h141936A8;
                25 : q_inv = 32'h0BE2D3E0;
                26 : q_inv = 32'h4C2129AB;
                27 : q_inv = 32'h0C6D867A;
                28 : q_inv = 32'h4A5E2286;
                29 : q_inv = 32'h7FC37814;
                30 : q_inv = 32'h590D22A7;
                31 : q_inv = 32'h6C1B25FA;
                32 : q_inv = 32'h35CCB5F1;
                33 : q_inv = 32'h0AF4296D;
                34 : q_inv = 32'h0F5A7E20;
                35 : q_inv = 32'h55372E3D;
                36 : q_inv = 32'h5EC9046F;
                37 : q_inv = 32'h1FDC1599;
                38 : q_inv = 32'h45FEEF78;
                39 : q_inv = 32'h03618C16;
                40 : q_inv = 32'h7DA0C39B;
                41 : q_inv = 32'h7F3A9BCE;
                42 : q_inv = 32'h160D67E0;
                43 : q_inv = 32'h1F25770E;
                44 : q_inv = 32'h77A464C9;
                45 : q_inv = 32'h3C77CA8B;
                46 : q_inv = 32'h6F23D3BA;
                47 : q_inv = 32'h687FF31E;
                48 : q_inv = 32'h1D54E472;
                49 : q_inv = 32'h7D76301E;
                50 : q_inv = 32'h69872159;
                51 : q_inv = 32'h4C1064D1;
                52 : q_inv = 32'h5DC86791;
                53 : q_inv = 32'h7A9EFEA8;
                54 : q_inv = 32'h327619E8;
                55 : q_inv = 32'h5D5A993E;
                56 : q_inv = 32'h11AFBDDE;
                57 : q_inv = 32'h676D238F;
                58 : q_inv = 32'h2C5B6AAB;

                default: q_inv = 32'h5AF205C2;
            endcase
        end
    end
    
end



endmodule