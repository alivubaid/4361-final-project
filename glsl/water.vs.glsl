varying vec3 vNormal;
varying vec3 vViewPos;

uniform float time;

void main() {
  vec3 pos = position;
  pos.y += 0.5 * sin(pos.x * 0.5 + time) * cos(pos.z * 0.5 + time);

  vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
  vViewPos = mvPosition.xyz;

  // Approximate normals from geometry
  vNormal = normalize(normalMatrix * normal);

  gl_Position = projectionMatrix * mvPosition;
}