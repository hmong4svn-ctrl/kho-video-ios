# Bo kenh trong suot (alpha) khoi icon — App Store TU CHOI icon con alpha.
# Roi chep vao Assets.xcassets dung ten Capacitor doi.
import os, shutil, json
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
XC   = os.path.join(HERE, "..", "ios", "App", "App", "Assets.xcassets")

# --- ICON: 1024x1024, KHONG alpha, nen trang ---
ic = Image.open(os.path.join(HERE, "icon-1024.svg.png")).convert("RGBA")
if ic.size != (1024, 1024):
    ic = ic.resize((1024, 1024), Image.LANCZOS)
flat = Image.new("RGB", (1024, 1024), (255, 255, 255))
flat.paste(ic, (0, 0), ic)
icon_out = os.path.join(XC, "AppIcon.appiconset", "AppIcon-512@2x.png")
os.makedirs(os.path.dirname(icon_out), exist_ok=True)
flat.save(icon_out, "PNG")
print("icon ->", icon_out, flat.size, "alpha:", flat.mode)

# --- SPLASH: 2732x2732, nen xanh dam #0B3E69 ---
sp = Image.open(os.path.join(HERE, "splash-2732.svg.png")).convert("RGBA")
if sp.size != (2732, 2732):
    sp = sp.resize((2732, 2732), Image.LANCZOS)
spf = Image.new("RGB", (2732, 2732), (0x0B, 0x3E, 0x69))
spf.paste(sp, (0, 0), sp)
sdir = os.path.join(XC, "Splash.imageset")
os.makedirs(sdir, exist_ok=True)
base = os.path.join(sdir, "splash-2732x2732.png")
spf.save(base, "PNG")
for extra in ("splash-2732x2732-1.png", "splash-2732x2732-2.png"):
    shutil.copyfile(base, os.path.join(sdir, extra))
for n in ("1x", "2x", "3x"):
    for suf in ("", "-dark"):
        shutil.copyfile(base, os.path.join(sdir, f"Default@{n}~universal~anyany{suf}.png"))

# Contents.json theo dung mau cua HMONG X (co ban toi/sang)
imgs = []
for n in ("1x", "2x", "3x"):
    imgs.append({"idiom": "universal", "filename": f"Default@{n}~universal~anyany.png", "scale": n})
for n in ("1x", "2x", "3x"):
    imgs.append({"appearances": [{"appearance": "luminosity", "value": "dark"}],
                 "idiom": "universal", "scale": n,
                 "filename": f"Default@{n}~universal~anyany-dark.png"})
with open(os.path.join(sdir, "Contents.json"), "w") as f:
    json.dump({"images": imgs, "info": {"version": 1, "author": "xcode"}}, f, indent=2)
print("splash ->", sdir, spf.size)
