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
IF (dbo.isTableExists('Events') = 0)
BEGIN
CREATE TABLE [Events](
    [Id] [uniqueidentifier] NOT NULL,
    [AggregateId] [uniqueidentifier] NOT NULL,
    [EventJson] [nvarchar](MAX) NOT NULL,
    [EventType] [nvarchar](1000) NOT NULL,
    [MetadataJson] [nvarchar](Max) NOT NULL,
    [Version] [int] NOT NULL,
    [SequenceNumber] int NOT NULL IDENTITY (1, 1),
    CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED 
    (
        [Id] ASC
    )
)
END; 
GO
-----------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'Events_SequenceNumber_AggregateId')
CREATE NONCLUSTERED INDEX [Events_SequenceNumber_AggregateId] ON [Events] ([SequenceNumber] ASC,[AggregateId] ASC)
-----------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'Events_AggregateId_SequenceNumber')
CREATE NONCLUSTERED INDEX [Events_AggregateId_SequenceNumber] ON [Events] ([AggregateId] ASC,[SequenceNumber] ASC)
--------------------------------------------------------------
IF (dbo.isTableExists('CompanyRequestDto') = 0)
BEGIN
	CREATE TABLE "CompanyRequestDto" 
	(
	  "Id" VARCHAR(8000) PRIMARY KEY, 
	  "CompanyType" VARCHAR(8000) NOT NULL, 
	  "Status" VARCHAR(8000) NOT NULL, 
	  "Comments" VARCHAR(8000) NULL, 
	  "UpdateDate" DATETIME NOT NULL, 
	  "CompanyName" VARCHAR(8000) NULL, 
	  "CompanyNumber" VARCHAR(8000) NULL, 
	  "CountryCode" VARCHAR(8000) NULL, 
	  "RegistrationSteps" VARCHAR(8000) NULL, 
	  "IsVisible" BIT NOT NULL 
	);
END; 
GO
--------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyRequestDto_CompanyType_Status_CompanyName')
  CREATE NONCLUSTERED INDEX [CompanyRequestDto_CompanyType_Status_CompanyName] ON [CompanyRequestDto] ([CompanyType] ASC,[Status] ASC,[CompanyName] ASC)
----------------------------------------------------------------------------------
IF (dbo.isTableExists('CompanyUserIdDto') = 0)
BEGIN
	CREATE TABLE "CompanyUserIdDto" 
    (
      "UserId" UniqueIdentifier PRIMARY KEY, 
      "CompanyId" UniqueIdentifier NOT NULL 
    ); 

END; 
GO
---------------------------------------------------------
IF (dbo.isTableExists('CompanyUserDto') = 0)
BEGIN
  CREATE TABLE "CompanyUserDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "FullName" VARCHAR(8000) NULL, 
    "Email" VARCHAR(8000) NULL, 
    "Role" VARCHAR(8000) NOT NULL, 
    "UpdatedDateTimeUtc" DATETIME NOT NULL, 
    "IsCompanyRejected" BIT NOT NULL 
  ); 
END;
GO
-------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyUserDto_CompanyId')
 CREATE NONCLUSTERED INDEX [CompanyUserDto_CompanyId] ON [CompanyUserDto] ([CompanyId] ASC)
---------------------------------------------------------------
IF (dbo.isTableExists('UserDto') = 0)
BEGIN
  CREATE TABLE "UserDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "Role" VARCHAR(8000) NOT NULL, 
    "Login" VARCHAR(8000) NULL, 
    "PasswordSalt" UniqueIdentifier NOT NULL, 
    "PasswordHash" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "FullName" VARCHAR(8000) NULL, 
    "IsBlocked" BIT NOT NULL 
  ); 
END;
GO
---------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'UserDto_Login')
  CREATE NONCLUSTERED INDEX [UserDto_Login] ON [UserDto] ([Login] ASC)
-----------------------------------------------------
IF (dbo.isTableExists('CountryCompetenceStatisticsDto') = 0)
BEGIN
  CREATE TABLE "CountryCompetenceStatisticsDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CountryCode" VARCHAR(8000) NULL, 
    "Count" INTEGER NOT NULL 
  ); 
END;
GO
------------------------------------------------------
IF (dbo.isTableExists('BlockedPersonDto') = 0)
BEGIN
  CREATE TABLE "BlockedPersonDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "CountryOfOrigin" VARCHAR(8000) NULL, 
    "BlockedCountryCode" VARCHAR(8000) NULL 
  ); 
