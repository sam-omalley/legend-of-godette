shader_type spatial;
render_mode unshaded;

uniform vec3 colour: source_color;
uniform float energy = 1.0;
uniform float alpha: hint_range(0.0, 1.0) = 0.0;

void fragment() {
	ALBEDO = colour * energy;
	ALPHA = alpha;
}
