# Hospital Management Database System

## 📚 Proje Açıklaması

Bu proje, hastane yönetim sistemine yönelik kapsamlı bir veritabanı yapısı sunmaktadır. SQL komutlarıyla çeşitli tablolar, ilişkiler, görünüm (view) tanımlamaları ve tetikleyiciler (trigger) oluşturulmuştur. Amaç; doktorlar, hastalar, hastaneler ve randevular arasında organize bir veri bütünlüğü ve otomasyon sağlamaktır.

## 🧩 Tablolar

- **PATIENT**: Hastaların temel bilgilerini tutar (ID, yaş, cinsiyet, ad, notlar).
- **DOCTOR**: Doktorlara ait kimlik ve uzmanlık bilgilerini içerir.
- **HOSPITAL**: Hastane adları, adresleri ve iletişim bilgileri gibi detayları içerir.
- **APPOINTMENT**: Randevularla ilgili bilgiler içerir ve doktor, hasta, hastane gibi diğer tablolara bağlıdır.
- **MEDICAL_RECORD**: Hastalara ait muayene geçmişi, hastalık ve ilaç bilgilerini tutar.
- **AUDIT_LOG**: Tetikleyiciler yardımıyla yapılan işlem kayıtlarını saklar.
- **NOTIFICATION**: Hastalara veya doktorlara gönderilen bildirim mesajlarını kaydeder.

## 🔗 Foreign Key Kısıtlamaları

- `appointment` tablosu; `doctor`, `patient` ve `hospital` tablolarına çeşitli sütunlar üzerinden foreign key bağları içerir.
- ON DELETE ve ON UPDATE CASCADE seçenekleriyle referanslı verilerdeki değişimlerin bağlı tablolara yansıması sağlanır.

## 👁 Oluşturulan Görünümler (Views)

- `Doctor_Patient_Info`: Doktorların kendilerine ait hastaları ve randevu bilgilerini görmesini sağlar.
- `Patient_Medical_Records`: Hastaların geçmiş muayene kayıtlarını listeleyen bir görünüm.
- `Patient_Appointments`: Hastaların geçmiş ve mevcut randevularını gösterir.
- `Hospital_Overview`: Hastane yöneticilerinin, ilgili hastane bünyesindeki doktorları ve hastaları görebileceği genel bir rapor.

## 🔔 Tetikleyiciler (Triggers)

- `AfterMedicalRecordInsert`: Yeni bir kayıt eklendiğinde `Audit_Log` tablosuna log düşer.
- `AfterAppointmentInsert`: Randevu oluşturulduğunda hastaya bildirim gönderilir.
- `AfterDoctorInsert`: Yeni doktor eklendiğinde doktor adına hoş geldin mesajı oluşturulur.
- `AfterDoctorDelete`: Doktor silindiğinde veda mesajı oluşturulur.
