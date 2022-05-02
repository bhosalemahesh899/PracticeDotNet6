IF COL_LENGTH('dbo.RolePermission', 'IsAccess') IS NOT NULL
GOTO ENDS

IF OBJECT_ID('dbo.Permission') IS NOT NULL AND OBJECT_ID('dbo.Permission1') IS NULL
	EXECUTE sp_rename '[dbo].[Permission]', 'Permission1';

IF OBJECT_ID('dbo.RolePermission') IS NOT NULL AND OBJECT_ID('dbo.RolePermission1') IS NULL
	EXECUTE sp_rename '[dbo].[RolePermission]', 'RolePermission1';

IF OBJECT_ID('UC_Permission_Key') IS NOT NULL AND OBJECT_ID('dbo.UC_Permission_Key1') IS NULL
	EXECUTE sp_rename 'UC_Permission_Key', 'UC_Permission_Key1';
IF OBJECT_ID('PK_Permission') IS NOT NULL AND OBJECT_ID('dbo.PK_Permission1') IS NULL
	EXECUTE sp_rename 'PK_Permission', 'PK_Permission1';
IF OBJECT_ID('DF_RolePermission_IsAccess') IS NOT NULL AND OBJECT_ID('.DF_RolePermission_IsAccess1') IS NULL
	EXECUTE sp_rename 'DF_RolePermission_IsAccess',N'DF_RolePermission_IsAccess1';
IF OBJECT_ID('DF_RolePermission_CreatedOn') IS NOT NULL AND OBJECT_ID('dbo.DF_RolePermission_CreatedOn1') IS NULL
	EXECUTE sp_rename 'DF_RolePermission_CreatedOn', 'DF_RolePermission_CreatedOn1';
IF OBJECT_ID('DF_RolePermission_IsDeleted]') IS NOT NULL AND OBJECT_ID('dbo.DF_RolePermission_IsDeleted1') IS NULL
	EXECUTE sp_rename 'DF_RolePermission_IsDeleted', 'DF_RolePermission_IsDeleted1';
IF OBJECT_ID('PK_RolePermission') IS NOT NULL AND OBJECT_ID('PK_RolePermission1') IS NULL
	EXECUTE sp_rename 'PK_RolePermission]', 'PK_RolePermission1';
IF OBJECT_ID('UC_RolePermission_RoleId_PermissionId') IS NOT NULL AND OBJECT_ID('dbo.UC_RolePermission_RoleId_PermissionId1') IS NULL
	EXECUTE sp_rename '[dbo].[UC_RolePermission_RoleId_PermissionId]', 'UC_RolePermission_RoleId_PermissionId1';
IF OBJECT_ID('dbo.[FK_RolePermission_PermissionId]') IS NOT NULL AND OBJECT_ID('dbo.FK_RolePermission_PermissionId1') IS NULL
	EXECUTE sp_rename '[dbo].[FK_RolePermission_PermissionId]', 'FK_RolePermission_PermissionId1';
IF OBJECT_ID('dbo.[FK_RolePermission_RoleId]') IS NOT NULL AND OBJECT_ID('dbo.FK_RolePermission_RoleId1') IS NULL
	EXECUTE sp_rename '[dbo].[FK_RolePermission_RoleId]', 'FK_RolePermission_RoleId1';

IF OBJECT_ID('dbo.Permission') IS NULL
BEGIN
	CREATE TABLE [dbo].[Permission] (
	    [PermissionId] INT IDENTITY (1, 1) NOT NULL,
	    [Name] NVARCHAR (150) NOT NULL,
		[Key] NVARCHAR (150) CONSTRAINT [UC_Permission_Key] UNIQUE([Key]) NOT NULL,
	    [CreatedOn] DATETIME2 (7) DEFAULT (getutcdate()) NOT NULL,
	    [ModifiedOn] DATETIME2 (7) NULL,
	    CONSTRAINT [PK_Permission] PRIMARY KEY CLUSTERED ([PermissionId] ASC)
	);
END


IF OBJECT_ID('dbo.RolePermission') IS NULL
BEGIN
	CREATE TABLE [dbo].[RolePermission] (
	    [RolePermissionId] INT IDENTITY (1, 1) NOT NULL,
	    [RoleId] INT NOT NULL,
	    [PermissionId] INT NOT NULL,
		[IsAccess] BIT CONSTRAINT [DF_RolePermission_IsAccess] DEFAULT 0 NOT NULL,
	    [CreatedOn] DATETIME2 (7) CONSTRAINT [DF_RolePermission_CreatedOn] DEFAULT (getutcdate()) NOT NULL,
	    [CreatedBy] INT NULL,
	    [ModifiedOn] DATETIME2 (7) NULL,
	    [ModifiedBy] INT NULL,
	    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_RolePermission_IsDeleted] DEFAULT 0,
	    [DeletedBy] INT NULL,
	    [DeletedOn] DATETIME2 NULL,
	
	    CONSTRAINT [PK_RolePermission] PRIMARY KEY CLUSTERED ([RolePermissionId] ASC),
		CONSTRAINT [UC_RolePermission_RoleId_PermissionId] UNIQUE NONCLUSTERED ([RoleId], [PermissionId]),
	    CONSTRAINT [FK_RolePermission_PermissionId] FOREIGN KEY ([PermissionId]) REFERENCES [dbo].[Permission] ([PermissionId]),
	    CONSTRAINT [FK_RolePermission_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([RoleId])
	);
END

