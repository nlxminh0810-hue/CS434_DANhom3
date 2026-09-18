-- Ghi du lieu thong qua cac procedure de bao toan ton kho va tong tien.
CREATE OR ALTER PROCEDURE dbo.usp_CapNhatGioHang
    @MaND INT, @MaSP INT, @SoLuong INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF @SoLuong IS NULL OR @SoLuong < 0 THROW 51001, N'Số lượng không hợp lệ.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.NguoiDung WITH(UPDLOCK,HOLDLOCK)
                       WHERE MaND=@MaND AND TrangThai=N'Hoạt động')
            THROW 51002, N'Tài khoản không hoạt động.', 1;
        DECLARE @MaGH INT;
        SELECT @MaGH=MaGH FROM dbo.GioHang WITH(UPDLOCK,HOLDLOCK) WHERE MaND=@MaND;
        IF @MaGH IS NULL
        BEGIN
            INSERT dbo.GioHang(MaND) VALUES(@MaND);
            SET @MaGH=CONVERT(INT,SCOPE_IDENTITY());
        END;
        IF @SoLuong=0
            DELETE dbo.ChiTietGioHang WHERE MaGH=@MaGH AND MaSP=@MaSP;
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WITH(UPDLOCK,HOLDLOCK)
                           WHERE MaSP=@MaSP AND TrangThai=N'Đang bán' AND SoLuong>=@SoLuong)
                THROW 51003, N'Sản phẩm không bán hoặc không đủ tồn kho.', 1;
            UPDATE dbo.ChiTietGioHang SET SoLuong=@SoLuong WHERE MaGH=@MaGH AND MaSP=@MaSP;
            IF @@ROWCOUNT=0 INSERT dbo.ChiTietGioHang VALUES(@MaGH,@MaSP,@SoLuong);
        END;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DatHang
    @MaND INT, @TenNguoiNhan NVARCHAR(100), @SoDTNhan VARCHAR(15),
    @DiaChiNhan NVARCHAR(255), @PhuongThuc VARCHAR(50) = 'COD',
    @HinhThucGiaoHang NVARCHAR(50) = N'Giao tiêu chuẩn',
    @PhiVanChuyen DECIMAL(18,2) = 0, @GhiChu NVARCHAR(500) = NULL,
    @MaDH INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM dbo.NguoiDung WITH(UPDLOCK,HOLDLOCK)
                       WHERE MaND=@MaND AND TrangThai=N'Hoạt động')
            THROW 51002, N'Tài khoản không hoạt động.', 1;
        DECLARE @MaGH INT;
        SELECT @MaGH=MaGH FROM dbo.GioHang WITH(UPDLOCK,HOLDLOCK) WHERE MaND=@MaND;
        DECLARE @Items TABLE(MaSP INT PRIMARY KEY, SoLuong INT, DonGia DECIMAL(18,2), TenSP NVARCHAR(150));
        INSERT @Items SELECT c.MaSP,c.SoLuong,p.Gia,p.TenSP
        FROM dbo.ChiTietGioHang c WITH(UPDLOCK,HOLDLOCK)
        JOIN dbo.SanPham p WITH(UPDLOCK,HOLDLOCK) ON p.MaSP=c.MaSP WHERE c.MaGH=@MaGH;
        IF NOT EXISTS(SELECT 1 FROM @Items) THROW 51004, N'Giỏ hàng trống.', 1;
        IF EXISTS(SELECT 1 FROM @Items i JOIN dbo.SanPham p ON p.MaSP=i.MaSP
                  WHERE p.SoLuong<i.SoLuong OR p.TrangThai<>N'Đang bán')
            THROW 51003, N'Sản phẩm không bán hoặc không đủ tồn kho.', 1;
        DECLARE @Tong DECIMAL(18,2);
        SELECT @Tong=SUM(DonGia*SoLuong)+@PhiVanChuyen FROM @Items;
        INSERT dbo.DonHang(MaND,TongTien,DiaChiNhan,TenNguoiNhan,SoDTNhan,HinhThucGiaoHang,PhiVanChuyen,GhiChu)
        VALUES(@MaND,@Tong,@DiaChiNhan,@TenNguoiNhan,@SoDTNhan,@HinhThucGiaoHang,@PhiVanChuyen,@GhiChu);
        SET @MaDH=CONVERT(INT,SCOPE_IDENTITY());
        INSERT dbo.ChiTietDonHang(MaDH,MaSP,DonGia,SoLuong,TenSPLucDat)
            SELECT @MaDH,MaSP,DonGia,SoLuong,TenSP FROM @Items;
        UPDATE p SET SoLuong=p.SoLuong-i.SoLuong FROM dbo.SanPham p JOIN @Items i ON i.MaSP=p.MaSP;
        INSERT dbo.ThanhToan(MaDH,PhuongThuc) VALUES(@MaDH,@PhuongThuc);
        DELETE dbo.ChiTietGioHang WHERE MaGH=@MaGH;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ChuyenTrangThaiDonHang
    @MaDH INT, @TrangThai NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @Cu NVARCHAR(30);
        SELECT @Cu=TrangThai FROM dbo.DonHang WITH(UPDLOCK,HOLDLOCK) WHERE MaDH=@MaDH;
        IF @Cu IS NULL THROW 51005, N'Đơn hàng không tồn tại.', 1;
        IF @Cu=@TrangThai BEGIN COMMIT; RETURN; END;
        IF @TrangThai IS NULL OR NOT (
            (@Cu=N'Chờ xác nhận' AND @TrangThai IN(N'Đang xử lý',N'Đã hủy')) OR
            (@Cu=N'Đang xử lý' AND @TrangThai IN(N'Đang vận chuyển',N'Đã hủy')) OR
            (@Cu=N'Đang vận chuyển' AND @TrangThai=N'Đã giao hàng'))
            THROW 51006, N'Không được chuyển trạng thái đơn hàng như yêu cầu.', 1;
        IF @TrangThai=N'Đã giao hàng' AND NOT EXISTS
            (SELECT 1 FROM dbo.ThanhToan WITH(UPDLOCK,HOLDLOCK) WHERE MaDH=@MaDH AND TrangThai='DaThanhToan')
            THROW 51007, N'Cần xác nhận đã thu tiền trước khi hoàn tất giao hàng.', 1;
        UPDATE dbo.DonHang SET TrangThai=@TrangThai WHERE MaDH=@MaDH;
        IF @TrangThai=N'Đã hủy'
        BEGIN
            UPDATE p SET SoLuong=p.SoLuong+c.SoLuong FROM dbo.SanPham p
            JOIN dbo.ChiTietDonHang c ON c.MaSP=p.MaSP WHERE c.MaDH=@MaDH;
            UPDATE dbo.ThanhToan SET TrangThai=CASE WHEN TrangThai='DaThanhToan' THEN 'ChoHoanTien' ELSE 'DaHuy' END
            WHERE MaDH=@MaDH;
        END;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO
