uniform float time;
uniform vec3 bgColor;
varying vec2 vUv;

void main() {
  // base sea color
  vec3 base = vec3(0.0, 0.25, 0.55);

  // subtle animated highlights using UV and time
  float wave1 = sin((vUv.x + time * 0.15) * 10.0) * 0.03;
  float wave2 = sin((vUv.y - time * 0.1) * 6.0) * 0.02;
  float shimmer = clamp(wave1 + wave2, -0.05, 0.05);

  vec3 color = base + vec3(0.15, 0.18, 0.22) * shimmer;

  // compute distance from center in UV space and make a smooth edge mask
  float dist = length(vUv - 0.5);
  float edgeMask = smoothstep(0.45, 0.9, dist);

  // blend water color into the page background color at the edges
  color = mix(color, bgColor, edgeMask);

  gl_FragColor = vec4(color, 1.0);
}