IF OBJECT_ID('dbo.Permission') IS NOT NULL
BEGIN 
MERGE INTO [dbo].[Permission] AS Target
USING (VALUES
    (N'Usermanagement_IsView', N'UserMgmt_View'),	
	(N'Usermanagement_User_IsView', N'UserMgmt_User_View'),	
    (N'Usermanagement_User_IsCreate', N'UserMgmt_User_Create'),	
    (N'Usermanagement_User_IsDelete', N'UserMgmt_User_Delete'),	
    (N'Usermanagement_User_IsEdit', N'UserMgmt_User_Edit'),	
    (N'Usermanagement_User_IsPublishActivate', N'UserMgmt_User_PublishActivate'),
	(N'Usermanagement_Groups_IsView', N'UserMgmt_Group_View'),
	(N'Usermanagement_Groups_IsCreate', N'UserMgmt_Group_Create'),
	(N'Usermanagement_Groups_IsDelete', N'UserMgmt_Group_Delete'),
	(N'Usermanagement_Groups_IsEdit', N'UserMgmt_Group_Edit'),
	(N'Usermanagement_Roles_IsView', N'UserMgmt_Role_View'),
	(N'Usermanagement_Roles_IsCreate', N'UserMgmt_Role_Create'),
	(N'Usermanagement_Roles_IsDelete', N'UserMgmt_Role_Delete'),
	(N'Usermanagement_Roles_IsEdit', N'UserMgmt_Role_Edit'),
	(N'Usermanagement_GroupCharacteristics_IsView', N'UserMgmt_GroupCharcts_View'),
	(N'Usermanagement_GroupCharacteristics_IsCreate', N'UserMgmt_GroupCharcts_Create'),
	(N'Usermanagement_GroupCharacteristics_IsDelete', N'UserMgmt_GroupCharcts_Delete'),
	(N'Usermanagement_GroupCharacteristics_IsEdit', N'UserMgmt_GroupCharcts_Edit'),
	(N'Usermanagement_Supportusers_IsView', N'UserMgmt_SupportUser_View'),
	(N'General_IsView', N'General_View'),
	(N'General_IsCreate', N'General_Create'),
	(N'General_IsDelete', N'General_Delete'),
	(N'General_IsEdit', N'General_Edit'),
	(N'General_IsPublishActivate', N'General_PublishActivate'),
	(N'General_Notification_IsView', N'General_Notif_View'),
	(N'General_Notification_IsCreate', N'General_Notif_Create'),
	(N'General_Notification_IsDelete', N'General_Notif_Delete'),
	(N'General_Notification_IsEdit', N'General_Notif_Edit'),
	(N'Projects_IsView', N'Project_View'),
	(N'Projects_IsCreate', N'Project_Create'),
	(N'Projects_IsDelete', N'Project_Delete'),
	(N'Projects_IsEdit', N'Project_Edit'),
	(N'Projects_IsPublishActivate', N'Project_PublishActivate'),
	(N'Blog_IsView', N'Blog_View'),
	(N'Blog_IsCreate', N'Blog_Create'),
	(N'Blog_IsDelete', N'Blog_Delete'),
	(N'Blog_IsEdit', N'Blog_Edit'),
	(N'Blog_IsPublishActivate', N'Blog_PublishActivate'),
	(N'Portalmanagement_IsView', N'PortalMgmt_View'),
	(N'Portalmanagement_IsEdit', N'PortalMgmt_Edit'),
	(N'Medialibrary_IsView', N'MediaLib_View'),
	(N'Medialibrary_IsCreate', N'MediaLib_Create'),
	(N'Medialibrary_IsDelete', N'MediaLib_Delete'),
	(N'Medialibrary_IsEdit', N'MediaLib_Edit'),
	(N'Projects_Questionnaire_IsView', N'Project_Questionnaire_View'),
	(N'Projects_Questionnaire_IsCreate', N'Project_Questionnaire_Create'),
	(N'Projects_Questionnaire_IsDelete', N'Project_Questionnaire_Delete'),
	(N'Projects_Questionnaire_IsEdit', N'Project_Questionnaire_Edit'),
	(N'Projects_Questionnaire_IsPublishActivate', N'Project_Questionnaire_PublishActivate'),
	(N'Projects_IrisDataReport_IsView', N'Project_IrisDataReport_View'),
	(N'Projects_IrisDataReport_IsCreate', N'Project_IrisDataReport_Create'),
	(N'Projects_Publish_IsView', N'Project_Publish_View'),
	(N'Projects_Publish_IsCreate', N'Project_Publish_Create'),
	(N'Projects_Publish_IsDelete', N'Project_Publish_Delete'),
	(N'IrisPushReport_IsView', N'IrisPushReport_View'),
	(N'IrisPushReport_IsCreate', N'IrisPushReport_Create'),
	(N'IrisPushReport_IsDelete', N'IrisPushReport_Delete'),
	(N'IrisPushReport_IsEdit', N'IrisPushReport_Edit'),
	(N'Tenantmanagement_IsView', N'TenantMgmt_View'),
	(N'Tenantmanagement_IsCreate', N'TenantMgmt_Create'),
	(N'Tenantmanagement_IsDelete', N'TenantMgmt_Delete'),
	(N'Tenantmanagement_IsEdit', N'TenantMgmt_Edit'),
	(N'Tenantmanagement_IsPublishActivate', N'TenantMgmt_PublishActivate'),
	(N'Tenantmanagement_Supportusers_IsView', N'TenantMgmt_SupportUser_View'),
	(N'Tenantmanagement_Supportusers_IsCreate', N'TenantMgmt_SupportUser_Create'),
	(N'Tenantmanagement_Supportusers_IsDelete', N'TenantMgmt_SupportUser_Delete'),
	(N'Tenantmanagement_Package_IsView', N'TenantMgmt_Pkg_View'),
	(N'Tenantmanagement_Package_IsEdit', N'TenantMgmt_Pkg_Edit'),
	(N'Blacklistsubdomain_IsView', N'BlackListSubDomain_View'),
	(N'Blacklistsubdomain_IsCreate', N'BlackListSubDomain_Create'),
	(N'Blacklistsubdomain_IsDelete', N'BlackListSubDomain_Delete'),
	(N'Blacklistsubdomain_IsEdit', N'BlackListSubDomain_Edit')

) AS Source ([Name],[Key])
ON Target.[Key] = Source.[Key]

