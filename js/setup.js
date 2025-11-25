import * as THREE from './three.module.js';
import { OrbitControls } from './OrbitControls.js';

function setup() {
  const canvas = document.getElementById('webglcanvas');
  const context = canvas.getContext('webgl2');
  const renderer = new THREE.WebGLRenderer({ canvas, context });
  renderer.setClearColor(0x80CEE1); // light blue background
  return { renderer, canvas };
}

function createScene(canvas, renderer) {
  const scene = new THREE.Scene();

  const camera = new THREE.PerspectiveCamera(30.0, 1.0, 0.1, 1000.0);
  camera.position.set(0.0, 30.0, 80.0);
  camera.lookAt(scene.position);
  scene.add(camera);

  const controls = new OrbitControls(camera, canvas);
  controls.screenSpacePanning = true;
  controls.damping = 0.2;
  controls.autoRotate = false;

  function resize() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
  }
  window.addEventListener('resize', resize);
  resize();

  const worldFrame = new THREE.AxesHelper(1);
  scene.add(worldFrame);

  return { scene, camera, worldFrame };
}

export { setup, createScene };