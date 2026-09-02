# #!/usr/bin/env bash
# set -e
# mkdir -p apex-humanoid/src/{config,state,render,audio,vision,ui} apex-humanoid/server apex-humanoid/public/reference
# cd apex-humanoid

# cat > package.json <<'EOF_PKG'
# {
#   "name": "apex-humanoid", "private": true, "version": "1.1.0", "type": "module",
#   "scripts": { "dev": "vite", "build": "vite build", "preview": "vite preview", "tts": "node server/tts.mjs" },
#   "dependencies": {
#     "@mediapipe/tasks-vision": "^0.10.14", "gsap": "^3.12.5", "lil-gui": "^0.19.2",
#     "react": "^18.3.1", "react-dom": "^18.3.1", "three": "^0.164.1"
#   },
#   "devDependencies": {
#     "@types/react": "^18.3.3", "@types/react-dom": "^18.3.0", "@types/three": "^0.164.0",
#     "@vitejs/plugin-react": "^4.3.1", "typescript": "^5.5.4", "vite": "^5.4.2"
#   }
# }
# EOF_PKG

# cat > vite.config.ts <<'EOF_VITE'
# import { defineConfig } from 'vite';
# import react from '@vitejs/plugin-react';
# export default defineConfig({ plugins: [react()], server: { proxy: { '/api': 'http://localhost:8787' } } });
# EOF_VITE

# cat > tsconfig.json <<'EOF_TS'
# { "compilerOptions": { "target":"ES2020","module":"ESNext","moduleResolution":"bundler","jsx":"react-jsx",
#   "strict":false,"skipLibCheck":true,"esModuleInterop":true,"allowSyntheticDefaultImports":true,"noEmit":true,
#   "lib":["ES2020","DOM","DOM.Iterable"] }, "include":["src"] }
# EOF_TS

# cat > index.html <<'EOF_HTML'
# <!doctype html><html lang="en"><head><meta charset="UTF-8"/>
# <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover"/>
# <title>APEX — Humanoid Interface</title>
# <style>html,body{margin:0;height:100%;background:#020409;overflow:hidden}</style></head>
# <body><div id="root"></div><script type="module" src="/src/main.tsx"></script></body></html>
# EOF_HTML

# cat > src/main.tsx <<'EOF_MAIN'
# import { createRoot } from 'react-dom/client';
# import App from './ui/App';
# import './styles.css';
# createRoot(document.getElementById('root')!).render(<App />);
# EOF_MAIN

# cat > src/config/visualConfig.ts <<'EOF_CFG'
# export const VISUAL_CONFIG = {
#   background:'#020409', cyan:'#3ec9ff', blue:'#1e7dff', deepBlue:'#0a2f66',
#   orange:'#ff8c2e', amber:'#ffc46b', whiteEnergy:'#eaffff',
#   bloomStrength:0.85, bloomRadius:0.55, bloomThreshold:0.12,
#   particleBrightness:1.15, lineBrightness:1.0, particleDensity:1.0, particleSize:1.0,
#   noiseStrength:0.55, distortionStrength:0.35, faceEnergy:1.0, chestEnergy:1.0,
#   fieldAmplitude:1.0, ringIntensity:0.5, cyanIntensity:1.0, orangeIntensity:1.0
# };
# export const MOTION_CONFIG = {
#   entry:{ core:0.7, swirl:1.5, head:2.4, torso:2.2, face:1.2, field:1.8, rings:1.6, halo:1.6 },
#   idle:{ breathingSpeed:0.55, breathingAmount:0.5, particleDrift:0.4, energyPulse:0.5, headSway:0.12 },
#   speech:{ faceResponse:1.0, chestResponse:0.85, particleResponse:0.6, glowResponse:0.7, headNod:0.22 },
#   gesture:{ influenceRadius:1.5, strength:0.5, smoothing:0.14, returnSpeed:0.06, pinchStrength:0.85 },
#   camera:{ parallaxStrength:0.32, rotationStrength:0.1 }
# };
# export type Quality='HIGH'|'MEDIUM'|'LOW';
# export function detectQuality():Quality{
#   const mobile=/Android|iPhone|iPad|Mobile/i.test(navigator.userAgent);
#   const cores=navigator.hardwareConcurrency||4; const mem=(navigator as any).deviceMemory||8;
#   if(mobile||cores<=4||mem<=4) return mobile?'LOW':'MEDIUM';
#   if(cores<=6||mem<=8) return 'MEDIUM'; return 'HIGH';
# }
# export const QUALITY_PRESETS={ HIGH:{density:1,prCap:2,bloom:true}, MEDIUM:{density:0.6,prCap:1.75,bloom:true}, LOW:{density:0.35,prCap:1.25,bloom:false} } as const;
# EOF_CFG

# cat > src/state/store.ts <<'EOF_STORE'
# export type AppState='BOOT'|'FORMING'|'IDLE'|'LISTENING'|'THINKING'|'SPEAKING'|'GESTURE_REACTION'|'ERROR';
# type Snapshot={ state:AppState; assembly:number; audioLevel:number; handStatus:'off'|'loading'|'on'|'denied';
#   gesture:string; micSupported:boolean; fps:number; particles:number; renderer:string; errorMsg:string; caption:string };
# class Store{
#   private snap:Snapshot={ state:'BOOT',assembly:0,audioLevel:0,handStatus:'off',gesture:'none',
#     micSupported:typeof window!=='undefined'&&!!((window as any).SpeechRecognition||(window as any).webkitSpeechRecognition),
#     fps:0,particles:0,renderer:'-',errorMsg:'',caption:'' };
#   private listeners=new Set<()=>void>();
#   get=()=>this.snap;
#   set(p:Partial<Snapshot>){ this.snap={...this.snap,...p}; this.listeners.forEach(l=>l()); }
#   subscribe=(l:()=>void)=>{ this.listeners.add(l); return ()=>{ this.listeners.delete(l); }; };
# }
# export const store=new Store();
# export const STATUS_TEXT:Record<AppState,string>={ BOOT:'STATUS: BOOT',FORMING:'ASSEMBLING',IDLE:'STATUS: OPERATING',
#   LISTENING:'STATUS: LISTENING',THINKING:'STATUS: PROCESSING',SPEAKING:'STATUS: SPEECH SYNTHESIS',
#   GESTURE_REACTION:'STATUS: OPERATING',ERROR:'STATUS: FAULT' };
# EOF_STORE