WHEN MATCHED THEN 
UPDATE SET
	Target.[Name] = Source.[Name]

WHEN NOT MATCHED BY TARGET THEN 
    INSERT ([Name], [Key], [CreatedOn], [ModifiedOn])
    VALUES (Source.[Name], Source.[Key], GetUTCDate(), GetUTCDate())

WHEN NOT MATCHED BY SOURCE THEN
DELETE;
END


-- Drop function if already exist
DROP FUNCTION IF EXISTS [dbo].GetRoleIdByName

DROP FUNCTION IF EXISTS [dbo].GetPermissionId

ENDS:
	PRINT 'END'
GO

IF COL_LENGTH('dbo.RolePermission', 'IsAccess') IS NOT NULL
GOTO ENDS2

CREATE FUNCTION [dbo].GetRoleIdByName(@name NVARCHAR(50))
RETURNS INT AS    
BEGIN RETURN(SELECT TOP 1 RoleId FROM [dbo].[Role] WHERE [NAME] = @name) END
GO

CREATE FUNCTION [dbo].GetPermissionId(@key NVARCHAR(50))
RETURNS INT AS
BEGIN RETURN (SELECT TOP 1 PermissionId FROM [dbo].[Permission] WHERE [Key] = @key) END
GO

CREATE TABLE #NameMap(OldName NVARCHAR (150), CurrentName NVARCHAR (150))
GO

INSERT INTO #NameMap (OldName, CurrentName) VALUES
('Usermanagement', 'UserMgmt_'),
('Usermanagement_Users', 'UserMgmt_User_'),
('Usermanagement_Groups', 'UserMgmt_Group_'),
('Usermanagement_Roles', 'UserMgmt_Role_'),
('Usermanagement_GroupCharacteristics', 'UserMgmt_GroupCharcts_'),
('Usermanagement_Supportusers', 'UserMgmt_SupportUser_'),
('General', 'General_'),
('General_Notification', 'General_Notif_'),
('Projects', 'Project_'),
('Blog', 'Blog_'),
('Portalmanagement', 'PortalMgmt_'),
('Medialibrary', 'MediaLib_'),
('Projects_Questionnaire', 'Project_Questionnaire_'),
('Projects_IrisDataReport', 'Project_IrisDataReport_'),
('IrisPushReport', 'IrisPushReport_'),
('Tenantmanagement', 'TenantMgmt_'),
('Tenantmanagement_Supportusers', 'TenantMgmt_SupportUser_'),
('Blacklistsubdomain', 'BlackListSubDomain_')
GO

--IF OBJECT_ID('dbo.RolePermission1') IS NULL OR COL_LENGTH('dbo.RolePermission1', 'IsView') IS NULL OR OBJECT_ID('dbo.Permission1') IS NULL
--GOTO EndScript_1

