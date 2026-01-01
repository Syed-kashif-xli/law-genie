/* 
   LAW GENIE - INTERACTION ENGINE
   Aesthetic Particles & Custom Cursor
*/

document.addEventListener('DOMContentLoaded', () => {
    initWebGL();
    initCursor();
});

function initWebGL() {
    const canvas = document.querySelector('#webgl-bg');
    if (!canvas || !window.THREE) return;

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ canvas, alpha: true, antialias: true });

    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    const particlesCount = 2000;
    const posArray = new Float32Array(particlesCount * 3);

    for (let i = 0; i < particlesCount * 3; i++) {
        posArray[i] = (Math.random() - 0.5) * 10;
    }

    const geometry = new THREE.BufferGeometry();
    geometry.setAttribute('position', new THREE.BufferAttribute(posArray, 3));

    const material = new THREE.PointsMaterial({
        size: 0.005,
        color: '#6366f1',
        transparent: true,
        opacity: 0.5
    });

    const mesh = new THREE.Points(geometry, material);
    scene.add(mesh);

    camera.position.z = 3;

    function animate() {
        requestAnimationFrame(animate);
        mesh.rotation.y += 0.001;
        renderer.render(scene, camera);
    }
    animate();

    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });

    // --- AI CHAT LOGIC (GOOGLE GEMINI PRO) ---
    const chatDisplay = document.getElementById('chat-display');
    const userInput = document.getElementById('user-input');
    const sendBtn = document.getElementById('send-btn');

    if (chatDisplay && userInput && sendBtn) {
        const DEEPSEEK_API_KEY = 'sk-155095e52fc647f39bc1dabf35821b51';
        const SYSTEM_PROMPT = "You are Law Genie AI, a specialized legal assistant for Indian Law. Answer questions accurately based on Indian statutes (like BNS, BNSS, BSA, IPC, CrPC) and case law precedents. Provide citations if possible. Keep answers concise and professional.";

        const appendMessage = (content, isUser = false) => {
            const msgDiv = document.createElement('div');
            msgDiv.className = `message ${isUser ? 'user-msg' : 'ai-msg'}`;
            msgDiv.textContent = content;
            chatDisplay.appendChild(msgDiv);
            chatDisplay.scrollTop = chatDisplay.scrollHeight;
        };

        const showTyping = () => {
            const typingDiv = document.createElement('div');
            typingDiv.className = 'typing';
            typingDiv.id = 'typing-indicator';
            typingDiv.textContent = 'Law Genie AI is analyzing...';
            chatDisplay.appendChild(typingDiv);
            chatDisplay.scrollTop = chatDisplay.scrollHeight;
        };

        const hideTyping = () => {
            const indicator = document.getElementById('typing-indicator');
            if (indicator) indicator.remove();
        };

        const handleSend = async () => {
            const text = userInput.value.trim();
            if (!text) return;

            appendMessage(text, true);
            userInput.value = '';
            showTyping();

            try {
                const response = await fetch('https://api.deepseek.com/chat/completions', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${DEEPSEEK_API_KEY}`
                    },
                    body: JSON.stringify({
                        model: "deepseek-chat",
                        messages: [
                            { role: "system", content: SYSTEM_PROMPT },
                            { role: "user", content: text }
                        ],
                        stream: false
                    })
                });

                if (response.status === 429) {
                    hideTyping();
                    appendMessage("The AI is currently under heavy load (Rate Limit reached). Please wait a moment and try again.");
                    return;
                }

                const data = await response.json();
                hideTyping();

                if (data.choices && data.choices[0] && data.choices[0].message) {
                    const aiResponse = data.choices[0].message.content;
                    appendMessage(aiResponse);
                } else {
                    appendMessage("I'm sorry, I encountered a legal processing error. This might be due to safety filters or a temporary outage.");
                    console.error("DeepSeek Error Context:", data);
                }
            } catch (error) {
                hideTyping();
                appendMessage("An error occurred. Please check your network connection.");
                console.error("Fetch Error:", error);
            }
        };

        sendBtn.addEventListener('click', handleSend);
        userInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') handleSend();
        });
    }
}

function initCursor() {
    const dot = document.querySelector('.cursor-dot');
    const outline = document.querySelector('.cursor-outline');
    if (!dot || !outline) return;

    document.addEventListener('mousemove', (e) => {
        gsap.to(dot, { x: e.clientX, y: e.clientY, duration: 0.1 });
        gsap.to(outline, { x: e.clientX - 15, y: e.clientY - 15, duration: 0.3 });
    });

    const hoverables = document.querySelectorAll('a, button, .feat-card');
    hoverables.forEach(el => {
        el.addEventListener('mouseenter', () => {
            gsap.to(outline, { scale: 2, borderColor: '#6366f1', duration: 0.3 });
        });
        el.addEventListener('mouseleave', () => {
            gsap.to(outline, { scale: 1, borderColor: 'rgba(255,255,255,0.3)', duration: 0.3 });
        });
    });
}
