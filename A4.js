import * as THREE from './js/three.module.js';
import { setup, createScene } from './js/setup.js';
import { SourceLoader } from './js/SourceLoader.js';
import { OrbitControls } from './js/OrbitControls.js';

const shaderFiles = ['glsl/water.vs.glsl', 'glsl/water.fs.glsl', 'glsl/land.vs.glsl' , 'glsl/land.fs.glsl'];

const { renderer, canvas } = setup();
const { scene, camera } = createScene(canvas, renderer);

const waterMaterial = new THREE.ShaderMaterial({
  uniforms: {
    time: { value: 0.0 },
    lightPosition: { value: new THREE.Vector3(10, 20, 10) },
    cameraPosition: { value: new THREE.Vector3() },
    bgColor: { value: new THREE.Color(0x000000) }
  },
  vertexShader: '',
  fragmentShader: '',
  side: THREE.DoubleSide,
  transparent: true
});

const landMaterial = new THREE.ShaderMaterial({
  uniforms: {
     lightPosition: { value: new THREE.Vector3(10, 20, 10) },
    cameraPosition: { value: new THREE.Vector3() }
  },
  vertexShader: '',
  fragmentShader: '',
  side: THREE.DoubleSide
})

new SourceLoader().load(shaderFiles, function (shaders) {
  waterMaterial.vertexShader = shaders['glsl/water.vs.glsl']; // water
  waterMaterial.fragmentShader = shaders['glsl/water.fs.glsl'];
  waterMaterial.needsUpdate = true;

  const lakeGeometry = new THREE.PlaneGeometry(200, 20, 100, 100);
  const lake = new THREE.Mesh(lakeGeometry, waterMaterial);
  lake.rotation.x = -Math.PI / 2;
  // Use the shader material for animated water
  scene.add(lake);

  landMaterial.vertexShader = shaders['glsl/land.vs.glsl']; // land
  landMaterial.fragmentShader = shaders['glsl/land.fs.glsl'];
  landMaterial.needsUpdate = true;

  const landGeometry = new THREE.PlaneGeometry(200, 100, 400, 400);
  const land = new THREE.Mesh(landGeometry, landMaterial);
  land.rotation.x = -Math.PI / 2;
  land.position.y = -.1;
  scene.add(land);

  camera.position.set(0, 10, 30);
  camera.lookAt(0, 0, 0);

  const groundBoxGeometry = new THREE.BoxGeometry(200, 10, 200);
  const groundBoxMaterial = new THREE.MeshBasicMaterial({ color: 0x0a3d0a });
  const groundBox = new THREE.Mesh(groundBoxGeometry, groundBoxMaterial);
  groundBox.position.y = -10; // adjust so it sits just below land/water
  scene.add(groundBox);


  // Add a starfield background
  const starGeom = new THREE.SphereGeometry(0.1, 8, 8);
  const starMat = new THREE.MeshBasicMaterial({ color: 0xFFFFFF });
  const starCount = 200;
  for (let i = 0; i < starCount; i++) {
    const star = new THREE.Mesh(starGeom, starMat);
    const radius = 80; // far away from camera
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.random() * Math.PI;
    star.position.set(
      radius * Math.sin(phi) * Math.cos(theta),
      radius * Math.cos(phi),
      radius * Math.sin(phi) * Math.sin(theta)
    );
    scene.add(star);
  }

  // Add a moon in the sky
  const sunGeom = new THREE.SphereGeometry(1, 32, 32);
  const sunMat = new THREE.MeshBasicMaterial({ color: 0xEEEEEE });
  const sun = new THREE.Mesh(sunGeom, sunMat);
  sun.position.set(8, 4, 5);
  scene.add(sun);

  // Add a point light at the moon's position for moonlight
  const sunLight = new THREE.PointLight(0xCCDDFF, 2, 50);
  sunLight.position.copy(sun.position);
  scene.add(sunLight);

  // Add ambient light for overall illumination and reflection enhancement
  const ambientLight = new THREE.AmbientLight(0xFFFFFF, 0.6);
  scene.add(ambientLight);

  // Helper to create a simple tree (trunk + foliage) with lighting
  function createTree() {
    const group = new THREE.Group();

    const trunkGeom = new THREE.CylinderGeometry(0.2, 0.2, 2, 12);
    const trunkMat = new THREE.MeshStandardMaterial({ color: 0x8B4513, roughness: 0.3, metalness: 0.8 });
    const trunk = new THREE.Mesh(trunkGeom, trunkMat);
    trunk.position.y = 1.0; // half the trunk height so it sits on the plane
    group.add(trunk);

    const foliageGeom = new THREE.SphereGeometry(1.2, 16, 12);
    const foliageMat = new THREE.MeshStandardMaterial({ color: 0x228B22, roughness: 0.2, metalness: 0.7 });
    const foliage = new THREE.Mesh(foliageGeom, foliageMat);
    foliage.position.y = 2.4;
    group.add(foliage);

    return group;
  }

  // Spread multiple trees across the plane (randomized within plane bounds)
  // Plane is 20x20 centered at origin; keep trees inside -9..9 to avoid edges
  // Helper: same as before
function createTree() {
  const group = new THREE.Group();

  const trunkGeom = new THREE.CylinderGeometry(0.2, 0.2, 2, 12);
  const trunkMat = new THREE.MeshStandardMaterial({ color: 0x8B4513, roughness: 0.3, metalness: 0.8 });
  const trunk = new THREE.Mesh(trunkGeom, trunkMat);
  trunk.position.y = 1.0;
  group.add(trunk);

  const foliageGeom = new THREE.SphereGeometry(1.2, 16, 12);
  const foliageMat = new THREE.MeshStandardMaterial({ color: 0x228B22, roughness: 0.2, metalness: 0.7 });
  const foliage = new THREE.Mesh(foliageGeom, foliageMat);
  foliage.position.y = 2.4;
  group.add(foliage);

  return group;
}

// Elevation function (same as vertex shader)
function getLandHeight(x, z) {
  return Math.sin(x * 0.2) * Math.cos(z * 0.2) * 2.0;
}

// Plane bounds
const halfWidth  = 200 / 2; // 100
const halfHeight = 100 / 2; // 50

// River bounds
const riverHalfWidth  = 10;
const riverHalfLength = 100;

// Dense forest
const numTrees = 500; // much higher count

for (let i = 0; i < numTrees; i++) {
  let x, z, y;

  // Keep picking until outside river
  do {
    x = (Math.random() * 2 - 1) * halfWidth;
    z = (Math.random() * 2 - 1) * halfHeight;
    y = getLandHeight(x, z);
  } while (Math.abs(z) < riverHalfWidth && Math.abs(x) < riverHalfLength);

  const t = createTree();
  t.position.set(x, y, z);

  // Random scale/rotation for variety
  const s = 0.7 + Math.random() * 0.6;
  t.scale.set(s, s, s);
  t.rotation.y = Math.random() * Math.PI * 2;

  scene.add(t);
}


  // Keyboard controls for moon movement
  const keys = {};
  window.addEventListener('keydown', (e) => { keys[e.key] = true; });
  window.addEventListener('keyup', (e) => { keys[e.key] = false; });

  // Store moon and light references for animation loop
  window.moonObject = { sun, sunLight };
  window.keysPressed = keys;

  animate();
});

function animate() {
  requestAnimationFrame(animate);

  // Handle moon movement with arrow keys
  if (window.moonObject) {
    const { sun, sunLight } = window.moonObject;
    const moveSpeed = 0.5;
    if (window.keysPressed['ArrowUp']) { sun.position.z -= moveSpeed; sunLight.position.z -= moveSpeed; }
    if (window.keysPressed['ArrowDown']) { sun.position.z += moveSpeed; sunLight.position.z += moveSpeed; }
    if (window.keysPressed['ArrowLeft']) { sun.position.x -= moveSpeed; sunLight.position.x -= moveSpeed; }
    if (window.keysPressed['ArrowRight']) { sun.position.x += moveSpeed; sunLight.position.x += moveSpeed; }
  }

  waterMaterial.uniforms.time.value += 0.01;
  waterMaterial.uniforms.cameraPosition.value.copy(camera.position);

  renderer.render(scene, camera);
}