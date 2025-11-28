uniform float time;
varying vec2 vUv;

void main() {
  vUv = uv;
  // simple vertex displacement along the normal to simulate waves
  vec3 pos = position + normal * (sin(position.x * 2.0 + time * 2.0) * 0.25 + sin(position.y * 3.0 + time * 1.5) * 0.12);
  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}