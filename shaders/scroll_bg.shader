shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.0, -200.0); // negative Y = scroll up
uniform float time_passed = 0.0;

void fragment() {
	vec2 uv = UV;
	uv += scroll_speed * time_passed / vec2(1.0, 1.0); // scale by 1.0 since UV is 0–1
	COLOR = texture(TEXTURE, fract(uv)); // fract() repeats UV for infinite tiling
}
