PImage img;
// int 		iteration_limit = 200;
// int 		offset = 4;
int 		iteration_limit = 1;
int 		offset = 40;
int 		iter_frame_rate = 3;
int 		normal_frame_rate = 30;
int 		block_size = 1;
float   shift_block_chance = 0.7;
float   down_chance = 0.8;
float   up_dampening = 0.4;
float   down_dampening = 1.0;

boolean   flash_selection = false;

int iteration_number = 0;
int begin_x = 0;
int begin_y = 0;
int end_x = 0;
int end_y = 0;
boolean mod_mode = false;
ArrayList<PShape> points;
PShape s;


void settings() {
	img = loadImage("../love.jpg");
	// img = loadImage("../almost-drone-hit.jpg");
	size(img.width, img.height);
}

void setup() {
	noFill();
	stroke(255);
	begin_x = round(img.width / 4);
	begin_y = round(img.height / 3);
	end_x = begin_x*3;
	end_y = begin_y*2;
	image(img, 0, 0);
	frameRate(normal_frame_rate);
	points = new ArrayList<PShape>();
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

			println("clicked aaat x: " + mx +" y: "+ my);
		}
	}else{
		points.clear();
		image(img, 0, 0);


		frameRate(iter_frame_rate);
		// && !list_init
		//  NOT someList.Length == 0
		// iterate over all points, find those in poly and build a list

		// if(mod_mode && iteration_number < iteration_limit){
		// 	img.loadPixels();
		// 	iterateColBlocks();
		// 	img.updatePixels();
		// 	image(img, 0, 0);
		// 	iteration_number++;
		// }
	}

	if (keyPressed) {
		frameRate(normal_frame_rate);
		iteration_number =0;
		mod_mode = true;
		s = createShape();
		s.beginShape();
		s.noStroke();
		for(PShape a_point : points){
			PVector a_point_coord = a_point.getVertex(0);
			s.vertex(a_point_coord.x, a_point_coord.y);
		}
		if(flash_selection)
			s.fill(0, 0, 255);
		s.endShape(CLOSE);
		shape(s, 0, 0);
	}

}

void iterateColBlocks(){
	for(int count = begin_x; count < end_x-block_size; count=count+block_size){
		if(random(1) < shift_block_chance){
			if(random(1) > down_chance){
				shiftUpBlock(count);
			}else{
				shiftDownBlock(count);
			}
		}
	}
}

void shiftUpBlock(int count_mess){
	int rand_offset = round(random(offset)* up_dampening);
	for(int x = count_mess; x < count_mess+block_size; x++){
		for(int y = begin_y-rand_offset; y < end_y+rand_offset; y++){
			img.pixels[x + (y-rand_offset) * img.width] =
				img.pixels[x + y * img.width];
		}
	}
}

void shiftDownBlock(int count_mess){
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
