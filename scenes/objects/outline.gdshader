shader_type spatial;

uniform float border_thickness : hint_range(0.01, 0.1) = 0.05;
uniform float opacity : hint_range(0.0, 1.0) = 1.0; // Controls the opacity of lines

uniform float outline_width = 0.02;
uniform vec3 highlight_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	vec3 base_color = ALBEDO;
	float edge_dist = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));

    // Apply the effect to the edges only
    if (edge_dist < border_thickness) {
        // Apply colour and opacity to points
        ALBEDO = highlight_color;
        ALPHA = opacity;
    } else {
        ALBEDO = base_color;
    }
}

void vertex() {
	float time_offset = -TIME;
    vec3 normal = NORMAL;
    vec3 offset_position = VERTEX + normal * outline_width * time_offset;
    VERTEX = offset_position;
}