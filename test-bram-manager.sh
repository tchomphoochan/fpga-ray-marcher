cd src
iverilog -g2012 ../src/bram_manager.sv ../src/xilinx_true_dual_port_read_first_1_clock_ram.v ../sim/bram_manager_tb.sv && ./a.out | tee ../bram_manager.txt
rm -f a.out *.vcd