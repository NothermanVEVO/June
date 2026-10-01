shader_type canvas_item;

uniform float horizontal = 0.0;
uniform float vertical = 1.0;
uniform float speed = 0.5;

varying vec4 v_color;

void vertex() {
	v_color = COLOR;

	UV.x += horizontal * TIME * speed;
	UV.y += vertical * TIME * speed;
}

void fragment() {
	vec2 uv = UV;
	vec4 tex = texture(TEXTURE, uv);

	COLOR = tex * v_color;
}