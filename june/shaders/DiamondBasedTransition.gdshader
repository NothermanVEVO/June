shader_type canvas_item;

uniform float progress : hint_range(0, 1);
uniform float diamondPixelSize = 10.0;
uniform bool invert = false;

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);

	// Direção padrão (canto inferior direito → canto superior esquerdo)
	float dir = UV.x + UV.y;

	// Direção invertida (canto superior esquerdo → canto inferior direito)
	if (invert) {
		dir = (1.0 - UV.x) + (1.0 - UV.y);
	}

	if (xDistance + yDistance + dir > progress * 3.0) {
		discard;
	}
}
