# KHO VIDEO LÊN APP STORE — việc Aib phải tự bấm

Ngày dựng: **30/08/2026**
Thư mục dự án: `~/kho-video-ios`

Em đã dựng xong **cái vỏ iOS** cho Kho Video. Vỏ này giống hệt cái đã đưa HMONG X lên App Store
thành công ngày 26/08, chỉ khác: **tên khác, logo khác, trỏ vào video.hmongx.com**.

Còn lại là mấy việc **chỉ Aib mới làm được** — vì nó cần Aib đăng nhập tài khoản Apple và
Codemagic bằng chính mật khẩu của Aib. Em không được phép làm hộ.

---

## 🟥 PHẢI ĐỌC TRƯỚC — CÁI NGUY HIỂM NHẤT

Kho Video **bán token / bán gói**. Trong sổ tay nộp App Store, đây là **kẻ giết người số 1**:

> **Guideline 3.1.1** — App cho người ta *xài* thứ đã mua ở ngoài (web, chuyển khoản)
> mà **trong app không mua được** → Apple đánh rớt. HMONG X đã rớt **3 lần** vì đúng cái này.
> Ẩn chữ, ẩn nút, đổi câu báo lỗi — **cả ba cách đều đã chết**.

Nghĩa là: **trước khi nộp Kho Video lên chợ, phải cắm mua-trong-app (IAP) thật.**
Và trước IAP thì giấy tờ phải xong theo đúng thứ tự:

> **Thuế (W-8BEN) → Ngân hàng → Paid Apps hiện chữ `Active` → rồi mới nộp.**

Tin mừng: **HMONG X đã đi hết đoạn đường này rồi**, nên giấy tờ chắc đã `Active`.
Aib chỉ cần vào xem lại một lần cho chắc: `App Store Connect → Business → Agreements`.

👉 **Vẫn nộp TestFlight được ngay bây giờ** (TestFlight không xét 3.1.1).
Chỉ **đừng bấm gửi duyệt lên chợ** khi chưa có IAP.

---

## ✅ BƯỚC 1 — Tạo App ID trong Apple Developer

Chỗ này là để Apple biết "có một app mới tên như thế này".

1. Mở https://developer.apple.com/account
2. Menu trái → **Certificates, Identifiers & Profiles**
3. Bấm **Identifiers** → dấu **＋** (màu xanh, cạnh chữ Identifiers)
4. Chọn **App IDs** → **Continue**
5. Chọn **App** → **Continue**
6. Điền:
   - **Description**: `Kho Video`
   - **Bundle ID**: chọn ô **Explicit**, gõ đúng chuỗi này (không thừa dấu cách):
     ```
     com.hmongx.khovideo
     ```
7. Kéo xuống phần **Capabilities** — **chưa cần tích gì cả.**
   *(Khi nào làm mua-trong-app thì quay lại tích **In-App Purchase**.)*
8. **Continue** → **Register**

> ✔️ Em đã hỏi thẳng Apple ngày 30/08/2026: tài khoản Aib hiện chỉ có
> `com.hmongx.app` và `com.hmongx.web`. **`com.hmongx.khovideo` còn trống, không đụng ai cả.**

---

## ✅ BƯỚC 2 — Tạo app mới trong App Store Connect

Chỗ này là cái "gian hàng" trên chợ.

1. Mở https://appstoreconnect.apple.com/apps
2. Bấm dấu **＋** góc trên trái → **New App**
3. Điền:
   - **Platforms**: tích **iOS**
   - **Name**: `Kho Video` — *(nếu Apple báo tên đã có người lấy, đổi thành `Kho Video Hmong`)*
   - **Primary Language**: `English (U.S.)`
   - **Bundle ID**: chọn `com.hmongx.khovideo` trong danh sách thả xuống
     *(chưa thấy thì Bước 1 chưa xong hoặc phải chờ 1-2 phút rồi tải lại trang)*
   - **SKU**: `khovideo-2026` (số nội bộ, Aib tự đặt, không ai nhìn thấy)
   - **User Access**: `Full Access`
4. **Create**

**Xong rồi hãy làm việc này ngay** — em cần con số:

5. Nhìn lên thanh địa chỉ của trình duyệt, nó sẽ như:
   `https://appstoreconnect.apple.com/apps/`**`6801789131`**`/appstore/...`
   → **Cụm 10 chữ số đó là Apple ID của app.** Chép lại gửi em.

6. Hoặc Aib tự sửa cũng được: mở file `~/kho-video-ios/codemagic.yaml`, tìm dòng
   ```yaml
   APP_STORE_APPLE_ID: "CHUA_CO"
   ```
   thay `CHUA_CO` bằng cụm số vừa chép.

---

## ✅ BƯỚC 3 — Dán khoá ký code vào Codemagic  ⚠️ QUAN TRỌNG NHẤT

### Vì sao phải làm

Mỗi lần Codemagic build mà **không có sẵn khoá cố định**, nó lại **đẻ thêm một chứng chỉ
phân phối mới** trong tài khoản Apple. Apple **chỉ cho 3 cái**.