# cat > src/render/shaders.ts <<'EOF_SH'
# export const NOISE=/* glsl */`
# float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1,311.7)))*43758.5453123); }
# float hash1(float n){ return fract(sin(n)*43758.5453123); }
# float vnoise(vec2 p){ vec2 i=floor(p), f=fract(p); vec2 u=f*f*(3.0-2.0*f);
#   return mix(mix(hash(i),hash(i+vec2(1,0)),u.x), mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),u.x), u.y); }
# float fbm(vec2 p){ float v=0.0,a=0.5; for(int i=0;i<4;i++){ v+=a*vnoise(p); p*=2.03; a*=0.5; } return v; }
# float ridge(vec2 p){ float v=0.0,a=0.5; for(int i=0;i<4;i++){ v+=a*(1.0-abs(2.0*vnoise(p)-1.0)); p*=2.11; a*=0.5; } return v*0.5; }
# `;
# export const PARTICLE_VERT=/* glsl */`
# uniform float uTime,uPR,uSize,uHead,uTorso,uHalo,uAudio,uBass,uSpeech,uHandA,uPinch,uRadius,uStrength;
# uniform float uReduce,uBreathAmp,uBreathSpeed,uDrift,uPulse;
# uniform vec3 uHand; uniform vec2 uSwipe;
# attribute vec3 aScatter; attribute float aSeed,aRegion,aTint,aSize;
# varying float vTint; varying float vAlpha; varying float vGlow;
# float sstep(float a,float b,float x){ return smoothstep(a,b,x); }
# void main(){
#   float seed=aSeed; float f=1.0;
#   if(aRegion<0.5)      f=sstep(seed*0.45, seed*0.45+0.45, uHead);
#   else if(aRegion<1.5) f=sstep(0.10+seed*0.35, 0.55+seed*0.35, uHead);
#   else if(aRegion<2.5) f=sstep(seed*0.5, seed*0.5+0.5, uHalo);
#   else if(aRegion<3.5) f=sstep(seed*0.55, seed*0.55+0.45, uTorso);
#   else if(aRegion<4.5) f=sstep(0.25+seed*0.4, 0.75+seed*0.4, uTorso);
#   else f=0.9;
#   float fe=f*f*(3.0-2.0*f);
#   vec3 target=position;
#   float br=sin(uTime*uBreathSpeed+target.y*1.4)*uBreathAmp*(1.0-uReduce*0.6);
#   target.y+=br*0.025; target.x*=1.0+br*0.01;
#   float amp=(aRegion<2.5?0.012:0.02)*uDrift*(1.0+uSpeech*1.6)*(1.0-uReduce*0.7);
#   target.x+=sin(uTime*0.7+seed*17.0)*amp;
#   target.y+=cos(uTime*0.6+seed*23.0)*amp;
#   target.z+=sin(uTime*0.5+seed*29.0)*amp*2.0;
#   if(aRegion>1.5&&aRegion<2.5){ target.y+=fract(seed+uTime*0.06)*0.55; }
#   if((aRegion>0.5&&aRegion<1.5)||aRegion>2.5){
#     float p=fract(seed*7.31+uTime*0.05);
#     if(p>0.94) target+=normalize(vec3(target.x,1.0,0.0))*(p-0.94)*1.6;
#   }
#   vec3 pos=mix(aScatter,target,fe);
#   vec2 d=pos.xy-uHand.xy; float dist=length(d)+1e-4;
#   float infl=exp(-dist*dist/(uRadius*uRadius))*uHandA;
#   float mode=mix(1.0,-0.75,uPinch);
#   pos.xy+=(d/dist)*infl*uStrength*mode;
#   pos.xy+=uSwipe*(0.25+0.75*infl);
#   float tw=0.72+0.28*sin(uTime*(1.0+seed*2.0)+seed*40.0);
#   vAlpha=fe*tw*(aRegion>4.5?0.4:1.0)*(1.0+uAudio*0.55*(aRegion<2.5?1.0:0.4));
#   vGlow=0.0;
#   if(aRegion>3.5&&aRegion<4.5){
#     float ph=fract(uTime*0.35);
#     vGlow+=smoothstep(0.18,0.0,abs(seed-ph))*0.9+uBass*0.8+uPulse*0.6;
#   }
#   vGlow+=uPulse*0.4; vTint=aTint;
#   vec4 mv=modelViewMatrix*vec4(pos,1.0);
#   float sz=aSize*uSize*uPR*(1.0+uAudio*0.5*(aRegion<2.5?1.0:0.3)+vGlow*0.4);
#   gl_PointSize=sz*(150.0/-mv.z);
#   gl_Position=projectionMatrix*mv;
# }`;
# export const PARTICLE_FRAG=/* glsl */`
# uniform vec3 uCyan,uGold,uWhite; uniform float uBright;
# varying float vTint; varying float vAlpha; varying float vGlow;
# void main(){
#   vec2 p=gl_PointCoord-0.5; float d=length(p)*2.0;
#   float a=smoothstep(1.0,0.0,d); a*=a;
#   vec3 col=mix(uCyan,uGold,vTint);
#   col=mix(col,uWhite,clamp(pow(a,3.0)*0.75+vGlow*0.6,0.0,1.0));
#   float i=a*vAlpha*uBright;
#   gl_FragColor=vec4(col*i,i);
# }`;
# export const SWIRL_VERT=/* glsl */`
# uniform float uTime,uPR,uSwirl,uCore;
# attribute float aT,aSeed; varying float vA;
# void main(){
#   float head=uSwirl;
#   float on=smoothstep(aT,aT+0.04,head);
#   float trail=exp(-(head-aT)*2.6);
#   float coreGlow=exp(-abs(aT-head)*34.0)*2.2+uCore*exp(-aT*9.0);
#   vA=on*trail+coreGlow;
#   vec3 pos=position;
#   pos.xy+=vec2(sin(uTime*3.0+aSeed*40.0),cos(uTime*2.6+aSeed*37.0))*0.015;
#   vec4 mv=modelViewMatrix*vec4(pos,1.0);
#   gl_PointSize=(1.2+coreGlow*2.4)*uPR*(150.0/-mv.z);
#   gl_Position=projectionMatrix*mv;
# }`;
# export const SWIRL_FRAG=/* glsl */`
# uniform vec3 uCyan,uWhite; varying float vA;
# void main(){
#   vec2 p=gl_PointCoord-0.5; float d=length(p)*2.0;
#   float a=smoothstep(1.0,0.0,d); a*=a;
#   vec3 col=mix(uCyan,uWhite,a*0.7);
#   float i=a*vA; gl_FragColor=vec4(col*i,i);
# }`;
# export const QUAD_VERT=/* glsl */`
# varying vec2 vUv;
# void main(){ vUv=uv; gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0); }`;
# export const FACE_FRAG=NOISE+/* glsl */`
# uniform float uTime,uAudio,uMid,uFace,uFaceE,uNoise,uOrangeI;
# uniform vec3 uOrange,uAmber,uCyan; varying vec2 vUv;
# void main(){
#   vec2 uv=vUv*2.0-1.0; uv.x*=0.88;
#   float e=length(uv);
#   float mask=smoothstep(1.0,0.72,e);
#   float n=fbm(vec2(uv.x*3.0,uv.y*5.0)+vec2(0.0,uTime*0.35))*uNoise;
#   float amp=0.45+uAudio*1.35+uMid*0.6;
#   float wave=sin(uv.y*(20.0+uMid*8.0)+uv.x*2.2+n*5.0+uTime*1.3);
#   float ridges=pow(clamp(0.5+0.5*wave,0.0,1.0),2.6)*amp;
#   float core=exp(-pow(e*1.55,2.0));
#   float flick=0.82+0.18*sin(uTime*2.1)+uAudio*0.7;
#   float i=(core*0.85+ridges*mask*1.25)*uFace*flick*uFaceE;
#   vec3 col=mix(uOrange,uAmber,clamp(ridges,0.0,1.0));
#   col=mix(col,uCyan,smoothstep(0.72,1.0,e)*0.8);
#   i*=uOrangeI;
#   gl_FragColor=vec4(col*i,i);
# }`;
# export const CHEST_FRAG=NOISE+/* glsl */`
# uniform float uTime,uBass,uCore,uChest,uPulse;
# uniform vec3 uCyan,uWhite; varying vec2 vUv;
# void main(){
#   vec2 uv=vUv*2.0-1.0;
#   float pulse=0.75+0.25*sin(uTime*1.15)+uBass*0.9+uPulse*0.8;
#   float d=length(uv);
#   float core=exp(-d*4.5)*pulse;
#   float flare=exp(-abs(uv.x)*7.0)*exp(-max(uv.y,0.0)*2.2)*0.7;
#   float spark=fbm(uv*6.0+uTime*0.6)*0.25;
#   float i=(core+flare+spark*core)*uCore*uChest;
#   vec3 col=mix(uCyan,uWhite,clamp(core,0.0,1.0));
#   gl_FragColor=vec4(col*i,i);
# }`;
# export const FIELD_FRAG=NOISE+/* glsl */`
# uniform float uTime,uField,uFieldAmp,uAudio,uCyanI;
# uniform float uMirror;
# uniform vec3 uCyan,uDeep,uGold; varying vec2 vUv;
# void main(){
#   float x=mix(vUv.x,1.0-vUv.x,uMirror);
#   float y=vUv.y;
#   float h=ridge(vec2(x*2.4,1.7))*0.72*uFieldAmp+0.62-x*0.28;
#   h+=sin(uTime*0.12+x*3.0)*0.015;
#   float m=smoothstep(h+0.02,h-0.14,y);
#   float crest=smoothstep(0.06,0.0,abs(y-h));
#   vec2 g=vUv*vec2(170.0,120.0);
#   vec2 id=floor(g); vec2 f=fract(g)-0.5;
#   float rnd=hash(id);
#   vec2 off=vec2(hash(id+3.1),hash(id+7.7))*0.7-0.35;
#   float spark=smoothstep(0.3,0.0,length(f-off))*step(0.3,rnd)*(0.4+0.6*sin(uTime*(0.8+rnd*2.0)+rnd*44.0));
#   float strata=pow(0.5+0.5*sin(y*46.0+fbm(vec2(x*4.0,y*3.0)+uTime*0.05)*6.0),6.0)*0.5;
#   float vein=smoothstep(0.035,0.0,abs(fbm(vUv*4.5+vec2(uTime*0.02,0.0))-0.52))*m;
#   float edge=smoothstep(0.0,0.12,x)*smoothstep(1.0,0.85,x);
#   float i=(crest*1.6+spark*m*0.9+strata*m+uAudio*0.25*m)*uField*edge*uCyanI;
#   vec3 col=uCyan*(crest+spark*m*0.8+strata*m*0.6)+uDeep*m*0.35+uGold*vein*1.4*uField*edge;
#   gl_FragColor=vec4(col*i+col*0.06*m*uField,clamp(i+vein*uField*m,0.0,1.0));
# }`;
# export const RINGS_FRAG=/* glsl */`
# uniform float uTime,uRings,uRingI,uPulse;
# uniform vec3 uCyan; varying vec2 vUv;
# void main(){
#   vec2 uv=vUv*2.0-1.0; float r=length(uv);
#   float rings=pow(0.5+0.5*sin(r*34.0-uTime*0.5),10.0);
#   float ann=smoothstep(0.25,0.4,r)*smoothstep(1.0,0.75,r);
#   float pulse=exp(-abs(r-fract(uTime*0.22)*1.1)*14.0)*0.6+uPulse*exp(-abs(r-0.5)*8.0);
#   float i=(rings*ann*0.5+pulse*ann)*uRings*uRingI;
#   gl_FragColor=vec4(uCyan*i,i);
# }`;
# export const POST_FRAG=/* glsl */`
# uniform sampler2D tDiffuse; uniform float uTime,uVignette;
# varying vec2 vUv;
# float h(vec2 p){ return fract(sin(dot(p,vec2(12.9898,78.233)))*43758.5453); }
# void main(){
#   vec2 uv=vUv; vec2 c=uv-0.5;
#   float ca=dot(c,c)*0.0016;
#   vec3 col;
#   col.r=texture2D(tDiffuse,uv+c*ca).r;
#   col.g=texture2D(tDiffuse,uv).g;
#   col.b=texture2D(tDiffuse,uv-c*ca).b;
#   float v=smoothstep(0.95,0.35,length(c)*1.15);
#   col*=mix(1.0,v,uVignette);
#   col+=(h(uv*vec2(1613.0,1471.0)+uTime)-0.5)*0.015;
#   gl_FragColor=vec4(col,1.0);
# }`;
# EOF_SH

