shader_type canvas_item;

uniform bool direction_up = true;
uniform float speed = 0.5;

uniform float seed;
uniform float randomness = 0.5;

varying vec4 v_color;

void vertex() {
	v_color = COLOR;

	UV.y += TIME * speed;
	UV.x += TIME * speed;
}

void fragment() {
	vec2 uv = UV;
	vec4 tex = texture(TEXTURE, uv);
	
	COLOR = tex * v_color;
}
