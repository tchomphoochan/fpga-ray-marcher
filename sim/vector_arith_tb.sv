`timescale 1ns / 1ps
`default_nettype none

`include "vector_arith.svh"

module vector_arith_tb;

  real tolerance, ax, ay, az, bx, by, bz, cx, cy, cz, dv;
  fp d;
  vec3 a, b, c;

  logic all_passed = 1;
  logic passed;

  initial begin
    $dumpfile("vector_arith.vcd");
    $dumpvars(0, vector_arith_tb);
    $display("Starting Sim");

    tolerance = 1e-4;

    // negation works
    ax = 0.420; ay = -0.691; az = 0.2;
    cx = -ax; cy = -ay; cz = -az;
    a = vec3_from_reals(ax, ay, az);
    c = vec3_neg(a);
    $display("Expected: -a = (%f,%f,%f)", cx,cy,cz);
    $display("Actual: -a = %s", vec3_to_str(c));
    passed = $abs(cx - fp_to_real(c.x)) < tolerance
            && $abs(cy - fp_to_real(c.y)) < tolerance
            && $abs(cz - fp_to_real(c.z)) < tolerance;
    all_passed = all_passed & passed;
    $display("%s\n", passed ? "PASSED" : "FAILED");

    // binary operation (e.g. addition) works
    ax = 0.420; ay = -0.691; az = 0.2;
    bx = -0.420; by = 0.420; bz = 0.5;
    cx = ax+bx; cy = ay+by; cz = az+bz;
    a = vec3_from_reals(ax, ay, az);
    b = vec3_from_reals(bx, by, bz);
    c = vec3_add(a,b);
    $display("Expected: a+b = (%f,%f,%f)", cx,cy,cz);
    $display("Actual: a+b = %s", vec3_to_str(c));
    passed = $abs(cx - fp_to_real(c.x)) < tolerance
            && $abs(cy - fp_to_real(c.y)) < tolerance
            && $abs(cz - fp_to_real(c.z)) < tolerance;
    all_passed = all_passed & passed;
    $display("%s\n", passed ? "PASSED" : "FAILED");

    // dot product works
    ax = 0.420; ay = -0.691; az = 0.2;
    bx = -0.420; by = 0.420; bz = 0.5;
    dv = ax*bx + ay*by + az*bz;
    a = vec3_from_reals(ax, ay, az);
    b = vec3_from_reals(bx, by, bz);
    d = vec3_dot(a, b);
    $display("Expected: a dot b = %f", dv);
    $display("Actual: a+b = %f", fp_to_real(d));
    passed = $abs(dv - fp_to_real(d)) < tolerance;
    all_passed = all_passed & passed;
    $display("%s\n", passed ? "PASSED" : "FAILED");

    tolerance = 1e-2;

    // vector normalization works
    ax = 0.420; ay = -0.691; az = 0.2;
    dv = $sqrt(ax*ax + ay*ay + az*az);
    cx = ax/dv; cy = ay/dv; cz = az/dv;
    a = vec3_from_reals(ax, ay, az);
    c = vec3_normed(a);
    $display("Expected: norm(a) = (%f,%f,%f)", cx,cy,cz);
    $display("Actual: norm(a) = %s", vec3_to_str(c));
    passed = $abs(cx - fp_to_real(c.x)) < tolerance
            && $abs(cy - fp_to_real(c.y)) < tolerance
            && $abs(cz - fp_to_real(c.z)) < tolerance;
    all_passed = all_passed & passed;
    $display("%s\n", passed ? "PASSED" : "FAILED");

    // vector normalization works (another one)
    ax = 0.39; ay = 0.01; az = 0.52;
    dv = $sqrt(ax*ax + ay*ay + az*az);
    cx = ax/dv; cy = ay/dv; cz = az/dv;
    a = vec3_from_reals(ax, ay, az);
    c = vec3_normed(a);
    $display("Expected: norm(a) = (%f,%f,%f)", cx,cy,cz);
    $display("Actual: norm(a) = %s", vec3_to_str(c));
    passed = $abs(cx - fp_to_real(c.x)) < tolerance
            && $abs(cy - fp_to_real(c.y)) < tolerance
            && $abs(cz - fp_to_real(c.z)) < tolerance;
    all_passed = all_passed & passed;
    $display("%s\n", passed ? "PASSED" : "FAILED");

    // vector normalization works (another one)
    ax = 2.5; ay = 0.91; az = 1.8;
    dv = $sqrt(ax*ax + ay*ay + az*az);
    cx = ax/dv; cy = ay/dv; cz = az/dv;
    a = vec3_from_reals(ax, ay, az);
    c = vec3_normed(a);
    $display("Expected: norm(a) = (%f,%f,%f)", cx,cy,cz);
    $display("Actual: norm(a) = %s", vec3_to_str(c));
    passed = $abs(cx - fp_to_real(c.x)) < tolerance
            && $abs(cy - fp_to_real(c.y)) < tolerance
            && $abs(cz - fp_to_real(c.z)) < tolerance;
    all_passed = all_passed & passed;
    $display("%s\n", passed ? "PASSED" : "FAILED");

    $display("%s", all_passed ? "ALL PASSED": "SOME FAILED");
    $display("Finishing Sim");
    $finish;
  end
endmodule // vector_arith_tb

`default_nettype wire
