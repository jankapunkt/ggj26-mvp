shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.0, -200.0); // pixels/sec
uniform float time_passed = 0.0;

void fragment() {
    vec2 uv = UV;
    uv += scroll_speed * time_passed / TEXTURE_PIXEL_SIZE; // scale pixels -> UV
    COLOR = texture(TEXTURE, fract(uv));
}
