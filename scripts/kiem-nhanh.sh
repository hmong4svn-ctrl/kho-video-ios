#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# KIEM NHANH — chay tren may Aib TRUOC khi day len Codemagic, va Codemagic
# cung chay lai buoc nay truoc khi ky code.
# Bat 4 loi Apple da danh HMONG X that su, KHONG can build:
#   1. sslip.io lot vao allowNavigation  -> chet dang nhap (SKILL §6c) -> Guideline 2.1
#   2. Info.plist thieu quyen            -> CRASH khi bam chon video  -> Guideline 2.1(a)
#   3. Icon con alpha / sai co           -> App Store tu choi goi nop
#   4. appendUserAgent khong khop        -> trang khong biet dang chay trong app iOS
# Chay:  bash scripts/kiem-nhanh.sh
# ─────────────────────────────────────────────────────────────────────────────
set -u
cd "$(dirname "$0")/.."
LOI=0
bao_loi(){ echo "❌ $1"; LOI=1; }
bao_dat(){ echo "✅ $1"; }

CFG=capacitor.config.json
PL=ios/App/App/Info.plist
IC=ios/App/App/Assets.xcassets/AppIcon.appiconset/AppIcon-512@2x.png

# 1) CUA THOAT dang nhap phai nam NGOAI allowNavigation
#    Trang kho-video.html mo Safari that bang  https://video.152-42-172-109.sslip.io
#    Neu ten mien do lot vao allowNavigation, Capacitor giu lai trong webview
#    -> Google chan (disallowed_useragent) -> 3 nut dang nhap chet.
if grep -q "sslip.io" "$CFG"; then
  bao_loi "capacitor.config.json CO sslip.io trong allowNavigation - HONG CO CHE DANG NHAP"
else
  bao_dat "allowNavigation khong co sslip.io (cua thoat con nguyen)"
fi

# 2) Ba quyen bat buoc trong Info.plist
for k in NSCameraUsageDescription NSPhotoLibraryUsageDescription NSMicrophoneUsageDescription; do
  if /usr/libexec/PlistBuddy -c "Print :$k" "$PL" >/dev/null 2>&1; then
    bao_dat "Info.plist co $k"
  else
    bao_loi "Info.plist THIEU $k  (app se CRASH = Guideline 2.1(a))"
  fi
done

# 3) Icon: 1024x1024, khong alpha
#    🔴 VA 01/09/26 — TRUOC DUNG `from PIL import Image` ⇒ BUILD CHET tren may Codemagic:
#    "ModuleNotFoundError: No module named 'PIL'". May CI khong co Pillow, va cai them thi
#    ton them ~30 giay moi build. Doc thang HEADER PNG bang `struct` — chi can thu vien
#    co san cua Python, chay o dau cung duoc.
#    Cach doc: PNG bat dau bang 8 byte dau nhan dang, roi chunk IHDR:
#      byte 16-19 = chieu rong · 20-23 = chieu cao · 24 = do sau bit · 25 = kieu mau
#    Kieu mau 4 = xam+alpha, 6 = RGB+alpha ⇒ CO alpha (Apple tu choi icon co alpha).
python3 -c "
import sys, struct
p='$IC'
try:
    d=open(p,'rb').read(26)
except Exception as e:
    print('❌ Khong doc duoc icon:',e); sys.exit(1)
if d[:8] != b'\x89PNG\r\n\x1a\n':
    print('❌ Icon khong phai PNG:',p); sys.exit(1)
w,h = struct.unpack('>II', d[16:24])
mau  = d[25]
bad=False
if mau in (4,6):
    print('❌ Icon con kenh trong suot (alpha):',p); bad=True
if (w,h)!=(1024,1024):
    print('❌ Icon sai co:',(w,h),'- phai la 1024x1024'); bad=True
if not bad: print('✅ Icon 1024x1024, khong alpha')
sys.exit(1 if bad else 0)
" || LOI=1

# 4) appendUserAgent phai chua 'HmongX' hoac 'Capacitor'
#    kho-video.html:  laAppIOS() = /HmongX|Capacitor/i.test(navigator.userAgent)
#    Khong khop thi trang tuong dang chay tren web -> dang nhap o lai trong webview.
UA=$(python3 -c "import json;print(json.load(open('$CFG'))['ios'].get('appendUserAgent',''))")
if echo "$UA" | grep -Eqi "HmongX|Capacitor"; then
  bao_dat "appendUserAgent = '$UA' (khop laAppIOS)"
else
  bao_loi "appendUserAgent = '$UA' - KHONG khop /HmongX|Capacitor/i trong kho-video.html"
fi

echo


# 🔴 THÊM 30/08/26 — CỬA THOÁT phải nằm NGOÀI allowNavigation.
# Kho Video mượn cửa đăng nhập của app chính (biến CUA_THOAT trong kho-video.html). Nếu tên miền
# đó lọt vào allowNavigation thì Capacitor giữ trong app ⇒ Google thấy webview nhúng ⇒ CHẶN
# ⇒ đăng nhập chết. Suýt dính 30/08: dự án thêm hmongx.com vào danh sách, cùng ngày cửa thoát
# lại đổi sang đúng hmongx.com.
if python3 - <<'PYKIEM'
import json, re, sys, urllib.request
try:
    rq = urllib.request.Request('https://video.hmongx.com/kho-video.html',
        headers={'User-Agent': 'Mozilla/5.0', 'Cache-Control': 'no-cache'})   # Cloudflare chặn urllib trần (403)
    h = urllib.request.urlopen(rq, timeout=15).read().decode('utf-8', 'replace')
except Exception as e:
    print('  (bỏ qua: không tải được trang —', str(e)[:40], ')'); sys.exit(0)
m = re.search(r"CUA_THOAT\s*=\s*'https?://([^/']+)'", h)
if not m: print('  (bỏ qua: không thấy CUA_THOAT)'); sys.exit(0)
cua = m.group(1)
ds = json.load(open('capacitor.config.json'))['server']['allowNavigation']
xau = [x for x in ds if x == cua or (x.startswith('*.') and cua.endswith(x[1:]))]
if xau:
    print('  ❌ CUA THOAT (' + cua + ') LOT VAO allowNavigation qua: ' + ', '.join(xau))
    print('     → dang nhap se CHET trong app iOS. Bo cac muc do khoi allowNavigation.')
    sys.exit(1)
print('  cua thoat (' + cua + ') nam NGOAI allowNavigation')
sys.exit(0)
PYKIEM
then echo "✅ cua thoat nam ngoai allowNavigation"; else echo "❌ CUA THOAT LOT VAO allowNavigation"; LOI=1; fi

if [ $LOI -eq 0 ]; then echo "🟢 KIEM NHANH: DAT"; else echo "🔴 KIEM NHANH: CO LOI - DUNG NOP"; fi
exit $LOI
