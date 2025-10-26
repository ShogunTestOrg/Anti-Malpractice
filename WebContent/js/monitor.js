// QuizMonitor.js - Client-side monitoring system
class QuizMonitor {
    constructor(config) {
        this.username = config.username;
        this.quizId = config.quizId;
        this.violationThreshold = config.violationThreshold || 5; // Auto-submit after 5 violations
        this.violationCount = 0;
        this.timeRemaining = config.timeRemaining;
        this.tabSwitchCount = 0;
        this.inactiveTime = 0;
        this.lastActivity = Date.now();
        this.isFullScreen = false;
        this.isTabHidden = false; // Track if tab is currently hidden
        this.monitoringEnabled = false; // Start with monitoring disabled
        
        // Debouncing: prevent duplicate violations within timeframe
        this.lastViolationTime = {};
        this.violationCooldown = 3000; // 3 seconds cooldown per violation type
        
        this.init();
    }
    
    init() {
        this.setupEventListeners();
        this.startTimer();
        // Commenting out aggressive features for testing
        // this.startInactivityMonitor();
        // this.requestFullScreen();
        this.disableContextMenu();
        // this.preventDevTools();
        
        // Enable monitoring after page fully loads + small buffer
        if (document.readyState === 'complete') {
            // Page already loaded
            this.enableMonitoring();
        } else {
            // Wait for page to finish loading
            window.addEventListener('load', () => {
                this.enableMonitoring();
            });
        }
    }
    
    enableMonitoring() {
        // Add a small buffer after page load to ensure everything is settled
        setTimeout(() => {
            this.monitoringEnabled = true;
            console.log('Tab switch monitoring enabled');
        }, 1000); // 1 second buffer after page load
    }
    
    setupEventListeners() {
        // Disable monitoring when form is being submitted to prevent false positives
        const quizForm = document.getElementById('quizForm');
        if (quizForm) {
            quizForm.addEventListener('submit', () => {
                console.log('Form submission detected - disabling monitoring');
                this.monitoringEnabled = false;
            });
        }
        
        // Tab switch detection - only log once when leaving tab, after monitoring is enabled
        document.addEventListener('visibilitychange', () => {
            // Only monitor after page has fully loaded and buffer period passed
            if (!this.monitoringEnabled) {
                console.log('Tab switch monitoring not yet enabled - ignoring visibility change');
                return;
            }
            
            if (document.visibilityState === 'hidden') {
                // Tab became hidden - log violation only if not already hidden
                if (!this.isTabHidden) {
                    this.isTabHidden = true;
                    this.tabSwitchCount++;
                    this.logViolation('Tab switch detected', 'TAB_SWITCH');
                    this.showWarning('Tab switching is not allowed during the quiz!');
                }
            } else {
                // Tab became visible - reset flag
                this.isTabHidden = false;
            }
        });
        
        // Copy prevention
        document.addEventListener('copy', (e) => {
            e.preventDefault();
            this.logViolation('Copy attempt detected', 'COPY_ATTEMPT');
            this.showWarning('Copying is not allowed!');
        });
        
        // Cut prevention
        document.addEventListener('cut', (e) => {
            e.preventDefault();
            this.logViolation('Cut attempt detected', 'CUT_ATTEMPT');
            this.showWarning('Cutting is not allowed!');
        });
        
        // Paste prevention
        document.addEventListener('paste', (e) => {
            e.preventDefault();
            this.logViolation('Paste attempt detected', 'PASTE_ATTEMPT');
            this.showWarning('Pasting is not allowed!');
        });
        
        // Screenshot detection (limited)
        document.addEventListener('keydown', (e) => {
            // Detect Print Screen
            if (e.key === 'PrintScreen') {
                this.logViolation('Screenshot attempt (Print Screen)', 'SCREENSHOT_ATTEMPT');
                this.showWarning('Screenshots are not allowed!');
            }
            
            // Detect common screenshot shortcuts
            if ((e.ctrlKey || e.metaKey) && e.shiftKey && (e.key === 'S' || e.key === 's')) {
                e.preventDefault();
                this.logViolation('Screenshot attempt (Ctrl+Shift+S)', 'SCREENSHOT_ATTEMPT');
                this.showWarning('Screenshots are not allowed!');
            }
        });
        
        // Fullscreen exit detection
        document.addEventListener('fullscreenchange', () => {
            if (!document.fullscreenElement) {
                this.logViolation('Exited fullscreen mode', 'FULLSCREEN_EXIT');
                this.showWarning('Please stay in fullscreen mode!');
                this.requestFullScreen();
            }
        });
        
        // Mouse leave detection (disabled - too sensitive)
        // document.addEventListener('mouseleave', () => {
        //     this.logViolation('Mouse left window', 'MOUSE_LEAVE');
        // });
        
        // Activity tracking
        ['mousedown', 'keydown', 'scroll', 'touchstart'].forEach(event => {
            document.addEventListener(event, () => {
                this.lastActivity = Date.now();
            });
        });
        
        // Prevent multiple tabs
        window.addEventListener('focus', () => {
            this.checkMultipleTabs();
        });
        
        // Disable beforeunload warning - we have custom modals
        // window.addEventListener('beforeunload', (e) => {
        //     e.preventDefault();
        //     e.returnValue = '';
        //     return 'Are you sure you want to leave? Your progress will be lost!';
        // });
    }
    
