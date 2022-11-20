`default_nettype none
`timescale 1ns / 1ps

/*
uint32_t hsl2rgb(uint8_t h, uint8_t s, uint8_t l) {
    uint8_t  r, g, b, lo, c, x, m;
    uint16_t h1, l1, H;
    l1 = l + 1;
    if (l < 128) {
        c = ((l1<<1) * s) >> 8;
    }
    else {
        c = (512 - (l1<<1)) * s >> 8;
    }

    H = h*6; // 0 to 1535 (actually 1530)
    lo = H & 255;          // Low byte  = primary/secondary color mix
    h1 = lo + 1;
    if ((H & 256) == 0) { // even sextant, like red to yellow
        x = h1 * c >> 8;
    }
    else { // odd sextant, like yellow to green
        x = (256 - h1) * c >> 8;
    }
    m = l - (c >> 1);
    switch(H >> 8) {       // High byte = sextant of colorwheel
        case 0 : r = c  ; g = x  ; b = 0  ; break; // R to Y
        case 1 : r = x  ; g = c  ; b = 0  ; break; // Y to G
        case 2 : r = 0  ; g = c  ; b = x  ; break; // G to C
        case 3 : r = 0  ; g = x  ; b = c  ; break; // C to B
        case 4 : r = x  ; g = 0  ; b = c  ; break; // B to M
        default: r = c  ; g = 0  ; b = x  ; break; // M to R
    }

    return r+m<<16 | g+m<<8 | b+m;
}
*/
function automatic [7:0][2:0] rgb2rgb(input [7:0] h, input [7:0] s, input [7:0] l);
    return {h, s, l};
endfunction
function automatic [7:0][2:0] hsl2rgb(input [7:0] h, input [7:0] s, input [7:0] l);
    logic [7:0] r, g, b, lo, c, x, m;
    logic [15:0] h1, l1, Hh;
    l1 = l + 1;
    c = (l1 < 128) ? ((l1<<1) * s) >> 8 : (512 - (l1<<1)) * s >> 8;
    Hh = h*6; // 0 to 1535 (actually 1530)
    lo = Hh[7:0];          // Low byte  = primary/secondary color mix
    h1 = lo + 1;
    x = (Hh[8] == 0) ? h1 * c >> 8 : (256 - h1) * c >> 8;
    m = l - (c >> 1);
    r = (Hh[9:8] == 0) ? c : (Hh[9:8] == 4) ? x : 0;
    g = (Hh[9:8] == 1) ? c : (Hh[9:8] == 2) ? x : 0;
    b = (Hh[9:8] == 3) ? c : (Hh[9:8] == 4) ? c : x;
    return {r+m, g+m, b+m};
endfunction

`default_nettype wire