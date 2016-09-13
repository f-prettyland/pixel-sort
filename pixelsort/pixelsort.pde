PImage img;
// int 		iteration_limit = 200;
// int 		offset = 4;
int 		iteration_limit = 1;
int 		offset = 40;
int 		iter_frame_rate = 3;
int 		normal_frame_rate = 30;
int 		block_size = 1;
float   shift_block_chance = 0.2;
float   down_chance = 1;
float   up_dampening = 0.4;
float   down_dampening = 1.0;
float unit = 100;

boolean   flash_selection = false;

int iteration_number = 0;
int begin_x = 0;
int begin_y = 0;
int end_x = 0;
int end_y = 0;
boolean mod_mode = false;
boolean marked_pips = false;
ArrayList<PShape> points = new ArrayList<PShape>();;
ArrayList<ArrayList<PVector>> lines =  new ArrayList<ArrayList<PVector>>();
PShape s;
boolean pip[][];


void settings() {
	img = loadImage("../love.jpg");
	// img = loadImage("../almost-drone-hit.jpg");
	size(img.width, img.height);
}

void setup() {
	noFill();
	stroke(255);
	image(img, 0, 0);
	frameRate(normal_frame_rate);
	pip = new boolean[width][height];
}

void draw() {
	// rect(begin_x,begin_y,end_x-begin_x,end_y-begin_y);

	if(!mod_mode ){
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

		frameRate(iter_frame_rate);

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

		// && !list_init
		//  NOT someList.Length == 0
		// iterate over all points, find those in poly and build a list

		if(mod_mode && iteration_number < iteration_limit){
			img.loadPixels();
			iterateColBlocks();
			img.updatePixels();
			image(img, 0, 0);
			iteration_number++;
		}else{
			mod_mode = false;
			frameRate(normal_frame_rate);
		}

	}

	if (keyPressed) {
		frameRate(normal_frame_rate);
		iteration_number =0;
		mod_mode = true;
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
		if(flash_selection)
			s.fill(0, 0, 0);
		s.endShape(CLOSE);
		shape(s, 0, 0);
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
	// for(int count = begin_x; count < end_x-block_size; count=count+block_size){
	for(ArrayList<PVector> line : lines){
		if(random(1) < shift_block_chance){
			int rand_offset = round(random(offset) * down_dampening);
			if(random(1) > down_chance){
				rand_offset = round(random(offset)* up_dampening);
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

void shiftUpBlock(int count_mess, int begin_y){
	int rand_offset = round(random(offset)* up_dampening);
	for(int x = count_mess; x < count_mess+block_size; x++){
		for(int y = begin_y-rand_offset; y < end_y+rand_offset; y++){
			img.pixels[x + (y-rand_offset) * img.width] =
				img.pixels[x + y * img.width];
		}
	}
}

void shiftDownBlock(int count_mess, int begin_y){
	int rand_offset = round(random(offset) * down_dampening);
	for(int x = count_mess; x < count_mess+block_size; x++){
		for(int y = end_y+rand_offset; y > begin_y+rand_offset; y--){
			img.pixels[x + (y+rand_offset) * img.width] =
				img.pixels[x + y * img.width];
		}
	}
}

void drawSomeNoooooise() {
	float noiseScale = 0.02;
	for (int x=0; x < width; x++) {
		for (int y=0; y < width; y++) {
			float noiseVal = noise(x*noiseScale, y*noiseScale);
			stroke(noiseVal*255);
			point(x,y);
		}
	}
}

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
