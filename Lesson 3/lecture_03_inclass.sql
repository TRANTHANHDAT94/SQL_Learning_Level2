/* LECTURE 03 */

/* 1. Vòng lặp:
    Vòng lặp là cấu trúc điều khiển câu lệnh chạy lặp đi lặp lạit, gọi là loop. Mỗi lần lặp lại như vậy
    được gọi là 1 iteration (1 vòng).

    Có 02 loại vòng lặp trong ngôn ngữ lập trình:
    1. FOR...LOOP: Chạy lặp lại các câu lệnh theo một số lần định trước.
    2. WHILE...LOOP: Chạy lặp lại các câu lệnh cho đến khi không còn thỏa mãn điều kiện logic.
        Lưu ý: Phải luôn đảm bảo điều kiện của WHILE...LOOP chuyển thành không thỏa mãn sau
        một số lần chạy hữu hạn. Nếu ko code của bạn sẽ không bao giờ dừng lại được :<

    Trong SQL SERVER không có cú pháp cho FOR...LOOP mà chỉ có cú pháp 
    cho WHILE...LOOP. Tuy nhiên ta vẫn có thể sử dụng cú pháp WHILE...LOOP để tạo ra
    chức năng tương đương
*/

/* WHILE...LOOP 
    Cú pháp 
    WHILE <điều kiện>
    BEGIN -- block lệnh
        <Câu lệnh>
    END

    Để tạo lệnh tương đương FOR...LOOP cú pháp như sau:
    DECLARE @cnt INT = 0;
    WHILE @cnt < <một số hữu hạn> -- Ví dụ 5 lần 
    BEGIN
        <câu lệnh>
        SET @cnt = @cnt + 1 // 0 1 2 3 4 -> 5 (dừng lại) -- FALSE
    END
*/
USE Northwind
GO 

/* Ví dụ:
    Tạo hàm tính Tổ hợp chập k của một số n.
    Nếu giai thừa của một số n = n! = 1*2*3..*n
    Thì tổ hợp chập k của một số n được tính như sau: n!/((n-k)!*k!)
    Ví dụ: Tổ hợp chập 2 của 6 = 6!/(4!2!)
*/

-- Trước tiên tạo hàm tính giai thừa
CREATE OR ALTER FUNCTION func_Factorial (
    @number INT 
) RETURNS INT AS 
BEGIN 
    DECLARE 
        @cnt INT = 1
        , @fact INT = 1 -- Kết quả trả lại 
    WHILE @cnt <= @number -- Chạy từ 1...n
    BEGIN 
        SET @fact = @fact * @cnt -- 1*2*...*n
        SET @cnt = @cnt + 1 -- 2 3 4 5..n
    END 
    RETURN @fact
END 
GO 

SELECT dbo.func_Factorial(5)
GO 

-- Tạo hàm tính Tổ hợp
CREATE FUNCTION func_Combination(
    @n INT -- 6
    , @k INT -- 2
) RETURNS INT AS 
BEGIN 
    DECLARE -- Khai báo biến 
        @n_fact INT = dbo.func_Factorial(@n)
        , @k_fact INT = dbo.func_Factorial(@k)
        , @n_minus_k_fact INT = dbo.func_Factorial(@n - @k)

    RETURN @n_fact/(@k_fact*@n_minus_k_fact)
END 
GO 

SELECT dbo.func_Combination(6, 2)
GO

SELECT dbo.func_Combination(8, 3)
GO 

/* Thực hành 1:
    Viết hàm "func_SumEven" để tính tổng tất cả các số chắn từ 0 tới số n.
*/

CREATE OR ALTER FUNCTION func_SumEven(
    @start_num INT = 0 
    , @end_num INT 
) RETURNS INT AS 
BEGIN 
    DECLARE 
        @sum INT = 0 -- Giá trị kết quả trả lại 
    WHILE @start_num <= @end_num 
    BEGIN
        -- PRINT @start_num 
        IF @start_num%2=0
            SET @sum = @sum + @start_num 
        SET @start_num = @start_num + 1
    END 
    RETURN @sum
END 
GO 

SELECT dbo.func_SumEven(0, 10); -- 2 4 6 8 10 -- 24
GO



/* Thực hành 2:
    Viết hàm "func_CheckPrime" kiểm tra xem một số có phải nguyên tố hay ko?
    Gợi ý: Số nguyên tố chỉ chia hết cho 1 và chính bản thân nó. Chúng ta có thể
    thử tất cả các số. Tuy nhiên thông thường chỉ cần thử tới căn bậc 2 của số
    đó là đủ
*/

