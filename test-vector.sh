cd src
iverilog -g2012 ../sim/vector_arith_tb.sv && vvp a.out | tee ../vector.txt
rm -f a.out *.vcd