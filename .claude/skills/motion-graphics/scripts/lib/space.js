// space.js: deterministic WebGL2 space scenes for seek(t) films.
//   const sp = createSpace(W, H);
//   sp.solar({ ro, target, fov, t, planets, orbitAlpha })   -> renders the solar system (raytraced) into sp.canvas
//   sp.galaxy({ ro, target, fov, t, phase, sgr, andromeda })  -> renders the galaxy (particles) into sp.canvas
// Every frame is a pure function of its inputs (seeded particles, no timers).

import { rng } from './motion.js';

const V3 = { sub: (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]], add: (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]], mul: (a, s) => [a[0] * s, a[1] * s, a[2] * s],
  dot: (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2], cross: (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]],
  len: (a) => Math.hypot(a[0], a[1], a[2]), norm: (a) => { const l = Math.hypot(a[0], a[1], a[2]) || 1; return [a[0] / l, a[1] / l, a[2] / l]; }, lerp: (a, b, p) => [a[0] + (b[0] - a[0]) * p, a[1] + (b[1] - a[1]) * p, a[2] + (b[2] - a[2]) * p] };
export { V3 };

// Camera basis: right, up, forward (looking at target).
export function basis(ro, target, roll = 0) {
  const f = V3.norm(V3.sub(target, ro)); let r = V3.norm(V3.cross(f, [0, 1, 0])); let u = V3.cross(r, f);
  if (roll) { const c = Math.cos(roll), s = Math.sin(roll); const r2 = V3.add(V3.mul(r, c), V3.mul(u, s)); u = V3.add(V3.mul(u, c), V3.mul(r, -s)); r = r2; }
  return { r, u, f };
}
// Project a world point to screen pixels (null when behind the camera).
export function project(p, ro, target, fovDeg, W, H, roll = 0) {
  const { r, u, f } = basis(ro, target, roll), d = V3.sub(p, ro), z = V3.dot(d, f); if (z <= 0.0001) return null;
  const k = 1 / Math.tan((fovDeg * Math.PI) / 360); const x = (V3.dot(d, r) / z) * k, y = (V3.dot(d, u) / z) * k;
  return [W / 2 + x * H / 2, H / 2 - y * H / 2, z];
}

const NOISE = `
float hash(vec3 p){ p = fract(p*0.3183099+vec3(.1,.2,.3)); p *= 17.0; return fract(p.x*p.y*p.z*(p.x+p.y+p.z)); }
float noise(vec3 x){ vec3 i=floor(x), f=fract(x); f=f*f*(3.0-2.0*f);
  return mix(mix(mix(hash(i+vec3(0,0,0)),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),
             mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z); }
float fbm(vec3 p){ float a=0.5, s=0.0; for(int i=0;i<6;i++){ s+=a*noise(p); p*=2.03; a*=0.5; } return s; }
vec3 aces(vec3 x){ return clamp((x*(2.51*x+0.03))/(x*(2.43*x+0.59)+0.14),0.0,1.0); }
// Background sky: stars in two layers plus the Milky Way band (galactic plane normal G).
vec3 sky(vec3 rd, float band, vec3 G, vec3 core){
  vec3 c = vec3(0.004,0.006,0.016);
  for(int L=0; L<2; L++){ float sc = L==0 ? 260.0 : 110.0; vec3 q = rd*sc; vec3 id = floor(q); float h = hash(id);
    float thr = L==0 ? 0.985 : 0.996; if(h>thr){ vec3 sp = id+0.5+(vec3(hash(id+1.3),hash(id+2.7),hash(id+5.1))-0.5)*0.7; float d = length(q-sp);
      float b = smoothstep(L==0?0.22:0.3, 0.0, d) * (h-thr)/(1.0-thr) * (L==0?1.6:3.0); vec3 tint = mix(vec3(0.75,0.82,1.0), vec3(1.0,0.85,0.7), hash(id+9.0)); c += tint*b; } }
  if(band>0.0){ float lat = dot(rd,G); float m = exp(-lat*lat/0.03);
    float toward = pow(max(dot(rd,core),0.0),3.0);
    float dust = fbm(rd*7.0+3.0); float clouds = fbm(rd*3.0);
    vec3 mw = mix(vec3(0.25,0.27,0.4), vec3(0.75,0.6,0.45), toward) * (0.35+0.9*clouds) * (1.0 - 0.75*smoothstep(0.45,0.7,dust)*exp(-lat*lat/0.006));
    c += mw * m * (0.06 + 0.28*toward) * band; }
  return c; }`;

