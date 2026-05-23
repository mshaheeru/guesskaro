// ============================================================================
// Jhat Pat — SUNNY QUIZ theme: shared tokens, primitives, css
// ============================================================================
// Exports (on window): C, BottomNav, TimerBar, XPBar, CoinBadge, StreakBadge,
//                      MCQOption, Confetti, ImgPlaceholder, BtnPrimary, BtnGhost,
//                      Card, Sticker, SunBlob

const C = {
  // Surfaces
  paper:      '#FFF1D6',   // primary screen bg
  paperWarm:  '#FCE4B6',   // alt surface (inputs, daily goal track)
  card:       '#FFFFFF',   // card bg
  ink:        '#2A1810',   // outline + primary text + offset shadow
  inkSoft:    '#6B5D52',   // secondary text
  inkMuted:   '#A89580',   // tertiary text / disabled
  // Accents
  tomato:     '#E94F37',   // primary CTA, brand red, wrong answer
  marigold:   '#FFB627',   // rewards, coins, daily goal
  teal:       '#2A9D8F',   // correct answer, learn mode secondary
  purple:     '#7E57C2',   // stage-2 quiz, accents
  sky:        '#5DBBE8',   // chill accent
  // Mode colors (used for mode cards)
  modeQuick:    '#E94F37',
  modeLearn:    '#7E57C2',
  modeSpeed:    '#FFB627',
  modeCategory: '#2A9D8F',
};

// ============================================================================
// Global CSS (fonts, keyframes, primitives)
// ============================================================================
const injectCSS = () => {
  if (document.getElementById('jp-global-css')) return;
  const style = document.createElement('style');
  style.id = 'jp-global-css';
  style.textContent = `
    @import url('https://fonts.googleapis.com/css2?family=Nunito:wght@600;700;800;900&family=Noto+Nastaliq+Urdu:wght@400;500;700&display=swap');

    * { box-sizing: border-box; margin: 0; padding: 0; }

    .jp-urdu {
      font-family: 'Noto Nastaliq Urdu', serif;
      direction: rtl;
      text-align: right;
    }
    .jp-en {
      font-family: 'Nunito', system-ui, sans-serif;
    }

    /* ── Keyframes ─────────────────────────────────────── */
    @keyframes jp-float       { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-6px); } }
    @keyframes jp-slide-up    { from { transform: translateY(24px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
    @keyframes jp-pop-in      { 0% { transform: scale(0.6); opacity: 0; } 70% { transform: scale(1.08); } 100% { transform: scale(1); opacity: 1; } }
    @keyframes jp-bounce-in   { 0% { transform: scale(0); } 60% { transform: scale(1.2); } 80% { transform: scale(0.95); } 100% { transform: scale(1); } }
    @keyframes jp-fade-in     { from { opacity: 0; } to { opacity: 1; } }
    @keyframes jp-score-pop   { 0% { transform: scale(0) translateY(20px); opacity: 0; } 60% { transform: scale(1.25); } 100% { transform: scale(1) translateY(0); opacity: 1; } }
    @keyframes jp-count-up    { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes jp-shake       { 0%,100% { transform: translateX(0); } 25% { transform: translateX(-6px); } 75% { transform: translateX(6px); } }
    @keyframes jp-timer-pulse { 0%,100% { transform: scaleY(1); } 50% { transform: scaleY(1.4); } }
    @keyframes jp-confetti    { 0% { transform: translateY(-30px) rotate(0); opacity: 1; } 100% { transform: translateY(380px) rotate(720deg); opacity: 0; } }
    @keyframes jp-press       { 0% { transform: translate(0,0); box-shadow: 4px 4px 0 #2A1810; } 100% { transform: translate(2px,2px); box-shadow: 2px 2px 0 #2A1810; } }
    @keyframes jp-sparkle     { 0%,100% { opacity: 0.6; transform: scale(0.9); } 50% { opacity: 1; transform: scale(1.1); } }

    /* ── Button primary (chunky tomato) ────────────────── */
    .jp-btn-primary {
      background: ${C.tomato};
      color: #fff;
      border: 2.5px solid ${C.ink};
      border-radius: 18px;
      font-family: 'Nunito', sans-serif;
      font-weight: 900;
      cursor: pointer;
      box-shadow: 4px 4px 0 ${C.ink};
      transition: transform 0.1s ease, box-shadow 0.1s ease;
    }
    .jp-btn-primary:hover  { transform: translate(-1px,-1px); box-shadow: 5px 5px 0 ${C.ink}; }
    .jp-btn-primary:active { transform: translate(2px,2px);  box-shadow: 1px 1px 0 ${C.ink}; }
    .jp-btn-primary:disabled { opacity: 0.4; cursor: not-allowed; box-shadow: 4px 4px 0 ${C.ink}; }

    /* ── Button ghost (cream outline) ──────────────────── */
    .jp-btn-ghost {
      background: ${C.card};
      color: ${C.ink};
      border: 2.5px solid ${C.ink};
      border-radius: 18px;
      font-family: 'Nunito', sans-serif;
      font-weight: 800;
      cursor: pointer;
      box-shadow: 4px 4px 0 ${C.ink};
      transition: transform 0.1s ease, box-shadow 0.1s ease;
    }
    .jp-btn-ghost:hover  { transform: translate(-1px,-1px); box-shadow: 5px 5px 0 ${C.ink}; }
    .jp-btn-ghost:active { transform: translate(2px,2px);  box-shadow: 1px 1px 0 ${C.ink}; }

    /* ── Card ──────────────────────────────────────────── */
    .jp-card {
      background: ${C.card};
      border: 2.5px solid ${C.ink};
      border-radius: 24px;
      box-shadow: 4px 4px 0 ${C.ink};
    }

    /* ── MCQ Option ────────────────────────────────────── */
    .jp-mcq-option {
      background: ${C.card};
      border: 2.5px solid ${C.ink};
      border-radius: 20px;
      cursor: pointer;
      box-shadow: 3px 3px 0 ${C.ink};
      transition: transform 0.1s ease, box-shadow 0.1s ease, background 0.2s ease, border-color 0.2s ease;
      position: relative;
    }
    .jp-mcq-option:hover { transform: translate(-1px,-1px); box-shadow: 4px 4px 0 ${C.ink}; }
    .jp-mcq-option:active { transform: translate(2px,2px); box-shadow: 1px 1px 0 ${C.ink}; }
    .jp-mcq-option.correct {
      background: #DFF3F0;
      border-color: ${C.teal};
      box-shadow: 3px 3px 0 ${C.teal};
    }
    .jp-mcq-option.wrong {
      background: #FBE0DC;
      border-color: ${C.tomato};
      box-shadow: 3px 3px 0 ${C.tomato};
      animation: jp-shake 0.4s ease;
    }
    .jp-mcq-option.disabled { pointer-events: none; opacity: 0.45; box-shadow: 3px 3px 0 ${C.ink}; }

    ::-webkit-scrollbar { width: 0; }
  `;
  document.head.appendChild(style);
};