IF OBJECT_ID('dbo.RolePermission1') IS NOT NULL AND COL_LENGTH('dbo.RolePermission1', 'IsView') IS NOT NULL AND OBJECT_ID('dbo.Permission1') IS NOT NULL
BEGIN
	SET NOCOUNT ON
	DECLARE @RoleId int;
	DECLARE @PermissionId int;
	DECLARE @IsView bit;
	DECLARE @IsCreate bit
	DECLARE @IsDelete bit
	DECLARE @IsEdit bit
	DECLARE @IsPublishActivate bit
	DECLARE @Name nvarchar(50)

	DECLARE cur_rp CURSOR
	STATIC FOR 
		SELECT RoleId, RP.PermissionId, IsView, IsCreate, IsDelete, IsEdit, IsPublishActivate, P.[Name]
		FROM [dbo].[RolePermission1] AS RP
		JOIN [dbo].[Permission1] AS P ON RP.PermissionId = P.PermissionId
	OPEN cur_rp
	IF @@CURSOR_ROWS > 0
	 BEGIN 
		 FETCH NEXT FROM cur_rp INTO @RoleId, @PermissionId, @IsView, @IsCreate, @IsDelete, @IsEdit, @IsPublishActivate, @Name
		 WHILE @@Fetch_status = 0
		 BEGIN
			DECLARE @newName varchar(150);
			SELECT TOP 1 @newName = CurrentName FROM #NameMap WHERE OldName = @Name;
			DECLARE @v varchar(150) = @newName + 'View';
			DECLARE @c varchar(150) = @newName + 'Create';
			DECLARE @d varchar(150) = @newName + 'Delete';
			DECLARE @e varchar(150) = @newName + 'Edit';
			DECLARE @p varchar(150) = @newName + 'PublishActivate';

			DECLARE @permissionIdInsert INT = [dbo].[GetPermissionId](@v);
			PRINT @permissionIdInsert
			IF (@permissionIdInsert IS NOT NULL) AND (@IsView IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleId] = @RoleId AND [PermissionId] = @permissionIdInsert)
				INSERT INTO [dbo].[RolePermission]([RoleId],[PermissionId],[IsAccess]) VALUES
				(@RoleId, @permissionIdInsert, @IsView)
			ELSE
				PRINT 'Record Already exist or no permission'
	
			SET @permissionIdInsert = [dbo].[GetPermissionId](@c);
			IF (@permissionIdInsert IS NOT NULL) AND (@IsCreate IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleId] = @RoleId AND [PermissionId] = @permissionIdInsert)
				INSERT INTO [dbo].[RolePermission]([RoleId],[PermissionId],[IsAccess]) VALUES
				(@RoleId, @permissionIdInsert, @IsCreate)
			ELSE
				PRINT 'Record Already exist or no permission'

			SET @permissionIdInsert = [dbo].[GetPermissionId](@d);
			IF (@permissionIdInsert IS NOT NULL) AND (@IsDelete IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleId] = @RoleId AND [PermissionId] = @permissionIdInsert)
				INSERT INTO [dbo].[RolePermission]([RoleId],[PermissionId],[IsAccess]) VALUES
				(@RoleId, @permissionIdInsert, @IsDelete)
			ELSE
				PRINT 'Record Already exist or no permission'

			SET @permissionIdInsert = [dbo].[GetPermissionId](@e);
			IF (@permissionIdInsert IS NOT NULL) AND (@IsEdit IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleId] = @RoleId AND [PermissionId] = @permissionIdInsert)
				INSERT INTO [dbo].[RolePermission]([RoleId],[PermissionId],[IsAccess]) VALUES
				(@RoleId, @permissionIdInsert, @IsEdit)
			ELSE
				PRINT 'Record Already exist or no permission'

			SET @permissionIdInsert = [dbo].[GetPermissionId](@p);
			IF (@permissionIdInsert IS NOT NULL) AND (@IsPublishActivate IS NOT NULL) AND NOT EXISTS (SELECT 1 FROM [dbo].[RolePermission] WHERE [RoleId] = @RoleId AND [PermissionId] = @permissionIdInsert)
				INSERT INTO [dbo].[RolePermission]([RoleId],[PermissionId],[IsAccess]) VALUES
				(@RoleId, @permissionIdInsert, @IsPublishActivate)
			ELSE
				PRINT 'Record Already exist or no permission'

		 FETCH NEXT FROM cur_rp INTO @RoleId, @PermissionId, @IsView, @IsCreate, @IsDelete, @IsEdit, @IsPublishActivate, @Name
		 END
	END
	CLOSE cur_rp
	DEALLOCATE cur_rp
	SET NOCOUNT OFF

	DROP TABLE [dbo].[RolePermission1];
	DROP TABLE [dbo].[Permission1];
END
GO

--EndScript_1:

DROP TABLE IF EXISTS #NameMap
-- This query not inserts Tenent management, Blacklist sub domain, Tenant managemnrt support user permissions

DECLARE @appUser INT = [dbo].GetRoleIdByName(N'App users');
DECLARE @accountAdmin INT = [dbo].GetRoleIdByName(N'Account administrators');
DECLARE @admin INT = [dbo].GetRoleIdByName(N'Administrators');
DECLARE @projCollaborator INT = [dbo].GetRoleIdByName(N'Project collaborators');
DECLARE @noRole INT = [dbo].GetRoleIdByName(N'No role');

DECLARE @UserMgmt_View INT = [dbo].GetPermissionId(N'UserMgmt_View');

DECLARE @UserMgmt_User_View INT = [dbo].GetPermissionId(N'UserMgmt_User_View');
DECLARE @UserMgmt_User_Create INT = [dbo].GetPermissionId(N'UserMgmt_User_Create');
DECLARE @UserMgmt_User_Delete INT = [dbo].GetPermissionId(N'UserMgmt_User_Delete');
DECLARE @UserMgmt_User_Edit INT = [dbo].GetPermissionId(N'UserMgmt_User_Edit');
DECLARE @UserMgmt_User_PublishActivate INT = [dbo].GetPermissionId(N'UserMgmt_User_PublishActivate');

DECLARE @UserMgmt_Group_View INT = [dbo].GetPermissionId(N'UserMgmt_Group_View');
DECLARE @UserMgmt_Group_Create INT = [dbo].GetPermissionId(N'UserMgmt_Group_Create');
DECLARE @UserMgmt_Group_Delete INT = [dbo].GetPermissionId(N'UserMgmt_Group_Delete');
DECLARE @UserMgmt_Group_Edit INT = [dbo].GetPermissionId(N'UserMgmt_Group_Edit');

DECLARE @UserMgmt_Role_View INT = [dbo].GetPermissionId(N'UserMgmt_Role_View');
DECLARE @UserMgmt_Role_Create INT = [dbo].GetPermissionId(N'UserMgmt_Role_Create');
DECLARE @UserMgmt_Role_Delete INT = [dbo].GetPermissionId(N'UserMgmt_Role_Delete');
DECLARE @UserMgmt_Role_Edit INT = [dbo].GetPermissionId(N'UserMgmt_Role_Edit');

DECLARE @UserMgmt_GroupCharcts_View INT = [dbo].GetPermissionId(N'UserMgmt_GroupCharcts_View');
DECLARE @UserMgmt_GroupCharcts_Create INT = [dbo].GetPermissionId(N'UserMgmt_GroupCharcts_Create');
DECLARE @UserMgmt_GroupCharcts_Delete INT = [dbo].GetPermissionId(N'UserMgmt_GroupCharcts_Delete');
DECLARE @UserMgmt_GroupCharcts_Edit INT = [dbo].GetPermissionId(N'UserMgmt_GroupCharcts_Edit');

