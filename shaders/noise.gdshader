shader_type canvas_item;

uniform vec2 scrool = vec2(0.0, 0.004);

float hash (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV + scrool * sin(TIME));
	COLOR = texture_color;
}