// ============================================================================
// Sun blob — soft warm gradient circle for screen backgrounds
// ============================================================================
function SunBlob({ top = -100, right = -120, size = 320, opacity = 1, color = C.marigold }) {
  return (
    <div style={{
      position: 'absolute', top, right, width: size, height: size,
      borderRadius: '50%', pointerEvents: 'none', opacity,
      background: `radial-gradient(circle, ${color} 0%, ${color}55 55%, transparent 78%)`,
    }} />
  );
}

// ============================================================================
// Sticker — small badge with rotation + ink outline + offset shadow
// ============================================================================
function Sticker({ children, color = C.marigold, rotate = -4, style = {} }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: '5px 11px', borderRadius: 999,
      background: color, color: C.ink,
      border: `2px solid ${C.ink}`,
      boxShadow: `2.5px 2.5px 0 ${C.ink}`,
      transform: `rotate(${rotate}deg)`,
      fontFamily: 'Nunito, sans-serif',
      fontWeight: 800, fontSize: 13,
      ...style,
    }}>
      {children}
    </div>
  );
}

// ============================================================================
// BottomNav — chunky cream pill with marigold active tab
// ============================================================================
function BottomNav({ active, onNavigate }) {
  const items = [
    { id: 'home',    label: 'Home',    ur: 'گھر',  icon: HomeIcon },
    { id: 'library', label: 'Library', ur: 'کتب', icon: BookIcon },
    { id: 'profile', label: 'You',     ur: 'آپ',  icon: UserIcon },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 20, left: 16, right: 16, zIndex: 5,
      background: C.card, borderRadius: 999, border: `2.5px solid ${C.ink}`,
      boxShadow: `4px 4px 0 ${C.ink}`,
      display: 'flex', height: 60, alignItems: 'center', padding: 5,
    }}>
      {items.map(item => {
        const isActive = active === item.id;
        const Icon = item.icon;
        return (
          <div
            key={item.id}
            onClick={() => onNavigate(item.id)}
            style={{
              flex: isActive ? 1.4 : 1,
              height: 46, margin: 0,
              borderRadius: 999,
              background: isActive ? C.marigold : 'transparent',
              border: isActive ? `2px solid ${C.ink}` : 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              cursor: 'pointer', transition: 'all 0.2s ease',
            }}
          >
            <Icon active={isActive} />
            {isActive && <span className="jp-en" style={{ fontSize: 13, fontWeight: 900, color: C.ink }}>{item.label}</span>}
          </div>
        );
      })}
    </div>
  );
}
function HomeIcon({ active }) {
  return (
    <svg width="22" height="20" viewBox="0 0 22 20" fill="none">
      <path d="M2 9.5L11 2L20 9.5V18.5C20 19 19.5 19.5 19 19.5H14V13.5H8V19.5H3C2.5 19.5 2 19 2 18.5V9.5Z" stroke={C.ink} strokeWidth="2" strokeLinejoin="round" fill={active ? '#fff' : 'none'}/>
    </svg>
  );
}
function BookIcon() {
  return (
    <svg width="22" height="20" viewBox="0 0 22 20" fill="none">
      <path d="M2 3C2 2.4 2.4 2 3 2H10V18H3C2.4 18 2 17.6 2 17V3Z" stroke={C.ink} strokeWidth="2" strokeLinejoin="round" fill="none"/>
      <path d="M12 2H19C19.6 2 20 2.4 20 3V17C20 17.6 19.6 18 19 18H12V2Z" stroke={C.ink} strokeWidth="2" strokeLinejoin="round" fill="none"/>
    </svg>
  );
}
function UserIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
      <circle cx="10" cy="7" r="3.5" stroke={C.ink} strokeWidth="2"/>
      <path d="M2.5 18C2.5 14.4 5.9 11.5 10 11.5C14.1 11.5 17.5 14.4 17.5 18" stroke={C.ink} strokeWidth="2" strokeLinecap="round"/>
    </svg>
  );
}

