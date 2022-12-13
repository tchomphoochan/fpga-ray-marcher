cd src
iverilog -g2012 ../src/bitorder.sv ../src/crc32.sv ../src/ether_tx.sv ../sim/ether_tx_sim.sv && vvp a.out > ../ether-tx-sim.txt
# rm -f a.out ether_tx_sim.vcd
rm -f a.out
cd ..
echo "See ether-tx-sim.txt"