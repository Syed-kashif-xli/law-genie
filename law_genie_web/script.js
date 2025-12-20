/* 
   LUXURY INTERACTION ENGINE 
   Author: Law Genie Design Team
*/

document.addEventListener('DOMContentLoaded', () => {
    // Force show scrollbar immediately
    document.body.style.overflow = 'auto';
    document.body.classList.remove('loading');

    // 1. WebGL Background (Luxury Neural Particles)
    try { initWebGL(); } catch (e) { console.error("WebGL Init Failed", e); }

    // 2. Custom Cursor (Sleek Liquid Transition)
    try { initCursor(); } catch (e) { console.error("Cursor Init Failed", e); }

    // 3. Navbar Interaction
    try { initNavbar(); } catch (e) { console.error("Navbar Init Failed", e); }

    // 4. Scroll Reveal System (GSAP Powered)
    try { initScrollReveal(); } catch (e) { console.error("Reveal Init Failed", e); }

    // 5. Magnetic Hover Effects
    try { initMagneticInteractions(); } catch (e) { console.error("Magnetic Init Failed", e); }

    // 6. Mockup Animations
    try { initMockupAnimations(); } catch (e) { console.error("Mockup Anim Failed", e); }
});

function initWebGL() {
    const canvas = document.querySelector('#webgl-bg');
    if (!canvas || !window.THREE) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });

    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    // Neural Grid Particles
    const particlesCount = window.innerWidth < 768 ? 800 : 2500;
    const posArray = new THREE.Float32Array(particlesCount * 3);

    for (let i = 0; i < particlesCount * 3; i++) {
        posArray[i] = (Math.random() - 0.5) * 15;
    }

    const particlesGeometry = new THREE.BufferGeometry();
    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(posArray, 3));

    const particlesMaterial = new THREE.PointsMaterial({
        size: 0.006,
        color: '#6366f1',
        transparent: true,
        opacity: 0.4,
        blending: THREE.AdditiveBlending
    });

    const particlesMesh = new THREE.Points(particlesGeometry, particlesMaterial);
    scene.add(particlesMesh);

    camera.position.z = 5;

    let mouseX = 0, mouseY = 0;
    document.addEventListener('mousemove', (e) => {
        mouseX = (e.clientX - window.innerWidth / 2) * 0.0001;
        mouseY = (e.clientY - window.innerHeight / 2) * 0.0001;
    });

    function animate() {
        requestAnimationFrame(animate);
        particlesMesh.rotation.y += 0.0005;
        particlesMesh.rotation.x += 0.0002;
        particlesMesh.position.x += (mouseX - particlesMesh.position.x) * 0.03;
        particlesMesh.position.y += (-mouseY - particlesMesh.position.y) * 0.03;
        renderer.render(scene, camera);
    }
    animate();

    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });
}

function initCursor() {
    const dot = document.querySelector('.cursor-dot');
    const outline = document.querySelector('.cursor-outline');
    if (!dot || !outline) return;

    // Mobile check: Disable on touch
    if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
        dot.style.display = 'none';
        outline.style.display = 'none';
        document.body.style.cursor = 'auto';
        return;
    }

    let posX = 0, posY = 0, mouseX = 0, mouseY = 0;

    if (window.gsap) {
        gsap.to({}, {
            duration: 0.016,
            repeat: -1,
            onRepeat: () => {
                posX += (mouseX - posX) / 10;
                posY += (mouseY - posY) / 10;
                gsap.set(dot, { css: { left: mouseX, top: mouseY } });
                gsap.set(outline, { css: { left: posX, top: posY } });
            }
        });

        document.addEventListener('mousemove', (e) => {
            mouseX = e.clientX;
            mouseY = e.clientY;
            // Ensure visibility
            dot.style.opacity = '1';
            outline.style.opacity = '1';
        });

        const targets = document.querySelectorAll('a, button, .btn, .feature-card, .pricing-card, input, textarea, .action-box');
        targets.forEach(el => {
            el.addEventListener('mouseenter', () => {
                gsap.to(outline, {
                    scale: 2.2,
                    backgroundColor: 'rgba(99, 102, 241, 0.1)',
                    borderColor: 'rgba(99, 102, 241, 0.4)',
                    duration: 0.3
                });
                gsap.to(dot, { scale: 1.5, duration: 0.3 });
            });
            el.addEventListener('mouseleave', () => {
                gsap.to(outline, {
                    scale: 1,
                    backgroundColor: 'rgba(255, 255, 255, 0.02)',
                    borderColor: 'rgba(255, 255, 255, 0.3)',
                    duration: 0.3
                });
                gsap.to(dot, { scale: 1, duration: 0.3 });
            });
        });
    }
}

function initNavbar() {
    const navbar = document.querySelector('.navbar');
    if (!navbar) return;

    window.addEventListener('scroll', () => {
        if (window.scrollY > 100) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });
}

function initScrollReveal() {
    const observerOptions = {
        threshold: 0.15,
        rootMargin: "0px 0px -50px 0px"
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('active');

                // Staggered child animations
                const children = entry.target.querySelectorAll('.feature-card, .stat-item, .step-item');
                if (children.length > 0 && window.gsap) {
                    gsap.from(children, {
                        y: 40,
                        opacity: 0,
                        duration: 1,
                        stagger: 0.15,
                        ease: "power3.out"
                    });
                }
            }
        });
    }, observerOptions);

    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
}

function initMagneticInteractions() {
    const items = document.querySelectorAll('.logo, .btn, .nav-links a, .feature-icon');

    items.forEach(item => {
        item.addEventListener('mousemove', (e) => {
            const bounds = item.getBoundingClientRect();
            const x = (e.clientX - bounds.left - bounds.width / 2) * 0.4;
            const y = (e.clientY - bounds.top - bounds.height / 2) * 0.4;

            if (window.gsap) {
                gsap.to(item, {
                    x: x,
                    y: y,
                    duration: 0.6,
                    ease: "power2.out"
                });
            }
        });

        item.addEventListener('mouseleave', () => {
            if (window.gsap) {
                gsap.to(item, {
                    x: 0,
                    y: 0,
                    duration: 1,
                    ease: "elastic.out(1, 0.3)"
                });
            }
        });
    });
}

function initMockupAnimations() {
    if (!window.gsap) return;

    // Set initial states
    gsap.set('.mini-phone', { opacity: 0, scale: 0.9 });

    const mockupObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const target = entry.target;

                // Animate entry of the mini phone
                gsap.to(target, {
                    opacity: 1,
                    scale: 1,
                    duration: 1,
                    ease: "power3.out"
                });

                // Trigger specific internals if any
                const waveBars = target.querySelectorAll('.wave-bar');
                if (waveBars.length > 0) {
                    gsap.to(waveBars, {
                        height: 30,
                        duration: 0.5,
                        repeat: -1,
                        yoyo: true,
                        stagger: 0.1
                    });
                }
            }
        });
    }, { threshold: 0.3 });

    document.querySelectorAll('.mini-phone').forEach(el => {
        mockupObserver.observe(el);
    });
}