const QUAD_VS = `#version 300 es
in vec2 p; out vec2 v; void main(){ v = p; gl_Position = vec4(p,0,1); }`;

const SOLAR_FS = `#version 300 es
precision highp float;
in vec2 v; out vec4 o;
uniform vec2 res; uniform vec3 ro, cr, cu, cf; uniform float k, time, orbitAlpha, band, fade;
uniform vec4 P[6];            // 0 sun, 1 earth, 2 moon, 3 mars, 4 jupiter, 5 saturn: xyz pos, w radius
uniform float orbitR[6];
${NOISE}
float sph(vec3 ro, vec3 rd, vec4 s){ vec3 oc=ro-s.xyz; float b=dot(oc,rd), c=dot(oc,oc)-s.w*s.w, h=b*b-c; if(h<0.0) return -1.0; h=sqrt(h); float t=-b-h; return t>0.0?t:-1.0; }
mat3 rotY(float a){ float c=cos(a), s=sin(a); return mat3(c,0,-s, 0,1,0, s,0,c); }
const vec3 RN = normalize(vec3(0.42,1.0,0.1)); // Saturn ring-plane normal (tilted)
vec3 surface(int id, vec3 n, vec3 N, vec3 L, vec3 rd, out float spec){
  spec = 0.0;
  if(id==1){ vec3 p = rotY(time*0.05)*n; float h = fbm(p*2.1+vec3(3.1,1.7,0.4)); float land = smoothstep(0.52,0.56,h);
    vec3 ocean = mix(vec3(0.01,0.05,0.16), vec3(0.03,0.16,0.36), fbm(p*7.0));
    vec3 lc = mix(vec3(0.10,0.24,0.08), vec3(0.42,0.35,0.2), smoothstep(0.56,0.7,h)); lc = mix(lc, vec3(0.85,0.88,0.9), smoothstep(0.78,0.86,abs(p.y)));
    vec3 col = mix(ocean, lc, land); spec = (1.0-land)*0.9;
    float cl = smoothstep(0.5,0.75, fbm(rotY(time*0.03)*n*3.5 + vec3(0.0,7.0,0.0))); return mix(col, vec3(0.95), cl*0.85); }
  if(id==2){ float c = fbm(n*5.0); return vec3(0.5,0.49,0.47)*(0.6+0.5*c) - 0.18*smoothstep(0.55,0.62,fbm(n*9.0+2.0)); }
  if(id==3){ vec3 p = rotY(time*0.06)*n; vec3 col = mix(vec3(0.36,0.1,0.04), vec3(0.72,0.28,0.12), fbm(p*3.0)); col = mix(col, vec3(0.2,0.07,0.04), smoothstep(0.55,0.7,fbm(p*5.0+4.0))*0.6); col *= 0.75+0.35*fbm(p*12.0); return mix(col, vec3(0.9,0.88,0.86), smoothstep(0.86,0.93,abs(p.y))); }
  if(id==4){ vec3 p = rotY(time*0.08)*n; float lat = p.y; float w = fbm(vec3(p.x*2.5, lat*10.0, p.z*2.5)+time*0.01);
    float b = sin(lat*21.0 + w*4.5); float b2 = sin(lat*47.0 + w*6.0);
    vec3 col = mix(vec3(0.9,0.82,0.68), vec3(0.55,0.33,0.2), smoothstep(-0.35,0.35,b)); col = mix(col, vec3(0.75,0.6,0.45), 0.25*(b2*0.5+0.5)); col *= 0.85+0.3*fbm(p*9.0);
    float lon = atan(p.z,p.x); vec2 q = vec2((lon-0.8)*2.2, (lat+0.36)*7.0); float sp = smoothstep(1.0,0.6,length(q)); col = mix(col, vec3(0.74,0.33,0.2), sp*0.85); return col; }
  if(id==5){ vec3 p = rotY(time*0.07)*n; float lat = dot(p, RN); float b = sin(lat*16.0 + fbm(p*vec3(2,10,2))*1.5); return mix(vec3(0.86,0.74,0.52), vec3(0.68,0.56,0.38), b*0.5+0.5); }
  return vec3(1.0); }
void main(){
  vec2 uv = v * vec2(res.x/res.y, 1.0); vec3 rd = normalize(cf*k + cr*uv.x + cu*uv.y);
  vec3 col = sky(rd, band, normalize(vec3(0.28,0.92,0.27)), normalize(vec3(-0.6,0.1,0.8)));
  float tHit = 1e9; int hid = -1;
  for(int i=0;i<6;i++){ float t = sph(ro, rd, P[i]); if(t>0.0 && t<tHit){ tHit=t; hid=i; } }
  // Saturn rings
  vec4 S = P[5]; float denom = dot(rd, RN); float tr = abs(denom)>1e-5 ? dot(S.xyz-ro, RN)/denom : -1.0; vec4 ring = vec4(0);
  if(tr>0.0){ vec3 hp = ro+rd*tr; float r = length(hp-S.xyz)/S.w; if(r>1.24 && r<2.28){ // C ring faint, B ring dense, Cassini division, A ring with the Encke gap
      float prof = r<1.53 ? 0.18 : r<1.95 ? 0.95 : r<2.03 ? 0.06 : 0.62; prof *= 1.0 - 0.8*smoothstep(0.01,0.0,abs(r-2.21));
      float d = prof * (0.8 + 0.25*(fbm(vec3(r*90.0,0.0,0.0))-0.5)*2.0 + 0.08*sin(r*260.0)); d *= smoothstep(1.24,1.27,r)*smoothstep(2.28,2.26,r);
      vec3 rc = r<1.53 ? vec3(0.55,0.5,0.45) : r<1.95 ? vec3(0.9,0.8,0.62) : vec3(0.78,0.75,0.7);
      vec3 L = normalize(P[0].xyz-hp); float lit = 0.3+0.7*abs(dot(RN,L)); if(sph(hp+L*0.01, L, S)>0.0) lit *= 0.12; ring = vec4(rc*lit*1.15, clamp(d,0.0,1.0)*0.92); } }
  // Orbits on the ecliptic (y = 0), a hairline in screen space
  if(orbitAlpha>0.0 && abs(rd.y)>1e-4){ float te = -ro.y/rd.y; if(te>0.0 && te<tHit){ vec3 hp = ro+rd*te; float r = length(hp.xz); float w = te*0.0016;
      for(int i=1;i<6;i++){ if(i==2) continue; col += vec3(0.55,0.65,0.9)*0.5*orbitAlpha*exp(-abs(r-orbitR[i])/w); } } }
  if(hid>=0){ vec3 hp = ro+rd*tHit; vec3 N = normalize(hp-P[hid].xyz);
    if(hid==0){ float g = fbm(N*7.0+time*0.05); col = vec3(1.0,0.72,0.35)*(1.6+1.2*g)*(0.55+0.45*dot(N,-rd)); }
    else { vec3 L = normalize(P[0].xyz-hp); float spec; vec3 a = surface(hid, N, N, L, rd, spec); float dif = max(dot(N,L),0.0);
      float shadow = (hid==5 || hid==4) ? 1.0 : (sph(hp+L*0.01, L, P[2])>0.0 && hid==1 ? 0.25 : 1.0);
      vec3 c = a*dif*shadow*1.25 + a*0.012; c += vec3(1.0,0.9,0.75)*spec*pow(max(dot(reflect(-L,N),-rd),0.0),60.0)*dif;
      if(hid==1){ float fr = pow(1.0-max(dot(N,-rd),0.0),3.0); c += vec3(0.3,0.55,1.0)*fr*(0.15+0.85*smoothstep(-0.2,0.4,dot(N,L))); }
      col = c; } }
  // Ring compositing: in front of the planet or alone
  if(ring.a>0.0 && tr < tHit) col = mix(col, ring.rgb, ring.a);
  // Earth atmosphere halo and the Sun's corona (not behind a hit)
  { vec3 oc = P[1].xyz-ro; float tb = dot(oc,rd); if(tb>0.0){ float d = length(oc-rd*tb); float R = P[1].w; if(d>R && tb<tHit+R){ vec3 L = normalize(P[0].xyz-P[1].xyz); vec3 hn = normalize((ro+rd*tb)-P[1].xyz);
      col += vec3(0.25,0.5,1.0)*exp(-(d-R)/(0.045*R))*0.6*smoothstep(-0.3,0.5,dot(hn,L)); } } }
  { vec3 oc = P[0].xyz-ro; float tb = dot(oc,rd); if(hid<0 || tHit>tb){ float d = tb>0.0 ? length(oc-rd*tb) : length(oc); float R = P[0].w;
      col += vec3(1.0,0.6,0.25)*0.55*pow(R/max(d,R),2.2) + vec3(1.0,0.85,0.6)*0.25*exp(-(d-R)/(0.35*R))*step(R,d); } }
  col = aces(col*1.15);
  o = vec4(pow(col, vec3(0.4545))*fade, 1.0);
}`;