Em vừa hỏi Apple hôm nay: **đã dùng đủ 3/3 rồi, hết chỗ.**

| Chứng chỉ | Hết hạn |
|---|---|
| iOS Distribution: A Cu Lao | 15/08/2027 |
| iOS Distribution: A Cu Lao | 22/08/2027 |
| iOS Distribution: A Cu Lao | 23/08/2027 |

⇒ Nếu build Kho Video mà thiếu khoá, nó đòi tạo cái thứ 4 → Apple từ chối → **build chết**,
và tệ hơn là có thể phải xoá bớt chứng chỉ, làm HMONG X cũng khó ký lại.

Em đã cài sẵn **chốt an toàn**: workflow sẽ **dừng ngay và báo lỗi rõ ràng** nếu thiếu khoá,
chứ không lẳng lặng đẻ thêm chứng chỉ như bản HMONG X cũ.

### Làm thế nào

Aib **dùng lại đúng cái khoá đã dùng cho HMONG X** — file tên `hmongx_cert_key`
(Aib tự sinh hồi 22/08, hoặc lấy lại giá trị biến `CERTIFICATE_PRIVATE_KEY` trong
app HMONG X trên Codemagic).

1. Mở https://codemagic.io → chọn app **Kho Video** (sau khi đã nối kho mã ở Bước 4)
2. Vào **Settings → Environment variables**
3. Điền:
   - **Variable name**: `CERTIFICATE_PRIVATE_KEY`
   - **Variable value**: dán **TOÀN BỘ** nội dung file `hmongx_cert_key`
     (kể cả 2 dòng `-----BEGIN RSA PRIVATE KEY-----` và `-----END RSA PRIVATE KEY-----`)
   - **Variable group**: gõ `ios_signing`
   - **Secure**: ✅ **tích vào**
4. Bấm **Add**

> ❌ **Đừng sinh khoá mới cho Kho Video.** Khoá mới = chứng chỉ mới = hết chỗ = chết.
> Phải là **đúng cái khoá cũ**, thì Apple mới nhận ra "à, vẫn chứng chỉ cũ" và cho ký.

*(Nếu Aib đã mất file `hmongx_cert_key` — báo em, đó là chuyện khác phải xử lý riêng,
có thể phải thu hồi 1 chứng chỉ cũ. Đừng tự bấm Revoke.)*

---

## ✅ BƯỚC 4 — Nối kho mã + khoá App Store Connect trên Codemagic

### 4a. Đưa mã lên GitHub
Dự án đã có sẵn git ở máy (`~/kho-video-ios`, đã commit lần đầu). Cần một kho trên GitHub
giống như HMONG X (`hmong4svn-ctrl/hmong-x-ios`).
Aib bảo em một câu là em đẩy lên hộ — **em chưa tự đẩy vì chưa được phép.**

⚠️ Kho HMONG X đang để **công khai**. Nếu Kho Video cũng công khai thì **tuyệt đối không
để mật khẩu / khoá nào trong file mã** — mọi thứ bí mật đều nằm ở biến môi trường Codemagic.

### 4b. Khoá App Store Connect API — **KHÔNG cần tạo mới**
Codemagic của Aib đã có tích hợp tên **`hmongx-asc`**. Một khoá dùng chung cho cả tài khoản
Apple, nên Kho Video **dùng lại y nguyên**. File `codemagic.yaml` đã ghi sẵn tên đó.

Chỉ cần kiểm lại một lần: **Codemagic → Teams → Integrations → App Store Connect**,
xem có dòng tên đúng là `hmongx-asc` không. Có rồi thì thôi, không phải làm gì.

---

## ✅ BƯỚC 5 — Bấm build

Trên Codemagic, app Kho Video sẽ hiện **2 nút chạy**:

| Tên | Làm gì | Khi nào bấm |
|---|---|---|
| **Kho Video iOS - kiem tra build** | Chỉ thử biên dịch, **không đụng chứng chỉ**, không tốn gì | Bấm **cái này trước**, cho chắc |
| **Kho Video iOS - NOP APP STORE** | Ký code + đẩy lên **TestFlight** | Khi cái trên đã xanh |

Bản nộp mặc định chỉ đi tới **TestFlight**, **không tự gửi duyệt lên chợ** — cố ý như vậy,
để không lỡ tay nộp khi chưa có IAP.

Kết quả gửi mail về `hmong4svn@gmail.com`.

---

## 📋 CÒN NHỮNG VIỆC NÀY TRƯỚC KHI NỘP LÊN CHỢ THẬT

Đây là bảng rút từ 11 lỗi Apple đã đánh HMONG X. Em đánh dấu cái nào Kho Video đã ổn,
cái nào **còn phải làm**.