END;
GO
-------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'BlockedPersonDto_PersonalNumber_CountryOfOrigin')
  CREATE NONCLUSTERED INDEX [BlockedPersonDto_PersonalNumber_CountryOfOrigin] ON [BlockedPersonDto] ([PersonalNumber] ASC,[CountryOfOrigin] ASC)
---------------------------------------------------
IF (dbo.isTableExists('CountryCompetenceEventDto') = 0)
BEGIN
  CREATE TABLE "CountryCompetenceEventDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "ProofOfEducationId" UniqueIdentifier NULL, 
    "CompanyId" UniqueIdentifier NULL, 
    "CompanyName" VARCHAR(8000) NULL, 
    "CompanyNumber" VARCHAR(8000) NULL, 
    "CompanyType" VARCHAR(8000) NOT NULL, 
    "CompetenceId" UniqueIdentifier NULL, 
    "CompetenceCode" VARCHAR(8000) NULL, 
    "CompetenceName" VARCHAR(8000) NULL, 
    "GroupId" UniqueIdentifier NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "IssueDate" DATETIME NULL, 
    "ValidUntil" DATETIME NULL, 
    "RegisteredBy" VARCHAR(8000) NULL, 
    "RegisteredDate" DATETIME NULL, 
    "CompetenceType" VARCHAR(8000) NOT NULL, 
    "EventType" VARCHAR(8000) NOT NULL, 
    "CompetenceCountryCode" VARCHAR(8000) NULL, 
    "Flag" VARCHAR(8000) NULL, 
    "IsDeleted" BIT NOT NULL, 
    "RegisteredByRole" VARCHAR(8000) NOT NULL
  );
END;
GO
---------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_PersonalNumber_EventType')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_PersonalNumber_EventType] ON [CountryCompetenceEventDto] ([PersonalNumber] ASC,[EventType] ASC)
-------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_CompanyId_EventType_GroupId_CompetenceName_CompetenceId')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_CompanyId_EventType_GroupId_CompetenceName_CompetenceId] ON [CountryCompetenceEventDto] ([CompanyId] ASC,[EventType] ASC,[GroupId] ASC,[CompetenceName] ASC,[CompetenceId] ASC)
-----------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_CompetenceCountryCode_EventType_PersonalNumber')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_CompetenceCountryCode_EventType_PersonalNumber] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[PersonalNumber] ASC) INCLUDE ([Name],[CountryCode])
----------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_CompetenceCountryCode_EventType_PersonalNumber_CountryCode')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_CompetenceCountryCode_EventType_PersonalNumber_CountryCode] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[PersonalNumber] ASC,[CountryCode] ASC) INCLUDE ([Name],[CompetenceType],[CompanyType])
---------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_CompetenceCountryCode_EventType_CompetenceId_PersonalNumber')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_CompetenceCountryCode_EventType_CompetenceId_PersonalNumber] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[CompetenceId] ASC,[PersonalNumber] ASC)
------------------------- ---------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_CompetenceCountryCode_EventType_CompanyId_CompetenceId')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_CompetenceCountryCode_EventType_CompanyId_CompetenceId] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[CompanyId] ASC,[CompetenceId] ASC)
  -------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_export_filters')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_export_filters] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[Name] ASC,[PersonalNumber] ASC,[CompetenceName] ASC)
  ----------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_regular_filter_fields')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_regular_filter_fields] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[CompanyName] ASC,[CompetenceName] ASC,[GroupId] ASC,[CompanyId] ASC,[CompanyType] ASC,[CompetenceId] ASC)
 ---------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_statistics_count')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_statistics_count] ON [CountryCompetenceEventDto] ([CompetenceCountryCode] ASC,[EventType] ASC,[CompanyName] ASC,[CompetenceName] ASC)
  ------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CountryCompetenceEventDto_GroupId_EventType')
  CREATE NONCLUSTERED INDEX [CountryCompetenceEventDto_GroupId_EventType] ON [CountryCompetenceEventDto] ([GroupId] ASC,[EventType] ASC) INCLUDE ([GroupName])
