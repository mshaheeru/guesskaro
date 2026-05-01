
// Shared components for Jhat Pat
// Exports: BottomNav, TimerBar, MCQOption, XPBar, CoinBadge, StreakBadge, PhoneShell

const C = {
  bg: '#1A1A2E',
  card: '#16213E',
  elevated: '#0F3460',
  orange: '#FF6B35',
  orangeGlow: 'rgba(255,107,53,0.25)',
  orangeDim: 'rgba(255,107,53,0.12)',
  gold: '#FFD700',
  green: '#00D97E',
  greenGlow: 'rgba(0,217,126,0.2)',
  red: '#FF4757',
  redGlow: 'rgba(255,71,87,0.2)',
  textPrimary: '#FFFFFF',
  textSecondary: '#8892A4',
  textMuted: '#4A5568',
  border: 'rgba(255,255,255,0.07)',
  borderOrange: 'rgba(255,107,53,0.4)',
};

// CSS injection
const injectCSS = () => {
  if (document.getElementById('jp-global-css')) return;
  const style = document.createElement('style');
  style.id = 'jp-global-css';
  style.textContent = `
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800;900&family=Noto+Nastaliq+Urdu:wght@400;500;600;700&display=swap');
    
    * { box-sizing: border-box; margin: 0; padding: 0; }
    
    .jp-urdu {
      font-family: 'Noto Nastaliq Urdu', serif;
      direction: rtl;
      text-align: right;
    }
    .jp-en {
      font-family: 'Poppins', sans-serif;
    }
    
    @keyframes jp-pulse-orange {
      0%,100% { box-shadow: 0 0 0 0 rgba(255,107,53,0.4); }
      50% { box-shadow: 0 0 0 8px rgba(255,107,53,0); }
    }
    @keyframes jp-float {
      0%,100% { transform: translateY(0px); }
      50% { transform: translateY(-6px); }
    }
    @keyframes jp-shake {
      0%,100% { transform: translateX(0); }
      20% { transform: translateX(-8px); }
      40% { transform: translateX(8px); }
      60% { transform: translateX(-5px); }
      80% { transform: translateX(5px); }
    }
    @keyframes jp-pop-in {
      0% { transform: scale(0.5); opacity: 0; }
      70% { transform: scale(1.1); }
      100% { transform: scale(1); opacity: 1; }
    }
    @keyframes jp-slide-up {
      from { transform: translateY(30px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
    @keyframes jp-fade-in {
      from { opacity: 0; }
      to { opacity: 1; }
    }
    @keyframes jp-score-pop {
      0% { transform: scale(0) translateY(20px); opacity: 0; }
      60% { transform: scale(1.3) translateY(-5px); }
      100% { transform: scale(1) translateY(0); opacity: 1; }
    }
    @keyframes jp-glow-pulse {
      0%,100% { opacity: 0.6; }
      50% { opacity: 1; }
    }
    @keyframes jp-timer-danger {
      0%,100% { transform: scaleY(1); }
      50% { transform: scaleY(1.3); }
    }
    @keyframes jp-confetti {
      0% { transform: translateY(0) rotate(0deg); opacity: 1; }
      100% { transform: translateY(300px) rotate(720deg); opacity: 0; }
    }
    @keyframes jp-slide-in-right {
      from { transform: translateX(100%); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
    }
    @keyframes jp-slide-in-left {
      from { transform: translateX(-100%); opacity: 0; }
      to { transform: translateX(0); opacity: 1; }
    }
    @keyframes jp-bounce-in {
      0% { transform: scale(0); }
      50% { transform: scale(1.2); }
      75% { transform: scale(0.9); }
      100% { transform: scale(1); }
    }
    @keyframes jp-spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }
    @keyframes jp-star-burst {
      0% { transform: scale(0) rotate(0); opacity: 1; }
      100% { transform: scale(2.5) rotate(180deg); opacity: 0; }
    }
    @keyframes jp-count-up {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .jp-btn-orange {
      background: linear-gradient(135deg, #FF6B35, #FF4500);
      color: #fff;
      border: none;
      border-radius: 16px;
      font-family: 'Poppins', sans-serif;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.15s ease;
      box-shadow: 0 4px 20px rgba(255,107,53,0.4);
    }
    .jp-btn-orange:active { transform: scale(0.96); }
    
    .jp-btn-ghost {
      background: rgba(255,255,255,0.06);
      color: rgba(255,255,255,0.7);
      border: 1px solid rgba(255,255,255,0.12);
      border-radius: 16px;
      font-family: 'Poppins', sans-serif;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .jp-btn-ghost:active { transform: scale(0.96); }
    
    .jp-card {
      background: #16213E;
      border-radius: 20px;
      border: 1px solid rgba(255,255,255,0.07);
    }
    
    .jp-card-glow {
      background: #16213E;
      border-radius: 20px;
      border: 1px solid rgba(255,107,53,0.3);
      box-shadow: 0 0 20px rgba(255,107,53,0.1), inset 0 1px 0 rgba(255,255,255,0.05);
    }
    
    .jp-mcq-option {
      background: #16213E;
      border: 1.5px solid rgba(255,255,255,0.1);
      border-radius: 16px;
      cursor: pointer;
      transition: all 0.15s ease;
      position: relative;
      overflow: hidden;
    }
    .jp-mcq-option::before {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(135deg, rgba(255,255,255,0.03), transparent);
      pointer-events: none;
    }
    .jp-mcq-option:active { transform: scale(0.97); }
    .jp-mcq-option.correct {
      background: rgba(0,217,126,0.15);
      border-color: #00D97E;
      box-shadow: 0 0 20px rgba(0,217,126,0.3);
    }
    .jp-mcq-option.wrong {
      background: rgba(255,71,87,0.15);
      border-color: #FF4757;
      box-shadow: 0 0 20px rgba(255,71,87,0.2);
    }
    .jp-mcq-option.disabled { pointer-events: none; opacity: 0.5; }
    
    .jp-bottom-nav {
      position: absolute;
      bottom: 0; left: 0; right: 0;
      background: #16213E;
      border-top: 1px solid rgba(255,255,255,0.07);
      display: flex;
      align-items: center;
      justify-content: space-around;
      padding: 10px 0 20px;
    }
    
    .jp-nav-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
      cursor: pointer;
      padding: 6px 20px;
      border-radius: 12px;
      transition: all 0.2s ease;
    }
    .jp-nav-item.active .jp-nav-label { color: #FF6B35; }
    .jp-nav-item.active .jp-nav-icon { color: #FF6B35; filter: drop-shadow(0 0 6px rgba(255,107,53,0.6)); }
    
    ::-webkit-scrollbar { width: 0; }
  `;
  document.head.appendChild(style);
};