const SKY_FS = `#version 300 es
precision highp float; in vec2 v; out vec4 o;
uniform vec2 res; uniform vec3 cr, cu, cf, G, core; uniform float k, band, fade;
${NOISE}
void main(){ vec2 uv = v*vec2(res.x/res.y,1.0); vec3 rd = normalize(cf*k+cr*uv.x+cu*uv.y); vec3 c = sky(rd, band, G, core)*0.8;
  float neb = fbm(rd*2.2+1.7); c += vec3(0.10,0.04,0.13)*smoothstep(0.6,0.9,neb)*0.28 + vec3(0.02,0.04,0.09)*smoothstep(0.55,0.85,fbm(rd*1.5+8.0))*0.3;
  o = vec4(pow(aces(c), vec3(0.4545))*fade, 1.0); }`;

const PTS_VS = `#version 300 es
in vec4 a;   // r, theta, y, size
in vec4 col; // rgb, kind (0 star, 1 dust, 2 nebula, 3 glow)
uniform mat4 vp; uniform vec3 cam; uniform float phase, pscale, maxSize; uniform mat4 model;
out vec4 vcol; flat out float kind;
void main(){
  float r = a.x; float th = a.y + phase * (10.0 / (r + 2.0));
  vec4 wp = model * vec4(r*cos(th), a.z, r*sin(th), 1.0);
  gl_Position = vp * wp; float dist = max(gl_Position.w, 1e-4);
  float s = a.w * pscale / dist; float alpha = 1.0;
  if(s < 1.5){ alpha = (s*s)/(1.5*1.5); s = 1.5; }
  gl_PointSize = min(s, maxSize); kind = col.a;
  vcol = vec4(col.rgb, alpha * (col.a > 0.5 && col.a < 1.5 ? 0.3 : 1.0));
}`;
const PTS_FS = `#version 300 es
precision highp float; in vec4 vcol; flat in float kind; out vec4 o; uniform float fade;
void main(){ vec2 q = gl_PointCoord*2.0-1.0; float d = dot(q,q); if(d>1.0) discard;
  float g = kind > 1.5 ? exp(-d*2.5) : exp(-d*5.0);
  if(kind > 0.5 && kind < 1.5){ o = vec4(vec3(0.0), g*vcol.a*fade); return; }
  o = vec4(vcol.rgb*g*vcol.a*fade, 1.0); }`;

