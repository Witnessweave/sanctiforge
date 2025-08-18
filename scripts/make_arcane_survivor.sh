#!/usr/bin/env bash
set -euo pipefail
log(){ printf '%s %s\n' "$(date -u -Is)" "$*" | tee -a "$HOME/sanctiforge/logs/arcane_survivor.log" >/dev/null; }

# Require Node 22+ (we already set up nvm earlier)
if ! command -v node >/dev/null; then
  echo "Node not found. Load nvm then: . \"$HOME/.nvm/nvm.sh\" && nvm use 22" >&2; exit 1
fi

GAME="$HOME/sanctiforge/games/arcane-witness-survivor"

log "BEGIN — scaffold"
if [ ! -d "$GAME" ]; then
  mkdir -p "$(dirname "$GAME")"
  cd "$(dirname "$GAME")"
  npm create vite@latest arcane-witness-survivor -- --template vanilla-ts </dev/tty
else
  log "exists — $GAME"
fi

cd "$GAME"
log "npm install"
npm i

# --- Secure dev config (localhost only), relative base for file:// builds
cat > vite.config.ts <<'VCONF'
import { defineConfig } from 'vite'

export default defineConfig({
  base: './',
  server: {
    host: '127.0.0.1',
    port: 5173,
    strictPort: true,
    cors: false,
    open: false,
    fs: { strict: true, allow: ['.'] },
    hmr: { host: '127.0.0.1', protocol: 'ws', port: 5173 }
  },
  preview: { host: '127.0.0.1', port: 4173, strictPort: true }
})
VCONF

# --- tsconfig (strict)
cat > tsconfig.json <<'TSCFG'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "lib": ["ES2020", "DOM"],
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true
  },
  "include": ["src"]
}
TSCFG