DECLARE @UserMgmt_SupportUser_View INT = [dbo].GetPermissionId(N'UserMgmt_SupportUser_View');

DECLARE @General_View INT = [dbo].GetPermissionId(N'General_View');
DECLARE @General_Create INT = [dbo].GetPermissionId(N'General_Create');
DECLARE @General_Delete INT = [dbo].GetPermissionId(N'General_Delete');
DECLARE @General_Edit INT = [dbo].GetPermissionId(N'General_Edit');
DECLARE @General_PublishActivate INT = [dbo].GetPermissionId(N'General_PublishActivate');

DECLARE @General_Notif_View INT = [dbo].GetPermissionId(N'General_Notif_View');
DECLARE @General_Notif_Create INT = [dbo].GetPermissionId(N'General_Notif_Create');
DECLARE @General_Notif_Delete INT = [dbo].GetPermissionId(N'General_Notif_Delete');
DECLARE @General_Notif_Edit INT = [dbo].GetPermissionId(N'General_Notif_Edit');

DECLARE @Project_View INT = [dbo].GetPermissionId(N'Project_View');
DECLARE @Project_Create INT = [dbo].GetPermissionId(N'Project_Create');
DECLARE @Project_Delete INT = [dbo].GetPermissionId(N'Project_Delete');
DECLARE @Project_Edit INT = [dbo].GetPermissionId(N'Project_Edit');
DECLARE @Project_PublishActivate INT = [dbo].GetPermissionId(N'Project_PublishActivate');

DECLARE @Blog_View INT = [dbo].GetPermissionId(N'Blog_View');
DECLARE @Blog_Create INT = [dbo].GetPermissionId(N'Blog_Create');
DECLARE @Blog_Delete INT = [dbo].GetPermissionId(N'Blog_Delete');
DECLARE @Blog_Edit INT = [dbo].GetPermissionId(N'Blog_Edit');
DECLARE @Blog_PublishActivate INT = [dbo].GetPermissionId(N'Blog_PublishActivate');

DECLARE @PortalMgmt_View INT = [dbo].GetPermissionId(N'PortalMgmt_View');
DECLARE @PortalMgmt_Edit INT = [dbo].GetPermissionId(N'PortalMgmt_Edit');

DECLARE @MediaLib_View INT = [dbo].GetPermissionId(N'MediaLib_View');
DECLARE @MediaLib_Create INT = [dbo].GetPermissionId(N'MediaLib_Create');
DECLARE @MediaLib_Delete INT = [dbo].GetPermissionId(N'MediaLib_Delete');
DECLARE @MediaLib_Edit INT = [dbo].GetPermissionId(N'MediaLib_Edit');

DECLARE @Project_Questionnaire_View INT = [dbo].GetPermissionId(N'Project_Questionnaire_View');
DECLARE @Project_Questionnaire_Create INT = [dbo].GetPermissionId(N'Project_Questionnaire_Create');
DECLARE @Project_Questionnaire_Delete INT = [dbo].GetPermissionId(N'Project_Questionnaire_Delete');
DECLARE @Project_Questionnaire_Edit INT = [dbo].GetPermissionId(N'Project_Questionnaire_Edit');
DECLARE @Project_Questionnaire_PublishActivate INT = [dbo].GetPermissionId(N'Project_Questionnaire_PublishActivate');

DECLARE @Project_IrisDataReport_View INT = [dbo].GetPermissionId(N'Project_IrisDataReport_View');
DECLARE @Project_IrisDataReport_Create INT = [dbo].GetPermissionId(N'Project_IrisDataReport_Create');

DECLARE @Project_Publish_View INT = [dbo].GetPermissionId(N'Project_Publish_View');
DECLARE @Project_Publish_Create INT = [dbo].GetPermissionId(N'Project_Publish_Create');
DECLARE @Project_Publish_Delete INT = [dbo].GetPermissionId(N'Project_Publish_Delete');

DECLARE @IrisPushReport_View INT = [dbo].GetPermissionId(N'IrisPushReport_View');
DECLARE @IrisPushReport_Create INT = [dbo].GetPermissionId(N'IrisPushReport_Create');
DECLARE @IrisPushReport_Delete INT = [dbo].GetPermissionId(N'IrisPushReport_Delete');
DECLARE @IrisPushReport_Edit INT = [dbo].GetPermissionId(N'IrisPushReport_Edit');

