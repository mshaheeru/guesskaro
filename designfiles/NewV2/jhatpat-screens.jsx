// ============================================================================
// Jhat Pat — SUNNY QUIZ theme: all 11 screens
// Depends on: C, BottomNav, TimerBar, XPBar, CoinBadge, StreakBadge,
//             MCQOption, Confetti, ImgPlaceholder, BtnPrimary, BtnGhost,
//             Sticker, SunBlob
// ============================================================================

const { useState, useEffect, useRef } = React;

// ─── SAMPLE DATA ─────────────────────────────────────────────────────────────
const PHRASES = [
  { id:1, urdu:'طوطے اڑ جانا', roman:'Totay ur jana', meaning:'حیران و پریشان رہ جانا', example:'جب اسے خبر ملی تو اس کے طوطے اڑ گئے', category:'محاورہ', difficulty:'آسان', wrong:['بہت خوش ہو جانا','تیز دوڑنا','کسی کو دھوکہ دینا'] },
  { id:2, urdu:'کان کھڑے ہونا', roman:'Kaan kharay hona', meaning:'چوکنا یا ہوشیار ہو جانا', example:'مشکوک آواز سنتے ہی اس کے کان کھڑے ہو گئے', category:'محاورہ', difficulty:'آسان', wrong:['سننے میں دشواری','چغلی کھانا','کان بند کر لینا'] },
  { id:3, urdu:'باغ باغ ہونا', roman:'Bagh bagh hona', meaning:'انتہائی خوش اور مسرور ہونا', example:'خوشخبری سن کر وہ باغ باغ ہو گئے', category:'محاورہ', difficulty:'آسان', wrong:['بہت غصہ آنا','چوری کرنا','گم ہو جانا'] },
  { id:4, urdu:'آگ بگولہ ہونا', roman:'Aag bagola hona', meaning:'بہت زیادہ غصے میں آ جانا', example:'بات سن کر وہ آگ بگولہ ہو گیا', category:'محاورہ', difficulty:'آسان', wrong:['بہت خوش ہونا','حیران ہو جانا','تیز چلنا'] },
  { id:5, urdu:'دانتوں تلے انگلی دبانا', roman:'Danton talay ungli dabana', meaning:'بہت زیادہ حیران ہونا', example:'اس کا کام دیکھ کر سب نے دانتوں تلے انگلی دبا لی', category:'محاورہ', difficulty:'درمیانہ', wrong:['تھکا ہوا ہونا','چھپ جانا','فرار ہو جانا'] },
];

function shuffle(arr) { return [...arr].sort(() => Math.random() - 0.5); }

