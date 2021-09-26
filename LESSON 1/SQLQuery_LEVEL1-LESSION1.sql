use Northwind;
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
-- select * from dbo.[Order Details];

-- Lấy tất cả Order trong tháng 11-1997
SELECT *
FROM dbo.Orders
select * from dbo.[Orders] where (OrderDate > '1997-11-01 00:00:00.000' and OrderDate < '1997-12-01 00:00:00.000')
GO
----------------------------------------
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

--- PROCEDURE
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
CREATE PROCEDURE proc_DetailOrderByMonth AS 
BEGIN 
    SELECT *
    FROM dbo.[Order Details] A
	join dbo.Orders as B on A.OrderID=B.OrderID
    WHERE YEAR(OrderDate) = 1997
        AND MONTH(OrderDate) = 11
END 
GO 

EXEC proc_DetailOrderByMonth
GO
DROP PROC proc_DetailOrderByMonth;
/* Thực hành 2: 
    Tạo procedure tìm các khách hàng có tên bắt
    đầu bằng chứ cái "B" và lưu dưới tên "proc_GetCustomerByInitial"
*/
CREATE PROC proc_GetCustomerByInitial AS
BEGIN
	SELECT *
    FROM dbo.Orders A
	JOIN dbo.Customers as B on A.CustomerID=B.CustomerID
    WHERE B.ContactName like 'B%'
END 
GO 

EXEC proc_GetCustomerByInitial
GO
DROP PROC proc_GetCustomerByInitial
select * from dbo.[C];
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
------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER PROCEDURE proc_GetOrderDetailsByMonth AS 
BEGIN
    SELECT * 
    FROM dbo.Orders
    WHERE YEAR(OrderDate) = 1998 
        AND MONTH(OrderDate) = 2
		AND EmployeeID = 2
END
GO

EXEC proc_GetOrderDetailsByMonth

DROP PROC proc_GetOrderDetailsByMonth
------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Thực hành 4: 
    
    Thay đổi procedure "proc_GetCustomerByInitial" thành lấy
    dữ liệu cho các KH có tên người liên hệ (ContactName) bắt đầu bằng chữ
    cái "P". Sau đó xóa bỏ procedure này
*/
ALTER PROC proc_GetCustomerByInitial AS
BEGIN
	SELECT *
    FROM dbo.Orders A
	JOIN dbo.Customers as B 
		 on A.CustomerID = B.CustomerID
    WHERE B.CompanyName like 'P%'
END 
GO

EXEC proc_GetCustomerByInitial
GO

DROP PROC proc_GetCustomerByInitial

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

CREATE PROC proc_GetOrderDetailsByMonth (
    @orderMonth INT 
    , @orderYear INT 
    ,@employ_id INT
) AS 
BEGIN 
    SELECT *
    FROM dbo.[Order Details] A
	join dbo.Orders as B on A.OrderID=B.OrderID
    WHERE YEAR(OrderDate) = @orderYear
        AND MONTH(OrderDate) = @orderMonth 
        AND EmployeeID = @employ_id
END 
GO 

EXEC proc_GetOrderDetailsByMonth 4,1998,3 
GO 


CREATE PROC proc_GetOrderDetailsByMonth2
(
	@orderMonth INT,
	@orderYear INT,
	@employeeID INT
) AS
BEGIN
SELECT *
    FROM (select * from dbo.Orders where EmployeeID = @employeeID) as a
    WHERE YEAR(OrderDate) = @orderYear
        AND MONTH(OrderDate) = @orderMonth 
		-- AND EmployeeID = @employeeID
END 
GO
EXEC proc_GetOrderDetailsByMonth2 4,1998,3 
GO 
drop proc proc_GetOrderDetailsByMonth2
go

/* Thực hành 6: 
    
    Thay đổi procedure "proc_GetCustomerByInitial" thành lấy
    dữ liệu cho các KH có tên người liên hệ (ContactName) bắt đầu bằng 1 chữ
    cái theo yêu cầu (Ví dụ: chữ cái "P")
*/
ALTER PROCEDURE proc_GetCustomerByInitial (
    @custInitial NVARCHAR(10)
) AS 
BEGIN 
    SELECT * FROM dbo.Customers WHERE UPPER(ContactName) LIKE UPPER(@custInitial+'%') 
END 
GO 

EXEC proc_GetCustomerByInitial 'PA'
GO 


-- Cài đặt giá trị mặc định của tham số
-- Thực hành 6
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

EXEC proc_GetOrderByMonth 11, 1997
GO 

------------------------------------------------------------------------
ALTER PROCEDURE proc_GetCustomerByInitial (
    @custInitial NVARCHAR(10)
) AS 
BEGIN 
    SELECT * FROM dbo.Customers WHERE UPPER(ContactName) LIKE UPPER(@custInitial+'%') 
END 
GO 

EXEC proc_GetCustomerByInitial 'PA'
GO 
------------------------------------------------------------------------
/*  Thực hành 7: 
    
    Tạo/thay đổi "proc_GetCustomerByInitial" mặc định trả lại
    KH có tên người liên hệ bắt đầu bằng chữ cái "A".
*/
ALTER PROCEDURE proc_GetCustomerByInitial (
    @custInitial NVARCHAR(10)
) AS 
BEGIN 
    SELECT * FROM dbo.Customers WHERE UPPER(ContactName) LIKE UPPER(@custInitial+'%') 
END 
GO 

EXEC proc_GetCustomerByInitial 'A'
GO 
------------------------------------------------------------------------
/* Thực hành 8:

    Tạo procedure "proc_GetEmployeeRevenueByMonth" tính doanh số của từng nhân viên 
    theo tháng yêu cầu (tham số). Kết quả trả lại bao gồm: Mã NV, Tên NV, Số lượng đơn hàng
    và doanh số. Sắp xếp kết quả theo thứ tự nhân viên có doanh số cao nhất trong tháng trước
    sau đó giảm dần.
*/
select * from Employees;
select * from Orders;
select * from [Order Details Extended]

CREATE PROCEDURE proc_GetEmployeeRevenueByMonth(
    @OrderYear INT,
	@OderMonth INT
)
AS 
BEGIN 
    SELECT a.EmployeeID,FirstName+ ' ' + LastName as Fulname, Count(c.OrderID) as Homany, sum(UnitPrice*Quantity) as Revenue
    FROM dbo.Employees as a
	join dbo.Orders c on a.EmployeeID= c.EmployeeID
	join dbo.[Order Details] b on b.OrderID= c.OrderID
    WHERE YEAR(OrderDate) = @OrderYear
        AND MONTH(OrderDate) = @OderMonth
	group by a.EmployeeID,FirstName,LastName
    order by Revenue desc;

END 
GO

exec proc_GetEmployeeRevenueByMonth 1998,4
go
drop proc proc_GetEmployeeRevenueByMonth
go 

----
    SELECT a.EmployeeID,FirstName+ ' ' + LastName as Fulname, Count(c.OrderID) as Homany, sum(UnitPrice*Quantity) as Revenue
    FROM dbo.Employees as a
	join dbo.Orders c on a.EmployeeID= c.EmployeeID
	join dbo.[Order Details] b on b.OrderID= c.OrderID
    WHERE YEAR(OrderDate) = 1997
        AND MONTH(OrderDate) = 12
	group by a.EmployeeID,FirstName,LastName
    order by Revenue desc;
---


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
