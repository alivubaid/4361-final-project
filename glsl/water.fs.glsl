uniform float time;
uniform vec3 bgColor;
varying vec2 vUv;

void main() {
  // lighter sea color
  vec3 base = vec3(0.0, 0.35, 0.65);

  // multiple wave layers for more complex water surface
  float wave1 = sin((vUv.x + time * 0.15) * 10.0) * 0.03;
  float wave2 = sin((vUv.y - time * 0.1) * 6.0) * 0.02;
  float wave3 = sin((vUv.x * 3.0 - time * 0.08) * 15.0) * 0.015;
  float wave4 = sin((vUv.y * 2.5 + time * 0.12) * 8.0) * 0.012;
  float shimmer = clamp(wave1 + wave2 + wave3 + wave4, -0.1, 0.1);

  vec3 color = base + vec3(0.15, 0.18, 0.22) * shimmer;

  // compute distance from center in UV space
  float dist = length(vUv - 0.5);

  // enhanced depth darkening: stronger gradient toward center for deeper appearance
  float depthDarkening = 1.0 - (dist * 0.8);
  color *= depthDarkening;

  // darken bottom further using vUv.y for vertical gradient effect
  float bottomDarkness = smoothstep(0.0, 0.5, dist) * 0.5;
  color *= (1.0 - bottomDarkness);

  // make a very smooth edge fade
  float edgeMask = smoothstep(0.35, 1.0, dist);

  // blend water color into the page background color at the edges
  color = mix(color, bgColor, edgeMask);

  gl_FragColor = vec4(color, 1.0);
}