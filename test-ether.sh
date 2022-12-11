cd src
iverilog -g2012 ../src/bitorder.sv ../src/crc32.sv ../src/cksum.sv ../src/ether_tx.sv ../src/aggregate.sv ../src/firewall.sv ../src/ether_rx.sv ../src/ether_rx_driver.sv ../sim/ether_full_test.sv && vvp a.out > ../ether-full-test.txt
rm -f a.out ether_full_test.vcd
cd ..
echo "See ether-full-test.txt"