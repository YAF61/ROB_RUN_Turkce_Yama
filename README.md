# ROB RUN — Türkçe Yama (YAF Sürümü & %100 Açık Kaynak)

ROB RUN için Easy Anti-Cheat (EAC) korumasını tetiklemeyen, oyun ana dizinindeki orijinal dosyaları bozmayan, **.EXE veya Python gerektirmeyen**, **YAF** tarafından düzenlenmiş ve optimize edilmiş %100 açık kaynaklı Türkçe yama projesi.

---

## 🌟 Özellikler

- **Geliştirici / Düzenleyen:** **YAF**
- **.EXE veya Python Gerektirmez:** Windows yerleşik altyapısıyla çalışır; harici hiçbir program veya şüpheli çalıştırılabilir dosya içermez. Kodların tamamı `.bat` ve `.ps1` olarak incelenebilir.
- **EAC Güvenli:** Oyunun Steam dosyalarının üzerine yazmaz. Unity Addressables sisteminin yerel önbellek yönlendirmesini (`%USERPROFILE%\AppData\LocalLow\Kefir\ROB RUN\YAF_TRMod`) kullanır.
- **Düzeltilmiş ve Eksiksiz Çeviri:** 
  - Yükleme ekranlarındaki imla ve karakter hataları giderildi.
  - Menü, arayüz, eşya ve sistem metinleri baştan sona kontrol edildi.
  - Türkçe karakter desteği (ç, ğ, ı, ö, ş, ü, İ) tam font entegrasyonuyla sağlandı.
  - Oyun içi dil ayarlarında ve yükleme adımlarında özel Türkçe entegrasyonu yapıldı.
- **Tek Tıkla Kurulum & Kaldırma:** Dilediğiniz an tek tıkla orijinal İngilizce haline döndürebilirsiniz.

---

## 📥 Kurulum

1. Bu depoyu (veya en son **Releases** zip dosyasını) indirin ve bir klasöre çıkartın.
2. Klasör içindeki **`Yamayi_Kur.bat`** dosyasına çift tıklayın.
   *(Alternatif olarak menü üzerinden işlem yapmak isterseniz **`Yama_Menusu.bat`** dosyasını da açabilirsiniz).*
3. Kurulum aracı Steam kütüphanenizdeki oyunu otomatik olarak tespit edecek ve yamayı birkaç saniyede uygulayacaktır.
4. "Türkçe Yama (YAF Sürümü) başarıyla kuruldu" mesajını gördükten sonra oyunu Steam üzerinden doğrudan başlatabilirsiniz.

---

## 🗑️ Kaldırma (Orijinal Haline Dönüş)

Yamayı dilediğiniz zaman kaldırmak için:
- **`Yamayi_Kaldir.bat`** dosyasına çift tıklamanız yeterlidir.
- Oyun dosyalarınız Steam'den dosya doğrulamaya ihtiyaç duymadan anında orijinal haline döner.

---

## 📁 Proje Yapısı

```text
├── Yamayi_Kur.bat           # Tek tıkla Türkçe yama kurulumu (YAF)
├── Yamayi_Kaldir.bat        # Tek tıkla orijinal haline dönüş
├── Yama_Menusu.bat          # Etkileşimli yönetim menüsü
├── install_patch.ps1        # Açık kaynak PowerShell kurucu betiği
├── BeniOku.txt              # Kullanıcı bilgilendirme notu
├── Gorseller/               # Oyun logosu ve ikon
└── Yama_Dosyalari/          # Türkçe metin ve font AssetBundle paketleri
```

---

## 📄 Lisans
Bu proje açık kaynaklıdır ve topluluk kullanımı için hazırlanmıştır.
Düzenleme & Paketleme: **YAF**
