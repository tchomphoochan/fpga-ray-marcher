cd src
iverilog -g2012 ../src/ray_unit.sv ../src/ray_marcher.sv ../sim/full_ray_marcher_sim.sv
vvp a.out | findstr "CMD" > ../full-ray-marcher-sim.txt
cd ..
echo "See full-ray-marcher-sim.txt"
python scripts/txt_to_img.py full-ray-marcher-sim.txt