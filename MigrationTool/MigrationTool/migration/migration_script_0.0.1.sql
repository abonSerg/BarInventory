IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'isTableExists' AND ROUTINE_SCHEMA = 'dbo' AND ROUTINE_TYPE = 'FUNCTION')
 EXEC ('DROP FUNCTION dbo.isTableExists')

GO
CREATE FUNCTION dbo.isTableExists(@tableName varchar(30))  
RETURNS bit   
AS   
BEGIN  
	 DECLARE @result bit

 SET @result  = (SELECT CASE 
   WHEN EXISTS(
      SELECT 1 
      FROM information_schema.Tables WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = @tableName
   ) 
   THEN 1 
   ELSE 0 
end)

       RETURN @result;  
END;
GO 
------------------------------------------------

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'isTableContainsColumn' AND ROUTINE_SCHEMA = 'dbo' AND ROUTINE_TYPE = 'FUNCTION')
 EXEC ('DROP FUNCTION dbo.isTableContainsColumn')

GO
CREATE FUNCTION dbo.isTableContainsColumn(@tableName varchar(30), @columnName varchar(30))  
RETURNS bit   
AS   
BEGIN  
	 DECLARE @result bit

 SET @result  = (SELECT CASE 
   WHEN EXISTS(
      SELECT 1 
      FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = @tableName AND column_Name = @columnName) 
    THEN 1 
    ELSE 0 
   END)
   RETURN @result;  
END;
GO 
-------------------------------------------------------
IF (dbo.isTableExists('Bottles') = 0)
BEGIN
CREATE TABLE [Bottles](
    [Id] [uniqueidentifier] NOT NULL,
    [Name] [uniqueidentifier] NOT NULL,
    [Capacity] [decimal](2,2) NOT NULL,
    [Weight] [decimal](2,2) NULL,
    [Barcode] [varchar](Max) NULL,

    CONSTRAINT [PK_Bottles] PRIMARY KEY CLUSTERED 
    (
        [Id] 
    )
)
END; 
GO
-----------------------------------------------------------
IF (dbo.isTableExists('Areas') = 0)
BEGIN
CREATE TABLE [Areas](
    [Id] [uniqueidentifier] NOT NULL,
    [Name] [uniqueidentifier] NOT NULL,

    CONSTRAINT [PK_Areas] PRIMARY KEY CLUSTERED 
    (
        [Id] 
    )
)
END; 
GO
-----------------------------------------------------------
IF (dbo.isTableExists('BottlesAreas') = 0)
BEGIN
CREATE TABLE [BottlesAreas](
    [Id] [uniqueidentifier] NOT NULL,
    [AreaId] [uniqueidentifier] NOT NULL,
    [BottleId] [uniqueidentifier] NOT NULL,
	[BottleCount] [INT]  CONSTRAINT [DF_BottlesAreas_BottleCount] DEFAULT ((0)) NOT NULL,  

    CONSTRAINT [PK_BottlesAreas] PRIMARY KEY CLUSTERED 
    (
        [Id] 
    ),

	CONSTRAINT [FK_BottlesAreas_AreaId_Areas_Id] FOREIGN KEY ([AreaId]) REFERENCES [dbo].[BottlesAreas] ([Id]),
	CONSTRAINT [FK_BottlesAreas_BottleId_Bottles_Id] FOREIGN KEY ([BottleId]) REFERENCES [dbo].[Bottles] ([Id])
)
END; 
GO
-----------------------------------------------------------