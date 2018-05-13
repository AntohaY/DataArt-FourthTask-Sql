USE [Bank1]
GO

/****** Object:  Table [dbo].[Addresses]    Script Date: 12.05.2018 13:43:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Addresses](
	[ClientID] [int] NOT NULL,
	[Country] [nvarchar](50) NOT NULL,
	[State] [nvarchar](50) NOT NULL,
	[City] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Addresses] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Card]    Script Date: 12.05.2018 13:43:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Card](
	[CadrID] [char](16) NOT NULL,
	[ClientID] [int] NOT NULL,
	[PinCode] [char](10) NOT NULL,
	[Ballance] [money] NOT NULL,
 CONSTRAINT [PK_Card] PRIMARY KEY CLUSTERED 
(
	[CadrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Clients]    Script Date: 12.05.2018 13:43:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Clients](
	[ClientID] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Birthday] [date] NOT NULL,
	[Phone] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Operations]    Script Date: 12.05.2018 13:43:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Operations](
	[OperationID] [int] NOT NULL,
	[InID] [char](16) NOT NULL,
	[OutID] [char](16) NOT NULL,
	[Amount] [money] NOT NULL,
	[OperationTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Operations] PRIMARY KEY CLUSTERED 
(
	[OperationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Operations] ADD  CONSTRAINT [DF_Operations_OperationTime]  DEFAULT (getdate()) FOR [OperationTime]
GO

ALTER TABLE [dbo].[Addresses]  WITH CHECK ADD  CONSTRAINT [FK_Addresses_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO

ALTER TABLE [dbo].[Addresses] CHECK CONSTRAINT [FK_Addresses_Clients]
GO

ALTER TABLE [dbo].[Card]  WITH CHECK ADD  CONSTRAINT [FK_Card_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO

ALTER TABLE [dbo].[Card] CHECK CONSTRAINT [FK_Card_Clients]
GO

ALTER TABLE [dbo].[Operations]  WITH CHECK ADD  CONSTRAINT [FK_Operations_Card] FOREIGN KEY([InID])
REFERENCES [dbo].[Card] ([CadrID])
GO

ALTER TABLE [dbo].[Operations] CHECK CONSTRAINT [FK_Operations_Card]
GO

ALTER TABLE [dbo].[Operations]  WITH CHECK ADD  CONSTRAINT [FK_Operations_OUT] FOREIGN KEY([OutID])
REFERENCES [dbo].[Card] ([CadrID])
GO

ALTER TABLE [dbo].[Operations] CHECK CONSTRAINT [FK_Operations_OUT]
GO
INSERT INTO [dbo].[Addresses]([ClientID],[Country],[State],[City],[Address])VALUES('2','Ukraine','Khersonska oblast','Kherson','Stepana Razina,75'),
('3','Ukraine','Khersonska oblast','Kherson','Ushakova,23'),
('4','Ukraine','Khersonska oblast','Kherson','Kulika,123')
INSERT INTO [dbo].[Clients] ([ClientID],[FirstName],[LastName],[Birthday],[Phone])
VALUES (1, '','', '1900-01-01','')
, (2,'Ivan','Ivanov', '1964-04-04','+380 (067) 111 11 11')
, (3,'Fedor','Fedorov', '1999-01-01','+380 (067) 222 11 11')	
, (4,'John','Smith', '1980-01-01','+380 (067) 333 33 33')
INSERT INTO [dbo].[Cards] ([CardID], [ClientID], [PinCode])
VALUES 
('0000000000000000', 1, '0000')
, ('1111111111111111', 2, '1111'), ('1111111111111112', 2, '1112'), ('1111111111111113', 2, '1113')
, ('2222222222222221', 3, '2221'), ('2222222222222222', 3, '2222')
, ('3333333333333331', 4, '3331')

INSERT INTO [dbo].[Operations] ([OutID],[InId],[Amount],[OperationTime])
VALUES 
('0000000000000000','1111111111111111', 1255.67)
, ('0000000000000000','2222222222222221', 100.00)
, ('0000000000000000','3333333333333331', 1000.00)
, ('1111111111111111','1111111111111112', 10.55)
, ('1111111111111111','1111111111111113', 1000.00)
, ('1111111111111111','2222222222222222', 33.00)
  


with cteIn as 
(
	select InId as cardNo, debet = sum(Amount)
	from Operations
	group by InId
)
, cteOut as 
(
	select OutID as cardNo, kredit = sum(Amount)
	from Operations
	group by OutID
)
, cteBallance as
(
	select c.CadrID, newBallance = isnull(debet, 0) - isnull(kredit, 0)
	from Card c
		left join cteIn i on c.CadrID = i.cardNo
		left join cteOut o on c.CadrID = o.cardNo
)
update Card
set Ballance = newBallance
from Card inner join cteBallance on Card.CadrID = cteBallance.CadrID





