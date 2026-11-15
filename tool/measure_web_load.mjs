// Usage: node tool/measure_web_load.mjs <url> <empty-chrome-profile-dir> [Fast|Slow|No] [runs]
// Needs Node 22+ (built-in WebSocket) and Google Chrome on macOS. No npm packages.
// Emulates a 390x844 phone with 4x CPU slowdown and network throttling, cache disabled.
// Prints, per run, the first paint (the splash, if any) and the first Flutter frame, in ms.
// Measures first load of the published Sprint web app under network/CPU throttling via CDP.
import { spawn } from 'node:child_process';
const URL_ = process.argv[2];
const profiles = {
  'No throttle': { down: -1, up: -1, rtt: 0 },
  'Fast 4G (9 Mbps, 170 ms RTT)': { down: 9e6, up: 1.5e6, rtt: 170 },
  'Slow 4G (1.6 Mbps, 150 ms RTT)': { down: 1.6e6, up: 0.75e6, rtt: 150 },
};
const ONLY = process.argv[4], RUNS = +(process.argv[5]||3), CPU = 4, PORT = 9333 + Math.floor(Math.random()*500);
const chrome = spawn('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  ['--headless=new', `--remote-debugging-port=${PORT}`, '--user-data-dir=' + process.argv[3], '--no-first-run', '--no-default-browser-check', '--disable-extensions', 'about:blank'], { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));
async function ver() { for (let i = 0; i < 50; i++) { try { return await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json(); } catch { await sleep(200); } } throw new Error('no chrome'); }
async function one(browserWs, prof) {
  const bws = new WebSocket(browserWs); await new Promise(r => bws.onopen = r);
  let id = 0; const pend = new Map(); const events = [];
  bws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && pend.has(d.id)) { pend.get(d.id)(d); pend.delete(d.id); } else events.push(d); };
  const send = (method, params = {}, sessionId) => new Promise(r => { const i = ++id; pend.set(i, r); bws.send(JSON.stringify({ id: i, method, params, sessionId })); });
  const { result: { targetId } } = await send('Target.createTarget', { url: 'about:blank' });
  const { result: { sessionId } } = await send('Target.attachToTarget', { targetId, flatten: true });
  const s = (m, p) => send(m, p, sessionId);
  await s('Page.enable'); await s('Network.enable'); await s('Page.addScriptToEvaluateOnNewDocument', { source: "window.addEventListener('flutter-first-frame',function(){window.__ff=performance.now();});" }); await s('Network.setCacheDisabled', { cacheDisabled: true });
  await s('Network.clearBrowserCache'); await s('Network.clearBrowserCookies');
  await s('Emulation.setDeviceMetricsOverride', { width: 390, height: 844, deviceScaleFactor: 3, mobile: true });
  await s('Emulation.setCPUThrottlingRate', { rate: prof.down === -1 ? 1 : CPU });
  await s('Network.emulateNetworkConditions', { offline: false, latency: prof.rtt, downloadThroughput: prof.down === -1 ? -1 : prof.down / 8, uploadThroughput: prof.up === -1 ? -1 : prof.up / 8 });
  const t0 = Date.now(); let bytes = 0; const reqs = new Map();
  await s('Page.navigate', { url: URL_ });
  let paneAt = null, fcp = null, firstFrame = null, ff = null;
  while (Date.now() - t0 < 90000) {
    for (const e of events.splice(0)) {
      if (e.method === 'Network.dataReceived') bytes += e.params.encodedDataLength || 0;
      if (e.method === 'Network.loadingFinished') { /* encoded length already counted via dataReceived approx */ }
    }
    const r = await s('Runtime.evaluate', { expression: `JSON.stringify({pane: !!document.querySelector('flt-glass-pane'), sem: !!document.querySelector('flt-semantics, flt-semantics-placeholder'), fcp: (performance.getEntriesByName('first-contentful-paint')[0]||{}).startTime||null, ff: window.__ff||null, txt: document.body ? document.body.innerText.length : 0, canv: document.querySelectorAll('canvas').length})`, returnByValue: true });
    const v = r.result?.result?.value ? JSON.parse(r.result.result.value) : null;
    if (v) { if (v.ff && ff === null) ff = Math.round(v.ff); if (v.pane && paneAt === null) paneAt = Date.now() - t0; if (v.fcp && fcp === null) fcp = v.fcp; if (v.canv > 0 && firstFrame === null) firstFrame = Date.now() - t0; }
    if (ff !== null) break;
    await sleep(100);
  }
  await send('Target.closeTarget', { targetId }); bws.close();
  return { firstPaint: fcp && Math.round(fcp), firstFlutterFrame: ff, mb: +(bytes / 1048576).toFixed(2) };
}
try {
  const { webSocketDebuggerUrl } = await ver();
  for (const [name, prof] of Object.entries(profiles)) {
    if (ONLY && !name.startsWith(ONLY)) continue;
    const out = [];
    for (let i = 0; i < RUNS; i++) out.push(await one(webSocketDebuggerUrl, prof));
    console.log(name, JSON.stringify(out));
  }
} finally { chrome.kill(); }
