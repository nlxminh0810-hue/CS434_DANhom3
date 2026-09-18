-- Moi ca tao fixture rieng trong transaction va rollback; khong sua du lieu nguoi dung.
CREATE PROCEDURE #Fixture @MaND INT OUTPUT,@MaSP INT OUTPUT
AS
BEGIN
    DECLARE @Role INT,@Category INT,@Token VARCHAR(32)=REPLACE(CONVERT(VARCHAR(36),NEWID()),'-','');
    INSERT dbo.VaiTro(TenVaiTro) VALUES(@Token);
    SET @Role=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.DanhMuc(TenDM) VALUES(@Token);
    SET @Category=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.NguoiDung(TenDN,Email,MatKhau,SoDT,MaVT)
    VALUES(@Token,@Token+'@test.example',REPLICATE('x',60),'0900000000',@Role);
    SET @MaND=CONVERT(INT,SCOPE_IDENTITY());
    INSERT dbo.SanPham(TenSP,Gia,SoLuong,MaDM) VALUES(N'Sản phẩm kiểm thử',100000,10,@Category);
    SET @MaSP=CONVERT(INT,SCOPE_IDENTITY());
END;
GO
-- 1. Dat hang, snapshot gia, thanh toan lap lai, giao hang, danh gia, bao cao.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT,@D INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_CapNhatGioHang @U,@P,2;
    EXEC dbo.usp_DatHang @U,N'Test','0900000000',N'Đà Nẵng',@PhiVanChuyen=15000,@MaDH=@D OUTPUT;
    IF (SELECT TongTien FROM dbo.DonHang WHERE MaDH=@D)<>215000 THROW 51900,N'Sai tổng tiền.',1;
    IF (SELECT SoLuong FROM dbo.SanPham WHERE MaSP=@P)<>8 THROW 51900,N'Sai tồn kho.',1;
    IF EXISTS(SELECT 1 FROM dbo.vw_GioHang WHERE MaND=@U) THROW 51900,N'Giỏ chưa được làm trống.',1;
    UPDATE dbo.SanPham SET Gia=200000 WHERE MaSP=@P;
    IF (SELECT DonGia FROM dbo.ChiTietDonHang WHERE MaDH=@D AND MaSP=@P)<>100000 THROW 51900,N'Mất giá tại thời điểm đặt.',1;
    DECLARE @GD VARCHAR(100)='test-'+CONVERT(VARCHAR(36),NEWID());
    EXEC dbo.usp_XacNhanThanhToan @D,215000,@GD;
    EXEC dbo.usp_XacNhanThanhToan @D,215000,@GD;
    EXEC dbo.usp_ChuyenTrangThaiDonHang @D,N'Đang xử lý';
    EXEC dbo.usp_ChuyenTrangThaiDonHang @D,N'Đang vận chuyển';
    EXEC dbo.usp_ChuyenTrangThaiDonHang @D,N'Đã giao hàng';
    EXEC dbo.usp_DanhGiaSanPham @U,@P,5,N'Tốt';
    EXEC dbo.usp_DanhGiaSanPham @U,@P,4,N'Cập nhật';
    IF (SELECT COUNT(*) FROM dbo.DanhGia WHERE MaND=@U AND MaSP=@P)<>1 THROW 51900,N'Đánh giá bị trùng.',1;
    IF (SELECT DoanhThu FROM dbo.vw_DoanhThuSanPham WHERE MaSP=@P)<>200000 THROW 51900,N'Sai doanh thu.',1;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    THROW;
