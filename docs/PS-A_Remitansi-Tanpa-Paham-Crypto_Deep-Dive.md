# Problem Statement A — "Remitansi Murah Tanpa Harus Paham Crypto"
### Deep-Dive untuk Tahap Ideation & Pengembangan | Hackathon Stellar

> **Status dokumen:** Draft riset v1 — untuk didiskusikan tim sebelum fiksasi problem statement
> **Track:** Payment Consumer Applications (SEA)
> **Disusun oleh:** Mentor (Web3/Stellar)
> **Cakupan data:** World Bank/KNOMAD, BSP, State Bank of Vietnam, IOM, OJK, dokumentasi resmi Stellar, laporan industri 2025–2026

---

## 0. TL;DR (baca ini dulu)

**Masalahnya nyata, besar, dan quantifiable.** Pekerja migran dari Indonesia, Filipina, dan Vietnam mengirim pulang **puluhan miliar dolar per tahun** (PH sendiri: rekor **$35,6 miliar** di 2025), tapi masih membayar biaya **5–8%** lewat jalur konvensional dan menunggu **3–5 hari kerja** untuk settlement. Stablecoin di Stellar sudah terbukti memangkas biaya ke **<1–1,5%** dan settlement ke **~5 detik**.

**Tapi ada dua barrier, bukan satu:**
1. **Barrier finansial** — biaya tinggi + settlement lambat (masalah lama).
2. **Barrier crypto/UX** — untuk pakai stablecoin hari ini, user biasanya harus paham exchange, wallet, seed phrase. **~60% calon user Web3 kabur begitu ketemu seed phrase; >90% hilang sebelum transaksi pertama.**

**Celah yang bisa kita isi:** solusi yang menang bukan yang "paling crypto", tapi yang **paling tidak terasa seperti crypto**. Passkey (Protocol 21 Stellar) + embedded wallet + off-ramp via anchor = user cukup pakai Face ID, saldo dalam "dolar", cash-out ke rekening/e-wallet lokal. **Terasa seperti transfer bank, jalannya di atas Stellar.**

