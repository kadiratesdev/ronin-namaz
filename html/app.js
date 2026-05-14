// Durum değişkenleri
let currentScreen = 'selection';
let selectedPrayer = null;
let selectedType = 'fard';
let autoEnabled = true;
let sequence = [];
let currentStep = 0;
let totalSteps = 0;
let autoTimer = null;

// Element referansları
const screens = {
    selection: document.getElementById('prayer-selection'),
    detail: document.getElementById('prayer-detail'),
    flow: document.getElementById('prayer-flow'),
    completion: document.getElementById('completion-screen'),
    settings: document.getElementById('settings-screen'),
    about: document.getElementById('about-screen'),
    zikir: document.getElementById('zikir-screen')
};

const app = document.getElementById('app');
const gameTime = document.getElementById('game-time');
const prayerCards = document.getElementById('prayer-cards');
const specialPrayerCards = document.getElementById('special-prayer-cards');

// ========== NUI Mesajları ==========
window.addEventListener('message', function(event) {
    const data = event.data;
    if (!data) return;

    switch (data.action) {
        case 'open':
            openApp(data.data);
            break;
        case 'close':
            closeApp();
            break;
        case 'hideApp':
            hideApp();
            break;
        case 'showFlow':
            showFlowExisting(data.data);
            break;
        case 'startPrayer':
            startFlow(data.data);
            break;
        case 'updateStep':
            updateFlow(data.data);
            break;
        case 'finishPrayer':
            showCompletion(data.data);
            break;
        case 'cancelPrayer':
            resetToSelection();
            break;
        case 'reminder':
            handleReminder(data.data);
            break;
    }
});

// ========== Uygulama Aç/Kapat ==========
function openApp(data) {
    app.classList.remove('hidden');
    if (data) {
        gameTime.textContent = `${String(data.currentHour).padStart(2, '0')}:${String(data.currentMinute).padStart(2, '0')}`;
        renderPrayerCards(data.prayerTimes, data.currentPrayer);
        renderSpecialPrayerCards(data.specialPrayers);
        const allPrayers = [...(data.prayerTimes || []), ...(data.specialPrayers || [])];
        if (allPrayers.length) prayerTimesData = allPrayers;
    }
    showScreen('selection');
}

function closeApp() {
    app.classList.add('hidden');
    fetch('https://ronin-namaz/close', { method: 'POST', body: '{}' });
}

function hideApp() {
    app.classList.add('hidden');
}

function showScreen(screen) {
    currentScreen = screen;
    Object.values(screens).forEach(s => s.classList.add('hidden'));
    if (screens[screen]) {
        screens[screen].classList.remove('hidden');
    }
}

// ========== Namaz Kartları ==========
function renderPrayerCards(prayerTimes, currentPrayer) {
    prayerCards.innerHTML = '';
    
    if (!prayerTimes) return;
    
    prayerTimes.forEach(prayer => {
        const isActive = currentPrayer && currentPrayer.id === prayer.id;
        const card = document.createElement('div');
        card.className = `prayer-card ${isActive ? 'active' : ''}`;
        card.innerHTML = `
            ${isActive ? '<span class="card-badge">Şimdi</span>' : ''}
            <span class="card-icon">${prayer.icon}</span>
            <div class="card-name">${prayer.name}</div>
            <div class="card-time">${String(prayer.startHour).padStart(2,'0')}:${String(prayer.startMinute).padStart(2,'0')} - ${String(prayer.endHour).padStart(2,'0')}:${String(prayer.endMinute).padStart(2,'0')}</div>
        `;
        card.addEventListener('click', () => showPrayerDetail(prayer));
        prayerCards.appendChild(card);
    });
}

function renderSpecialPrayerCards(specialPrayers) {
    if (!specialPrayerCards) return;
    specialPrayerCards.innerHTML = '';
    
    if (!specialPrayers || specialPrayers.length === 0) {
        specialPrayerCards.style.display = 'none';
        return;
    }
    
    specialPrayerCards.style.display = 'grid';
    
    specialPrayers.forEach(prayer => {
        const card = document.createElement('div');
        card.className = 'prayer-card special';
        card.innerHTML = `
            <span class="card-icon">${prayer.icon}</span>
            <div class="card-name">${prayer.name}</div>
            <div class="card-time">${prayer.description}</div>
        `;
        card.addEventListener('click', () => showPrayerDetail(prayer));
        specialPrayerCards.appendChild(card);
    });
}

