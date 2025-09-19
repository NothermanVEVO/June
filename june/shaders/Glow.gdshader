shader_type canvas_item;

uniform sampler2D t0 : hint_screen_texture;
uniform float glow_size = .5;
uniform vec3 glow_colour : source_color = vec3(0, 0, 0);
uniform float color_intensity :hint_range(0.0, 1.0, 0.01) = .5;
uniform float glow_intensity = .5;
uniform float glow_threshold = .5;

void fragment() {
    COLOR = texture(t0, SCREEN_UV);
    if (length(COLOR) >= glow_threshold) {
        ivec2 size = textureSize(t0, 0);
	
        float uv_x = SCREEN_UV.x * float(size.x);
        float uv_y = SCREEN_UV.y * float(size.y);

        vec4 sum = vec4(0.0);
        for (int n = 0; n < 9; ++n) {
            uv_y = (SCREEN_UV.y * float(size.y)) + (glow_size * (float(n) - 4.5));
            vec4 h_sum = vec4(0.0);
            h_sum += texelFetch(t0, ivec2(int(uv_x) -  int(4.0 * glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) -  int(3.0 * glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) -  int(2.0 * glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) - int(glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) + int(glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) + int(2.0 * glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) + int(3.0 * glow_size), int(uv_y)), 0).a;
            h_sum += texelFetch(t0, ivec2(int(uv_x) + int(4.0 * glow_size), int(uv_y)), 0).a;
            sum += h_sum / 9.0;
        }

    	COLOR = texture(t0, SCREEN_UV) + ((sum / 9.0) * glow_intensity);
	COLOR = mix(COLOR, vec4(glow_colour, 1.0), color_intensity);
    }
	
	
}