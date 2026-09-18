SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
IF NOT EXISTS(SELECT 1 FROM dbo.VaiTro WHERE TenVaiTro=N'Admin') INSERT dbo.VaiTro(TenVaiTro) VALUES(N'Admin');
IF NOT EXISTS(SELECT 1 FROM dbo.VaiTro WHERE TenVaiTro=N'Khách hàng') INSERT dbo.VaiTro(TenVaiTro) VALUES(N'Khách hàng');
DECLARE @DanhMuc TABLE(TenDM NVARCHAR(100),MoTa NVARCHAR(255));
INSERT @DanhMuc VALUES (N'Áo đấu',N'Áo đấu và quần thể thao'),(N'Giày bóng đá',N'Giày thi đấu bóng đá'),(N'Phụ kiện',N'Bóng, tất, ba lô và phụ kiện');
INSERT dbo.DanhMuc(TenDM,MoTa) SELECT TenDM,MoTa FROM @DanhMuc s WHERE NOT EXISTS(SELECT 1 FROM dbo.DanhMuc d WHERE d.TenDM=s.TenDM);
DECLARE @SanPham TABLE(TenSP NVARCHAR(150),TenDM NVARCHAR(100),Gia DECIMAL(18,2),SoLuong INT,MoTa NVARCHAR(255),Anh VARCHAR(500));
INSERT @SanPham VALUES
(N'Áo đá bóng sân nhà',N'Áo đấu',289000,135,N'Áo đấu thoáng khí, form thể thao.','src/assets/img/img1.png'),
(N'Quần thể thao cao cấp',N'Áo đấu',219000,212,N'Chất vải co giãn tốt.','src/assets/img/img2.png'),
(N'Ba lô đựng giày',N'Phụ kiện',349000,124,N'Nhiều ngăn tiện lợi.','src/assets/img/img3.png'),
(N'Bóng thi đấu cao cấp',N'Phụ kiện',499000,245,N'Độ nảy ổn định.','src/assets/img/img4.png'),
(N'Áo Messi phiên bản fan',N'Áo đấu',399000,164,N'Thiết kế nổi bật.','src/assets/img/img5.png'),
(N'Giày tốc độ sân cỏ nhân tạo',N'Giày bóng đá',1599000,57,N'Đế TF bám sân.','src/assets/img/img6.png'),
(N'Giày kiểm soát bóng',N'Giày bóng đá',1899000,46,N'Hỗ trợ chạm bóng.','src/assets/img/img7.png'),
(N'Tất chống trượt Luxury',N'Phụ kiện',99000,96,N'Đệm chân êm.','src/assets/img/img8.png');
INSERT dbo.SanPham(TenSP,MaDM,Gia,SoLuong,MoTa)
SELECT s.TenSP,d.MaDM,s.Gia,s.SoLuong,s.MoTa FROM @SanPham s JOIN dbo.DanhMuc d ON d.TenDM=s.TenDM
WHERE NOT EXISTS(SELECT 1 FROM dbo.SanPham p WHERE p.TenSP=s.TenSP AND p.MaDM=d.MaDM);
INSERT dbo.HinhAnhSanPham(MaSP,DuongDanAnh)
SELECT p.MaSP,s.Anh FROM @SanPham s JOIN dbo.SanPham p ON p.TenSP=s.TenSP
JOIN dbo.DanhMuc d ON d.MaDM=p.MaDM AND d.TenDM=s.TenDM
WHERE NOT EXISTS(SELECT 1 FROM dbo.HinhAnhSanPham a WHERE a.MaSP=p.MaSP AND a.DuongDanAnh=s.Anh);

-- Mat khau ngau nhien da bam scrypt; khong co mat khau mac dinh dang nhap.
-- Tai khoan demo bi khoa sau khi tao cac nghiep vu mau.
IF NOT EXISTS(SELECT 1 FROM dbo.NguoiDung WHERE TenDN='soccerhub_demo' OR Email='demo@soccerhub.example')
BEGIN
    DECLARE @MaND INT,@MaSP INT,@MaDH INT,@MaVT INT;
    SELECT @MaVT=MaVT FROM dbo.VaiTro WHERE TenVaiTro=N'Khách hàng';
    INSERT dbo.NguoiDung(TenDN,Email,MatKhau,SoDT,DiaChi,MaVT,HoTen,NgaySinh,GioiTinh)
    VALUES('soccerhub_demo','demo@soccerhub.example',
      'scrypt$d9d7682f5e6f995c6ebc9901f1d99415$1fc7686559ed0e34fb1f86a058aac9a05ea84023189d1a1c907fa445379f8a075cf61f063baf0c40828e63de5316590eb38cb7d635668973b85da98778667182',
      '0900000000',N'Địa chỉ minh họa, Đà Nẵng',@MaVT,N'Khách hàng minh họa','20000101',N'Khác');
    SET @MaND=CONVERT(INT,SCOPE_IDENTITY());
    SELECT TOP(1) @MaSP=MaSP FROM dbo.SanPham WHERE TenSP=N'Áo đá bóng sân nhà' ORDER BY MaSP;
    EXEC dbo.usp_CapNhatGioHang @MaND,@MaSP,2;
    EXEC dbo.usp_DatHang @MaND,N'Khách hàng minh họa','0900000000',N'Địa chỉ minh họa, Đà Nẵng',@MaDH=@MaDH OUTPUT;
    DECLARE @Tong DECIMAL(18,2);
    SELECT @Tong=TongTien FROM dbo.DonHang WHERE MaDH=@MaDH;
    EXEC dbo.usp_XacNhanThanhToan @MaDH,@Tong,'DEMO-COD-001';
    EXEC dbo.usp_ChuyenTrangThaiDonHang @MaDH,N'Đang xử lý';
    EXEC dbo.usp_ChuyenTrangThaiDonHang @MaDH,N'Đang vận chuyển';
    EXEC dbo.usp_ChuyenTrangThaiDonHang @MaDH,N'Đã giao hàng';
    EXEC dbo.usp_DanhGiaSanPham @MaND,@MaSP,5,N'Dữ liệu đánh giá minh họa.';
    SELECT TOP(1) @MaSP=MaSP FROM dbo.SanPham WHERE TenSP=N'Tất chống trượt Luxury' ORDER BY MaSP;
    EXEC dbo.usp_CapNhatGioHang @MaND,@MaSP,1;
    UPDATE dbo.NguoiDung SET TrangThai=N'Đã khóa' WHERE MaND=@MaND;
END;
COMMIT;
