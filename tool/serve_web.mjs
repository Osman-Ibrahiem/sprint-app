// Usage: node tool/serve_web.mjs <dir> <port>   e.g. build/web 8081
// Serves a web build under /sprint-app/ with gzip and no caching, like GitHub Pages,
// so tool/measure_web_load.mjs can compare two builds on the same footing.
// Static server with gzip, mounted under /sprint-app/ like GitHub Pages.
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path'; import zlib from 'node:zlib';
const [root, port] = [process.argv[2], +process.argv[3]];
const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.ttf': 'font/ttf', '.otf': 'font/otf', '.png': 'image/png', '.svg': 'image/svg+xml' };
http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]).replace(/^\/sprint-app/, '') || '/';
  if (p.endsWith('/')) p += 'index.html';
  const f = path.join(root, p);
  if (!f.startsWith(root) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) { res.writeHead(404); return res.end(); }
  const ext = path.extname(f); const h = { 'content-type': types[ext] || 'application/octet-stream', 'cache-control': 'no-store' };
  const buf = fs.readFileSync(f);
  if (['.html', '.js', '.json', '.wasm', '.ttf', '.otf'].includes(ext)) { h['content-encoding'] = 'gzip'; res.writeHead(200, h); res.end(zlib.gzipSync(buf, { level: 6 })); }
  else { res.writeHead(200, h); res.end(buf); }
}).listen(port, '127.0.0.1');
