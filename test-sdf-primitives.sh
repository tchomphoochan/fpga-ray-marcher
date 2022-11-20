cd src
iverilog -g2012 ../sim/sdf_primitives_tb.sv && vvp a.out | tee ../primitives.txt
rm -f a.out *.vcd