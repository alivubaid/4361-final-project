precision mediump float;

varying vec3 vViewPos;
varying vec3 vWorldPos;

uniform vec3 lightPosition;

void main() {
  // Normal from derivatives
  vec3 dx = dFdx(vViewPos);
  vec3 dy = dFdy(vViewPos);
  vec3 N = normalize(cross(dx, dy));

  // Light + view directions
  vec3 lightVS = (viewMatrix * vec4(lightPosition, 1.0)).xyz;
  vec3 L = normalize(lightVS - vViewPos);
  vec3 V = normalize(-vViewPos);
  vec3 R = reflect(-L, N);

  // Phong lighting
  float diff = max(dot(N, L), 0.0);
  float spec = pow(max(dot(R, V), 0.0), 16.0);

  vec3 base     = vec3(0.0, 0.3, 0.6);
  vec3 ambient  = 0.2 * base;
  vec3 diffuse  = diff * base;
  vec3 specular = spec * vec3(1.0);

  vec3 color = ambient + diffuse + specular;

  // Fresnel shimmer
  float fresnel = pow(1.0 - max(dot(N, V), 0.0), 3.0);

  // Sky gradient tint
  float skyFactor = clamp(V.y * 0.5 + 0.5, 0.0, 1.0);
  vec3 horizon = vec3(1.0);
  vec3 zenith  = vec3(0.5, 0.7, 1.0);
  vec3 skyTint = mix(horizon, zenith, skyFactor);

  color += fresnel * skyTint;

  // Shore-based depth tint
 vec2 lakeCenter = vec2(0.0, 0.0); // adjust if your plane is offset
float lakeRadius = 10.0;          // match your geometry size
float dist = length(vWorldPos.xz - lakeCenter);
float depthFactor = 1.0 - clamp(dist / lakeRadius, 0.0, 1.0);

vec3 shallow = vec3(0.0, 0.4, 0.7);
vec3 deep    = vec3(0.0, 0.15, 0.25);
vec3 waterColor = mix(shallow, deep, depthFactor);

float alpha = mix(0.6, 0.95, depthFactor);
gl_FragColor = vec4(waterColor, alpha);
}