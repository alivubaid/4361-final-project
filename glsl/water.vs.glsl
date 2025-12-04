uniform float time;
varying vec2 vUv;

void main() {
  vUv = uv;
  // simple vertex displacement along the normal to simulate waves, increased by 30%
  vec3 pos = position + normal * (sin(position.x * 2.0 + time * 2.0) * 0.325 + sin(position.y * 3.0 + time * 1.5) * 0.156);
  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}