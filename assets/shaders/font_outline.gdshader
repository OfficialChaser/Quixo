shader_type canvas_item;

uniform float amt : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    float alpha = texture(TEXTURE, UV).a;
    COLOR.a = step(amt, alpha);
}