// ─── SCREEN 1: SPLASH ────────────────────────────────────────────────────────
function SplashScreen({ onDone }) {
  const [phase, setPhase] = useState(0);
  useEffect(() => {
    const t1 = setTimeout(() => setPhase(1), 400);
    const t2 = setTimeout(() => setPhase(2), 2200);
    const t3 = setTimeout(() => onDone(), 2700);
    return () => { clearTimeout(t1); clearTimeout(t2); clearTimeout(t3); };
  }, []);

  return (
    <div style={{
      flex: 1, position: 'relative', overflow: 'hidden',
      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
      background: C.paper,
      opacity: phase === 2 ? 0 : 1, transition: 'opacity 0.5s ease',
    }}>
      <SunBlob top={-140} right={-140} size={380} />
      <SunBlob top={520} right={-180} size={300} opacity={0.6} color={C.tomato} />

      {/* Bouncy sticker mark */}
      <div style={{
        position: 'relative',
        animation: phase >= 1 ? 'jp-float 3s ease-in-out infinite' : 'none',
        transform: phase >= 1 ? 'scale(1)' : 'scale(0.3)',
        opacity: phase >= 1 ? 1 : 0,
        transition: 'transform 0.6s cubic-bezier(0.34,1.56,0.64,1), opacity 0.4s ease',
      }}>
        <div style={{
          width: 140, height: 140, borderRadius: 36,
          background: C.tomato,
          border: `3px solid ${C.ink}`,
          boxShadow: `7px 7px 0 ${C.ink}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transform: 'rotate(-6deg)', position: 'relative',
        }}>
          {/* big J mark */}
          <div style={{ fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 92, color: C.paper, lineHeight: 1, marginTop: -8 }}>J</div>
          {/* sparkle stickers */}
          <div style={{ position: 'absolute', top: -16, right: -16 }}>
            <Sticker color={C.marigold} rotate={12}>✦</Sticker>
          </div>
          <div style={{ position: 'absolute', bottom: -14, left: -14 }}>
            <Sticker color={C.teal} rotate={-10} style={{ color: '#fff' }}>5</Sticker>
          </div>
        </div>
      </div>

      <div style={{
        marginTop: 36, textAlign: 'center',
        opacity: phase >= 1 ? 1 : 0,
        transform: phase >= 1 ? 'translateY(0)' : 'translateY(20px)',
        transition: 'all 0.6s ease 0.3s',
      }}>
        <div className="jp-urdu" style={{ fontSize: 44, color: C.ink, fontWeight: 700, lineHeight: 1.3 }}>جھٹ پٹ</div>
        <div className="jp-en" style={{ color: C.tomato, fontSize: 13, fontWeight: 900, letterSpacing: 4, marginTop: 4, textTransform: 'uppercase' }}>Jhat Pat</div>
      </div>

      <div style={{
        marginTop: 14,
        opacity: phase >= 1 ? 1 : 0,
        transition: 'opacity 0.6s ease 0.6s',
      }}>
        <div className="jp-urdu" style={{ color: C.inkSoft, fontSize: 18, textAlign: 'center', fontWeight: 500 }}>
          اردو محاورے سیکھیں، مزہ کریں
        </div>
      </div>

      <div style={{
        position: 'absolute', bottom: 90, display: 'flex', gap: 10,
        opacity: phase >= 1 ? 1 : 0, transition: 'opacity 0.5s ease 1s',
      }}>
        {[0,1,2].map(i => (
          <div key={i} style={{
            width: 10, height: 10, borderRadius: '50%',
            background: C.tomato, border: `2px solid ${C.ink}`,
            animation: phase >= 1 ? `jp-sparkle 1s ease-in-out ${i * 0.2}s infinite` : 'none',
          }} />
        ))}
      </div>
    </div>
  );
}

// ─── SCREEN 2: ONBOARDING ────────────────────────────────────────────────────
const ONBOARDING_SLIDES = [
  { icon: '🖼️', color: C.tomato,   bg: '#FFE0D5', title: 'تصویر دیکھو',          subtitle: 'پہلے تصویر دیکھیں اور اشارہ سمجھیں',           detail: 'AI سے بنی تصویریں اردو محاوروں کو دکھاتی ہیں' },
  { icon: '✅', color: C.teal,     bg: '#D5EFEA', title: 'جواب چنو',             subtitle: 'چار آپشن میں سے صحیح جواب منتخب کریں',         detail: 'جتنی جلدی جواب دیں، اتنے زیادہ پوائنٹس' },
  { icon: '🚀', color: C.purple,   bg: '#E8DDF4', title: 'سیکھو اور آگے بڑھو',    subtitle: 'سکے اور سٹریک بڑھائیں — روزانہ کھیل کر',       detail: 'XP کمائیں، لیول بڑھائیں اور ماہر بن جائیں' },
];

function OnboardingScreen({ onDone }) {
  const [slide, setSlide] = useState(0);
  const s = ONBOARDING_SLIDES[slide];
  const goNext = () => slide < 2 ? setSlide(slide + 1) : onDone();

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: s.bg, transition: 'background 0.4s ease', position: 'relative', overflow: 'hidden' }}>
      <SunBlob top={-100} right={-120} size={300} color={s.color} opacity={0.5} />

      <div style={{ display: 'flex', justifyContent: 'flex-end', padding: '16px 20px 0' }}>
        <button onClick={onDone} style={{
          background: 'transparent', border: 'none', cursor: 'pointer',
          fontFamily: 'Nunito, sans-serif', fontWeight: 800, fontSize: 14,
          color: C.ink, padding: '6px 12px',
          textDecoration: 'underline',
        }}>Skip</button>
      </div>

      <div key={slide} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 28px', animation: 'jp-slide-up 0.4s ease both' }}>
        <div style={{
          width: 140, height: 140, borderRadius: 36,
          background: s.color, border: `3px solid ${C.ink}`,
          boxShadow: `6px 6px 0 ${C.ink}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 64, marginBottom: 30,
          transform: 'rotate(-4deg)',
          animation: 'jp-float 3s ease-in-out infinite',
        }}>{s.icon}</div>

        <div className="jp-urdu" style={{ fontSize: 32, color: C.ink, fontWeight: 700, textAlign: 'center', lineHeight: 1.5, marginBottom: 12 }}>{s.title}</div>
        <div className="jp-urdu" style={{ fontSize: 19, color: C.ink, opacity: 0.85, textAlign: 'center', lineHeight: 1.8, marginBottom: 8 }}>{s.subtitle}</div>
        <div className="jp-urdu" style={{ fontSize: 16, color: C.inkSoft, textAlign: 'center', lineHeight: 1.8 }}>{s.detail}</div>
      </div>

      <div style={{ padding: '0 24px 40px' }}>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 8, marginBottom: 24 }}>
          {ONBOARDING_SLIDES.map((_, i) => (
            <div key={i} onClick={() => setSlide(i)} style={{
              width: i === slide ? 28 : 12, height: 12, borderRadius: 6,
              background: i === slide ? C.ink : 'transparent',
              border: `2px solid ${C.ink}`,
              transition: 'all 0.3s ease', cursor: 'pointer',
            }} />
          ))}
        </div>
        <BtnPrimary onClick={goNext}>
          <span className="jp-urdu" style={{ fontSize: 18 }}>{slide === 2 ? 'شروع کریں' : 'اگلا'}</span>
        </BtnPrimary>
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
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, position: 'relative', overflowY: 'auto' }}>
      <SunBlob top={-120} right={-140} size={340} />

      <div style={{ padding: '54px 24px 8px', textAlign: 'center', position: 'relative', zIndex: 2 }}>
        <div className="jp-urdu" style={{ fontSize: 38, color: C.ink, fontWeight: 700 }}>خوش آمدید</div>
        <div className="jp-urdu" style={{ fontSize: 17, color: C.inkSoft, marginTop: 4 }}>اپنا نام درج کریں اور کھیلنا شروع کریں</div>
      </div>

      <div style={{ padding: '20px 24px 40px', display: 'flex', flexDirection: 'column', gap: 22, position: 'relative', zIndex: 2 }}>
        {/* Language selector */}
        <div>
          <div className="jp-urdu" style={{ color: C.ink, fontSize: 15, fontWeight: 600, marginBottom: 10, textAlign: 'right' }}>ایپ کی زبان</div>
          <div style={{ display: 'flex', gap: 10 }}>
            {['ur','en'].map(l => (
              <button key={l} onClick={() => setLang(l)} style={{
                flex: 1, padding: '14px', borderRadius: 16, cursor: 'pointer',
                fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 16,
                background: lang === l ? C.marigold : C.card,
                border: `2.5px solid ${C.ink}`,
                color: C.ink,
                boxShadow: lang === l ? `3px 3px 0 ${C.ink}` : `2px 2px 0 ${C.ink}`,
                transition: 'all 0.2s ease',
              }}>
                {l === 'ur' ? 'اردو' : 'English'}
              </button>
            ))}
          </div>
        </div>

        {/* Avatar picker */}
        <div>
          <div className="jp-urdu" style={{ color: C.ink, fontSize: 15, fontWeight: 600, marginBottom: 12, textAlign: 'right' }}>اپنا اوتار چنیں</div>
          <div style={{ display: 'flex', gap: 10, justifyContent: 'space-between' }}>
            {avatars.map((av, i) => (
              <div key={i} onClick={() => setAvatarIdx(i)} style={{
                width: 50, height: 50, borderRadius: 16, fontSize: 26,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                background: i === avatarIdx ? C.tomato : C.card,
                border: `2.5px solid ${C.ink}`,
                boxShadow: i === avatarIdx ? `3px 3px 0 ${C.ink}` : `2px 2px 0 ${C.ink}`,
                cursor: 'pointer', transition: 'all 0.2s ease',
                transform: i === avatarIdx ? 'scale(1.08) rotate(-6deg)' : 'scale(1)',
              }}>
                {av}
              </div>
            ))}
          </div>
        </div>

        {/* Name input */}
        <div>
          <div className="jp-urdu" style={{ color: C.ink, fontSize: 15, fontWeight: 600, marginBottom: 10, textAlign: 'right' }}>اپنا نام</div>
          <input
            value={name} onChange={e => setName(e.target.value)}
            placeholder="اپنا نام لکھیں"
            style={{
              width: '100%', padding: '16px 18px',
              background: C.card,
              border: `2.5px solid ${C.ink}`,
              borderRadius: 16, color: C.ink, fontSize: 18,
              fontFamily: 'Noto Nastaliq Urdu, serif',
              direction: 'rtl', textAlign: 'right',
              outline: 'none', boxSizing: 'border-box',
              boxShadow: `3px 3px 0 ${C.ink}`,
              fontWeight: 500,
            }}
          />
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 6 }}>
          <BtnPrimary onClick={() => name.trim() && onDone(name.trim(), avatarIdx)} disabled={!name.trim()}>
            <span className="jp-urdu" style={{ fontSize: 18 }}>آگے بڑھیں</span>
          </BtnPrimary>
          <BtnGhost onClick={() => onDone('مہمان', 0)}>
            <span className="jp-urdu">مہمان کے طور پر کھیلو</span>
          </BtnGhost>
        </div>
      </div>
    </div>
  );
}

