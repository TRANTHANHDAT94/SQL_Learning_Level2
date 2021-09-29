/* 1. Hàm trong SQL */

/* 1.1 Hàm Scalar:
    Là một hàm trả lại giá trị.

    Cú pháp:

    CREATE FUNCTION <Tên hàm> (
        @<Biến đầu vào 1> <Định dạng dữ liệu>,
        @<Biến đầu vào 2> <Định dạng dữ liệu>,
        ...
        @<Biến đầu vào n> <Định dạng dữ liệu>
    ) RETURNS <Định dạng dữ liệu> AS
    BEGIN
        <Câu lệnh>
        RETURN <Scalar>
    END 
*/

/* Ví dụ:
    Tạo hàm tính số ngày từ một thời điểm đến thời điểm hiện tại
*/
USE Northwind
GO 

SELECT CURRENT_TIMESTAMP;

SELECT DATEDIFF(DAY, CURRENT_TIMESTAMP, '2021-10-01');
GO 

CREATE FUNCTION func_DayFromToday (
    @date DATE
) RETURNS INT AS 
BEGIN 
    RETURN DATEDIFF(DAY, CURRENT_TIMESTAMP, @date)
END 
GO 

SELECT dbo.func_DayFromToday('2021-10-01')
GO

SELECT 
    OrderID 
    , OrderDate
    , dbo.func_DayFromToday(OrderDate) DayFromToday
FROM dbo.Orders 
GO

/* Sử dụng kết quả đầu vào của hàm để tiếp tục tính toán */
SELECT
    OrderID 
    , OrderDate 
    , DATEADD(DAY, -1*dbo.func_DayFromToday(OrderDate),  ShippedDate) NewShippedDate
FROM dbo.Orders 
GO 

/* Thực hành 01 
    Tạo hàm tên "func_DayTillChristmas" tính số ngày cho đến giáng sinh cùng năm.
    Hàm này nhận biến đầu vào là 01 ngày cụ thể và tính số ngày còn lại cho đến 
    ngày giáng sinh của cùng năm đấy
*/


/* Sửa đổi hàm
    Cú pháp tương tự tạo hàm thay CREATE bằng ALTER 

    ALTER FUNCTION <Tên hàm> (
        @<Biến đầu vào 1> <Định dạng dữ liệu>,
        @<Biến đầu vào 2> <Định dạng dữ liệu>,
        ...
        @<Biến đầu vào n> <Định dạng dữ liệu>
    ) RETURNS <Định dạng dữ liệu> AS
    BEGIN
        <Câu lệnh mới>
        RETURN <Scalar>
    END 
*/

/* Ví dụ:
    Thay đổi hàm "func_DayFromToday" thành tính số tháng 
*/
ALTER FUNCTION func_DayFromToday (
    @date DATE 
) RETURNS INT AS 
BEGIN 
    RETURN DATEDIFF(MONTH, GETDATE(), @date)
END 
GO 

SELECT dbo.func_DayFromToday('2022-01-01')
GO 

SELECT 
    OrderID 
    , OrderDate 
    , dbo.func_DayFromToday(ShippedDate) DayFromToday 
FROM dbo.Orders
GO 

/* Xóa bỏ hàm
    Cú pháp:
    DROP FUNCTION <Tên hàm>
*/

/* Ví dụ: 
    Xóa bỏ hàm "func_DayFromToday" 
*/
DROP FUNCTION dbo.func_DayFromToday()
GO 

SELECT dbo.func_DayFromToday('2022-01-01')
GO 

/* Thực hành 02
    Sửa hàm "func_DayTillChristmas" vừa tạo thành tính số tuần tới giáng sinh
    năm TIẾP THEO.
    Gọi hàm trên bảng Orders với ngày ShippeDate cho ra kết quả.
    Sau đó xóa bỏ hàm này khỏi DB.
*/

/* lưu ý:
    Cả hàm (FUNCTION) và thủ tục (PROCEDURE) có cú pháp tương đối giống nhau.
    Tuy nhiên:
    - Hàm trả kết quả bằng mệnh đề RETURNS. Thủ tục ko trả kết quả bằng RETURNS.
    - Hàm phải nêu rõ định dạng dữ liệu trả lại 
    - Hàm có thể gọi ra trong một câu query thông thường và kết quả trả lại được sử dụng
    để tiếp tục tính toán
    - Thủ tục được gọi bằng lệnh EXEC và kết quả chỉ đứng một mình.
*/

