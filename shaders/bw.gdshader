shader_type canvas_item;

uniform bool is_selected = true;

void fragment() {
	if (is_selected)  {
		COLOR = COLOR;
	} else {
		float gray = (COLOR.r + COLOR.g + COLOR.b + COLOR.a) / 4.0;
		COLOR = vec4(gray, gray, gray, gray);
	}
}