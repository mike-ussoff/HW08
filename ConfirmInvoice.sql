USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID (N'Sales.ConfirmInvoice', N'P') IS NOT NULL
    DROP PROCEDURE Sales.ConfirmInvoice;
GO

CREATE PROCEDURE Sales.ConfirmInvoice
AS
BEGIN
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		IF (@InitiatorReplyDlgHandle is not null)
		BEGIN
			END CONVERSATION @InitiatorReplyDlgHandle; 
		END;
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --не для прода

	COMMIT TRAN; 
END
