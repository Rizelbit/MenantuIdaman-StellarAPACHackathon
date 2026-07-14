# Mobile UI Handoff Spec — Kirimin

**Untuk:** handoff ke Claude Design (arsitektur informasi & fitur, bukan panduan visual)
**Sumber:** `docs/scope/scope.md`, `docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md`, `docs/PS-A_Remitansi-Tanpa-Paham-Crypto_Deep-Dive.md`, `frontend/lib/screens/*`
**Status:** draft — menambahkan permukaan baru (family shortcuts, request, split bill) di atas MVP scope yang sudah ada (send/receive/history)

North star tetap berlaku ke setiap layar: tidak ada seed phrase/wallet/gas di UI; angka selalu Rp; sign = biometrik.

---

## 1. Navigasi & struktur layar

```
Splash
  └─ Onboarding (passkey / Face ID)
       └─ Home (tab root)
            ├─ Tab: Home
            ├─ Tab: Riwayat (History)
            └─ (Profile/Settings — belum di-spec, out of scope dokumen ini)

Home
  ├─ Send Amount → Send Review → Send Success
  ├─ Receive
  ├─ Request Money (baru)
  ├─ Split Bill (baru)
  │    ├─ Split Bill: buat tagihan → pilih kontak → rincian per orang → kirim request
  │    └─ Split Bill: detail tagihan (status bayar per peserta)
  ├─ Family Contacts (baru — daftar penuh, diakses dari shortcut row)
  ├─ Transaction Detail (dari Recent Transaction list)
  └─ Promo Detail (dari banner, bisa deep-link ke Split Bill)
```

Home tetap satu scroll (bukan tab terpisah untuk tiap fitur) — konsisten dengan `home_screen.dart` yang sudah ada, diperluas.

---

## 2. Home screen — arsitektur informasi (top to bottom)

1. **Balance indicator** (sudah ada, dipertahankan)
2. **Promotional banner carousel** (baru)
3. **Quick actions row** (baru — 4 aksi)
4. **Family contact shortcuts** (baru — horizontal scroll)
5. **Recent transactions** (sudah ada sebagai "Riwayat", diperluas jadi list singkat + "Lihat semua")

### 2.1 Balance indicator
Sudah terimplementasi (`_BalanceHero`): eyebrow "Total saldo", angka Rp besar, toggle show/hide. Tidak ada perubahan struktur — dokumen ini hanya mencatatnya sebagai anchor teratas.

**Mock data:**
```json
{ "balanceIdr": 4250000, "balanceHiddenDefault": false }
```

### 2.2 Promotional banner
Carousel horizontal, auto-scroll opsional, 1 banner terlihat penuh + peek berikutnya. Tap → Promo Detail atau langsung deep-link ke fitur (mis. Split Bill).

**Fields per banner:** `id`, `title`, `subtitle`, `ctaLabel`, `deepLink`, `imageAsset` (placeholder saja, bukan concern dokumen ini), `badge` (opsional, mis. "Baru").

**Mock data:**
```json
[
  {
    "id": "promo-split-bill-launch",
    "title": "Sekarang bisa split bill bareng keluarga",
    "subtitle": "Bagi tagihan listrik, sewa, atau belanja bulanan tanpa ribet hitung manual.",
    "ctaLabel": "Coba Split Bill",
    "deepLink": "/split-bill/new",
    "badge": "Baru"
  },
  {
    "id": "promo-fee-transparency",
    "title": "Biaya transparan, selalu.",
    "subtitle": "Kamu selalu tahu persis berapa yang keluarga terima sebelum kirim.",
    "ctaLabel": "Pelajari",
    "deepLink": "/promo/fee-transparency"
  }
]
```

### 2.3 Quick actions
Row 4 ikon+label, ukuran sama, tidak ada hierarki visual di antara mereka (transparansi & kesetaraan aksi finansial).

| Action | Label | Target |
|---|---|---|
| Send | "Kirim" | Send Amount (flow existing) |
| Request | "Minta" | Request Money (baru) |
| Split Bill | "Split Bill" | Split Bill: buat tagihan (baru) |
| Receive | "Terima" | Receive (existing, dipindah dari tombol besar ke quick action agar sejajar) |

> Catatan desain-informasi: `home_screen.dart` saat ini punya tombol besar Kirim/Terima. Spec ini menaikkan itu menjadi 4 quick actions sejajar begitu Request dan Split Bill masuk scope — keputusan visual (ukuran/hierarki) tetap didesain oleh Claude Design, bukan bagian dokumen ini.

**Mock data:**
```json
[
  { "id": "send", "label": "Kirim", "icon": "arrow_upward" },
  { "id": "request", "label": "Minta", "icon": "call_received" },
  { "id": "split_bill", "label": "Split Bill", "icon": "call_split" },
  { "id": "receive", "label": "Terima", "icon": "arrow_downward" }
]
```

### 2.4 Family contact shortcuts
Horizontal scroll avatar+nama, untuk kontak keluarga yang sering dikirimi. Tap avatar → prefill Send Amount dengan penerima itu. Item terakhir "+ Tambah" → Family Contacts (tambah/kelola).

**Fields:** `id`, `name`, `relation` (mis. "Ibu", "Adik"), `avatarInitial` atau `avatarUrl`, `lastSentAt`, `isFrequent`.

