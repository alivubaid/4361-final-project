precision highp float;

varying vec3 vNormal;
varying vec3 vViewPos;

uniform vec3 lightPosition;

void main() {
  vec3 N = normalize(vNormal);
  vec3 L = normalize(lightPosition - vViewPos);
  vec3 V = normalize(-vViewPos);
  vec3 R = reflect(-L, N);

  float diff = max(dot(N, L), 0.0);
  float spec = pow(max(dot(R, V), 0.0), 16.0);

  vec3 base = vec3(0.0, 0.3, 0.6);
  vec3 color = 0.2 * base + diff * base + spec * vec3(1.0);

  gl_FragColor = vec4(color, 1.0);
}