-- Chi backend da xac minh callback/cong thanh toan hoac nhan vien thu COD duoc goi.
CREATE OR ALTER PROCEDURE dbo.usp_XacNhanThanhToan
    @MaDH INT, @SoTien DECIMAL(18,2), @MaGiaoDich VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @Tong DECIMAL(18,2), @DonTrangThai NVARCHAR(30), @TT VARCHAR(30), @GD VARCHAR(100);
        SELECT @Tong=TongTien,@DonTrangThai=TrangThai FROM dbo.DonHang WITH(UPDLOCK,HOLDLOCK) WHERE MaDH=@MaDH;
        IF @Tong IS NULL OR @DonTrangThai=N'Đã hủy' THROW 51008, N'Đơn hàng không hợp lệ để thanh toán.', 1;
        IF @SoTien IS NULL OR @SoTien<>@Tong THROW 51009, N'Số tiền thanh toán không khớp.', 1;
        IF @MaGiaoDich IS NULL OR LEN(LTRIM(RTRIM(@MaGiaoDich)))=0 THROW 51010, N'Thiếu mã giao dịch.', 1;
        SELECT @TT=TrangThai,@GD=MaGiaoDich FROM dbo.ThanhToan WITH(UPDLOCK,HOLDLOCK) WHERE MaDH=@MaDH;
        IF @TT='DaThanhToan' AND @GD=@MaGiaoDich BEGIN COMMIT; RETURN; END;
        IF @TT IS NULL OR @TT NOT IN('ChoThanhToan','ThatBai') THROW 51011, N'Trạng thái thanh toán không hợp lệ.', 1;
        UPDATE dbo.ThanhToan SET TrangThai='DaThanhToan',NgayTT=CONVERT(DATE,GETDATE()),MaGiaoDich=@MaGiaoDich WHERE MaDH=@MaDH;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_XacNhanHoanTien @MaDH INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ThanhToan SET TrangThai='DaHoanTien' WHERE MaDH=@MaDH AND TrangThai='ChoHoanTien';
    IF @@ROWCOUNT=0 AND NOT EXISTS(SELECT 1 FROM dbo.ThanhToan WHERE MaDH=@MaDH AND TrangThai='DaHoanTien')
        THROW 51012, N'Đơn hàng không chờ hoàn tiền.', 1;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_DanhGiaSanPham
    @MaND INT, @MaSP INT, @SoSao INT, @NoiDung NVARCHAR(255)=NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS(SELECT 1 FROM dbo.NguoiDung WITH(UPDLOCK,HOLDLOCK) WHERE MaND=@MaND AND TrangThai=N'Hoạt động')
            THROW 51002, N'Tài khoản không hoạt động.', 1;
        IF NOT EXISTS(SELECT 1 FROM dbo.DonHang d JOIN dbo.ChiTietDonHang c ON c.MaDH=d.MaDH
                      WHERE d.MaND=@MaND AND c.MaSP=@MaSP AND d.TrangThai=N'Đã giao hàng')
            THROW 51013, N'Chỉ được đánh giá sản phẩm đã mua và nhận hàng.', 1;
        UPDATE dbo.DanhGia WITH(UPDLOCK,HOLDLOCK) SET SoSao=@SoSao,NoiDung=@NoiDung,NgayGD=CONVERT(DATE,GETDATE())
        WHERE MaND=@MaND AND MaSP=@MaSP;
        IF @@ROWCOUNT=0 INSERT dbo.DanhGia(MaND,MaSP,SoSao,NoiDung) VALUES(@MaND,@MaSP,@SoSao,@NoiDung);
        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
    END CATCH;
END;
GO