-------------------------------------------------------------------------------------------------
IF (dbo.isTableExists('CompanyCompetenceStatisticsDto') = 0)
BEGIN
  CREATE TABLE "CompanyCompetenceStatisticsDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CompanyId" UniqueIdentifier NULL, 
    "GroupId" UniqueIdentifier NULL, 
    "CompetenceId" UniqueIdentifier NULL, 
    "CompetenceName" VARCHAR(8000) NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "Count" INTEGER NULL 
  ); 
END;
GO
---------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyCompetenceStatisticsDto_GroupId')
CREATE NONCLUSTERED INDEX [CompanyCompetenceStatisticsDto_GroupId] ON [CompanyCompetenceStatisticsDto] ([GroupId] ASC)
---------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyCompetenceStatisticsDto_CompetenceId_CompanyId')
CREATE NONCLUSTERED INDEX [CompanyCompetenceStatisticsDto_CompetenceId_CompanyId] ON [CompanyCompetenceStatisticsDto] ([CompetenceId] ASC,[CompanyId] ASC)
-----------------------------------------------------------------------------------
IF (dbo.isTableExists('PersonCompetenceEventDto') = 0)
BEGIN
  CREATE TABLE "PersonCompetenceEventDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "CorporateId" VARCHAR(8000) NULL, 
    "ProofOfEducationId" UniqueIdentifier NULL, 
    "CompanyId" UniqueIdentifier NULL, 
    "CompanyName" VARCHAR(8000) NULL, 
    "CompetenceId" UniqueIdentifier NULL, 
    "CompetenceName" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "IssueDate" DATETIME NULL, 
    "ValidUntil" DATETIME NULL, 
    "RegisteredBy" VARCHAR(8000) NULL,  
    "RegisteredDate" DATETIME NULL, 
    "ModifyingDate" DATETIME NULL, 
    "CompetenceType" VARCHAR(8000) NULL, 
    "GroupId" UniqueIdentifier NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "EventType" VARCHAR(8000) NOT NULL, 
    "CompetenceCode" VARCHAR(8000) NULL, 
    "RegisteredByRole" VARCHAR(8000) NOT NULL, 
    "CompetenceCountryCode" VARCHAR(8000) NULL, 
    "Flag" VARCHAR(8000) NULL 
  ); 
END;
GO
--------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'PersonCompetenceEventDto_PersonalNumber_CountryCode_EventType')
CREATE NONCLUSTERED INDEX [PersonCompetenceEventDto_PersonalNumber_CountryCode_EventType] ON [PersonCompetenceEventDto] ([PersonalNumber] ASC,[CountryCode] ASC,[EventType] ASC) INCLUDE ([CompetenceId])
---------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'PersonCompetenceEventDto_CompanyId_EventType')
CREATE NONCLUSTERED INDEX [PersonCompetenceEventDto_CompanyId_EventType] ON [PersonCompetenceEventDto] ([CompanyId] ASC,[EventType] ASC)
-----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'PersonCompetenceEventDto_CorporateId_PersonalNumber_CountryCode')
CREATE NONCLUSTERED INDEX [PersonCompetenceEventDto_CorporateId_PersonalNumber_CountryCode] ON [PersonCompetenceEventDto] ([CorporateId] ASC,[PersonalNumber] ASC,[CountryCode] ASC)
----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'PersonCompetenceEventDto_ProofOfEducationId')
CREATE NONCLUSTERED INDEX [PersonCompetenceEventDto_ProofOfEducationId] ON [PersonCompetenceEventDto] ([ProofOfEducationId] ASC)
-------------------------------------------------------------------------------
IF (dbo.isTableExists('DeletedPersonalCompetenceDto') = 0)
BEGIN
  CREATE TABLE "DeletedPersonalCompetenceDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "CorporateId" VARCHAR(8000) NULL, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "CompanyName" VARCHAR(8000) NULL, 
    "CompetenceId" UniqueIdentifier NOT NULL, 
    "CompetenceName" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "IssueDate" DATETIME NOT NULL, 
    "ValidUntil" DATETIME NOT NULL, 
    "RegisteredBy" VARCHAR(8000) NULL, 
    "RegisteredDate" DATETIME NOT NULL, 
    "DeletedDate" DATETIME NOT NULL, 
    "CompetenceType" VARCHAR(8000) NOT NULL, 
    "GroupId" UniqueIdentifier NOT NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "CompetenceCode" VARCHAR(8000) NULL, 
    "RegisteredByRole" VARCHAR(8000) NOT NULL, 
    "CompetenceCountryCode" VARCHAR(8000) NULL, 
    "Flag" VARCHAR(8000) NULL 
  ); 
