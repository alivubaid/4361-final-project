precision highp float;

varying vec3 vWorldPosition;

void main() {
    // Elevation pattern
    float elevation = sin(position.x * 0.2) * cos(position.y * 0.2) * 2.0;

    // Push along Z
    vec3 displaced = position + vec3(0.0, 0.0, elevation);

    vWorldPosition = (modelMatrix * vec4(displaced, 1.0)).xyz;
    gl_Position = projectionMatrix * modelViewMatrix * vec4(displaced, 1.0);
}