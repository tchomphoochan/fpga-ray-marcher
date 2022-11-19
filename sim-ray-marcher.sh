cd src
iverilog -g2012 ../src/ray_unit.sv ../src/ray_marcher.sv ../sim/full_ray_marcher_sim.sv && vvp a.out | grep "CMD" > ../full-ray-marcher-sim.txt
rm -f a.out full_ray_marcher_sim.vcd
cd ..
echo "See full-ray-marcher-sim.txt"