// ========== Namaz Detayı ==========
function showPrayerDetail(prayer) {
    selectedPrayer = prayer;
    
    document.getElementById('detail-icon').textContent = prayer.icon;
    document.getElementById('detail-name').textContent = prayer.name;
    document.getElementById('detail-desc').textContent = prayer.description;
    
    const options = {
        sunnah: document.getElementById('option-sunnah'),
        fard: document.getElementById('option-fard'),
        extra: document.getElementById('option-extra'),
        vitr: document.getElementById('option-vitr')
    };
    
    // Cenaze namazı için özel ekran (rekât seçimi yok)
    if (prayer.id === 'cenaze') {
        Object.values(options).forEach(opt => opt.style.display = 'none');
        document.getElementById('rakah-options').style.display = 'none';
        selectedType = 'cenaze';
        document.getElementById('btn-start').style.display = 'flex';
        showScreen('detail');
        return;
    }
    
    // Normal namazlar için mevcut mantık
    document.getElementById('rakah-options').style.display = 'grid';
    Object.values(options).forEach(opt => {
        opt.style.display = '';
        opt.classList.remove('disabled', 'active');
    });
    
    selectedType = 'fard';
    
    if (prayer.sunnah && prayer.sunnah > 0) {
        options.sunnah.classList.remove('disabled');
        document.getElementById('count-sunnah').textContent = `${prayer.sunnah} Rekât`;
    } else {
        options.sunnah.classList.add('disabled');
        document.getElementById('count-sunnah').textContent = '-';
    }
    
    if (prayer.fard && prayer.fard > 0) {
        options.fard.classList.remove('disabled');
        document.getElementById('count-fard').textContent = `${prayer.fard} Rekât`;
    } else {
        options.fard.classList.add('disabled');
        document.getElementById('count-fard').textContent = '-';
    }
    
    if (prayer.extraSunnah && prayer.extraSunnah > 0) {
        options.extra.classList.remove('disabled');
        document.getElementById('count-extra').textContent = `${prayer.extraSunnah} Rekât`;
    } else {
        options.extra.classList.add('disabled');
        document.getElementById('count-extra').textContent = '-';
    }
    
    if (prayer.vitr && prayer.vitr > 0) {
        options.vitr.classList.remove('disabled');
        document.getElementById('count-vitr').textContent = `${prayer.vitr} Rekât`;
    } else {
        options.vitr.classList.add('disabled');
        document.getElementById('count-vitr').textContent = '-';
    }
    
    Object.values(options).forEach(opt => opt.classList.remove('active'));
    if (prayer.fard && prayer.fard > 0) {
        options.fard.classList.add('active');
        selectedType = 'fard';
    } else if (prayer.sunnah && prayer.sunnah > 0) {
        options.sunnah.classList.add('active');
        selectedType = 'sunnah';
    }
    
    document.getElementById('btn-start').style.display = 'flex';
    showScreen('detail');
}

// Rekât tipi seçimi
document.querySelectorAll('.rakah-type').forEach(el => {
    el.addEventListener('click', function() {
        if (this.classList.contains('disabled')) return;
        document.querySelectorAll('.rakah-type').forEach(e => e.classList.remove('active'));
        this.classList.add('active');
        selectedType = this.dataset.type;
    });
});

// Geri butonu
document.getElementById('btn-back').addEventListener('click', () => {
    showScreen('selection');
});

// Başla butonu
document.getElementById('btn-start').addEventListener('click', () => {
    if (!selectedPrayer) return;
    
    fetch('https://ronin-namaz/startPrayer', {
        method: 'POST',
        body: JSON.stringify({
            prayerId: selectedPrayer.id,
            type: selectedType
        })
    });
});

// ========== Namaz Akışı ==========
function startFlow(data) {
    sequence = data.sequence || [];
    totalSteps = data.totalSteps || 0;
    currentStep = 0;
    autoEnabled = true;
    
    document.getElementById('flow-prayer-name').textContent = data.prayerName;
    document.getElementById('flow-type').textContent = typeLabel(data.prayerType);
    
    updateFlow({
        currentStep: 0,
        totalSteps: totalSteps,
        currentRakah: 0,
        totalRakah: data.totalRakah,
        stepName: 'Hazırlık',
        stepIcon: '\uD83E\uDD32',
        duration: 0,
        prayerName: data.prayerName,
        prayerType: data.prayerType,
        sequence: sequence
    });
    
    showScreen('flow');
}

