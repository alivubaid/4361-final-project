varying vec3 vNormal;
varying vec3 vViewPos;

uniform float time;

float wave(float x, float z, float t) {
  return 0.5 * sin(x * 0.5 + t) * cos(z * 0.5 + t);
}

void main() {
  vec3 pos = position;
  pos.y += wave(pos.x, pos.z, time);

  // Sample displaced neighbors
  float eps = 0.1;
  vec3 dx = vec3(eps, wave(pos.x + eps, pos.z, time) - wave(pos.x, pos.z, time), 0.0);
  vec3 dz = vec3(0.0, wave(pos.x, pos.z + eps, time) - wave(pos.x, pos.z, time), eps);

  // Cross product → normal
  vNormal = normalize(cross(dz, dx));

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
  vViewPos = mvPosition.xyz;
  gl_Position = projectionMatrix * mvPosition;
}