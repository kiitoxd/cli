#!/usr/bin/env node
// wt-sphere: black hole frames, set default background, or cycle. usage: node wt-sphere.js [--generate|--set-default|--set-powershell-default]

const fs = require("fs");
const path = require("path");
const pc = require("picocolors");

const framesDir = path.join(__dirname, "frames");
const intervalMs = 80;
const opacity = 0.4;

function getSettingsPath() {
  const base = process.env.LOCALAPPDATA || "";
  const candidates = [
    path.join(base, "Packages", "Microsoft.WindowsTerminal_8wekyb3d8bbwe", "LocalState", "settings.json"),
    path.join(base, "Microsoft", "Windows Terminal", "settings.json"),
  ];
  for (const p of candidates) if (fs.existsSync(p)) return p;
  return null;
}

function getFrameFiles() {
  if (!fs.existsSync(framesDir)) return [];
  return fs.readdirSync(framesDir)
    .filter((f) => /\.(png|jpg|jpeg|gif|bmp)$/i.test(f))
    .sort()
    .map((f) => path.join(framesDir, f));
}

function getFirstFrame() {
  const list = getFrameFiles();
  return list.length ? list[0] : null;
}

function loadSettings(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

function ensureDefaults(data) {
  if (!data.profiles) data.profiles = {};
  if (!data.profiles.defaults) data.profiles.defaults = {};
  return data.profiles.defaults;
}

function writeSettings(p, data) {
  fs.writeFileSync(p, JSON.stringify(data, null, 2), "utf8");
}

function applyFrame(data, framePath) {
  const d = ensureDefaults(data);
  d.backgroundImage = framePath;
  d.backgroundImageStretchMode = "uniformToFill";
  d.backgroundImageOpacity = opacity;
}

async function generateFrames() {
  const sharp = require("sharp");
  const n = parseInt(process.env.FRAMES, 10) || 36;
  const w = parseInt(process.env.WIDTH, 10) || 800;
  const h = parseInt(process.env.HEIGHT, 10) || 600;
  const cx = w / 2, cy = h / 2;
  const rDisk = Math.min(w, h) * 0.4;
  const rHorizon = Math.min(w, h) * 0.12;
  const black = "#000000";
  const bg = "#0a0a0f";
  const orange = "#ff6b35";
  const yellow = "#f7c548";
  const red = "#c23a2b";
  const dim = "#1a0a0a";

  if (!fs.existsSync(framesDir)) fs.mkdirSync(framesDir, { recursive: true });

  for (let i = 0; i < n; i++) {
    const deg = (i / n) * 360;
    const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
  <defs>
    <radialGradient id="bh" gradientUnits="userSpaceOnUse" cx="${cx}" cy="${cy}" r="${rDisk}" gradientTransform="rotate(${deg} ${cx} ${cy})">
      <stop offset="0%" stop-color="${black}"/>
      <stop offset="${(rHorizon / rDisk) * 100}%" stop-color="${black}"/>
      <stop offset="${(rHorizon / rDisk) * 100 + 5}%" stop-color="${red}"/>
      <stop offset="35%" stop-color="${orange}"/>
      <stop offset="42%" stop-color="${yellow}"/>
      <stop offset="50%" stop-color="${orange}"/>
      <stop offset="65%" stop-color="${dim}"/>
      <stop offset="100%" stop-color="${bg}"/>
    </radialGradient>
  </defs>
  <rect width="100%" height="100%" fill="${bg}"/>
  <circle cx="${cx}" cy="${cy}" r="${rDisk}" fill="url(#bh)"/>
  <circle cx="${cx}" cy="${cy}" r="${rHorizon}" fill="${black}"/>
</svg>`;
    await sharp(Buffer.from(svg)).png().toFile(path.join(framesDir, `frame_${String(i + 1).padStart(3, "0")}.png`));
  }
  console.log(pc.green(`generated ${n} black hole frames in ${framesDir}`));
}

async function ensureFrames() {
  let first = getFirstFrame();
  if (first) return first;
  console.log(pc.cyan("no frames found, generating..."));
  await generateFrames();
  return getFirstFrame();
}

function setDefault() {
  const settingsPath = getSettingsPath();
  if (!settingsPath) {
    console.error(pc.red("windows terminal settings.json not found"));
    process.exit(1);
  }
  ensureFrames().then((framePath) => {
    if (!framePath) {
      console.error(pc.red("could not create or find frames"));
      process.exit(1);
    }
    const data = loadSettings(settingsPath);
    applyFrame(data, framePath);
    writeSettings(settingsPath, data);
    console.log(pc.green("default background set; open a new tab or restart wt"));
  }).catch((err) => {
    console.error(pc.red(err.message || err));
    process.exit(1);
  });
}

function cycle() {
  const settingsPath = getSettingsPath();
  if (!settingsPath) {
    console.error(pc.red("windows terminal settings.json not found"));
    process.exit(1);
  }
  const frames = getFrameFiles();
  if (!frames.length) {
    console.error(pc.red("no images in frames/; run with --generate first"));
    process.exit(1);
  }
  let i = 0;
  console.log(pc.cyan("cycling through"), pc.yellow(frames.length), pc.cyan("frames (ctrl+c to stop)"));
  function tick() {
    try {
      const data = loadSettings(settingsPath);
      applyFrame(data, frames[i]);
      writeSettings(settingsPath, data);
      i = (i + 1) % frames.length;
    } catch (e) {
      console.error(pc.red(e.message));
    }
    setTimeout(tick, intervalMs);
  }
  tick();
}

function setPowerShellDefault() {
  const settingsPath = getSettingsPath();
  if (!settingsPath) {
    console.error(pc.red("windows terminal settings.json not found"));
    process.exit(1);
  }
  const data = loadSettings(settingsPath);
  const list = data.profiles?.list || [];
  const ps = list.find((p) => (p.name && p.name.includes("PowerShell")) || p.source === "Windows.Terminal.PowerShellCore" || p.source === "Windows.Terminal.PowerShell") || list.find((p) => p.name && /powershell/i.test(p.name));
  if (!ps || !ps.guid) {
    console.error(pc.red("powerShell profile not found in windows terminal"));
    process.exit(1);
  }
  data.defaultProfile = ps.guid;
  writeSettings(settingsPath, data);
  console.log(pc.green("windows terminal default profile set to powershell"));
}

async function main() {
  const arg = process.argv[2];
  if (arg === "--generate") {
    await generateFrames();
    return;
  }
  if (arg === "--set-default") {
    setDefault();
    return;
  }
  if (arg === "--set-powershell-default") {
    setPowerShellDefault();
    return;
  }
  cycle();
}

main().catch((err) => {
  console.error(pc.red(err.message || err));
  process.exit(1);
});