// BottomNav
function BottomNav({ active, onNavigate }) {
  const items = [
    { id: 'home', icon: '⌂', label: 'Home' },
    { id: 'library', icon: '◫', label: 'Library' },
    { id: 'profile', icon: '◉', label: 'Profile' },
  ];
  return (
    <div className="jp-bottom-nav">
      {items.map(item => (
        <div
          key={item.id}
          className={`jp-nav-item ${active === item.id ? 'active' : ''}`}
          onClick={() => onNavigate(item.id)}
        >
          <span className="jp-nav-icon jp-en" style={{ fontSize: 20, color: active === item.id ? C.orange : C.textSecondary, lineHeight: 1 }}>
            {item.icon === '⌂' ? (
              <svg width="22" height="20" viewBox="0 0 22 20" fill="none">
                <path d="M1 9L11 1L21 9V19C21 19.5523 20.5523 20 20 20H14V14H8V20H2C1.44772 20 1 19.5523 1 19V9Z" stroke="currentColor" strokeWidth="1.8" fill={active === item.id ? C.orange : 'none'}/>
              </svg>
            ) : item.icon === '◫' ? (
              <svg width="22" height="20" viewBox="0 0 22 20" fill="none">
                <rect x="1" y="1" width="20" height="18" rx="3" stroke="currentColor" strokeWidth="1.8"/>
                <path d="M1 7H21" stroke="currentColor" strokeWidth="1.8"/>
                <path d="M8 7V19" stroke="currentColor" strokeWidth="1.8"/>
              </svg>
            ) : (
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <circle cx="10" cy="7" r="4" stroke="currentColor" strokeWidth="1.8"/>
                <path d="M1 18C1 14.134 5.02944 11 10 11C14.9706 11 19 14.134 19 18" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
              </svg>
            )}
          </span>
          <span className="jp-nav-label jp-en" style={{ fontSize: 10, fontWeight: 600, color: active === item.id ? C.orange : C.textSecondary }}>
            {item.label}
          </span>
        </div>
      ))}
    </div>
  );
}

// Timer Bar
function TimerBar({ pct, danger }) {
  const color = pct > 0.6 ? '#00D97E' : pct > 0.3 ? '#FFD700' : '#FF4757';
  return (
    <div style={{ height: 6, background: 'rgba(255,255,255,0.08)', borderRadius: 4, overflow: 'hidden', position: 'relative' }}>
      <div style={{
        height: '100%',
        width: `${pct * 100}%`,
        background: `linear-gradient(90deg, ${color}aa, ${color})`,
        borderRadius: 4,
        transition: 'width 0.25s linear, background 0.5s ease',
        boxShadow: `0 0 8px ${color}88`,
        animation: pct < 0.3 ? 'jp-timer-danger 0.4s ease-in-out infinite' : 'none',
      }} />
    </div>
  );
}

