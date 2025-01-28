shader_type spatial;
render_mode cull_disabled;

uniform vec3 colour: source_color;
uniform vec3 shadow_colour: source_color;
uniform sampler2D curve_sampler: repeat_disable;
uniform sampler2D wind_sampler: repeat_enable, filter_linear;
uniform float wind_strength = 0.4;
uniform float player_displacement = 1.5;

global uniform vec3 player_position;

void vertex() {
	/* Wind */
	vec2 world_pos = vec2(NODE_POSITION_WORLD.x, NODE_POSITION_WORLD.z);
	float curve = texture(curve_sampler, vec2(UV.y, 0.0)).x;
	float wind = (texture(wind_sampler, world_pos * 0.08 + TIME * 0.05).x - 0.5) * curve * wind_strength;
	VERTEX += vec3(wind);
	
	/* Player */
	vec3 direction_to_player = player_position - NODE_POSITION_WORLD;
	float distance_to_player = length(direction_to_player);
	
	float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_player);
	
	VERTEX += -direction_to_player * falloff * curve * player_displacement;
	
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	ALBEDO = mix(colour, shadow_colour * colour, UV.y);
}