/* 1.2 Hàm Table 
    Ngoài hàm trả lại một giá trị duy nhất (Hàm Scalar). Hàm còn có thể trả lại
    giá trị dưới dạng bảng.

    Cú pháp:
    CREATE FUNCTION <Tên hàm> (
        @<Biến đầu vào 1> <Định dạng dữ liệu>,
        @<Biến đầu vào 2> <Định dạng dữ liệu>,
        ...
        @<Biến đầu vào n> <Định dạng dữ liệu>
    ) RETURNS TABLE AS
    RETURN
        <Câu lệnh>
*/

/* Ví dụ: 
    Tạo hàm "func_OrdersShippedToCountry" lấy ra tất cả các đơn hàng được
    chuyển đến một quốc gia
*/
CREATE FUNCTION func_OrdersShippedToCountry(
    @country NVARCHAR(50)
) RETURNS TABLE AS 
RETURN  
    SELECT *
    FROM Orders 
    WHERE ShipCountry = @country 
GO 

SELECT * 
FROM dbo.func_OrdersShippedToCountry('USA')
GO

CREATE PROC proc_OrdersShippedToCountry(
    @country NVARCHAR(50)
) AS 
BEGIN   
    SELECT *
    FROM Orders 
    WHERE ShipCountry = @country 
END 
GO 

EXEC proc_OrdersShippedToCountry 'USA'
GO 

/* Thực hành 03:
    Viết hàm "func_Top10PercentProduct" đưa ra danh sách 10% sản phẩm có doanh số
    tốt nhất tỏng một năm.
    Hàm nhận biến đầu vào là một năm.
*/


/*
    Phân biệt Scalar Function vs Table-valued Function
    - Scalar Function: 
        + Trả ra kết quả giá trị đơn, ví dụ số, kí tự, ...
        + Có thể được gọi bên trong câu lệnh query như là một giá trị

    - Table-valued Function: 
        + Trả ra kết quả là bảng dữ liệu
        + Có thể được gọi bên trong câu lệnh query như là một bảng dữ liệu nguồn
*/

/* 2. Mệnh đề IF/ELSE 
    là mệnh đề kiểm soát luồng chạy của chương trình theo dạng điều kiện.
    NẾU <điều kiện> THÌ <Câu lệnh>
    Cú pháp:

    IF <Điều kiện 1>
        <câu lệnh sql 1 | Block lệnh 1>
    ELSE <Điều kiện 2>
        <câu lệnh sql 2 | Block lệnh 2>

    Có thể sử dụng nhiều IF/ELSE lồng nhau
*/

/* Lưu ý:
    <câu lệnh sql> (sql statement) vs <block lệnh> (code block)
    - Câu lệnh sql: là những lệnh có thể chạy riêng ngoài môi trường scripting như
    SELECT, UPDATE, DELETE, INSERT ...
    - Block lệnh là những đoạn code scripting tính toán và phải bắt đầu bằng BEGIN...END.
    Thông thường nếu có đặt biến sẽ bắt buộc phải viết dưới dạng block lệnh.
*/

/* Ví dụ: <câu lệnh sql> vs <block lệnh> */
-- câu lệnh sql 
SELECT * 
FROM dbo.Orders 
WHERE YEAR(RequiredDate) = 1997
GO 

-- block lệnh
BEGIN 
    DECLARE @year INT 
    SET @year = 1997 
    SELECT * 
    FROM dbo.Orders 
    WHERE YEAR(RequiredDate) = @year 
END 
GO 

/* Ví dụ IF/ELSE 
    Tạo hàm tên "func_OddEven". Trả lại kết quả một số là chắn hay lể.
    Nếu là chẵn trả lại "Even" ngược lại trả lại "Odd".
*/

CREATE FUNCTION func_OddEven(@number INT)
RETURNS NVARCHAR(10) AS 
BEGIN 
    IF @number%2 = 0 
        RETURN 'Even'
    ELSE 
        RETURN 'Odd'
    RETURN NULL 
END 
GO 

SELECT dbo.func_OddEven(EmployeeID) 
FROM dbo.Orders 
GO 

