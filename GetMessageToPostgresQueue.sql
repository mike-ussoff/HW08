USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID (N'Sales.GetMessageToPostgresQueue', N'P') IS NOT NULL
    DROP PROCEDURE Sales.GetMessageToPostgresQueue;
GO

CREATE PROCEDURE Sales.GetMessageToPostgresQueue
AS
BEGIN

	SET XACT_ABORT ON;

	DECLARE @queuename VARCHAR(20) = 'test_queue',
			@TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@InvoiceID INT,
			@cmd VARCHAR(1024);			
	
	BEGIN TRAN; 	
	
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	IF (@Message is not null)
	BEGIN
		SET @cmd = CONCAT('select * from pgmq.send(''', @queuename, ''',''', @message, ''')');
		EXEC (@cmd) AT pg_wwi_queue;
	END;

	SELECT @Message AS ReceivedRequestMessage, @MessageType as MessageType; --не для прода

	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'{"Result": "Ok"}'; 
	
		SEND ON CONVERSATION @TargetDlgHandle MESSAGE TYPE [//WWI/SB/ReplyMessage] (@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 

	SELECT @ReplyMessage AS SentReplyMessage; --не для прода

	COMMIT TRAN;
END