CREATE OR ALTER FUNCTION func_CheckPrime (
    @number INT 
) RETURNS BIT AS -- (1, 0)
BEGIN
    DECLARE 
        @start INT = 2, 
        @end INT = FLOOR(SQRT(@number)) -- Căn bậc 2 của số đấy
    WHILE @start <= @end
    BEGIN 
        IF @number%@start = 0 -- 51 có phải là số nguyên tố hay ko: chạy từ 2 đến căn 51
            RETURN 0 
        SET @start = @start + 1
    END 
    RETURN 1 
END 
GO 

SELECT dbo.func_CheckPrime(51)
GO 

/* Trong quá trình loop đôi khi chúng ta cần phá ra khỏi loop trước khi loop kết thúc
    hoặc đơng giản là bỏ qua không thực hiện hết một iteration và chuyển sang vòng tiếp theo
    ngay. Để thực hiện các thao tác can thiệp như vậy chúng ta có thể sử dụng từ khóa
    CONTINUE để bỏ qua vòng lặp hiện tại hoặc BREAK để phá ra khỏi loop.
*/

/* Ví dụ:
    Vẫn là hàm tìm số nguyên tố nhưng sử dụng BREAK
*/

/* Ví dụ minh họa CONTINUE
    WHILE 1..3
    BEGIN  -- 1
        command_1
        IF condition -- FALSE/TRUE // Ví dụ chạy từ 1 đến 3 nhưng đến 2 thì ăn vào lệnh IF
            CONTINUE <--
        command_2
        command_3 
    END 
    command_4

    -- Vòng 1: command_1 -> command_2 -> command_3
    -- Vòng 2: command_1
    -- Vòng 3: command_1 -> command_2 -> command 3
    -- command_4 

*/

/* Ví dụ minh họa CONTINUE
    WHILE 1..3
    BEGIN
        command_1
        IF condition -- FALSE/TRUE
            BREAK <-- 
        command_2
        command_3 
    END 
    command_4

    -- Vòng 1: command_1 -> command_2 -> command_3
    -- Vòng 2: command_1
    -- command_4 
*/

CREATE OR ALTER FUNCTION func_CheckPrime (
    @number INT 
) RETURNS BIT AS 
BEGIN 
    DECLARE 
        @bound INT
        , @cnt INT = 2
        , @result INT = 1 -- Tính là số nguyên tố cho đến khi chứng được điều ngược lại
    SET @bound = FLOOR(SQRT(@number)) -- Căn bậc 2
    WHILE @cnt <= @bound 
    BEGIN 
        IF @number%@cnt = 0
            SET @result = 0 -- Thay vì dùng lệnh RETURN thì thay thế bằng break
            BREAK
        SET @cnt = @cnt + 1
    END 
    RETURN @result
END 
GO 

SELECT dbo.func_CheckPrime(112)
GO 

/* Thực hành 3
    Bạn đã bao giờ nghe nói về dãy Fibonacci?
    Dãy Fibonacci bắt đầu bằng 0 và 1, sau đó các phần tử đứng sau được tính bằng
    tổng của 2 phần tử đứng trước.
    Hãy viết một thủ tục để in ra n phần tử đầu tiên của một dãy Fibonacci.
    Nếu n <= 2 thì chỉ in ra 2 phần tử đầu tiên là 0 và 1 thôi.
*/

/* 0 1 1 2 3 5 8 13 */
CREATE OR ALTER PROCEDURE proc_Fibonacci(
    @position INT 
) AS 
BEGIN -- a b a+b -> a tiếp theo = b, b tiếp theo = a+b
    DECLARE 
        @n1 INT = 0
        , @n2 INT = 1
        , @n INT 
        , @i INT = 2 
    PRINT @n1
    PRINT @n2 
	WHILE @i < @position
	BEGIN 
		SET @n = @n2 -- lưu lại giá trị của số sau
		SET @n2 = @n2 + @n1 -- đặt số sau mới bằng tổng số sau và số trước
		SET @n1 = @n -- đặt số trước mới bằng giá trị cũ của số sau
		SET @i += 1
        PRINT @n2 
	END	
END 
GO 

EXEC proc_Fibonacci 2
GO 

-- Đáp án của bạn Thu Trang
CREATE OR ALTER FUNCTION fn_Fibonacci(
    @max int
)
RETURNS @numbers TABLE(number int)
AS
BEGIN
	DECLARE 
        @n1 INT = 0
        , @n2 INT = 1
        , @i INT = 1 
        , @num INT 
	INSERT INTO @numbers VALUES (@n1), (@n2)
	WHILE (@i <= @max-2) -- @max -- vị trí trong dãy Fibo
    -- WHILE (@i <= @max) -- @i INT = 2
	BEGIN 
		INSERT INTO @numbers Values(@n2 + @n1)
		SET @num = @n2 -- lưu lại giá trị của số sau
		SET @n2 = @n2 + @n1 -- đặt số sau mới bằng tổng số sau và số trước
		SET @n1 = @num -- đặt số trước mới bằng giá trị cũ của số sau
		SET @i += 1
	END	
	RETURN 
