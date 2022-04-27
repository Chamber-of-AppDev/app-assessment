IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DBAnalysis]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[DBAnalysis](
		[DatabaseName] [nvarchar](100) NULL,
		[CPUTimeAsMS] [nvarchar](100) NULL,
		[CPUTimePercentage] [decimal](5, 2) NULL,
		[NumberOfConnections] [int] NULL,
		[LogDate] [datetime] NULL
	) ON [PRIMARY]
END;


WITH CPU_Per_Db
AS
(
	SELECT 
	 dmpa.DatabaseID
	 , DB_Name(dmpa.DatabaseID) AS [Database]
	 , SUM(dmqs.total_worker_time) AS CPUTimeAsMS
	 FROM sys.dm_exec_query_stats dmqs 
	 CROSS APPLY 
		(
			SELECT 
				CONVERT(INT, value) AS [DatabaseID] 
			FROM sys.dm_exec_plan_attributes(dmqs.plan_handle)
			WHERE attribute = N'dbid'
		) dmpa
	 GROUP BY dmpa.DatabaseID
)

INSERT INTO DBAnalysis
SELECT
		[Database] 
		,[CPUTimeAsMS] 
		,CAST([CPUTimeAsMS] * 1.0 / SUM([CPUTimeAsMS]) OVER() * 100.0 AS DECIMAL(5, 2)) AS CPUTimePercentage
		,P.NumberOfConnections
		,getdate()
	FROM CPU_Per_Db 
	LEFT JOIN (
		SELECT 
		dbid, 
		COUNT(dbid) as NumberOfConnections
	FROM
		sys.sysprocesses
	WHERE 
		dbid > 0
	GROUP BY 
		dbid
	) P ON P.dbid = DatabaseID
ORDER BY [CPUTimeAsMS] DESC;