END;
GO
------------------------------------------------------------------
IF (dbo.isTableExists('PersonDto') = 0)
BEGIN
  CREATE TABLE "PersonDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CountryCode" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "LastUpdated" DATETIME NOT NULL, 
    "IsCentralConsentApproved" BIT NOT NULL, 
    "IsHcConsentApproved" BIT NOT NULL, 
    "ConsentApprovalDate" DATETIME NULL, 
    "HcConsentApprovalDate" DATETIME NULL
); 
END;
GO
---------------------------------------------------------------------

IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'PersonDto_PersonalNumber')
 CREATE NONCLUSTERED INDEX [PersonDto_PersonalNumber] ON [PersonDto] ([PersonalNumber] ASC)
------------------------------------------------------------------------------
IF (dbo.isTableExists('ProofOfEducationCompanyDto') = 0)
BEGIN
  CREATE TABLE "ProofOfEducationCompanyDto" 
  (
    "Name" VARCHAR(8000) NULL, 
    "Competence" VARCHAR(8000) NULL, 
    "CompetenceId" UniqueIdentifier NULL, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "RegisteredBy" VARCHAR(8000) NULL, 
    "RegisteredByRole" VARCHAR(8000) NOT NULL, 
    "RegisteredDate" DATETIME NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "IsValid" BIT NOT NULL, 
    "Id" UniqueIdentifier PRIMARY KEY, 
    "ValidUntil" DATETIME NULL, 
    "IssueDate" DATETIME NULL, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "ConfirmationType" VARCHAR(8000) NOT NULL, 
    "CompetenceCode" VARCHAR(8000) NULL, 
    "CompanyName" VARCHAR(8000) NULL, 
    "GroupId" UniqueIdentifier NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "RecordType" VARCHAR(8000) NOT NULL, 
    "Flag" VARCHAR(8000) NULL 
);
END;
GO
--------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'ProofOfEducationCompanyDto_CompanyId_CompetenceId_ValidUntil')
 CREATE NONCLUSTERED INDEX [ProofOfEducationCompanyDto_CompanyId_CompetenceId_ValidUntil] ON [ProofOfEducationCompanyDto] ([CompanyId] ASC,[CompetenceId] ASC,[ValidUntil] ASC)
---------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'ProofOfEducationCompanyDto_PersonalNumber')
 CREATE NONCLUSTERED INDEX [ProofOfEducationCompanyDto_PersonalNumber] ON [ProofOfEducationCompanyDto] ([PersonalNumber] ASC)
-------------------------------------------------------------------------------------------
IF (dbo.isTableExists('HealthCertificateDto') = 0)
BEGIN
  CREATE TABLE "HealthCertificateDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "CountryOfOrigin" VARCHAR(8000) NULL, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "ValidUntil" DATETIME NOT NULL, 
    "CreatedBy" VARCHAR(8000) NULL, 
    "ModifyingDate" DATETIME NOT NULL 
); 
END;
GO
--------------------------------------------------------
IF (dbo.isTableExists('CompanyAllowedCompetencesDto') = 0)
BEGIN
  CREATE TABLE "CompanyAllowedCompetencesDto" 
  (
    "Id" VARCHAR(8000) PRIMARY KEY, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "CompetenceId" UniqueIdentifier NOT NULL, 
    "CompetenceType" VARCHAR(8000) NOT NULL 
  ); 
END;
GO
-------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyAllowedCompetencesDto_CompetenceId_CompanyId')
 CREATE NONCLUSTERED INDEX [CompanyAllowedCompetencesDto_CompetenceId_CompanyId] ON [CompanyAllowedCompetencesDto] ([CompetenceId] ASC,[CompanyId] ASC)
