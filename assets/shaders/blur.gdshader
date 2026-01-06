shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_strength : hint_range(0.0, 10.0) = 4.0;

void fragment() {
    vec2 tex_size = vec2(textureSize(SCREEN_TEXTURE, 0));
    vec2 uv = UV;
    vec4 color = vec4(0.0);
    float total = 0.0;

    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) / tex_size;
            float weight = exp(-(float(x * x + y * y)) / (2.0 * blur_strength));
            color += texture(SCREEN_TEXTURE, uv + offset) * weight;
            total += weight;
        }
    }

    color /= total;
    COLOR = color;
}
