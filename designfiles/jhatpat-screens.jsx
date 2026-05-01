
// All 11 screens for Jhat Pat
// Requires: C, BottomNav, TimerBar, XPBar, CoinBadge, StreakBadge, MCQOption, Confetti, ImgPlaceholder

const { useState, useEffect, useRef, useCallback } = React;

// ─── SAMPLE DATA ─────────────────────────────────────────────────────────────
const PHRASES = [
  {
    id: 1,
    urdu: 'طوطے اڑ جانا',
    roman: 'Totay ur jana',
    meaning: 'حیران و پریشان رہ جانا',
    example: 'جب اسے خبر ملی تو اس کے طوطے اڑ گئے',
    category: 'محاورہ',
    difficulty: 'آسان',
    wrong: ['بہت خوش ہو جانا', 'تیز دوڑنا', 'کسی کو دھوکہ دینا'],
  },
  {
    id: 2,
    urdu: 'کان کھڑے ہونا',
    roman: 'Kaan kharay hona',
    meaning: 'چوکنا یا ہوشیار ہو جانا',
    example: 'مشکوک آواز سنتے ہی اس کے کان کھڑے ہو گئے',
    category: 'محاورہ',
    difficulty: 'آسان',
    wrong: ['سننے میں دشواری محسوس کرنا', 'کسی کی چغلی کھانا', 'بہت تیز آواز سن کر کان بند کر لینا'],
  },
  {
    id: 3,
    urdu: 'باغ باغ ہونا',
    roman: 'Bagh bagh hona',
    meaning: 'انتہائی خوش اور مسرور ہونا',
    example: 'خوشخبری سن کر وہ باغ باغ ہو گئے',
    category: 'محاورہ',
    difficulty: 'آسان',
    wrong: ['بہت غصہ آنا', 'چوری کرنا', 'گم ہو جانا'],
  },
  {
    id: 4,
    urdu: 'آگ بگولہ ہونا',
    roman: 'Aag bagola hona',
    meaning: 'بہت زیادہ غصے میں آ جانا',
    example: 'بات سن کر وہ آگ بگولہ ہو گیا',
    category: 'محاورہ',
    difficulty: 'آسان',
    wrong: ['بہت خوش ہونا', 'حیران ہو جانا', 'تیز چلنا'],
  },
  {
    id: 5,
    urdu: 'دانتوں تلے انگلی دبانا',
    roman: 'Danton talay ungli dabana',
    meaning: 'بہت زیادہ حیران ہونا',
    example: 'اس کا کام دیکھ کر سب نے دانتوں تلے انگلی دبا لی',
    category: 'محاورہ',
    difficulty: 'درمیانہ',
    wrong: ['بہت تھکا ہوا ہونا', 'چھپ جانا', 'فرار ہو جانا'],
  },
];

function shuffle(arr) {
  return [...arr].sort(() => Math.random() - 0.5);
}

// ─── SCREEN 1: SPLASH ────────────────────────────────────────────────────────
function SplashScreen({ onDone }) {
  const [phase, setPhase] = useState(0); // 0=logo, 1=glow, 2=out

  useEffect(() => {
    const t1 = setTimeout(() => setPhase(1), 600);
    const t2 = setTimeout(() => setPhase(2), 2200);
    const t3 = setTimeout(() => onDone(), 2700);
    return () => { clearTimeout(t1); clearTimeout(t2); clearTimeout(t3); };
  }, []);

  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center',
      background: `radial-gradient(ellipse at 50% 40%, #0F3460 0%, #1A1A2E 70%)`,
      position: 'relative', overflow: 'hidden',
      opacity: phase === 2 ? 0 : 1, transition: 'opacity 0.5s ease',
    }}>
      {/* Background particles */}
      {[...Array(6)].map((_, i) => (
        <div key={i} style={{
          position: 'absolute',
          width: 2, height: 2,
          borderRadius: '50%',
          background: C.orange,
          left: `${15 + i * 13}%`,
          top: `${20 + (i % 3) * 25}%`,
          opacity: phase >= 1 ? 0.6 : 0,
          animation: phase >= 1 ? `jp-glow-pulse ${1 + i * 0.3}s ease-in-out infinite` : 'none',
          transition: 'opacity 0.5s ease',
          boxShadow: `0 0 6px ${C.orange}`,
        }} />
      ))}

      {/* Logo ring */}
      <div style={{
        position: 'relative',
        animation: phase >= 1 ? 'jp-float 3s ease-in-out infinite' : 'none',
        transform: phase >= 1 ? 'scale(1)' : 'scale(0.3)',
        opacity: phase >= 1 ? 1 : 0,
        transition: 'transform 0.6s cubic-bezier(0.34,1.56,0.64,1), opacity 0.4s ease',
      }}>
        {/* Outer glow ring */}
        <div style={{
          width: 140, height: 140,
          borderRadius: '50%',
          border: `2px solid ${C.orange}44`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: phase >= 1 ? `0 0 40px ${C.orange}44, 0 0 80px ${C.orange}22` : 'none',
          transition: 'box-shadow 0.8s ease',
        }}>
          <div style={{
            width: 110, height: 110,
            borderRadius: '50%',
            border: `2px solid ${C.orange}66`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: `radial-gradient(circle, #FF6B3520, transparent)`,
          }}>
            {/* Bot mascot head */}
            <div style={{
              width: 76, height: 76,
              borderRadius: 20,
              background: 'linear-gradient(135deg, #C0C0C0, #909090)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexDirection: 'column', gap: 3,
              boxShadow: '0 8px 24px rgba(0,0,0,0.4)',
              position: 'relative',
              overflow: 'hidden',
            }}>
              {/* Robot eyes */}
              <div style={{ display: 'flex', gap: 10 }}>
                <div style={{ width: 12, height: 12, borderRadius: '50%', background: C.orange, boxShadow: `0 0 8px ${C.orange}` }} />
                <div style={{ width: 12, height: 12, borderRadius: '50%', background: C.orange, boxShadow: `0 0 8px ${C.orange}` }} />
              </div>
              {/* Robot mouth */}
              <div style={{ width: 28, height: 4, background: '#666', borderRadius: 2 }} />
              {/* Antenna */}
              <div style={{ position: 'absolute', top: -14, left: '50%', transform: 'translateX(-50%)', width: 3, height: 14, background: '#999', borderRadius: 2 }}>
                <div style={{ width: 8, height: 8, borderRadius: '50%', background: C.orange, position: 'absolute', top: -6, left: -2.5, boxShadow: `0 0 6px ${C.orange}` }} />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* App name */}
      <div style={{
        marginTop: 32,
        opacity: phase >= 1 ? 1 : 0,
        transform: phase >= 1 ? 'translateY(0)' : 'translateY(20px)',
        transition: 'all 0.6s ease 0.3s',
        textAlign: 'center',
      }}>
        <div className="jp-urdu" style={{ fontSize: 42, color: '#fff', fontWeight: 700, letterSpacing: -1, lineHeight: 1.3 }}>
          جھٹ پٹ
        </div>
        <div className="jp-en" style={{ color: C.orange, fontSize: 13, fontWeight: 600, letterSpacing: 3, marginTop: 4, textTransform: 'uppercase' }}>
          Jhat Pat
        </div>
      </div>

      {/* Tagline */}
      <div style={{
        marginTop: 16,
        opacity: phase >= 1 ? 1 : 0,
        transition: 'opacity 0.6s ease 0.6s',
      }}>
        <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 16, textAlign: 'center' }}>
          اردو محاورے سیکھیں، مزہ کریں
        </div>
      </div>

      {/* Loading dots */}
      <div style={{
        position: 'absolute', bottom: 60,
        display: 'flex', gap: 8,
        opacity: phase >= 1 ? 1 : 0,
        transition: 'opacity 0.5s ease 1s',
      }}>
        {[0,1,2].map(i => (
          <div key={i} style={{
            width: 6, height: 6, borderRadius: '50%',
            background: C.orange,
            animation: phase >= 1 ? `jp-glow-pulse 1s ease-in-out ${i * 0.2}s infinite` : 'none',
          }} />
        ))}
      </div>
    </div>
  );
}

