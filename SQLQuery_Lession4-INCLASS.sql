use Northwind
CREATE OR ALTER FUNCTION fn_Fibonacci(@max int)
RETURNS @numbers TABLE(number int)
AS
BEGIN
	DECLARE @n1 INT = 0,@n2 INT =1,@i INT=0,@num int
	INSERT INTO @numbers VALUES(@n1),(@n2)
	WHILE (@i< @max-2)
	BEGIN 
		INSERT INTO @numbers Values(@n2+@n1)
		set @num = @n2
		Set @n2 = @n2 + @n1
		Set @n1 = @num
		Set @i += 1
	END	
	RETURN 
END
GO

SELECT * FROM dbo.fn_Fibonacci(10)
GO