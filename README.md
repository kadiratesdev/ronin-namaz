<div align="center">

# 🕌 Ronin Namaz Sistemi

**Gelişmiş Namaz Sistemi — FiveM / QBCore / Standalone**

[![Version](https://img.shields.io/badge/Version-1.0.0-gold?style=flat-square)](https://github.com/kadiratesdev/ronin-namaz)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-blue?style=flat-square&logo=fivem)](https://fivem.net)
[![QBCore](https://img.shields.io/badge/QBCore-Destekliyor-green?style=flat-square)](https://github.com/qbcore-framework)

</div>

---

## 📋 Özellikler

- ✅ **Oyun Saatine Göre Vakit Belirleme** — Sabah, Öğle, İkindi, Akşam, Yatsı vakitleri otomatik hesaplanır.
- ✅ **rpemotes Bağımsız** — Tüm namaz animasyonları (`smo@prayer_posepack`) script içinde `stream` olarak gelir, harici bağımlılık yoktur.
- ✅ **Kesintisiz Animasyon Geçişleri** — `TaskPlayAnim` ile animasyonlar arasında takılma/ayakta kalma olmaz.
- ✅ **Takbir ile Başlama** — Namaz "Allahu Ekber" (Takbir) ile başlar, doğru sırayla devam eder.
- ✅ **Otomatik & Manuel İlerleme** — Otomatik modda adımlar kendi kendine geçer, isterseniz manuel kontrol edebilirsiniz.
- ✅ **Hatırlatıcı Sistemi** — Vakit yaklaştığında veya geçmeye yakın ekran bildirimi alırsınız.
- ✅ **Namaz Hatırlatıcı Ayarları** — Hangi vakitlerde, kaç dakika önce hatırlatma alacağınızı localStorage'da kaydederek özelleştirebilirsiniz.
- ✅ **X ile İptal** — Namaz sırasında `X` tuşuna basarak anında iptal edebilirsiniz.
- ✅ **Kompakt NUI** — Küçük, şeffaf, modern arayüz. Namaz sırasında karakterinizi izleyebilirsiniz.
- ✅ **Rekât Sıralaması** — Farz, Sünnet, Son Sünnet ve Vitir seçenekleri ile doğru rekât sayısı.
- ✅ **Çift Yönlü Selam** — Namaz bitiminde sağa ve sola selam verilir.

---

## 📺 Tanıtım Videosu

<div align="center">

[![Ronin Namaz - Tanıtım Videosu](https://img.youtube.com/vi/vAf2-Na2GUs/0.jpg)](https://www.youtube.com/watch?v=vAf2-Na2GUs)

**[▶ YouTube'da İzle](https://www.youtube.com/watch?v=vAf2-Na2GUs)**

</div>

---

## 🚀 Kurulum

1. Bu repoyu indirin veya klonlayın:
   ```bash
   git clone https://github.com/kadiratesdev/ronin-namaz.git
   ```

2. `ronin-namaz` klasörünü sunucunuzun `resources` dizinine atın.

3. `server.cfg` veya `resources.cfg` dosyanıza şunu ekleyin:
   ```cfg
   ensure ronin-namaz
   ```

4. Sunucuyu restartlayın. Hepsi bu kadar! 🎉

---

## 🎮 Kullanım

| Komut | Açıklama |
|-------|----------|
| `/namaz` | Namaz menüsünü açar / kapatır |
| `X` | Namaz sırasında iptal eder |
| `ESC` | NUI'yi kapatır (namaz devam eder) |

### Namaz Akışı

1. `/namaz` yazın.
2. O anki vakit otomatik seçili gelir, isterseniz başka vakit seçin.
3. Farz / Sünnet / Vitir seçin.
4. **Namaza Başla** butonuna basın.
5. NUI otomatik kapanır, animasyonlar arka planda devam eder.
6. Tekrar `/namaz` yazarak kaldığınız yeri görebilirsiniz.

---

## ⚙️ Hatırlatıcı Ayarları

Menüdeki ⚙️ (Ayarlar) butonuna basarak:
- Hatırlatmaları açıp kapatabilirsiniz.
- Vakit başlamadan kaç dakika önce hatırlatılacağını ayarlayabilirsiniz.
- Vakit bitmeden kaç dakika önce hatırlatılacağını ayarlayabilirsiniz.
- Hangi vakitlerde hatırlatma alacağınızı tek tek seçebilirsiniz.

> Tüm ayarlar tarayıcı `localStorage`'ında saklanır, sunucudan çıksanız bile korunur.

---

## 📁 Dosya Yapısı

```
ronin-namaz/
├── client/
│   └── main.lua          # Client mantığı, NUI iletişimi
├── server/
│   └── main.lua          # Server loglama
├── html/
│   ├── index.html        # NUI arayüzü
│   ├── style.css         # Arayüz stilleri
│   └── app.js            # Arayüz mantığı
├── stream/
│   └── smo@prayer_posepack_*.ycd  # Namaz animasyonları (21 adet)
├── config.lua            # Vakitler, rekât sayıları, süreler
├── fxmanifest.lua        # Resource manifest
└── README.md             # Bu dosya
```

---

## 🛠️ Gereksinimler

| Gereksinim | Zorunlu | Not |
|------------|---------|-----|
| FiveM / RedM | ✅ | CFX Platform |
| QBCore | ❌ | Opsiyonel, bildirimler için kullanılır |
| rpemotes | ❌ | **Artık gerekmez**, animasyonlar script içindedir |

---

## 🧑‍💻 Geliştirici

**kadiratesdev**

- GitHub: [@kadiratesdev](https://github.com/kadiratesdev)
- Repo: [github.com/kadiratesdev/ronin-namaz](https://github.com/kadiratesdev/ronin-namaz)

---

## 📄 Lisans

Bu proje açık kaynaklıdır. İstediğiniz gibi kullanabilir, değiştirebilir ve paylaşabilirsiniz.

---

<div align="center">

**Allah kabul etsin.** 🤲

</div>