/* Thực hành 04
    Tạo hàm "func_MonthAverage" tính giá trị trung bình ngày của một ước lượng 
    cho một tháng. Cụ thể: sẽ có tháng 28, 29, 30 và 31 ngày và tùy vào tháng có
    bao nhiêu ngày mà chia ước lượng ra tương ứng.
    Hàm nhận 3 giá trị biến: ước lượng, tháng và năm.
*/

/* Thực hành 05 
    Sử dụng hàm "func_MonthAverage" để tính doanh thu trung bình ngày cho mỗi tháng
    từ tháng 01/1996 đến hết tháng 01/1998.
*/

/* Thực hành 06
    Thực hiện thực hành 10 - Buổi số 1:
    Tạo báo cáo tổng giá trị cước vận chuyển của từng đơn vị vận chuyển (Shipper) trong một thời kỳ 
    (giữa 2 ngày với định dạng "DD/MM/YYYY", ví dụ: 23/12/1996). Khi không truyền tham số thì tự động trả lại dữ liệu của tháng
    gần nhất.
    Yêu cầu báo cáo ghi rõ: Tên ĐVVC, Số ĐT, Tổng số lượng đơn hàng, Tổng giá trị cước vận chuyển.
*/

/* Hàm trả lại TABLE qua biến dạng TABLE
    Đôi khi chúng ta ko thể trả lại ngay được bảng mà phải xử lý dữ liệu/
    kiểm tra điều kiện trước khi trả lại bảng. Trong trường hợp đó ta có thể
    sử dụng biến có định dạng dữ liệu dạng bảng để trả lại kết quả.

    Cú pháp:
    CREATE FUNCTION <Tên hàm> (
        @<Biến đầu vào 1> <Định dạng dữ liệu>,
        @<Biến đầu vào 2> <Định dạng dữ liệu>,
        ...
        @<Biến đầu vào n> <Định dạng dữ liệu>
    ) RETURNS @table TABLE (
        <Trường dữ liệu 1> <Định dạng dữ liệu>,
        <Trường dữ liệu 2> <Định dạng dữ liệu>,
        ...
        <Trường dữ liệu n> <Định dạng dữ liệu>,
    ) AS
    BEGIN
        <Câu lệnh>
        RETURN @table
    END 
*/

/* Ví dụ:
    Tạo hàm "func_GetOrderByEmployee" nhận biến đầu vào là EmployeeID và một năm và 
    trả lại tất cả Order của EmployeeID đó trong năm.
    Nếu ko điền là EmployeeID nào thì trả lại tất cả Order của tất cả Employee trong năm.
*/

CREATE FUNCTION func_GetOrderByEmployee(
    @employeeID INT = NULL 
    , @year INT 
) RETURNS @table TABLE (
    EmployeeID INT
    , OrderID INT 
) AS  
BEGIN
    IF @employeeID IS NULL 
        INSERT INTO @table
        SELECT 
            EmployeeID
            , OrderID
        FROM Orders
        WHERE YEAR(OrderDate) = @year
    ELSE
        INSERT INTO @table
        SELECT 
            EmployeeID
            , OrderID
        FROM Orders
        WHERE EmployeeID = @employeeID
            AND YEAR(OrderDate) = @year 
    RETURN
END
GO 

SELECT * 
FROM dbo.func_GetOrderByEmployee(default, 1996)
GO 

/* Thực hành 07
	Công ty có chính sách khen thưởng, theo đó sẽ thưởng doanh số khi doanh số trong tháng vượt $10,000. 
	Theo đó, công ty sẽ thưởng 5% phần doanh số vượt mức $10,000 cho nhân viên hàng tháng. 

	Ví dụ, nhân viên A có doanh số tháng đạt $11,000, công ty sẽ thưởng 5% trên phần vượt là $1,000, tức là $50.
	Tính chi phí mà công ty phải chi trả thưởng mỗi tháng cho các nhân viên.

    Gợi ý: Tạo 02 hàm như sau
	scalar function: 
	đầu vào: doanh số của nhân viên
	đầu ra: chi phí cty thưởng cho nhân viên

	table-valued function:
	đầu vào: tháng cần báo cáo
	đầu ra: bảng liệt kê các nhân viên và mức thưởng tương ứng
*/