END CATCH;
GO
-- 2. Huy lap lai chi hoan kho mot lan; don da thu tien phai cho hoan tien.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT,@D INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_CapNhatGioHang @U,@P,3;
    EXEC dbo.usp_DatHang @U,N'Test','0900000000',N'Đà Nẵng',@MaDH=@D OUTPUT;
    DECLARE @GD VARCHAR(100)='test-'+CONVERT(VARCHAR(36),NEWID());
    EXEC dbo.usp_XacNhanThanhToan @D,300000,@GD;
    EXEC dbo.usp_ChuyenTrangThaiDonHang @D,N'Đã hủy';
    EXEC dbo.usp_ChuyenTrangThaiDonHang @D,N'Đã hủy';
    IF (SELECT SoLuong FROM dbo.SanPham WHERE MaSP=@P)<>10 THROW 51900,N'Hoàn kho sai.',1;
    IF (SELECT TrangThai FROM dbo.ThanhToan WHERE MaDH=@D)<>'ChoHoanTien' THROW 51900,N'Sai trạng thái hoàn tiền.',1;
    IF EXISTS(SELECT 1 FROM dbo.vw_DoanhThuSanPham WHERE MaSP=@P) THROW 51900,N'Tính doanh thu đơn hủy.',1;
    EXEC dbo.usp_XacNhanHoanTien @D;
    EXEC dbo.usp_XacNhanHoanTien @D;
    IF (SELECT TrangThai FROM dbo.ThanhToan WHERE MaDH=@D)<>'DaHoanTien' THROW 51900,N'Chưa xác nhận hoàn tiền.',1;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    THROW;
END CATCH;
GO
-- 3. Ton kho thay doi sau khi them gio: checkout phai tu choi.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT,@D INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_CapNhatGioHang @U,@P,10;
    UPDATE dbo.SanPham SET SoLuong=1 WHERE MaSP=@P;
    EXEC dbo.usp_DatHang @U,N'Test','0900000000',N'Đà Nẵng',@MaDH=@D OUTPUT;
    THROW 51900,N'Đã cho phép bán quá tồn kho.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>51003 THROW;
END CATCH;
GO
-- 4. Gio rong.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_DatHang @U,N'Test','0900000000',N'Đà Nẵng';
    THROW 51900,N'Đã đặt được giỏ rỗng.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>51004 THROW;
END CATCH;
GO
-- 5. Tai khoan bi khoa.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    UPDATE dbo.NguoiDung SET TrangThai=N'Đã khóa' WHERE MaND=@U;
    EXEC dbo.usp_CapNhatGioHang @U,@P,1;
    THROW 51900,N'Tài khoản khóa vẫn mua hàng.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>51002 THROW;
END CATCH;
GO
-- 6. Danh gia khi chua mua hang.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_DanhGiaSanPham @U,@P,5;
    THROW 51900,N'Cho phép đánh giá khi chưa mua.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>51013 THROW;
END CATCH;
GO
-- 7. Thanh toan sai so tien.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT,@D INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_CapNhatGioHang @U,@P,1;
    EXEC dbo.usp_DatHang @U,N'Test','0900000000',N'Đà Nẵng',@MaDH=@D OUTPUT;
    EXEC dbo.usp_XacNhanThanhToan @D,1,'invalid-amount';
    THROW 51900,N'Chấp nhận số tiền sai.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>51009 THROW;
END CATCH;
GO
-- 8. Cam nhay trang thai.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT,@D INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_CapNhatGioHang @U,@P,1;
    EXEC dbo.usp_DatHang @U,N'Test','0900000000',N'Đà Nẵng',@MaDH=@D OUTPUT;
    EXEC dbo.usp_ChuyenTrangThaiDonHang @D,N'Đã giao hàng';
    THROW 51900,N'Cho phép nhảy trạng thái.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>51006 THROW;
END CATCH;
GO
-- 9. Gia am bi CHECK tu choi.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    UPDATE dbo.SanPham SET Gia=-1 WHERE MaSP=@P;
    THROW 51900,N'Chấp nhận giá âm.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
GO
-- 10. FK ngan xoa san pham dang co trong gio.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    EXEC dbo.usp_CapNhatGioHang @U,@P,1;
    DELETE dbo.SanPham WHERE MaSP=@P;
    THROW 51900,N'Mất ràng buộc khóa ngoại.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
GO
-- 11. Username trung lap bi tu choi.
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @U INT,@P INT;
    EXEC #Fixture @U OUTPUT,@P OUTPUT;
    INSERT dbo.NguoiDung(TenDN,Email,MatKhau,SoDT,MaVT)
        SELECT TenDN,'other-'+Email,MatKhau,SoDT,MaVT FROM dbo.NguoiDung WHERE MaND=@U;
    THROW 51900,N'Chấp nhận tên đăng nhập trùng.',1;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK;
    IF ERROR_NUMBER() NOT IN(2601,2627) THROW;
END CATCH;
GO
DROP PROCEDURE #Fixture;
PRINT N'PASS: 11 database scenarios';
