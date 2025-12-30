shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform vec2 resolution = vec2(0.0, 0.0);
uniform float scan_line_amount: hint_range(0.0, 1.0) = 0.5; // 扫描线
uniform float warp_amount: hint_range(0.0, 1.0) = 0.1; // 扭曲
uniform float vignette_amount: hint_range(0.0, 1.0) = 0.5; // 暗角
uniform float grille_amount: hint_range(0.0, 1.0) = 0.1; // 网格
uniform float brightness_boost: hint_range(1.0, 2.0) = 1.5; // 亮度提升

void fragment() {
    vec2 uv = SCREEN_UV;
    // 扭曲
    vec2 delta = uv - 0.5;
    float warp_factor = dot(delta, delta) * warp_amount;
    uv += delta * warp_factor;
    // 扫描线
    float scan_line = sin(uv.y * resolution.y * PI) * 0.5 + 0.5;
    scan_line = mix(1.0, scan_line, scan_line_amount * 0.5);
    // 暗角
    float grille = (mod(uv.x * resolution.x, 3.0) < 1.5) ? 0.95 : 1.05;
    grille = mix(1.0, grille, grille_amount * 0.5);
    // 子像素采样
    vec3 color = texture(SCREEN_TEXTURE, uv).rgb * scan_line * grille;
    vec2 v_uv = uv * (1.0 - uv);
    float vignette = mix(1.0, v_uv.x * v_uv.y * 15.0, vignette_amount * 0.7);
    // 亮度提升
    color *= vignette * brightness_boost;
    // 边缘遮罩
    float d = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float mask = smoothstep(0.0, 0.001, d);
    color *= mask;
    COLOR = vec4(color, 1.0);
}
