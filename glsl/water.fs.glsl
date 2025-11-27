precision mediump float;

varying vec3 vViewPos;

uniform vec3 lightPosition;

void main() {
  // Reconstruct normal from derivatives
  vec3 dx = dFdx(vViewPos);
  vec3 dy = dFdy(vViewPos);
  vec3 N = normalize(cross(dx, dy));

  vec3 L = normalize(lightPosition - vViewPos);
  vec3 V = normalize(cameraPosition - vViewPos);

  // Diffuse
  float diff = max(dot(N, L), 0.0);

  // Specular
  vec3 R = reflect(-L, N);
  float spec = pow(max(dot(R, V), 0.0), 16.0);

  vec3 base = vec3(0.0, 0.3, 0.6);
  vec3 ambient = 0.2 * base;
  vec3 diffuse = diff * base;
  vec3 specular = spec * vec3(1.0);

  vec3 color = ambient + diffuse + specular;
  gl_FragColor = vec4(color, 1.0);
}