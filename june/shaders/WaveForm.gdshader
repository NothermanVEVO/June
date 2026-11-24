shader_type canvas_item;

uniform vec4 wave_color : source_color = vec4(0.35, 0.9, 1.0, 1.0);
uniform float hover : hint_range(0.0, 1.0) = 0.0;

const float BAR_COUNT = 64.0;

float hash(float n) {
	return fract(sin(n * 127.1) * 43758.5453);
}

void fragment() {
	float id = floor(UV.x * BAR_COUNT);
	float local_x = fract(UV.x * BAR_COUNT);

	// Espaçamento entre as barras
	float bar_width = smoothstep(0.05, 0.15, local_x)
		* (1.0 - smoothstep(0.85, 0.95, local_x));

	// Variação individual de cada barra
	float random_height = hash(id);

	float movement = sin(TIME * 2.0 + id * 0.35) * 0.5 + 0.5;
	float movement2 = sin(TIME * 1.3 - id * 0.19) * 0.5 + 0.5;

	// Altura no idle
	float idle_height = 0.025 + random_height * 0.035;

	// Altura no hover
	float hover_height = 0.08 + random_height * 0.18 + movement * 0.12 + movement2 * 0.08;

	float height = mix(idle_height, hover_height, hover);

	// Barras simétricas verticalmente
	float distance_from_center = abs(UV.y - 0.5);

	float bar = 1.0 - smoothstep(
		height - 0.005,
		height + 0.005,
		distance_from_center
	);

	// Intensidade
	float alpha = bar * bar_width;
	alpha *= mix(0.15, 0.8, hover);

	// Cor e brilho
	vec3 color = wave_color.rgb * (1.0 + hover * 0.5);

	COLOR = vec4(color, alpha * wave_color.a);
}