| # | Điều luật | Kho Video hiện thế nào |
|---|---|---|
| 1 | **2.1(a)** thiếu khai quyền → app sập | 🟢 **Xong.** Em đã khai đủ camera / thư viện ảnh / micro bằng tiếng Anh |
| 2 | **Đăng nhập bị đá ra Safari không quay lại** | 🟢 **Xong.** Trang `kho-video.html` đã có sẵn "cửa thoát" `video.152-42-172-109.sslip.io`, và em **cố ý KHÔNG cho tên miền đó vào `allowNavigation`** — có nó là hỏng cả cơ chế |
| 3 | Icon sai / dùng nhầm logo | 🟢 **Xong.** Dùng `kho-video-mark.svg` (máy quay + hoa văn thổ cẩm). **Không** dùng logo Hmong X |
| 4 | **Chứng chỉ chạm trần 3/3** | 🟡 Đã cài chốt chặn, **chờ Aib dán khoá** (Bước 3) |
| 5 | **3.1.1 — mua trong app (IAP)** | 🔴 **CHƯA LÀM.** Kho Video bán token mà trong app chưa mua được → **nộp chợ là rớt** |
| 6 | **5.1.1(v) — xoá tài khoản ngay trong app** | 🔴 **Chưa kiểm.** Kho Video có đăng nhập ⇒ **bắt buộc** phải có nút xoá tài khoản, 2 lối vào, chữ tiếng Anh |
| 7 | **4.8 — Sign in with Apple phải nhìn thấy** | 🟡 Nút Apple có trong trang nhưng chỉ hiện khi máy chủ bật `appleReady`. **Phải mở app trên máy thật xem nút có hiện không** — HMONG X đã rớt 2 lần vì nút tàng hình |
| 8 | **2.1 — nút chết, "sắp có"** | 🔴 **Chưa rà.** Phải soi lại `kho-video.html` xem còn nút nào bấm không ra gì |
| 9 | **2.3.10 — ảnh chụp màn hình** | 🔴 **Chưa có.** Cần ảnh đúng cỡ **1290×2796** (6.7"). Ảnh Android không dùng được |
| 10 | **Tài khoản demo + Review Notes** | 🔴 **Chưa có.** Phải cho Apple một tài khoản đăng nhập được thật |
| 11 | **Apple duyệt trên iPad** | 🔴 **Chưa kiểm.** Lần 4 và 5 họ dùng iPad Air 11". Mọi thứ phải nhìn được ở khổ iPad |

---

## 🔧 MẤY ĐIỀU HAY DÙNG

### Sửa web là app tự đổi — khỏi build lại
App nạp giao diện thẳng từ `https://video.hmongx.com/kho-video.html`.
⇒ Sửa web + deploy VPS là **app đang nằm ở Apple cũng đổi theo**, không cần Codemagic.

**Chỉ 3 thứ này mới bắt buộc build lại:**
đổi `capacitor.config.json` · đổi mã Swift · đổi icon/splash.

### Tự kiểm trước khi nộp (chạy trên máy Aib)
```bash
bash ~/kho-video-ios/scripts/kiem-nhanh.sh
```
Bắt 4 lỗi chết người mà không cần build gì cả. **Đỏ một dòng là đừng nộp.**

Và bộ kiểm đầy đủ của sổ tay, chạy trên bản đang sống:
```bash
SITE=https://video.hmongx.com IOS_DIR=~/kho-video-ios \
bash "<vault>/.claude/skills/nop-app-store/scripts/kiem-truoc-khi-nop.sh"
```

### Vẽ lại icon nếu đổi logo
```bash
bash ~/kho-video-ios/assets/tao-anh.sh
```
Nó đọc `assets/kho-video-mark.svg`, vẽ lại icon 1024 + splash 2732, tự bỏ nền trong suốt
(App Store từ chối icon còn nền trong suốt) rồi chép thẳng vào dự án Xcode.

---

## 🗂️ CHỐT LẠI CẤU HÌNH

| Thứ | Giá trị |
|---|---|
| Bundle ID | `com.hmongx.khovideo` |
| Tên app | `Kho Video` |
| Trang app nạp | `https://video.hmongx.com/kho-video.html` |
| Màu nền / splash | `#0B3E69` (đúng màu `theme-color` của trang) |
| Nhãn trình duyệt | `KhoVideoiOS Capacitor` — chữ `Capacitor` **bắt buộc phải có**, vì `kho-video.html` nhận ra app iOS bằng `/HmongX\|Capacitor/i` |
| iOS thấp nhất chạy được | 15.0 |
| Team ID Apple | `A4XPMY5ZB8` (dùng chung với HMONG X) |
| Khoá ASC trên Codemagic | `hmongx-asc` (dùng lại, không tạo mới) |

**Cho vào `allowNavigation`:**
`video.hmongx.com` · `hmongx.com` · `*.hmongx.com` · `accounts.google.com` · `*.google.com` ·
`*.facebook.com` · `connect.facebook.net` · `appleid.apple.com`

**Cố ý KHÔNG cho vào:** `152-42-172-109.sslip.io` — đó là **cửa thoát** để app bung ra
Safari thật khi đăng nhập. Cho nó vào là Google chặn, ba nút đăng nhập chết hết.