MERGE INTO [dbo].[RolePermission] AS Target
USING (VALUES
    (@appUser, @UserMgmt_View, 1), -- AppUser
    (@appUser, @UserMgmt_User_View, 1),
    (@appUser, @UserMgmt_User_Create, 0),
    (@appUser, @UserMgmt_User_Delete, 0),
    (@appUser, @UserMgmt_User_Edit, 0),
    (@appUser, @UserMgmt_User_PublishActivate, 0),
    (@appUser, @UserMgmt_Group_View, 0),
    (@appUser, @UserMgmt_Group_Create, 0),
    (@appUser, @UserMgmt_Group_Delete, 0),
    (@appUser, @UserMgmt_Group_Edit, 0),
    (@appUser, @UserMgmt_Role_View, 1),
    (@appUser, @UserMgmt_Role_Create, 0),
    (@appUser, @UserMgmt_Role_Delete, 0),
    (@appUser, @UserMgmt_Role_Edit, 0),
    (@appUser, @UserMgmt_GroupCharcts_View, 0),
    (@appUser, @UserMgmt_GroupCharcts_Create, 0),
    (@appUser, @UserMgmt_GroupCharcts_Delete, 0),
    (@appUser, @UserMgmt_GroupCharcts_Edit, 0),
    (@appUser, @UserMgmt_SupportUser_View, 1),
    (@appUser, @General_View, 0),
    (@appUser, @General_Create, 0),
    (@appUser, @General_Delete, 0),
    (@appUser, @General_Edit, 0),
    (@appUser, @General_PublishActivate, 0),
    (@appUser, @General_Notif_View, 0),
    (@appUser, @General_Notif_Create, 0),
    (@appUser, @General_Notif_Delete, 0),
    (@appUser, @General_Notif_Edit, 0),
    (@appUser, @Project_View, 0),
    (@appUser, @Project_Create, 0),
    (@appUser, @Project_Delete, 0),
    (@appUser, @Project_Edit, 0),
    (@appUser, @Project_PublishActivate, 0),
    (@appUser, @Blog_View, 0),
    (@appUser, @Blog_Create, 0),
    (@appUser, @Blog_Delete, 0),
    (@appUser, @Blog_Edit, 0),
    (@appUser, @Blog_PublishActivate, 0),
    (@appUser, @PortalMgmt_View, 0),
    (@appUser, @PortalMgmt_Edit, 0),
    (@appUser, @MediaLib_View, 0),
    (@appUser, @MediaLib_Create, 0),
    (@appUser, @MediaLib_Delete, 0),
    (@appUser, @MediaLib_Edit, 0),
    (@appUser, @Project_Questionnaire_View, 0),
    (@appUser, @Project_Questionnaire_Create, 0),
    (@appUser, @Project_Questionnaire_Delete, 0),
    (@appUser, @Project_Questionnaire_Edit, 0),
    (@appUser, @Project_Questionnaire_PublishActivate, 0),
    (@appUser, @Project_IrisDataReport_View, 0),
    (@appUser, @Project_IrisDataReport_Create, 0),
	(@appUser, @Project_Publish_View, 0),
	(@appUser, @Project_Publish_Create, 0),
	(@appUser, @Project_Publish_Delete, 0),
    (@appUser, @IrisPushReport_View, 0),
    (@appUser, @IrisPushReport_Create, 0),
    (@appUser, @IrisPushReport_Delete, 0),
    (@appUser, @IrisPushReport_Edit, 0),
	(@accountAdmin, @UserMgmt_View, 1),--AccountAdmin
    (@accountAdmin, @UserMgmt_User_View, 1),
    (@accountAdmin, @UserMgmt_User_Create, 1),
    (@accountAdmin, @UserMgmt_User_Delete, 1),
    (@accountAdmin, @UserMgmt_User_Edit, 1),
    (@accountAdmin, @UserMgmt_User_PublishActivate, 1),
    (@accountAdmin, @UserMgmt_Group_View, 1),
    (@accountAdmin, @UserMgmt_Group_Create, 1),
    (@accountAdmin, @UserMgmt_Group_Delete, 1),
    (@accountAdmin, @UserMgmt_Group_Edit, 1),
    (@accountAdmin, @UserMgmt_Role_View, 1),
    (@accountAdmin, @UserMgmt_Role_Create, 1),
    (@accountAdmin, @UserMgmt_Role_Delete, 1),
    (@accountAdmin, @UserMgmt_Role_Edit, 1),
    (@accountAdmin, @UserMgmt_GroupCharcts_View, 1),
    (@accountAdmin, @UserMgmt_GroupCharcts_Create, 1),
    (@accountAdmin, @UserMgmt_GroupCharcts_Delete, 1),
    (@accountAdmin, @UserMgmt_GroupCharcts_Edit, 1),
    (@accountAdmin, @UserMgmt_SupportUser_View, 1),
    (@accountAdmin, @General_View, 1),
    (@accountAdmin, @General_Create, 1),
    (@accountAdmin, @General_Delete, 1),
    (@accountAdmin, @General_Edit, 1),
    (@accountAdmin, @General_PublishActivate, 1),
    (@accountAdmin, @General_Notif_View, 1),
    (@accountAdmin, @General_Notif_Create, 1),
    (@accountAdmin, @General_Notif_Delete, 1),
    (@accountAdmin, @General_Notif_Edit, 1),
    (@accountAdmin, @Project_View, 1),
    (@accountAdmin, @Project_Create, 1),
    (@accountAdmin, @Project_Delete, 1),
    (@accountAdmin, @Project_Edit, 1),
    (@accountAdmin, @Project_PublishActivate, 1),
    (@accountAdmin, @Blog_View, 1),
    (@accountAdmin, @Blog_Create, 1),
    (@accountAdmin, @Blog_Delete, 1),
    (@accountAdmin, @Blog_Edit, 1),
    (@accountAdmin, @Blog_PublishActivate, 1),
    (@accountAdmin, @PortalMgmt_View, 1),
    (@accountAdmin, @PortalMgmt_Edit, 1),
    (@accountAdmin, @MediaLib_View, 1),
    (@accountAdmin, @MediaLib_Create, 1),
    (@accountAdmin, @MediaLib_Delete, 1),
    (@accountAdmin, @MediaLib_Edit, 1),
    (@accountAdmin, @Project_Questionnaire_View, 1),
    (@accountAdmin, @Project_Questionnaire_Create, 1),
    (@accountAdmin, @Project_Questionnaire_Delete, 1),
    (@accountAdmin, @Project_Questionnaire_Edit, 1),
    (@accountAdmin, @Project_Questionnaire_PublishActivate, 1),
    (@accountAdmin, @Project_IrisDataReport_View, 1),
    (@accountAdmin, @Project_IrisDataReport_Create, 1),
	(@accountAdmin, @Project_Publish_View, 1),
	(@accountAdmin, @Project_Publish_Create, 1),
	(@accountAdmin, @Project_Publish_Delete, 1),
    (@accountAdmin, @IrisPushReport_View, 1),
    (@accountAdmin, @IrisPushReport_Create, 1),
    (@accountAdmin, @IrisPushReport_Delete, 1),
    (@accountAdmin, @IrisPushReport_Edit, 1),
	(@admin, @UserMgmt_View, 1), -- Admin
    (@admin, @UserMgmt_User_View, 1),
    (@admin, @UserMgmt_User_Create, 1),
    (@admin, @UserMgmt_User_Delete, 1),
    (@admin, @UserMgmt_User_Edit, 1),
    (@admin, @UserMgmt_User_PublishActivate, 1),
    (@admin, @UserMgmt_Group_View, 1),
    (@admin, @UserMgmt_Group_Create, 1),
    (@admin, @UserMgmt_Group_Delete, 1),
    (@admin, @UserMgmt_Group_Edit, 1),
    (@admin, @UserMgmt_Role_View, 1),
    (@admin, @UserMgmt_Role_Create, 1),
    (@admin, @UserMgmt_Role_Delete, 1),
    (@admin, @UserMgmt_Role_Edit, 1),
    (@admin, @UserMgmt_GroupCharcts_View, 1),
    (@admin, @UserMgmt_GroupCharcts_Create, 1),
    (@admin, @UserMgmt_GroupCharcts_Delete, 1),
    (@admin, @UserMgmt_GroupCharcts_Edit, 1),
    (@admin, @UserMgmt_SupportUser_View, 1),
    (@admin, @General_View, 1),
    (@admin, @General_Create, 1),
    (@admin, @General_Delete, 1),
    (@admin, @General_Edit, 1),
    (@admin, @General_PublishActivate, 1),
    (@admin, @General_Notif_View, 1),
    (@admin, @General_Notif_Create, 1),
    (@admin, @General_Notif_Delete, 1),
    (@admin, @General_Notif_Edit, 1),
    (@admin, @Project_View, 1),
    (@admin, @Project_Create, 1),
    (@admin, @Project_Delete, 1),
    (@admin, @Project_Edit, 1),
    (@admin, @Project_PublishActivate, 1),
    (@admin, @Blog_View, 1),
    (@admin, @Blog_Create, 1),
    (@admin, @Blog_Delete, 1),
    (@admin, @Blog_Edit, 1),
    (@admin, @Blog_PublishActivate, 1),
    (@admin, @PortalMgmt_View, 1),
    (@admin, @PortalMgmt_Edit, 1),
    (@admin, @MediaLib_View, 1),
    (@admin, @MediaLib_Create, 1),
    (@admin, @MediaLib_Delete, 1),
    (@admin, @MediaLib_Edit, 1),
    (@admin, @Project_Questionnaire_View, 1),
    (@admin, @Project_Questionnaire_Create, 1),
    (@admin, @Project_Questionnaire_Delete, 1),
    (@admin, @Project_Questionnaire_Edit, 1),
    (@admin, @Project_Questionnaire_PublishActivate, 1),
    (@admin, @Project_IrisDataReport_View, 1),
    (@admin, @Project_IrisDataReport_Create, 1),
	(@admin, @Project_Publish_View, 1),
	(@admin, @Project_Publish_Create, 1),
	(@admin, @Project_Publish_Delete, 1),
    (@admin, @IrisPushReport_View, 1),
    (@admin, @IrisPushReport_Create, 1),
    (@admin, @IrisPushReport_Delete, 1),
    (@admin, @IrisPushReport_Edit, 1),
	(@projCollaborator, @UserMgmt_View, 1),--projCollaborator
    (@projCollaborator, @UserMgmt_User_View, 1),
    (@projCollaborator, @UserMgmt_User_Create, 0),
    (@projCollaborator, @UserMgmt_User_Delete, 0),
    (@projCollaborator, @UserMgmt_User_Edit, 0),
    (@projCollaborator, @UserMgmt_User_PublishActivate, 0),
    (@projCollaborator, @UserMgmt_Group_View, 0),
    (@projCollaborator, @UserMgmt_Group_Create, 0),
    (@projCollaborator, @UserMgmt_Group_Delete, 0),
    (@projCollaborator, @UserMgmt_Group_Edit, 0),
    (@projCollaborator, @UserMgmt_Role_View, 1),
    (@projCollaborator, @UserMgmt_Role_Create, 0),
    (@projCollaborator, @UserMgmt_Role_Delete, 0),
    (@projCollaborator, @UserMgmt_Role_Edit, 0),
    (@projCollaborator, @UserMgmt_GroupCharcts_View, 0),
    (@projCollaborator, @UserMgmt_GroupCharcts_Create, 0),
    (@projCollaborator, @UserMgmt_GroupCharcts_Delete, 0),
    (@projCollaborator, @UserMgmt_GroupCharcts_Edit, 0),
    (@projCollaborator, @UserMgmt_SupportUser_View, 1),
    (@projCollaborator, @General_View, 0),
    (@projCollaborator, @General_Create, 0),
    (@projCollaborator, @General_Delete, 0),
    (@projCollaborator, @General_Edit, 0),
    (@projCollaborator, @General_PublishActivate, 0),
    (@projCollaborator, @General_Notif_View, 0),
    (@projCollaborator, @General_Notif_Create, 0),
    (@projCollaborator, @General_Notif_Delete, 0),
    (@projCollaborator, @General_Notif_Edit, 0),
    (@projCollaborator, @Project_View, 1),
    (@projCollaborator, @Project_Create, 0),
    (@projCollaborator, @Project_Delete, 0),
    (@projCollaborator, @Project_Edit, 1),
    (@projCollaborator, @Project_PublishActivate, 1),
    (@projCollaborator, @Blog_View, 0),
    (@projCollaborator, @Blog_Create, 0),
    (@projCollaborator, @Blog_Delete, 0),
    (@projCollaborator, @Blog_Edit, 0),
    (@projCollaborator, @Blog_PublishActivate, 0),
    (@projCollaborator, @PortalMgmt_View, 0),
    (@projCollaborator, @PortalMgmt_Edit, 0),
    (@projCollaborator, @MediaLib_View, 0),
    (@projCollaborator, @MediaLib_Create, 0),
    (@projCollaborator, @MediaLib_Delete, 0),
    (@projCollaborator, @MediaLib_Edit, 0),
    (@projCollaborator, @Project_Questionnaire_View, 1),
    (@projCollaborator, @Project_Questionnaire_Create, 0),
    (@projCollaborator, @Project_Questionnaire_Delete, 0),
    (@projCollaborator, @Project_Questionnaire_Edit, 1),
    (@projCollaborator, @Project_Questionnaire_PublishActivate, 1),
    (@projCollaborator, @Project_IrisDataReport_View, 1),
    (@projCollaborator, @Project_IrisDataReport_Create, 0),
	(@projCollaborator, @Project_Publish_View, 1),
	(@projCollaborator, @Project_Publish_Create, 0),
	(@projCollaborator, @Project_Publish_Delete, 0),
    (@projCollaborator, @IrisPushReport_View, 1),
    (@projCollaborator, @IrisPushReport_Create, 0),
    (@projCollaborator, @IrisPushReport_Delete, 0),
    (@projCollaborator, @IrisPushReport_Edit, 1),
    (@noRole, @UserMgmt_View, 1),--No Role
    (@noRole, @UserMgmt_User_View, 1),
    (@noRole, @UserMgmt_User_Create, 0),
    (@noRole, @UserMgmt_User_Delete, 0),
    (@noRole, @UserMgmt_User_Edit, 0),
    (@noRole, @UserMgmt_User_PublishActivate, 0),
    (@noRole, @UserMgmt_Group_View, 0),
    (@noRole, @UserMgmt_Group_Create, 0),
    (@noRole, @UserMgmt_Group_Delete, 0),
    (@noRole, @UserMgmt_Group_Edit, 0),
    (@noRole, @UserMgmt_Role_View, 1),
    (@noRole, @UserMgmt_Role_Create, 0),
    (@noRole, @UserMgmt_Role_Delete, 0),
    (@noRole, @UserMgmt_Role_Edit, 0),
    (@noRole, @UserMgmt_GroupCharcts_View, 0),
    (@noRole, @UserMgmt_GroupCharcts_Create, 0),
    (@noRole, @UserMgmt_GroupCharcts_Delete, 0),
    (@noRole, @UserMgmt_GroupCharcts_Edit, 0),
    (@noRole, @UserMgmt_SupportUser_View, 0),
    (@noRole, @General_View, 0),
    (@noRole, @General_Create, 0),
    (@noRole, @General_Delete, 0),
    (@noRole, @General_Edit, 0),
    (@noRole, @General_PublishActivate, 0),
    (@noRole, @General_Notif_View, 0),
    (@noRole, @General_Notif_Create, 0),
    (@noRole, @General_Notif_Delete, 0),
    (@noRole, @General_Notif_Edit, 0),
    (@noRole, @Project_View, 0),
    (@noRole, @Project_Create, 0),
    (@noRole, @Project_Delete, 0),
    (@noRole, @Project_Edit, 0),
    (@noRole, @Project_PublishActivate, 0),
    (@noRole, @Blog_View, 0),
    (@noRole, @Blog_Create, 0),
    (@noRole, @Blog_Delete, 0),
    (@noRole, @Blog_Edit, 0),
    (@noRole, @Blog_PublishActivate, 0),
    (@noRole, @PortalMgmt_View, 0),
    (@noRole, @PortalMgmt_Edit, 0),
    (@noRole, @MediaLib_View, 0),
    (@noRole, @MediaLib_Create, 0),
    (@noRole, @MediaLib_Delete, 0),
    (@noRole, @MediaLib_Edit, 0),
    (@noRole, @Project_Questionnaire_View, 0),
    (@noRole, @Project_Questionnaire_Create, 0),
    (@noRole, @Project_Questionnaire_Delete, 0),
    (@noRole, @Project_Questionnaire_Edit, 0),
    (@noRole, @Project_Questionnaire_PublishActivate, 0),
    (@noRole, @Project_IrisDataReport_View, 0),
    (@noRole, @Project_IrisDataReport_Create, 0),
	(@noRole, @Project_Publish_View, 0),
	(@noRole, @Project_Publish_Create, 0),
	(@noRole, @Project_Publish_Delete, 0),
    (@noRole, @IrisPushReport_View, 0),
    (@noRole, @IrisPushReport_Create, 0),
    (@noRole, @IrisPushReport_Delete, 0),
    (@noRole, @IrisPushReport_Edit, 0)

) AS Source ([RoleId],[PermissionId],[IsAccess])
ON Target.[RoleId] = Source.[RoleId] AND Target.[PermissionId] = Source.[PermissionId]

WHEN NOT MATCHED BY TARGET THEN 
    INSERT ([RoleId],[PermissionId],[IsAccess])
    VALUES (Source.[RoleId],Source.[PermissionId],Source.[IsAccess]);