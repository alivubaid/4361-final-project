uniform float time;
uniform vec3 bgColor;
varying vec2 vUv;

void main() {
  vec2 flowUV = vUv;
  flowUV.x += time * 0.02; // drift

  vec3 base = vec3(0.0, 0.1, 0.25);

  float wave1 = sin((flowUV.x + time * 0.15) * 10.0) * 0.03;
  float wave2 = sin((flowUV.y - time * 0.1) * 6.0) * 0.02;
  float wave3 = sin((flowUV.x * 3.0 - time * 0.08) * 15.0) * 0.015;
  float wave4 = sin((flowUV.y * 2.5 + time * 0.12) * 8.0) * 0.012;
  float shimmer = clamp(wave1 + wave2 + wave3 + wave4, -0.1, 0.1);

  vec3 color = base + vec3(0.15, 0.18, 0.22) * shimmer;

  float dist = abs(vUv.y - 0.5);
  float depthDarkening = 1.0 - (dist * 0.8);
  color *= depthDarkening;

  float bottomDarkness = smoothstep(0.0, 0.5, dist) * 0.5;
  color *= (1.0 - bottomDarkness);

  float edgeMask = smoothstep(0.35, 1.0, dist);
  color = mix(color, bgColor, edgeMask * .5);

  // Foam edges
  float foamMask = smoothstep(0.3, 0.35, dist);
  foamMask += 1.0 - smoothstep(0.95, 1.0, dist);
  color = mix(color, vec3(1.0), foamMask * 0.03);

  // Highlights
  float fresnel = pow(1.0 - dist, 3.0);
  vec3 highlight = vec3(0.6, 0.7, 0.9) * fresnel * 0.15; // dimmer
  color += highlight;

  // Noise variation
  float noise = sin(flowUV.x * 40.0 + time) * sin(flowUV.y * 40.0 - time);
  color *= 1.0 + noise * 0.02;

  gl_FragColor = vec4(color, 1.0);
}