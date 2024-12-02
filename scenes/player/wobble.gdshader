shader_type spatial;

uniform float wobble_amount = 0.1;
uniform float wobble_speed = 1.0;

varying float v_time;

void fragment() {
    // No need to assign a value to COLOR
}

void vertex() {
    v_time = TIME * wobble_speed;
    vec3 new_position = VERTEX;

    // Add a sine wave oscillation to each axis
    //new_position.x += sin(v_time + new_position.x) * wobble_amount;
    new_position.x += sin(VERTEX.y + v_time) * wobble_amount;
    new_position.z += sin(VERTEX.y + v_time) * wobble_amount;

    VERTEX = new_position;
}