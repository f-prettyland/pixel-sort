PImage img;
int 		some_limit = 300;
int 		iteration_limit = 1;
int 		block_size = 1;
int 		offset = 30;
float   mutation_chance = 0.4;

int iteration_number = 0;
int begin_x = 0;
int begin_y = 0;
int end_x = 0;
int end_y = 0;


void settings() {
	img = loadImage("../love.jpg");
	// img = loadImage("../almost-drone-hit.jpg");
	size(img.width, img.height);
}

void setup() {
	noFill();
	stroke(255);
	frameRate(10);
	begin_x = img.width / 3;
	begin_y = img.height / 3;
	end_x = begin_x*2;
	end_y = begin_y*2;
}

void draw() {

	if(iteration_number < iteration_limit){
		img.loadPixels();
		iterateColBlocks();
		img.updatePixels();
		image(img, 0, 0);
		iteration_number++;
	}

	if (mousePressed) {
		int mx = constrain(mouseX, 0, img.width-1);
		int my = constrain(mouseY, 0, img.height-1);
		println("clicked aaat x: " + mx +" y: "+ my);
	}

}

void iterateColBlocks(){
	for(int count = begin_x; count < end_x-block_size; count=count+block_size){
		if(random(1) < mutation_chance){
			println("shiiifting aaat x: " + count);
			shiftUpBlock(count);
		}
	}
}

void shiftUpBlock(int count_mess){
	for(int x = count_mess; x < count_mess+block_size; x++){
		for(int y = end_y+offset; y > begin_y+offset; y--){
			img.pixels[x + (y+offset) * img.width] = img.pixels[x + y * img.width];
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