// ─── SCREEN 2: ONBOARDING ─────────────────────────────────────────────────────
const ONBOARDING_SLIDES = [
  {
    icon: '🖼️',
    color: C.orange,
    bg: 'linear-gradient(160deg, #FF6B3520 0%, #1A1A2E 60%)',
    title: 'تصویر دیکھو',
    subtitle: 'پہلے تصویر دیکھیں اور اشارہ سمجھیں',
    detail: 'AI سے بنی تصویریں دیکھیں جو اردو محاورے کو دکھاتی ہیں',
  },
  {
    icon: '✅',
    color: C.green,
    bg: 'linear-gradient(160deg, #00D97E20 0%, #1A1A2E 60%)',
    title: 'جواب چنو',
    subtitle: 'چار آپشن میں سے صحیح جواب منتخب کریں',
    detail: 'جتنی جلدی جواب دیں، اتنے زیادہ پوائنٹس کمائیں',
  },
  {
    icon: '🚀',
    color: '#C77DFF',
    bg: 'linear-gradient(160deg, #C77DFF20 0%, #1A1A2E 60%)',
    title: 'سیکھو اور آگے بڑھو',
    subtitle: 'سکے اور سٹریک بڑھائیں — روزانہ کھیل کر',
    detail: 'XP کمائیں، لیول بڑھائیں اور اردو کے ماہر بن جائیں',
  },
];

function OnboardingScreen({ onDone }) {
  const [slide, setSlide] = useState(0);
  const [animDir, setAnimDir] = useState('right');
  const s = ONBOARDING_SLIDES[slide];

  const goNext = () => {
    if (slide < 2) { setAnimDir('right'); setSlide(slide + 1); }
    else onDone();
  };
  const goPrev = () => {
    if (slide > 0) { setAnimDir('left'); setSlide(slide - 1); }
  };

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: s.bg, transition: 'background 0.4s ease', position: 'relative' }}>
      {/* Skip */}
      <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '16px 20px 0' }}>
        <button className="jp-en jp-btn-ghost" onClick={onDone} style={{ padding: '8px 18px', fontSize: 13 }}>
          اسکپ
        </button>
      </div>

      {/* Main content */}
      <div key={slide} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 32px', animation: 'jp-slide-up 0.4s ease both' }}>
        {/* Icon blob */}
        <div style={{
          width: 140, height: 140,
          borderRadius: '50%',
          background: `${s.color}18`,
          border: `2px solid ${s.color}44`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 56,
          marginBottom: 32,
          boxShadow: `0 0 40px ${s.color}30`,
          animation: 'jp-float 3s ease-in-out infinite',
        }}>
          {s.icon}
        </div>

        <div className="jp-urdu" style={{ fontSize: 32, color: '#fff', fontWeight: 700, textAlign: 'center', lineHeight: 1.5, marginBottom: 12 }}>
          {s.title}
        </div>
        <div className="jp-urdu" style={{ fontSize: 20, color: C.textSecondary, textAlign: 'center', lineHeight: 1.8, marginBottom: 8 }}>
          {s.subtitle}
        </div>
        <div className="jp-urdu" style={{ fontSize: 16, color: C.textMuted, textAlign: 'center', lineHeight: 1.8 }}>
          {s.detail}
        </div>
      </div>

      {/* Bottom controls */}
      <div style={{ padding: '0 24px 40px' }}>
        {/* Dots */}
        <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginBottom: 24 }}>
          {ONBOARDING_SLIDES.map((_, i) => (
            <div key={i} onClick={() => setSlide(i)} style={{
              width: i === slide ? 24 : 8,
              height: 8, borderRadius: 4,
              background: i === slide ? s.color : C.textMuted,
              transition: 'all 0.3s ease',
              cursor: 'pointer',
            }} />
          ))}
        </div>

        <button className="jp-btn-orange" onClick={goNext} style={{ width: '100%', padding: '17px', fontSize: 18 }}>
          <span className="jp-urdu">{slide === 2 ? 'شروع کریں' : 'اگلا'}</span>
        </button>
      </div>
    </div>
  );
}

