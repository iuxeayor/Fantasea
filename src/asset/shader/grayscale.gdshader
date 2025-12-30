shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
    vec4 tex = texture(SCREEN_TEXTURE, SCREEN_UV);
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    COLOR = vec4(gray, gray, gray, tex.a);
}