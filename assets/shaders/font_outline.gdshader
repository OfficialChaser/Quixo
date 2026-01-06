shader_type canvas_item;

uniform float amt : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float cutoff = step(amt, tex.a);

    COLOR.rgb *= tex.rgb;
    COLOR.a *= cutoff;
}