--------------------------------------------------------------------
IF (dbo.isTableExists('CompanyProjectionDto') = 0)
BEGIN
CREATE TABLE "CompanyProjectionDto" 
(
  "Id" UniqueIdentifier PRIMARY KEY, 
  "CompanyName" VARCHAR(8000) NULL, 
  "PostalAddress" VARCHAR(8000) NULL, 
  "InvoiceCompanyName" VARCHAR(8000) NULL, 
  "InvoiceAddress" VARCHAR(8000) NULL, 
  "Phone" VARCHAR(8000) NULL, 
  "Cellphone" VARCHAR(8000) NULL, 
  "Fax" VARCHAR(8000) NULL, 
  "Tax" VARCHAR(8000) NULL, 
  "WebSite" VARCHAR(8000) NULL, 
  "Description" VARCHAR(8000) NULL, 
  "AbbreviatedName" VARCHAR(8000) NULL, 
  "Flag" VARCHAR(8000) NULL, 
  "CorporateId" VARCHAR(8000) NULL, 
  "CountryOfRegistrationCode" VARCHAR(8000) NULL, 
  "IsBlocked" BIT NOT NULL, 
  "IsApproved" BIT NOT NULL, 
  "Type" VARCHAR(8000) NOT NULL, 
  "Competences" VARCHAR(MAX) NULL, 
  "EmployerGuarantees" VARCHAR(MAX) NULL, 
  "NonRegulates" VARCHAR(MAX) NULL, 
  "UpdateDate" DATETIME NOT NULL, 
  "ApprovalDate" DATETIME NULL, 
  "CreationDate" DATETIME NOT NULL, 
  "Registration" VARCHAR(8000) NULL, 
  "Deleted" BIT NOT NULL, 
  "ReferenceNumber" VARCHAR(8000) NULL, 
  "ReferenceName" VARCHAR(8000) NULL, 
  "HasLogo" BIT NOT NULL, 
  "IsVisible" BIT NOT NULL, 
  "BlockReasonCode" VARCHAR(8000) NULL 
);
END;
GO
-----------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyProjectionDto_CorporateId')
  CREATE NONCLUSTERED INDEX [CompanyProjectionDto_CorporateId] ON [CompanyProjectionDto] ([CorporateId] ASC)
-----------------------------------------------------------------------------
IF (dbo.isTableExists('UniqueCompetenceGroupDto') = 0)
BEGIN
  CREATE TABLE "UniqueCompetenceGroupDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "Name" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL 
  );
END;
------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'UniqueCompetenceGroupDto_Name')
  CREATE NONCLUSTERED INDEX [UniqueCompetenceGroupDto_Name] ON [UniqueCompetenceGroupDto] ([Name] ASC)
---------------------------------------------------------------------------------------------------
IF (dbo.isTableExists('CompetenceProjectionDto') = 0)
BEGIN
  CREATE TABLE "CompetenceProjectionDto" 
  (
    "Code" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CompetenceGroupId" UniqueIdentifier NOT NULL, 
    "Enabled" BIT NOT NULL, 
    "ExamIsPermanent" BIT NOT NULL, 
    "ExamValidForTimeAmount" INTEGER NULL, 
    "ExamValidityUnitOfTime" VARCHAR(8000) NULL, 
    "ExamValidityFloatingMonth" INTEGER NULL, 
    "ExamValidityFloatingDay" INTEGER NULL 
  );
END;
GO
--------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompetenceProjectionDto_CompetenceGroupId_Name')
 CREATE NONCLUSTERED INDEX [CompetenceProjectionDto_CompetenceGroupId_Name] ON [CompetenceProjectionDto] ([CompetenceGroupId] ASC,[Name] ASC)
---------------------------------------------------------------------------------------------
IF (dbo.isTableExists('PasswordRequestDto') = 0)
BEGIN
  CREATE TABLE "PasswordRequestDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "Token" VARCHAR(8000) NULL 
  );
END;
GO
-------------------------------------------------------------
IF (dbo.isTableExists('ProofOfEducationProjectionDto') = 0)
BEGIN
  CREATE TABLE "ProofOfEducationProjectionDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "PersonalNumber" VARCHAR(8000) NULL, 
    "CompetenceId" UniqueIdentifier NOT NULL, 
    "IssueDate" DATETIME NOT NULL, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "ConfirmationType" VARCHAR(8000) NOT NULL, 
    "CompetenceCountryCode" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL 
); 
END;
GO
-------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'ProofOfEducationProjectionDto_CompetenceId_PersonalNumber')
  CREATE NONCLUSTERED INDEX [ProofOfEducationProjectionDto_CompetenceId_PersonalNumber] ON [ProofOfEducationProjectionDto] ([CompetenceId] ASC,[PersonalNumber] ASC)
