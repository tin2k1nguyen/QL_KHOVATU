--tạo dữ liệu quản lý kho hàng vật tư
create database QL_KhoHang
USE QL_KhoHang
GO 

On Primary 
(
	name = KhoData,
	filename = 'F:\Hệ Thống Thông Tin\KhoData.mdf',
	size = 20MB,
	maxsize= 100MB,
	filegrowth=10mb
)
Log on 
(
	name= KaraLog,
	filename = 'F:\Hệ Thống Thông Tin\KaraLog.ldf', 
	size = 5 MB,
	maxsize = 15 MB, 
	filegrowth = 1 MB
)
--tạo bảng khách hàng 
create table KhachHang
(
	MaKH nvarchar(10),
	TenKH nvarchar(50),
	DiaChi nvarchar(max), 
	DienThoai int,
	constraint pk_kh primary key(MaKH)
)
--tạo bảng nhân viên
create table NhanVien
(
	MaNV nvarchar(10),
	TenNV nvarchar(50),
	NgaySinh datetime,
	DiaChi nvarchar(max),
	DienThoai int,
	Email nvarchar(max)
	constraint pk_nv primary key(MaNV)
)
--tạo bảng nhà cung cấp
create table NCC 
(
	MaNCC nvarchar(10),
	TenNCC nvarchar(50),
	DiaChi nvarchar(max),
	DienThoai int
	constraint pk_ncc primary key (MaNCC)
)
--tạo bảng loại vật tư
create table LoaiVatTu
(
	MaLoai nvarchar(10),
	TenLoai nvarchar(50),
	constraint pk_lvt primary key (MaLoai)
)
--tạo bảng vật tư
create table VatTu
(
	MaVT nvarchar(10),
	TenVT nvarchar(50),
	MaLoai nvarchar(10),
	DVT nvarchar(10),
	constraint pk_vt primary key (MaVT)
)
 
-- tạo bảng đơn đặt hàng 
create table DonDatHang
(
	SoDH int ,
	NgayDH datetime,
	NgayGH datetime,
	MaKH nvarchar(10),
	TienDatCoc money,
	MaNV nvarchar(10)
	constraint pk_ddh primary key (SoDH)
)

create table CT_DonDatHang
(
	SoDH int,
	MaVT nvarchar(10),
	SoLuong int,
	constraint pk_ctddh primary key(SoDH, MaVT)
)
--tạo bảng phiếu nhập
create table PhieuNhap 
(
	SoPN int,
	NgayNhap datetime,
	MaNCC nvarchar(10),
	NgayTT datetime,
	constraint pk_pn primary key (SoPN)
)
alter table PhieuNhap 
add MaNV nvarchar(10),
	TamUng money
--tạo bảng chi tiết phiếu nhập
create table CT_PhieuNhap
(
	SoPN int,
	MaVT nvarchar(10),
	SLNhap int,
	DGNhap money,
	ThanhTien money,
	constraint pk_ctpn primary key (SoPN, MaVT)
)

-- tạo bảng phiếu xuất
create table PhieuXuat
(
	SoPX int,
	NgayXuat datetime,
	LyDo nvarchar(max),
	MaNV nvarchar(10),
	constraint pk_px primary key (SoPX)
)
--tạo bảng chi tiết phiếu xuất
create table CT_PhieuXuat
(
	SoPX int,
	MaVT nvarchar(10),
	SLXuat int,
	constraint pk_ctpx primary key (SoPX, MaVT)
)
-- Tạo bảng tồn kho
create table TonKho
(
	MaTK nvarchar(10),
	MaVT nvarchar(10),
	SL_TonDK int,
	SLNhap int,
	SLXuat int,
	SL_TonCK int,
	constraint pk_tk primary key (MaTK)
)
--Thêm khóa ngoại cho bảng đơn đặt hàng
alter table DonDatHang
add constraint fk_ddh_kh foreign key (MaKH) references KhachHang (MaKH),
	constraint fk_ddh_nv foreign key (MaNV) references NhanVien(MaNV)
--Thêm khóa ngoại cho bảng Tồn Kho 
alter table TonKho
add constraint fk_tk_vt foreign key (MaVT) references VatTu (MaVT)
--Thêm khóa ngoại cho bảng phiếu nhập
alter table PhieuNhap
add constraint fk_pn_nv foreign key (MaNV) references NhanVien (MaNV),
	constraint fk_pn_ncc foreign key (MaNCC) references NCC
--Thêm khóa ngoai cho bảng chi tiết phiếu nhập 
alter table CT_PhieuNhap
add constraint fk_ctpn_pn foreign key (SoPN) references PhieuNhap (SoPN),
	constraint fk_ctpn_vt foreign key (MaVT) references VatTu (MaVT)
--Thêm khóa ngoại cho bảng phiếu xuất
alter table PhieuXuat
add constraint fk_px_nv foreign key (MaNV) references NhanVien (MaNV)
--Thêm khóa ngoại cho bảng chi tiết phiếu xuất 
alter table CT_PhieuXuat
add constraint fk_ctpx_px foreign key (SoPX) references PhieuXuat (SoPX),
	constraint fk_ctpx_vt foreign key (MaVT) references VatTu (MaVT)
-- Thêm khóa ngoại cho bảng vật tư
alter table VatTu
add constraint fk_vt_lvt foreign key (MaLoai) references LoaiVatTu (MaLoai)
-- Thêm khóa ngoại cho bảng chi tiết đơn đặt hàng 
alter table CT_DonDatHang
add constraint fk_ctddh_vt foreign key (MaVT) references VatTu (MaVT),
	constraint fk_ctddh_ddh foreign key (SoDH) references DonDatHang (SoDH)

	-------------------------------
	create proc sp_GetTonKho 
as
select * from TonKho
-------------------------------
create proc sp_InsertTK
@MaTk nvarchar(10),
@MaVT nvarchar(10),
@SL_TonDk int,
@SLNhap int,
@SLXuat int,
@SL_TonCK int
as
insert into TonKho(MaTk,MaVT,SL_TonDk,SLNhap,SLXuat,SL_TonCK)
values (@MaTk,@MaVT,@SL_TonDk,@SLNhap,@SLXuat,@SL_TonCK)
--------------------------------
create proc sp_DeleteTK
@MaTK nvarchar(10)
as 
Delete from TonKho
where MaTK=@MaTK
-----------------
create proc sp_UpdateTK
@MaTk nvarchar(10),
@MaVT nvarchar(10),
@SL_TonDk int,
@SLNhap int,
@SLXuat int,
@SL_TonCK int
as 
Update TonKho
set MaTK=@MaTk,
    MaVT=@MaVT,
	SL_TonDK=@SL_TonDk,
	@SLNhap=@SLNhap,
	SLXuat=@SLXuat,
	SL_TonCK = @SL_TonCK
	
where MaTK=@MaTk