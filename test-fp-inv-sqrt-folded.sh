cd src
iverilog -g2012 ../src/fp_inv_sqrt_folded.sv  ../sim/fp_inv_sqrt_folded_tb.sv && vvp a.out | tee ../fp-inv-sqrt-folded.txt
rm -f a.out *.vcd
cd ..