# cat > src/render/geometry.ts <<'EOF_GEO'
# import * as THREE from 'three';
# const rnd=(a=1,b?:number)=>b===undefined?Math.random()*a:a+Math.random()*(b-a);
# export function buildHumanoid(density:number){
#   const P:number[]=[],S:number[]=[],SEED:number[]=[],REG:number[]=[],TINT:number[]=[],SIZE:number[]=[];
#   const push=(x:number,y:number,z:number,region:number,tint:number,size:number)=>{
#     P.push(x,y,z);
#     const t=Math.random();
#     const ax=-2.7,ay=-0.5,cx=0.9,cy=2.7,bx=0.0,by=0.6;
#     const ix=(1-t)*(1-t)*ax+2*(1-t)*t*cx+t*t*bx, iy=(1-t)*(1-t)*ay+2*(1-t)*t*cy+t*t*by;
#     S.push(ix+rnd(-1,1),iy+rnd(-1,1),rnd(-1.5,1.5));
#     SEED.push(Math.random()); REG.push(region); TINT.push(tint); SIZE.push(size);
#   };
#   const cy=1.62,rx=0.46,ry=0.62,RINGS=Math.round(42*density)+10;
#   for(let i=0;i<RINGS;i++){
#     const t=-0.78+(i/(RINGS-1))*1.76;
#     const y=cy+ry*t;
#     const half=rx*Math.sqrt(Math.max(0,1-t*t));
#     const curve=0.12*(0.25-t);
#     const N=Math.max(8,Math.round(half*150*density));
#     for(let j=0;j<N;j++){
#       const u=(j/(N-1))*2-1;
#       push(half*u,y-curve*(1-u*u),0.16*Math.sqrt(Math.max(0,1-u*u))+rnd(-0.01,0.01),0,0,rnd(0.7,1.3));
#     }
#   }
#   const RIM=Math.round(240*density);
#   for(let i=0;i<RIM;i++){
#     const a=(i/RIM)*Math.PI*2;
#     push(rx*Math.sin(a)*1.02,cy+ry*Math.cos(a)*1.02,rnd(-0.02,0.02),1,0,rnd(1.4,2.1));
#   }
#   const HALO=Math.round(420*density);
#   for(let i=0;i<HALO;i++){
#     const a=rnd(-1,1),h2=rnd(0,1);
#     push(a*rx*(0.5+h2*0.9),cy+ry*(0.72+h2*0.62),rnd(-0.1,0.1),2,0,rnd(0.5,1.1));
#   }
#   const C=new THREE.Vector2(0,0.55);
#   const pts=[[0.14,1.22],[0.34,1.02],[0.78,0.78],[1.22,0.52],[1.5,0.18],[1.62,-0.35],[1.66,-0.98]]
#     .map(p=>new THREE.Vector3(p[0],p[1],0));
#   const curve2=new THREE.CatmullRomCurve3(pts);
#   const L=Math.round(22*density)+6;
#   for(let l=0;l<L;l++){
#     const q=0.28+(l/(L-1))*0.72;
#     const N=Math.round((30+70*q)*density);
#     for(let j=0;j<N;j++){
#       const p=curve2.getPoint(j/(N-1));
#       const x=C.x+(p.x-C.x)*q, y=C.y+(p.y-C.y)*q;
#       push(x,y,rnd(-0.05,0.05),3,0,rnd(0.6,1.2)*(0.5+q*0.6));
#       push(-x,y,rnd(-0.05,0.05),3,0,rnd(0.6,1.2)*(0.5+q*0.6));
#     }
#   }
#   const strands=[[0.10,0.20,0.12,0.02],[0.16,0.26,0.16,0.05],[0.05,0.12,0.07,0.0]];
#   for(const s of strands) for(const side of [1,-1]){
#     const c=new THREE.CatmullRomCurve3([
#       new THREE.Vector3(side*s[0],1.24,0),new THREE.Vector3(side*s[1],0.98,0),
#       new THREE.Vector3(side*s[2],0.78,0),new THREE.Vector3(side*s[3],0.60,0)]);
#     const N=Math.round(60*density);
#     for(let j=0;j<N;j++){ const p=c.getPoint(j/(N-1)); push(p.x,p.y,p.z,4,1,rnd(0.8,1.4)); }
#   }
#   const DUST=Math.round(450*density);
#   for(let i=0;i<DUST;i++) push(rnd(-5,5),rnd(-1.1,3.1),rnd(-2,0.8),5,0,rnd(0.4,0.9));
#   const g=new THREE.BufferGeometry();
#   g.setAttribute('position',new THREE.Float32BufferAttribute(P,3));
#   g.setAttribute('aScatter',new THREE.Float32BufferAttribute(S,3));
#   g.setAttribute('aSeed',new THREE.Float32BufferAttribute(SEED,1));
#   g.setAttribute('aRegion',new THREE.Float32BufferAttribute(REG,1));
#   g.setAttribute('aTint',new THREE.Float32BufferAttribute(TINT,1));
#   g.setAttribute('aSize',new THREE.Float32BufferAttribute(SIZE,1));
#   return { geometry:g, count:P.length/3 };
# }
# export function buildSwirl(density:number){
#   const N=Math.round(520*density);
#   const P:number[]=[],T:number[]=[],SEED:number[]=[];
#   const ax=-2.7,ay=-0.5,cx=0.9,cy=2.7,bx=0.0,by=0.6;
#   for(let i=0;i<N;i++){
#     const t=i/(N-1);
#     const x=(1-t)*(1-t)*ax+2*(1-t)*t*cx+t*t*bx, y=(1-t)*(1-t)*ay+2*(1-t)*t*cy+t*t*by;
#     P.push(x+rnd(-0.12,0.12),y+rnd(-0.12,0.12),rnd(-0.2,0.2)); T.push(t); SEED.push(Math.random());
#   }
#   const g=new THREE.BufferGeometry();
#   g.setAttribute('position',new THREE.Float32BufferAttribute(P,3));
#   g.setAttribute('aT',new THREE.Float32BufferAttribute(T,1));
#   g.setAttribute('aSeed',new THREE.Float32BufferAttribute(SEED,1));
#   return g;
# }
# EOF_GEO

