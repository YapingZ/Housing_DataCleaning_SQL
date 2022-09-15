-- We want to creat a database called 'NashvilleHousing', and then will do data cleaning for this database
-- By Yaping 13/09/2022

USE master
GO 

IF NOT EXISTS(
    SELECT [name]
    FROM sys.databases 
    WHERE [name] = N'NashvilleHousing'
)

CREATE DATABASE NashvilleHousing
GO
