#!/usr/bin/env python3

# written by 6.205 staff

import sys
from PIL import Image, ImageOps

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: {0} <image to convert> [mode] [colors]".format(sys.argv[0])) # modified

    else:
        input_fname = sys.argv[1]
        mode = sys.argv[2] if 2 < len(sys.argv) else "RGB"
        num_colors_out = int(sys.argv[3] if 3 < len(sys.argv) else "256") # modified

        image_in = Image.open(input_fname)
        image_in = image_in.convert(mode, dither=True)

        w, h = image_in.size
        print(f'Reducing {input_fname} of size {w}x{h} to {num_colors_out} unique colors.')

        # Take input image
        # modified: don't divide each color channel's value by 16
        image_out = image_in.copy()
        W = 400
        H = 300
        image_out = image_out.resize((W,H))

        # Palettize the image
        image_out = image_out.convert(mode='P', palette=1, colors=num_colors_out, dither=True)
        palette = image_out.getpalette()
        rgb_tuples = [tuple(palette[i:i+3]) for i in range(0, 3*num_colors_out, 3)]

        # Save pallete
        # with open(f'palette.mem', 'w') as f:
        #     f.write( '\n'.join( [f'{r:01x}{g:01x}{b:01x}' for r, g, b in rgb_tuples] ) )

        # print('Output image pallete saved at palette.mem')

        # # Save the image itself
        # with open(f'image.mem', 'w') as f:
        #     for y in range(h):
        #         for x in range(w):
        #             f.write(f'{image_out.getpixel((x,y)):02x}\n')

        # print('Output image saved at image.mem')
        image_out.save("image_preview.png");

        # Save the image itself
        image_raw = image_out.convert(mode='L', dither=True)
        with open(f'image.mem', 'w') as f:
            for y in range(H):
                for x in range(W):
                    # f.write(f'{image_raw.getpixel((x,y)):02x}\n')
                    f.write(f'{(image_raw.getpixel((x,y))//16):01x}\n')
        print('Output image saved at image.mem')
        image_raw.save("image.png");