# cat > src/audio/AudioEngine.ts <<'EOF_AUD'
# export class AudioEngine {
#   ctx:AudioContext|null=null; analyser:AnalyserNode|null=null;
#   private data:Uint8Array|null=null;
#   private env={level:0,bass:0,mid:0,high:0};
#   private smooth={level:0,bass:0,mid:0,high:0};
#   private synthActive=false; private lastBoundary=0; private wordEnergy=0;
#   muted=false;
#   ensure(){
#     if(!this.ctx){
#       this.ctx=new (window.AudioContext||(window as any).webkitAudioContext)();
#       this.analyser=this.ctx.createAnalyser();
#       this.analyser.fftSize=512; this.analyser.smoothingTimeConstant=0.55;
#       this.data=new Uint8Array(this.analyser.frequencyBinCount);
#       this.analyser.connect(this.ctx.destination);
#     }
#     if(this.ctx.state==='suspended') this.ctx.resume();
#   }
#   async playBuffer(buf:ArrayBuffer):Promise<void>{
#     this.ensure();
#     const audio=await this.ctx!.decodeAudioData(buf);
#     return new Promise(res=>{
#       const src=this.ctx!.createBufferSource(); src.buffer=audio;
#       const gain=this.ctx!.createGain(); gain.gain.value=this.muted?0:1;
#       src.connect(gain); gain.connect(this.analyser!);
#       src.onended=()=>res(); src.start();
#     });
#   }
#   synthStart(){ this.synthActive=true; }
#   synthBoundary(word:string){ this.lastBoundary=performance.now(); this.wordEnergy=Math.min(1,0.35+word.length*0.06); }
#   synthEnd(){ this.synthActive=false; this.wordEnergy=0; }
#   update(dt:number){
#     const target=this.env;
#     if(this.analyser&&this.ctx&&this.ctx.state==='running'){
#       this.analyser.getByteFrequencyData(this.data!);
#       const d=this.data!; let b=0,m=0,h=0;
#       for(let i=1;i<10;i++)b+=d[i];  b/=9*255;
#       for(let i=10;i<60;i++)m+=d[i]; m/=50*255;
#       for(let i=60;i<160;i++)h+=d[i];h/=100*255;
#       target.level=Math.min(1,(b+m+h)*1.4); target.bass=b; target.mid=m; target.high=h;
#     } else if(this.synthActive){
#       const since=performance.now()-this.lastBoundary;
#       const decay=Math.exp(-since/160);
#       const vib=0.75+0.25*Math.sin(performance.now()/46);
#       target.level=this.wordEnergy*decay*vib;
#       target.bass=target.level*0.8; target.mid=target.level; target.high=target.level*0.55;
#     } else { target.level=target.bass=target.mid=target.high=0; }
#     const k=(cur:number,tgt:number)=>cur+(tgt-cur)*(1-Math.exp(-dt*(tgt>cur?28:9)));
#     this.smooth.level=k(this.smooth.level,target.level);
#     this.smooth.bass=k(this.smooth.bass,target.bass);
#     this.smooth.mid=k(this.smooth.mid,target.mid);
#     this.smooth.high=k(this.smooth.high,target.high);
#   }
#   get levels(){ return this.smooth; }
# }
# EOF_AUD

# cat > src/audio/TTSService.ts <<'EOF_TTS'
# import { AudioEngine } from './AudioEngine';
# export class TTSService {
#   private endpoint:string|null=null;
#   constructor(private engine:AudioEngine){}
#   async init(){
#     try{
#       const ctl=new AbortController(); const t=setTimeout(()=>ctl.abort(),900);
#       const r=await fetch('/api/health',{signal:ctl.signal}); clearTimeout(t);
#       if(r.ok) this.endpoint='/api/tts';
#     }catch{ this.endpoint=null; }
#   }
#   get mode(){ return this.endpoint?'edge-tts':'browser-synth'; }
#   async speak(text:string, hooks:{onStart?:()=>void; onEnd?:()=>void}={}):Promise<void>{
#     if(this.endpoint){
#       try{
#         const r=await fetch(this.endpoint,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({text})});
#         if(r.ok){
#           const buf=await r.arrayBuffer();
#           hooks.onStart?.();
#           await this.engine.playBuffer(buf);
#           hooks.onEnd?.(); return;
#         }
#       }catch{ /* fall through */ }
#     }
#     await this.speakBrowser(text,hooks);
#   }
#   private speakBrowser(text:string, hooks:{onStart?:()=>void; onEnd?:()=>void}){
#     return new Promise<void>(res=>{
#       if(!('speechSynthesis' in window)){ hooks.onEnd?.(); res(); return; }
#       const u=new SpeechSynthesisUtterance(text);
#       u.rate=1; u.pitch=0.9;
#       const voices=speechSynthesis.getVoices();
#       const v=voices.find(v=>/en-US/.test(v.lang)&&/Neural|Natural|Google/i.test(v.name))||voices.find(v=>/en/.test(v.lang));
#       if(v) u.voice=v;
#       u.onstart=()=>{ this.engine.synthStart(); hooks.onStart?.(); };
#       u.onboundary=e=>this.engine.synthBoundary(text.slice(e.charIndex).split(/\s+/)[0]||'');
#       u.onend=u.onerror=()=>{ this.engine.synthEnd(); hooks.onEnd?.(); res(); };
#       speechSynthesis.speak(u);
#     });
#   }
# }
# EOF_TTS

