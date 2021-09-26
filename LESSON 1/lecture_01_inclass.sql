-- 1. TẠO, SỬA, XÓA STORED PROCEDURE

-- 1.1. TẠO PROCEDURE

/* 
    Procedure: thủ tục = đóng gói các câu lệnh cần chạy lặp lại

    - Cú pháp:

    CREATE PROCEDURE <Tên của procedure>
    AS 
    BEGIN
        <Câu lệnh thực hiện>
    END 

    - Gọi/chạy procedure:

    EXEC <Tên của procedure>
*/

USE Northwind
GO

-- Lấy tất cả Order trong tháng 11-1997
SELECT *
FROM dbo.Orders
GO

SELECT *
FROM dbo.[Order Details]
GO

SELECT DISTINCT
    YEAR(OrderDate) OrderYear
    , MONTH(OrderDate) OrderMonth
FROM dbo.Orders
GO

SELECT *
FROM dbo.Orders A
WHERE YEAR(OrderDate) = 1997
    AND MONTH(OrderDate) = 11
GO

CREATE PROCEDURE proc_GetOrderByMonth AS 
BEGIN 
    SELECT *
    FROM dbo.Orders A
    WHERE YEAR(OrderDate) = 1997
        AND MONTH(OrderDate) = 11
END 
GO 

EXEC proc_GetOrderByMonth
GO

/* Thực hành 1: 
    
    Tạo procedure tìm các Chi tiết hóa đơn (Order Details)
    của các hóa đơn trong tháng 11-1997 và lưu với tên 
    "proc_GetOrderDetailsByMonth"
*/

/* Thực hành 2: 
    
    Tạo procedure tìm các khách hàng có tên bắt
    đầu bằng chứ cái "B" và lưu dưới tên "proc_GetCustomerByInitial"
*/

-- 1.2. SỬA, XÓA STORED PROCEDURE

-- Thay đổi procedure vừa tạo thành lấy tất cả Order trong tháng 11-1996
ALTER PROCEDURE proc_GetOrderByMonth AS 
BEGIN
    SELECT * 
    FROM dbo.Orders 
    WHERE YEAR(OrderDate) = 1996 
        AND MONTH(OrderDate) = 11
END
GO

EXEC proc_GetOrderByMonth
GO

-- Xóa Stored Procedure 
DROP PROC proc_GetOrderByMonth
GO 

EXEC proc_GetOrderByMonth -- Trả lại lỗi vì procedure đã bị xóa
GO 

/* Thực hành 3: 
    
    Thay đổi procedure "proc_GetOrderDetailsByMonth" thành 
    lấy dữ liệu cho tháng 2-1998 và EmployeeID = 2.
*/

/* Thực hành 4: 
    
    Thay đổi procedure "proc_GetCustomerByInitial" thành lấy
    dữ liệu cho các KH có tên người liên hệ (ContactName) bắt đầu bằng chữ
    cái "P". Sau đó xóa bỏ procedure này
*/

-- 2. Tham số hóa Stored Procedure

/* 
    Cú pháp:
    CREATE PROCEDURE <Tên của procedure> (
        @<Tên biến 1> <kiểu dữ liệu>
        , @<Tên biến 2> <kiểu dữ liệu>
        ...
    ) AS
    BEGIN 
        <Câu lệnh thực hiện>
    
    END
*/

-- Tạo stored procedure trả lại tất cả các Order theo tháng & năm yêu cầu
CREATE PROC proc_GetOrderByMonth (
    @orderMonth INT 
    , @orderYear INT 
) AS 
BEGIN
    SELECT *
    FROM dbo.Orders A
    WHERE YEAR(OrderDate) = @orderYear
        AND MONTH(OrderDate) = @orderMonth 
END 
GO 

EXEC proc_GetOrderByMonth 11, 1997 
GO 

EXEC proc_GetOrderByMonth 02, 1998
GO 

/* Thực hành 5: 
    
    Tạo/thay đổi "proc_GetOrderDetailsByMonth" thành 
    lấy dữ liệu theo tháng, năm và mã nhân viên yêu cầu
*/

/* Thực hành 6: 
    
    Thay đổi procedure "proc_GetCustomerByInitial" thành lấy
    dữ liệu cho các KH có tên người liên hệ (ContactName) bắt đầu bằng 1 chữ
    cái theo yêu cầu (Ví dụ: chữ cái "P")
*/

-- Cài đặt giá trị mặc định của tham số

/* 
    Tạo stored procedure trả lại tất cả các Order theo tháng & năm yêu cầu.
    Nếu ko truyền tham số thì trả lại dữ liệu tháng 1 năm 1998
*/
ALTER PROCEDURE proc_GetOrderByMonth (
    @orderMonth INT = 1
    , @orderYear INT = 1998 
) AS 
BEGIN 
    SELECT *
    FROM dbo.Orders A
    WHERE YEAR(OrderDate) = @orderYear
        AND MONTH(OrderDate) = @orderMonth 
END 
GO 

EXEC proc_GetOrderByMonth
GO 

EXEC proc_GetOrderByMonth 11, 1997
GO 

/*  Thực hành 7: 
    
    Tạo/thay đổi "proc_GetCustomerByInitial" mặc định trả lại
    KH có tên người liên hệ bắt đầu bằng chữ cái "A".
*/

/* Thực hành 8:

    Tạo procedure "proc_GetEmployeeRevenueByMonth" tính doanh số của từng nhân viên 
    theo tháng yêu cầu (tham số). Kết quả trả lại bao gồm: Mã NV, Tên NV, Số lượng đơn hàng
    và doanh số. Sắp xếp kết quả theo thứ tự nhân viên có doanh số cao nhất trong tháng trước
    sau đó giảm dần.
*/

/* Thực hành 9:

    Tạo báo cáo tổng giá trị cước vận chuyển của từng đơn vị vận chuyển (Shipper) trong một thời kỳ 
    (giữa 2 ngày với định dạng "DD/MM/YYYY", ví dụ: 23/12/1996)
    Yêu cầu báo cáo ghi rõ: Tên ĐVVC, Số ĐT, Tổng số lượng đơn hàng, Tổng giá trị cước vận chuyển.
    Gợi ý: biến đổi dữ liệu dạng chữ thành dạng ngày/tháng/năm sử dụng hàm CONVERT:
    https://www.mssqltips.com/sqlservertip/1145/date-and-time-conversions-using-sql-server/
*/ 

/* Thực hành 10:

    Tương tự thực hành số 9 tuy nhiên khi không truyền tham số thì tự động trả lại dữ liệu của tháng
    gần nhất.
*/
