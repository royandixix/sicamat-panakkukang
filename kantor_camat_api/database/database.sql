CREATE DATABASE IF NOT EXISTS sicamat_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sicamat_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS cluster_members;
DROP TABLE IF EXISTS cluster_runs;
DROP TABLE IF EXISTS disposisi;
DROP TABLE IF EXISTS pengajuan;
DROP TABLE IF EXISTS surat;
DROP TABLE IF EXISTS kegiatan;
DROP TABLE IF EXISTS layanan;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS profil_kecamatan;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE profil_kecamatan (
  id INT PRIMARY KEY,
  nama_instansi VARCHAR(150) NOT NULL,
  alamat TEXT NOT NULL,
  telepon VARCHAR(30),
  email VARCHAR(120),
  jam_layanan VARCHAR(200),
  visi TEXT,
  misi TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash CHAR(64) NOT NULL,
  role VARCHAR(20) NOT NULL,
  kelurahan VARCHAR(100),
  seksi VARCHAR(150),
  no_hp VARCHAR(30),
  aktif TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_users_role (role),
  CHECK (role IN ('kasubag', 'camat', 'seksi', 'warga'))
) ENGINE=InnoDB;

CREATE TABLE sessions (
  token VARCHAR(128) PRIMARY KEY,
  user_id INT NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_sessions_user (user_id),
  INDEX idx_sessions_expiry (expires_at)
) ENGINE=InnoDB;

CREATE TABLE layanan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(180) NOT NULL,
  sektor VARCHAR(150),
  deskripsi TEXT,
  persyaratan TEXT,
  estimasi_hari INT NOT NULL DEFAULT 1,
  biaya DECIMAL(14,2) NOT NULL DEFAULT 0,
  aktif TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE kegiatan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  judul VARCHAR(200) NOT NULL,
  isi TEXT,
  tanggal DATE NOT NULL,
  lokasi VARCHAR(200),
  publikasi TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_kegiatan_tanggal (tanggal)
) ENGINE=InnoDB;

CREATE TABLE surat (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nomor_surat VARCHAR(150) NOT NULL UNIQUE,
  jenis VARCHAR(20) NOT NULL,
  perihal TEXT NOT NULL,
  pengirim VARCHAR(180) NOT NULL,
  tujuan VARCHAR(180) NOT NULL,
  tanggal_surat DATE NOT NULL,
  tanggal_diterima DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'baru',
  file_url TEXT,
  cluster_no INT NULL,
  cluster_label VARCHAR(250) NULL,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_surat_creator FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_surat_jenis (jenis),
  INDEX idx_surat_status (status),
  INDEX idx_surat_tanggal (tanggal_surat),
  FULLTEXT INDEX ft_surat_perihal (perihal)
) ENGINE=InnoDB;

CREATE TABLE disposisi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  surat_id INT NOT NULL,
  dari_user_id INT NOT NULL,
  ke_user_id INT NOT NULL,
  catatan TEXT,
  batas_waktu DATE,
  status VARCHAR(30) NOT NULL DEFAULT 'dikirim',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_disposisi_surat FOREIGN KEY (surat_id) REFERENCES surat(id) ON DELETE CASCADE,
  CONSTRAINT fk_disposisi_dari FOREIGN KEY (dari_user_id) REFERENCES users(id),
  CONSTRAINT fk_disposisi_kepada FOREIGN KEY (ke_user_id) REFERENCES users(id),
  INDEX idx_disposisi_penerima (ke_user_id, status)
) ENGINE=InnoDB;

CREATE TABLE pengajuan (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kode VARCHAR(40) NOT NULL UNIQUE,
  user_id INT NOT NULL,
  layanan_id INT NOT NULL,
  judul VARCHAR(200) NOT NULL,
  deskripsi TEXT NOT NULL,
  lokasi VARCHAR(200),
  tanggal_mulai DATE NULL,
  tanggal_selesai DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'diajukan',
  catatan_petugas TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pengajuan_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_pengajuan_layanan FOREIGN KEY (layanan_id) REFERENCES layanan(id),
  INDEX idx_pengajuan_status (status),
  INDEX idx_pengajuan_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE cluster_runs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  k_value INT NOT NULL,
  jumlah_data INT NOT NULL,
  silhouette DECIMAL(10,6) NOT NULL DEFAULT 0,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cluster_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE cluster_members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  run_id INT NOT NULL,
  surat_id INT NOT NULL,
  cluster_no INT NOT NULL,
  cluster_label VARCHAR(250) NOT NULL,
  distance DECIMAL(16,10) NOT NULL,
  CONSTRAINT fk_cluster_run FOREIGN KEY (run_id) REFERENCES cluster_runs(id) ON DELETE CASCADE,
  CONSTRAINT fk_cluster_surat FOREIGN KEY (surat_id) REFERENCES surat(id) ON DELETE CASCADE,
  UNIQUE KEY uq_run_surat (run_id, surat_id)
) ENGINE=InnoDB;

INSERT INTO profil_kecamatan
(id, nama_instansi, alamat, telepon, email, jam_layanan, visi, misi)
VALUES
(1, 'Kantor Camat Panakkukang',
 'Jalan Batua Raya No. 168, Kelurahan Paropo, Kecamatan Panakkukang, Kota Makassar',
 '(0411) 000000', 'panakkukang@makassarkota.go.id',
 'Senin–Jumat, 08.00–16.00 WITA',
 'Terwujudnya pelayanan kecamatan yang profesional, transparan, dan responsif.',
 'Meningkatkan kualitas pelayanan publik; memperkuat tata kelola administrasi; serta menyediakan akses informasi yang mudah bagi masyarakat.')
ON DUPLICATE KEY UPDATE nama_instansi = VALUES(nama_instansi);