# --- index.html
cat > index.html <<'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; font-src 'self' data:; object-src 'none'; base-uri 'none'; frame-ancestors 'none'">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Arcane Witness: Survivor™</title>
    <style>
      html,body { margin:0; height:100%; background:#0b0b0f; color:#cbd5e1; font:14px/1.4 system-ui, sans-serif; }
      #ui { position:fixed; inset:0; pointer-events:none; }
      .hud { position:fixed; top:8px; left:8px; background:#111a; border:1px solid #334; padding:6px 8px; border-radius:6px; }
      .lvlup { position:fixed; inset:0; display:none; align-items:center; justify-content:center; background:#000a; }
      .card { pointer-events:auto; background:#121826; border:1px solid #3b4252; border-radius:10px; padding:12px; width:320px; box-shadow:0 0 24px #6cf4; }
      .grid { display:grid; gap:10px; }
      .btn { border:1px solid #3b4252; background:#1b2233; color:#cde; padding:10px 12px; border-radius:8px; cursor:pointer; }
      .btn:hover { background:#233047; }
      .note { opacity:.7; font-size:12px; }
      .bar { position:fixed; bottom:10px; left:50%; transform:translateX(-50%); width:min(800px,90vw); background:#111a; border:1px solid #334; border-radius:6px; height:10px; }
      .bar > i { display:block; height:100%; background:linear-gradient(90deg,#8ef,#9cf); width:0% }
      .topright { position:fixed; top:8px; right:8px; opacity:.8 }
    </style>
  </head>
  <body>
    <canvas id="game"></canvas>
    <div id="ui">
      <div class="hud" id="hud"></div>
      <div class="topright">WASD move • Auto-cast • Space dash • P pause • L toggle glow</div>
      <div class="bar"><i id="xpfill"></i></div>
      <div class="lvlup" id="lvlup">
        <div class="card">
          <div style="font-weight:700;margin-bottom:8px">Choose a Blessing</div>
          <div class="grid" id="choices"></div>
          <div class="note">Press 1 / 2 / 3 to choose</div>
        </div>
      </div>
    </div>
    <script type="module" src="/src/main.ts"></script>
  </body>
</html>
HTML

# --- src/main.ts (core game)
mkdir -p src
cat > src/main.ts <<'TS'
type Vec = { x:number; y:number };
const rnd = (()=>{ let s=seed(Date.now()); function seed(n:number){ s=(n>>>0)||1; } function f(){ s|=0; s=(s+0x6D2B79F5)|0; let t=Math.imul(s^s>>>15,1|s); t^=t+Math.imul(t^t>>>7,61|t); return ((t^t>>>14)>>>0)/4294967296; } return Object.assign(f,{seed}); })();
const clamp=(v:number,a:number,b:number)=>Math.max(a,Math.min(b,v));
const len=(v:Vec)=>Math.hypot(v.x,v.y); const norm=(v:Vec)=>{const L=len(v)||1; return {x:v.x/L,y:v.y/L}};
const add=(a:Vec,b:Vec)=>({x:a.x+b.x,y:a.y+b.y}); const sub=(a:Vec,b:Vec)=>({x:a.x-b.x,y:a.y-b.y});
const mul=(a:Vec,s:number)=>({x:a.x*s,y:a.y*s}); const dist=(a:Vec,b:Vec)=>len(sub(a,b));

const CANVAS = document.getElementById('game') as HTMLCanvasElement;
const HUD = document.getElementById('hud')!;
const LVLUP = document.getElementById('lvlup') as HTMLDivElement;
const CHOICES = document.getElementById('choices')!;
const XPBAR = document.getElementById('xpfill') as HTMLIFrameElement;

let DPR=1, W=0, H=0, CTX:CanvasRenderingContext2D;
function resize(){
  DPR = Math.min(2, window.devicePixelRatio||1);
  W = innerWidth; H = innerHeight;
  CANVAS.width = Math.floor(W*DPR); CANVAS.height=Math.floor(H*DPR);
  CANVAS.style.width=W+'px'; CANVAS.style.height=H+'px';
  CTX = CANVAS.getContext('2d')!;
}
new ResizeObserver(resize).observe(document.body); resize();

const keys:Record<string,boolean>={};
onkeydown = e => { keys[e.key.toLowerCase()]=true; if(showingChoices && ['1','2','3'].includes(e.key)) pickUpgrade(parseInt(e.key)-1); };
onkeyup   = e => { keys[e.key.toLowerCase()]=false; };

let running=true; onblur=()=>running=false; onfocus=()=>running=true;
let glowOn=true;

type Enemy={ p:Vec; v:Vec; r:number; hp:number; maxhp:number; };
type Proj={ p:Vec; v:Vec; r:number; dmg:number; life:number; };
type Orb={ p:Vec; v:Vec; r:number; xp:number; };

const player = {
  p:{x:W/2,y:H/2}, v:{x:0,y:0}, r:14,
  speed:240, dash:0, dashCD:0, pickup:110,
  projCooldown:0.6, projTimer:0, projSpeed:520, projDmg:10, projCount:1,
};

let time=0, kills=0, level=1, xp=0, xpNext=30, showingChoices=false;
const enemies:Enemy[]=[]; const projs:Proj[]=[]; const orbs:Orb[]=[];

function spawnEnemy(dt:number){
  // spawn rate scales with time
  const rate = 0.6 + time*0.02;
  if (rnd() < dt*rate){
    const side = Math.floor(rnd()*4);
    const margin = 40;
    const p:Vec = side===0?{x:-margin,y:rnd()*H}: side===1?{x:W+margin,y:rnd()*H}: side===2?{x:rnd()*W,y:-margin}:{x:rnd()*W,y:H+margin};
    const speed = 60 + rnd()*60 + Math.min(240,time*6);
    const r = 14 + rnd()*6;
    const v = mul(norm(sub(player.p,p)), speed);
    const hp = 20 + time*2 + rnd()*10;
    enemies.push({p,v,r,hp,maxhp:hp});
  }
}

function castSpell(){
  // auto-aim nearest enemy
  const targets = enemies.slice().sort((a,b)=>dist(a.p,player.p)-dist(b.p,player.p));
  if (!targets.length) return;
  for (let i=0;i<player.projCount;i++){
    const t = targets[i%targets.length];
    const dir = norm(sub(t.p,player.p));
    const jitter = (rnd()-0.5)*0.2;
    const ang = Math.atan2(dir.y,dir.x)+jitter;
    const v={x:Math.cos(ang)*player.projSpeed, y:Math.sin(ang)*player.projSpeed};
    projs.push({p:{x:player.p.x,y:player.p.y}, v, r:5, dmg:player.projDmg, life:1.2});
  }
}

function dropOrbs(e:Enemy){
  const n = 1 + Math.floor(e.maxhp/30);
  for(let i=0;i<n;i++){
    const ang = rnd()*Math.PI*2; const s= 40+rnd()*60;
    const v={x:Math.cos(ang)*s,y:Math.sin(ang)*s};
    orbs.push({p:{...e.p}, v, r:5, xp:8+Math.floor(rnd()*6)});
  }
}

function levelUp(){
  level++; xp=0; xpNext = Math.floor(xpNext*1.25 + 10);
  showChoices([
    {name:'+1 Projectile', apply:()=>player.projCount=Math.min(player.projCount+1,6)},
    {name:'+25% Damage', apply:()=>player.projDmg=Math.round(player.projDmg*1.25)},
    {name:'+20% Fire Rate', apply:()=>player.projCooldown=Math.max(0.18, player.projCooldown*0.8)},
    {name:'+15% Move Speed', apply:()=>player.speed=Math.round(player.speed*1.15)},
    {name:'+50 Pickup Radius', apply:()=>player.pickup+=50},
    {name:'Dash Quicker', apply:()=>player.dashCD=Math.max(0.8, player.dashCD===0?2.5:player.dashCD*0.85)},
  ]);
}

type Choice={ name:string; apply:()=>void };
function showChoices(pool:Choice[]){
  showingChoices=true;
  CHOICES.innerHTML='';
  const picks:Choice[]=[];
  const used=new Set<number>();
  while(picks.length<3 && used.size<pool.length){
    const k=Math.floor(rnd()*pool.length);
    if(!used.has(k)){ used.add(k); picks.push(pool[k]); }
  }
  picks.forEach((c,i)=>{
    const b=document.createElement('button'); b.className='btn'; b.textContent=`${i+1}. ${c.name}`; b.onclick=()=>pickUpgrade(i);
    CHOICES.appendChild(b);
  });
  LVLUP.style.display='flex';
}
function pickUpgrade(index:number){
  const btn = CHOICES.children[index] as HTMLButtonElement;
  if(!btn) return;
  const txt = btn.textContent!.replace(/^\d+\. /,'');
  const found = Array.from(CHOICES.children).find(b=> (b as HTMLButtonElement).textContent!.endsWith(txt)) as HTMLButtonElement;
  const label = found?.textContent||'';
  // Map label to effect
  const map:Record<string,()=>void>={
    '+1 Projectile':()=>player.projCount=Math.min(player.projCount+1,6),
    '+25% Damage':()=>player.projDmg=Math.round(player.projDmg*1.25),
    '+20% Fire Rate':()=>player.projCooldown=Math.max(0.18, player.projCooldown*0.8),
    '+15% Move Speed':()=>player.speed=Math.round(player.speed*1.15),
    '+50 Pickup Radius':()=>player.pickup+=50,
    'Dash Quicker':()=>player.dashCD=Math.max(0.8, player.dashCD===0?2.5:player.dashCD*0.85),
  };
  const key = Object.keys(map).find(k=>label.includes(k));
  if (key) map[key]!();
  LVLUP.style.display='none'; showingChoices=false;
}

let last=performance.now();
function loop(now:number){
  const dt = Math.min(0.033,(now-last)/1000); last=now;
  if (running && !showingChoices) update(dt);
  render();
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);

function update(dt:number){
  time += dt;

  // input
  const dir={x:(+!!keys['d'])-(+!!keys['a']), y:(+!!keys['s'])-(+!!keys['w'])};
  const n = len(dir); const d = n? mul(norm(dir), player.speed*(keys[' ']&&player.dash<=0?2.4:1)) : {x:0,y:0};
  if (keys[' '] && player.dash<=0){ player.dash=0.18; if(player.dashCD>0) player.dashCD+=1.2; }
  player.v = d;
  player.p = add(player.p, mul(player.v, dt + (player.dash>0?dt*0.8:0)));
  player.p.x = clamp(player.p.x, 20, W-20); player.p.y = clamp(player.p.y, 20, H-20);
  if (player.dash>0) player.dash-=dt; if (player.dashCD>0) player.dashCD-=dt;

  if (keys['p']) running=false;
  if (!running && keys['p']) running=true;
  if (keys['l']) { glowOn = !glowOn; keys['l']=false; }

  // spawn & move enemies
  spawnEnemy(dt);
  for (let e of enemies){
    const toP = norm(sub(player.p,e.p));
    e.v = add(e.v, mul(toP, 20*dt)); // slight home-in
    e.p = add(e.p, mul(e.v, dt));
  }

  // auto-cast
  player.projTimer -= dt;
  if (player.projTimer<=0){ player.projTimer = player.projCooldown; castSpell(); }

  // projectiles
  for (let p of projs){ p.p=add(p.p, mul(p.v, dt)); p.life-=dt; }

  // collisions: proj vs enemy
  for (let p of projs){
    for (let e of enemies){
      if (dist(p.p,e.p) < p.r+e.r){
        e.hp -= p.dmg; p.life=0;
        if (e.hp<=0){ kills++; dropOrbs(e); e.hp=0; e.r=0; }
        break;
      }
    }
  }
  // clean
  for (let i=enemies.length-1;i>=0;i--) if (enemies[i].hp<=0) enemies.splice(i,1);
  for (let i=projs.length-1;i>=0;i--) if (projs[i].life<=0) projs.splice(i,1);

  // orbs physics + magnet
  for (let o of orbs){
    o.v = mul(o.v, 0.985);
    if (dist(o.p,player.p)<player.pickup){
      const dir = norm(sub(player.p,o.p));
      o.v = add(o.v, mul(dir, 280*dt));
    }
    o.p = add(o.p, mul(o.v, dt));
  }
  // pickup
  for (let i=orbs.length-1;i>=0;i--){
    const o=orbs[i];
    if (dist(o.p,player.p) < player.r+o.r){
      xp += o.xp; orbs.splice(i,1);
      if (xp>=xpNext) levelUp();
    }
  }

  // HUD + XP bar
  HUD.textContent = `Lv ${level}  XP ${xp}/${xpNext}  Kills ${kills}  Time ${time.toFixed(1)}s  Proj ${player.projCount}  DMG ${player.projDmg}`;
  (XPBAR as any).style.width = `${clamp((xp/xpNext)*100,0,100)}%`;
}

function render(){
  const ctx=CTX; const dpr=DPR;
  ctx.save(); ctx.scale(dpr,dpr);
  // background grid
  ctx.fillStyle = '#0b0b10'; ctx.fillRect(0,0,W,H);
  ctx.globalAlpha=0.08; ctx.strokeStyle='#224'; ctx.lineWidth=1;
  const step=32; for(let x=0;x<W;x+=step){ ctx.beginPath(); ctx.moveTo(x+0.5,0); ctx.lineTo(x+0.5,H); ctx.stroke(); }
  for(let y=0;y<H;y+=step){ ctx.beginPath(); ctx.moveTo(0,y+0.5); ctx.lineTo(W,y+0.5); ctx.stroke(); }
  ctx.globalAlpha=1;

  // trails
  if (glowOn){ ctx.globalCompositeOperation='lighter'; }

  // orbs
  for (let o of orbs){
    ctx.beginPath(); ctx.fillStyle='#6cf'; ctx.arc(o.p.x,o.p.y,o.r,0,Math.PI*2); ctx.fill();
  }

  // enemies
  for (let e of enemies){
    const hpAlpha = clamp(e.hp/e.maxhp,0,1);
    ctx.beginPath();
    ctx.fillStyle = `hsl(${220-180*hpAlpha},80%,${40+20*hpAlpha}%)`;
    ctx.arc(e.p.x,e.p.y,e.r,0,Math.PI*2); ctx.fill();
    if (glowOn){ ctx.shadowBlur=12; ctx.shadowColor='#f36'; }
    ctx.shadowBlur=0;
  }

  // projectiles
  ctx.lineWidth=2;
  for (let p of projs){
    ctx.beginPath(); ctx.strokeStyle='#9ff';
    ctx.moveTo(p.p.x - p.v.x*0.02, p.p.y - p.v.y*0.02);
    ctx.lineTo(p.p.x, p.p.y); ctx.stroke();
  }

  // player
  ctx.beginPath(); ctx.fillStyle='#fff';
  ctx.arc(player.p.x, player.p.y, player.r, 0, Math.PI*2); ctx.fill();
  if (glowOn){ ctx.shadowBlur=20; ctx.shadowColor='#9cf'; }
  ctx.shadowBlur=0;

  // pickup ring
  ctx.beginPath(); ctx.strokeStyle='#355'; ctx.setLineDash([6,6]); ctx.arc(player.p.x, player.p.y, player.pickup, 0, Math.PI*2); ctx.stroke(); ctx.setLineDash([]);

  ctx.restore();
}
TS

# --- package.json: helpful scripts
node - <<'NODE'
const fs=require('fs'); const p=JSON.parse(fs.readFileSync('package.json','utf8'));
p.scripts = Object.assign({}, p.scripts, {
  dev: "vite",
  build: "vite build",
  preview: "vite preview"
});
fs.writeFileSync('package.json', JSON.stringify(p,null,2));
console.log('package.json updated');
NODE

log "START — npm run dev (Ctrl+C to stop)"
npm run dev
