/* BTVN Buổi 1 */

/* Bài tập 1
    Tạo một Stored Procedure "proc_GetBestEmployeeRevenueByMonth" lấy ra thông tin nhân viên 
    có doanh số cao nhất theo tháng. 
    Thủ tục sẽ nhận tháng làm tham số đầu vào theo định dạng "MM-YYYY".
    Yêu cầu thủ tục trả lại dữ liệu bao gồm: Tháng, Tổng doanh số, Mã NV, Tên đầy đủ (bao gồm cả danh xưng Mr. Mrs.), Chức danh, Ngày vào làm,
    số năm kinh nghiệm làm việc tại Cty.
*/

-- Bắt đầu viết code từ đây
-- INPUT:@MM, @YY
use Northwind
Go 

-- B1: Create the processing task inside
SELECT a.EmployeeID,FirstName+ ' ' + LastName as Fulname, Count(c.OrderID) as Homany, sum(UnitPrice*Quantity) as Revenue
    FROM dbo.Employees as a
	join dbo.Orders c on a.EmployeeID= c.EmployeeID
	join dbo.[Order Details] b on b.OrderID= c.OrderID
    WHERE YEAR(OrderDate) = 1997
        AND MONTH(OrderDate) = 12
	group by a.EmployeeID,FirstName,LastName
    order by Revenue desc;
-- B2- PUT IT TO THE PROC
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
-------------------------
ALTER PROCEDURE proc_GetEmployeeRevenueByMonth(
    @OrderYear INT,
	@OderMonth INT
)
AS 
BEGIN
    select
        A.EmployeeID,
        B.FirstName+ ' '+B.LastName AS FULLNAME,
        sum(C.UnitPrice*C.Quantity) as Revenue 
    from dbo.Orders A
    join Employees B on A.EmployeeID=B.EmployeeID
    join dbo.[Order Details] C on A.OrderID=C.OrderID
    --WHERE RIGHT(CONVERT(varchar, OrderDate,105),7) = '11-1997'
    WHERE YEAR(OrderDate) = @OrderYear
        AND MONTH(OrderDate) = @OderMonth
    GROUP BY A.EmployeeID,B.FirstName,B.LastName 
    ORDER BY Revenue desc;
end 
go 
drop proc proc_GetEmployeeRevenueByMonth;
exec proc_GetEmployeeRevenueByMonth 1997,11
go 
/* Bài tập 2
    Tạo một Stored Procedure đưa ra danh sách các sản phẩm đã hết hàng trong kho
*/
-- Bắt đầu viết code từ đây
select * from dbo.[Products] where UnitsInStock =0;

ALTER PROC proc_GetListProductOutOfStock
AS
BEGIN
	SELECT 
    *
    FROM dbo.Products
    WHERE UnitsInStock = 0
END 
GO 

EXEC proc_GetListProductOutOfStock
GO
/* Bài tập 3 
    Tạo một Stored Procedure lấy ra thông tin quốc gia ship hàng tới có doanh số lớn nhất
    trong tháng. Thủ tục nhận tham số đầu vào là tháng với định dạng tương tự Bài tập 1.
*/

-- Bắt đầu viết code từ đây


/* Bài tập 4 
    Tạo một Stored Procedure lấy ra thông tin doanh số theo nhà cung cấp (Supplier) trong một khoảng thời gian.
    Sắp xếp theo thứ tự doanh số giảm dần. 
    Thủ thục nhận tham số đầu vào là ngày bắt đầu và ngày kết thúc với format "YYYY-MM-DD" Và 
    nhận giá trị mặc định là ngày đầu tháng và cuối tháng 1 năm 1998.
    Yêu cầu thủ tục trả lại dữ liệu bao gồm: Ngày bắt đầu, ngày kết thúc, Mã nhà cung cấp, Tên nhà cung cấp, người đại điện, chức danh người đại diện,
    Thông tin địa chỉ của nhà cung cấp và doanh số tương ứng.
*/

-- Bắt đầu viết code từ đây

ALTER PROC proc_GetSupplierRevenueByPeriod (
    @StartOrderDate VARCHAR(10) = NULL
    -- @@StartOrderDate VARCHAR(10) = NULL
) AS 
BEGIN
    IF @StartOrderDate IS NULL
    SET @StartOrderDate = '1998-01-01'

    SELECT
        FORMAT((DATEADD(month, DATEDIFF(month, 0, o.OrderDate), 0)), 'yyyy-MM-dd') as Start_of_Order_Month,
        FORMAT(EOMONTH(o.OrderDate), 'yyyy-MM-dd') as End_of_Order_Month,
        o.OrderDate,
        s.SupplierID,
        s.CompanyName as SupplyName,
        s.ContactName,
        s.ContactTitle,
        s.Address,
        SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as Total_Sales
    FROM dbo.Suppliers s
    JOIN dbo.Products p ON s.SupplierID=p.SupplierID
    JOIN dbo.[Order Details] od ON p.ProductID=od.ProductID
    JOIN dbo.Orders o ON o.OrderID=od.OrderID
    WHERE YEAR(o.OrderDate)=LEFT(@StartOrderDate,4)
        AND MONTH(o.OrderDate)=SUBSTRING(@StartOrderDate,6,2)
    GROUP BY
        FORMAT((DATEADD(month, DATEDIFF(month, 0, o.OrderDate), 0)), 'yyyy-MM-dd'),
        FORMAT(EOMONTH(o.OrderDate), 'yyyy-MM-dd'),
        o.OrderDate,
        s.SupplierID,
        s.CompanyName,
        s.ContactName,
        s.ContactTitle,
        s.Address
    ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC
END 
GO 

EXEC proc_GetSupplierRevenueByPeriod '1996-07-20'
GO
WITH SupplierDetails AS (--DimensionTable 
    SELECT 
    SupplierID,
    CompanyName SupplyName,
    ContactName,
    ContactTitle,
    Address
    FROM dbo.Suppliers
)
select distinct SupplierID from Suppliers;

select
    s.SupplierID,
    SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) as Total_Sales
from dbo.Suppliers s 
join dbo.Products p on s.SupplierID =p.SupplierID
join dbo.[Order Details] od on od.ProductID=p.ProductID
join Orders o on o.OrderID=od.OrderID
--Convert using datatimefunction convert in SQL thôi 
where o.OrderDate BETWEEN '1996-07-04 00:00:00.000' and '1997-07-04 00:00:00.000'
group by s.SupplierID;