-------------------------------------------------------------
IF (dbo.isTableExists('CompetenceDetailsDto') = 0)
BEGIN
  CREATE TABLE "CompetenceDetailsDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "GroupId" UniqueIdentifier NOT NULL, 
    "CompetenceCode" VARCHAR(8000) NULL, 
    "Name" VARCHAR(8000) NULL, 
    "Created" DATETIME NOT NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "RegulatedBy" VARCHAR(8000) NULL, 
    "Enabled" BIT NOT NULL, 
    "Version" INTEGER NOT NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "Descriptions" VARCHAR(8000) NULL 
); 
END;
GO
----------------------------------------------
IF (dbo.isTableExists('CompetenceCodeHistoryDto') = 0)
BEGIN
  CREATE TABLE "CompetenceCodeHistoryDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CompetenceId" UniqueIdentifier NOT NULL, 
    "CompetenceCode" VARCHAR(8000) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "HappenedDate" DATETIME NOT NULL 
  );
END
GO
------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompetenceCodeHistoryDto_CompetenceCode')
 CREATE NONCLUSTERED INDEX [CompetenceCodeHistoryDto_CompetenceCode] ON [CompetenceCodeHistoryDto] ([CompetenceCode] ASC)
---------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompetenceCodeHistoryDto_CompetenceId_HappenedDate')
 CREATE NONCLUSTERED INDEX [CompetenceCodeHistoryDto_CompetenceId_HappenedDate] ON [CompetenceCodeHistoryDto] ([CompetenceId] ASC,[HappenedDate] DESC)
-----------------------------------------------------------------
IF (dbo.isTableExists('CompanyCompetenceDto') = 0)
BEGIN
  CREATE TABLE "CompanyCompetenceDto" 
  (
    "Id" VARCHAR(8000) PRIMARY KEY, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "CompetenceId" UniqueIdentifier NOT NULL, 
    "EnabledBySuperUser" BIT NOT NULL, 
    "State" VARCHAR(8000) NOT NULL, 
    "CompetenceType" VARCHAR(8000) NOT NULL, 
    "ProofsAmount" INTEGER NOT NULL 
  ); 
END;
GO
-----------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompanyCompetenceDto_CompanyId_CompetenceId_CompetenceType')
  CREATE NONCLUSTERED INDEX [CompanyCompetenceDto_CompanyId_CompetenceId_CompetenceType] ON [CompanyCompetenceDto] ([CompanyId] ASC,[CompetenceId] ASC,[CompetenceType] ASC) INCLUDE ([ProofsAmount])
---------------------------------------------------------------------
IF (dbo.isTableExists('CompetenceGroupDto') = 0)
BEGIN
  CREATE TABLE "CompetenceGroupDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "Name" VARCHAR(8000) NULL, 
    "SequenceNumber" INTEGER NOT NULL, 
    "Competences" VARCHAR(MAX) NULL, 
    "CountryCode" VARCHAR(8000) NULL, 
    "CreatedDate" DATETIME NOT NULL, 
    "IsRegulated" BIT NOT NULL 
  ); 
END;
----------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompetenceGroupDto_SequenceNumber_CreatedDate')
CREATE NONCLUSTERED INDEX [CompetenceGroupDto_SequenceNumber_CreatedDate] ON [CompetenceGroupDto] ([SequenceNumber] ASC,[CreatedDate] DESC)
------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.indexes WHERE name = N'CompetenceGroupDto_Name')
CREATE NONCLUSTERED INDEX [CompetenceGroupDto_Name] ON [CompetenceGroupDto] ([Name] ASC)
------------------------------------------------------------------
IF (dbo.isTableExists('LogoDto') = 0)
BEGIN
  CREATE TABLE "LogoDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "Logo" VARBINARY(MAX) NULL, 
    "MimeType" VARCHAR(8000) NULL 
  ); 
END;
----------------------------------------------
IF (dbo.isTableExists('CompanyGroupDto') = 0)
BEGIN
  CREATE TABLE "CompanyGroupDto" 
  (
    "Id" UniqueIdentifier PRIMARY KEY, 
    "CountryCode" VARCHAR(8000) NULL, 
    "GroupName" VARCHAR(8000) NULL, 
    "GroupId" UniqueIdentifier NOT NULL, 
    "CompanyId" UniqueIdentifier NOT NULL, 
    "CompanyName" VARCHAR(8000) NULL, 
    "IsMain" BIT NOT NULL, 
    "RecordType" VARCHAR(8000) NOT NULL, 
    "CorporateId" VARCHAR(8000) NULL 
); 
END;