function showFlowExisting(data) {
    if (!data) return;
    sequence = data.sequence || [];
    totalSteps = data.totalSteps || 0;
    currentStep = data.currentStep || 0;
    autoEnabled = data.autoEnabled !== undefined ? data.autoEnabled : true;
    
    document.getElementById('flow-prayer-name').textContent = data.prayerName || '';
    document.getElementById('flow-type').textContent = typeLabel(data.prayerType);
    
    app.classList.remove('hidden');
    updateFlow(data);
    showScreen('flow');
}

function updateFlow(data) {
    currentStep = data.currentStep;
    totalSteps = data.totalSteps;
    sequence = data.sequence || sequence;
    
    const rakahLabel = data.prayerType === 'cenaze' ? 'Tekbir' : 'Rekât';
    document.getElementById('rakah-text').textContent = 
        `${data.currentRakah} / ${data.totalRakah} ${rakahLabel}`;
    
    document.getElementById('position-icon').textContent = data.stepIcon;
    document.getElementById('position-name').textContent = data.stepName;
    
    document.getElementById('step-text').textContent = 
        `${data.currentStep} / ${data.totalSteps} Adım`;
    
    const progress = totalSteps > 0 ? (currentStep / totalSteps) * 100 : 0;
    document.getElementById('progress-fill').style.width = `${progress}%`;
    
    const circumference = 2 * Math.PI * 76;
    const ringProgress = totalSteps > 0 ? (currentStep / totalSteps) * circumference : circumference;
    const ringFill = document.getElementById('progress-ring');
    ringFill.style.strokeDashoffset = circumference - ringProgress;
    
    renderEmoteList();
    
    const autoBtn = document.getElementById('btn-auto');
    if (autoEnabled) {
        autoBtn.classList.add('active');
        autoBtn.innerHTML = '<span>▶</span> Otomatik';
    } else {
        autoBtn.classList.remove('active');
        autoBtn.innerHTML = '<span>⏸</span> Manuel';
    }
    
    if (autoTimer) clearTimeout(autoTimer);
}

function renderEmoteList() {
    const list = document.getElementById('emote-list');
    list.innerHTML = '';
    
    sequence.forEach((step, index) => {
        const item = document.createElement('div');
        item.className = `emote-item ${index + 1 === currentStep ? 'active' : ''} ${index + 1 < currentStep ? 'completed' : ''}`;
        const rakahLabel = step.type === 'cenaze' ? 'Tekbir' : 'Rekât';
        item.innerHTML = `
            <span class="item-number">${index + 1}</span>
            <span class="item-icon">${step.emote.icon}</span>
            <span class="item-name">${step.stepName}</span>
            <span class="item-rakah">${step.rakah}. ${rakahLabel}</span>
        `;
        item.addEventListener('click', () => {
            fetch('https://ronin-namaz/goToStep', {
                method: 'POST',
                body: JSON.stringify({ index: index + 1 })
            });
        });
        list.appendChild(item);
    });
    
    const activeItem = list.querySelector('.active');
    if (activeItem) {
        activeItem.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
}

function typeLabel(type) {
    const labels = {
        fard: 'Farz',
        sunnah: 'Sünnet',
        extraSunnah: 'Son Sünnet',
        vitr: 'Vitir',
        cenaze: 'Cenaze'
    };
    return labels[type] || type;
}

// ========== Akış Kontrolleri ==========
document.getElementById('btn-prev').addEventListener('click', () => {
    fetch('https://ronin-namaz/prevStep', { method: 'POST', body: '{}' });
});

document.getElementById('btn-next').addEventListener('click', () => {
    fetch('https://ronin-namaz/nextStep', { method: 'POST', body: '{}' });
});

document.getElementById('btn-auto').addEventListener('click', () => {
    autoEnabled = !autoEnabled;
    fetch('https://ronin-namaz/toggleAuto', {
        method: 'POST',
        body: JSON.stringify({ enabled: autoEnabled })
    });
    
    const btn = document.getElementById('btn-auto');
    if (autoEnabled) {
        btn.classList.add('active');
        btn.innerHTML = '<span>▶</span> Otomatik';
    } else {
        btn.classList.remove('active');
        btn.innerHTML = '<span>⏸</span> Manuel';
    }
});

document.getElementById('btn-finish').addEventListener('click', () => {
    fetch('https://ronin-namaz/finishPrayer', { method: 'POST', body: '{}' });
});

document.getElementById('btn-cancel').addEventListener('click', () => {
    fetch('https://ronin-namaz/cancelPrayer', { method: 'POST', body: '{}' });
});

// ========== Tamamlama Ekranı ==========
function showCompletion(data) {
    app.classList.remove('hidden');
    let text = '';
    if (data.prayerType === 'cenaze') {
        text = `${data.prayerName} namazınızı eda ettiniz.`;
    } else {
        text = `${data.prayerName} ${typeLabel(data.prayerType)} namazınızı eda ettiniz.`;
    }
    document.getElementById('completion-text').textContent = text;
    showScreen('completion');
}

document.getElementById('btn-complete-close').addEventListener('click', () => {
    resetToSelection();
});

function resetToSelection() {
    selectedPrayer = null;
    selectedType = 'fard';
    sequence = [];
    currentStep = 0;
    totalSteps = 0;
    autoEnabled = true;
    if (autoTimer) clearTimeout(autoTimer);
    closeApp();
}

// ========== Klavye ==========
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        if (currentScreen === 'flow' && sequence.length > 0) {
            fetch('https://ronin-namaz/close', { method: 'POST', body: '{}' });
        } else {
            closeApp();
        }
    }
});