# cat > src/vision/HandTracker.ts <<'EOF_HAND'
# import { FilesetResolver, HandLandmarker } from '@mediapipe/tasks-vision';
# export type HandFrame={ present:boolean; x:number; y:number; pinch:number; open:number; point:number; gesture:string; vx:number; vy:number };
# export class HandTracker {
#   private landmarker:HandLandmarker|null=null;
#   private video:HTMLVideoElement|null=null;
#   private raf=0; private running=false; private lastVideoTime=-1; private lastT=0;
#   private sm={x:0.5,y:0.5};
#   onFrame:(f:HandFrame)=>void=()=>{};
#   onStatus:(s:'loading'|'on'|'denied')=>void=()=>{};
#   async start(){
#     this.onStatus('loading');
#     try{
#       const stream=await navigator.mediaDevices.getUserMedia({video:{width:320,height:240,facingMode:'user'}});
#       const video=document.createElement('video');
#       video.muted=true; video.playsInline=true; video.srcObject=stream; await video.play();
#       this.video=video;
#       const fileset=await FilesetResolver.forVisionTasks('https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm');
#       this.landmarker=await HandLandmarker.createFromOptions(fileset,{
#         baseOptions:{modelAssetPath:'https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task',delegate:'GPU'},
#         runningMode:'VIDEO',numHands:1});
#       this.running=true; this.onStatus('on'); this.loop();
#     }catch{ this.onStatus('denied'); }
#   }
#   private loop=()=>{
#     if(!this.running) return;
#     this.raf=requestAnimationFrame(this.loop);
#     const v=this.video!; if(v.currentTime===this.lastVideoTime) return;
#     this.lastVideoTime=v.currentTime;
#     const res=this.landmarker!.detectForVideo(v,performance.now());
#     if(res.landmarks&&res.landmarks.length){
#       const lm=res.landmarks[0];
#       const palm=lm[9];
#       const scale=Math.hypot(lm[0].x-lm[9].x,lm[0].y-lm[9].y)+1e-4;
#       const pinchD=Math.hypot(lm[4].x-lm[8].x,lm[4].y-lm[8].y)/scale;
#       const ext=(a:number,b:number)=>lm[a].y<lm[b].y?1:0;
#       const fingers=ext(8,6)+ext(12,10)+ext(16,14)+ext(20,18);
#       const open=fingers>=3?1:0;
#       const point=(fingers===1&&ext(8,6)===1)?1:0;
#       const pinch=Math.max(0,Math.min(1,1.6-pinchD));
#       const px=this.sm.x, py=this.sm.y;
#       this.sm.x+=((1-palm.x)-this.sm.x)*0.35; this.sm.y+=((1-palm.y)-this.sm.y)*0.35;
#       const now=performance.now(); const dtm=Math.max(8,now-this.lastT); this.lastT=now;
#       const vx=(this.sm.x-px)/(dtm/1000), vy=(this.sm.y-py)/(dtm/1000);
#       const gesture=pinch>0.75?'pinch':open?'open':point?'point':'fist';
#       this.onFrame({present:true,x:this.sm.x,y:this.sm.y,pinch,open,point,gesture,vx,vy});
#     } else this.onFrame({present:false,x:this.sm.x,y:this.sm.y,pinch:0,open:0,point:0,gesture:'none',vx:0,vy:0});
#   };
#   stop(){
#     this.running=false; cancelAnimationFrame(this.raf);
#     (this.video?.srcObject as MediaStream)?.getTracks().forEach(t=>t.stop());
#     this.landmarker?.close(); this.landmarker=null; this.video=null;
#   }
# }
# EOF_HAND

# cat > src/render/Experience.ts <<'EOF_EXP'
# import * as THREE from 'three';
# import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
# import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
# import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
# import { ShaderPass } from 'three/addons/postprocessing/ShaderPass.js';
# import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';
# import gsap from 'gsap';
# import { VISUAL_CONFIG as V, MOTION_CONFIG as M, QUALITY_PRESETS, detectQuality } from '../config/visualConfig';
# import { PARTICLE_VERT,PARTICLE_FRAG,SWIRL_VERT,SWIRL_FRAG,QUAD_VERT,FACE_FRAG,CHEST_FRAG,FIELD_FRAG,RINGS_FRAG,POST_FRAG } from './shaders';
# import { buildHumanoid, buildSwirl } from './geometry';
# import { AudioEngine } from '../audio/AudioEngine';
# import { TTSService } from '../audio/TTSService';
# import { HandTracker } from '../vision/HandTracker';
# import { store } from '../state/store';

# export class Experience {
#   renderer!:THREE.WebGLRenderer; scene=new THREE.Scene(); camera!:THREE.PerspectiveCamera;
#   composer!:EffectComposer; bloom!:UnrealBloomPass;
#   U:Record<string,THREE.IUniform>={};
#   audio=new AudioEngine(); tts=new TTSService(this.audio); hands=new HandTracker();
#   private pointer={x:0,y:0,active:0};
#   private hand={present:false,pinch:0,a:0,vx:0,vy:0,gesture:'none'};
#   private swipe=new THREE.Vector2(); private swipeT=0; private pulse=0;
#   private clock=new THREE.Clock(); private t=0;
#   private quality=detectQuality(); private preset=QUALITY_PRESETS[this.quality];
#   private reduced=matchMedia('(prefers-reduced-motion: reduce)').matches;
#   private frames=0; private fpsT=0; private disposed=false;
#   private group=new THREE.Group();
#   private pointerWorld=new THREE.Vector3(99,99,0); private handWorld=new THREE.Vector3(99,99,0);

