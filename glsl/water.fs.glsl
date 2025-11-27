precision highp float;

varying vec2 vUv;

uniform vec3 lightPosition;
uniform float time;

void main() {
  // Map vUv to world-like coordinates
  vec2 uv = vUv * 20.0 - 10.0; // scale plane size

  // Ray origin = camera
  vec3 ro = cameraPosition;

  // Approximate ray direction from uv
  vec3 rd = normalize(vec3(uv, -1.0));

  // Intersect with plane at y=0
  float t = -ro.y / rd.y;
  vec3 hit = ro + rd * t;

  // Wave displacement
  float wave = 0.5 * sin(hit.x * 0.5 + time) * cos(hit.z * 0.5 + time);
  hit.y = wave;

  // Approximate normal from wave function
  float eps = 0.1;
  float waveX = 0.5 * sin((hit.x + eps) * 0.5 + time) * cos(hit.z * 0.5 + time);
  float waveZ = 0.5 * sin(hit.x * 0.5 + time) * cos((hit.z + eps) * 0.5 + time);

  vec3 dx = vec3(eps, waveX - wave, 0.0);
  vec3 dz = vec3(0.0, waveZ - wave, eps);
  vec3 N = normalize(cross(dz, dx));

  // Lighting
  vec3 L = normalize(lightPosition - hit);
  vec3 V = normalize(cameraPosition - hit);
  vec3 R = reflect(-L, N);

  float diff = max(dot(N, L), 0.0);
  float spec = pow(max(dot(R, V), 0.0), 16.0);

  vec3 base = vec3(0.0, 0.3, 0.6);
  vec3 color = 0.2 * base + diff * base + spec * vec3(1.0);

  gl_FragColor = vec4(color, 1.0);
}