// ─── SCREEN 4: HOME ──────────────────────────────────────────────────────────
function HomeScreen({ profile, onNavigate, onStartGame, onOpenSettings }) {
  const modes = [
    { id: 'quick',    icon: '⚡',  urdu: 'جھٹ پٹ کھیلو', en: 'Quick Play',  color: C.tomato,   locked: false },
    { id: 'learn',    icon: '📖', urdu: 'سیکھو',        en: 'Learn Mode',  color: C.purple,   locked: false },
    { id: 'speed',    icon: '🔥', urdu: 'اسپیڈ راؤنڈ',  en: 'Speed Round', color: C.marigold, locked: profile.level < 5, lockMsg: 'Level 5 پر کھلے گا' },
    { id: 'category', icon: '📁', urdu: 'زمرہ',          en: 'Categories',  color: C.teal,     locked: false },
  ];

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, paddingBottom: 96, position: 'relative', overflowY: 'auto' }}>
      <SunBlob top={-100} right={-120} size={320} />

      {/* Top bar */}
      <div style={{ padding: '16px 20px 0', display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', position: 'relative', zIndex: 2 }}>
        <div>
          <div className="jp-en" style={{ fontSize: 13, fontWeight: 700, color: C.inkSoft, letterSpacing: 0.3 }}>سلام · Wednesday</div>
          <div className="jp-en" style={{ fontSize: 26, fontWeight: 900, color: C.ink, lineHeight: 1.05, marginTop: 2 }}>Hey, {profile.name}<span style={{ color: C.tomato }}>!</span></div>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <CoinBadge amount={profile.coins} />
          <button onClick={onOpenSettings} style={{
            width: 38, height: 38, borderRadius: 12,
            background: C.card, border: `2px solid ${C.ink}`,
            boxShadow: `2px 2px 0 ${C.ink}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            cursor: 'pointer',
          }}>
            <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
              <circle cx="9" cy="9" r="2.5" stroke={C.ink} strokeWidth="2"/>
              <path d="M9 1.5V3.5M9 14.5V16.5M3.2 3.2L4.6 4.6M13.4 13.4L14.8 14.8M1.5 9H3.5M14.5 9H16.5M3.2 14.8L4.6 13.4M13.4 4.6L14.8 3.2" stroke={C.ink} strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </button>
        </div>
      </div>

      {/* Profile card */}
      <div style={{ margin: '16px 20px 0', position: 'relative', zIndex: 2 }}>
        <div className="jp-card" style={{ padding: 18 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <div style={{
              width: 60, height: 60, borderRadius: 18,
              background: C.tomato, border: `2.5px solid ${C.ink}`,
              boxShadow: `3px 3px 0 ${C.ink}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 30,
              transform: 'rotate(-4deg)', flexShrink: 0,
            }}>{profile.avatar}</div>
            <div style={{ flex: 1 }}>
              <div className="jp-en" style={{ fontSize: 12, fontWeight: 800, color: C.inkSoft, textTransform: 'uppercase', letterSpacing: 1 }}>Level {profile.level}</div>
              <div className="jp-en" style={{ fontSize: 20, fontWeight: 900, color: C.ink, lineHeight: 1.1 }}>{profile.name}</div>
              <div className="jp-urdu" style={{ fontSize: 14, color: C.inkSoft, marginTop: 2 }}>{profile.levelTitle}</div>
            </div>
            {profile.streak > 0 && <StreakBadge count={profile.streak} />}
          </div>

          <div style={{ marginTop: 16 }}>
            <XPBar pct={profile.xpPct} level={profile.level} />
            <div className="jp-en" style={{ display: 'flex', justifyContent: 'space-between', marginTop: 6, fontSize: 11, fontWeight: 800, color: C.inkSoft }}>
              <span>{profile.xp} / {profile.xpNext} XP</span>
              <span>{profile.xpNext - profile.xp} to Level {profile.level + 1}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Daily goal banner */}
      <div style={{ margin: '14px 20px 0', position: 'relative', zIndex: 2 }}>
        <div style={{
          background: C.teal, color: '#fff',
          borderRadius: 18, border: `2.5px solid ${C.ink}`,
          boxShadow: `4px 4px 0 ${C.ink}`,
          padding: '14px 16px',
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{ fontSize: 32 }}>🎯</div>
          <div style={{ flex: 1 }}>
            <div className="jp-en" style={{ fontWeight: 900, fontSize: 15 }}>Daily Goal</div>
            <div className="jp-en" style={{ fontSize: 12, opacity: 0.9, fontWeight: 700 }}>{profile.todayCards} of 5 cards · keep going!</div>
          </div>
          <div className="jp-en" style={{
            background: '#fff', color: C.ink, fontWeight: 900, fontSize: 18,
            padding: '6px 12px', borderRadius: 12, border: `2px solid ${C.ink}`,
          }}>{profile.todayCards}/5</div>
        </div>
      </div>

      {/* Pick a mode */}
      <div className="jp-en" style={{ padding: '16px 20px 8px', fontSize: 13, fontWeight: 900, color: C.ink, opacity: 0.6, textTransform: 'uppercase', letterSpacing: 1, position: 'relative', zIndex: 2 }}>
        Pick a mode
      </div>

      <div style={{ padding: '0 20px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, position: 'relative', zIndex: 2 }}>
        {modes.map((m, i) => (
          <div
            key={m.id}
            onClick={() => !m.locked && onStartGame(m.id)}
            style={{
              background: m.locked ? C.paperWarm : C.card,
              borderRadius: 22, border: `2.5px solid ${C.ink}`,
              boxShadow: m.locked ? `2px 2px 0 ${C.ink}88` : `4px 4px 0 ${C.ink}`,
              padding: 14, cursor: m.locked ? 'default' : 'pointer',
              opacity: m.locked ? 0.7 : 1, position: 'relative',
              animation: `jp-slide-up 0.35s ease ${i * 0.07}s both`,
              transition: 'transform 0.1s ease, box-shadow 0.1s ease',
            }}
            onMouseDown={e => { if (!m.locked) { e.currentTarget.style.transform = 'translate(2px,2px)'; e.currentTarget.style.boxShadow = `2px 2px 0 ${C.ink}`; }}}
            onMouseUp={e => { if (!m.locked) { e.currentTarget.style.transform = 'translate(0,0)'; e.currentTarget.style.boxShadow = `4px 4px 0 ${C.ink}`; }}}
            onMouseLeave={e => { if (!m.locked) { e.currentTarget.style.transform = 'translate(0,0)'; e.currentTarget.style.boxShadow = `4px 4px 0 ${C.ink}`; }}}
          >
            <div style={{
              width: 44, height: 44, borderRadius: 14,
              background: m.locked ? C.inkMuted : m.color,
              border: `2px solid ${C.ink}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: 22, marginBottom: 10,
            }}>
              {m.locked ? '🔒' : m.icon}
            </div>
            <div className="jp-urdu" style={{ color: C.ink, fontSize: 17, fontWeight: 700, lineHeight: 1.4, marginBottom: 2 }}>{m.urdu}</div>
            {m.locked
              ? <div className="jp-urdu" style={{ color: C.tomato, fontSize: 12, fontWeight: 600 }}>{m.lockMsg}</div>
              : <div className="jp-en" style={{ color: C.inkSoft, fontSize: 12, fontWeight: 700 }}>{m.en}</div>}
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── SCREEN 5: PHOTO CARD ────────────────────────────────────────────────────
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
        if (t <= 0.25) { clearInterval(timerRef.current); handleAnswer(null); return 0; }
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
    setTimeout(() => setFrozen(false), 5000);
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

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, position: 'relative', overflow: 'hidden' }}>
      <SunBlob top={-100} right={-140} size={300} opacity={0.4} />

      {/* Header */}
      <div style={{ padding: '14px 20px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative', zIndex: 2 }}>
        <div className="jp-en" style={{ color: C.ink, fontWeight: 800, fontSize: 14, background: C.card, padding: '6px 12px', borderRadius: 999, border: `2px solid ${C.ink}` }}>
          Card <span style={{ color: C.tomato }}>{cardIdx}</span><span style={{ opacity: 0.6 }}>/{totalCards}</span>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          {streak >= 3 && <StreakBadge count={streak} />}
          <CoinBadge amount={coins} />
        </div>
      </div>

      {/* Timer */}
      <div style={{ padding: '0 20px 12px', position: 'relative', zIndex: 2 }}>
        <TimerBar pct={timeLeft / TOTAL_TIME} />
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 4 }}>
          <span className="jp-en" style={{
            fontSize: 12, fontWeight: 900,
            color: timeLeft < 5 ? C.tomato : C.inkSoft,
            fontVariantNumeric: 'tabular-nums',
          }}>
            {frozen ? '❄️ Frozen' : `${Math.ceil(timeLeft)}s`}
          </span>
        </div>
      </div>

      {/* Card image */}
      <div style={{ margin: '0 20px 14px', position: 'relative', zIndex: 2 }}>
        <div style={{
          borderRadius: 22, overflow: 'hidden',
          border: `2.5px solid ${C.ink}`,
          boxShadow: `5px 5px 0 ${C.ink}`,
          position: 'relative',
        }}>
          <ImgPlaceholder label={`AI illustration: "${phrase.roman}"`} style={{ height: 200, width: '100%' }} />
          <div style={{ position: 'absolute', top: 10, right: 10 }}>
            <Sticker color={C.marigold} rotate={6}>{phrase.category}</Sticker>
          </div>
        </div>
      </div>

      {/* Prompt */}
      <div style={{ padding: '0 20px 12px', position: 'relative', zIndex: 2 }}>
        <div className="jp-urdu" style={{ color: C.ink, fontSize: 17, textAlign: 'right', fontWeight: 600 }}>اس تصویر کا کیا مطلب ہے؟</div>
      </div>

      {/* MCQ options */}
      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10, flex: 1, position: 'relative', zIndex: 2 }}>
        {options.map((opt, i) => {
          const isEliminated = eliminated && opt !== phrase.meaning && options.filter(x => x !== phrase.meaning).indexOf(opt) > 0;
          let state = null;
          if (answered) {
            if (opt === phrase.meaning) state = 'correct';
            else if (opt === selected) state = 'wrong';
            else state = 'disabled';
          }
          if (isEliminated) state = 'disabled';
          return <MCQOption key={opt} text={opt} state={state} onClick={() => handleAnswer(opt)} index={i} />;
        })}
      </div>

      {/* Hint buttons */}
      <div style={{ padding: '12px 20px 22px', display: 'flex', gap: 10, position: 'relative', zIndex: 2 }}>
        <button onClick={() => !answered && coins >= 10 && !eliminated && onHintEliminate()} style={{
          flex: 1, padding: '12px', borderRadius: 14, cursor: 'pointer',
          background: C.card,
          border: `2px solid ${C.ink}`,
          boxShadow: `2.5px 2.5px 0 ${C.ink}`,
          color: C.ink,
          fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 13,
          opacity: answered || eliminated || coins < 10 ? 0.45 : 1,
        }}>
          ➖ Eliminate · 10🪙
        </button>
        <button onClick={handleFreeze} style={{
          flex: 1, padding: '12px', borderRadius: 14, cursor: 'pointer',
          background: C.card,
          border: `2px solid ${C.ink}`,
          boxShadow: `2.5px 2.5px 0 ${C.ink}`,
          color: C.ink,
          fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 13,
          opacity: answered || frozen || coins < 15 ? 0.45 : 1,
        }}>
          ❄️ Freeze · 15🪙
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
      background: correct ? '#D5EFEA' : '#FBE0DC',
      position: 'relative', overflow: 'hidden',
    }}>
      <SunBlob top={-100} right={-100} size={280} color={correct ? C.teal : C.tomato} opacity={0.45} />
      <SunBlob top={500} right={-150} size={280} color={correct ? C.marigold : C.purple} opacity={0.4} />
      <Confetti active={correct} />

      {/* Result icon */}
      <div style={{
        width: 130, height: 130, borderRadius: 36,
        background: correct ? C.teal : C.tomato,
        border: `3.5px solid ${C.ink}`, boxShadow: `8px 8px 0 ${C.ink}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        marginBottom: 28,
        transform: 'rotate(-6deg)',
        animation: show ? 'jp-bounce-in 0.5s cubic-bezier(0.34,1.56,0.64,1) both' : 'none',
      }}>
        <span style={{ color: '#fff', fontSize: 76, fontWeight: 900, fontFamily: 'Nunito, sans-serif', lineHeight: 1 }}>
          {correct ? '✓' : '✗'}
        </span>
      </div>

      {/* Label */}
      <div className="jp-urdu" style={{
        fontSize: 38, color: C.ink, fontWeight: 700,
        animation: show ? 'jp-slide-up 0.4s ease 0.2s both' : 'none',
        marginBottom: 10,
      }}>
        {correct ? 'شاباش!' : 'غلط جواب'}
      </div>

      {correct && points > 0 && (
        <div className="jp-en" style={{
          fontSize: 38, color: C.tomato, fontWeight: 900,
          animation: show ? 'jp-score-pop 0.6s ease 0.3s both' : 'none',
          marginBottom: 10,
          textShadow: `3px 3px 0 ${C.marigold}`,
        }}>
          +{points}
        </div>
      )}

      {correct && streak >= 3 && (
        <div style={{ animation: show ? 'jp-slide-up 0.4s ease 0.5s both' : 'none' }}>
          <Sticker color={C.marigold} rotate={-4}>🔥 {streak} streak!</Sticker>
        </div>
      )}

      <div className="jp-urdu" style={{
        position: 'absolute', bottom: 50,
        color: C.inkSoft, fontSize: 14, fontWeight: 500,
        animation: show ? 'jp-fade-in 0.4s ease 1s both' : 'none',
      }}>
        جاری ہے...
      </div>
    </div>
  );
}

// ─── SCREEN 7: REVEAL CARD ───────────────────────────────────────────────────
function RevealCardScreen({ phrase, cardIdx, totalCards, onStartMeaning, isLast }) {
  const [showExample, setShowExample] = useState(false);
  const [revealed, setRevealed] = useState(false);
  useEffect(() => { setTimeout(() => setRevealed(true), 100); }, []);

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, overflowY: 'auto', position: 'relative' }}>
      <SunBlob top={-100} right={-120} size={300} opacity={0.5} />

      {/* Header */}
      <div style={{ padding: '14px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative', zIndex: 2 }}>
        <div className="jp-en" style={{ color: C.ink, fontWeight: 800, fontSize: 14, background: C.card, padding: '6px 12px', borderRadius: 999, border: `2px solid ${C.ink}` }}>
          Card {cardIdx}/{totalCards} · Reveal
        </div>
        <Sticker color={C.marigold} rotate={4}>انکشاف ✦</Sticker>
      </div>

      {/* Image */}
      <div style={{ margin: '0 20px 16px', position: 'relative', zIndex: 2, animation: revealed ? 'jp-slide-up 0.4s ease both' : 'none' }}>
        <div style={{ borderRadius: 22, overflow: 'hidden', border: `2.5px solid ${C.ink}`, boxShadow: `5px 5px 0 ${C.ink}` }}>
          <ImgPlaceholder label={`Reveal: "${phrase.roman}"`} style={{ height: 170, width: '100%' }} />
        </div>
      </div>

      {/* Phrase card */}
      <div style={{ margin: '0 20px 14px', position: 'relative', zIndex: 2, animation: revealed ? 'jp-slide-up 0.4s ease 0.1s both' : 'none' }}>
        <div className="jp-card" style={{ padding: '22px 20px', textAlign: 'right' }}>
          <div className="jp-urdu" style={{ fontSize: 30, color: C.ink, fontWeight: 700, marginBottom: 4, lineHeight: 1.5 }}>{phrase.urdu}</div>
          <div className="jp-en" style={{ color: C.inkSoft, fontSize: 15, fontWeight: 700, marginBottom: 14 }}>{phrase.roman}</div>
          <div style={{ height: 2, background: C.ink, opacity: 0.1, marginBottom: 14 }} />
          <div className="jp-urdu" style={{ fontSize: 19, color: C.tomato, lineHeight: 1.8, fontWeight: 600 }}>
            معنی: {phrase.meaning}
          </div>
        </div>
      </div>

      {/* Example button */}
      <div style={{ padding: '0 20px 14px', position: 'relative', zIndex: 2, animation: revealed ? 'jp-slide-up 0.4s ease 0.2s both' : 'none' }}>
        <button onClick={() => setShowExample(true)} style={{
          width: '100%', padding: '14px', borderRadius: 16, cursor: 'pointer',
          background: C.card, border: `2.5px solid ${C.ink}`, boxShadow: `3px 3px 0 ${C.ink}`,
          color: C.ink, fontSize: 16,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          fontFamily: 'Nunito, sans-serif', fontWeight: 800,
        }}>
          <span style={{ fontSize: 18 }}>👁</span>
          <span className="jp-urdu" style={{ fontSize: 16 }}>مثال دیکھیں</span>
        </button>
      </div>

      {/* CTA */}
      <div style={{ padding: '0 20px 28px', marginTop: 'auto', position: 'relative', zIndex: 2, animation: revealed ? 'jp-slide-up 0.4s ease 0.3s both' : 'none' }}>
        <BtnPrimary onClick={onStartMeaning}>
          <span className="jp-urdu" style={{ fontSize: 18 }}>معنی کوئز ←</span>
        </BtnPrimary>
      </div>

      {/* Example bottom sheet */}
      {showExample && (
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(42,24,16,0.55)', display: 'flex', alignItems: 'flex-end', zIndex: 100 }} onClick={() => setShowExample(false)}>
          <div style={{
            background: C.card, borderRadius: '24px 24px 0 0',
            border: `2.5px solid ${C.ink}`,
            borderBottom: 'none',
            padding: '24px 24px 40px',
            width: '100%', animation: 'jp-slide-up 0.3s ease both',
          }} onClick={e => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
              <button onClick={() => setShowExample(false)} style={{
                width: 36, height: 36, borderRadius: 10,
                background: C.paper, border: `2px solid ${C.ink}`, boxShadow: `2px 2px 0 ${C.ink}`,
                color: C.ink, cursor: 'pointer', fontSize: 16, fontWeight: 900,
              }}>✕</button>
              <Sticker color={C.tomato} rotate={4} style={{ color: '#fff' }}>مثال</Sticker>
            </div>
            <div className="jp-urdu" style={{ fontSize: 22, color: C.ink, lineHeight: 1.9, textAlign: 'right', marginBottom: 10, fontWeight: 600 }}>{phrase.example}</div>
            <div className="jp-en" style={{ color: C.inkSoft, fontSize: 14, fontWeight: 700 }}>{phrase.roman}</div>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── SCREEN 7b: MEANING QUIZ ─────────────────────────────────────────────────
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
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, position: 'relative', overflow: 'hidden' }}>
      <SunBlob top={-100} right={-120} size={300} color={C.purple} opacity={0.35} />

      <div style={{ padding: '14px 20px 10px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative', zIndex: 2 }}>
        <div className="jp-en" style={{ color: C.ink, fontWeight: 800, fontSize: 14, background: C.card, padding: '6px 12px', borderRadius: 999, border: `2px solid ${C.ink}` }}>
          Card {cardIdx}/{totalCards}
        </div>
        <Sticker color={C.purple} rotate={4} style={{ color: '#fff' }}>مرحلہ ۲/۲</Sticker>
      </div>

      <div style={{ padding: '0 20px 14px', position: 'relative', zIndex: 2 }}>
        <TimerBar pct={timeLeft / TOTAL_TIME} />
      </div>

      {/* Phrase display */}
      <div style={{ margin: '4px 20px 16px', position: 'relative', zIndex: 2 }}>
        <div className="jp-card" style={{ padding: '22px 20px', textAlign: 'center' }}>
          <div className="jp-urdu" style={{ fontSize: 28, color: C.ink, fontWeight: 700, lineHeight: 1.5 }}>{phrase.urdu}</div>
          <div className="jp-en" style={{ color: C.inkSoft, fontSize: 14, fontWeight: 700, marginTop: 4 }}>{phrase.roman}</div>
        </div>
      </div>

      <div style={{ padding: '0 20px 10px', position: 'relative', zIndex: 2 }}>
        <div className="jp-urdu" style={{ color: C.ink, fontSize: 17, textAlign: 'right', fontWeight: 600 }}>اس فقرے کا صحیح مفہوم کیا ہے؟</div>
      </div>

      <div style={{ padding: '0 20px', display: 'flex', flexDirection: 'column', gap: 10, flex: 1, position: 'relative', zIndex: 2 }}>
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
      <div style={{ height: 22 }} />
    </div>
  );
}

// ─── SCREEN 8: SESSION SUMMARY ───────────────────────────────────────────────
function SessionSummaryScreen({ results, onPlayAgain, onHome }) {
  const [countedScore, setCountedScore] = useState(0);
  const totalScore = results.reduce((s, r) => s + r.pts, 0);
  const correct = results.filter(r => r.correct).length;
  const xpEarned = correct * 10 + results.length * 2 + (correct === results.length ? 50 : 0);

  useEffect(() => {
    let start = 0;
    const step = Math.max(totalScore / 40, 1);
    const t = setInterval(() => {
      start += step;
      if (start >= totalScore) { setCountedScore(totalScore); clearInterval(t); }
      else setCountedScore(Math.floor(start));
    }, 30);
    return () => clearInterval(t);
  }, []);

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, overflowY: 'auto', position: 'relative' }}>
      <SunBlob top={-140} right={-140} size={400} opacity={0.7} />
      <Confetti active={correct >= results.length / 2} />

      <div style={{ padding: '40px 24px 16px', textAlign: 'center', position: 'relative', zIndex: 2 }}>
        <div style={{ fontSize: 60, marginBottom: 6, display: 'inline-block', transform: 'rotate(-8deg)' }}>🏆</div>
        <div className="jp-urdu" style={{ fontSize: 30, color: C.ink, fontWeight: 700, marginBottom: 8 }}>سیشن مکمل!</div>
        <div className="jp-en" style={{
          fontSize: 64, fontWeight: 900, color: C.tomato,
          textShadow: `4px 4px 0 ${C.marigold}, 5px 5px 0 ${C.ink}`,
          letterSpacing: -2, lineHeight: 1,
          animation: 'jp-count-up 0.5s ease both',
        }}>
          {countedScore.toLocaleString()}
        </div>
        <div className="jp-en" style={{ color: C.inkSoft, fontSize: 13, fontWeight: 800, letterSpacing: 1, textTransform: 'uppercase', marginTop: 8 }}>Total Points</div>
      </div>

      {/* Stats row */}
      <div style={{ padding: '0 20px 18px', display: 'flex', gap: 10, position: 'relative', zIndex: 2 }}>
        {[
          { label: 'Correct',  value: `${correct}/${results.length}`, icon: '✅', color: C.teal },
          { label: 'XP Earned', value: `+${xpEarned}`, icon: '⭐', color: C.marigold },
          { label: 'Accuracy', value: `${Math.round((correct / results.length) * 100)}%`, icon: '🎯', color: C.purple },
        ].map(s => (
          <div key={s.label} style={{
            flex: 1, background: C.card, borderRadius: 18,
            border: `2.5px solid ${C.ink}`, boxShadow: `3px 3px 0 ${C.ink}`,
            padding: '14px 8px', textAlign: 'center',
            animation: 'jp-slide-up 0.4s ease both',
          }}>
            <div style={{ fontSize: 22, marginBottom: 4 }}>{s.icon}</div>
            <div className="jp-en" style={{ color: s.color, fontWeight: 900, fontSize: 18 }}>{s.value}</div>
            <div className="jp-en" style={{ color: C.inkSoft, fontSize: 11, marginTop: 2, fontWeight: 800 }}>{s.label}</div>
          </div>
        ))}
      </div>

      <div className="jp-en" style={{ padding: '0 20px 10px', fontSize: 13, fontWeight: 900, color: C.ink, opacity: 0.6, textTransform: 'uppercase', letterSpacing: 1, position: 'relative', zIndex: 2 }}>
        Card Breakdown
      </div>

      <div style={{ padding: '0 20px', position: 'relative', zIndex: 2 }}>
        {results.map((r, i) => (
          <div key={i} style={{
            background: C.card, borderRadius: 16,
            border: `2px solid ${C.ink}`, boxShadow: `2.5px 2.5px 0 ${C.ink}`,
            padding: '12px 16px', marginBottom: 10,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            animation: `jp-slide-up 0.3s ease ${i * 0.06}s both`,
          }}>
            <div className="jp-urdu" style={{ color: C.ink, fontSize: 17, flex: 1, textAlign: 'right', fontWeight: 600 }}>{r.urdu}</div>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginLeft: 12 }}>
              {r.correct
                ? <div style={{ width: 24, height: 24, borderRadius: '50%', background: C.teal, border: `2px solid ${C.ink}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 900, fontSize: 13 }}>✓</div>
                : <div style={{ width: 24, height: 24, borderRadius: '50%', background: C.tomato, border: `2px solid ${C.ink}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 900, fontSize: 13 }}>✗</div>}
              {r.pts > 0 && <span className="jp-en" style={{ color: C.tomato, fontWeight: 900, fontSize: 14 }}>+{r.pts}</span>}
            </div>
          </div>
        ))}
      </div>

      <div style={{ padding: '14px 20px 36px', display: 'flex', flexDirection: 'column', gap: 12, position: 'relative', zIndex: 2 }}>
        <BtnPrimary onClick={onPlayAgain}><span className="jp-urdu" style={{ fontSize: 18 }}>دوبارہ کھیلو</span></BtnPrimary>
        <BtnGhost onClick={onHome}><span className="jp-urdu">گھر جاؤ</span></BtnGhost>
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
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, paddingBottom: 96, position: 'relative', overflow: 'hidden' }}>
      <SunBlob top={-100} right={-130} size={320} opacity={0.5} />

      <div style={{ padding: '16px 20px 12px', position: 'relative', zIndex: 2 }}>
        <div className="jp-en" style={{ fontSize: 26, fontWeight: 900, color: C.ink, marginBottom: 4 }}>Library</div>
        <div className="jp-urdu" style={{ fontSize: 16, color: C.inkSoft, marginBottom: 14, fontWeight: 500 }}>کتب خانہ — سارے محاورے</div>

        <div style={{ position: 'relative', marginBottom: 12 }}>
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="محاورہ تلاش کریں..."
            style={{
              width: '100%', padding: '13px 16px 13px 42px',
              background: C.card, border: `2.5px solid ${C.ink}`, borderRadius: 16,
              boxShadow: `2px 2px 0 ${C.ink}`,
              color: C.ink, fontSize: 16,
              fontFamily: 'Noto Nastaliq Urdu, serif', direction: 'rtl',
              outline: 'none', boxSizing: 'border-box',
            }}
          />
          <span style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: C.ink, fontSize: 18 }}>🔍</span>
        </div>

        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 4 }}>
          {['سب','محاورہ','کہاوت'].map(f => (
            <button key={f} onClick={() => setCatFilter(f)} style={{
              padding: '7px 14px', borderRadius: 999, cursor: 'pointer',
              fontFamily: 'Noto Nastaliq Urdu, serif', fontSize: 14,
              background: catFilter === f ? C.tomato : C.card,
              border: `2px solid ${C.ink}`,
              boxShadow: catFilter === f ? `2px 2px 0 ${C.ink}` : 'none',
              color: catFilter === f ? '#fff' : C.ink,
              fontWeight: 700,
            }}>{f}</button>
          ))}
          {['سب','آسان','درمیانہ','مشکل'].map(f => (
            <button key={f} onClick={() => setDiffFilter(f)} style={{
              padding: '7px 14px', borderRadius: 999, cursor: 'pointer',
              fontFamily: 'Noto Nastaliq Urdu, serif', fontSize: 14,
              background: diffFilter === f ? C.purple : C.card,
              border: `2px solid ${C.ink}`,
              boxShadow: diffFilter === f ? `2px 2px 0 ${C.ink}` : 'none',
              color: diffFilter === f ? '#fff' : C.ink,
              fontWeight: 700,
            }}>{f}</button>
          ))}
        </div>
        <div className="jp-en" style={{ color: C.inkSoft, fontSize: 13, marginTop: 10, fontWeight: 800 }}>{filtered.length} phrases</div>
      </div>

      <div style={{ padding: '0 20px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, overflowY: 'auto', flex: 1, position: 'relative', zIndex: 2 }}>
        {filtered.map((p, i) => (
          <div key={p.id} style={{
            background: C.card, borderRadius: 18,
            border: `2.5px solid ${C.ink}`, boxShadow: `3px 3px 0 ${C.ink}`,
            overflow: 'hidden',
            animation: `jp-slide-up 0.3s ease ${i * 0.05}s both`,
            cursor: 'pointer',
          }}>
            <ImgPlaceholder label={p.roman} style={{ height: 110, width: '100%' }} />
            <div style={{ padding: '10px 12px 14px' }}>
              <div className="jp-urdu" style={{ fontSize: 17, color: C.ink, lineHeight: 1.6, fontWeight: 600 }}>{p.urdu}</div>
              <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
                <span className="jp-urdu" style={{ background: C.marigold, color: C.ink, fontSize: 11, padding: '3px 8px', borderRadius: 999, border: `1.5px solid ${C.ink}`, fontWeight: 700 }}>{p.category}</span>
                <span className="jp-urdu" style={{ background: C.paperWarm, color: C.ink, fontSize: 11, padding: '3px 8px', borderRadius: 999, border: `1.5px solid ${C.ink}`, fontWeight: 700 }}>{p.difficulty}</span>
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
    { date: 'Today',    cards: 5, correct: 4, pts: 1850, mode: 'Quick Play' },
    { date: 'Yesterday',cards: 5, correct: 3, pts: 1200, mode: 'Learn' },
    { date: '2d ago',   cards: 5, correct: 5, pts: 2400, mode: 'Quick Play' },
  ];

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, overflowY: 'auto', paddingBottom: 96, position: 'relative', overflow: 'hidden' }}>
      <SunBlob top={-140} right={-140} size={380} opacity={0.7} />

      <div style={{ padding: '24px 20px 16px', textAlign: 'center', position: 'relative', zIndex: 2 }}>
        <div style={{
          width: 90, height: 90, borderRadius: 28,
          background: C.tomato, border: `3px solid ${C.ink}`,
          boxShadow: `5px 5px 0 ${C.ink}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 44, margin: '0 auto 14px',
          transform: 'rotate(-5deg)',
          animation: 'jp-float 3s ease-in-out infinite',
        }}>{profile.avatar}</div>
        <div className="jp-en" style={{ color: C.ink, fontWeight: 900, fontSize: 24 }}>{profile.name}</div>
        <div className="jp-urdu" style={{ color: C.tomato, fontSize: 16, marginBottom: 16, fontWeight: 600 }}>{profile.levelTitle}</div>
        <XPBar pct={profile.xpPct} level={profile.level} />
        <div className="jp-en" style={{ color: C.inkSoft, fontSize: 12, marginTop: 8, fontWeight: 800 }}>{profile.xp} / {profile.xpNext} XP to Level {profile.level + 1}</div>
      </div>

      {/* Stats grid 2×2 */}
      <div style={{ padding: '12px 20px 0', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, position: 'relative', zIndex: 2 }}>
        {[
          { label: 'Streak',  value: profile.streak, icon: '🔥', color: C.tomato },
          { label: 'Best',    value: profile.bestStreak, icon: '🏆', color: C.marigold },
          { label: 'Coins',   value: profile.coins, icon: '🪙', color: C.marigold },
          { label: 'Correct', value: '87%', icon: '✅', color: C.teal },
        ].map((s, i) => (
          <div key={s.label} style={{
            background: C.card, borderRadius: 16,
            border: `2.5px solid ${C.ink}`, boxShadow: `3px 3px 0 ${C.ink}`,
            padding: '14px 16px',
            display: 'flex', alignItems: 'center', gap: 12,
            animation: `jp-slide-up 0.3s ease ${i * 0.06}s both`,
          }}>
            <div style={{ width: 38, height: 38, borderRadius: 12, background: s.color, border: `2px solid ${C.ink}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>
              {s.icon}
            </div>
            <div>
              <div className="jp-en" style={{ color: C.ink, fontWeight: 900, fontSize: 22, lineHeight: 1 }}>{s.value}</div>
              <div className="jp-en" style={{ color: C.inkSoft, fontSize: 11, marginTop: 2, fontWeight: 800, textTransform: 'uppercase', letterSpacing: 0.5 }}>{s.label}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Recent sessions */}
      <div style={{ padding: '20px 20px 0', position: 'relative', zIndex: 2 }}>
        <div className="jp-en" style={{ color: C.ink, fontWeight: 900, fontSize: 13, marginBottom: 12, opacity: 0.6, textTransform: 'uppercase', letterSpacing: 1 }}>Recent Sessions</div>
        {sessions.map((s, i) => (
          <div key={i} style={{
            background: C.card, borderRadius: 14,
            border: `2px solid ${C.ink}`, boxShadow: `2.5px 2.5px 0 ${C.ink}`,
            padding: '12px 14px', marginBottom: 10,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            animation: `jp-slide-up 0.3s ease ${i * 0.08}s both`,
          }}>
            <div>
              <div className="jp-en" style={{ color: C.ink, fontWeight: 900, fontSize: 15 }}>{s.mode}</div>
              <div className="jp-en" style={{ color: C.inkSoft, fontSize: 12, fontWeight: 700 }}>{s.date}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="jp-en" style={{ color: C.tomato, fontWeight: 900, fontSize: 16 }}>+{s.pts}</div>
              <div className="jp-en" style={{ color: C.inkSoft, fontSize: 11, fontWeight: 700 }}>{s.correct}/{s.cards} correct</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── SCREEN 11: SETTINGS ─────────────────────────────────────────────────────
function SettingsScreen({ onBack }) {
  const [sound, setSound] = useState(true);
  const [haptic, setHaptic] = useState(true);
  const [reminders, setReminders] = useState(false);
  const [lang, setLang] = useState('ur');

  const Toggle = ({ value, onChange }) => (
    <div onClick={() => onChange(!value)} style={{
      width: 52, height: 30,
      borderRadius: 999, cursor: 'pointer',
      background: value ? C.teal : C.paperWarm,
      border: `2.5px solid ${C.ink}`,
      boxShadow: `2px 2px 0 ${C.ink}`,
      position: 'relative', transition: 'background 0.3s ease',
      flexShrink: 0,
    }}>
      <div style={{
        position: 'absolute', top: 2, left: value ? 22 : 2,
        width: 20, height: 20, borderRadius: '50%',
        background: '#fff', border: `2px solid ${C.ink}`,
        transition: 'left 0.3s cubic-bezier(0.34,1.56,0.64,1)',
      }} />
    </div>
  );

  const Row = ({ label, sublabel, control, isLast }) => (
    <div style={{
      padding: '14px 16px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      borderBottom: isLast ? 'none' : `1.5px solid ${C.ink}11`,
    }}>
      <div>
        <div className="jp-en" style={{ color: C.ink, fontWeight: 800, fontSize: 15 }}>{label}</div>
        {sublabel && <div className="jp-en" style={{ color: C.inkSoft, fontSize: 12, marginTop: 2, fontWeight: 700 }}>{sublabel}</div>}
      </div>
      {control}
    </div>
  );

  const Section = ({ title, children }) => (
    <div style={{ marginBottom: 18 }}>
      <div className="jp-en" style={{ color: C.ink, opacity: 0.6, fontSize: 11, fontWeight: 900, letterSpacing: 1.2, textTransform: 'uppercase', padding: '0 20px 8px' }}>{title}</div>
      <div style={{
        margin: '0 20px',
        background: C.card, borderRadius: 18,
        border: `2.5px solid ${C.ink}`, boxShadow: `3px 3px 0 ${C.ink}`,
        overflow: 'hidden',
      }}>{children}</div>
    </div>
  );

  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: C.paper, overflowY: 'auto', position: 'relative' }}>
      <SunBlob top={-100} right={-130} size={300} opacity={0.5} />

      <div style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', gap: 12, position: 'relative', zIndex: 2 }}>
        <button onClick={onBack} style={{
          width: 38, height: 38, borderRadius: 12,
          background: C.card, border: `2px solid ${C.ink}`, boxShadow: `2px 2px 0 ${C.ink}`,
          cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 18, color: C.ink, fontWeight: 900,
        }}>←</button>
        <div className="jp-en" style={{ fontSize: 22, fontWeight: 900, color: C.ink }}>Settings</div>
      </div>

      <div style={{ position: 'relative', zIndex: 2 }}>
        <Section title="Language">
          <div style={{ padding: 12, display: 'flex', gap: 10 }}>
            {['ur','en'].map(l => (
              <button key={l} onClick={() => setLang(l)} style={{
                flex: 1, padding: '12px', borderRadius: 14, cursor: 'pointer',
                fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 15,
                background: lang === l ? C.marigold : C.paperWarm,
                border: `2px solid ${C.ink}`,
                boxShadow: lang === l ? `2px 2px 0 ${C.ink}` : 'none',
                color: C.ink,
              }}>{l === 'ur' ? 'اردو' : 'English'}</button>
            ))}
          </div>
        </Section>

        <Section title="Gameplay">
          <Row label="Sound Effects"   sublabel="Tap & answer sounds"  control={<Toggle value={sound}     onChange={setSound} />} />
          <Row label="Haptic Feedback" sublabel="Vibrate on touch"      control={<Toggle value={haptic}    onChange={setHaptic} />} />
          <Row label="Daily Reminders" sublabel="Notify at 9 PM"        control={<Toggle value={reminders} onChange={setReminders} />} isLast />
        </Section>

        <Section title="Account">
          <Row label="Change Name"    sublabel="Shaheer"              control={<span style={{ color: C.tomato, fontSize: 22, fontWeight: 900 }}>›</span>} />
          <Row label="Change Avatar"  sublabel="😊"                   control={<span style={{ color: C.tomato, fontSize: 22, fontWeight: 900 }}>›</span>} isLast />
        </Section>

        <Section title="About">
          <Row label="App Version"    control={<span className="jp-en" style={{ color: C.inkSoft, fontWeight: 800, fontSize: 13 }}>1.0.0+1</span>} />
          <Row label="Clear Cache"    control={<span style={{ color: C.tomato, fontSize: 22, fontWeight: 900 }}>›</span>} isLast />
        </Section>

        <div style={{ padding: '8px 20px 36px' }}>
          <button style={{
            width: '100%', padding: '14px', borderRadius: 16, cursor: 'pointer',
            background: C.card, border: `2.5px solid ${C.tomato}`,
            boxShadow: `3px 3px 0 ${C.tomato}`,
            color: C.tomato, fontFamily: 'Nunito, sans-serif', fontWeight: 900, fontSize: 15,
          }}>Sign Out</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  PHRASES, SplashScreen, OnboardingScreen, SignInScreen, HomeScreen,
  PhotoCardScreen, ResultFlashScreen, RevealCardScreen, MeaningQuizScreen,
  SessionSummaryScreen, LibraryScreen, ProfileScreen, SettingsScreen,
});