#   constructor(private canvas:HTMLCanvasElement){
#     try{ this.renderer=new THREE.WebGLRenderer({canvas,antialias:true,powerPreference:'high-performance'}); }
#     catch(e){ store.set({state:'ERROR',errorMsg:'WebGL unavailable on this device.'}); throw e; }
#     const gl=this.renderer.getContext();
#     store.set({renderer:gl.getParameter(gl.VERSION)});
#     this.renderer.setClearColor(new THREE.Color(V.background),1);
#     this.camera=new THREE.PerspectiveCamera(42,1,0.1,60);
#     this.camera.position.set(0,0.85,7.3);
#     const c=(hex:string)=>new THREE.Color(hex);
#     Object.assign(this.U,{
#       uTime:{value:0},uPR:{value:1},uSize:{value:1},uBright:{value:1},
#       uCyan:{value:c(V.cyan)},uGold:{value:c(V.amber)},uWhite:{value:c(V.whiteEnergy)},
#       uOrange:{value:c(V.orange)},uAmber:{value:c(V.amber)},uDeep:{value:c(V.deepBlue)},
#       uHead:{value:0},uTorso:{value:0},uHalo:{value:0},uField:{value:0},uRings:{value:0},
#       uFace:{value:0},uFaceE:{value:V.faceEnergy},uCore:{value:0},uSwirl:{value:0},
#       uAudio:{value:0},uBass:{value:0},uMid:{value:0},uHigh:{value:0},uSpeech:{value:0},
#       uHand:{value:new THREE.Vector3(99,99,0)},uHandA:{value:0},uPinch:{value:0},
#       uRadius:{value:M.gesture.influenceRadius},uStrength:{value:M.gesture.strength},
#       uSwipe:{value:new THREE.Vector2()},
#       uReduce:{value:this.reduced?1:0},uBreathAmp:{value:M.idle.breathingAmount},
#       uBreathSpeed:{value:M.idle.breathingSpeed},uDrift:{value:M.idle.particleDrift},
#       uNoise:{value:V.noiseStrength},uFieldAmp:{value:V.fieldAmplitude},uRingI:{value:V.ringIntensity},
#       uChest:{value:V.chestEnergy},uPulse:{value:0},uOrangeI:{value:V.orangeIntensity},uCyanI:{value:V.cyanIntensity}
#     });
#     this.scene.add(this.group);
#     const hum=buildHumanoid(V.particleDensity*this.preset.density);
#     const pMat=new THREE.ShaderMaterial({vertexShader:PARTICLE_VERT,fragmentShader:PARTICLE_FRAG,uniforms:this.U,
#       transparent:true,depthWrite:false,depthTest:false,blending:THREE.AdditiveBlending});
#     const points=new THREE.Points(hum.geometry,pMat); points.renderOrder=3; this.group.add(points);
#     const swirl=new THREE.Points(buildSwirl(this.preset.density),
#       new THREE.ShaderMaterial({vertexShader:SWIRL_VERT,fragmentShader:SWIRL_FRAG,uniforms:this.U,
#         transparent:true,depthWrite:false,depthTest:false,blending:THREE.AdditiveBlending}));
#     swirl.renderOrder=2; this.group.add(swirl);
#     const quad=(w:number,h:number,x:number,y:number,z:number,frag:string,order:number,mirror=0)=>{
#       const u={...this.U,uMirror:{value:mirror}};
#       const m=new THREE.Mesh(new THREE.PlaneGeometry(w,h),
#         new THREE.ShaderMaterial({vertexShader:QUAD_VERT,fragmentShader:frag,uniforms:u,
#           transparent:true,depthWrite:false,depthTest:false,blending:THREE.AdditiveBlending}));
#       m.position.set(x,y,z); m.renderOrder=order; this.group.add(m); return m;
#     };
#     quad(5.4,5.4,0,1.5,-0.9,RINGS_FRAG,0);
#     quad(4.8,2.7,-3.35,0.12,-1.2,FIELD_FRAG,1,0);
#     quad(4.8,2.7,3.35,0.12,-1.2,FIELD_FRAG,1,1);
#     quad(1.18,1.4,0,1.58,0.05,FACE_FRAG,4);
#     quad(1.0,1.0,0,0.58,0.06,CHEST_FRAG,5);
#     this.composer=new EffectComposer(this.renderer);
#     this.composer.addPass(new RenderPass(this.scene,this.camera));
#     this.bloom=new UnrealBloomPass(new THREE.Vector2(1,1),V.bloomStrength,V.bloomRadius,V.bloomThreshold);
#     this.bloom.enabled=this.preset.bloom;
#     this.composer.addPass(this.bloom);
#     this.composer.addPass(new OutputPass());
#     this.composer.addPass(new ShaderPass({uniforms:{tDiffuse:{value:null},uTime:{value:0},uVignette:{value:0.55}},
#       vertexShader:QUAD_VERT,fragmentShader:POST_FRAG} as any));
#     this.bindInput(); this.resize();
#     window.addEventListener('resize',this.resize);
#     this.tts.init(); this.startEntry();
#     this.renderer.setAnimationLoop(this.tick);
#     store.set({particles:hum.count});
#   }

#   private startEntry(){
#     store.set({state:'FORMING'});
#     const U=this.U,E=M.entry;
#     const tl=gsap.timeline({onUpdate:()=>store.set({assembly:tl.progress()}),
#       onComplete:()=>store.set({state:'IDLE',assembly:1})});
#     tl.to(U.uCore,{value:1,duration:E.core,ease:'power2.out'},0.2)
#       .to(U.uSwirl,{value:1,duration:E.swirl,ease:'power1.inOut'},0.35)
#       .to(U.uHead,{value:1,duration:E.head,ease:'power2.out'},1.3)
#       .to(U.uTorso,{value:1,duration:E.torso,ease:'power2.out'},2.4)
#       .to(U.uFace,{value:1,duration:E.face,ease:'power2.inOut'},3.6)
#       .to(U.uHalo,{value:1,duration:E.halo,ease:'power2.out'},4.0)
#       .to(U.uField,{value:1,duration:E.field,ease:'power2.out'},4.4)
#       .to(U.uRings,{value:1,duration:E.rings,ease:'power2.out'},4.9);
#   }

#   private bindInput(){
#     const toWorld=(nx:number,ny:number)=>{
#       const d=this.camera.position.z-0.85;
#       const t=Math.tan(THREE.MathUtils.degToRad(21));
#       return new THREE.Vector3(nx*t*this.camera.aspect*d,0.85+ny*t*d,0);
#     };
#     window.addEventListener('pointermove',e=>{
#       const nx=(e.clientX/innerWidth)*2-1, ny=-((e.clientY/innerHeight)*2-1);
#       this.pointer={x:nx,y:ny,active:0.45};
#       this.pointerWorld=toWorld(nx,ny);
#     });
#     window.addEventListener('pointerdown',()=>{ this.pulse=1; });
#     document.addEventListener('pointerleave',()=>{ this.pointer.active=0; });
#     this.hands.onStatus=s=>store.set({handStatus:s});
#     this.hands.onFrame=f=>{
#       this.hand.present=f.present; this.hand.pinch=f.pinch; this.hand.gesture=f.gesture;
#       this.hand.vx=f.vx; this.hand.vy=f.vy;
#       if(f.present) this.handWorld=toWorld(f.x*2-1,-(f.y*2-1));
#       store.set({gesture:f.gesture});
#     };
#   }

#   async enableCamera(on:boolean){
#     if(on) await this.hands.start();
#     else { this.hands.stop(); store.set({handStatus:'off',gesture:'none'}); }
#   }

#   async say(text:string){
#     store.set({state:'THINKING',caption:text});
#     await new Promise(r=>setTimeout(r,450));
#     store.set({state:'SPEAKING'});
#     await this.tts.speak(text,{onEnd:()=>store.set({state:'IDLE'})});
#   }

