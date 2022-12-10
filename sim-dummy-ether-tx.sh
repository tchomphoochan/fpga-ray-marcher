cd src
iverilog -g2012 ../src/bitorder.sv ../src/crc32.sv ../src/dummy_ether_tx.sv ../sim/dummy_ether_tx_sim.sv && vvp a.out > ../dummy-ether-tx-sim.txt
rm -f a.out dummy_ether_tx_sim.vcd
cd ..
echo "See dummy-ether-tx-sim.txt"