// ─── SCREEN 3: SIGN IN ───────────────────────────────────────────────────────
function SignInScreen({ onDone }) {
  const [name, setName] = useState('');
  const [avatarIdx, setAvatarIdx] = useState(0);
  const [lang, setLang] = useState('ur');
  const avatars = ['😊','😎','🤩','🧠','🔥','⭐'];

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, position: 'relative', overflowY: 'auto' }}>
      {/* Header gradient */}
      <div style={{ background: 'linear-gradient(180deg, #0F346030 0%, transparent 100%)', padding: '48px 28px 24px', textAlign: 'center' }}>
        <div className="jp-urdu" style={{ fontSize: 36, color: '#fff', fontWeight: 700, marginBottom: 6 }}>خوش آمدید</div>
        <div className="jp-urdu" style={{ fontSize: 18, color: C.textSecondary }}>اپنا نام درج کریں اور کھیلنا شروع کریں</div>
      </div>

      <div style={{ padding: '0 24px 40px', display: 'flex', flexDirection: 'column', gap: 24 }}>
        {/* Language selector */}
        <div>
          <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 14, marginBottom: 10, textAlign: 'right' }}>ایپ کی زبان</div>
          <div style={{ display: 'flex', gap: 10 }}>
            {['ur','en'].map(l => (
              <button key={l} onClick={() => setLang(l)} style={{
                flex: 1, padding: '12px', borderRadius: 14, cursor: 'pointer', fontFamily: 'Poppins,sans-serif', fontWeight: 600, fontSize: 15,
                background: lang === l ? `${C.orange}22` : 'rgba(255,255,255,0.04)',
                border: `1.5px solid ${lang === l ? C.orange : 'rgba(255,255,255,0.1)'}`,
                color: lang === l ? C.orange : C.textSecondary,
                transition: 'all 0.2s ease',
              }}>
                {l === 'ur' ? 'اردو' : 'English'}
              </button>
            ))}
          </div>
        </div>

        {/* Avatar picker */}
        <div>
          <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 14, marginBottom: 10, textAlign: 'right' }}>اپنا اوتار چنیں</div>
          <div style={{ display: 'flex', gap: 10, justifyContent: 'center' }}>
            {avatars.map((av, i) => (
              <div key={i} onClick={() => setAvatarIdx(i)} style={{
                width: 52, height: 52, borderRadius: '50%', fontSize: 24,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: i === avatarIdx ? `${C.orange}22` : 'rgba(255,255,255,0.05)',
                border: `2px solid ${i === avatarIdx ? C.orange : 'transparent'}`,
                cursor: 'pointer', transition: 'all 0.2s ease',
                boxShadow: i === avatarIdx ? `0 0 16px ${C.orange}44` : 'none',
                transform: i === avatarIdx ? 'scale(1.15)' : 'scale(1)',
              }}>
                {av}
              </div>
            ))}
          </div>
        </div>

        {/* Name input */}
        <div>
          <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 14, marginBottom: 10, textAlign: 'right' }}>اپنا نام</div>
          <input
            value={name}
            onChange={e => setName(e.target.value)}
            placeholder="اپنا نام لکھیں"
            style={{
              width: '100%', padding: '16px 18px',
              background: '#16213E',
              border: `1.5px solid ${name ? C.orange + '66' : 'rgba(255,255,255,0.1)'}`,
              borderRadius: 16, color: '#fff', fontSize: 18,
              fontFamily: 'Noto Nastaliq Urdu, serif',
              direction: 'rtl', textAlign: 'right',
              outline: 'none', transition: 'border 0.2s ease',
              boxSizing: 'border-box',
            }}
          />
        </div>

        {/* CTA buttons */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 8 }}>
          <button className="jp-btn-orange" onClick={() => name.trim() && onDone(name.trim(), avatarIdx)} style={{ padding: '17px', fontSize: 18, width: '100%', opacity: name.trim() ? 1 : 0.5 }}>
            <span className="jp-urdu">آگے بڑھیں</span>
          </button>
          <button className="jp-btn-ghost" onClick={() => onDone('مہمان', 0)} style={{ padding: '16px', fontSize: 15, width: '100%' }}>
            <span className="jp-urdu">مہمان کے طور پر کھیلو</span>
          </button>
          {/* Google sign-in */}
          <button style={{
            width: '100%', padding: '15px',
            background: '#fff', color: '#333',
            border: 'none', borderRadius: 16, cursor: 'pointer',
            fontFamily: 'Poppins, sans-serif', fontWeight: 600, fontSize: 14,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          }}>
            <svg width="20" height="20" viewBox="0 0 20 20"><path d="M19.6 10.23c0-.68-.06-1.36-.18-2H10v3.77h5.4c-.23 1.22-.95 2.26-2.04 2.95v2.45h3.3c1.93-1.78 3.04-4.4 3.04-7.17z" fill="#4285F4"/><path d="M10 20c2.7 0 4.97-.9 6.62-2.44l-3.3-2.56c-.9.6-2.04.96-3.32.96-2.55 0-4.71-1.72-5.48-4.04H1.12v2.63C2.76 17.74 6.14 20 10 20z" fill="#34A853"/><path d="M4.52 11.92A6.05 6.05 0 014.2 10c0-.67.12-1.32.32-1.92V5.45H1.12A10 10 0 000 10c0 1.62.39 3.14 1.12 4.55l3.4-2.63z" fill="#FBBC05"/><path d="M10 3.96c1.43 0 2.72.49 3.73 1.46l2.8-2.8C14.96.99 12.7 0 10 0 6.14 0 2.76 2.26 1.12 5.45l3.4 2.63C5.29 5.68 7.45 3.96 10 3.96z" fill="#EA4335"/></svg>
            Google سے سائن ان
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── SCREEN 4: HOME ──────────────────────────────────────────────────────────
function HomeScreen({ profile, onNavigate, onStartGame }) {
  const modes = [
    { id: 'quick', icon: '⚡', urdu: 'جھٹ پٹ کھیلو', en: 'Quick Play', color: C.orange, glow: C.orangeGlow, locked: false },
    { id: 'learn', icon: '📖', urdu: 'سیکھو', en: 'Learn Mode', color: '#C77DFF', glow: 'rgba(199,125,255,0.2)', locked: false },
    { id: 'speed', icon: '🔥', urdu: 'اسپیڈ راؤنڈ', en: 'Speed Round', color: C.red, glow: C.redGlow, locked: profile.level < 5, lockMsg: 'Level 5 پر کھلے گا' },
    { id: 'category', icon: '📁', urdu: 'زمرہ', en: 'Category', color: C.gold, glow: 'rgba(255,215,0,0.2)', locked: false },
  ];

  const streakLabel = profile.streak >= 8 ? '👑' : profile.streak >= 5 ? '⚡' : profile.streak >= 3 ? '🔥' : '';

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, paddingBottom: 72 }}>
      {/* Top bar */}
      <div style={{ padding: '16px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div className="jp-urdu" style={{ fontSize: 26, color: '#fff', fontWeight: 700 }}>جھٹ پٹ</div>
        <div style={{ display: 'flex', gap: 8 }}>
          <CoinBadge amount={profile.coins} />
        </div>
      </div>

      {/* Profile card */}
      <div style={{ margin: '16px 20px 0' }} className="jp-card-glow">
        <div style={{ padding: '16px 18px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 14 }}>
            <div style={{ width: 50, height: 50, borderRadius: '50%', background: `${C.orange}20`, border: `2px solid ${C.orange}66`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24 }}>
              {profile.avatar}
            </div>
            <div>
              <div className="jp-en" style={{ color: '#fff', fontWeight: 700, fontSize: 16 }}>{profile.name}</div>
              <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 14 }}>{profile.levelTitle}</div>
            </div>
            {profile.streak > 0 && (
              <div style={{ marginLeft: 'auto' }}>
                <StreakBadge count={profile.streak} />
              </div>
            )}
          </div>
          <XPBar pct={profile.xpPct} level={profile.level} />
          <div className="jp-en" style={{ color: C.textMuted, fontSize: 11, marginTop: 6, textAlign: 'right' }}>
            {profile.xp} / {profile.xpNext} XP
          </div>
        </div>
      </div>

      {/* Daily goal */}
      <div style={{ margin: '12px 20px 0' }}>
        <div style={{ background: '#16213E', borderRadius: 14, padding: '12px 16px', border: `1px solid rgba(255,215,0,0.2)` }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ fontSize: 16 }}>🎯</span>
              <span className="jp-urdu" style={{ color: '#fff', fontSize: 15 }}>آج کا ہدف</span>
            </div>
            <span className="jp-en" style={{ color: C.gold, fontWeight: 700, fontSize: 14 }}>{profile.todayCards}/5</span>
          </div>
          <div style={{ height: 6, background: 'rgba(255,255,255,0.08)', borderRadius: 3, marginTop: 10, overflow: 'hidden' }}>
            <div style={{ height: '100%', width: `${(profile.todayCards / 5) * 100}%`, background: `linear-gradient(90deg, ${C.gold}aa, ${C.gold})`, borderRadius: 3, transition: 'width 1s ease' }} />
          </div>
        </div>
      </div>

      {/* Mode grid */}
      <div style={{ margin: '16px 20px 0', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        {modes.map((m, i) => (
          <div
            key={m.id}
            onClick={() => !m.locked && onStartGame(m.id)}
            style={{
              background: '#16213E',
              borderRadius: 18,
              border: `1.5px solid ${m.locked ? 'rgba(255,255,255,0.06)' : m.color + '44'}`,
              padding: '20px 16px',
              cursor: m.locked ? 'default' : 'pointer',
              opacity: m.locked ? 0.5 : 1,
              position: 'relative',
              overflow: 'hidden',
              animation: `jp-slide-up 0.3s ease ${i * 0.07}s both`,
              transition: 'transform 0.15s ease, box-shadow 0.15s ease',
              boxShadow: m.locked ? 'none' : `0 4px 20px ${m.glow}`,
            }}
            onMouseEnter={e => { if (!m.locked) { e.currentTarget.style.transform = 'scale(1.02)'; e.currentTarget.style.boxShadow = `0 8px 28px ${m.glow}`; }}}
            onMouseLeave={e => { e.currentTarget.style.transform = 'scale(1)'; e.currentTarget.style.boxShadow = m.locked ? 'none' : `0 4px 20px ${m.glow}`; }}
          >
            <div style={{ background: `${m.color}18`, width: 44, height: 44, borderRadius: 12, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22, marginBottom: 12 }}>
              {m.icon}
            </div>
            <div className="jp-urdu" style={{ color: '#fff', fontSize: 18, fontWeight: 600, marginBottom: 2 }}>{m.urdu}</div>
            {m.locked
              ? <div className="jp-urdu" style={{ color: C.red, fontSize: 13 }}>{m.lockMsg}</div>
              : <div className="jp-en" style={{ color: C.textMuted, fontSize: 12 }}>{m.en}</div>
            }
            {!m.locked && <div style={{ position: 'absolute', bottom: 14, right: 14, color: m.color, fontSize: 16 }}>›</div>}
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── SCREEN 5: PHOTO CARD (GAMEPLAY) ─────────────────────────────────────────
function PhotoCardScreen({ cardIdx, totalCards, phrase, streak, coins, onAnswer, onHintEliminate, onHintFreeze, eliminated }) {
  const TOTAL_TIME = 15;
  const [timeLeft, setTimeLeft] = useState(TOTAL_TIME);
  const [frozen, setFrozen] = useState(false);
  const [selected, setSelected] = useState(null);
  const [answered, setAnswered] = useState(false);
  const timerRef = useRef(null);

  const options = useRef(shuffle([phrase.meaning, ...phrase.wrong])).current;

  useEffect(() => {
    if (answered || frozen) return;
    timerRef.current = setInterval(() => {
      setTimeLeft(t => {
        if (t <= 0.25) {
          clearInterval(timerRef.current);
          handleAnswer(null);
          return 0;
        }
        return t - 0.25;
      });
    }, 250);
    return () => clearInterval(timerRef.current);
  }, [answered, frozen]);

  const handleFreeze = () => {
    if (coins < 15 || frozen || answered) return;
    setFrozen(true);
    clearInterval(timerRef.current);
    onHintFreeze();
    setTimeout(() => {
      setFrozen(false);
    }, 5000);
  };

  const handleAnswer = (opt) => {
    if (answered) return;
    clearInterval(timerRef.current);
    setSelected(opt);
    setAnswered(true);
    const correct = opt === phrase.meaning;
    const pts = correct ? (timeLeft >= 12 ? 500 : timeLeft >= 9 ? 400 : timeLeft >= 6 ? 300 : timeLeft >= 3 ? 200 : 100) : 0;
    setTimeout(() => onAnswer(correct, pts), 900);
  };

  const elimOptions = eliminated ? options.filter(o => o === phrase.meaning || (o !== phrase.meaning && options.filter(x => x !== phrase.meaning).indexOf(o) === 0)) : options;

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg }}>
      {/* Header */}
      <div style={{ padding: '14px 20px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div className="jp-en" style={{ color: C.textSecondary, fontWeight: 600, fontSize: 14 }}>
          Card <span style={{ color: '#fff' }}>{cardIdx}</span>/{totalCards}
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          {streak >= 3 && <StreakBadge count={streak} />}
          <CoinBadge amount={coins} />
        </div>
      </div>

      {/* Timer */}
      <div style={{ padding: '0 20px 12px' }}>
        <TimerBar pct={timeLeft / TOTAL_TIME} />
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 4 }}>
          <span className="jp-en" style={{ fontSize: 12, color: timeLeft < 5 ? C.red : C.textMuted, fontWeight: 600, fontVariantNumeric: 'tabular-nums', transition: 'color 0.3s' }}>
            {frozen ? '❄️ Frozen' : `${Math.ceil(timeLeft)}s`}
          </span>
        </div>
      </div>

      {/* Card image */}
      <div style={{ margin: '0 20px 16px' }}>
        <div style={{
          borderRadius: 20,
          overflow: 'hidden',
          border: `2px solid ${C.borderOrange}`,
          boxShadow: `0 8px 32px rgba(0,0,0,0.4), 0 0 0 1px ${C.orange}22`,
          position: 'relative',
        }}>
          <ImgPlaceholder label={`AI illustration: "${phrase.roman}"`} style={{ height: 200, width: '100%' }} />
          {/* Corner badge */}
          <div style={{ position: 'absolute', top: 10, right: 10, background: `${C.orange}ee`, borderRadius: 8, padding: '4px 10px' }}>
            <span className="jp-urdu" style={{ color: '#fff', fontSize: 13 }}>{phrase.category}</span>
          </div>
        </div>
      </div>

      {/* Question prompt */}
      <div style={{ padding: '0 20px 14px' }}>
        <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 15, textAlign: 'right' }}>اس تصویر کا کیا مطلب ہے؟</div>
      </div>

      {/* MCQ options */}
      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10, flex: 1 }}>
        {options.map((opt, i) => {
          const isEliminated = eliminated && opt !== phrase.meaning && options.filter(x => x !== phrase.meaning).indexOf(opt) > 0;
          let state = null;
          if (answered) {
            if (opt === phrase.meaning) state = 'correct';
            else if (opt === selected) state = 'wrong';
            else state = 'disabled';
          }
          if (isEliminated) state = 'disabled';
          return (
            <MCQOption
              key={opt}
              text={opt}
              state={state}
              onClick={() => handleAnswer(opt)}
              index={i}
            />
          );
        })}
      </div>

      {/* Hint buttons */}
      <div style={{ padding: '12px 20px 20px', display: 'flex', gap: 10 }}>
        <button onClick={() => !answered && onHintEliminate()} style={{
          flex: 1, padding: '12px', borderRadius: 14, cursor: 'pointer', fontSize: 13,
          background: coins >= 10 && !answered ? 'rgba(255,71,87,0.1)' : 'rgba(255,255,255,0.03)',
          border: `1.5px solid ${coins >= 10 && !answered ? C.red + '66' : 'rgba(255,255,255,0.06)'}`,
          color: coins >= 10 && !answered ? C.red : C.textMuted,
          fontFamily: 'Poppins, sans-serif', fontWeight: 600,
          opacity: answered ? 0.4 : 1,
        }}>
          ➖ Eliminate (10🪙)
        </button>
        <button onClick={handleFreeze} style={{
          flex: 1, padding: '12px', borderRadius: 14, cursor: 'pointer', fontSize: 13,
          background: coins >= 15 && !frozen && !answered ? 'rgba(100,200,255,0.1)' : 'rgba(255,255,255,0.03)',
          border: `1.5px solid ${coins >= 15 && !frozen && !answered ? '#64C8FF66' : 'rgba(255,255,255,0.06)'}`,
          color: coins >= 15 && !frozen && !answered ? '#64C8FF' : C.textMuted,
          fontFamily: 'Poppins, sans-serif', fontWeight: 600,
          opacity: answered || frozen ? 0.4 : 1,
        }}>
          ❄️ Freeze (15🪙)
        </button>
      </div>
    </div>
  );
}

