cd src
iverilog -g2012 ../src/ray_unit.sv ../src/ray_marcher.sv ../sim/full_ray_marcher_sim.sv && vvp a.out > ../full-ray-marcher-sim.txt
rm -f a.out full_ray_marcher_sim.vcd
cd ..
echo "See full-ray-marcher-sim.txt"
python3 scripts/txt_to_img.py full-ray-marcher-sim.txt