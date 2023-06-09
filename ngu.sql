USE [master]
GO
/****** Object:  Database [BookStore]    Script Date: 18/5/2023 8:58:54 PM ******/
ALTER DATABASE [BookStore] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BookStore].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BookStore] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BookStore] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BookStore] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BookStore] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BookStore] SET ARITHABORT OFF 
GO
ALTER DATABASE [BookStore] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BookStore] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BookStore] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BookStore] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BookStore] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BookStore] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BookStore] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BookStore] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BookStore] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BookStore] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BookStore] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BookStore] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BookStore] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BookStore] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BookStore] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BookStore] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BookStore] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BookStore] SET RECOVERY FULL 
GO
ALTER DATABASE [BookStore] SET  MULTI_USER 
GO
ALTER DATABASE [BookStore] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BookStore] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BookStore] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BookStore] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BookStore] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BookStore] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'BookStore', N'ON'
GO
ALTER DATABASE [BookStore] SET QUERY_STORE = ON
GO
ALTER DATABASE [BookStore] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [BookStore]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetOrder_ByCustomer]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[Fn_GetOrder_ByCustomer]
(@CUSTOMER_ID INT)
RETURNS @CustomerOrder TABLE(
OrderID int, Name nvarchar(100), 
Date Date, [Shipping method] nvarchar(100),
[Total cost] float, Complete bit)
AS
BEGIN

	INSERT INTO @CustomerOrder(OrderID, Name, Date, [Shipping method], [Total cost], Complete)
	SELECT Orders.ID as Order_ID, Customers.Name, 
	Date, Shippings.Method as [Shipping method], dbo.Fn_Order_GetCost(Orders.ID) as [Total cost],
	Orders.Complete
	FROM Orders, Customers, Shippings
	WHERE Orders.Customer_ID = Customers.ID
	AND ShippingMethod_ID = Shippings.ID
	AND Customer_ID = @CUSTOMER_ID

	RETURN
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetRest_BookQuantity]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[Fn_GetRest_BookQuantity](@Book_ID int)
RETURNS int
AS
BEGIN
	DECLARE @Book_in int, @Book_out int;

	--get input books
	SELECT @Book_in = SUM(Warehouse_Books.Quantity)
	FROM Warehouse 
	INNER JOIN Warehouse_Books ON Warehouse.Seri = Warehouse_Books.Seri
	INNER JOIN Books ON Books.ID = Warehouse_Books.Book_ID
	WHERE Books.ID = @Book_ID
	GROUP BY Books.ID, Books.Name

	--get sold books
	SELECT @Book_out = SUM(Books_Orders.Amount)
	FROM Orders
	INNER JOIN Books_Orders ON Orders.ID = Books_Orders.Order_ID
	INNER JOIN Books ON Books.ID = Books_Orders.Book_ID
	WHERE Books.ID = @Book_ID
	GROUP BY Books.ID, Books.Name


	return @Book_in - @Book_out
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetRevenue_ByYearMonth]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[Fn_GetRevenue_ByYearMonth]
(@Month int, @Year int)
RETURNS @Revenue_Table TABLE(BookName nvarchar(200), Amount int, Revenue float)
AS
BEGIN

INSERT INTO @Revenue_Table(BookName, Amount, Revenue)
SELECT Books.Name, TEMP.[Amount of books],
Books.Price * [Amount of books] as Revenue
FROM
	(SELECT Books_Orders.Book_ID,
	SUM(Books_Orders.Amount) as [Amount of books]
	FROM Orders, Books_Orders
	WHERE Orders.ID = Books_Orders.Order_ID
	AND YEAR(Orders.Date) = @Year AND MONTH(Orders.Date) = @Month
	GROUP BY Books_Orders.Book_ID)
	AS TEMP, Books
	WHERE TEMP.Book_ID = Books.ID

RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetTop3_BestAuthorOfTheYear]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[Fn_GetTop3_BestAuthorOfTheYear](@Year nvarchar(10))
RETURNS @Top3_BestAuthorOfTheYear
TABLE ([Author name] nvarchar(100), [Amount of book sold] int)
AS
BEGIN
	
	INSERT INTO @Top3_BestAuthorOfTheYear([Author name], [Amount of book sold])
	SELECT TOP 3 Authors.Name, SUM(Books_Orders.Amount) as Sold
	FROM Orders
	INNER JOIN Books_Orders ON Orders.ID = Books_Orders.Order_ID
	INNER JOIN Books ON Books.ID = Books_Orders.Book_ID
	INNER JOIN Authors ON Books.Author_ID = Authors.ID
	WHERE YEAR(Orders.Date) = @Year
	GROUP BY Authors.Name
	ORDER BY [Sold] Desc

	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetTop5BestSellerOfTheYear]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[Fn_GetTop5BestSellerOfTheYear](@Year nvarchar(10))
RETURNS @Top5BestSeller 
TABLE (BookName nvarchar(100), Amount int)
AS
BEGIN
	
	INSERT INTO @Top5BestSeller(BookName, Amount)
	SELECT TOP 5 Books.Name, SUM(Books_Orders.Amount) as Sold
	FROM Orders
	INNER JOIN Books_Orders ON Orders.ID = Books_Orders.Order_ID
	INNER JOIN Books ON Books.ID = Books_Orders.Book_ID
	WHERE YEAR(Orders.Date) = @Year
	GROUP BY Books.Name
	ORDER BY [Sold] Desc

	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_GetUser]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[Fn_GetUser] 
(@Username nvarchar(100), @Password nvarchar(100))
RETURNS @USERTABLE
TABLE (ID	int,
Name	nvarchar(50),	
Address	nvarchar(50),	
Country	nvarchar(50),	
Phone	nvarchar(50),	
Email	nvarchar(50),	
UserName	varchar(50),
Password	varchar(50),	
[Level]	int)
AS
BEGIN
	--LOGIC CHECK USERNAME AND PW DONE IN BS LAYER
	--FUNCTION HANDLE RETURN CUSTOMER OBJECT WHEN TYPE CORRECT USERNAME AND PW
	INSERT INTO @USERTABLE(ID, Name, Address,Country,Phone,Email,UserName,Password,Level)
	SELECT * FROM CUSTOMERS
	WHERE Customers.UserName = @Username
	AND Customers.Password = @Password

	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_Order_GetCost]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[Fn_Order_GetCost]
(@OrderID FLOAT)
RETURNS FLOAT
AS
BEGIN

--GET PRICE FOR BOOKS
DECLARE @PriceOfBooks FLOAT
SELECT @PriceOfBooks = SUM(Price * Amount)
FROM Orders, Shippings, Books_Orders, Books
WHERE Orders.ID = Books_Orders.Order_ID
--AND Orders.Complete = 1
AND Orders.ShippingMethod_ID = Shippings.ID
AND Books.ID = Books_Orders.Book_ID
AND Order_ID = @OrderID

