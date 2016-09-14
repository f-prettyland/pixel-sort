static final String   DEFAULT_CONFIG_FILE_PATH    = "config.json";

PImage img;
int iteration_number = 0;
boolean melt_mode = false;
boolean marked_pips = false;
ArrayList<PShape> points = new ArrayList<PShape>();;
ArrayList<ArrayList<PVector>> lines =  new ArrayList<ArrayList<PVector>>();
float unit = 100;
PShape s;
boolean pip[][];
Config global_config;

/**
 * Stores the current configuration state of the application.
 */
class Config {
	// int 		iteration_limit = 200;
	// int 		offset_scaler = 0.01;
	int 		iteration_limit = 1;
	float 	offset_scaler = 1.2;
	int 		iter_frame_rate = 3;
	int 		normal_frame_rate = 30;
	float   shift_block_chance = 0.2;
	float   down_chance = 0.8;
	float   up_dampening = 0.5;
	float   down_dampening = 1.0;
	String 	save_file_name = "../out/outting";
	String 	save_file_type = ".png";
	String 	image_file = "../input/github-logo.png";
	// String 	image_file = "../input/love.jpg";
	// String 	image_file = "../input/almost-drone-hit.jpg";
	boolean   flash_selection = false;

	/**
	 * Attempt to load configuration values from a JSON file.
	 *
	 * @param path Path to the configuration file.
	 */
	boolean load_from_file(String path) {
		File config_file = new File(path);

		JSONObject json = loadJSONObject(path);

		this.iteration_limit = json.getInt("iteration_limit", this.iteration_limit);
		this.offset_scaler = json.getFloat("offset_scaler", this.offset_scaler);
		this.iter_frame_rate = json.getInt("iter_frame_rate", this.iter_frame_rate);
		this.normal_frame_rate =
			json.getInt("normal_frame_rate", this.normal_frame_rate);
		this.shift_block_chance =
			json.getFloat("shift_block_chance", this.shift_block_chance);
		this.down_chance = json.getFloat("down_chance", this.down_chance);
		this.up_dampening = json.getFloat("up_dampening", this.up_dampening);
		this.down_dampening = json.getFloat("down_dampening", this.down_dampening);

		this.save_file_name = json.getString("save_file_name", this.save_file_name);
		this.save_file_type = json.getString("save_file_type", this.save_file_type);
		this.image_file = json.getString("image_file", this.image_file);

		this.flash_selection =
			json.getBoolean("flash_selection", this.flash_selection);

		return true;
	}
}


void settings() {
	global_config = new Config();

	global_config.load_from_file(DEFAULT_CONFIG_FILE_PATH);

	img = loadImage(global_config.image_file);
	size(img.width, img.height);
}

void setup() {
	noFill();
	stroke(255);
	image(img, 0, 0);
	frameRate(global_config.normal_frame_rate);
	pip = new boolean[width][height];
}

void draw() {
	// if user drawing stuff
	if(!melt_mode){
		if (mousePressed) {
			int mx = constrain(mouseX, 0, img.width-1);
			int my = constrain(mouseY, 0, img.height-1);

			PShape new_point = createShape();
			new_point.beginShape();
			new_point.vertex(mx,my);
			new_point.endShape(CLOSE);
			points.add(new_point);
			shape(points.get(points.size()-1), 0,0);
		}
	}else{
		points.clear();
		image(img, 0, 0);

		frameRate(global_config.iter_frame_rate);

		// Figures out what pixels are in the shape and of these, which are in line
		if (!marked_pips) {
			for (int x = 0; x < (width); x++) {
				for (int y = 0; y < (height); y++) {
					if(!pip[x][y] && pixelInPoly(x, y)){
						pip[x][y] = true;
						lines.add(new ArrayList<PVector>());
						checkColBeneath(x, y, lines.size()-1);
					}
				}
			}
			marked_pips = true;
		}

		// iterate over lines in the
		if(melt_mode && iteration_number < global_config.iteration_limit){
			img.loadPixels();
			iterateColBlocks();
			img.updatePixels();
			image(img, 0, 0);
			iteration_number++;
		}else{
			melt_mode = false;
			frameRate(global_config.normal_frame_rate);
		}

	}

	// Draw the shape the user input and set correct flags to begin melt
	//   unless it was q, then just save it
	if (keyPressed) {
		if (key == 'q')
		{
			saveFrame(global_config.save_file_name + "-######"
				+ global_config.save_file_type);
		}else{
			frameRate(global_config.normal_frame_rate);
			iteration_number =0;
			melt_mode = true;
			if(points.size()>0){
				marked_pips = false;
				pip = new boolean[width][height];
				lines.clear();
			}
			s = createShape();
			s.beginShape();
			s.noStroke();
			for(PShape a_point : points){
				PVector a_point_coord = a_point.getVertex(0);
				s.vertex(a_point_coord.x, a_point_coord.y);
			}
			if(global_config.flash_selection)
				s.fill(0, 0, 0);
			s.endShape(CLOSE);
			shape(s, 0, 0);
		}
	}

}