const BH_VS = `#version 300 es
in vec2 p; out vec2 v; uniform mat4 vp; uniform vec3 C, R, U; uniform float S;
void main(){ v = p; vec3 w = C + (R*p.x + U*p.y)*S; gl_Position = vp*vec4(w,1.0); }`;
const BH_FS = `#version 300 es
precision highp float; in vec2 v; out vec4 o; uniform float time, fade;
${NOISE}
void main(){ vec2 q = v; float r = length(q);
  // accretion disc seen at an angle: ellipse, Doppler-bright on the approaching side, a lensed arc over the top
  vec2 e = vec2(q.x, q.y/0.32); float re = length(e); float ang = atan(e.y, e.x);
  float disc = smoothstep(0.32,0.38,re)*smoothstep(1.0,0.62,re) * (0.6+0.4*fbm(vec3(re*9.0, ang*3.0 - time*0.9, 1.0)));
  float dop = 1.0 + 0.85*cos(ang);
  float front = step(0.0, -e.y) + step(0.0, e.y)*step(0.3, r); // far half hidden inside the shadow
  vec3 c = vec3(1.0,0.62,0.25)*disc*dop*front*1.6;
  float arc = exp(-pow((r-0.36)/0.03,2.0)) * smoothstep(-0.05,0.2,q.y); c += vec3(1.0,0.75,0.45)*arc*1.3;
  float ring = exp(-pow((r-0.27)/0.012,2.0)); c += vec3(1.0,0.85,0.6)*ring*1.2;
  float shadow = smoothstep(0.255,0.24,r);
  float a = clamp(max(max(disc*front, arc), ring) + shadow, 0.0, 1.0) * smoothstep(1.0,0.85,r);
  o = vec4(c*fade, a*fade); }`;