--GET SHIPPING COST
DECLARE @ShippingCost FLOAT
SELECT @ShippingCost = Cost
FROM Orders, Shippings
WHERE Orders.ShippingMethod_ID = Shippings.ID
AND Orders.ID = @OrderID 

--GET DISCOUNT
DECLARE @Discount FLOAT
SELECT  @Discount = DiscountRate
FROM CustomerLeveL, Customers, Orders
WHERE Customers.ID = Orders.Customer_ID
AND Customers.Level=CustomerLevel.Level
AND Orders.ID= @OrderID

RETURN @PriceOfBooks + @ShippingCost - @Discount/100*@PriceOfBooks
END
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_TotalCostOfCus_ID]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[Fn_TotalCostOfCus_ID] (@Cus_ID int)
RETURNS FLOAT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
DECLARE @Total_Cost_CusID FLOAT
SELECT @Total_Cost_CusID = SUM(COST)
FROM v_AllSumOrderByOrder_ID v
WHERE v.Customer_ID = @Cus_ID
RETURN @Total_Cost_CusID
END
GO
/****** Object:  Table [dbo].[Books_Orders]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books_Orders](
	[Order_ID] [int] NOT NULL,
	[Book_ID] [int] NOT NULL,
	[Amount] [int] NOT NULL,
 CONSTRAINT [PK_Books_Orders] PRIMARY KEY CLUSTERED 
(
	[Order_ID] ASC,
	[Book_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Customer_ID] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[ShippingMethod_ID] [int] NULL,
	[Payment_Method] [nvarchar](50) NULL,
	[Discount_Ship] [int] NULL,
	[Complete] [bit] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Books]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Price] [float] NOT NULL,
	[Author_ID] [int] NOT NULL,
	[Publisher_ID] [int] NOT NULL,
	[Release_Date] [date] NULL,
 CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Authors]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Authors](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Date] [date] NOT NULL,
 CONSTRAINT [PK_Authors] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_TopAuthors]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_TopAuthors]
AS
SELECT TOP 3 Authors.Name, TEMP.[Amount of books]
FROM (SELECT Books_Orders.Book_ID,
	SUM(Books_Orders.Amount) as [Amount of books]
	FROM Orders, Books_Orders
	WHERE Orders.ID = Books_Orders.Order_ID
	GROUP BY Books_Orders.Book_ID)
	AS TEMP, Books, Authors
WHERE TEMP.Book_ID = Books.ID
AND Books.Author_ID = Authors.ID
ORDER BY TEMP.[Amount of books] DESC
GO
/****** Object:  View [dbo].[v_Top3Authors]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_Top3Authors]
AS
SELECT TOP 3 Authors.Name, TEMP.[Amount of books]
FROM (SELECT Books_Orders.Book_ID,
	SUM(Books_Orders.Amount) as [Amount of books]
	FROM Orders, Books_Orders
	WHERE Orders.ID = Books_Orders.Order_ID
	GROUP BY Books_Orders.Book_ID)
	AS TEMP, Books, Authors
WHERE TEMP.Book_ID = Books.ID
AND Books.Author_ID = Authors.ID
ORDER BY TEMP.[Amount of books] DESC
GO
/****** Object:  View [dbo].[v_Top5Books]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_Top5Books]
AS
SELECT TOP 5 Books.Name, TEMP.[Amount of books]
FROM (SELECT Books_Orders.Book_ID,
	SUM(Books_Orders.Amount) as [Amount of books]
	FROM Orders, Books_Orders
	WHERE Orders.ID = Books_Orders.Order_ID
	GROUP BY Books_Orders.Book_ID)
	AS TEMP, Books
WHERE TEMP.Book_ID = Books.ID
ORDER BY TEMP.[Amount of books] DESC
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[Level] [int] NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_AllSumOrderByOrder_ID]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [dbo].[v_AllSumOrderByOrder_ID]
AS
SELECT Orders.ID , dbo.Fn_Order_GetCost (Orders.ID) AS COST, Orders.Customer_ID, Customers.Name
FROM Orders INNER JOIN Customers ON Orders.Customer_ID = Customers.ID
GO
/****** Object:  View [dbo].[v_AllSumOrderByCus_ID]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [dbo].[v_AllSumOrderByCus_ID]
AS
SELECT v.Customer_ID, dbo.Fn_TotalCostOfCus_ID (v.Customer_ID) AS Total_Cost, v.Name
FROM v_AllSumOrderByOrder_ID v
GROUP BY v.Customer_ID, v.Name
GO
/****** Object:  Table [dbo].[Publishers]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Publishers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Publishers] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_AllProducts]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_AllProducts]
AS
SELECT Books.Name Tittle, Books.Price, Authors.Name Author,
Publishers.Name Publisher, Books.Release_Date [Release date], dbo.Fn_GetRest_BookQuantity(Books.ID) as Rest
FROM Books
INNER JOIN Authors ON Authors.ID = Books.Author_ID
INNER JOIN Publishers ON Publishers.ID = Books.Author_ID
GO
/****** Object:  Table [dbo].[Authors_Publishers]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Authors_Publishers](
	[Publisher_ID] [int] NOT NULL,
	[Author_ID] [int] NOT NULL,
	[Apply_Date] [date] NOT NULL,
	[Severance_Date] [date] NULL,
 CONSTRAINT [PK_Authors_Publishers] PRIMARY KEY CLUSTERED 
(
	[Publisher_ID] ASC,
	[Author_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Books_Genres]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books_Genres](
	[Book_ID] [int] NOT NULL,
	[Genre_ID] [int] NOT NULL,
 CONSTRAINT [PK_Books_Genres] PRIMARY KEY CLUSTERED 
(
	[Book_ID] ASC,
	[Genre_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerLevel]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerLevel](
	[Level] [int] NOT NULL,
	[Desc] [nvarchar](50) NOT NULL,
	[DiscountRate] [float] NOT NULL,
 CONSTRAINT [PK_CustomerLevel] PRIMARY KEY CLUSTERED 
(
	[Level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Genres]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Genres](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Genres] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shippings]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shippings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Method] [nvarchar](50) NOT NULL,
	[Cost] [int] NOT NULL,
 CONSTRAINT [PK_Shippings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Warehouse]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Warehouse](
	[Seri] [int] NOT NULL,
	[Date] [date] NOT NULL,
 CONSTRAINT [PK_Warehouse] PRIMARY KEY CLUSTERED 
(
	[Seri] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Warehouse_Books]    Script Date: 18/5/2023 8:58:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Warehouse_Books](
	[Seri] [int] NOT NULL,
	[Book_ID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_Warehouse_Books] PRIMARY KEY CLUSTERED 
(
	[Seri] ASC,
	[Book_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Authors] ON 

INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (1, N'Regan Satterthwaite', CAST(N'1994-09-08' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (2, N'Haskell Hutcheon', CAST(N'1985-10-25' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (3, N'Floria Gurge', CAST(N'1977-08-04' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (4, N'Dru Killingsworth', CAST(N'1981-04-12' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (5, N'Twyla Barz', CAST(N'1986-08-30' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (6, N'Olivier Tremoulet', CAST(N'1985-11-04' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (7, N'Clo Mardling', CAST(N'1994-09-24' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (8, N'Gabby Burdis', CAST(N'1986-03-05' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (9, N'Sarette Goring', CAST(N'1976-03-07' AS Date))
INSERT [dbo].[Authors] ([ID], [Name], [Date]) VALUES (10, N'Rois Naire', CAST(N'1985-09-01' AS Date))
SET IDENTITY_INSERT [dbo].[Authors] OFF
GO
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (1, 4, CAST(N'1999-06-01' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (2, 6, CAST(N'1976-04-15' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (2, 8, CAST(N'2023-03-18' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (2, 10, CAST(N'2001-08-11' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (3, 1, CAST(N'2022-07-12' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (3, 10, CAST(N'2002-01-05' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (4, 3, CAST(N'1996-08-22' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (5, 3, CAST(N'2004-11-08' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (5, 4, CAST(N'2015-10-24' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (5, 6, CAST(N'1994-04-09' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (5, 9, CAST(N'1982-02-07' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (6, 4, CAST(N'1983-11-27' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (6, 9, CAST(N'1980-05-02' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (8, 1, CAST(N'2018-09-17' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (8, 2, CAST(N'2012-11-16' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (8, 3, CAST(N'2010-06-24' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (9, 5, CAST(N'2006-11-06' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (9, 6, CAST(N'1996-11-27' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (9, 7, CAST(N'1986-05-05' AS Date), NULL)
INSERT [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID], [Apply_Date], [Severance_Date]) VALUES (10, 8, CAST(N'1976-08-17' AS Date), NULL)
GO
SET IDENTITY_INSERT [dbo].[Books] ON 

INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (1, N'It', 30.15, 9, 6, CAST(N'2022-06-01' AS Date))
INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (2, N'Biodex', 34.89, 6, 9, CAST(N'2021-08-18' AS Date))
INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (3, N'Flowdesk', 16.37, 1, 3, CAST(N'2021-10-01' AS Date))
INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (4, N'Opela', 31.6, 4, 5, CAST(N'2020-07-31' AS Date))
INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (5, N'Keylex', 23.24, 6, 5, CAST(N'2021-07-09' AS Date))
INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (6, N'Alpha', 21.83, 10, 2, CAST(N'2022-10-01' AS Date))
INSERT [dbo].[Books] ([ID], [Name], [Price], [Author_ID], [Publisher_ID], [Release_Date]) VALUES (7, N'Daltfresh', 41.52, 3, 5, CAST(N'2022-08-22' AS Date))
SET IDENTITY_INSERT [dbo].[Books] OFF
GO
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (1, 7, 10)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (2, 1, 3)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (2, 3, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (2, 4, 10)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (3, 3, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (3, 5, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (3, 6, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (3, 7, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (4, 3, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (5, 2, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (6, 2, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (6, 6, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (7, 1, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (7, 3, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (7, 5, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (7, 7, 3)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (8, 4, 4)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (8, 5, 3)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (8, 7, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (9, 4, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (9, 5, 4)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (10, 3, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (10, 6, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (10, 7, 4)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (11, 2, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (11, 3, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (11, 7, 4)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (12, 1, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (12, 5, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (12, 7, 3)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (13, 1, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (13, 4, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (13, 6, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (13, 7, 2)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (14, 2, 5)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (14, 3, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (14, 5, 3)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (14, 7, 3)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (16, 4, 4)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (17, 5, 22)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (18, 2, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (18, 3, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (18, 4, 4)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (18, 6, 1)
INSERT [dbo].[Books_Orders] ([Order_ID], [Book_ID], [Amount]) VALUES (18, 7, 1)
GO
INSERT [dbo].[CustomerLevel] ([Level], [Desc], [DiscountRate]) VALUES (1, N'Bronze', 0)
INSERT [dbo].[CustomerLevel] ([Level], [Desc], [DiscountRate]) VALUES (2, N'Silver', 2)
INSERT [dbo].[CustomerLevel] ([Level], [Desc], [DiscountRate]) VALUES (3, N'Gold', 4)
INSERT [dbo].[CustomerLevel] ([Level], [Desc], [DiscountRate]) VALUES (4, N'Platinum', 7)
INSERT [dbo].[CustomerLevel] ([Level], [Desc], [DiscountRate]) VALUES (5, N'Diamond', 10)
GO
SET IDENTITY_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([ID], [Name], [Address], [Country], [Phone], [Email], [UserName], [Password], [Level]) VALUES (1, N'Huu Nhan', N'42 Nguyen Thi Tan', N'VietNam', N'928312747', N'nhanhohuunhan7398@gmail.com', N'lynkdoll0122', N'nhan1111', 2)
INSERT [dbo].[Customers] ([ID], [Name], [Address], [Country], [Phone], [Email], [UserName], [Password], [Level]) VALUES (2, N'Thanh Vy', N'Houston Texas', N'USA', N'123889101', N'ThanhVy@gmai..com', N'vythanh123', N'vy123123', 5)
INSERT [dbo].[Customers] ([ID], [Name], [Address], [Country], [Phone], [Email], [UserName], [Password], [Level]) VALUES (3, N'ZangHa', N'Ho Chi Minh City', N'VietNam', N'98939104', N'zangha@gmail.com', N'zangha', N'ha913', NULL)
INSERT [dbo].[Customers] ([ID], [Name], [Address], [Country], [Phone], [Email], [UserName], [Password], [Level]) VALUES (6, N'ZangHa', N'Ho Chi Minh City', N'VietNam', N'98939104', N'zangha@gmail.com', N'zangha2', N'ha0912', NULL)
SET IDENTITY_INSERT [dbo].[Customers] OFF
GO
SET IDENTITY_INSERT [dbo].[Genres] ON 

INSERT [dbo].[Genres] ([ID], [Name]) VALUES (1, N'Action')
INSERT [dbo].[Genres] ([ID], [Name]) VALUES (3, N'horror')
SET IDENTITY_INSERT [dbo].[Genres] OFF
GO
SET IDENTITY_INSERT [dbo].[Orders] ON 

INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (1, 2, CAST(N'2022-09-21' AS Date), 3, N'COD', 50, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (2, 2, CAST(N'2023-02-07' AS Date), 3, N'COD', 50, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (3, 1, CAST(N'2022-06-17' AS Date), 1, N'COD', 0, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (4, 2, CAST(N'2022-11-12' AS Date), 4, N'COD', 0, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (5, 2, CAST(N'2022-01-04' AS Date), 4, N'COD', 0, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (6, 2, CAST(N'2021-07-22' AS Date), 3, N'COD', 0, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (7, 1, CAST(N'2021-11-30' AS Date), 1, N'COD', 10, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (8, 2, CAST(N'2022-07-28' AS Date), 3, N'COD', 0, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (9, 2, CAST(N'2020-07-29' AS Date), 4, N'COD', 0, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (10, 2, CAST(N'2023-03-28' AS Date), 3, N'COD', 50, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (11, 1, CAST(N'2020-05-03' AS Date), 2, N'COD', 20, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (12, 1, CAST(N'2022-06-13' AS Date), 2, N'COD', 20, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (13, 1, CAST(N'2022-06-01' AS Date), 2, N'Bank', 20, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (14, 2, CAST(N'2022-06-08' AS Date), 3, N'Paypal', 50, 1)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (16, 1, CAST(N'2023-05-18' AS Date), 1, N'COD', 10, 0)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (17, 1, CAST(N'2023-05-18' AS Date), 1, N'COD', 10, 0)
INSERT [dbo].[Orders] ([ID], [Customer_ID], [Date], [ShippingMethod_ID], [Payment_Method], [Discount_Ship], [Complete]) VALUES (18, 1, CAST(N'2023-05-18' AS Date), 1, N'Bank', 10, 0)
SET IDENTITY_INSERT [dbo].[Orders] OFF
GO
SET IDENTITY_INSERT [dbo].[Publishers] ON 

INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (1, N'Odelinda Ruddin')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (2, N'Ibrahim Shireff')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (3, N'Sully Morena')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (4, N'Fawn Dimblebee')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (5, N'Bunny Arundale')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (6, N'Ginger Levet')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (7, N'Florinda Cabble')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (8, N'Ben Kittless')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (9, N'Kikelia Bonellie')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (10, N'Blair Veld')
INSERT [dbo].[Publishers] ([ID], [Name]) VALUES (11, N'zangha')
SET IDENTITY_INSERT [dbo].[Publishers] OFF
GO
SET IDENTITY_INSERT [dbo].[Shippings] ON 

INSERT [dbo].[Shippings] ([ID], [Method], [Cost]) VALUES (1, N'Local Car', 10)
INSERT [dbo].[Shippings] ([ID], [Method], [Cost]) VALUES (2, N'Private MotorBike', 20)
INSERT [dbo].[Shippings] ([ID], [Method], [Cost]) VALUES (3, N'Ship', 50)
INSERT [dbo].[Shippings] ([ID], [Method], [Cost]) VALUES (4, N'Air', 100)
SET IDENTITY_INSERT [dbo].[Shippings] OFF
GO
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (1, CAST(N'2021-09-30' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (2, CAST(N'2023-01-03' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (3, CAST(N'2022-03-24' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (4, CAST(N'2023-01-28' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (5, CAST(N'2021-01-26' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (6, CAST(N'2021-02-23' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (7, CAST(N'2023-03-14' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (8, CAST(N'2021-07-03' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (9, CAST(N'2022-03-26' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (10, CAST(N'2021-03-05' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (11, CAST(N'2020-09-16' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (12, CAST(N'2022-06-18' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (13, CAST(N'2021-10-25' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (14, CAST(N'2022-07-21' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (15, CAST(N'2021-12-13' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (16, CAST(N'2021-04-25' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (17, CAST(N'2020-09-22' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (18, CAST(N'2020-10-02' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (19, CAST(N'2021-06-09' AS Date))
INSERT [dbo].[Warehouse] ([Seri], [Date]) VALUES (20, CAST(N'2022-01-15' AS Date))
GO
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (1, 6, 33)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (1, 7, 27)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (2, 2, 38)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (2, 3, 30)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (2, 5, 33)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (3, 1, 22)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (3, 2, 38)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (4, 1, 33)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (5, 1, 28)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (5, 5, 33)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (6, 2, 21)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (6, 6, 29)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (8, 1, 25)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (8, 3, 24)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (8, 4, 37)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (8, 5, 39)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (8, 7, 22)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (9, 1, 26)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (9, 2, 31)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (9, 4, 21)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (9, 7, 20)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (10, 2, 28)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (10, 3, 22)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (10, 5, 33)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (10, 6, 34)
INSERT [dbo].[Warehouse_Books] ([Seri], [Book_ID], [Quantity]) VALUES (10, 7, 29)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [un_UserName]    Script Date: 18/5/2023 8:58:56 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [un_UserName] UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Authors_Publishers]  WITH CHECK ADD  CONSTRAINT [FK_Authors_Publishers_Authors] FOREIGN KEY([Author_ID])
REFERENCES [dbo].[Authors] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Authors_Publishers] CHECK CONSTRAINT [FK_Authors_Publishers_Authors]
GO
ALTER TABLE [dbo].[Authors_Publishers]  WITH CHECK ADD  CONSTRAINT [FK_Authors_Publishers_Publishers] FOREIGN KEY([Publisher_ID])
REFERENCES [dbo].[Publishers] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Authors_Publishers] CHECK CONSTRAINT [FK_Authors_Publishers_Publishers]
GO
ALTER TABLE [dbo].[Books]  WITH CHECK ADD  CONSTRAINT [FK_Books_Authors_Publishers] FOREIGN KEY([Publisher_ID], [Author_ID])
REFERENCES [dbo].[Authors_Publishers] ([Publisher_ID], [Author_ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Books] CHECK CONSTRAINT [FK_Books_Authors_Publishers]
GO
ALTER TABLE [dbo].[Books_Genres]  WITH CHECK ADD  CONSTRAINT [FK_Books_Genres_Books] FOREIGN KEY([Book_ID])
REFERENCES [dbo].[Books] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Books_Genres] CHECK CONSTRAINT [FK_Books_Genres_Books]
GO
ALTER TABLE [dbo].[Books_Genres]  WITH CHECK ADD  CONSTRAINT [FK_Books_Genres_Genres] FOREIGN KEY([Genre_ID])
REFERENCES [dbo].[Genres] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Books_Genres] CHECK CONSTRAINT [FK_Books_Genres_Genres]
GO
ALTER TABLE [dbo].[Books_Orders]  WITH CHECK ADD  CONSTRAINT [FK_Books_Orders_Books] FOREIGN KEY([Book_ID])
REFERENCES [dbo].[Books] ([ID])
GO
ALTER TABLE [dbo].[Books_Orders] CHECK CONSTRAINT [FK_Books_Orders_Books]
GO
ALTER TABLE [dbo].[Books_Orders]  WITH CHECK ADD  CONSTRAINT [FK_Books_Orders_Orders] FOREIGN KEY([Order_ID])
REFERENCES [dbo].[Orders] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Books_Orders] CHECK CONSTRAINT [FK_Books_Orders_Orders]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FK_Customers_CustomerLevel] FOREIGN KEY([Level])
REFERENCES [dbo].[CustomerLevel] ([Level])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FK_Customers_CustomerLevel]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Books_Customers_Customers] FOREIGN KEY([Customer_ID])
REFERENCES [dbo].[Customers] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Books_Customers_Customers]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Shippings] FOREIGN KEY([ShippingMethod_ID])
REFERENCES [dbo].[Shippings] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Shippings]
GO
ALTER TABLE [dbo].[Warehouse_Books]  WITH CHECK ADD  CONSTRAINT [FK_Warehouse_Books_Books] FOREIGN KEY([Book_ID])
REFERENCES [dbo].[Books] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Warehouse_Books] CHECK CONSTRAINT [FK_Warehouse_Books_Books]
GO
ALTER TABLE [dbo].[Warehouse_Books]  WITH CHECK ADD  CONSTRAINT [FK_Warehouse_Books_Warehouse] FOREIGN KEY([Seri])
REFERENCES [dbo].[Warehouse] ([Seri])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Warehouse_Books] CHECK CONSTRAINT [FK_Warehouse_Books_Warehouse]
GO
ALTER TABLE [dbo].[Authors]  WITH CHECK ADD  CONSTRAINT [

ERROR:
Author must be older than 18 years old

] CHECK  (((datepart(year,getdate())-datepart(year,[Authors].[Date]))>=(18)))
GO
ALTER TABLE [dbo].[Authors] CHECK CONSTRAINT [

ERROR:
Author must be older than 18 years old

]
GO
/****** Object:  StoredProcedure [dbo].[add_customer_level]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[add_customer_level]
    @level int,
    @desc varchar(50),
    @discountRate decimal(10, 2)
AS
BEGIN
    INSERT INTO customer_level (level, [desc], discountRate)
    VALUES (@level, @desc, @discountRate);
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Add_Author_Publisher]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Add_Author_Publisher] (
    @publisher_id INT,
    @author_id INT,
    @apply_date DATE,
    @severance_date DATE
) AS
BEGIN
    INSERT INTO authors_publishers (publisher_id, author_id, apply_date, severance_date)
    VALUES (@publisher_id, @author_id, @apply_date, @severance_date);
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Add_Books_Genres]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Add_Books_Genres]
    @genre_ID INT,
    @book_ID INT
AS
BEGIN
    INSERT INTO books_genres (genre_ID, book_ID)
    VALUES (@genre_ID, @book_ID)
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Add_books_orders]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Add_books_orders]
    @order_ID int,
    @book_ID int,
    @amount int
AS
BEGIN
    INSERT INTO books_orders (order_ID, book_ID, amount)
    VALUES (@order_ID, @book_ID, @amount);
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_add_customer_level]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_add_customer_level]
    @level int,
    @desc nvarchar(100),
    @discountRate int
AS
BEGIN
    INSERT INTO customer_level ([level], [desc], discountRate)
    VALUES (@level, @desc, @discountRate);
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Add_WareHouse]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Add_WareHouse] 
   @seri int, 
   @date datetime
AS
BEGIN
   INSERT INTO warehouse (seri, date)
   VALUES (@seri, @date)
END
GO
/****** Object:  StoredProcedure [dbo].[PR_add_warehouse_book]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PR_add_warehouse_book]
    @seri INT,
    @book_ID INT,
    @quantity INT
AS
BEGIN
    INSERT INTO warehouse_book (seri, book_ID, quantity)
    VALUES (@seri, @book_ID, @quantity)
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddAuthor]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--add authors
CREATE   PROCEDURE [dbo].[Pr_AddAuthor]
  @name varchar(50),
  @date datetime
AS
BEGIN
  INSERT INTO authors (name, date)
  VALUES (@name, @date);
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddBook]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[Pr_AddBook]
@Name nvarchar(100),
@Price float,
@Author_Name nvarchar(100),
@Publisher_Name nvarchar(100),
@Release_date date
AS
	DECLARE @Author_ID int, @Publisher_ID int

	--Get Author ID and Publisher ID
	SELECT @Author_ID = Authors.ID, @Publisher_ID = Publishers.ID 
	FROM Authors_Publishers 
		INNER JOIN Authors ON Authors_Publishers.Author_ID = Authors.ID
		INNER JOIN Publishers ON Authors_Publishers.Publisher_ID = Publishers.ID
	WHERE 
		Authors.Name = @Author_Name AND
		Publishers.Name = @Publisher_Name

	--CATCH ERROR
	IF (@Author_ID IS NULL OR @Publisher_ID IS NULL)
	BEGIN
		PRINT 'Author and publisher value dont match'
		RETURN
	END

	--HANDLE ADD TO BOOKS
	INSERT INTO Books(Name, Price, Author_ID, Publisher_ID, Release_Date)
	VALUES(@Name, @Price, @Author_ID, @Publisher_ID, @Release_date)
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddCustomer]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--add customer
CREATE   PROCEDURE [dbo].[Pr_AddCustomer]
    @name VARCHAR(50),
    @address VARCHAR(100),
    @country VARCHAR(50),
    @phone VARCHAR(20),
    @email VARCHAR(50),
    @username VARCHAR(20),
    @password VARCHAR(20)
AS
BEGIN
    INSERT INTO customers(name, address, country, phone, email, username, password)
    VALUES(@name, @address, @country, @phone, @email, @username, @password)
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddGenre]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--add genre
CREATE   PROCEDURE [dbo].[Pr_AddGenre]
    @name nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO genres (name)
    VALUES (@name);
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddOrder]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--add order
CREATE   PROCEDURE [dbo].[Pr_AddOrder]
    @customerID INT,
    @date DATETIME,
    @shippingMethodID INT,
    @paymentMethod VARCHAR(50),
    @discountShip DECIMAL(10,2)
AS
BEGIN
    INSERT INTO orders (customer_ID, date, shippingMethod_ID, payment_method, discount_ship, Complete)
    VALUES (@customerID, @date, @shippingMethodID, @paymentMethod, @discountShip, 0)
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddPublisher]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--add publisher
CREATE   PROCEDURE [dbo].[Pr_AddPublisher]
    @Name NVARCHAR(50)
AS
BEGIN
    INSERT INTO publishers (name)
    VALUES (@Name)
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_AddShippingMethod]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_AddShippingMethod]
    @Method NVARCHAR(50),
    @Cost DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO shippings (method, cost)
    VALUES (@Method, @Cost)
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Delete_Author_Publisher]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Delete_Author_Publisher]
    @publisher_ID INT,
    @author_ID INT
AS
BEGIN
    DELETE FROM authors_publishers
    WHERE publisher_ID = @publisher_ID AND author_ID = @author_ID
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Delete_Books_Genres]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Delete_Books_Genres]
    @genre_ID int,
    @book_ID int
AS
BEGIN
    DELETE FROM books_genres 
    WHERE genre_ID = @genre_ID AND book_ID = @book_ID
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Delete_books_order]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE  [dbo].[Pr_Delete_books_order]
    @order_ID INT,
    @book_ID INT
AS
BEGIN
    DELETE FROM books_orders
    WHERE order_ID = @order_ID AND book_ID = @book_ID;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_delete_customer_level]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_delete_customer_level]
(
    @level INT
)
AS
BEGIN
    DELETE FROM customer_level
    WHERE [level] = @level;
END;
GO
/****** Object:  StoredProcedure [dbo].[Pr_Delete_publisher]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--delete publisher
CREATE PROCEDURE [dbo].[Pr_Delete_publisher]
    @publisher_id INT
AS
BEGIN
    DELETE FROM publishers
    WHERE ID = @publisher_id;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Delete_Warehouse]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Pr_Delete_Warehouse]
    @seri INT
AS
BEGIN
    DELETE FROM warehouse
    WHERE seri = @seri;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_delete_warehouse_book]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_delete_warehouse_book]
    @seri INT,
    @book_ID INT
AS
BEGIN
    DELETE FROM warehouse_book
    WHERE seri = @seri AND book_ID = @book_ID
END
GO
/****** Object:  StoredProcedure [dbo].[PR_DeleteAuthor]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PR_DeleteAuthor]
    @author_id INT
AS
BEGIN
    DELETE FROM authors
    WHERE ID = @author_id
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_DeleteBook]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[Pr_DeleteBook]
@ID int
AS
	--HANDLE DELETE TO BOOKS
	DELETE FROM Books
	WHERE Books.ID = @ID
GO
/****** Object:  StoredProcedure [dbo].[Pr_DeleteCustomer]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[Pr_DeleteCustomer]
@ID int
AS
	--HANDLE DELETE TO CUSTOMER
	DELETE FROM Customers
	WHERE Customers.ID = @ID
GO
/****** Object:  StoredProcedure [dbo].[Pr_DeleteGenre]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--delete genre
CREATE   PROCEDURE [dbo].[Pr_DeleteGenre]
    @id INT
AS
BEGIN
    DELETE FROM genres
    WHERE id = @id;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_DeleteOrder]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--delete order
CREATE   PROCEDURE [dbo].[Pr_DeleteOrder]
    @orderID INT
AS
BEGIN
    DELETE FROM orders WHERE ID = @orderID;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_DeleteShipping]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_DeleteShipping]
    @ID int
AS
BEGIN
    DELETE FROM shippings
    WHERE ID = @ID;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_SetCustomerLevel]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[Pr_SetCustomerLevel]
@customer_ID INT
AS
BEGIN
    DECLARE @TotalCost FLOAT
    DECLARE @Level INT

    SELECT @TotalCost = v.Total_Cost
    FROM v_AllSumOrderByCus_ID v
    WHERE v.Customer_ID = @customer_ID

    IF @TotalCost BETWEEN 500 AND 1000
        SET @Level = 1
    ELSE IF @TotalCost BETWEEN 1100 AND 1500
        SET @Level = 2
	ELSE IF @TotalCost BETWEEN 1600 AND 2000
        SET @Level = 3
	ELSE IF @TotalCost BETWEEN 2100 AND 2500
        SET @Level = 4
	ELSE IF @TotalCost > 2600 
        SET @Level = 5
    --ELSE
    --    SET @Level = 'Regular'

    -- Update the customer table with the new level
    UPDATE Customers
    SET [level] = @level
    WHERE ID = @customer_ID
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Update_Author_Publisher]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--update authors publisher
CREATE   PROCEDURE [dbo].[Pr_Update_Author_Publisher]
    @publisher_id INT,
    @author_id INT,
    @apply_date DATE,
    @severance_date DATE
AS
BEGIN
    UPDATE authors_publishers
    SET apply_date = @apply_date,
        severance_date = @severance_date
    WHERE publisher_id = @publisher_id AND author_id = @author_id
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Update_books_order]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Update_books_order]
  @id INT,
  @order_id INT,
  @book_id INT,
  @amount INT
AS
BEGIN
  UPDATE books_orders
  SET order_id = @order_id,
      book_id = @book_id,
      amount = @amount
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_update_customer_level]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_update_customer_level]
    @level INT,
    @desc NVARCHAR(100),
    @discountRate INT,
    @oldLevel INT
AS
BEGIN
    UPDATE customer_level
    SET [level] = @level,
        [desc] = @desc,
        discountRate = @discountRate
    WHERE [level] = @oldLevel;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_Update_Warehouse]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_Update_Warehouse]
    @seri INT,
    @date DATETIME
AS
BEGIN
    UPDATE warehouse
    SET date = @date
    WHERE seri = @seri
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_update_warehouse_book]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_update_warehouse_book]
(
  @seri INT,
  @book_ID INT,
  @quantity INT
)
AS
BEGIN
  UPDATE warehouse_book
  SET quantity = @quantity
  WHERE seri = @seri AND book_ID = @book_ID;
END;
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateAuthor]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_UpdateAuthor]
    @ID INT,
    @name NVARCHAR(50),
    @date DATE
AS
BEGIN
    UPDATE authors 
    SET name = @name, date = @date
    WHERE ID = @ID
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateBook]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[Pr_UpdateBook]
@ID int,
@Name nvarchar(100),
@Price float,
@Author_Name nvarchar(100),
@Publisher_Name nvarchar(100),
@Release_date date
AS
	DECLARE @Author_ID int, @Publisher_ID int

	--Get Author ID and Publisher ID
	SELECT @Author_ID = Authors.ID, @Publisher_ID = Publishers.ID 
	FROM Authors_Publishers 
		INNER JOIN Authors ON Authors_Publishers.Author_ID = Authors.ID
		INNER JOIN Publishers ON Authors_Publishers.Publisher_ID = Publishers.ID
	WHERE 
		Authors.Name = @Author_Name AND
		Publishers.Name = @Publisher_Name

	--CATCH ERROR
	IF (@Author_ID IS NULL OR @Publisher_ID IS NULL)
	BEGIN
		PRINT 'Author and publisher value dont match'
		RETURN
	END

	--HANDLE ADD TO BOOKS
	UPDATE Books
	SET Books.Name = @Name, 
	Books.Price = @Price, 
	Books.Author_ID = @Author_ID, 
	Books.Publisher_ID = @Publisher_ID,
	Books.Release_Date = @Release_date
	WHERE Books.ID = @ID
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateBooksGenres]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_UpdateBooksGenres]
    @genre_ID INT,
    @book_ID INT,
    @old_genre_ID INT,
    @old_book_ID INT
AS
BEGIN
    UPDATE books_genres
    SET genre_ID = @genre_ID, book_ID = @book_ID
    WHERE genre_ID = @old_genre_ID AND book_ID = @old_book_ID
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateCustomer]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Update Customer
CREATE   PROCEDURE [dbo].[Pr_UpdateCustomer]
    @id INT,
    @name NVARCHAR(50),
    @address NVARCHAR(100),
    @country NVARCHAR(50),
    @phone NVARCHAR(20),
    @email NVARCHAR(50),
    @username NVARCHAR(50),
    @password NVARCHAR(50)
AS
BEGIN
    UPDATE Customers
    SET name = @name,
        address = @address,
        country = @country,
        phone = @phone,
        email = @email,
        username = @username,
        password = @password
    WHERE id = @id;
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateGenre]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--update genre
CREATE   PROCEDURE [dbo].[Pr_UpdateGenre]
  @genre_id INT,
  @name VARCHAR(50)
AS
BEGIN
  UPDATE genres
  SET name = @name
  WHERE ID = @genre_id
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateOrder]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_UpdateOrder]
    @order_id INT,
    @customer_id INT,
    @date DATE,
    @shipping_id INT,
    @payment_method VARCHAR(50),
    @discount_ship FLOAT
AS
BEGIN
    UPDATE orders
    SET customer_ID = @customer_id,
        date = @date,
        shippingMethod_ID = @shipping_id,
        payment_method = @payment_method,
        discount_ship = @discount_ship
    WHERE ID = @order_id
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdatePublisher]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Pr_UpdatePublisher]
    @publisher_id INT,
    @publisher_name VARCHAR(255)
AS
BEGIN
    UPDATE publishers
    SET name = @publisher_name
    WHERE ID = @publisher_id
END
GO
/****** Object:  StoredProcedure [dbo].[Pr_UpdateShipping]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Pr_UpdateShipping]
    @ID INT,
    @Method VARCHAR(50),
    @Cost DECIMAL(10, 2)
AS
BEGIN
    UPDATE shippings
    SET method = @Method,
        cost = @Cost
    WHERE ID = @ID
END
GO
/****** Object:  Trigger [dbo].[INSERT_UPDATE_AUTHORS_PUBLISHER]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[INSERT_UPDATE_AUTHORS_PUBLISHER]
ON [dbo].[Authors_Publishers] FOR INSERT, UPDATE
AS
	declare @countError int
	SELECT @countError = COUNT(*) 
	FROM inserted A
	WHERE EXISTS
	(SELECT AP.Author_ID, COUNT(AP.Author_ID) 
	FROM Authors_Publishers AP
	WHERE A.Author_ID = AP.Author_ID
	GROUP BY AP.Author_ID
	HAVING COUNT(AP.Author_ID) > 3)

	IF(@countError > 0)
	begin
		rollback tran
		print 'Each authors are just able to work for at most 3 publishers'
	end
GO
ALTER TABLE [dbo].[Authors_Publishers] ENABLE TRIGGER [INSERT_UPDATE_AUTHORS_PUBLISHER]
GO
/****** Object:  Trigger [dbo].[Trig_applyDate_serveranceDate]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Trig_applyDate_serveranceDate] 
ON [dbo].[Authors_Publishers] FOR INSERT, UPDATE
AS
	declare @COUNT INT
	
	SELECT @COUNT = COUNT(A.Author_ID) FROM inserted A
	WHERE EXISTS 
	(SELECT * FROM inserted B 
	WHERE A.Author_ID = B.Author_ID AND
	B.Severance_Date IS NOT NULL AND
	B.Apply_Date >= B.Severance_Date)

	IF (@COUNT > 0)
	BEGIN 
		ROLLBACK TRAN
		PRINT '
		

[ERROR]: Serverance date cannot exist before apply date
		
		
		'
	END
GO
ALTER TABLE [dbo].[Authors_Publishers] ENABLE TRIGGER [Trig_applyDate_serveranceDate]
GO
/****** Object:  Trigger [dbo].[Trig_AutoSetDiscount_FreeShip_Close]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Trig_AutoSetDiscount_FreeShip_Close]
ON [dbo].[Books_Orders] AFTER INSERT, UPDATE
AS
	WITH TrueCondition(Order_ID, [Cost of Products]) AS
		(SELECT Order_ID, SUM(Price * Amount) AS [Cost of Products]
		FROM 
			Books_Orders A INNER JOIN Books B ON A.Book_ID = B.ID
			INNER JOIN Orders O ON O.ID = A.Order_ID
			INNER JOIN Shippings S ON O.ShippingMethod_ID = S.ID
		WHERE
			(S.Method LIKE 'Local Car'
			OR S.Method LIKE 'Private MotorBike')
		GROUP BY A.Order_ID
		HAVING SUM(Price * Amount) > 120)
	UPDATE Orders
	SET Discount_Ship = (SELECT COST FROM Shippings WHERE Orders.ShippingMethod_ID = Shippings.ID)
	WHERE EXISTS
		(SELECT * FROM TrueCondition T WHERE T.Order_ID = Orders.ID)
GO
ALTER TABLE [dbo].[Books_Orders] ENABLE TRIGGER [Trig_AutoSetDiscount_FreeShip_Close]
GO
/****** Object:  Trigger [dbo].[Trig_AutoSetDiscount_FreeShip_Far]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Trig_AutoSetDiscount_FreeShip_Far]
ON [dbo].[Books_Orders] AFTER INSERT, UPDATE
AS
	WITH TrueCondition(Order_ID, [Cost of Products]) AS
		(SELECT Order_ID, SUM(Price * Amount) AS [Cost of Products]
		FROM 
			Books_Orders A INNER JOIN Books B ON A.Book_ID = B.ID
			INNER JOIN Orders O ON O.ID = A.Order_ID
			INNER JOIN Shippings S ON O.ShippingMethod_ID = S.ID
		WHERE
			(S.Method LIKE 'Air'
			OR S.Method LIKE 'Ship')
		GROUP BY A.Order_ID
		HAVING SUM(Price * Amount) > 300)
	UPDATE Orders
	SET Discount_Ship = (SELECT COST FROM Shippings WHERE Orders.ShippingMethod_ID = Shippings.ID)
	WHERE EXISTS
		(SELECT * FROM TrueCondition T WHERE T.Order_ID = Orders.ID)
GO
ALTER TABLE [dbo].[Books_Orders] ENABLE TRIGGER [Trig_AutoSetDiscount_FreeShip_Far]
GO
/****** Object:  Trigger [dbo].[Trig_AutoSetDiscount_NoneDiscount_Close]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   TRIGGER [dbo].[Trig_AutoSetDiscount_NoneDiscount_Close]
ON [dbo].[Books_Orders] AFTER INSERT, UPDATE
AS
	WITH TrueCondition(Order_ID, [Cost of Products]) AS
		(SELECT Order_ID, SUM(Price * Amount) AS [Cost of Products]
		FROM 
			Books_Orders A INNER JOIN Books B ON A.Book_ID = B.ID
			INNER JOIN Orders O ON O.ID = A.Order_ID
			INNER JOIN Shippings S ON O.ShippingMethod_ID = S.ID
		WHERE
			(S.Method LIKE 'Local Car'
			OR S.Method LIKE 'Private MotorBike')
		GROUP BY A.Order_ID
		HAVING SUM(Price * Amount) <= 120)
	UPDATE Orders
	SET Discount_Ship = 0
	WHERE EXISTS
		(SELECT * FROM TrueCondition T WHERE T.Order_ID = Orders.ID)
GO
ALTER TABLE [dbo].[Books_Orders] ENABLE TRIGGER [Trig_AutoSetDiscount_NoneDiscount_Close]
GO
/****** Object:  Trigger [dbo].[Trig_AutoSetDiscount_NoneDiscount_Far]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Trig_AutoSetDiscount_NoneDiscount_Far]
ON [dbo].[Books_Orders] AFTER INSERT, UPDATE
AS
	WITH TrueCondition(Order_ID, [Cost of Products]) AS
		(SELECT Order_ID, SUM(Price * Amount) AS [Cost of Products]
		FROM 
			Books_Orders A INNER JOIN Books B ON A.Book_ID = B.ID
			INNER JOIN Orders O ON O.ID = A.Order_ID
			INNER JOIN Shippings S ON O.ShippingMethod_ID = S.ID
		WHERE
			(S.Method LIKE 'Air'
			OR S.Method LIKE 'Ship')
		GROUP BY A.Order_ID
		HAVING SUM(Price * Amount) <= 300)
	UPDATE Orders
	SET Discount_Ship = 0
	WHERE EXISTS
		(SELECT * FROM TrueCondition T WHERE T.Order_ID = Orders.ID)
GO
ALTER TABLE [dbo].[Books_Orders] ENABLE TRIGGER [Trig_AutoSetDiscount_NoneDiscount_Far]
GO
/****** Object:  Trigger [dbo].[INSERT_UPDATE_PASSWORD]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[INSERT_UPDATE_PASSWORD]
ON [dbo].[Customers] FOR INSERT, UPDATE
as
	declare @countError int
	SELECT @countError = COUNT(*)
	FROM inserted NewCustomers
	WHERE NewCustomers.Password NOT LIKE '%[a-z]%' OR NewCustomers.Password NOT LIKE '%[0-9]%'

	IF(@countError > 0)
	begin
		rollback tran
		print 'Password must contain characters and number'
	end
GO
ALTER TABLE [dbo].[Customers] ENABLE TRIGGER [INSERT_UPDATE_PASSWORD]
GO
/****** Object:  Trigger [dbo].[Tr_UpdateLevel]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Tr_UpdateLevel]
ON [dbo].[Orders]
AFTER INSERT, UPDATE
AS
BEGIN
DECLARE @Customer_ID INT 
SELECT @Customer_ID = inserted.Customer_ID 
FROM inserted
 exec Pr_SetCustomerLevel @Customer_ID
END
GO
ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [Tr_UpdateLevel]
GO
/****** Object:  Trigger [dbo].[Trig_CheckShippingMethod_InVietNam]    Script Date: 18/5/2023 8:58:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Trig_CheckShippingMethod_InVietNam]
ON [dbo].[Orders] FOR INSERT, UPDATE
AS
	DECLARE @ERROR INT

	SELECT @ERROR = COUNT(*) FROM Customers Cus, Orders Ord, Shippings Ship
	WHERE Cus.ID = Ord.Customer_ID AND Ord.ShippingMethod_ID = Ship.ID
	AND CUS.Country LIKE 'VietNam'
	AND (Ship.Method NOT LIKE 'Private MotorBike' AND Ship.Method NOT LIKE 'Local Car')

	IF (@ERROR > 0)
	BEGIN
		ROLLBACK TRAN
		PRINT'
		
Customers who have VietNam as their country are not allowed to ship by air or by ship

		'
	END
GO
ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [Trig_CheckShippingMethod_InVietNam]
GO
/****** Object:  Trigger [dbo].[Trig_CheckShippingMethod_OutVietNam]    Script Date: 18/5/2023 8:58:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   TRIGGER [dbo].[Trig_CheckShippingMethod_OutVietNam]
ON [dbo].[Orders] FOR INSERT, UPDATE
AS
	DECLARE @ERROR INT

	SELECT @ERROR = COUNT(*) FROM Customers Cus, Orders Ord, Shippings Ship
	WHERE Cus.ID = Ord.Customer_ID AND Ord.ShippingMethod_ID = Ship.ID
	AND CUS.Country NOT LIKE 'VietNam'
	AND (Ship.Method LIKE 'Private MotorBike' OR Ship.Method LIKE 'Local Car')

	IF (@ERROR > 0)
	BEGIN
		ROLLBACK TRAN
		PRINT'
		
Customers who dont have VietNam as their country are just allowed to ship by air or by ship

		'
	END
GO
ALTER TABLE [dbo].[Orders] ENABLE TRIGGER [Trig_CheckShippingMethod_OutVietNam]
GO
/****** Object:  Trigger [dbo].[CheckInputDay]    Script Date: 18/5/2023 8:58:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    TRIGGER [dbo].[CheckInputDay]
ON [dbo].[Warehouse]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN warehouse w ON i.seri = w.seri
        INNER JOIN warehouse w2 ON w.seri = w2.seri + 1
        WHERE i.Date <= w2.Date
    )
    BEGIN
        RAISERROR ('Ngày nhập kho sau phải lớn hơn ngày nhập kho trước.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
GO
ALTER TABLE [dbo].[Warehouse] ENABLE TRIGGER [CheckInputDay]
GO
/****** Object:  Trigger [dbo].[Pr_CheckInputDay]    Script Date: 18/5/2023 8:58:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    TRIGGER [dbo].[Pr_CheckInputDay]
ON [dbo].[Warehouse]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN warehouse w ON i.seri = w.seri
        INNER JOIN warehouse w2 ON w.seri = w2.seri + 1
        WHERE i.Date <= w2.Date
    )
    BEGIN
        RAISERROR ('Ngày nhập kho sau phải lớn hơn ngày nhập kho trước.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
GO
ALTER TABLE [dbo].[Warehouse] ENABLE TRIGGER [Pr_CheckInputDay]
GO
/****** Object:  Trigger [dbo].[Tr_CheckInputDay]    Script Date: 18/5/2023 8:58:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--trigger check inputday
CREATE    TRIGGER [dbo].[Tr_CheckInputDay]
ON [dbo].[Warehouse]
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN warehouse w ON i.seri = w.seri
        INNER JOIN warehouse w2 ON w.seri = w2.seri + 1
        WHERE i.Date <= w2.Date
    )
    BEGIN
        RAISERROR ('Ngày nhập kho sau phải lớn hơn ngày nhập kho trước.', 16, 1)
        ROLLBACK TRANSACTION
        RETURN
    END
END
GO
ALTER TABLE [dbo].[Warehouse] ENABLE TRIGGER [Tr_CheckInputDay]
GO
USE [master]
GO
ALTER DATABASE [BookStore] SET  READ_WRITE 
GO