void checkColBeneath(int start_x, int start_y, int lines_index){
	lines.get(lines_index).add(new PVector(start_x, start_y));
	for(int y = start_y+1; y < height; y++){
		if(!pip[start_x][y] &&  pixelInPoly(start_x,y)){
			pip[start_x][y] = true;
			lines.get(lines_index).add(new PVector(start_x, y));
		}else{
			return;
		}
	}
}


void iterateColBlocks(){
	for(ArrayList<PVector> line : lines){
		if(random(1) < global_config.shift_block_chance){
			int rand_offset = round(
				random(line.size()) *
				global_config.offset_scaler  *
				global_config.down_dampening
			);
			if(random(1) > global_config.down_chance){
				rand_offset = (-1)*round(
					random(line.size()) *
					global_config.offset_scaler *
					global_config.up_dampening
				);
			}
			for(PVector pix : line){
				int x = (int) pix.x;
				int y = (int) pix.y;
				int y_to_pinch_from = constrain((y+rand_offset), 0, img.height-1);
				img.pixels[x + y_to_pinch_from * img.width] =
					img.pixels[x + y * img.width];
			}
		}
	}
}

// ------- DEPRICATED -------
// old methods of shifting by pixels in given range

// void shiftUpBlock(int count_mess, int begin_y){
// 	int rand_offset = round(random(offset)* up_dampening);
// 	for(int x = count_mess; x < count_mess+block_size; x++){
// 		for(int y = begin_y-rand_offset; y < end_y+rand_offset; y++){
// 			img.pixels[x + (y-rand_offset) * img.width] =
// 				img.pixels[x + y * img.width];
// 		}
// 	}
// }
//
// void shiftDownBlock(int count_mess, int begin_y){
// 	int rand_offset = round(random(offset) * down_dampening);
// 	for(int x = count_mess; x < count_mess+block_size; x++){
// 		for(int y = end_y+rand_offset; y > begin_y+rand_offset; y--){
// 			img.pixels[x + (y+rand_offset) * img.width] =
// 				img.pixels[x + y * img.width];
// 		}
// 	}
// }
//
// void drawSomeNoooooise() {
// 	float noiseScale = 0.02;
// 	for (int x=0; x < width; x++) {
// 		for (int y=0; y < width; y++) {
// 			float noiseVal = noise(x*noiseScale, y*noiseScale);
// 			stroke(noiseVal*255);
// 			point(x,y);
// 		}
// 	}
// }

// Algorithm taken with love from
//  http://forum.processing.org/topic/how-do-i-find-if-a-point-is-inside-a-complex-polygon.html
boolean pixelInPoly(int x, int y) {
	int i, j;
	boolean c=false;
	int sides = s.getVertexCount();
	for (i=0,j=sides-1;i<sides;j=i++) {
		if (( ((s.getVertex(i).y <= y) && (y < s.getVertex(j).y)) ||
					((s.getVertex(j).y <= y) && (y < s.getVertex(i).y))) &&
					(
						(x < (s.getVertex(j).x - s.getVertex(i).x) *
						(y - s.getVertex(i).y) /
						(s.getVertex(j).y - s.getVertex(i).y) + s.getVertex(i).x)
					)
				)
		{
			c = !c;
		}
	}
	return c;
}