**Mock data:**
```json
[
  { "id": "c1", "name": "Ibu", "relation": "Ibu", "avatarInitial": "IB", "lastSentAt": "2026-07-10", "isFrequent": true },
  { "id": "c2", "name": "Ayu (Adik)", "relation": "Adik", "avatarInitial": "AY", "lastSentAt": "2026-06-28", "isFrequent": true },
  { "id": "c3", "name": "Pak Slamet", "relation": "Ayah", "avatarInitial": "PS", "lastSentAt": "2026-05-02", "isFrequent": false }
]
```

### 2.5 Recent transactions
List ringkas (3–5 item terbaru) di Home; "Lihat semua" → History screen penuh (sudah ada). Tiap item: arah (kirim/terima/split bill), nominal, nama pihak lain, status, waktu relatif.

**Fields:** `id`, `type` (`send` | `receive` | `split_bill`), `counterpartyName`, `amountIdr`, `status` (`success` | `pending` | `failed`), `timestamp`.

**Mock data:**
```json
[
  { "id": "tx1", "type": "send", "counterpartyName": "Ibu", "amountIdr": 995000, "status": "success", "timestamp": "2026-07-13T09:20:00+07:00" },
  { "id": "tx2", "type": "split_bill", "counterpartyName": "Tagihan Listrik (3 orang)", "amountIdr": 150000, "status": "pending", "timestamp": "2026-07-11T18:05:00+07:00" },
  { "id": "tx3", "type": "receive", "counterpartyName": "Ayu (Adik)", "amountIdr": 200000, "status": "success", "timestamp": "2026-07-09T14:41:00+07:00" }
]
```

Empty state (0 transaksi) tetap pakai `EmptyView` yang sudah ada di `home_screen.dart`.

---

## 3. Fitur baru — arsitektur & alur

### 3.1 Send Money (existing, tidak berubah)
`send_amount_screen.dart` → `send_review_screen.dart` (rincian biaya transparan) → `send_success_screen.dart`. Tidak di-scope ulang di sini.

### 3.2 Request Money (baru)
Kebalikan dari Send: user meminta sejumlah uang dari kontak (family/lainnya), lalu penerima request mendapat notifikasi dan bisa "Bayar" (memicu Send flow dengan prefill).

**Layar:**
1. Request — pilih kontak, masukkan nominal + catatan opsional.
2. Request — konfirmasi & kirim (tanpa biometrik, karena tidak memindahkan dana).
3. Request Sent — status "Menunggu dibayar".

**Fields:** `id`, `requesterName`, `targetContactId`, `amountIdr`, `note`, `status` (`pending` | `paid` | `declined` | `expired`), `createdAt`.

**Mock data:**
```json
{
  "id": "req1",
  "requesterName": "Kamu",
  "targetContactId": "c2",
  "amountIdr": 300000,
  "note": "Buat beli buku sekolah",
  "status": "pending",
  "createdAt": "2026-07-14T08:00:00+07:00"
}
```

### 3.3 Split Bill (baru)
Bagi satu tagihan ke beberapa kontak, tiap peserta menerima Request Money individual senilai bagiannya.

**Layar:**
1. Split Bill: buat tagihan — nominal total, judul tagihan (mis. "Listrik Juli"), pilih kontak peserta.
2. Split Bill: rincian pembagian — equal split default, opsi edit manual per orang; total harus selalu balance dengan tagihan.
3. Split Bill: konfirmasi & kirim request ke semua peserta sekaligus.
4. Split Bill: detail tagihan — status bayar per peserta (`paid`/`pending`), progress bar total terkumpul.

**Fields (tagihan):** `id`, `title`, `totalAmountIdr`, `createdBy`, `createdAt`, `participants[]`.
**Fields (participant):** `contactId`, `name`, `shareIdr`, `status` (`pending` | `paid`).

**Mock data:**
```json
{
  "id": "split1",
  "title": "Listrik Juli",
  "totalAmountIdr": 450000,
  "createdBy": "Kamu",
  "createdAt": "2026-07-11T18:00:00+07:00",
  "participants": [
    { "contactId": "c1", "name": "Ibu", "shareIdr": 150000, "status": "paid" },
    { "contactId": "c2", "name": "Ayu (Adik)", "shareIdr": 150000, "status": "pending" },
    { "contactId": "self", "name": "Kamu", "shareIdr": 150000, "status": "paid" }
  ]
}
```

### 3.4 Family Contacts (baru — manajemen penuh)
List semua kontak keluarga tersimpan (bukan cuma shortcut), tambah kontak baru (nama, nomor rekening/nomor telepon terkait wallet), tandai sebagai "favorit" agar muncul di shortcut Home.

**Fields:** sama seperti kontak di §2.4, ditambah `phoneOrAccountRef`.

---

## 4. Ringkasan permukaan data (mock) yang perlu disiapkan untuk desain

| Data | Dipakai di | Item mock |
|---|---|---|
| `balance` | Home balance indicator | 1 objek |
| `promoBanners` | Home banner carousel | 2 item |
| `quickActions` | Home quick action row | 4 item (statis) |
| `familyContacts` | Home shortcut + Family Contacts screen | 3 item |
| `recentTransactions` | Home recent list + History | 3 item |
| `moneyRequest` | Request Money flow | 1 contoh |
| `splitBill` | Split Bill flow | 1 contoh (3 peserta) |

Semua nominal dalam Rupiah, tidak ada representasi token/crypto di layer manapun — konsisten dengan checklist invisible-crypto di build plan (`docs/PS-A_MVP-Architecture-Build-Plan_Flutter.md` §4).