// ========== SVG Gradient Tanımı ==========
(function addSVGGradient() {
    const svg = document.querySelector('.progress-ring');
    if (svg) {
        const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs');
        const gradient = document.createElementNS('http://www.w3.org/2000/svg', 'linearGradient');
        gradient.setAttribute('id', 'gradient');
        gradient.setAttribute('x1', '0%');
        gradient.setAttribute('y1', '0%');
        gradient.setAttribute('x2', '100%');
        gradient.setAttribute('y2', '100%');
        
        const stop1 = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
        stop1.setAttribute('offset', '0%');
        stop1.setAttribute('stop-color', '#d4af37');
        
        const stop2 = document.createElementNS('http://www.w3.org/2000/svg', 'stop');
        stop2.setAttribute('offset', '100%');
        stop2.setAttribute('stop-color', '#f39c12');
        
        gradient.appendChild(stop1);
        gradient.appendChild(stop2);
        defs.appendChild(gradient);
        svg.insertBefore(defs, svg.firstChild);
    }
})();

// ========== LOCAL STORAGE / HATIRLATICI ==========
const SETTINGS_KEY = 'ronin_namaz_settings';
let prayerTimesData = [];

function getDefaultSettings() {
    return {
        enabled: true,
        beforeStart: 15,
        beforeEnd: 10,
        prayers: { fajr: true, dhuhr: true, asr: true, maghrib: true, isha: true, cuma: true, teravih: true, cenaze: true }
    };
}

function loadSettings() {
    try {
        const raw = localStorage.getItem(SETTINGS_KEY);
        if (!raw) return getDefaultSettings();
        const parsed = JSON.parse(raw);
        const defaults = getDefaultSettings();
        return { ...defaults, ...parsed, prayers: { ...defaults.prayers, ...parsed.prayers } };
    } catch (e) {
        return getDefaultSettings();
    }
}

function saveSettings(settings) {
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
}

let appSettings = loadSettings();

function handleReminder(data) {
    if (!appSettings.enabled) return;
    if (!data.prayerId || !appSettings.prayers[data.prayerId]) return;

    const typeText = data.type === 'before' ? 'başlamasına' : 'bitimine';
    const title = data.type === 'before' ? 'Namaz Vakti Yaklaşıyor' : 'Vakit Bitmek Üzere';
    
    showToast({
        icon: data.prayerIcon,
        title: title,
        body: `${data.prayerName} namazının ${typeText} ${data.minutesLeft} dakika kaldı.`,
        prayerId: data.prayerId,
        actions: true
    });
}

let toastIdCounter = 0;
function showToast({ icon, title, body, prayerId, actions = false }) {
    const container = document.getElementById('toast-container');
    const id = 'toast-' + (++toastIdCounter);
    
    const toast = document.createElement('div');
    toast.id = id;
    toast.className = 'toast';
    toast.innerHTML = `
        <div class="toast-header">
            <span class="toast-icon">${icon}</span>
            <span class="toast-title">${title}</span>
        </div>
        <div class="toast-body">${body}</div>
        ${actions ? `
        <div class="toast-footer">
            <button class="toast-btn toast-btn-primary" data-toast-action="pray" data-prayer="${prayerId}">Namaz Kıl</button>
            <button class="toast-btn toast-btn-secondary" data-toast-action="dismiss" data-toast-id="${id}">Kapat</button>
        </div>
        ` : ''}
    `;
    
    container.appendChild(toast);
    
    toast.addEventListener('click', function(e) {
        const btn = e.target.closest('[data-toast-action]');
        if (!btn) return;
        const action = btn.dataset.toastAction;
        if (action === 'dismiss') {
            dismissToast(btn.dataset.toastId);
        } else if (action === 'pray') {
            dismissToast(id);
            fetch('https://ronin-namaz/close', { method: 'POST', body: '{}' });
        }
    });
    
    setTimeout(() => { dismissToast(id); }, 8000);
}

