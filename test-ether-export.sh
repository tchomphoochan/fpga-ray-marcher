cd src
iverilog -g2012 ../src/xilinx_true_dual_port_read_first_1_clock_ram.v ../src/bitorder.sv ../src/crc32.sv ../src/bram_manager.sv ../src/ether_tx.sv ../src/ether_export.sv ../sim/ether_export_test.sv && vvp a.out > ../ether-export-test.txt
# rm -f a.out ether_export_test.vcd
rm -f a.out
cd ..
echo "See ether-export-test.txt"