// ============================================================================
// TimerBar — rounded pill, ink outline, color shifts by remaining time
// ============================================================================
function TimerBar({ pct }) {
  const danger = pct < 0.3;
  const color = pct > 0.6 ? C.teal : pct > 0.3 ? C.marigold : C.tomato;
  return (
    <div style={{
      height: 14, background: C.paperWarm,
      borderRadius: 999, border: `2px solid ${C.ink}`,
      overflow: 'hidden', position: 'relative',
    }}>
      <div style={{
        height: '100%', width: `${pct * 100}%`,
        background: color, borderRight: pct > 0.05 ? `2px solid ${C.ink}` : 'none',
        transition: 'width 0.25s linear, background 0.4s ease',
        animation: danger ? 'jp-timer-pulse 0.5s ease-in-out infinite' : 'none',
        transformOrigin: 'left center',
      }} />
    </div>
  );
}

// ============================================================================
// XPBar — chunky marigold-fill pill with level badge
// ============================================================================
function XPBar({ pct, level }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
      <div style={{
        background: C.tomato, color: '#fff',
        fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 15,
        width: 34, height: 34, borderRadius: 11,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        border: `2px solid ${C.ink}`, boxShadow: `2px 2px 0 ${C.ink}`,
        flexShrink: 0,
      }}>{level}</div>
      <div style={{ flex: 1 }}>
        <div style={{
          height: 14, background: C.paperWarm, borderRadius: 999,
          border: `2px solid ${C.ink}`, overflow: 'hidden',
        }}>
          <div style={{
            height: '100%', width: `${pct * 100}%`,
            background: C.teal,
            borderRight: pct > 0.05 && pct < 0.98 ? `2px solid ${C.ink}` : 'none',
            transition: 'width 1s ease',
          }} />
        </div>
      </div>
    </div>
  );
}