function program(gl, vs, fs) {
  const mk = (type, src) => { const s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s); if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(s) + '\n' + src.split('\n').map((l, i) => `${i + 1}: ${l}`).slice(0, 400).join('\n')); return s; };
  const p = gl.createProgram(); gl.attachShader(p, mk(gl.VERTEX_SHADER, vs)); gl.attachShader(p, mk(gl.FRAGMENT_SHADER, fs)); gl.linkProgram(p);
  if (!gl.getProgramParameter(p, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(p));
  const u = new Proxy({}, { get: (_, n) => gl.getUniformLocation(p, n) }); return { p, u };
}
const perspective = (fovDeg, aspect, n, f) => { const t = 1 / Math.tan((fovDeg * Math.PI) / 360), nf = 1 / (n - f); return [t / aspect, 0, 0, 0, 0, t, 0, 0, 0, 0, (f + n) * nf, -1, 0, 0, 2 * f * n * nf, 0]; };
function viewMat(ro, target, roll) { const { r, u, f } = basis(ro, target, roll); return [r[0], u[0], -f[0], 0, r[1], u[1], -f[1], 0, r[2], u[2], -f[2], 0, -V3.dot(r, ro), -V3.dot(u, ro), V3.dot(f, ro), 1]; }
const mul4 = (a, b) => { const o = new Array(16).fill(0); for (let c = 0; c < 4; c++) for (let r = 0; r < 4; r++) for (let k = 0; k < 4; k++) o[c * 4 + r] += a[k * 4 + r] * b[c * 4 + k]; return o; };
const I4 = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];

