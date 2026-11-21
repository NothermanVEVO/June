
shader_type canvas_item;
render_mode blend_mix;

uniform float width = 0.1;
uniform float strength = 1.3;
uniform float angle : hint_range(0.0, 360.0, 1.0) = 45.0;
uniform float progress : hint_range(0.0, 1.0) = -1.0;

uniform vec4 shine_color : source_color = vec4(1.0, 0.92, 0.7, 1.0);

void fragment() {
    if (progress < 0.0) {
        discard;
    }

    vec2 uv = UV - vec2(0.5);

    float rad = radians(angle);
    vec2 dir = vec2(cos(rad), sin(rad));

    float d = dot(uv, dir);

    float t = progress * 1.4 - 0.7;

    float band = 1.0 - smoothstep(0.0, width, abs(d - t));
    float core = 1.0 - smoothstep(0.0, width * 0.25, abs(d - t));

    float shine = (band * 0.6 + core * 0.8) * strength;

    if (shine <= 0.001) {
        discard;
    }

    COLOR = vec4(
        shine_color.rgb,
        clamp(shine * shine_color.a, 0.0, 1.0)
    );
}
