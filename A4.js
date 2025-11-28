import * as THREE from './js/three.module.js';
import { setup, createScene } from './js/setup.js';
import { SourceLoader } from './js/SourceLoader.js';
import { OrbitControls } from './js/OrbitControls.js';

const shaderFiles = ['glsl/water.vs.glsl', 'glsl/water.fs.glsl'];

const { renderer, canvas } = setup();
const { scene, camera, worldFrame } = createScene(canvas, renderer);

const waterMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: { value: 0.0 },
    lightPosition: { value: new THREE.Vector3(10, 20, 10) },
    cameraPosition: { value: new THREE.Vector3() },
    bgColor: { value: new THREE.Color(0x80CEE1) }
  },
  vertexShader: '',
  fragmentShader: '',
  side: THREE.DoubleSide,
  transparent: true
});

new SourceLoader().load(shaderFiles, function (shaders) {
  waterMaterial.vertexShader = shaders['glsl/water.vs.glsl'];
  waterMaterial.fragmentShader = shaders['glsl/water.fs.glsl'];
  waterMaterial.needsUpdate = true;

  const lakeGeometry = new THREE.PlaneGeometry(20, 20, 100, 100);
  const lake = new THREE.Mesh(lakeGeometry, waterMaterial);
  lake.rotation.x = -Math.PI / 2;
  // Use the shader material for animated water
  scene.add(lake);

  camera.position.set(0, 10, 30);
  camera.lookAt(0, 0, 0);
  // Helper to create a simple tree (trunk + foliage)
  function createTree() {
    const group = new THREE.Group();

    const trunkGeom = new THREE.CylinderGeometry(0.2, 0.2, 2, 12);
    const trunkMat = new THREE.MeshBasicMaterial({ color: 0x8B4513 });
    const trunk = new THREE.Mesh(trunkGeom, trunkMat);
    trunk.position.y = 1.0; // half the trunk height so it sits on the plane
    group.add(trunk);

    const foliageGeom = new THREE.SphereGeometry(1.2, 16, 12);
    const foliageMat = new THREE.MeshBasicMaterial({ color: 0x228B22 });
    const foliage = new THREE.Mesh(foliageGeom, foliageMat);
    foliage.position.y = 2.4;
    group.add(foliage);

    // Helper to add a branch (cylinder) at a given height and angle
    function addBranch(height, angle, length = 1.2, thickness = 0.06) {
      const branchGeom = new THREE.CylinderGeometry(thickness, thickness, length, 8);
      // make branches green to match foliage
      const branchMat = new THREE.MeshBasicMaterial({ color: 0x228B22 });
      const branch = new THREE.Mesh(branchGeom, branchMat);

      // cylinder default axis is Y; rotate to align along X, then rotate around Y for angle
      branch.rotation.z = Math.PI / 2;
      branch.rotation.y = angle;

      // place branch so one end touches the trunk surface
      const trunkRadius = 0.2;
      const offset = trunkRadius + length / 2;
      branch.position.x = Math.cos(angle) * offset;
      branch.position.z = Math.sin(angle) * offset;
      branch.position.y = height;

      group.add(branch);
    }

    // Add 2-4 branches at random heights/angles for a natural look
    const branchCount = 2 + Math.floor(Math.random() * 3); // 2..4
    for (let i = 0; i < branchCount; i++) {
      const h = 1.1 + Math.random() * 0.9; // between near mid and top of trunk
      const a = Math.random() * Math.PI * 2;
      const len = 0.8 + Math.random() * 0.8;
      const th = 0.04 + Math.random() * 0.04;
      addBranch(h, a, len, th);
    }

    return group;
  }

  // Spread multiple trees across the plane (randomized within plane bounds)
  // Plane is 20x20 centered at origin; keep trees inside -9..9 to avoid edges
  const numTrees = 6;
  const spread = 9;
  for (let i = 0; i < numTrees; i++) {
    const t = createTree();
    const x = (Math.random() * 2 - 1) * spread;
    const z = (Math.random() * 2 - 1) * spread;
    t.position.set(x, 0, z);
    // random slight scale and rotation for variety
    const s = 0.8 + Math.random() * 0.8;
    t.scale.set(s, s, s);
    t.rotation.y = Math.random() * Math.PI * 2;
    scene.add(t);
  }

  animate();
});

function animate() {
  requestAnimationFrame(animate);

  waterMaterial.uniforms.time.value += 0.01;
  waterMaterial.uniforms.cameraPosition.value.copy(camera.position);

  renderer.render(scene, camera);
}