CREATE OR ALTER VIEW dbo.vw_SanPham AS
SELECT p.MaSP,p.TenSP,p.Gia,p.SoLuong,p.MoTa,p.NgayThem,p.TrangThai,p.MaDM,d.TenDM,
       a.DuongDanAnh,ISNULL(g.SoDanhGia,0) AS SoDanhGia,g.DiemTrungBinh
FROM dbo.SanPham p JOIN dbo.DanhMuc d ON d.MaDM=p.MaDM
OUTER APPLY (SELECT TOP(1) DuongDanAnh FROM dbo.HinhAnhSanPham WHERE MaSP=p.MaSP ORDER BY ThuTu,MaAnh) a
OUTER APPLY (SELECT COUNT(*) SoDanhGia,CAST(AVG(CAST(SoSao AS DECIMAL(4,2))) AS DECIMAL(4,2)) DiemTrungBinh
             FROM dbo.DanhGia WHERE MaSP=p.MaSP) g;
GO
CREATE OR ALTER VIEW dbo.vw_GioHang AS
SELECT g.MaGH,g.MaND,c.MaSP,p.TenSP,c.SoLuong,p.Gia,
       CAST(c.SoLuong*p.Gia AS DECIMAL(18,2)) ThanhTien,p.SoLuong TonKho,p.TrangThai
FROM dbo.GioHang g JOIN dbo.ChiTietGioHang c ON c.MaGH=g.MaGH JOIN dbo.SanPham p ON p.MaSP=c.MaSP;
GO
CREATE OR ALTER VIEW dbo.vw_DonHang AS
SELECT d.*,n.TenDN,n.Email,t.PhuongThuc,t.TrangThai TrangThaiThanhToan,t.NgayTT,
       ISNULL(c.SoLuong,0) SoLuong,ISNULL(c.TienHang,0) TienHang
FROM dbo.DonHang d JOIN dbo.NguoiDung n ON n.MaND=d.MaND
LEFT JOIN dbo.ThanhToan t ON t.MaDH=d.MaDH
OUTER APPLY (SELECT SUM(CONVERT(BIGINT,SoLuong)) SoLuong,SUM(DonGia*SoLuong) TienHang
             FROM dbo.ChiTietDonHang WHERE MaDH=d.MaDH) c;
GO
CREATE OR ALTER VIEW dbo.vw_NguoiDung AS
SELECT n.MaND,n.TenDN,n.Email,n.SoDT,n.HoTen,n.NgaySinh,n.GioiTinh,n.DiaChi,n.TieuSu,n.NgayTao,n.TrangThai,
       n.MaVT,v.TenVaiTro,(SELECT COUNT(*) FROM dbo.DonHang d WHERE d.MaND=n.MaND) SoDonHang
FROM dbo.NguoiDung n JOIN dbo.VaiTro v ON v.MaVT=n.MaVT;
GO
-- Doanh thu ghi nhan theo ngay thu tien, chi tinh don da giao va da thanh toan.
CREATE OR ALTER VIEW dbo.vw_DoanhThuNgay AS
SELECT t.NgayTT,COUNT_BIG(*) SoDonHang,SUM(d.TongTien) TongThu,
       SUM(d.PhiVanChuyen) PhiVanChuyen,SUM(d.TongTien-d.PhiVanChuyen) DoanhThuSanPham
FROM dbo.DonHang d JOIN dbo.ThanhToan t ON t.MaDH=d.MaDH
WHERE d.TrangThai=N'Đã giao hàng' AND t.TrangThai='DaThanhToan' GROUP BY t.NgayTT;
GO
CREATE OR ALTER VIEW dbo.vw_DoanhThuSanPham AS
SELECT p.MaSP,p.TenSP,p.MaDM,m.TenDM,SUM(CONVERT(BIGINT,c.SoLuong)) SoLuongDaBan,SUM(c.DonGia*c.SoLuong) DoanhThu
FROM dbo.ChiTietDonHang c JOIN dbo.DonHang d ON d.MaDH=c.MaDH
JOIN dbo.ThanhToan t ON t.MaDH=d.MaDH JOIN dbo.SanPham p ON p.MaSP=c.MaSP
JOIN dbo.DanhMuc m ON m.MaDM=p.MaDM
WHERE d.TrangThai=N'Đã giao hàng' AND t.TrangThai='DaThanhToan' GROUP BY p.MaSP,p.TenSP,p.MaDM,m.TenDM;
GO
