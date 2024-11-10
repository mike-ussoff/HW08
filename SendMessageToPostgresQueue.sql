USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID (N'Sales.SendMessageToPostgresQueue', N'P') IS NOT NULL
    DROP PROCEDURE Sales.SendMessageToPostgresQueue;
GO

CREATE PROCEDURE Sales.SendMessageToPostgresQueue
	@invoiceId INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);

	BEGIN TRAN 

	SELECT @RequestMessage = (
			SELECT CustomerID, DeliveryInstructions FROM Sales.Invoices WHERE InvoiceID = @invoiceId
			FOR JSON AUTO, ROOT(N'Invoices'));

	BEGIN DIALOG @InitDlgHandle FROM SERVICE [//WWI/SB/InitiatorService]
		TO SERVICE '//WWI/SB/TargetService' 
		ON CONTRACT [//WWI/SB/Contract]
		WITH ENCRYPTION=OFF; 	

	SEND ON CONVERSATION @InitDlgHandle MESSAGE TYPE [//WWI/SB/RequestMessage] (@RequestMessage);
	
	SELECT @RequestMessage AS SentRequestMessage;

	COMMIT TRAN 
END
GO