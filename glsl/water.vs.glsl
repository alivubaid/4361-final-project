precision mediump float;

varying vec3 vViewPos;
varying vec3 vWorldPos;

uniform float time;

// Multi-frequency wave field (x,z plane)
float waveField(vec2 p, float t) {
  return 0.3 * sin(p.x * 0.5 + t)
       + 0.2 * cos(p.y * 0.7 + t * 1.2)
       + 0.1 * sin((p.x + p.y) * 0.3 + t * 0.8);
}

void main() {
  vec3 pos = position;
  pos.y += waveField(pos.xz, time);

  // View & world positions
  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
  vViewPos = mvPosition.xyz;
  vWorldPos = (modelMatrix * vec4(pos, 1.0)).xyz;

  gl_Position = projectionMatrix * mvPosition;
}