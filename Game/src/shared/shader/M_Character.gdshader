shader_type canvas_item;

uniform float quanitity : hint_range(0.0, 1.0);
uniform vec4 tint : source_color = vec4(1.0);
uniform bool is_rotation = false;


void fragment() {
	vec4 base = texture(TEXTURE, UV) * tint;
	vec4 flash = vec4(1.0,1.0,1.0, base.a);
	COLOR = mix(base, flash, quanitity);
}

uniform float speed = 1.0;

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float cosa = cos(rotation);
	float sina = sin(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x
	) + pivot;
}

void vertex() {
	if (is_rotation){
		VERTEX = rotateUV(VERTEX, vec2(0), TIME * speed);
	}
}