precision mediump float;

varying vec3 vViewPos;
varying vec3 vWorldPos;

uniform vec3 lightPosition; // world-space

void main() {
  // Normal from view-space derivatives
  vec3 dx = dFdx(vViewPos);
  vec3 dy = dFdy(vViewPos);
  vec3 N = normalize(cross(dx, dy));

  // Transform light to view-space
  vec3 lightVS = (viewMatrix * vec4(lightPosition, 1.0)).xyz;

  vec3 L = normalize(lightVS - vViewPos);
  vec3 V = normalize(-vViewPos); // view direction in view-space
  vec3 R = reflect(-L, N);

  // Phong lighting
  float diff = max(dot(N, L), 0.0);
  float spec = pow(max(dot(R, V), 0.0), 16.0);

  vec3 base       = vec3(0.0, 0.30, 0.60); // shallow water tint
  vec3 deepTint   = vec3(0.0, 0.15, 0.25); // deeper absorption
  vec3 ambient    = 0.20 * base;
  vec3 diffuse    = diff * base;
  vec3 specular   = spec * vec3(1.0);

  vec3 color = ambient + diffuse + specular;

  // Fresnel shimmer (stronger at grazing angles)
  float fresnel = pow(1.0 - max(dot(N, V), 0.0), 3.0);

  // Simple sky-like tint (no environment map): horizon→zenith blend
  float skyFactor = clamp(V.y * 0.5 + 0.5, 0.0, 1.0);
  vec3 horizon = vec3(1.0);
  vec3 zenith  = vec3(0.5, 0.7, 1.0);
  vec3 skyTint = mix(horizon, zenith, skyFactor);

  color += fresnel * skyTint;

  // Depth-based absorption: farther fragments get darker
  float viewDepth = clamp((-vViewPos.z) / 50.0, 0.0, 1.0);
  color = mix(color, deepTint, viewDepth * 0.6);

  // Transparency: more opaque at grazing angles (reflective)
  float alpha = mix(0.6, 0.95, fresnel);

  gl_FragColor = vec4(color, alpha);
}