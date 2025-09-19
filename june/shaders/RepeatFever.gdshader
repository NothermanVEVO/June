shader_type canvas_item;

uniform bool direction_up = true;
uniform float speed = 0.5;

uniform float seed;
uniform float randomness = 0.5;

varying vec4 v_color;

void vertex() {
	// guarda a cor do vértice/modulate
	v_color = COLOR;

	if (direction_up) {
		UV.y += TIME * speed;
	} else {
		UV.y -= TIME * speed;
	}
}

void fragment() {
	vec2 uv = UV;
	uv.y += seed * randomness;
	
	vec4 tex = texture(TEXTURE, uv);
	
	COLOR = tex * v_color;
}
