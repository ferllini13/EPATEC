USE [EPATEC]
GO
/****** Object:  StoredProcedure [dbo].[changeProviderPassword]    Script Date: 9/23/2016 11:33:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	insertar proveedor
-- =============================================
CREATE PROCEDURE [dbo].[changeProviderPassword]
	@id varchar(10),
	@password varchar(15)

AS
BEGIN

	update Provider
	set _password = @password
	where _id = @id

END


GO
/****** Object:  StoredProcedure [dbo].[changeUsersPassword]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	cambiar contraseña de usuarios
-- =============================================
CREATE PROCEDURE [dbo].[changeUsersPassword]
	@userID varchar(10),
	@password varchar(15)

AS
BEGIN

	update Users
	set _password = @password
	where @userID = _id

END


GO
/****** Object:  StoredProcedure [dbo].[createWishes]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[createWishes]	
	@clientID varchar(10),
	@id varchar(10),
	@office varchar(15),
	@creationTime varchar(15),
	@penalty bit

AS
BEGIN
	
	insert into Wish(_id, _office, _creationTime, penalty)
	values(@id, @office, @creationTime, @penalty)

	update Wish
	set clientId = @clientID
	where _id = @id
	
END

GO
/****** Object:  StoredProcedure [dbo].[deleteCategory]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	eliminar producto
-- =============================================
CREATE PROCEDURE [dbo].[deleteCategory]
	@id varchar(10)

AS
BEGIN
	
	declare @productsByCategory table(id varchar(10))

	insert into @productsByCategory
		select _id
		from Product
		where _categoryId = @id

	update Product
	set _categoryId = '0'
	where _id in (Select * from @productsByCategory)

	delete from Category
	where _id = @id


END



GO
/****** Object:  StoredProcedure [dbo].[deleteProduct]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	eliminar producto
-- =============================================
CREATE PROCEDURE [dbo].[deleteProduct]
	@providerID varchar(10),
	@id varchar(10)

AS
BEGIN
	
	delete from ProviderProducts
	where _productId = @id

	delete from WishProducts
	where _productId = @id

	delete from Product
	where _id = @id

END



GO
/****** Object:  StoredProcedure [dbo].[deleteProvider]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jairo
-- Create date: 18-9-16
-- Description:	Se ingresan los productos uno por uno a la relacion de los productos con un pedido
-- =============================================
CREATE PROCEDURE [dbo].[deleteProvider]
	@id varchar(10)

AS
BEGIN
	
	declare @productsByProvider Table(id varchar(10))


	insert into @productsByProvider
		select _productId
		from ProviderProducts
		where _providerId = @id
	
	delete from ProviderProducts
	where _productId in (select * from @productsByProvider)

	delete from Product
	where _id in (select * from @productsByProvider)

	delete from Provider
	where _id = @id
	
END


GO
/****** Object:  StoredProcedure [dbo].[deleteUser]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	cambiar contraseña de usuarios
-- =============================================
CREATE PROCEDURE [dbo].[deleteUser]
	@userID varchar(10)

AS
BEGIN

	delete from Users
	where @userID = _id

END


GO
/****** Object:  StoredProcedure [dbo].[deleteWish]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	eliminar producto
-- =============================================
CREATE PROCEDURE [dbo].[deleteWish]
	@wishID varchar(10)

AS
BEGIN
	
	declare @tmp table(pID varchar(10), numberP int)

	insert into @tmp (pID, numberP)
		select WP._productId, WP.numberOfProducts
		from WishProducts as WP
		where WP._wishId = @wishID

	update Product
	set _amount = _amount + (select numberP from @tmp where _id = pID)
	where _id in (select pID from @tmp)

	delete from WishProducts
	where _wishId = @wishID

	delete from Wish
	where _id = @wishID

END




GO
/****** Object:  StoredProcedure [dbo].[GetBestSellerProductByOffice]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	Obtener los productos mas vendidos en total
-- =============================================
CREATE PROCEDURE [dbo].[GetBestSellerProductByOffice]
	@office varchar(15)
AS
BEGIN
	
	declare @tmpTable table(productID varchar(10), productName varchar(20), quantitySold int)

	insert into @tmpTable(productID,productName,quantitySold)
		select distinct(WP._productId), P._description, SUM(WP.numberOfProducts) as cantidadComprada
		from WishProducts as WP inner join Product as P on P._id = WP._productId
		inner join Wish as W on W._id = WP._wishId
		where W._office = @office
		group by WP._productId, P._description, WP.numberOfProducts
		

	select top(3) productName, quantitySold
	from @tmpTable
	order by quantitySold desc

END





GO
/****** Object:  StoredProcedure [dbo].[GetBestSellerProductTotal]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	Obtener los productos mas vendidos en total
-- =============================================
CREATE PROCEDURE [dbo].[GetBestSellerProductTotal]
AS
BEGIN
	
	declare @tmpTable table(productID varchar(10), productName varchar(20), quantitySold int)

	insert into @tmpTable(productID,productName,quantitySold)
		select distinct(WP._productId), P._description, SUM(WP.numberOfProducts) as cantidadComprada
		from WishProducts as WP inner join Product as P on P._id = WP._productId
		group by WP._productId, P._description, WP.numberOfProducts
		
	

	select top(3) productName, quantitySold
	from @tmpTable
	order by quantitySold desc

END





GO
/****** Object:  StoredProcedure [dbo].[GetProductsByCategory]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	Obtener productos por categoría
-- =============================================
CREATE PROCEDURE [dbo].[GetProductsByCategory]
@categoryName VARCHAR(15)
AS
BEGIN

	declare @category table(categoryID varchar(15))
		insert into @category
			select C._id
			from Category as C
			where C._description = @categoryName


	DECLARE @productsID TABLE (_id VARCHAR(10)) -- se genera una tabla temporal
		insert into @productsID 
			select P._id
			from Product as P, @category as C
			where P._categoryId = C.categoryID 

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @categoryName as CategoryName, P._id as ProductId, P._description as ProductName, P._nonTaxable as Is_taxable, P._amount as quantityAvailable
	from Product as P INNER JOIN @productsId as pID On P._id = pID._id
END


GO
/****** Object:  StoredProcedure [dbo].[GetProductsByProvider]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[GetProductsByProvider]
	@providerID varchar(10)

AS
BEGIN	
	select P._description, P._amount
	from ProviderProducts as PP INNER JOIN Product as P ON P._id = PP._productId
	where PP._providerId = @providerID 
	group by  P._description, P._amount
	
END
GO
/****** Object:  StoredProcedure [dbo].[GetProductsByWish]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jairo
-- Create date: 19-9-2016
-- Description:	Obtener productos por pedido
-- =============================================
CREATE PROCEDURE [dbo].[GetProductsByWish]
	@wishID varchar(10)
AS
BEGIN
	
	select P._description
	from WishProducts as WP INNER JOIN Product as P ON P._id = WP._productId
	where WP._wishId = @wishID 
	group by  P._description
	
END

GO
/****** Object:  StoredProcedure [dbo].[GetSoldProductByOffice]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	Obtener los productos mas vendidos en total
-- =============================================
CREATE PROCEDURE [dbo].[GetSoldProductByOffice]
	@office varchar(15)
AS
BEGIN

	declare @tmpTable table(productID varchar(10), wishAmount int, quantitySold int)

	insert into @tmpTable(productID,wishAmount,quantitySold)
		select distinct(WP._productId), count(distinct(WP._productId)), SUM(WP.numberOfProducts) as cantidadComprada
		from WishProducts as WP inner join Product as P on P._id = WP._productId
		inner join Wish as W on W._id = WP._wishId
		where W._office = @office
		group by WP._productId, WP.numberOfProducts
	
	select  @office as sucursal,SUM(wishAmount) as pedidosEnLaSucursal, SUM(quantitySold) as productosVendidos
	from @tmpTable

END





GO
/****** Object:  StoredProcedure [dbo].[GetWishesByOffice]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Jairo
-- Create date: 19-9-2016
-- Description:	Obtener pedidos por oficina
-- =============================================
CREATE PROCEDURE [dbo].[GetWishesByOffice]
	@office varchar(15)

AS
BEGIN
	
	select distinct(WP._wishId), W._office, W.clientId,W._creationTime, count(distinct WP._productId) + WP.numberOfProducts -1 as quantityOfProductSold
	from WishProducts as WP INNER JOIN Wish as W ON W._id = WP._wishId
	where W._office = @office
	group by  WP._wishId, W._office, W.clientId,W._creationTime,WP.numberOfProducts
	
END






GO
/****** Object:  StoredProcedure [dbo].[insertCategory]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	insertar categoría
-- =============================================
CREATE PROCEDURE [dbo].[insertCategory]
	@id varchar(10),
	@description varchar(20)

AS
BEGIN

	insert into Category(_id, _description)
	values(@id, @description)

END


GO
/****** Object:  StoredProcedure [dbo].[insertProduct]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	insertar producto
-- =============================================
CREATE PROCEDURE [dbo].[insertProduct]
	@categoryID varchar(10),
	@providerID varchar(10),
	@id varchar(10),
	@nonTaxable bit,
	@amount int,
	@office varchar(15),
	@description varchar(20)

AS
BEGIN

	insert into Product(_id, _nonTaxable, _amount, _office, _description)
	values(@id, @nonTaxable, @amount, @office, @description)


	update Product
	set _categoryId = @categoryID
	where _id = @id

	insert into ProviderProducts(_providerId, _productId)
	values(@providerID, @id)

END

GO
/****** Object:  StoredProcedure [dbo].[insertProvider]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	insertar proveedor
-- =============================================
CREATE PROCEDURE [dbo].[insertProvider]
	@id varchar(10),
	@name varchar(10),
	@lastName1 varchar(10),
	@lastName2 varchar(10),
	@cellPhone varchar(8),
	@identityNumber varchar(9), 
	@residenceAddress varchar(20),
	@password varchar(15),
	@birthDate varchar(15)

AS
BEGIN

	insert into Provider(_id, _name, _lastName1, _lastName2, _cellPhone, _identityNumber, _residenceAddress, _password, _birtDate)
	values(@id, @name, @lastName1, @lastName2, @cellPhone, @identityNumber, @residenceAddress, @password, @birthDate)

END


GO
/****** Object:  StoredProcedure [dbo].[insertUsers]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	insertar usuarios
-- =============================================
CREATE PROCEDURE [dbo].[insertUsers]
	@id varchar(10),
	@name varchar(10),
	@lastname1 varchar(10),
	@lastname2 varchar(10),
	@cellPhone varchar(8),
	@identityNumber varchar(9),
	@residenceAddress varchar(20),
	@birthDate varchar(15),
	@type int,
	@password varchar(15)

AS
BEGIN

	insert into Users(_id, _name, _lastName1, _lastName2, _cellPhone, _identityNumber, _residenceAddress, _type, _password, _birthDate)
	values(@id, @name, @lastname1, @lastname2, @cellPhone, @identityNumber, @residenceAddress, @type, @password, @birthDate)


END


GO
/****** Object:  StoredProcedure [dbo].[penalizeUser]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- Create Stored Procedure Template for SQL Azure Database
-- ==========================================================

-- =============================================
-- Author:		Jairo
-- Create date: 17-09-2016
-- Description:	cambiar contraseña de usuarios
-- =============================================
CREATE PROCEDURE [dbo].[penalizeUser]
	@userID varchar(10)

AS
BEGIN

	update Users
	set penalty = '1'
	where @userID = _id

END


GO
/****** Object:  StoredProcedure [dbo].[updateWishProduct]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jairo
-- Create date: 18-9-16
-- Description:	Se ingresan los productos uno por uno a la relacion de los productos con un pedido
-- =============================================
CREATE PROCEDURE [dbo].[updateWishProduct]
	@productID varchar(10),
	@wishID varchar(10),
	@quantity int

AS
BEGIN
	
	insert into WishProducts(_wishId, _productId, numberOfProducts)
	values(@wishID, @productID, @quantity)

	update Product
	set _amount = _amount - @quantity
	where _id = @productID
	
END


GO
/****** Object:  Table [dbo].[Category]    Script Date: 9/23/2016 11:33:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Category](
	[_id] [varchar](10) NOT NULL,
	[_description] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Product]    Script Date: 9/23/2016 11:33:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Product](
	[_id] [varchar](10) NOT NULL,
	[_nonTaxable] [bit] NOT NULL,
	[_office] [varchar](15) NULL,
	[_description] [varchar](20) NULL,
	[_categoryId] [varchar](10) NULL,
	[_amount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Provider]    Script Date: 9/23/2016 11:33:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Provider](
	[_id] [varchar](10) NOT NULL,
	[_name] [varchar](10) NOT NULL,
	[_lastname1] [varchar](10) NOT NULL,
	[_lastname2] [varchar](10) NOT NULL,
	[_cellPhone] [varchar](8) NULL,
	[_identityNumber] [varchar](9) NOT NULL,
	[_password] [varchar](15) NOT NULL,
	[_birtDate] [varchar](15) NULL,
	[_residenceAddress] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
UNIQUE NONCLUSTERED 
(
	[_identityNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProviderProducts]    Script Date: 9/23/2016 11:33:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProviderProducts](
	[_providerId] [varchar](10) NOT NULL,
	[_productId] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[_providerId] ASC,
	[_productId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 9/23/2016 11:33:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[_id] [varchar](10) NOT NULL,
	[_name] [varchar](10) NOT NULL,
	[_lastName1] [varchar](10) NOT NULL,
	[_lastName2] [varchar](10) NOT NULL,
	[_cellPhone] [varchar](8) NULL,
	[_identityNumber] [varchar](9) NOT NULL,
	[_type] [int] NULL,
	[_password] [varchar](15) NULL,
	[_birthDate] [varchar](15) NULL,
	[penalty] [bit] NULL,
	[_office] [varchar](15) NULL,
	[_residenceAddress] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON),
UNIQUE NONCLUSTERED 
(
	[_identityNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Wish]    Script Date: 9/23/2016 11:33:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Wish](
	[_id] [varchar](10) NOT NULL,
	[_office] [varchar](15) NOT NULL,
	[clientId] [varchar](10) NULL,
	[penalty] [bit] NULL,
	[_creationTime] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[WishProducts]    Script Date: 9/23/2016 11:33:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[WishProducts](
	[_wishId] [varchar](10) NOT NULL,
	[_productId] [varchar](10) NOT NULL,
	[numberOfProducts] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[_wishId] ASC,
	[_productId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('0') FOR [penalty]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD FOREIGN KEY([_categoryId])
REFERENCES [dbo].[Category] ([_id])
GO
ALTER TABLE [dbo].[ProviderProducts]  WITH CHECK ADD FOREIGN KEY([_productId])
REFERENCES [dbo].[Product] ([_id])
GO
ALTER TABLE [dbo].[ProviderProducts]  WITH CHECK ADD FOREIGN KEY([_providerId])
REFERENCES [dbo].[Provider] ([_id])
GO
ALTER TABLE [dbo].[Wish]  WITH CHECK ADD FOREIGN KEY([clientId])
REFERENCES [dbo].[Users] ([_id])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[WishProducts]  WITH CHECK ADD FOREIGN KEY([_productId])
REFERENCES [dbo].[Product] ([_id])
GO
ALTER TABLE [dbo].[WishProducts]  WITH CHECK ADD FOREIGN KEY([_wishId])
REFERENCES [dbo].[Wish] ([_id])
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [positive_amount] CHECK  (((0)<=[_amount]))
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [positive_amount]
GO
