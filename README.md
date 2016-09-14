# pixel-sort
Not actually though, just shifts lines of pixels up and down randomly after you
draw an area to shift about in. Also allows for multiple iterations of shifting.

## Output
From
![](/input/github-logo.png)
To
![](/out/out/outting-002468.png)

## Using
1. Use the config to edit values, see end of readme for details on that.
2. Run it using commands under Running section
3. Draw a shape
	- You can hold down to draw a series of points or just click for each vertex
	- If no shape drawn it will use the previous one
4. Hit any key other than q
	- Hit q to save image in out and stay at this stage
5. Watch it melt
6. Goto 3

## Running
If you have processing installed as a system package you can simply do:
```
make run
```
If you have installed processing to a custom location you can instead do:
```
make run processing-bin=/path/to/processing-java
```
<sub> <sub> Lovingly taken from preda-prey </sub></sub>


## Configuration
The sketch looks for a `config.json` file in the directory that it is run from
and will load values if they are present.
All configurable values are optional and have sensible defaults which will be
loaded unless overriden.
Colors are specified as string representation of hex codes with the first
digit being the alpha channel and the following digits the standard RGB
values.

**iteration_limit** (__Integers__):
How many iterations of melting per key press

**iter_frame_rate** and **normal_frame_rate** (__Integers__):
How frequently to redraw the screen when drawing and when the computer is
melting

**shift_block_chance** and **down_chance** (__Float__):
Chance of a line in a block being shifted and the chance that the direction of
that block will be down

**offset_scaler** and **up_dampening** and **down_dampening**  (__Float__):
Shifting is calculated by the length of the inputted line, but can be adjusted
by `offset_scaler`, and up and down dampening just allow for reduction of the
amount each line will be moved by.

**image_file** (__String__):
Input image to mess with.

**save_file_name** and **save_file_type** (__String__):
Says what file type and filename you will have for your saved frames when you
hit `q`.

**flash_selection** (__Boolean__):
Flashes up the slected shape before melting. Used to see what you are shifting.
