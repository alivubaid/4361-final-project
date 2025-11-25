import * as THREE from './three.module.js';

class SourceLoader {
  load(urls, callback) {
    const loader = new THREE.FileLoader();
    const shaders = {};
    let loaded = 0;

    urls.forEach(url => {
      loader.load(url, data => {
        shaders[url] = data;
        loaded++;
        if (loaded === urls.length) {
          callback(shaders);
        }
      });
    });
  }
}

export { SourceLoader };