// XP Bar
function XPBar({ pct, level }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
      <div style={{
        background: C.orange,
        color: '#fff',
        fontFamily: 'Poppins, sans-serif',
        fontWeight: 800,
        fontSize: 12,
        width: 32, height: 32,
        borderRadius: 10,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 0 10px rgba(255,107,53,0.5)',
        flexShrink: 0,
      }}>
        {level}
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ height: 8, background: 'rgba(255,255,255,0.08)', borderRadius: 4, overflow: 'hidden' }}>
          <div style={{
            height: '100%',
            width: `${pct * 100}%`,
            background: 'linear-gradient(90deg, #FF6B35, #FFD700)',
            borderRadius: 4,
            boxShadow: '0 0 8px rgba(255,107,53,0.5)',
            transition: 'width 1s ease',
          }} />
        </div>
      </div>
    </div>
  );
}

// Coin Badge
function CoinBadge({ amount }) {
  return (
    <div className="jp-en" style={{ display: 'flex', alignItems: 'center', gap: 5, background: 'rgba(255,215,0,0.12)', border: '1px solid rgba(255,215,0,0.3)', borderRadius: 20, padding: '4px 10px' }}>
      <span style={{ fontSize: 14 }}>🪙</span>
      <span style={{ color: C.gold, fontWeight: 700, fontSize: 14 }}>{amount}</span>
    </div>
  );
}

// Streak Badge
function StreakBadge({ count }) {
  return (
    <div className="jp-en" style={{ display: 'flex', alignItems: 'center', gap: 5, background: 'rgba(255,107,53,0.12)', border: '1px solid rgba(255,107,53,0.3)', borderRadius: 20, padding: '4px 10px' }}>
      <span style={{ fontSize: 14 }}>🔥</span>
      <span style={{ color: C.orange, fontWeight: 700, fontSize: 14 }}>{count}</span>
    </div>
  );
}

// MCQ Option
function MCQOption({ text, state, onClick, index }) {
  const delay = index * 0.07;
  return (
    <div
      className={`jp-mcq-option ${state || ''}`}
      onClick={state ? undefined : onClick}
      style={{
        padding: '14px 18px',
        animation: `jp-slide-up 0.3s ease ${delay}s both`,
      }}
    >
      <p className="jp-urdu" style={{
        fontSize: 18,
        color: state === 'correct' ? '#00D97E' : state === 'wrong' ? '#FF4757' : C.textPrimary,
        fontWeight: state ? 700 : 400,
        lineHeight: 1.8,
        margin: 0,
      }}>
        {state === 'correct' ? '✓ ' : state === 'wrong' ? '✗ ' : ''}{text}
      </p>
    </div>
  );
}

// Confetti
function Confetti({ active }) {
  if (!active) return null;
  const pieces = Array.from({ length: 18 }, (_, i) => ({
    x: Math.random() * 100,
    color: [C.orange, C.gold, C.green, '#FF6B9D', '#C77DFF'][Math.floor(Math.random() * 5)],
    delay: Math.random() * 0.5,
    size: 6 + Math.random() * 8,
    shape: Math.random() > 0.5 ? 'circle' : 'rect',
  }));
  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden', zIndex: 10 }}>
      {pieces.map((p, i) => (
        <div key={i} style={{
          position: 'absolute',
          left: `${p.x}%`,
          top: -20,
          width: p.size,
          height: p.size,
          borderRadius: p.shape === 'circle' ? '50%' : 3,
          background: p.color,
          animation: `jp-confetti ${1.5 + Math.random()}s ease ${p.delay}s forwards`,
        }} />
      ))}
    </div>
  );
}

// Image placeholder
function ImgPlaceholder({ label, style = {} }) {
  return (
    <div style={{
      background: 'repeating-linear-gradient(45deg, #0F3460 0px, #0F3460 10px, #16213E 10px, #16213E 20px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexDirection: 'column', gap: 8,
      ...style,
    }}>
      <div style={{ fontSize: 28, opacity: 0.5 }}>🖼</div>
      <div className="jp-en" style={{ color: C.textMuted, fontSize: 11, textAlign: 'center', fontFamily: 'monospace', padding: '0 12px' }}>{label}</div>
    </div>
  );
}

injectCSS();

// Export all
Object.assign(window, {
  C, BottomNav, TimerBar, XPBar, CoinBadge, StreakBadge, MCQOption, Confetti, ImgPlaceholder,
});
