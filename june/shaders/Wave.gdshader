// Made by PWira
// MIT License
shader_type canvas_item;

// Liquid Property
uniform float liquid_level : hint_range(0.0, 1.0) = 0.5;
uniform vec4 liquid_color : source_color = vec4(0.2, 0.5, 1.0, 0.8);
uniform vec4 foam_color : source_color = vec4(0.8, 0.9, 1.0, 0.6);

// Wave property
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 20.0) = 5.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;

// Gravity property
uniform float gravity_angle : hint_range(-3.14159, 3.14159) = 0.0; // rotate in radian
uniform vec2 gravity_direction = vec2(0.0, 1.0);

// Visual property
uniform float foam_thickness : hint_range(0.0, 0.1) = 0.02;
uniform float shine_intensity : hint_range(0.0, 1.0) = 0.3;
uniform bool add_bubble = true;
uniform float bubble_scale : hint_range(0.0, 50.0) = 10.0;
uniform float bubble_speed : hint_range(0.0, 2.0) = 0.5;

// Simple Noise
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec2 rotate(vec2 v, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void fragment() {
    vec2 uv = UV;
    vec2 centered_uv = uv - 0.5;
    vec2 rotated_uv = rotate(centered_uv, -gravity_angle);
    rotated_uv += 0.5;

    // Wave based on X in gravity coordinate
    float wave = sin(rotated_uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
    float surface_y = (1.0 - liquid_level) + wave;


    if (rotated_uv.y > surface_y) {

        vec4 base_color = liquid_color;

        float internal_wave = noise(vec2(rotated_uv.x * 3.0, rotated_uv.y * 3.0 + TIME * 0.5)) * 0.1;
        base_color.rgb += vec3(internal_wave);


		if (add_bubble){
			vec2 bubble_uv = rotated_uv * bubble_scale;
	        bubble_uv.y += TIME * bubble_speed;
	        float bubble_noise = noise(bubble_uv);
	        float bubbles = step(0.95, bubble_noise);
	        base_color.rgb += vec3(bubbles * 0.3);
		}

        float shine = pow(1.0 - abs(uv.x - 0.5) * 2.0, 3.0) * shine_intensity;
        base_color.rgb += vec3(shine);

        float depth_factor = 1.0 - (rotated_uv.y - surface_y) / (1.0 - surface_y);
        base_color.rgb *= 0.7 + depth_factor * 0.3;

        COLOR = base_color;

    } else if (rotated_uv.y > surface_y - foam_thickness) {

        float foam_factor = (surface_y - rotated_uv.y) / foam_thickness;
        float foam_noise = noise(vec2(rotated_uv.x * 20.0, TIME * 2.0));
        foam_factor *= foam_noise;

        vec4 final_foam = mix(liquid_color, foam_color, foam_factor);
        COLOR = final_foam;

    } else {

        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}