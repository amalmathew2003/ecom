/**
 * Basic Three.js & WebGL Setup Helper for E-commerce Application
 * This script provides a foundation for rendering 3D content using Three.js.
 */

window.initThreeJS = function(containerId, modelUrl) {
    const container = document.getElementById(containerId);
    if (!container) return;

    // 1. Scene Setup
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x050505);

    // 2. Camera Setup
    const camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
    camera.position.z = 5;

    // 3. Renderer Setup
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    container.appendChild(renderer.domElement);

    // 4. Lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(5, 5, 5);
    scene.add(directionalLight);

    // 5. Model Loading (Example using GLTFLoader)
    if (modelUrl) {
        const loader = new THREE.GLTFLoader();
        loader.load(modelUrl, function(gltf) {
            scene.add(gltf.scene);
            
            // Center and scale the model
            const box = new THREE.Box3().setFromObject(gltf.scene);
            const center = box.getCenter(new THREE.Vector3());
            const size = box.getSize(new THREE.Vector3());
            
            const maxDim = Math.max(size.x, size.y, size.z);
            const scale = 3 / maxDim;
            gltf.scene.scale.setScalar(scale);
            gltf.scene.position.sub(center.multiplyScalar(scale));
        });
    }

    // 6. Animation Loop
    function animate() {
        requestAnimationFrame(animate);
        
        // Auto-rotation effect
        scene.children.forEach(child => {
            if (child.type === 'Group') {
                child.rotation.y += 0.01;
            }
        });

        renderer.render(scene, camera);
    }

    animate();

    // 7. Handle Resize
    window.addEventListener('resize', () => {
        camera.aspect = container.clientWidth / container.clientHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(container.clientWidth, container.clientHeight);
    });
    
    console.log("Three.js & WebGL Engine Initialized (Ready for assets)");
};
