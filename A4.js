import * as THREE from './js/three.module.js';
import { setup, createScene } from './js/setup.js';
import { SourceLoader } from './js/SourceLoader.js';
import { OrbitControls } from './js/OrbitControls.js';

const shaderFiles = ['glsl/water.vs.glsl', 'glsl/water.fs.glsl'];

const { renderer, canvas } = setup();
const { scene, camera, worldFrame } = createScene(canvas, renderer);

const waterMaterial = new THREE.ShaderMaterial({
  uniforms: {
    lightPosition: { value: new THREE.Vector3(10, 5, 10) },
    time: { value: 0.0 },
  }
});

new SourceLoader().load(shaderFiles, function (shaders) {
  waterMaterial.vertexShader = shaders['glsl/water.vs.glsl'];
  waterMaterial.fragmentShader = shaders['glsl/water.fs.glsl'];
  waterMaterial.needsUpdate = true;

  const lakeGeometry = new THREE.PlaneGeometry(20, 20, 100, 100);
  const lake = new THREE.Mesh(lakeGeometry, waterMaterial);
  lake.rotation.x = -Math.PI / 2;
  scene.add(lake);

  camera.position.set(0, 10, 30);
  camera.lookAt(0, 0, 0);

  animate();
});

function animate() {
  requestAnimationFrame(animate);

  waterMaterial.uniforms.time.value = performance.now() / 1000;

  renderer.render(scene, camera);
}