// ─── SCREEN 6: RESULT FLASH ──────────────────────────────────────────────────
function ResultFlashScreen({ correct, points, streak, onDone }) {
  const [show, setShow] = useState(false);

  useEffect(() => {
    setTimeout(() => setShow(true), 50);
    const t = setTimeout(onDone, 1600);
    return () => clearTimeout(t);
  }, []);

  return (
    <div style={{
      flex: 1, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center',
      background: correct
        ? 'radial-gradient(ellipse at 50% 40%, #00D97E33 0%, #1A1A2E 70%)'
        : 'radial-gradient(ellipse at 50% 40%, #FF475733 0%, #1A1A2E 70%)',
      position: 'relative', overflow: 'hidden',
    }}>
      <Confetti active={correct} />

      {/* Result icon */}
      <div style={{
        width: 110, height: 110,
        borderRadius: '50%',
        background: correct ? '#00D97E22' : '#FF475722',
        border: `3px solid ${correct ? C.green : C.red}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 50,
        boxShadow: `0 0 40px ${correct ? C.green : C.red}66`,
        animation: show ? 'jp-bounce-in 0.5s cubic-bezier(0.34,1.56,0.64,1) both' : 'none',
        marginBottom: 24,
      }}>
        {correct ? '✓' : '✗'}
      </div>

      {/* Label */}
      <div className="jp-urdu" style={{
        fontSize: 36, color: correct ? C.green : C.red, fontWeight: 700,
        animation: show ? 'jp-slide-up 0.4s ease 0.2s both' : 'none',
        marginBottom: 8,
      }}>
        {correct ? 'شاباش!' : 'غلط جواب'}
      </div>

      {/* Points */}
      {correct && points > 0 && (
        <div className="jp-en" style={{
          fontSize: 28, color: C.gold, fontWeight: 800,
          animation: show ? 'jp-score-pop 0.6s ease 0.3s both' : 'none',
          marginBottom: 8,
        }}>
          +{points}
        </div>
      )}

      {/* Streak */}
      {correct && streak >= 3 && (
        <div className="jp-en" style={{
          background: 'rgba(255,107,53,0.15)',
          border: `1px solid ${C.orange}44`,
          borderRadius: 20,
          padding: '8px 20px',
          color: C.orange,
          fontWeight: 700,
          fontSize: 14,
          animation: show ? 'jp-slide-up 0.4s ease 0.5s both' : 'none',
        }}>
          🔥 {streak} Streak!
        </div>
      )}

      {/* Continue hint */}
      <div className="jp-en" style={{
        position: 'absolute', bottom: 40,
        color: C.textMuted, fontSize: 13,
        animation: show ? 'jp-fade-in 0.4s ease 1s both' : 'none',
      }}>
        جاری ہے...
      </div>
    </div>
  );
}

// ─── SCREEN 7: REVEAL CARD ───────────────────────────────────────────────────
function RevealCardScreen({ phrase, cardIdx, totalCards, onStartMeaning, onNext, isLast }) {
  const [showExample, setShowExample] = useState(false);
  const [revealed, setRevealed] = useState(false);

  useEffect(() => { setTimeout(() => setRevealed(true), 100); }, []);

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, overflowY: 'auto' }}>
      {/* Header */}
      <div style={{ padding: '14px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div className="jp-en" style={{ color: C.textSecondary, fontSize: 14, fontWeight: 600 }}>
          Card <span style={{ color: '#fff' }}>{cardIdx}</span>/{totalCards} · Reveal
        </div>
        <div className="jp-urdu" style={{ color: C.orange, fontSize: 14 }}>انکشاف</div>
      </div>

      {/* Image */}
      <div style={{ margin: '0 20px 20px', animation: revealed ? 'jp-slide-up 0.4s ease both' : 'none' }}>
        <div style={{ borderRadius: 20, overflow: 'hidden', border: `2px solid ${C.borderOrange}`, boxShadow: `0 8px 32px rgba(0,0,0,0.4)` }}>
          <ImgPlaceholder label={`Reveal card: "${phrase.roman}"`} style={{ height: 180, width: '100%' }} />
        </div>
      </div>

      {/* Phrase reveal card */}
      <div style={{ margin: '0 20px 16px', animation: revealed ? 'jp-slide-up 0.4s ease 0.1s both' : 'none' }}>
        <div className="jp-card-glow" style={{ padding: '24px 20px', textAlign: 'right' }}>
          <div className="jp-urdu" style={{ fontSize: 30, color: '#fff', fontWeight: 700, marginBottom: 6, lineHeight: 1.5 }}>
            {phrase.urdu}
          </div>
          <div className="jp-en" style={{ color: C.textSecondary, fontSize: 15, marginBottom: 16 }}>
            {phrase.roman}
          </div>
          <div style={{ height: 1, background: 'rgba(255,255,255,0.07)', marginBottom: 16 }} />
          <div className="jp-urdu" style={{ fontSize: 18, color: C.orange, lineHeight: 1.8 }}>
            معنی: {phrase.meaning}
          </div>
        </div>
      </div>

      {/* Example sentence button */}
      <div style={{ padding: '0 20px 16px', animation: revealed ? 'jp-slide-up 0.4s ease 0.2s both' : 'none' }}>
        <button onClick={() => setShowExample(true)} style={{
          width: '100%', padding: '14px', borderRadius: 14, cursor: 'pointer',
          background: 'rgba(255,255,255,0.04)',
          border: '1.5px solid rgba(255,255,255,0.1)',
          color: C.textPrimary, fontSize: 16,
          fontFamily: 'Noto Nastaliq Urdu, serif',
          direction: 'rtl', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        }}>
          <span>👁</span>
          <span className="jp-urdu">مثال دیکھیں</span>
        </button>
      </div>

      {/* CTA */}
      <div style={{ padding: '0 20px 28px', marginTop: 'auto', animation: revealed ? 'jp-slide-up 0.4s ease 0.3s both' : 'none' }}>
        <button className="jp-btn-orange" onClick={onStartMeaning} style={{ width: '100%', padding: '17px', fontSize: 18 }}>
          <span className="jp-urdu">معنی کوئز →</span>
        </button>
      </div>

      {/* Example modal */}
      {showExample && (
        <div style={{
          position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.7)',
          display: 'flex', alignItems: 'flex-end', zIndex: 100,
        }} onClick={() => setShowExample(false)}>
          <div style={{
            background: '#16213E', borderRadius: '24px 24px 0 0',
            padding: '24px 24px 40px',
            width: '100%', animation: 'jp-slide-up 0.3s ease both',
            border: `1px solid ${C.borderOrange}`,
          }} onClick={e => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
              <button onClick={() => setShowExample(false)} style={{ background: 'rgba(255,255,255,0.08)', border: 'none', color: '#fff', width: 32, height: 32, borderRadius: 10, cursor: 'pointer', fontSize: 16 }}>✕</button>
              <span className="jp-urdu" style={{ color: C.orange, fontSize: 16 }}>مثال</span>
            </div>
            <div className="jp-urdu" style={{ fontSize: 20, color: '#fff', lineHeight: 2, textAlign: 'right', marginBottom: 12 }}>
              {phrase.example}
            </div>
            <div className="jp-en" style={{ color: C.textSecondary, fontSize: 14 }}>
              {phrase.roman}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── SCREEN 7B: MEANING QUIZ ─────────────────────────────────────────────────
function MeaningQuizScreen({ phrase, cardIdx, totalCards, onAnswer }) {
  const TOTAL_TIME = 8;
  const [timeLeft, setTimeLeft] = useState(TOTAL_TIME);
  const [selected, setSelected] = useState(null);
  const [answered, setAnswered] = useState(false);
  const options = useRef(shuffle([phrase.meaning, ...phrase.wrong])).current;

  useEffect(() => {
    if (answered) return;
    const t = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 0.25) { clearInterval(t); handleAnswer(null); return 0; }
        return prev - 0.25;
      });
    }, 250);
    return () => clearInterval(t);
  }, [answered]);

  const handleAnswer = (opt) => {
    if (answered) return;
    setSelected(opt);
    setAnswered(true);
    const correct = opt === phrase.meaning;
    const pts = correct ? (timeLeft >= 6 ? 200 : timeLeft >= 4 ? 150 : timeLeft >= 2 ? 100 : 50) : 0;
    setTimeout(() => onAnswer(correct, pts), 900);
  };

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg }}>
      <div style={{ padding: '14px 20px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div className="jp-en" style={{ color: C.textSecondary, fontSize: 14, fontWeight: 600 }}>
          Card {cardIdx}/{totalCards} · <span style={{ color: '#C77DFF' }}>مرحلہ ۲/۲</span>
        </div>
      </div>
      <div style={{ padding: '0 20px 12px' }}>
        <TimerBar pct={timeLeft / TOTAL_TIME} />
      </div>

      {/* Phrase display */}
      <div style={{ margin: '4px 20px 20px' }} className="jp-card">
        <div style={{ padding: '20px', textAlign: 'center' }}>
          <div className="jp-urdu" style={{ fontSize: 26, color: '#fff', fontWeight: 700, lineHeight: 1.6 }}>{phrase.urdu}</div>
          <div className="jp-en" style={{ color: C.textSecondary, fontSize: 14, marginTop: 4 }}>{phrase.roman}</div>
        </div>
      </div>

      <div style={{ padding: '0 20px 8px' }}>
        <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 15, textAlign: 'right' }}>اس فقرے کا صحیح مفہوم کیا ہے؟</div>
      </div>

      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10, flex: 1 }}>
        {options.map((opt, i) => {
          let state = null;
          if (answered) {
            if (opt === phrase.meaning) state = 'correct';
            else if (opt === selected) state = 'wrong';
            else state = 'disabled';
          }
          return <MCQOption key={opt} text={opt} state={state} onClick={() => handleAnswer(opt)} index={i} />;
        })}
      </div>
      <div style={{ height: 20 }} />
    </div>
  );
}

// ─── SCREEN 8: SESSION SUMMARY ───────────────────────────────────────────────
function SessionSummaryScreen({ results, profile, onPlayAgain, onHome }) {
  const [countedScore, setCountedScore] = useState(0);
  const totalScore = results.reduce((s, r) => s + r.pts, 0);
  const correct = results.filter(r => r.correct).length;
  const xpEarned = correct * 10 + results.length * 2 + (correct === results.length ? 50 : 0);

  useEffect(() => {
    let start = 0;
    const step = totalScore / 40;
    const t = setInterval(() => {
      start += step;
      if (start >= totalScore) { setCountedScore(totalScore); clearInterval(t); }
      else setCountedScore(Math.floor(start));
    }, 30);
    return () => clearInterval(t);
  }, []);

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, overflowY: 'auto' }}>
      {/* Header glow */}
      <div style={{ background: 'linear-gradient(180deg, rgba(255,215,0,0.15) 0%, transparent 100%)', padding: '40px 24px 20px', textAlign: 'center' }}>
        <div style={{ fontSize: 48, marginBottom: 8 }}>🏆</div>
        <div className="jp-urdu" style={{ fontSize: 28, color: '#fff', fontWeight: 700, marginBottom: 4 }}>سیشن مکمل!</div>
        <div className="jp-en" style={{
          fontSize: 52, fontWeight: 900, color: C.gold,
          textShadow: `0 0 20px ${C.gold}66`,
          animation: 'jp-count-up 0.5s ease both',
        }}>
          {countedScore.toLocaleString()}
        </div>
        <div className="jp-en" style={{ color: C.textMuted, fontSize: 14 }}>Total Points</div>
      </div>

      {/* Stats row */}
      <div style={{ padding: '0 20px 16px', display: 'flex', gap: 10 }}>
        {[
          { label: 'Correct', value: `${correct}/${results.length}`, icon: '✅', color: C.green },
          { label: 'XP Earned', value: `+${xpEarned}`, icon: '⭐', color: C.gold },
          { label: 'Accuracy', value: `${Math.round((correct / results.length) * 100)}%`, icon: '🎯', color: '#C77DFF' },
        ].map(s => (
          <div key={s.label} style={{
            flex: 1, background: '#16213E', borderRadius: 16, padding: '14px 12px', textAlign: 'center',
            border: `1px solid ${s.color}33`,
            animation: 'jp-slide-up 0.4s ease both',
          }}>
            <div style={{ fontSize: 20, marginBottom: 4 }}>{s.icon}</div>
            <div className="jp-en" style={{ color: s.color, fontWeight: 800, fontSize: 18 }}>{s.value}</div>
            <div className="jp-en" style={{ color: C.textMuted, fontSize: 11, marginTop: 2 }}>{s.label}</div>
          </div>
        ))}
      </div>

      {/* Per-card breakdown */}
      <div style={{ padding: '0 20px', marginBottom: 16 }}>
        <div className="jp-en" style={{ color: C.textSecondary, fontWeight: 600, fontSize: 13, marginBottom: 10 }}>Card Breakdown</div>
        {results.map((r, i) => (
          <div key={i} style={{
            background: '#16213E', borderRadius: 14, padding: '12px 16px',
            marginBottom: 8, display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            border: '1px solid rgba(255,255,255,0.05)',
            animation: `jp-slide-up 0.3s ease ${i * 0.06}s both`,
          }}>
            <div className="jp-urdu" style={{ color: '#fff', fontSize: 17, flex: 1, textAlign: 'right' }}>{r.urdu}</div>
            <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginLeft: 12 }}>
              <span style={{ fontSize: 15 }}>{r.correct ? '✅' : '❌'}</span>
              {r.pts > 0 && <span className="jp-en" style={{ color: C.gold, fontWeight: 700, fontSize: 13 }}>+{r.pts}</span>}
            </div>
          </div>
        ))}
      </div>

      {/* Buttons */}
      <div style={{ padding: '8px 20px 36px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <button className="jp-btn-orange" onClick={onPlayAgain} style={{ padding: '17px', fontSize: 18, width: '100%' }}>
          <span className="jp-urdu">دوبارہ کھیلو</span>
        </button>
        <button className="jp-btn-ghost" onClick={onHome} style={{ padding: '15px', fontSize: 16, width: '100%' }}>
          <span className="jp-urdu">گھر جاؤ</span>
        </button>
      </div>
    </div>
  );
}

// ─── SCREEN 9: LIBRARY ───────────────────────────────────────────────────────
function LibraryScreen() {
  const [search, setSearch] = useState('');
  const [catFilter, setCatFilter] = useState('سب');
  const [diffFilter, setDiffFilter] = useState('سب');

  const filtered = PHRASES.filter(p => {
    if (catFilter !== 'سب' && p.category !== catFilter) return false;
    if (diffFilter !== 'سب' && p.difficulty !== diffFilter) return false;
    if (search && !p.urdu.includes(search) && !p.roman.toLowerCase().includes(search.toLowerCase())) return false;
    return true;
  });

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, paddingBottom: 72 }}>
      {/* Header */}
      <div style={{ padding: '16px 20px 12px' }}>
        <div className="jp-urdu" style={{ fontSize: 26, color: '#fff', fontWeight: 700, marginBottom: 14 }}>کتب خانہ</div>
        {/* Search */}
        <div style={{ position: 'relative', marginBottom: 12 }}>
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="محاورہ تلاش کریں..."
            style={{
              width: '100%', padding: '13px 18px 13px 44px',
              background: '#16213E', border: `1.5px solid rgba(255,255,255,0.1)`,
              borderRadius: 14, color: '#fff', fontSize: 16,
              fontFamily: 'Noto Nastaliq Urdu, serif', direction: 'rtl',
              outline: 'none', boxSizing: 'border-box',
            }}
          />
          <span style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: C.textMuted, fontSize: 16 }}>🔍</span>
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 4 }}>
          {['سب','محاورہ','کہاوت'].map(f => (
            <button key={f} onClick={() => setCatFilter(f)} style={{
              padding: '7px 14px', borderRadius: 20, cursor: 'pointer', fontSize: 14,
              background: catFilter === f ? C.orange : 'rgba(255,255,255,0.05)',
              border: `1px solid ${catFilter === f ? C.orange : 'rgba(255,255,255,0.1)'}`,
              color: catFilter === f ? '#fff' : C.textSecondary,
              fontFamily: 'Noto Nastaliq Urdu, serif',
              transition: 'all 0.2s ease',
            }}>{f}</button>
          ))}
          {['سب','آسان','درمیانہ','مشکل'].map(f => (
            <button key={f} onClick={() => setDiffFilter(f)} style={{
              padding: '7px 14px', borderRadius: 20, cursor: 'pointer', fontSize: 14,
              background: diffFilter === f ? '#C77DFF' : 'rgba(255,255,255,0.05)',
              border: `1px solid ${diffFilter === f ? '#C77DFF' : 'rgba(255,255,255,0.1)'}`,
              color: diffFilter === f ? '#fff' : C.textSecondary,
              fontFamily: 'Noto Nastaliq Urdu, serif',
              transition: 'all 0.2s ease',
            }}>{f}</button>
          ))}
        </div>
        <div className="jp-en" style={{ color: C.textMuted, fontSize: 13, marginTop: 8 }}>{filtered.length} phrases</div>
      </div>

      {/* Grid */}
      <div style={{ padding: '0 20px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, overflowY: 'auto', flex: 1 }}>
        {filtered.map((p, i) => (
          <div key={p.id} style={{
            background: '#16213E', borderRadius: 16,
            border: '1px solid rgba(255,255,255,0.07)',
            overflow: 'hidden',
            animation: `jp-slide-up 0.3s ease ${i * 0.05}s both`,
            cursor: 'pointer',
            transition: 'transform 0.15s ease',
          }}
            onMouseEnter={e => e.currentTarget.style.transform = 'scale(1.02)'}
            onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}
          >
            <ImgPlaceholder label={p.roman} style={{ height: 120, width: '100%' }} />
            <div style={{ padding: '10px 10px 12px' }}>
              <div className="jp-urdu" style={{ fontSize: 16, color: '#fff', lineHeight: 1.6 }}>{p.urdu}</div>
              <div style={{ display: 'flex', gap: 4, marginTop: 6, flexWrap: 'wrap' }}>
                <span style={{ background: `${C.orange}22`, color: C.orange, fontSize: 11, padding: '2px 8px', borderRadius: 6, fontFamily: 'Noto Nastaliq Urdu' }}>{p.category}</span>
                <span style={{ background: 'rgba(255,255,255,0.06)', color: C.textMuted, fontSize: 11, padding: '2px 8px', borderRadius: 6, fontFamily: 'Noto Nastaliq Urdu' }}>{p.difficulty}</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── SCREEN 10: PROFILE ──────────────────────────────────────────────────────
function ProfileScreen({ profile }) {
  const sessions = [
    { date: 'آج', cards: 5, correct: 4, pts: 1850, mode: 'Quick Play' },
    { date: 'کل', cards: 5, correct: 3, pts: 1200, mode: 'Learn' },
    { date: '2 دن پہلے', cards: 5, correct: 5, pts: 2400, mode: 'Quick Play' },
  ];

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, overflowY: 'auto', paddingBottom: 72 }}>
      {/* Header */}
      <div style={{ background: 'linear-gradient(180deg, #0F3460 0%, transparent 100%)', padding: '24px 20px 16px', textAlign: 'center' }}>
        {/* Avatar */}
        <div style={{
          width: 80, height: 80, borderRadius: '50%',
          background: `${C.orange}20`,
          border: `3px solid ${C.orange}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 38, margin: '0 auto 12px',
          boxShadow: `0 0 24px ${C.orange}44`,
          animation: 'jp-float 3s ease-in-out infinite',
        }}>
          {profile.avatar}
        </div>
        <div className="jp-en" style={{ color: '#fff', fontWeight: 700, fontSize: 20 }}>{profile.name}</div>
        <div className="jp-urdu" style={{ color: C.orange, fontSize: 16, marginBottom: 16 }}>{profile.levelTitle}</div>
        <XPBar pct={profile.xpPct} level={profile.level} />
        <div className="jp-en" style={{ color: C.textMuted, fontSize: 12, marginTop: 6 }}>{profile.xp} / {profile.xpNext} XP to next level</div>
      </div>

      {/* Stats */}
      <div style={{ padding: '16px 20px 0', display: 'flex', gap: 10 }}>
        {[
          { label: 'Streak', value: profile.streak, icon: '🔥', color: C.orange },
          { label: 'Best', value: profile.bestStreak, icon: '🏆', color: C.gold },
          { label: 'Coins', value: profile.coins, icon: '🪙', color: C.gold },
          { label: 'Correct', value: '87%', icon: '✅', color: C.green },
        ].map(s => (
          <div key={s.label} style={{
            flex: 1, background: '#16213E', borderRadius: 14, padding: '12px 8px', textAlign: 'center',
            border: `1px solid ${s.color}22`,
          }}>
            <div style={{ fontSize: 18, marginBottom: 2 }}>{s.icon}</div>
            <div className="jp-en" style={{ color: s.color, fontWeight: 800, fontSize: 16 }}>{s.value}</div>
            <div className="jp-en" style={{ color: C.textMuted, fontSize: 10, marginTop: 1 }}>{s.label}</div>
          </div>
        ))}
      </div>

      {/* Recent sessions */}
      <div style={{ padding: '20px 20px 0' }}>
        <div className="jp-en" style={{ color: C.textSecondary, fontWeight: 600, fontSize: 14, marginBottom: 12 }}>Recent Sessions</div>
        {sessions.map((s, i) => (
          <div key={i} style={{
            background: '#16213E', borderRadius: 14, padding: '14px 16px', marginBottom: 10,
            border: '1px solid rgba(255,255,255,0.05)',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            animation: `jp-slide-up 0.3s ease ${i * 0.08}s both`,
          }}>
            <div>
              <div className="jp-en" style={{ color: '#fff', fontWeight: 600, fontSize: 14 }}>{s.mode}</div>
              <div className="jp-urdu" style={{ color: C.textSecondary, fontSize: 13 }}>{s.date}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="jp-en" style={{ color: C.gold, fontWeight: 700, fontSize: 16 }}>{s.pts.toLocaleString()}</div>
              <div className="jp-en" style={{ color: C.textMuted, fontSize: 12 }}>{s.correct}/{s.cards} correct</div>
            </div>
          </div>
        ))}
      </div>

      {/* Sign out */}
      <div style={{ padding: '12px 20px 20px' }}>
        <button className="jp-btn-ghost" style={{ width: '100%', padding: '15px', fontSize: 15, color: C.red, borderColor: `${C.red}44` }}>
          <span className="jp-en">Sign Out</span>
        </button>
      </div>
    </div>
  );
}