    disableContextMenu() {
        document.addEventListener('contextmenu', (e) => {
            e.preventDefault();
            this.logViolation('Right-click attempt', 'CONTEXT_MENU');
            this.showWarning('Right-click is disabled!');
        });
    }
    
    preventDevTools() {
        // Disabled - too unreliable and causes false positives
        // const detectDevTools = () => {
        //     const threshold = 160;
        //     const widthThreshold = window.outerWidth - window.innerWidth > threshold;
        //     const heightThreshold = window.outerHeight - window.innerHeight > threshold;
        //     
        //     if (widthThreshold || heightThreshold) {
        //         this.logViolation('Developer tools detected', 'DEVTOOLS_OPEN');
        //         this.showWarning('Developer tools are not allowed!');
        //     }
        // };
        // 
        // setInterval(detectDevTools, 1000);
        
        // Prevent F12
        document.addEventListener('keydown', (e) => {
            if (e.key === 'F12') {
                e.preventDefault();
                this.logViolation('F12 key pressed', 'DEVTOOLS_ATTEMPT');
                this.showWarning('Developer tools are not allowed!');
            }
        });
    }
    
    requestFullScreen() {
        const elem = document.documentElement;
        if (elem.requestFullscreen) {
            elem.requestFullscreen().catch(err => {
                console.log('Fullscreen request failed:', err);
            });
        }
    }
    
    startTimer() {
        const timerElement = document.getElementById('timer');
        let remaining = this.timeRemaining;
        
        const countdown = setInterval(() => {
            remaining--;
            
            if (remaining <= 0) {
                clearInterval(countdown);
                this.autoSubmit('Time limit exceeded');
                return;
            }
            
            const minutes = Math.floor(remaining / 60);
            const seconds = remaining % 60;
            timerElement.textContent = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            
            // Warning at 5 minutes
            if (remaining === 300) {
                this.showWarning('5 minutes remaining!');
            }
            
            // Warning at 1 minute
            if (remaining === 60) {
                this.showWarning('1 minute remaining!');
            }
        }, 1000);
    }
    
    startInactivityMonitor() {
        setInterval(() => {
            const inactive = Date.now() - this.lastActivity;
            const inactiveMinutes = Math.floor(inactive / 60000);
            
            if (inactiveMinutes >= 5) {
                this.logViolation(`Inactive for ${inactiveMinutes} minutes`, 'INACTIVITY');
                this.showWarning('Are you still there? Please continue the quiz.');
                this.lastActivity = Date.now();
            }
        }, 60000); // Check every minute
    }
    
    checkMultipleTabs() {
        // Store tab ID in sessionStorage
        if (!sessionStorage.getItem('quizTabId')) {
            sessionStorage.setItem('quizTabId', Date.now().toString());
        }
        
        // Use localStorage to detect multiple tabs
        const tabId = sessionStorage.getItem('quizTabId');
        const activeTab = localStorage.getItem('activeQuizTab');
        
        if (activeTab && activeTab !== tabId) {
            this.logViolation('Multiple tabs detected', 'MULTIPLE_TABS');
            this.showWarning('Quiz opened in another tab! Please use only one tab.');
        }
        
        localStorage.setItem('activeQuizTab', tabId);
    }
    