INSERT INTO users
(id, nama, email, password_hash, role, kelurahan, seksi, no_hp, aktif)
VALUES
(1, 'Kasubag Umum', 'kasubag@sicamat.local', SHA2('Sicamat123!', 256), 'kasubag', 'Panakkukang', 'Subbagian Umum', '081200000001', 1),
(2, 'Camat Panakkukang', 'camat@sicamat.local', SHA2('Sicamat123!', 256), 'camat', 'Panakkukang', 'Pimpinan Kecamatan', '081200000002', 1),
(3, 'Seksi Pemerintahan', 'pemerintahan@sicamat.local', SHA2('Sicamat123!', 256), 'seksi', 'Panakkukang', 'Seksi Pemerintahan', '081200000003', 1),
(4, 'Seksi Ketenteraman', 'trantib@sicamat.local', SHA2('Sicamat123!', 256), 'seksi', 'Panakkukang', 'Seksi Ketenteraman dan Ketertiban', '081200000004', 1),
(5, 'Graciel Eivrilia Tanan', 'warga@sicamat.local', SHA2('Sicamat123!', 256), 'warga', 'Paropo', NULL, '081200000005', 1);

INSERT INTO layanan
(id, nama, sektor, deskripsi, persyaratan, estimasi_hari, biaya, aktif)
VALUES
(1, 'Surat Keterangan Domisili', 'Pemerintahan', 'Pengajuan surat keterangan domisili warga.', 'KTP; KK; surat pengantar RT/RW.', 2, 0, 1),
(2, 'Surat Keterangan Usaha', 'Perekonomian dan Pembangunan', 'Pengajuan surat keterangan usaha untuk kebutuhan administrasi.', 'KTP; KK; foto lokasi usaha; surat pengantar kelurahan.', 3, 0, 1),
(3, 'Rekomendasi Izin Kegiatan', 'Ketenteraman dan Ketertiban', 'Permohonan rekomendasi pelaksanaan kegiatan di wilayah kecamatan.', 'KTP penanggung jawab; proposal kegiatan; surat persetujuan lokasi.', 5, 0, 1),
(4, 'Legalisasi Dokumen', 'Pelayanan Umum', 'Legalisasi dokumen administrasi yang menjadi kewenangan kecamatan.', 'Dokumen asli dan salinan; KTP pemohon.', 1, 0, 1),
(5, 'Pengaduan Pelayanan Publik', 'Pelayanan Umum', 'Penyampaian pengaduan terkait pelayanan dan fasilitas kecamatan.', 'Identitas pelapor; uraian dan bukti pendukung.', 3, 0, 1);

INSERT INTO kegiatan
(id, judul, isi, tanggal, lokasi, publikasi)
VALUES
(1, 'Pelayanan Administrasi Terpadu', 'Pelayanan administrasi bagi warga dari sebelas kelurahan di Kecamatan Panakkukang.', CURDATE(), 'Kantor Camat Panakkukang', 1),
(2, 'Rapat Koordinasi Kebersihan Wilayah', 'Koordinasi bersama kelurahan untuk peningkatan kebersihan dan pertamanan.', DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Aula Kecamatan Panakkukang', 1);

INSERT INTO surat
(id, nomor_surat, jenis, perihal, pengirim, tujuan, tanggal_surat, tanggal_diterima, status, created_by)
VALUES
(1, '001/PEM/VII/2026', 'masuk', 'Permohonan data penduduk dan administrasi pemerintahan kelurahan', 'Kelurahan Paropo', 'Seksi Pemerintahan', '2026-07-01', '2026-07-02', 'baru', 1),
(2, '002/TRANTIB/VII/2026', 'masuk', 'Permohonan pengamanan dan izin keramaian kegiatan masyarakat', 'Panitia Kegiatan Warga', 'Seksi Ketenteraman dan Ketertiban', '2026-07-02', '2026-07-03', 'baru', 1),
(3, '003/EKBANG/VII/2026', 'masuk', 'Permohonan rekomendasi usaha mikro dan pendataan pelaku usaha', 'Kelurahan Masale', 'Seksi Perekonomian dan Pembangunan', '2026-07-03', '2026-07-04', 'baru', 1),
(4, '004/PEM/VII/2026', 'masuk', 'Permintaan laporan administrasi kependudukan dan data kelurahan', 'Dinas Kependudukan', 'Seksi Pemerintahan', '2026-07-04', '2026-07-05', 'baru', 1),
(5, '005/TRANTIB/VII/2026', 'masuk', 'Koordinasi ketertiban wilayah dan pengamanan acara masyarakat', 'Satpol PP Kota Makassar', 'Seksi Ketenteraman dan Ketertiban', '2026-07-05', '2026-07-06', 'baru', 1),
(6, '006/EKBANG/VII/2026', 'masuk', 'Pendataan usaha kecil dan program pemberdayaan ekonomi masyarakat', 'Dinas Koperasi dan UMKM', 'Seksi Perekonomian dan Pembangunan', '2026-07-06', '2026-07-07', 'baru', 1),
(7, '007/UMUM/VII/2026', 'keluar', 'Penyampaian jadwal pelayanan administrasi Kecamatan Panakkukang', 'Kantor Camat Panakkukang', 'Seluruh Kelurahan', '2026-07-07', '2026-07-07', 'selesai', 1);

INSERT INTO pengajuan
(id, kode, user_id, layanan_id, judul, deskripsi, lokasi, tanggal_mulai, tanggal_selesai, status)
VALUES
(1, 'PGJ-20260713-2250', 5, 3, 'Rekomendasi Kegiatan Penelitian',
 'Permohonan rekomendasi kegiatan penelitian pada Kantor Camat Panakkukang.',
 'Kantor Camat Panakkukang', '2026-07-13', '2026-09-30', 'diajukan');