// ============================================================================
// CoinBadge / StreakBadge — sticker-style pills with ink outline
// ============================================================================
function CoinBadge({ amount }) {
  return (
    <div className="jp-en" style={{
      display: 'inline-flex', alignItems: 'center', gap: 6,
      background: C.card, color: C.ink,
      border: `2px solid ${C.ink}`,
      borderRadius: 999, padding: '6px 12px',
      boxShadow: `2.5px 2.5px 0 ${C.ink}`,
      fontWeight: 900, fontSize: 14,
    }}>
      <div style={{
        width: 18, height: 18, borderRadius: '50%',
        background: C.marigold, border: `2px solid ${C.ink}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 11, fontWeight: 900, color: C.ink,
      }}>$</div>
      <span>{amount}</span>
    </div>
  );
}

function StreakBadge({ count }) {
  return (
    <div className="jp-en" style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      background: C.marigold, color: C.ink,
      border: `2px solid ${C.ink}`,
      borderRadius: 999, padding: '6px 12px',
      boxShadow: `2.5px 2.5px 0 ${C.ink}`,
      fontWeight: 900, fontSize: 14,
    }}>
      🔥<span>{count}</span>
    </div>
  );
}

// ============================================================================
// MCQ Option — chunky white card, ink outline, hard offset shadow
// ============================================================================
function MCQOption({ text, state, onClick, index }) {
  const delay = index * 0.07;
  return (
    <div
      className={`jp-mcq-option ${state || ''}`}
      onClick={state ? undefined : onClick}
      style={{
        padding: '15px 18px',
        animation: `jp-slide-up 0.35s ease ${delay}s both`,
        display: 'flex', alignItems: 'center', gap: 12,
      }}
    >
      {/* state mark */}
      {state === 'correct' && (
        <div style={{
          width: 28, height: 28, borderRadius: '50%',
          background: C.teal, border: `2px solid ${C.ink}`,
          color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontWeight: 900, fontSize: 16, flexShrink: 0,
        }}>✓</div>
      )}
      {state === 'wrong' && (
        <div style={{
          width: 28, height: 28, borderRadius: '50%',
          background: C.tomato, border: `2px solid ${C.ink}`,
          color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontWeight: 900, fontSize: 16, flexShrink: 0,
        }}>✗</div>
      )}
      <p className="jp-urdu" style={{
        flex: 1, fontSize: 18,
        color: C.ink,
        fontWeight: state ? 700 : 500,
        lineHeight: 1.8, margin: 0,
      }}>
        {text}
      </p>
    </div>
  );
}

// ============================================================================
// Primary / Ghost button wrappers (for JSX use; CSS classes do most work)
// ============================================================================
function BtnPrimary({ children, onClick, disabled, style = {} }) {
  return (
    <button className="jp-btn-primary" onClick={onClick} disabled={disabled}
      style={{ width: '100%', padding: '16px', fontSize: 17, ...style }}>
      {children}
    </button>
  );
}

function BtnGhost({ children, onClick, style = {} }) {
  return (
    <button className="jp-btn-ghost" onClick={onClick}
      style={{ width: '100%', padding: '15px', fontSize: 16, ...style }}>
      {children}
    </button>
  );
}

// ============================================================================
// Confetti — Sunny palette pieces
// ============================================================================
function Confetti({ active }) {
  if (!active) return null;
  const palette = [C.tomato, C.marigold, C.teal, C.purple, C.sky];
  const pieces = Array.from({ length: 22 }, () => ({
    x: Math.random() * 100,
    color: palette[Math.floor(Math.random() * palette.length)],
    delay: Math.random() * 0.4,
    size: 8 + Math.random() * 8,
    shape: Math.random() > 0.5 ? 'circle' : 'rect',
    duration: 1.4 + Math.random() * 1.2,
  }));
  return (
    <div style={{ position: 'absolute', inset: 0, pointerEvents: 'none', overflow: 'hidden', zIndex: 10 }}>
      {pieces.map((p, i) => (
        <div key={i} style={{
          position: 'absolute', left: `${p.x}%`, top: -20,
          width: p.size, height: p.size,
          borderRadius: p.shape === 'circle' ? '50%' : 4,
          background: p.color,
          border: `1.5px solid ${C.ink}`,
          animation: `jp-confetti ${p.duration}s ease ${p.delay}s forwards`,
        }} />
      ))}
    </div>
  );
}

// ============================================================================
// Image placeholder — warm cream stripes, monospace label
// ============================================================================
function ImgPlaceholder({ label, style = {} }) {
  return (
    <div style={{
      background: `repeating-linear-gradient(45deg, ${C.paperWarm} 0 12px, #F3D89C 12px 24px)`,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexDirection: 'column', gap: 10,
      color: C.ink,
      ...style,
    }}>
      <div style={{ fontSize: 30 }}>🖼</div>
      <div className="jp-en" style={{
        color: C.ink, fontSize: 11, textAlign: 'center',
        fontFamily: 'ui-monospace, "JetBrains Mono", monospace', padding: '0 12px', opacity: 0.65,
        fontWeight: 700,
      }}>{label}</div>
    </div>
  );
}

injectCSS();

// Export
Object.assign(window, {
  C, BottomNav, TimerBar, XPBar, CoinBadge, StreakBadge, MCQOption,
  Confetti, ImgPlaceholder, BtnPrimary, BtnGhost, Sticker, SunBlob,
});