END
GO

SELECT * 
FROM dbo.fn_Fibonacci(10)
GO


/* Biến dạng CURSOR 
    Biến dạng CURSOR là một dạng đặc biết giúp chúng ta loop qua các bản ghi của một
    câu SELECT

    Giúp ích trong việc xử lý dữ liệu được đọc liên tục từ một nguồn nào đấy.
    TRY...CATCH
*/


/* Ví dụ
    In ra bảng danh sách nhân viên có đơn hàng trong tháng 11-1997. Sử dụng 
    biến dạng CURSOR. 
*/

BEGIN 
    DECLARE 
        @EmployeeID INT
        , @EmployeeName VARCHAR(100)

    DECLARE CUR CURSOR FOR -- Khai báo biến CURSOR và nội dung
    SELECT DISTINCT 
        A.EmployeeID
        , B.FirstName + ' ' + B.LastName
    FROM dbo.Orders A
    JOIN dbo.Employees B 
        ON A.EmployeeID = B.EmployeeID
    WHERE OrderDate BETWEEN '1997-11-01' AND '1997-11-30'

    OPEN CUR -- Mở CURSOR 

    FETCH NEXT FROM CUR INTO @EmployeeID, @EmployeeName -- Lấy từng bản ghi ra

    WHILE @@FETCH_STATUS = 0 -- Kết thúc FETCH
    BEGIN 
        PRINT 'Nhan vien id=' + CONVERT(VARCHAR(5), @EmployeeID) + ' ten là: ' + @EmployeeName
        IF @EmployeeName LIKE 'Robert %' -- Ứng dụng của lệnh BREAK
            BREAK
        FETCH NEXT FROM CUR INTO @EmployeeID, @EmployeeName
    END

    CLOSE CUR -- Đóng con trỏ
    DEALLOCATE CUR -- Xóa bỏ con trỏ
END 
GO 

/* Thực hành 4
    Tạo hàm tính doanh số nếu biết số lượng, giá thành và tỉ lệ khấu trừ. Sau đó 
    viết block lệnh sử dụng CURSOR để in ra doanh số của từng nhân viên trong tháng
    08/1996.
*/

-- Viết hàm
CREATE OR ALTER FUNCTION func_RevenueCalc(
    @quantity FLOAT  
    , @price FLOAT
    , @discount FLOAT
) RETURNS FLOAT AS 
BEGIN
    RETURN @quantity*@price*(1-@discount)
END 
GO 

-- Câu SELECT để lấy ra doanh số nhân viên
SELECT 
    EmployeeID
    , SUM(dbo.func_RevenueCalc(B.Quantity, B.UnitPrice, B.Discount)) Revenue
FROM dbo.Orders A
JOIN dbo.[Order Details] B
    ON A.OrderID = B.OrderID 
GROUP BY A.EmployeeID
GO 


-- Viết Block lệnh sử dụng CURSOR
BEGIN 
    DECLARE @EmployeeID INT
        , @Revenue FLOAT

    DECLARE CUR CURSOR FOR 
    SELECT 
        EmployeeID
        , SUM(dbo.func_RevenueCalc(B.Quantity, B.UnitPrice, B.Discount)) Revenue
    FROM dbo.Orders A
    JOIN dbo.[Order Details] B
        ON A.OrderID = B.OrderID 
    GROUP BY A.EmployeeID
    ORDER BY EmployeeID
    
    OPEN CUR 

    FETCH NEXT FROM CUR INTO @EmployeeID, @Revenue

    WHILE @@FETCH_STATUS = 0
    BEGIN 
        PRINT CONCAT(N'Doanh thu của Nhân viên mã số ', @EmployeeID, ' là ', ROUND(@Revenue, 2))

        FETCH NEXT FROM CUR INTO @EmployeeID, @Revenue
    END 

    CLOSE CUR 
    DEALLOCATE CUR 
END 

/* Thực hành 5
    Sử dụng vòng lặp WHILE và con trỏ CURSOR để in ra nhân viên xuất sắc 
    nhất mỗi tháng. Yêu cầu kết quả in ra: 
    Nhân viên <tên nhân viên> đã đạt danh hiệu nhân viên xuất sắc nhất tại 
    tháng <tháng báo cáo>  với doanh thu <doanh thu trong tháng>
*/

/* Thực hành 6
    Sử dụng vòng lặp WHILE và con trỏ CURSOR để in ra top 3 quốc gia ship hàng tới 
    đạt doanh thu cao nhất hàng tháng trong năm 1997. 
    Yêu cầu kết quả in ra: 
    Tại tháng <tháng báo cáo>, quốc gia <tên quốc gia> đã đạt doanh thu cao nhất/thứ hai/thứ ba 
    với doanh thu <doanh thu trong tháng>
*/