shader_type canvas_item;

// First wave color, adjustable via color picker in the editor
uniform vec4 water_color_1 : source_color = vec4(0.2, 0.6, 0.8, 0.5);
// Second wave color, adjustable via color picker in the editor
uniform vec4 water_color_2 : source_color = vec4(0.1, 0.5, 0.7, 0.4);
// Water level percentage, range 0.0 to 1.0, adjustable via slider in the editor
uniform float water_level_percentage : hint_range(0.0, 1.0) = 0;
// First wave frequency, controls wave density, range adjustable as needed, via slider in the editor
uniform float wave_frequency_1 : hint_range(1.0, 50.0) = 10.0;
// First wave amplitude, controls wave height, range adjustable as needed, via slider in the editor
uniform float wave_amplitude_1 : hint_range(0.0, 0.5) = 0.05;
// Second wave frequency, range adjustable as needed, via slider in the editor
uniform float wave_frequency_2 : hint_range(1.0, 50.0) = 15.0;
// Second wave amplitude, range adjustable as needed, via slider in the editor
uniform float wave_amplitude_2 : hint_range(0.0, 0.5) = 0.03;

// Simple noise function to generate random values
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth noise function to create more natural noise
float smooth_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(rand(i), rand(i + vec2(1.0, 0.0)), u.x),
        mix(rand(i + vec2(0.0, 1.0)), rand(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

// Encapsulates wave calculation logic
float calculate_wave_offset(float frequency, float amplitude, float time_multiplier, vec2 uv) {
    return sin(uv.x * frequency + TIME * time_multiplier) * amplitude;
}

// Encapsulates color blending logic
vec4 blend_water_color(vec4 base_color, vec4 water_color, float mask) {
    return mix(base_color, water_color, water_color.a * mask);
}

void fragment() {
    vec2 uv = UV;
    // Get texture color
    vec4 tex_color = texture(TEXTURE, uv);
    // Use texture alpha as mask
    float mask = tex_color.a;

    // Calculate first wave offset
    float wave_offset_1 = calculate_wave_offset(wave_frequency_1, wave_amplitude_1, 2.0, uv);
    // Calculate second wave offset
    float wave_offset_2 = calculate_wave_offset(wave_frequency_2, wave_amplitude_2, 3.0, uv);

    // Adjusted water level for first wave
    float water_level_1 = 1.0 - water_level_percentage + wave_offset_1;
    // Adjusted water level for second wave
    float water_level_2 = 1.0 - water_level_percentage + wave_offset_2;

    // Determine if below first wave water level
    bool is_below_water_1 = uv.y >= water_level_1;
    // Determine if below second wave water level
    bool is_below_water_2 = uv.y >= water_level_2;

    // Add noise and animation to simulate water flow
    vec2 noise_uv = uv * 10.0 + vec2(TIME * 0.5, 0.0);
    float noise = smooth_noise(noise_uv);
    float noise_offset = noise * 0.05;
    vec2 noisy_uv = uv + vec2(noise_offset);

    vec4 final_color = tex_color;

    if (is_below_water_1 && mask > 0.0) {
        final_color = blend_water_color(final_color, water_color_1, mask);
    }

    if (is_below_water_2 && mask > 0.0) {
        final_color = blend_water_color(final_color, water_color_2, mask);
    }

    COLOR = final_color;
}