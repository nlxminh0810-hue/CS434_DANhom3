-- SoccerHub / SQL Server 2016 SP1+. Chay trong database duoc chon boi install.ps1.
SET XACT_ABORT ON;
SET NOCOUNT ON;
IF OBJECT_ID(N'dbo.VaiTro', N'U') IS NOT NULL
BEGIN
    IF (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo') AND name IN
        ('VaiTro','NguoiDung','DanhMuc','SanPham','HinhAnhSanPham','GioHang',
         'ChiTietGioHang','DonHang','ChiTietDonHang','ThanhToan','DanhGia')) <> 11
        THROW 51000, N'Schema chưa đầy đủ. Không tự động ghi đè database hiện có.', 1;
    RETURN;
END;
BEGIN TRANSACTION;
CREATE TABLE dbo.VaiTro (
    MaVT INT IDENTITY(1,1) CONSTRAINT PK_VaiTro PRIMARY KEY,
    TenVaiTro NVARCHAR(50) NOT NULL CONSTRAINT UQ_VaiTro_Ten UNIQUE,
    CONSTRAINT CK_VaiTro_Ten CHECK (LEN(LTRIM(RTRIM(TenVaiTro))) > 0)
);
CREATE TABLE dbo.NguoiDung (
    MaND INT IDENTITY(1,1) CONSTRAINT PK_NguoiDung PRIMARY KEY,
    TenDN VARCHAR(50) NOT NULL CONSTRAINT UQ_NguoiDung_TenDN UNIQUE,
    Email VARCHAR(100) NOT NULL CONSTRAINT UQ_NguoiDung_Email UNIQUE,
    MatKhau VARCHAR(255) NOT NULL,
    SoDT VARCHAR(15) NOT NULL,
    DiaChi NVARCHAR(255) NULL,
    NgayTao DATE NOT NULL CONSTRAINT DF_NguoiDung_Ngay DEFAULT CONVERT(DATE,GETDATE()),
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_NguoiDung_TrangThai DEFAULT N'Hoạt động',
    MaVT INT NOT NULL CONSTRAINT FK_NguoiDung_VaiTro REFERENCES dbo.VaiTro(MaVT),
    HoTen NVARCHAR(100) NULL,
    NgaySinh DATE NULL,
    GioiTinh NVARCHAR(10) NULL,
    TieuSu NVARCHAR(500) NULL,
    CONSTRAINT CK_NguoiDung_Ten CHECK (LEN(LTRIM(RTRIM(TenDN))) > 0),
    CONSTRAINT CK_NguoiDung_Email CHECK (Email LIKE '%_@_%._%' AND Email NOT LIKE '% %'),
    CONSTRAINT CK_NguoiDung_SoDT CHECK (LEN(SoDT) BETWEEN 9 AND 15 AND SoDT NOT LIKE '%[^0-9+]%'),
    CONSTRAINT CK_NguoiDung_MatKhau CHECK (LEN(MatKhau) >= 60),
    CONSTRAINT CK_NguoiDung_TrangThai CHECK (TrangThai IN (N'Hoạt động',N'Đã khóa',N'Đã xóa')),
    CONSTRAINT CK_NguoiDung_GioiTinh CHECK (GioiTinh IN (N'Nam',N'Nữ',N'Khác'))
);
CREATE TABLE dbo.DanhMuc (
    MaDM INT IDENTITY(1,1) CONSTRAINT PK_DanhMuc PRIMARY KEY,
    TenDM NVARCHAR(100) NOT NULL CONSTRAINT UQ_DanhMuc_Ten UNIQUE,
    MoTa NVARCHAR(255) NULL,
    CONSTRAINT CK_DanhMuc_Ten CHECK (LEN(LTRIM(RTRIM(TenDM))) > 0)
);
CREATE TABLE dbo.SanPham (
    MaSP INT IDENTITY(1,1) CONSTRAINT PK_SanPham PRIMARY KEY,
    TenSP NVARCHAR(150) NOT NULL,
    Gia DECIMAL(18,2) NOT NULL,
    SoLuong INT NOT NULL CONSTRAINT DF_SanPham_SoLuong DEFAULT 0,
    MoTa NVARCHAR(255) NULL,
    NgayThem DATE NOT NULL CONSTRAINT DF_SanPham_Ngay DEFAULT CONVERT(DATE,GETDATE()),
    TrangThai NVARCHAR(20) NOT NULL CONSTRAINT DF_SanPham_TrangThai DEFAULT N'Đang bán',
    MaDM INT NOT NULL CONSTRAINT FK_SanPham_DanhMuc REFERENCES dbo.DanhMuc(MaDM),
    CONSTRAINT CK_SanPham_Ten CHECK (LEN(LTRIM(RTRIM(TenSP))) > 0),
    CONSTRAINT CK_SanPham_Gia CHECK (Gia >= 0),
    CONSTRAINT CK_SanPham_SoLuong CHECK (SoLuong >= 0),
    CONSTRAINT CK_SanPham_TrangThai CHECK (TrangThai IN (N'Đang bán',N'Ngừng bán'))
);
CREATE TABLE dbo.HinhAnhSanPham (
    MaAnh INT IDENTITY(1,1) CONSTRAINT PK_HinhAnhSanPham PRIMARY KEY,
    MaSP INT NOT NULL CONSTRAINT FK_HinhAnh_SanPham REFERENCES dbo.SanPham(MaSP),
    DuongDanAnh VARCHAR(500) NOT NULL,
    ThuTu INT NOT NULL CONSTRAINT DF_HinhAnh_ThuTu DEFAULT 0,
    CONSTRAINT UQ_HinhAnh UNIQUE(MaSP, DuongDanAnh),
    CONSTRAINT CK_HinhAnh_DuongDan CHECK (LEN(LTRIM(RTRIM(DuongDanAnh))) > 0),
    CONSTRAINT CK_HinhAnh_ThuTu CHECK (ThuTu >= 0)
);
CREATE TABLE dbo.GioHang (
    MaGH INT IDENTITY(1,1) CONSTRAINT PK_GioHang PRIMARY KEY,
    MaND INT NOT NULL CONSTRAINT UQ_GioHang_NguoiDung UNIQUE
        CONSTRAINT FK_GioHang_NguoiDung REFERENCES dbo.NguoiDung(MaND),
    NgayTao DATE NOT NULL CONSTRAINT DF_GioHang_Ngay DEFAULT CONVERT(DATE,GETDATE())
);
CREATE TABLE dbo.ChiTietGioHang (
    MaGH INT NOT NULL CONSTRAINT FK_ChiTietGioHang_GioHang REFERENCES dbo.GioHang(MaGH) ON DELETE CASCADE,
    MaSP INT NOT NULL CONSTRAINT FK_ChiTietGioHang_SanPham REFERENCES dbo.SanPham(MaSP),
    SoLuong INT NOT NULL,
    CONSTRAINT PK_ChiTietGioHang PRIMARY KEY(MaGH,MaSP),
    CONSTRAINT CK_ChiTietGioHang_SoLuong CHECK (SoLuong > 0)
);
CREATE TABLE dbo.DonHang (
    MaDH INT IDENTITY(1,1) CONSTRAINT PK_DonHang PRIMARY KEY,
    MaND INT NOT NULL CONSTRAINT FK_DonHang_NguoiDung REFERENCES dbo.NguoiDung(MaND),
    NgayDat DATE NOT NULL CONSTRAINT DF_DonHang_Ngay DEFAULT CONVERT(DATE,GETDATE()),
    TongTien DECIMAL(18,2) NOT NULL CONSTRAINT DF_DonHang_Tong DEFAULT 0,
    TrangThai NVARCHAR(30) NOT NULL CONSTRAINT DF_DonHang_TrangThai DEFAULT N'Chờ xác nhận',
    DiaChiNhan NVARCHAR(255) NOT NULL,
    TenNguoiNhan NVARCHAR(100) NOT NULL,
    SoDTNhan VARCHAR(15) NOT NULL,
    HinhThucGiaoHang NVARCHAR(50) NOT NULL CONSTRAINT DF_DonHang_GiaoHang DEFAULT N'Giao tiêu chuẩn',
    PhiVanChuyen DECIMAL(18,2) NOT NULL CONSTRAINT DF_DonHang_Phi DEFAULT 0,
    GhiChu NVARCHAR(500) NULL,
    HanXacNhan DATETIME2(0) NOT NULL CONSTRAINT DF_DonHang_Han DEFAULT DATEADD(DAY,2,SYSDATETIME()),
    CONSTRAINT CK_DonHang_Tien CHECK (TongTien >= 0 AND PhiVanChuyen >= 0 AND TongTien >= PhiVanChuyen),
    CONSTRAINT CK_DonHang_NguoiNhan CHECK (LEN(LTRIM(RTRIM(TenNguoiNhan))) > 0 AND LEN(LTRIM(RTRIM(DiaChiNhan))) > 0),
    CONSTRAINT CK_DonHang_SoDT CHECK (LEN(SoDTNhan) BETWEEN 9 AND 15 AND SoDTNhan NOT LIKE '%[^0-9+]%'),
    CONSTRAINT CK_DonHang_TrangThai CHECK (TrangThai IN
        (N'Chờ xác nhận',N'Đang xử lý',N'Đang vận chuyển',N'Đã giao hàng',N'Đã hủy'))
);
CREATE TABLE dbo.ChiTietDonHang (
    MaDH INT NOT NULL CONSTRAINT FK_ChiTietDonHang_DonHang REFERENCES dbo.DonHang(MaDH),
    MaSP INT NOT NULL CONSTRAINT FK_ChiTietDonHang_SanPham REFERENCES dbo.SanPham(MaSP),
    DonGia DECIMAL(18,2) NOT NULL,
    SoLuong INT NOT NULL,
    TenSPLucDat NVARCHAR(150) NOT NULL,
    CONSTRAINT PK_ChiTietDonHang PRIMARY KEY(MaDH,MaSP),
    CONSTRAINT CK_ChiTietDonHang_Gia CHECK (DonGia >= 0),
    CONSTRAINT CK_ChiTietDonHang_SoLuong CHECK (SoLuong > 0)
);
CREATE TABLE dbo.ThanhToan (
    MaTT INT IDENTITY(1,1) CONSTRAINT PK_ThanhToan PRIMARY KEY,
    MaDH INT NOT NULL CONSTRAINT UQ_ThanhToan_DonHang UNIQUE
        CONSTRAINT FK_ThanhToan_DonHang REFERENCES dbo.DonHang(MaDH),
    PhuongThuc VARCHAR(50) NOT NULL,
    TrangThai VARCHAR(30) NOT NULL CONSTRAINT DF_ThanhToan_TrangThai DEFAULT 'ChoThanhToan',
    NgayTT DATE NULL,
    MaGiaoDich VARCHAR(100) NULL,
    CONSTRAINT CK_ThanhToan_PhuongThuc CHECK (PhuongThuc IN ('COD','QR_PAY','MOMO','BANK')),
    CONSTRAINT CK_ThanhToan_TrangThai CHECK (TrangThai IN ('ChoThanhToan','DaThanhToan','ThatBai','DaHuy','ChoHoanTien','DaHoanTien')),
    CONSTRAINT CK_ThanhToan_Ngay CHECK (
        (TrangThai IN ('DaThanhToan','ChoHoanTien','DaHoanTien') AND NgayTT IS NOT NULL) OR
        (TrangThai IN ('ChoThanhToan','ThatBai','DaHuy') AND NgayTT IS NULL))
);
CREATE UNIQUE INDEX UX_ThanhToan_GiaoDich ON dbo.ThanhToan(MaGiaoDich) WHERE MaGiaoDich IS NOT NULL;
CREATE TABLE dbo.DanhGia (
    MaDG INT IDENTITY(1,1) CONSTRAINT PK_DanhGia PRIMARY KEY,
    MaND INT NOT NULL CONSTRAINT FK_DanhGia_NguoiDung REFERENCES dbo.NguoiDung(MaND),
    MaSP INT NOT NULL CONSTRAINT FK_DanhGia_SanPham REFERENCES dbo.SanPham(MaSP),
    SoSao INT NOT NULL,
    NoiDung NVARCHAR(255) NULL,
    NgayGD DATE NOT NULL CONSTRAINT DF_DanhGia_Ngay DEFAULT CONVERT(DATE,GETDATE()),
    CONSTRAINT UQ_DanhGia_NguoiDung_SanPham UNIQUE(MaND,MaSP),
    CONSTRAINT CK_DanhGia_SoSao CHECK (SoSao BETWEEN 1 AND 5)
);
CREATE INDEX IX_NguoiDung_VaiTro ON dbo.NguoiDung(MaVT);
CREATE INDEX IX_SanPham_DanhMuc_TrangThai ON dbo.SanPham(MaDM,TrangThai) INCLUDE(TenSP,Gia,SoLuong);
CREATE INDEX IX_SanPham_Ten ON dbo.SanPham(TenSP);
CREATE INDEX IX_ChiTietGioHang_SanPham ON dbo.ChiTietGioHang(MaSP);
CREATE INDEX IX_DonHang_NguoiDung_Ngay ON dbo.DonHang(MaND,NgayDat DESC) INCLUDE(TrangThai,TongTien);
CREATE INDEX IX_DonHang_TrangThai_Ngay ON dbo.DonHang(TrangThai,NgayDat) INCLUDE(TongTien);
CREATE INDEX IX_ChiTietDonHang_SanPham ON dbo.ChiTietDonHang(MaSP) INCLUDE(DonGia,SoLuong);
CREATE INDEX IX_DanhGia_SanPham ON dbo.DanhGia(MaSP,NgayGD DESC) INCLUDE(SoSao);
COMMIT;
