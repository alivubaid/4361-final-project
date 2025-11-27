varying vec2 vUv;

uniform float time;

void main() {
  vUv = uv;

  vec3 pos = position;
  pos.y += 0.5 * sin(pos.x * 0.5 + time) * cos(pos.z * 0.5 + time);

  gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
}