**Catatan penting (jangan dilewat):** di **Indonesia, crypto/stablecoin ILEGAL sebagai alat pembayaran domestik** (hanya rupiah legal tender). Jadi produk kita harus diposisikan sebagai **remitansi lintas-batas + off-ramp ke IDR lewat operator/exchange berlisensi**, *bukan* dompet stablecoin untuk belanja di dalam negeri. Detail di [Bagian 4](#4-catatan-regulasi-wajib-dibaca-sebelum-desain).

**Kompetitor sudah ada** (MoneyGram di Stellar, Coins.ph + Remitly, GCash), tapi celah UX/segmen tertentu masih terbuka. Detail di [Bagian 2](#2-existing-solutions--peta-kompetitor).

---

## 1. Pendalaman Masalah — Statistik, Press, & Konteks

### 1.1 Skala pasar: ini bukan masalah niche

Remitansi adalah salah satu aliran uang lintas-batas terbesar dan paling stabil ke negara berkembang. Untuk tiga negara target kita:

| Negara | Remitansi masuk / tahun | % dari GDP | Catatan |
|---|---|---|---|
| **Filipina** | **~$35,6 miliar** (cash, rekor 2025); ~$39,6 M (personal) | **7,3%** | Penerima remitansi terbesar ke-4 dunia. Sumber terbesar: AS (~40%), Singapura, Arab Saudi, Jepang, UEA |
| **Vietnam** | **~$16 miliar** (personal, 2025); $6–7 M dari pekerja kontrak | ~4% | Ho Chi Minh City sendiri: **$10,3 miliar** di 2025. ~860 ribu pekerja di luar negeri (Jepang, Taiwan, Korsel) |
| **Indonesia** | **~$14,5–15,6 miliar**; pasar money-transfer ~$18 M | ~1% | **~9 juta** pekerja migran (PMI). Wilayah penerima terbesar: Bali, Jakarta, **Bekasi**, Jawa Timur, NTB |

> **Hook lokal buat tim:** menurut data BNI, **Bekasi** termasuk lima wilayah penerima remitansi PMI terbesar di Indonesia. Ini masalah yang secara harfiah ada di sekitar kita — bagus untuk narasi demo & user interview.

**Gabungan Filipina + Indonesia + Vietnam + Thailand: >$70 miliar remitansi masuk per tahun.** Bahkan menghemat 3–4 poin persentase biaya = **miliaran dolar** yang tetap di tangan keluarga penerima, bukan hilang ke fee.

### 1.2 Pain point #1 — Biaya masih jauh di atas target global

- **Rata-rata biaya kirim remitansi global: 6,36%** (World Bank RPW, Q3 2025) — masih **dua kali lipat** target PBB SDG 10.c sebesar **3%**.
- Untuk koridor Asia via correspondent banking tradisional, biaya efektif sering **5–8%** dari nilai transfer.
- PBB memperkirakan jika target 3% tercapai, keluarga penerima remitansi global akan hemat **~$20 miliar/tahun**.

**Kenapa mahal?** Jalur lama melewati banyak bank perantara (correspondent banking), masing-masing memungut fee + spread FX yang tidak transparan. Semakin kecil nominal kiriman, semakin besar porsi fee-nya secara persentase — dan pekerja migran justru sering mengirim dalam nominal kecil tapi rutin.

### 1.3 Pain point #2 — Settlement lambat & tidak transparan

- Remitansi lewat bank/correspondent banking: **3–5 hari kerja**, dengan jam operasional terbatas dan proses batch.
- Stablecoin di Stellar: **settlement ~5 detik**, 24/7/365.
- Konteks buat keluarga penerima: uang yang telat 3 hari itu bisa berarti telat bayar sekolah, sewa, atau kebutuhan darurat.

### 1.4 Pain point #3 — Ketidaktahuan biaya & "double barrier" crypto

Ini bagian yang paling sering dilewatkan, padahal ini justru celah produk kita.

**Sisi transparansi (survei IOM di pekerja migran Indonesia):**
- **~85% responden tidak tahu rincian** dari biaya remitansi yang mereka bayar.
- **~21% bahkan tidak sadar** ada biaya layanan yang dipungut per transfer.

Artinya: bukan cuma mahal, tapi user *tidak tahu* seberapa mahal. Ada ruang besar untuk produk yang **jujur & transparan soal biaya** sebagai diferensiasi.

**Sisi barrier crypto (kalau solusinya berbasis blockchain):**
- **~60% calon user Web3 meninggalkan onboarding** begitu ketemu instruksi seed phrase.
- **>90% user hilang** sebelum menyelesaikan transaksi pertama di onboarding Web3 tradisional.

**Insight kunci:** kalau kita bangun remittance app di atas Stellar tapi masih memaksa user paham wallet/seed phrase/exchange, kita cuma menukar satu masalah (fee) dengan masalah lain (kompleksitas). **Solusi yang menang adalah yang menyembunyikan crypto sepenuhnya.** Ini persis yang di-enable oleh passkey Stellar (lihat [Bagian 3](#3-relevansi--implementasi-stellar)).

### 1.5 Pemicu momentum baru (kenapa timing-nya pas sekarang)

- **Pajak remitansi AS 1% (berlaku 2026).** AS memberlakukan pajak ~1% atas transfer remitansi tertentu (tunai/money order/cashier's check). AS adalah **~40% sumber remitansi Filipina** dan koridor besar untuk banyak diaspora. Ekonom BSP mencatat sebagian OFW bahkan mempercepat kiriman di Des 2025 untuk menghindari pajak ini. → Tekanan biaya baru = insentif tambahan untuk mencari jalur yang lebih murah.
- **Regulasi stablecoin makin matang** (OJK di Indonesia efektif Jan 2025; MiCA di Eropa; GENIUS Act di AS 2025). Stablecoin bergeser dari "eksperimen" ke "infrastruktur pembayaran" yang diakui regulator.
- **Adopsi B2B sudah divalidasi:** di SEA, sebagian besar volume stablecoin sudah dipakai untuk pembayaran bisnis lintas-batas. Rel-nya sudah terbukti; yang belum matang justru **pengalaman konsumen ritel** — itu arena kita.

**Kutipan industri (diparafrase):** CEO Coins.ph, Wei Zhou, menyebut stablecoin sedang bergeser dari teknologi niche menjadi infrastruktur global, dan tujuan adopsinya adalah agar setiap dolar yang dihemat memberi lebih banyak nilai bagi keluarga penerima. Eksekutif MoneyGram menyebut masalah tersulit dalam uang lintas-batas bukan sekadar memindahkan token, melainkan menangani identitas, kepatuhan, konversi FX, dan akses tunai di ujung — dan di situlah jaringan fisik mereka bermain.

---

## 2. Existing Solutions — Peta Kompetitor

**Kabar penting: kompetitor SUDAH ADA.** Ini bukan alasan mundur — di hackathon, membangun di ruang yang sudah tervalidasi lebih aman daripada menebak masalah. Yang perlu kita lakukan adalah **menemukan celah spesifik** yang belum digarap dengan baik. Berikut lanskapnya, dari yang paling matang.

### Tier 1 — Incumbent remittance + rel stablecoin

**MoneyGram (di atas Stellar)** — ini kompetitor paling langsung dan paling relevan untuk dipelajari.
- Produk **MoneyGram Ramps** (dulu "MoneyGram Access"): jembatan antara USDC di Stellar dan jaringan **~500.000 lokasi tunai fisik** di **200+ negara**.
- Volume kumulatif remitansi USDC yang difasilitasi: **>$4,2 miliar**; melayani puluhan juta pelanggan.
- Sept 2025: meluncurkan app generasi baru berbasis stablecoin (pertama di Kolombia), user terima saldo "dolar" (USDC), bisa hold / cash-out / pakai kartu debit.
- Juni 2026: meluncurkan **MGUSD**, stablecoin milik MoneyGram sendiri (issuer Bridge/Stripe, minting via M0, wallet via Fireblocks) — semuanya di Stellar.
- **Cara kerja off-ramp:** user tunjukkan kode konfirmasi dari app ke agen MoneyGram, ambil tunai dalam mata uang lokal. Cash-out leg biasanya **~1,5–3%**.

**Remitly + Coins.ph** (kolaborasi diumumkan ~Sept 2025, di-highlight lagi Jan 2026)
- Remitly (jaringan 170+ negara, ~8,9 juta user aktif kuartalan) memakai rel stablecoin Coins.ph untuk kirim ke Filipina.
- Fokus koridor **AS & Kanada → Filipina** (dua negara ini = ~45% total remitansi PH).

### Tier 2 — Crypto super-app lokal (sudah punya lisensi & user)

**Coins.ph** (Filipina) — **BSP-licensed** (VASP + e-money), berdiri 2014.
- Punya stablecoin peso sendiri, **PHPC** (di-approve BSP, peg 1:1 ke PHP).
- Fitur remitansi: kirim dari luar negeri → convert ke USDT → ke peso → masuk wallet/GCash/Maya/bank.
- **Bayar pakai stablecoin via QRPh** (USDT/USDC) di 600 ribu+ merchant — pertama di Filipina.
- Klaim biaya koridor turun ke **0,5–1,5%** inklusif spread on/off-ramp.

**GCash** (Filipina) — **94 juta user**, integrasi crypto lewat partnership Binance.
**Maya / PDAX** (Filipina) — VASP berlisensi, on-ramp crypto + remitansi.
**TransFi, RebelFi, dll.** — infrastruktur B2B untuk USDC→GCash/bank di seluruh SEA.

### Tier 3 — Wallet Stellar murni (pure crypto, UX beragam)

- **LOBSTR** (global), **Vibrant** (LATAM), **Beans** (fokus **SEA**), Chipper Cash/Ejara (Afrika) — 15+ wallet terintegrasi dengan MoneyGram Ramps.
- Umumnya masih menuntut user paham konsep wallet/aset — inilah tier yang paling kena "barrier crypto".

### Perbandingan biaya (buat kalibrasi ekspektasi)

| Jalur | Biaya per transfer (order of magnitude) | Kecepatan |
|---|---|---|
| Transfer USDC on-chain langsung (Stellar) | **~$0,01** (fraksi sen) | ~5 detik |
| Off-ramp via MoneyGram (cash-out leg) | ~1,5–3% | ~menit (ambil tunai) |
| Wise | ~0,5–0,6% (~$2,65 di transfer $500) | menit–jam |
| USDT di Tron | ~$0,50 | menit |
| Western Union / bank tradisional | **$25+ / 5–8%** | 3–5 hari |

### Analisis celah — di mana kita bisa menang

Kompetitor kuat di **koridor besar & mainstream** (AS→PH, cash pickup fisik). Celah yang **masih terbuka**:

1. **Koridor Indonesia yang under-served.** Fokus kompetitor stablecoin paling matang ada di **Filipina**. Koridor **Indonesia** (mis. Malaysia/Taiwan/Hong Kong/Arab Saudi → ID) jauh lebih sedikit digarap dengan UX konsumen yang mulus. Kita tim Indonesia — ini keunggulan konteks & bahasa.
2. **UX "invisible crypto" yang benar-benar tanpa seed phrase.** Banyak solusi masih exchange-first (user harus mikir "beli USDT dulu"). Passkey-first + saldo dolar + off-ramp otomatis masih jarang dieksekusi dengan mulus untuk ritel.
3. **Transparansi biaya sebagai fitur.** Mengingat ~85% user tidak tahu rincian biaya, app yang menampilkan **"kamu kirim X, keluarga terima Y, biaya Z"** secara eksplisit sebelum konfirmasi = diferensiasi kuat.
4. **Segmen spesifik** (mis. pekerja rumah tangga/PMI informal, atau koridor tertentu) yang belum jadi prioritas pemain besar.

> **Untuk demo hackathon, kita tidak perlu mengalahkan MoneyGram.** Kita perlu menunjukkan satu koridor/UX yang dieksekusi lebih baik untuk satu segmen yang jelas. Fokus > cakupan.

---

## 3. Relevansi & Implementasi Stellar

### 3.1 Kenapa Stellar (bukan Ethereum/Solana/Bitcoin)?

Stellar memang **dirancang khusus** untuk pembayaran lintas-batas, bukan komputasi umum:

- **Settlement ~5 detik**, finality cepat (konsensus SCP / Federated Byzantine Agreement).
- **Biaya transaksi sub-sen** (~$0,0007) dan **stabil** — insentif validator tidak mendorong fee spiral saat jaringan ramai. Krusial untuk transfer nominal kecil.
- **USDC native** sudah ada di Stellar sejak Feb 2021 (diterbitkan Circle) — kita tidak perlu deploy stablecoin sendiri untuk demo.
- **Ekosistem remitansi sudah terbukti** (MoneyGram, $4,2 M+ volume) — infrastruktur off-ramp production-grade sudah eksis dan bisa di-tap.

Kontras: fee Ethereum ($5–30/transfer) dan blok Bitcoin (~10 menit, fee variabel) secara ekonomi tidak masuk untuk remitansi ritel.

### 3.2 Building blocks Stellar yang akan kita pakai

**(a) USDC / stablecoin sebagai rel nilai**
- Aset di Stellar adalah objek kelas satu di ledger. USDC bisa langsung dipegang & ditransfer.
- **Stellar Asset Contract (SAC)** memungkinkan aset klasik (USDC dll.) dipakai di smart contract Soroban tanpa re-issue.

**(b) Anchors + Stellar Ecosystem Proposals (SEP) — ini kunci off-ramp**

*Anchor* = jembatan fiat ↔ Stellar (bank, exchange, money transfer operator). Mereka terima setoran fiat lewat rel lokal dan keluarkan token setara di Stellar, atau sebaliknya. SEP yang relevan:

| SEP | Fungsi | Relevansi untuk kita |
|---|---|---|
| **SEP-1** | TOML — deklarasi identitas anchor | Discovery |
| **SEP-10** | Autentikasi Stellar (challenge-response) | Login ke layanan anchor |
| **SEP-12** | KYC API | Compliance |
| **SEP-24** | Hosted deposit/withdrawal (interaktif) | **User cash-in/out tanpa keluar dari app kita** — pengalaman mirip banking app |
| **SEP-31** | Cross-border payments (anchor↔anchor, bank-to-bank) | Model remitansi klasik; user tidak pernah pegang crypto |
| **SEP-38** | RFQ / quote FX | Tampilkan kurs pasti sebelum konfirmasi |

- **SEP-24 vs SEP-31:** SEP-24 = user aktif withdraw saldo digital ke bank/tunai (cocok untuk "wallet" model). SEP-31 = anchor kirim langsung fiat→fiat, user **tidak pernah menyentuh aset digital** (cocok untuk "remittance" model murni). Untuk PS A, **SEP-31 atau SEP-24 keduanya layak** — pilihan tergantung apakah kita mau user pegang saldo dolar (SEP-24) atau benar-benar bank-to-bank (SEP-31).
- **Tooling:** SDF menyediakan **Anchor Platform** dan **Polaris** (app Django) yang menangani sebagian besar business logic SEP — anchor bisa deploy dalam hitungan minggu, bukan bulan. **Untuk hackathon, kita kemungkinan besar tidak membangun anchor sendiri** — kita **integrasi ke anchor/testnet yang sudah ada** (atau mock off-ramp) dan fokus di UX + logic aplikasi.

**(c) Passkey / Smart Wallet — INI jawaban atas "barrier crypto"**

Ini fitur pembeda paling kuat untuk PS A.

- **Protocol 21 Stellar (live 18 Juni 2024)** menambahkan verifikasi native **secp256r1** (CAP-0051) — kurva yang dipakai **WebAuthn/passkey**.
- Artinya smart contract Stellar bisa memverifikasi tanda tangan passkey **on-chain**. User cukup pakai **Face ID / Touch ID / fingerprint** untuk sign transaksi — **tanpa seed phrase, tanpa private key untuk diingat**.
- **Smart wallet** = contract account yang bisa pegang aset & menegakkan aturan (spending limit, allow-list, multi-sig, social recovery, time-lock) di `__check_auth`.
- **Tooling siap pakai:**
  - **Passkey Kit** — SDK TypeScript (client `PasskeyKit` + server `PasskeyServer`) untuk membuat & mengelola smart wallet berbasis passkey.
  - **Launchtube** — layanan relay yang menangani **fee & sequence number** (fee sponsorship / gas abstraction). → User bisa transaksi **tanpa perlu pegang XLM untuk gas**. Kita (app) yang sponsori fee di belakang layar.
  - **Mercury/Zephyr** — indexing event contract agar wallet lebih usable di sisi klien.
- **Bukti sudah production:** ada implementasi passkey-to-Soroban yang berjalan di produksi (mis. Meridian Pay), plus PoC open-source (factory + smart wallet contract, backend Express, frontend React) yang bisa jadi referensi arsitektur.

> **Kenapa ini decisive:** riset UX mana pun bilang seed phrase = pembunuh adopsi. Stellar adalah salah satu L1 dengan **dukungan passkey native di level protokol** (bukan sekadar library pihak ketiga). Ini bukan nice-to-have — ini inti value proposition PS A.

### 3.3 Arsitektur referensi (high-level, untuk didiskusikan)

Alur "terasa seperti transfer bank" yang kita tuju:

```
PENGIRIM (mis. PMI di Malaysia/Taiwan)
  │  buka app → daftar dengan passkey (Face ID), no seed phrase
  │  smart wallet dibuat di background (Passkey Kit)
  ▼
CASH-IN / FUNDING
  │  top-up via kartu/bank/e-wallet lokal → jadi USDC di Stellar
  │  (via anchor SEP-24, atau on-ramp partner)
  ▼
TRANSFER (di Stellar)
  │  USDC pindah wallet→wallet ~5 detik, fee ~sub-sen
  │  fee di-sponsor app via Launchtube (user tak perlu XLM)
  │  UI tampilkan: "Kirim Rp X → Keluarga terima Rp Y → Biaya Z" (transparan)
  ▼
CASH-OUT / OFF-RAMP (sisi Indonesia)
  │  USDC → IDR via anchor/exchange berlisensi (SEP-24/31)
  │  masuk rekening bank / e-wallet penerima (atau tunai)
  ▼
PENERIMA (keluarga di Indonesia)
     terima rupiah di rekening/e-wallet — tidak pernah lihat kata "crypto"
```

**Yang perlu tim putuskan di arsitektur ini:**
- Model **custodial vs non-custodial** (smart wallet passkey cenderung self-custodial tapi bisa dengan recovery — trade-off UX vs tanggung jawab).
- **On-ramp & off-ramp**: pakai anchor existing di testnet, mock, atau partner? (Untuk demo, mock/testnet cukup; untuk narasi, tunjukkan jalur real via anchor SEP.)
- **Custody & recovery**: kalau user kehilangan device/passkey, gimana? (backup signer, social recovery, atau recovery account — perlu didesain).

### 3.4 Mapping fitur Stellar → pain point (ringkas)

| Pain point (Bagian 1) | Fitur Stellar yang menjawab |
|---|---|
| Biaya 5–8% | Transfer sub-sen + off-ramp murah via anchor |
| Settlement 3–5 hari | Settlement ~5 detik, 24/7 |
| Barrier seed phrase (~60% kabur) | **Passkey (Protocol 21) — Face ID, no seed phrase** |
| User tak tahu biaya (~85%) | UI transparansi + SEP-38 quote sebelum konfirmasi |
| Butuh XLM untuk gas | Launchtube fee sponsorship (gas abstraction) |
| Butuh deploy stablecoin | USDC native sudah ada |

---

## 4. Catatan Regulasi (WAJIB dibaca sebelum desain)

Ini bisa membunuh atau menyelamatkan positioning produk. **Baca sebelum menentukan flow.**

### 🇮🇩 Indonesia — batasan paling ketat untuk kita

- Sejak **10 Jan 2025**, pengawasan aset kripto pindah dari **Bappebti → OJK** (GR 49/2024, POJK 27/2024, diamandemen POJK 23/2025). Kripto direklasifikasi sebagai **"aset keuangan digital"** dalam sektor jasa keuangan.
- **Kripto LEGAL untuk diperdagangkan, tapi ILEGAL sebagai alat pembayaran.** UU Mata Uang menetapkan **rupiah satu-satunya alat pembayaran sah**. (Bank Indonesia menegakkan ini.)
- Industri sedang **melobi BI** agar stablecoin diakui untuk pembayaran — **belum terjadi** per data terkini.
- ~**14,16 juta** pengguna kripto terdaftar di Indonesia (April 2025) — pasar besar, tapi dalam koridor "aset", bukan "pembayaran".
- Penerbit stablecoin lokal (jika ada) wajib: **cadangan 1:1, audit real-time, kustodi di bank domestik terdaftar OJK.**

**Implikasi desain (penting!):**
- ❌ **Jangan** posisikan produk sebagai "bayar belanja pakai stablecoin di Indonesia" atau "dompet stablecoin domestik untuk transaksi harian" — itu bertabrakan dengan larangan alat pembayaran.
- ✅ **Posisikan sebagai remitansi lintas-batas + off-ramp ke IDR** lewat **operator/exchange berlisensi**. Nilai masuk sebagai valuta asing → dikonversi → keluar sebagai **rupiah** di rekening/e-wallet penerima. Ini jalur yang lazim & compliant.
- ✅ Untuk demo, boleh tunjukkan mekanisme; untuk narasi produk nyata, sebutkan **kemitraan dengan VASP/MTO berlisensi** sebagai jalur go-to-market.

### 🇵🇭 Filipina — paling ramah

- **BSP** punya kerangka VASP (Circular 944 sejak 2017; guidelines VASP 2021). Banyak exchange berlisensi (Coins.ph, PDAX, Maya).
- Stablecoin peso **PHPC** sudah di-approve; **pembayaran QRPh pakai stablecoin sudah live** via Coins.ph.
- → Kalau tim mau koridor dengan hambatan regulasi paling rendah untuk sisi penerima, **Filipina paling matang**. Tapi juga paling kompetitif.

### 🇻🇳 Vietnam

- Transfer USDT informal sudah marak untuk remitansi. Pemerintah **berencana memformalkan** kerangka aset virtual di **2026** — masih bergerak.

> **Rekomendasi regulasi:** untuk hackathon, pilih **satu koridor utama** dan sebutkan asumsi regulasinya secara eksplisit di slide. Jangan klaim bisa "bayar pakai crypto di mana saja di ASEAN" — itu tidak akurat dan juri teknis/regulator akan menangkapnya.

---

## 5. Risiko & Pertanyaan Terbuka

**Risiko yang perlu dijawab tim:**
1. **Regulasi off-ramp Indonesia** — apakah kita andalkan partner VASP berlisensi, atau posisikan sebagai infra yang plug ke mereka? (Menentukan narasi go-to-market.)
2. **Custody & recovery passkey** — device hilang = akses hilang? Perlu desain recovery (social recovery / backup signer / recovery account).
3. **KYC/AML** — remitansi lintas-batas selalu kena KYC/AML. Untuk demo boleh disimulasikan (SEP-12), tapi harus disebut di arsitektur.
4. **Likuiditas off-ramp** — siapa yang menyediakan IDR di ujung? (anchor/exchange). Untuk demo, mock; untuk produk, ini hard problem.
5. **Base reserve Stellar** — tiap akun/trustline butuh cadangan 0,5 XLM per "entry". Perlu diperhitungkan dalam desain funding akun user (bisa di-sponsor app).
6. **Kompetisi** — MoneyGram & Coins.ph sudah kuat. Diferensiasi kita **harus** tajam di satu dimensi (koridor ID, UX passkey, atau transparansi biaya).

**Pertanyaan untuk tim jawab sebelum lanjut (lihat Bagian 6):** koridor, segmen, dan scope demo.

---

## 6. Rekomendasi Scope Hackathon & Next Steps

### Scope demo yang realistis (jangan overbuild)

Untuk hackathon, **jangan** bangun anchor + off-ramp production. Fokus ke yang paling berkesan & feasible:

**Must-have (inti value proposition):**
- ✅ **Onboarding passkey** (Face ID/Touch ID, no seed phrase) → smart wallet dibuat di background. **Ini demo money-shot-nya.**
- ✅ **Transfer USDC di Stellar testnet** ~5 detik, fee di-sponsor (Launchtube) → user tak pegang XLM.
- ✅ **UI transparansi biaya** ("kirim X → terima Y → biaya Z") sebelum konfirmasi.
- ✅ Simulasi/mock **off-ramp ke IDR** (tampilkan penerima terima "rupiah", bukan crypto).

**Nice-to-have (kalau waktu cukup):**
- Integrasi anchor SEP-24 di testnet (real off-ramp flow).
- Social recovery / backup signer untuk passkey.
- Kurs real via SEP-38 quote.

**Explicitly out-of-scope (sebutkan sebagai "future work"):**
- Lisensi VASP/MTO, anchor production, likuiditas IDR real, KYC/AML penuh.

### Stack yang disarankan (nyambung dengan keahlian tim)

- **Frontend:** React/TypeScript (sesuai stack yang sudah kalian kuasai) + Passkey Kit (TS SDK).
- **Backend:** Node/Express untuk PasskeyServer + relay Launchtube.
- **Contract:** smart wallet Soroban (Rust) — bisa mulai dari PoC factory + wallet yang sudah ada, jangan tulis dari nol.
- **Network:** Stellar Testnet/Futurenet.

### Next steps — keputusan yang saya butuhkan dari tim

Sebelum saya lanjut ke **breakdown arsitektur teknis detail + rencana build 48 jam**, tolong konfirmasi:

1. **Koridor utama demo?**
   - (a) **Malaysia/Taiwan/HK → Indonesia** (paling relevan buat kita, koridor under-served)
   - (b) **Timur Tengah/Singapura → Indonesia**
   - (c) **→ Filipina** (paling matang tapi paling kompetitif)
   - (d) Fleksibel / belum tahu

2. **Segmen target spesifik?**
   - (a) PMI sektor domestik/informal (pekerja rumah tangga dll.)
   - (b) Pekerja terampil/profesional diaspora
   - (c) Umum (semua pengirim ritel)

3. **Diferensiasi utama yang mau kita tonjolkan ke juri?**
   - (a) **UX "invisible crypto"** (passkey, no seed phrase) — paling kuat secara demo
   - (b) **Biaya termurah + transparansi**
   - (c) **Koridor Indonesia yang under-served**
   - (d) Kombinasi

4. **Ambisi scope demo:** MVP inti saja (must-have di atas), atau dorong sampai integrasi anchor real di testnet?

Begitu keempat ini terjawab, saya susun: arsitektur teknis detail per komponen, pembagian tugas, milestone per jam, dan daftar resource/dokumentasi Stellar yang perlu dipelajari tiap orang.

---

## Sumber

**Data remitansi & masalah**
- World Bank — Remittance Prices Worldwide, Issue 54 (Q3 2025): https://remittanceprices.worldbank.org/
- World Bank Blog — biaya remitansi >3% di 28 negara: https://blogs.worldbank.org/en/opendata/the-cost-of-sending-remittances-is-higher-than-3--in-28-countrie
- BSP / Philippine News Agency — remitansi OFW rekor 2025: https://www.pna.gov.ph/articles/1269149
- BusinessWorld — OFW remittances $35,6 M (pajak AS 1%): https://bworldonline.com/top-stories/2026/02/17/730931/ofw-remittances-hit-record-35-6b/
- World Bank — Migration & Development Brief (proyeksi ID/VN): https://documents1.worldbank.org/curated/en/099714008132436612/pdf/IDU1a9cf73b51fcad1425a1a0dd1cc8f2f3331ce.pdf
- Vietnam Plus — remitansi HCMC $10,3 M 2025: https://en.vietnamplus.vn/remittances-to-ho-chi-minh-city-exceed-103-billion-usd-in-2025-post336515.vnp
- Vietnam.vn — $6–7 M/tahun dari pekerja Vietnam: https://www.vietnam.vn/en/6-7-ty-usd-kieu-hoi-moi-nam-tu-lao-dong-viet-nam-o-nuoc-ngoai
- BNI/VOI — PMI, Bekasi sebagai wilayah penerima: https://voi.id/hi/amp/483138
- IOM — survei remitansi pekerja migran Indonesia (transparansi biaya): https://publications.iom.int/system/files/pdf/indonesia_remittances.pdf
- Ken Research — pasar remitansi Indonesia ~$18 M: https://www.kenresearch.com/indonesia-remittance-money-transfer-market

**Barrier UX Web3**
- ( Diringkas dari riset onboarding Web3: ~60% kabur di seed phrase, >90% hilang sebelum transaksi pertama — Digitap, Cobo, Sequence; lihat chat riset sebelumnya)

**Existing solutions / kompetitor**
- Stellar — studi kasus MoneyGram: https://stellar.org/case-studies/moneygram-international
- Stellar — MoneyGram Ramps: https://stellar.org/products-and-tools/moneygram
- ChainGain — MoneyGram + Stellar 2026 (perbandingan biaya): https://chaingain.io/moneygram-stellar-crypto-remittance-2026/
- Eco/Support — evolusi crypto MoneyGram → MGUSD (Juni 2026): https://eco.com/support/en/articles/15346499-moneygram-crypto-how-moneygram-integrates-digital-currencies
- Coins.ph — stablecoin remittance: https://www.coins.ph/en-ph/blog/coins-ph-and-the-stablecoin-advantage-5-ways-stablecoin-remittances-are-revolutionizing-cross-border-payments
- BitPinas — Coins.ph + Remitly: https://bitpinas.com/business/coins-ph-remitly
- RebelFi — stablecoin payments SEA (koridor & pemain): https://rebelfi.io/blog/stablecoin-payments-southeast-asia-yield-corridors

**Teknis Stellar**
- Stellar Docs — Anchors & SEP: https://developers.stellar.org/docs/learn/fundamentals/anchors
- Stellar — fiat on/off-ramp & cross-border (SEP-24 vs SEP-31, Polaris): https://stellar.org/blog/ecosystem/fiat-on-off-ramps-and-cross-border-payments-on-stellar
- Stellar Docs — Smart Wallets (passkey, secp256r1): https://developers.stellar.org/docs/build/guides/contract-accounts/smart-wallets
- Stellar — Protocol 21 live (secp256r1/passkey): https://stellar.org/blog/developers/protocol-21-is-live-on-stellar-mainnet
- Stellar — smart wallet & passkey overview: https://stellar.org/learn/crypto-smart-contract-wallets
- Cheesecake Labs — build passkey smart wallet di Stellar (PoC): https://cheesecakelabs.com/blog/building-a-passkey-enabled-smart-wallet-on-the-stellar-network/

**Regulasi**
- ADCO Law — arah regulasi kripto Indonesia (Bappebti→OJK): https://adcolaw.com/blog/the-direction-of-crypto-asset-regulation-in-indonesia-following-the-transfer-of-supervisory-authority-from-bappebti-to-the-ojk/
- Lightspark — status legal crypto Indonesia (larangan alat bayar): https://www.lightspark.com/knowledge/is-crypto-legal-in-indonesia
- HBT Law — OJK ambil alih pengawasan aset digital: https://www.hbtlaw.com/insights/2025-05/ojk-assumes-regulatory-oversight-digital-financial-assets
- Pintu Academy — stablecoin & regulasi Indonesia 2026: https://pintu.co.id/en/academy/post/the-future-of-stablecoins-in-2026-latest-marketcap-and-regulatory-data
- Tranglo — digital currency & remittance Filipina (PHPC/BSP): https://www.tranglo.com/blog/the-state-of-digital-currency-and-remittance-in-the-philippines/

---
*Catatan: sebagian angka (mis. pajak remitansi AS, regulasi Vietnam 2026, MGUSD) berasal dari perkembangan yang bergerak cepat — verifikasi ulang sebelum dipakai di materi final/pitch. Dokumen ini bukan nasihat hukum; untuk go-to-market nyata, konsultasikan status lisensi VASP/MTO dengan ahli hukum.*