function dismissToast(id) {
    const toast = document.getElementById(id);
    if (!toast) return;
    toast.classList.add('toast-hide');
    setTimeout(() => { if (toast.parentNode) toast.parentNode.removeChild(toast); }, 300);
}

// ========== AYARLAR EKRANI ==========
function openSettings() {
    const settings = loadSettings();
    document.getElementById('setting-enabled').checked = settings.enabled;
    document.getElementById('setting-before-start').value = settings.beforeStart;
    document.getElementById('setting-before-end').value = settings.beforeEnd;
    renderPrayerToggles(settings.prayers);
    showScreen('settings');
}

function renderPrayerToggles(prayerStates) {
    const container = document.getElementById('prayer-toggles');
    container.innerHTML = '';
    prayerTimesData.forEach(prayer => {
        const item = document.createElement('div');
        item.className = 'prayer-toggle-item';
        item.innerHTML = `
            <div class="prayer-toggle-info">
                <span>${prayer.icon}</span>
                <span>${prayer.name}</span>
            </div>
            <label class="toggle-switch">
                <input type="checkbox" data-prayer="${prayer.id}" ${prayerStates[prayer.id] ? 'checked' : ''}>
                <span class="toggle-slider"></span>
            </label>
        `;
        container.appendChild(item);
    });
}

document.getElementById('btn-about').addEventListener('click', () => {
    showScreen('about');
});

document.getElementById('btn-about-back').addEventListener('click', () => {
    showScreen('selection');
});

document.getElementById('btn-settings').addEventListener('click', () => {
    openSettings();
});

document.getElementById('btn-settings-back').addEventListener('click', () => {
    showScreen('selection');
});

document.getElementById('btn-save-settings').addEventListener('click', () => {
    const prayers = {};
    document.querySelectorAll('#prayer-toggles input[type="checkbox"]').forEach(input => {
        prayers[input.dataset.prayer] = input.checked;
    });
    
    const newSettings = {
        enabled: document.getElementById('setting-enabled').checked,
        beforeStart: parseInt(document.getElementById('setting-before-start').value) || 15,
        beforeEnd: parseInt(document.getElementById('setting-before-end').value) || 10,
        prayers: prayers
    };
    
    saveSettings(newSettings);
    appSettings = newSettings;
    showToast({
        icon: '\uD83D\uDCBE',
        title: 'Ayarlar Kaydedildi',
        body: 'Hatırlatıcı tercihleriniz kaydedildi.'
    });
    showScreen('selection');
});

// ========== ZikirMatik ==========
let zikirCount = 0;
let zikirTarget = 99;

document.getElementById('btn-zikir').addEventListener('click', () => {
    openZikir();
});

document.getElementById('btn-zikir-back').addEventListener('click', () => {
    showScreen('selection');
});

function openZikir() {
    updateZikirUI();
    showScreen('zikir');
}

document.getElementById('zikir-btn').addEventListener('click', () => {
    zikirCount++;
    updateZikirUI();
    if (zikirCount >= zikirTarget) {
        showToast({
            icon: '📿',
            title: 'Zikir Tamamlandı',
            body: `Hedefinize ulaştınız! ${zikirTarget} zikir çekildi. Allah kabul etsin.`
        });
    }
});

document.querySelectorAll('.zikir-target-btn').forEach(btn => {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.zikir-target-btn').forEach(b => b.classList.remove('active'));
        this.classList.add('active');
        zikirTarget = parseInt(this.dataset.target);
        zikirCount = 0;
        updateZikirUI();
    });
});

document.getElementById('zikir-reset').addEventListener('click', () => {
    zikirCount = 0;
    updateZikirUI();
});

function updateZikirUI() {
    document.getElementById('zikir-count').textContent = zikirCount;
    document.getElementById('zikir-target').textContent = zikirTarget;
    document.getElementById('zikir-progress-text').textContent = `${zikirCount} / ${zikirTarget}`;
    const pct = zikirTarget > 0 ? Math.min((zikirCount / zikirTarget) * 100, 100) : 0;
    document.getElementById('zikir-progress-fill').style.width = `${pct}%`;
}