// ─── SCREEN 11: SETTINGS ─────────────────────────────────────────────────────
function SettingsScreen() {
  const [sound, setSound] = useState(true);
  const [haptics, setHaptics] = useState(true);
  const [lang, setLang] = useState('en');
  const [notifications, setNotifications] = useState(true);

  const Toggle = ({ on, onToggle }) => (
    <div onClick={onToggle} style={{
      width: 50, height: 28, borderRadius: 14,
      background: on ? `linear-gradient(135deg, ${C.orange}, #FF4500)` : 'rgba(255,255,255,0.1)',
      position: 'relative', cursor: 'pointer', transition: 'background 0.3s ease',
      boxShadow: on ? `0 0 12px ${C.orange}66` : 'none',
      flexShrink: 0,
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: '50%', background: '#fff',
        position: 'absolute', top: 3, left: on ? 25 : 3,
        transition: 'left 0.3s cubic-bezier(0.34,1.56,0.64,1)',
        boxShadow: '0 2px 6px rgba(0,0,0,0.3)',
      }} />
    </div>
  );

  const Section = ({ title, children }) => (
    <div style={{ padding: '0 20px', marginBottom: 8 }}>
      <div className="jp-en" style={{ color: C.textMuted, fontSize: 11, fontWeight: 700, textTransform: 'uppercase', letterSpacing: 1.2, marginBottom: 8, paddingLeft: 4 }}>{title}</div>
      <div style={{ background: '#16213E', borderRadius: 16, overflow: 'hidden', border: '1px solid rgba(255,255,255,0.05)' }}>
        {children}
      </div>
    </div>
  );

  const Row = ({ label, sublabel, right, onClick, border = true }) => (
    <div onClick={onClick} style={{
      padding: '16px 18px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      borderBottom: border ? '1px solid rgba(255,255,255,0.05)' : 'none',
      cursor: onClick ? 'pointer' : 'default',
    }}>
      <div>
        <div className="jp-en" style={{ color: '#fff', fontSize: 16, fontWeight: 500 }}>{label}</div>
        {sublabel && <div className="jp-en" style={{ color: C.textMuted, fontSize: 13, marginTop: 2 }}>{sublabel}</div>}
      </div>
      {right}
    </div>
  );

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.bg, overflowY: 'auto', paddingBottom: 40 }}>
      <div style={{ padding: '16px 20px 20px' }}>
        <div className="jp-en" style={{ fontSize: 26, color: '#fff', fontWeight: 700 }}>Settings</div>
      </div>

      <Section title="Language">
        <Row label="App Language" sublabel={lang === 'ur' ? 'Urdu / اردو' : 'English'} border={false}
          right={
            <div style={{ display: 'flex', gap: 8 }}>
              {['ur','en'].map(l => (
                <button key={l} onClick={() => setLang(l)} style={{
                  padding: '7px 14px', borderRadius: 10, cursor: 'pointer',
                  background: lang === l ? `${C.orange}22` : 'rgba(255,255,255,0.06)',
                  border: `1.5px solid ${lang === l ? C.orange : 'rgba(255,255,255,0.1)'}`,
                  color: lang === l ? C.orange : C.textSecondary,
                  fontFamily: 'Poppins, sans-serif', fontWeight: 600, fontSize: 13,
                  transition: 'all 0.2s ease',
                }}>{l === 'ur' ? 'اردو' : 'English'}</button>
              ))}
            </div>
          }
        />
      </Section>

      <Section title="Gameplay">
        <Row label="Sound Effects" right={<Toggle on={sound} onToggle={() => setSound(!sound)} />} />
        <Row label="Haptic Feedback" right={<Toggle on={haptics} onToggle={() => setHaptics(!haptics)} />} />
        <Row label="Daily Reminders" right={<Toggle on={notifications} onToggle={() => setNotifications(!notifications)} />} border={false} />
      </Section>

      <Section title="Account">
        <Row label="Change Name" sublabel="Shaheer" right={<span style={{ color: C.orange, fontSize: 18 }}>›</span>} />
        <Row label="Change Avatar" right={<span style={{ color: C.textMuted, fontSize: 22 }}>😊</span>} border={false} />
      </Section>

      <Section title="About">
        <Row label="App Version" right={<span className="jp-en" style={{ color: C.textMuted }}>1.0.0+1</span>} />
        <Row label="Clear Cache" right={<span style={{ fontSize: 18 }}>🗑️</span>} border={false} />
      </Section>

      <div style={{ padding: '8px 20px' }}>
        <button className="jp-btn-ghost" style={{ width: '100%', padding: '15px', fontSize: 15, color: C.red, borderColor: `${C.red}44` }}>
          Sign Out
        </button>
      </div>
    </div>
  );
}

