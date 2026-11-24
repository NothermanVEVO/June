shader_type canvas_item;

uniform float skew : hint_range(-1.0, 1.0) = 0.25;

void vertex() {
	VERTEX.x -= VERTEX.y * skew;
}