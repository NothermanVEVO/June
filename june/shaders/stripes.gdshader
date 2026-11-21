
shader_type canvas_item;

uniform float line_width : hint_range(0.001, 1.0) = 0.2;
uniform float spacing : hint_range(0.001, 2.0) = 0.2;
uniform float angle : hint_range(0.0, 360.0) = 45.0;
uniform float time_per_cycle : hint_range(0.1, 30.0) = 8.0;

uniform vec4 line_color : source_color = vec4(0.75, 0.75, 0.8, 1.0);

uniform bool transparent_background = true;

void fragment() {
    float adjusted_spacing = line_width + spacing;

    float rad = radians(angle);
    vec2 direction = vec2(cos(rad), sin(rad));

    float diagonal = dot(UV, direction);
    diagonal += TIME / time_per_cycle;

    float spaced_diagonal = mod(diagonal, adjusted_spacing);

    bool is_line = spaced_diagonal < line_width;

    if (is_line) {
        COLOR = line_color * COLOR;
    } else if (transparent_background) {
        COLOR = vec4(0.0);
    }
}