// ─── MAIN APP CONTROLLER ─────────────────────────────────────────────────────
function JhatPatApp() {
  const [screen, setScreen] = useState('splash');
  const [activeTab, setActiveTab] = useState('home');
  const [gameState, setGameState] = useState(null);
  const [profile, setProfile] = useState({
    name: 'Shaheer',
    avatar: '😊',
    level: 3,
    levelTitle: 'پکا شاگرد',
    xp: 340,
    xpNext: 500,
    xpPct: 0.68,
    streak: 5,
    bestStreak: 8,
    coins: 50,
    todayCards: 2,
  });

  const startGame = (mode) => {
    setGameState({
      mode, cardIdx: 0, totalCards: PHRASES.length,
      results: [], streak: 0, coins: profile.coins,
      phase: 'photo', eliminated: false,
    });
    setScreen('photo');
  };

  const handlePhotoAnswer = (correct, pts) => {
    const gs = gameState;
    const newStreak = correct ? gs.streak + 1 : 0;
    setGameState({ ...gs, pendingCorrect: correct, pendingPts: pts, streak: newStreak });
    setScreen('resultFlash');
  };

  const handleFlashDone = () => {
    setScreen('reveal');
  };

  const handleStartMeaning = () => {
    setScreen('meaningQuiz');
  };

  const handleMeaningAnswer = (correct, pts) => {
    const gs = gameState;
    const phrase = PHRASES[gs.cardIdx];
    const newResults = [...gs.results, { urdu: phrase.urdu, correct: gs.pendingCorrect && correct, pts: gs.pendingPts + pts }];
    const newCardIdx = gs.cardIdx + 1;

    if (newCardIdx >= PHRASES.length) {
      setGameState({ ...gs, results: newResults, cardIdx: newCardIdx });
      setScreen('summary');
    } else {
      setGameState({ ...gs, results: newResults, cardIdx: newCardIdx, pendingCorrect: null, pendingPts: 0, eliminated: false });
      setScreen('photo');
    }
  };

  const handleNavigate = (tab) => {
    setActiveTab(tab);
    setScreen(tab === 'home' ? 'home' : tab);
  };

  const showBottomNav = ['home', 'library', 'profile'].includes(screen);
  const currentPhrase = gameState ? PHRASES[Math.min(gameState.cardIdx, PHRASES.length - 1)] : null;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', position: 'relative', overflow: 'hidden', background: C.bg }}>

      {screen === 'splash' && <SplashScreen onDone={() => setScreen('onboarding')} />}
      {screen === 'onboarding' && <OnboardingScreen onDone={() => setScreen('signin')} />}
      {screen === 'signin' && <SignInScreen onDone={(name, av) => { setProfile(p => ({...p, name, avatar: ['😊','😎','🤩','🧠','🔥','⭐'][av]})); setScreen('home'); }} />}

      {screen === 'home' && <HomeScreen profile={profile} onNavigate={handleNavigate} onStartGame={startGame} />}
      {screen === 'library' && <LibraryScreen />}
      {screen === 'profile' && <ProfileScreen profile={profile} />}
      {screen === 'settings' && <SettingsScreen />}

      {screen === 'photo' && currentPhrase && (
        <PhotoCardScreen
          cardIdx={gameState.cardIdx + 1}
          totalCards={gameState.totalCards}
          phrase={currentPhrase}
          streak={gameState.streak}
          coins={gameState.coins}
          onAnswer={handlePhotoAnswer}
          onHintEliminate={() => setGameState(g => ({...g, eliminated: true, coins: g.coins - 10}))}
          onHintFreeze={() => setGameState(g => ({...g, coins: g.coins - 15}))}
          eliminated={gameState.eliminated}
        />
      )}

      {screen === 'resultFlash' && (
        <ResultFlashScreen
          correct={gameState.pendingCorrect}
          points={gameState.pendingPts}
          streak={gameState.streak}
          onDone={handleFlashDone}
        />
      )}

      {screen === 'reveal' && currentPhrase && (
        <RevealCardScreen
          phrase={currentPhrase}
          cardIdx={gameState.cardIdx + 1}
          totalCards={gameState.totalCards}
          onStartMeaning={handleStartMeaning}
          isLast={gameState.cardIdx === PHRASES.length - 1}
        />
      )}

      {screen === 'meaningQuiz' && currentPhrase && (
        <MeaningQuizScreen
          phrase={currentPhrase}
          cardIdx={gameState.cardIdx + 1}
          totalCards={gameState.totalCards}
          onAnswer={handleMeaningAnswer}
        />
      )}

      {screen === 'summary' && (
        <SessionSummaryScreen
          results={gameState.results}
          profile={profile}
          onPlayAgain={() => startGame(gameState.mode)}
          onHome={() => setScreen('home')}
        />
      )}

      {showBottomNav && <BottomNav active={screen} onNavigate={handleNavigate} />}
    </div>
  );
}

Object.assign(window, { JhatPatApp });
