precision highp float;
varying vec3 vWorldPosition;

void main() {
    // --- River cut-out ---
    float halfWidth  = 10.0;
    float halfLength = 100.0;
    if (abs(vWorldPosition.z) < halfWidth && abs(vWorldPosition.x) < halfLength) {
        discard;
    }

    // --- Green gradient by height ---
    float h = vWorldPosition.y;

    // Define two shades of green
    vec3 lowGreen  = vec3(0.1, 0.4, 0.1); // darker green
    vec3 highGreen = vec3(0.6, 0.9, 0.6); // lighter green

    // Blend smoothly based on height
    float t = clamp(h / 2.0, 0.0, 1.0); // adjust divisor to control gradient spread
    vec3 color = mix(lowGreen, highGreen, t);

    gl_FragColor = vec4(color, 1.0);
}