// ---- Galaxy particle generator (units: 1 = 1000 light-years) ----
const gauss = (r) => { let u = 0, v = 0; while (u === 0) u = r(); v = r(); return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v); };
export const ARM_PITCH = (13 * Math.PI) / 180;
export const armTheta = (arm, r) => arm * (Math.PI / 2) + Math.log(r / 2.2) / Math.tan(ARM_PITCH);
function buildGalaxy(seed, scale = 1, counts = {}) {
  const r = rng(seed), out = [];
  const push = (rad, th, y, size, cr, cg, cb, kind) => out.push(rad, th, y, size, cr, cg, cb, kind);
  const nDisk = counts.disk ?? 170000, nBar = counts.bar ?? 22000, nBulge = counts.bulge ?? 22000, nDust = counts.dust ?? 60000, nNeb = counts.neb ?? 700, nGlow = counts.glow ?? 9000;
  for (let i = 0; i < nDisk; i++) { // disk: exponential profile, four logarithmic arms (two major), inter-arm field
    const rad = Math.min(54, 3 + -Math.log(1 - r() * 0.985) * 12.5) * scale; const inArm = r() < 0.72;
    const arm = r() < 0.66 ? (r() < 0.5 ? 0 : 2) : (r() < 0.5 ? 1 : 3);
    const spread = (0.18 + 2.2 / (rad / scale + 2)) * gauss(r) * (arm % 2 ? 1.3 : 1);
    const th = inArm ? armTheta(arm, rad / scale) + spread : r() * Math.PI * 2;
    const y = gauss(r) * (0.22 + 0.006 * rad / scale) * scale;
    const young = inArm && r() < 0.7; const tint = r();
    const c = young ? [0.62 + 0.2 * tint, 0.72 + 0.15 * tint, 1.0] : [1.0, 0.86 + 0.08 * tint, 0.7 + 0.12 * tint];
    const b = (young ? 1.0 : 0.65) * (0.5 + r() * 0.9);
    push(rad, th, y, (0.05 + r() * 0.11) * scale, c[0] * b * 1.5, c[1] * b * 1.5, c[2] * b * 1.5, 0);
  }
  for (let i = 0; i < nBar; i++) { const x = gauss(r) * 6.2 * scale, z = gauss(r) * 1.7 * scale, y = gauss(r) * 0.55 * scale, a = 0.45; const xx = x * Math.cos(a) - z * Math.sin(a), zz = x * Math.sin(a) + z * Math.cos(a); const b = 0.6 + r() * 0.8;
    push(Math.hypot(xx, zz), Math.atan2(zz, xx), y, (0.06 + r() * 0.1) * scale, 1.0 * b, 0.8 * b, 0.55 * b, 0); }
  for (let i = 0; i < nBulge; i++) { const x = gauss(r) * 2.6 * scale, z = gauss(r) * 2.6 * scale, y = gauss(r) * 1.6 * scale; const b = 0.7 + r() * 0.9;
    push(Math.hypot(x, z), Math.atan2(z, x), y, (0.07 + r() * 0.1) * scale, 1.0 * b, 0.78 * b, 0.5 * b, 0); }
  for (let i = 0; i < nDust; i++) { const rad = (4 + r() * 38) * scale, arm = Math.floor(r() * 4); const th = armTheta(arm, rad / scale) - 0.16 + gauss(r) * 0.07; push(rad, th, gauss(r) * 0.12 * scale, (0.3 + r() * 0.8) * scale, 0, 0, 0, 1); }
  for (let i = 0; i < nNeb; i++) { const rad = (6 + r() * 40) * scale, arm = Math.floor(r() * 4); const th = armTheta(arm, rad / scale) + gauss(r) * 0.08; const pink = r() < 0.75;
    push(rad, th, gauss(r) * 0.1 * scale, (0.25 + r() * 0.7) * scale, pink ? 0.3 : 0.15, pink ? 0.09 : 0.18, pink ? 0.16 : 0.3, 2); }
  for (let i = 0; i < nGlow; i++) { const inner = r() < 0.12; const rad = inner ? Math.abs(gauss(r)) * 4.5 * scale : (3 + -Math.log(1 - r() * 0.95) * 13) * scale, arm = Math.floor(r() * 4);
    const th = inner ? r() * Math.PI * 2 : armTheta(arm, rad / scale) + gauss(r) * 0.22; const s = (inner ? 2.5 + r() * 4 : 1.4 + r() * 2.4) * scale;
    push(rad, th, gauss(r) * 0.2 * scale, s, inner ? 0.07 : 0.035, inner ? 0.05 : 0.045, inner ? 0.025 : 0.07, 2); }
  push(0, 0, 0, 16 * scale, 0.7, 0.48, 0.24, 3); push(0, 0, 0, 6 * scale, 1.0, 0.8, 0.55, 3); push(0, 0, 0, 2 * scale, 1.0, 0.92, 0.8, 3); // core glow
  return new Float32Array(out);
}
// Extra local stars in a tube around a path (so travelling through the disk has parallax).
function buildTube(seed, pathFn, n = 40000, radius = 1.6) {
  const r = rng(seed), out = [];
  for (let i = 0; i < n; i++) { const s = r(); const [px, py, pz] = pathFn(s); const ox = gauss(r) * radius, oy = gauss(r) * radius * 0.35, oz = gauss(r) * radius; const x = px + ox, z = pz + oz;
    const tint = r(), b = 0.35 + r() * 0.9; const c = tint < 0.7 ? [0.8, 0.85, 1.0] : [1.0, 0.85, 0.65];
    out.push(Math.hypot(x, z), Math.atan2(z, x), py + oy, 0.006 + r() * 0.012, c[0] * b, c[1] * b, c[2] * b, 0); }
  return new Float32Array(out);
}