    logViolation(reason, type) {
        // Debounce: check if same violation type was logged recently
        const now = Date.now();
        const lastTime = this.lastViolationTime[type] || 0;
        
        if (now - lastTime < this.violationCooldown) {
            console.log(`Violation ${type} ignored (cooldown active)`);
            return; // Skip this violation
        }
        
        this.lastViolationTime[type] = now;
        this.violationCount++;
        
        // Update UI
        const countElement = document.getElementById('violationCount');
        if (countElement) {
            countElement.textContent = this.violationCount;
        }
        
        console.log(`Violation logged: ${type} - ${reason}`);
        
        // Send to server
        fetch(`violation?reason=${encodeURIComponent(reason)}&type=${type}&username=${this.username}&quizId=${this.quizId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        }).catch(err => console.error('Failed to log violation:', err));
        
        // Check if threshold reached and auto-submit
        if (this.violationCount >= this.violationThreshold) {
            this.autoSubmit(`Violation threshold reached (${this.violationCount} violations)`);
        }
    }
    
    showWarning(message) {
        // Use custom in-page modal instead of browser alert
        console.warn('Violation detected:', message);
        
        const overlay = document.getElementById('warningOverlay');
        const messageElement = document.getElementById('warningMessage');
        
        if (overlay && messageElement) {
            messageElement.textContent = message;
            overlay.style.display = 'flex';
            
            // Play warning sound (optional)
            this.playWarningSound();
        }
    }
    
    playWarningSound() {
        // Create a simple beep sound
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);
        
        oscillator.frequency.value = 800;
        oscillator.type = 'sine';
        
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);
        
        oscillator.start(audioContext.currentTime);
        oscillator.stop(audioContext.currentTime + 0.5);
    }
    
    autoSubmit(reason) {
        console.log('=== AUTO-SUBMIT TRIGGERED ===');
        console.log('Reason:', reason);
        
        // Log auto-submission
        this.logViolation(`Auto-submit: ${reason}`, 'AUTO_SUBMIT');
        
        // Disable all form elements to prevent further interaction
        const form = document.getElementById('quizForm');
        if (form) {
            const elements = form.elements;
            for (let i = 0; i < elements.length; i++) {
                elements[i].disabled = true;
            }
        }
        
        // Show modal THEN auto-submit after 3 seconds
        if (typeof showModal === 'function') {
            showModal(
                '🚫 Auto-Submit',
                `Your quiz is being automatically submitted. Reason: ${reason}. This page will redirect in 3 seconds...`,
                null, // No confirmation needed
                'alert'
            );
        }
        
        // Auto-submit after 3 seconds
        setTimeout(() => {
            console.log('Submitting form...');
            
            if (form) {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'autoSubmit';
                input.value = 'true';
                form.appendChild(input);
                
                const navInput = document.createElement('input');
                navInput.type = 'hidden';
                navInput.name = 'navigation';
                navInput.value = 'submit';
                form.appendChild(navInput);
                
                console.log('Form action:', form.action);
                console.log('Form method:', form.method);
                form.submit();
            } else {
                console.error('Form not found!');
            }
        }, 3000);
    }
}

function closeWarning() {
    document.getElementById('warningOverlay').style.display = 'none';
}

// Prevent keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Prevent Ctrl+P (Print)
    if ((e.ctrlKey || e.metaKey) && e.key === 'p') {
        e.preventDefault();
    }
    
    // Prevent Ctrl+S (Save)
    if ((e.ctrlKey || e.metaKey) && e.key === 's') {
        e.preventDefault();
    }
    
    // Prevent Ctrl+U (View Source)
    if ((e.ctrlKey || e.metaKey) && e.key === 'u') {
        e.preventDefault();
    }
    
    // Prevent Ctrl+Shift+I (DevTools)
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'I') {
        e.preventDefault();
    }
    
    // Prevent Ctrl+Shift+J (Console)
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'J') {
        e.preventDefault();
    }
    
    // Prevent Ctrl+Shift+C (Inspect)
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'C') {
        e.preventDefault();
    }
});