#   private tick=()=>{
#     if(this.disposed) return;
#     const dt=Math.min(0.05,this.clock.getDelta());
#     this.t+=dt*(this.reduced?0.6:1);
#     const U=this.U;
#     this.audio.update(dt);
#     const L=this.audio.levels;
#     const speaking=store.get().state==='SPEAKING';
#     const speechTarget=speaking?Math.min(1,L.level*1.6):0;
#     U.uTime.value=this.t; U.uBright.value=V.particleBrightness*V.lineBrightness;
#     U.uSize.value=V.particleSize; U.uNoise.value=V.noiseStrength; U.uFieldAmp.value=V.fieldAmplitude;
#     U.uRingI.value=V.ringIntensity; U.uChest.value=V.chestEnergy; U.uOrangeI.value=V.orangeIntensity;
#     U.uCyanI.value=V.cyanIntensity; U.uFaceE.value=V.faceEnergy;
#     U.uBreathAmp.value=M.idle.breathingAmount; U.uBreathSpeed.value=M.idle.breathingSpeed; U.uDrift.value=M.idle.particleDrift;
#     U.uRadius.value=M.gesture.influenceRadius;
#     U.uAudio.value=L.level; U.uBass.value=L.bass; U.uMid.value=L.mid; U.uHigh.value=L.high;
#     U.uSpeech.value+=(speechTarget-U.uSpeech.value)*(1-Math.exp(-dt*10));
#     const g=M.gesture;
#     const handTarget=this.hand.present?1:0;
#     this.hand.a+=(handTarget-this.hand.a)*(1-Math.exp(-dt*(this.hand.present?1/g.smoothing:g.returnSpeed*10)));
#     const target=this.hand.present?this.handWorld:this.pointerWorld;
#     (U.uHand.value as THREE.Vector3).lerp(target,1-Math.exp(-dt*12));
#     U.uHandA.value=Math.max(this.hand.a,this.pointer.active*0.5);
#     U.uPinch.value+=(this.hand.pinch-U.uPinch.value)*(1-Math.exp(-dt*10));
#     U.uStrength.value=g.strength*(0.6+this.hand.pinch*g.pinchStrength);
#     const speed=Math.hypot(this.hand.vx,this.hand.vy);
#     if(this.hand.present&&speed>1.2){
#       this.swipe.set(this.hand.vx,this.hand.vy).normalize().multiplyScalar(Math.min(1,speed/3));
#       this.swipeT=1;
#     }
#     this.swipeT*=Math.exp(-dt*2.5);
#     (U.uSwipe.value as THREE.Vector2).copy(this.swipe).multiplyScalar(this.swipeT);
#     this.pulse*=Math.exp(-dt*3.2); U.uPulse.value=this.pulse;
#     this.group.position.y=Math.sin(this.t*M.idle.breathingSpeed)*0.012*M.idle.breathingAmount;
#     this.group.rotation.y=Math.sin(this.t*0.14)*0.015*M.idle.headSway+U.uSpeech.value*Math.sin(this.t*7)*0.006*M.speech.headNod;
#     const px=(this.pointer.x*0.5+(this.hand.present?(U.uHand.value as THREE.Vector3).x*0.06:0))*M.camera.parallaxStrength;
#     this.camera.position.x+=(px-this.camera.position.x)*(1-Math.exp(-dt*3));
#     this.camera.position.y=0.85+this.pointer.y*0.12*M.camera.parallaxStrength;
#     this.camera.lookAt(0,0.82,0);
#     (this.composer.passes[3] as any).uniforms.uTime.value=this.t;
#     this.bloom.strength=V.bloomStrength*(1+U.uSpeech.value*0.35*M.speech.glowResponse);
#     this.composer.render();
#     this.frames++; this.fpsT+=dt;
#     if(this.fpsT>=0.5){ store.set({fps:Math.round(this.frames/this.fpsT),audioLevel:L.level}); this.frames=0; this.fpsT=0; }
#   };

#   resize=()=>{
#     const w=innerWidth,h=innerHeight;
#     const pr=Math.min(devicePixelRatio,this.preset.prCap);
#     this.renderer.setPixelRatio(pr); this.renderer.setSize(w,h);
#     this.composer.setPixelRatio(pr); this.composer.setSize(w,h);
#     this.camera.aspect=w/h;
#     this.camera.position.z=this.camera.aspect<0.9?9.6:7.3;
#     this.camera.updateProjectionMatrix();
#     this.U.uPR.value=pr;
#   };

#   dispose(){ this.disposed=true; this.renderer.setAnimationLoop(null); this.hands.stop(); this.renderer.dispose(); }
# }
# EOF_EXP

# cat > src/ui/App.tsx <<'EOF_APP'
# import { useEffect, useRef, useState, useSyncExternalStore } from 'react';
# import { Experience } from '../render/Experience';
# import { store, STATUS_TEXT } from '../state/store';
# import { DebugPanel } from './DebugPanel';

# const RESPONSES:[RegExp,string][]=[
#   [/feature|capab|think.*new|update/i,"Looking at the logs, I've shipped a few updates to humanoid tracking and stability. Gesture latency is down, and the particle field holds coherence at sixty frames. Shall I demonstrate?"],
#   [/hello|^hi\b|hey/i,"Hello. Systems nominal. I am Apex — a humanoid construct of light. Ask me anything."],
#   [/name|who are you/i,"I am Apex. A digital humanoid intelligence rendered in real time."],
#   [/gesture|hand|pinch/i,"Enable the camera and raise your hand. An open palm disperses my field; a pinch focuses it."],
# ];
# const reply=(t:string)=>RESPONSES.find(([r])=>r.test(t))?.[1]??`Processing "${t}". All subsystems nominal. Gesture interface standing by.`;

# export default function App(){
#   const canvasRef=useRef<HTMLCanvasElement>(null);
#   const expRef=useRef<Experience|null>(null);
#   const recRef=useRef<any>(null);
#   const snap=useSyncExternalStore(store.subscribe,store.get);
#   const [text,setText]=useState('');
#   const [camOn,setCamOn]=useState(false);
#   const [muted,setMuted]=useState(false);
#   const [listening,setListening]=useState(false);
#   const debug=location.search.includes('debug')||import.meta.env.DEV;
#   const compare=location.search.includes('compare');

#   useEffect(()=>{ const exp=new Experience(canvasRef.current!); expRef.current=exp; return ()=>exp.dispose(); },[]);

#   const send=async(t?:string)=>{
#     const msg=(t??text).trim(); if(!msg||!expRef.current) return; setText('');
#     expRef.current.audio.ensure();
#     await expRef.current.say(reply(msg));
#   };
#   const toggleCam=async()=>{ const next=!camOn; setCamOn(next); await expRef.current?.enableCamera(next); };
#   const toggleMic=()=>{
#     const SR=(window as any).SpeechRecognition||(window as any).webkitSpeechRecognition;
#     if(!SR) return;
#     if(listening){ recRef.current?.stop(); return; }
#     const rec=new SR(); recRef.current=rec; rec.lang='en-US'; rec.interimResults=false;
#     rec.onstart=()=>{ setListening(true); store.set({state:'LISTENING'}); };
#     rec.onresult=e=>{ const t=e.results[0][0].transcript; setText(t); setListening(false); send(t); };
#     rec.onend=()=>{ setListening(false); if(store.get().state==='LISTENING') store.set({state:'IDLE'}); };
#     rec.start();
#   };

#   return (
#     <div className="app">
#       <canvas ref={canvasRef} className="stage"/>
#       <div className="hud-status">{snap.state==='FORMING'?`ASSEMBLING... ${Math.round(snap.assembly*100)}%`:STATUS_TEXT[snap.state]}</div>
#       <div className="chip"><span className={`dot ${snap.state.toLowerCase()}`}/>{snap.state}{camOn?` · ${snap.gesture}`:''}</div>
#       <div className="controls">
#         <button onClick={toggleCam} title="Camera gestures">{camOn?'🖐 on':'🖐 off'}</button>
#         <button onClick={toggleMic} className={listening?'active':''} title="Voice input">{listening?'🎙 live':'🎙'}</button>
#         <button onClick={()=>{const m=!muted;setMuted(m);if(expRef.current)expRef.current.audio.muted=m;}}>{muted?'🔇':''}</button>
#         <button onClick={()=>document.fullscreenElement?document.exitFullscreen():document.documentElement.requestFullscreen()}>⛶</button>
#       </div>
#       <div className="voicebar">
#         <input value={text} onChange={e=>setText(e.target.value)} onKeyDown={e=>e.key==='Enter'&&send()} placeholder="Speak to the humanoid…"/>
#         <button onClick={()=>send()}>➤</button>
#       </div>
#       {snap.state==='ERROR'&&<div className="error">{snap.errorMsg||'Fault.'}</div>}
#       {debug&&<DebugPanel/>}
#       {compare&&<CompareOverlay/>}
#     </div>
#   );
# }

# function CompareOverlay(){
#   const [i,setI]=useState(0); const [op,setOp]=useState(0.5);
#   return (
#     <div className="compare">
#       <img src={`/reference/frame_${String(i).padStart(3,'0')}.png`} style={{opacity:op}} alt="reference"/>
#       <div className="compare-bar">
#         <button onClick={()=>setI(v=>Math.max(0,v-1))}>‹</button><span>frame {i}</span>
#         <button onClick={()=>setI(v=>v+1)}>›</button>
#         <input type="range" min={0} max={1} step={0.05} value={op} onChange={e=>setOp(+e.target.value)}/>
#       </div>
#     </div>
#   );
# }
# EOF_APP

