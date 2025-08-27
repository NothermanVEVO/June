shader_type canvas_item;

// === User Controls ===
// Color to blend with solid pixels (alpha is blend strength)
uniform vec4 shade_color      : source_color = vec4(1.0, 1.0, 1.0, 0.5);

// === Main Fragment ===
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float alpha = tex.a;

	 // Skip fully transparent pixel with no outline
	if (alpha <= 0.0) discard;

	vec4 out_color = tex;

	// Blend solid pixels toward the shade_color based on its alpha
	out_color.rgb = mix(tex.rgb, shade_color.rgb, shade_color.a);
	out_color.a   = alpha;

	// Set final pixel color
	COLOR = out_color;
}