export function createSpace(W, H, { tubePath } = {}) {
  const canvas = document.createElement('canvas'); canvas.width = W; canvas.height = H;
  const gl = canvas.getContext('webgl2', { preserveDrawingBuffer: true, antialias: true, premultipliedAlpha: false });
  if (!gl) throw new Error('WebGL2 not available');
  const quad = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, quad); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
  const solar = program(gl, QUAD_VS, SOLAR_FS), skyP = program(gl, QUAD_VS, SKY_FS), pts = program(gl, PTS_VS, PTS_FS), bh = program(gl, BH_VS, BH_FS);
  const mkCloud = (data) => { const vao = gl.createVertexArray(); gl.bindVertexArray(vao); const b = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, b); gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);
    const la = gl.getAttribLocation(pts.p, 'a'), lc = gl.getAttribLocation(pts.p, 'col'); gl.enableVertexAttribArray(la); gl.vertexAttribPointer(la, 4, gl.FLOAT, false, 32, 0); gl.enableVertexAttribArray(lc); gl.vertexAttribPointer(lc, 4, gl.FLOAT, false, 32, 16);
    gl.bindVertexArray(null); return { vao, n: data.length / 8, data }; };
  const kinds = (data, k) => { const idx = []; for (let i = 0; i < data.length / 8; i++) if (data[i * 8 + 7] === k) idx.push(i); return idx; };
  // Split clouds by kind so we can blend each pass correctly.
  const split = (data) => [0, 1, 2, 3].map((k) => { const ids = kinds(data, k), d = new Float32Array(ids.length * 8); ids.forEach((id, j) => d.set(data.subarray(id * 8, id * 8 + 8), j * 8)); return mkCloud(d); });
  const MW = split(buildGalaxy(7)), AND = split(buildGalaxy(31, 1.1, { disk: 60000, bar: 4000, bulge: 14000, dust: 6000, neb: 300 }));
  const TUBE = tubePath ? mkCloud(buildTube(5, tubePath)) : null;
  const bhBuf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, bhBuf); gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);

  const drawQuad = (prog) => { gl.useProgram(prog.p); gl.bindBuffer(gl.ARRAY_BUFFER, quad); const l = gl.getAttribLocation(prog.p, 'p'); gl.enableVertexAttribArray(l); gl.vertexAttribPointer(l, 2, gl.FLOAT, false, 0, 0); gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4); };
  const camU = (prog, ro, target, fov, roll) => { const { r, u, f } = basis(ro, target, roll); gl.uniform3fv(prog.u.cr, r); gl.uniform3fv(prog.u.cu, u); gl.uniform3fv(prog.u.cf, f); gl.uniform1f(prog.u.k, 1 / Math.tan((fov * Math.PI) / 360)); gl.uniform2f(prog.u.res, W, H); };

  return {
    canvas, gl,
    solar({ ro, target, fov = 45, roll = 0, t, planets, orbitR, orbitAlpha = 0, band = 1, fade = 1 }) {
      gl.viewport(0, 0, W, H); gl.disable(gl.BLEND); gl.useProgram(solar.p); camU(solar, ro, target, fov, roll);
      gl.uniform3fv(solar.u.ro, ro); gl.uniform1f(solar.u.time, t); gl.uniform1f(solar.u.orbitAlpha, orbitAlpha); gl.uniform1f(solar.u.band, band); gl.uniform1f(solar.u.fade, fade);
      gl.uniform4fv(solar.u.P, planets.flat()); gl.uniform1fv(solar.u.orbitR, orbitR); drawQuad(solar);
    },
    galaxy({ ro, target, fov = 50, roll = 0, t, phase = 0, pscale = 900, maxSize = 64, sgr = 0, andromeda = null, tube = 0, band = 0, fade = 1, gain = 1, near = 0.01, far = 20000 }) {
      gl.viewport(0, 0, W, H); gl.disable(gl.BLEND); gl.useProgram(skyP.p); camU(skyP, ro, target, fov, roll); gl.uniform1f(skyP.u.band, band); gl.uniform1f(skyP.u.fade, fade); gl.uniform3fv(skyP.u.G, [0, 1, 0]); gl.uniform3fv(skyP.u.core, V3.norm(V3.sub([0, 0, 0], ro))); drawQuad(skyP);
      const vp = mul4(perspective(fov, W / H, near, far), viewMat(ro, target, roll));
      gl.useProgram(pts.p); gl.uniformMatrix4fv(pts.u.vp, false, vp); gl.uniform3fv(pts.u.cam, ro); gl.uniform1f(pts.u.pscale, pscale * H / 1080); gl.uniform1f(pts.u.maxSize, maxSize); gl.uniform1f(pts.u.fade, fade * gain);
      gl.enable(gl.BLEND);
      const passes = (cloud, model, ph) => {
        gl.uniformMatrix4fv(pts.u.model, false, model); gl.uniform1f(pts.u.phase, ph);
        gl.blendFunc(gl.ONE, gl.ONE); gl.bindVertexArray(cloud[0].vao); gl.drawArrays(gl.POINTS, 0, cloud[0].n);                          // stars
        gl.blendFunc(gl.ZERO, gl.ONE_MINUS_SRC_ALPHA); gl.bindVertexArray(cloud[1].vao); gl.drawArrays(gl.POINTS, 0, cloud[1].n);         // dust darkens
        gl.blendFunc(gl.ONE, gl.ONE); gl.bindVertexArray(cloud[2].vao); gl.drawArrays(gl.POINTS, 0, cloud[2].n);                          // HII nebulae
        gl.bindVertexArray(cloud[3].vao); gl.drawArrays(gl.POINTS, 0, cloud[3].n);                                                        // core glow
      };
      passes(MW, I4, phase);
      if (TUBE && tube > 0) { gl.uniformMatrix4fv(pts.u.model, false, I4); gl.uniform1f(pts.u.phase, phase); gl.uniform1f(pts.u.fade, fade * tube); gl.blendFunc(gl.ONE, gl.ONE); gl.bindVertexArray(TUBE.vao); gl.drawArrays(gl.POINTS, 0, TUBE.n); gl.uniform1f(pts.u.fade, fade * gain); }
      if (andromeda) { gl.uniform1f(pts.u.pscale, pscale * H / 1080 * (andromeda.boost || 1)); passes(AND, andromeda.model, phase * 0.5); gl.uniform1f(pts.u.pscale, pscale * H / 1080); }
      gl.bindVertexArray(null);
      if (sgr > 0) { // Sagittarius A* billboard at the core, facing the camera
        const { r, u } = basis(ro, [0, 0, 0], roll); gl.useProgram(bh.p); gl.uniformMatrix4fv(bh.u.vp, false, vp); gl.uniform3fv(bh.u.C, [0, 0, 0]); gl.uniform3fv(bh.u.R, r); gl.uniform3fv(bh.u.U, u); gl.uniform1f(bh.u.S, sgr); gl.uniform1f(bh.u.time, t); gl.uniform1f(bh.u.fade, 1);
        gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); gl.bindBuffer(gl.ARRAY_BUFFER, bhBuf); const l = gl.getAttribLocation(bh.p, 'p'); gl.enableVertexAttribArray(l); gl.vertexAttribPointer(l, 2, gl.FLOAT, false, 0, 0); gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4); }
      gl.disable(gl.BLEND);
    },
  };
}
export const model = { translateRotate(tx, ty, tz, rx, rz, s = 1) { const cx = Math.cos(rx), sx = Math.sin(rx), cz = Math.cos(rz), sz = Math.sin(rz);
  // R = Rz * Rx, column-major with uniform scale
  const m = [cz, sz, 0, 0, -sz * cx, cz * cx, sx, 0, sz * sx, -cz * sx, cx, 0, 0, 0, 0, 1].map((v, i) => (i < 12 && i % 4 !== 3 ? v * s : v)); m[12] = tx; m[13] = ty; m[14] = tz; return m; } };