# cat > src/ui/DebugPanel.tsx <<'EOF_DBG'
# import { useEffect, useRef } from 'react';
# import GUI from 'lil-gui';
# import { VISUAL_CONFIG as V, MOTION_CONFIG as M } from '../config/visualConfig';
# import { store } from '../state/store';
# export function DebugPanel(){
#   const ref=useRef<HTMLDivElement>(null);
#   useEffect(()=>{
#     const gui=new GUI({container:ref.current!,title:'APEX debug'});
#     const v=gui.addFolder('visual');
#     v.add(V,'bloomStrength',0,2.5,0.05); v.add(V,'bloomThreshold',0,1,0.01);
#     v.add(V,'particleBrightness',0.2,3,0.05); v.add(V,'particleSize',0.3,2.5,0.05);
#     v.add(V,'cyanIntensity',0,2,0.05); v.add(V,'orangeIntensity',0,2,0.05);
#     v.add(V,'noiseStrength',0,1.5,0.01); v.add(V,'fieldAmplitude',0,2,0.05);
#     v.add(V,'faceEnergy',0,2,0.05); v.add(V,'chestEnergy',0,2,0.05); v.add(V,'ringIntensity',0,1.5,0.05);
#     const m=gui.addFolder('motion');
#     m.add(M.idle,'breathingSpeed',0.1,2,0.05); m.add(M.idle,'particleDrift',0,1.5,0.05);
#     m.add(M.speech,'faceResponse',0,2,0.05); m.add(M.speech,'chestResponse',0,2,0.05);
#     m.add(M.gesture,'strength',0,2,0.05); m.add(M.gesture,'influenceRadius',0.3,4,0.05);
#     m.add(M.gesture,'smoothing',0.02,0.5,0.01); m.add(M.camera,'parallaxStrength',0,1,0.02);
#     const stats={fps:0,particles:0,state:'',hand:'',audio:0,renderer:''};
#     const s=gui.addFolder('stats');
#     s.add(stats,'fps').listen(); s.add(stats,'particles').listen(); s.add(stats,'state').listen();
#     s.add(stats,'hand').listen(); s.add(stats,'audio',0,1,0.01).listen(); s.add(stats,'renderer').listen();
#     const id=setInterval(()=>{ const st=store.get();
#       stats.fps=st.fps; stats.particles=st.particles; stats.state=st.state;
#       stats.hand=st.handStatus+'/'+st.gesture; stats.audio=st.audioLevel; stats.renderer=st.renderer; },250);
#     return ()=>{ clearInterval(id); gui.destroy(); };
#   },[]);
#   return <div ref={ref} className="debug-panel"/>;
# }
# EOF_DBG

# cat > src/styles.css <<'EOF_CSS'
# *{box-sizing:border-box} html,body,#root{height:100%}
# body{background:#020409;color:#cfefff;font:14px/1.4 ui-monospace,'SF Mono',Menlo,Consolas,monospace}
# .app{position:fixed;inset:0}
# canvas.stage{position:absolute;inset:0;width:100%;height:100%;display:block}
# .hud-status{position:absolute;top:34%;right:6%;color:#3ec9ff;font-size:11px;letter-spacing:.12em;text-shadow:0 0 8px #3ec9ff88;pointer-events:none;opacity:.9}
# .chip{position:absolute;top:14px;left:14px;display:flex;gap:8px;align-items:center;background:#0a1526aa;border:1px solid #1e7dff33;border-radius:999px;padding:6px 12px;backdrop-filter:blur(8px);font-size:11px;letter-spacing:.08em}
# .dot{width:8px;height:8px;border-radius:50%;background:#3ec9ff;box-shadow:0 0 10px #3ec9ff}
# .dot.speaking{background:#ff8c2e;box-shadow:0 0 10px #ff8c2e}
# .dot.listening{background:#eaffff;box-shadow:0 0 10px #eaffff}
# .dot.forming{background:#1e7dff;animation:blink 1s infinite}
# .dot.error{background:#ff3355;box-shadow:0 0 10px #ff3355}
# @keyframes blink{50%{opacity:.3}}
# .controls{position:absolute;top:14px;right:14px;display:flex;gap:8px}
# .controls button,.voicebar button{background:#0a1526aa;border:1px solid #1e7dff33;color:#cfefff;border-radius:10px;padding:8px 10px;cursor:pointer;backdrop-filter:blur(8px)}
# .controls button:hover,.voicebar button:hover,.controls button.active{border-color:#3ec9ff88}
# .voicebar{position:absolute;bottom:18px;left:50%;transform:translateX(-50%);display:flex;gap:8px;width:min(560px,86vw)}
# .voicebar input{flex:1;background:#0a1526aa;border:1px solid #1e7dff33;border-radius:10px;color:#eaffff;padding:10px 14px;outline:none;backdrop-filter:blur(8px);font:inherit}
# .voicebar input:focus{border-color:#3ec9ff88}
# .error{position:absolute;inset:auto 0 40% 0;text-align:center;color:#ff8c9c}
# .debug-panel{position:absolute;left:10px;bottom:10px;z-index:20;opacity:.92}
# .compare{position:absolute;inset:0;pointer-events:none}
# .compare img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover;mix-blend-mode:screen}
# .compare-bar{position:absolute;bottom:70px;left:50%;transform:translateX(-50%);display:flex;gap:10px;align-items:center;pointer-events:auto;background:#0a1526cc;padding:8px 12px;border-radius:10px}
# @media (max-width:640px){ .hud-status{right:4%;top:30%} .chip{font-size:10px} }
# EOF_CSS

# cat > server/tts.mjs <<'EOF_SRV'
# // Optional Edge-TTS bridge. Requires: python3 + `pip install edge-tts`
# import http from 'node:http';
# import { execFile } from 'node:child_process';
# import { mkdtempSync, readFile, rm } from 'node:fs';
# import { tmpdir } from 'node:os';
# import { join } from 'node:path';
# http.createServer((req,res)=>{
#   res.setHeader('Access-Control-Allow-Origin','*');
#   res.setHeader('Access-Control-Allow-Headers','content-type');
#   if(req.method==='OPTIONS') return res.end();
#   if(req.url==='/api/health'){ res.setHeader('content-type','application/json'); return res.end('{"ok":true}'); }
#   if(req.url==='/api/tts'&&req.method==='POST'){
#     let body=''; req.on('data',c=>body+=c);
#     req.on('end',()=>{
#       const {text}=JSON.parse(body||'{}');
#       const dir=mkdtempSync(join(tmpdir(),'tts-'));
#       const out=join(dir,'tts.mp3');
#       execFile('edge-tts',['--voice','en-US-ChristopherNeural','--text',String(text||'').slice(0,500),'--write-media',out],
#         async err=>{
#           if(err){ res.statusCode=500; return res.end('tts error'); }
#           res.setHeader('content-type','audio/mpeg');
#           res.end(await readFile(out));
#           rm(dir,{recursive:true,force:true:()=>{}});
#         });
#     });
#     return;
#   }
#   res.statusCode=404; res.end();
# }).listen(8787,()=>console.log('edge-tts bridge on :8787'));
# EOF_SRV

# cat > README.md <<'EOF_README'
# # APEX Humanoid
# npm install && npm run dev
# Optional real Edge-TTS audio: pip install edge-tts && npm run tts
# Calibration: drop extracted frames into public/reference/frame_000.png… and open /?compare
# Debug: /?debug (auto in dev)
# EOF_README

# echo "✔ Project created in ./apex-humanoid — run: cd apex-humanoid && npm install && npm run dev"