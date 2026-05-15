# Designing Microsoft SQL Server (MSSQL) Databases

> **Research Date:** 2026-04-28  
> **Query Type:** Technical Deep-dive  
> **Scope:** Comprehensive MSSQL database design — schema, indexing, partitioning, storage, security, and performance

---

## Executive Summary

Microsoft SQL Server (MSSQL) is a full-featured relational database engine with a rich set of design primitives spanning schema organization, multiple index types, table partitioning, filegroup-based storage tiering, row/page-level data compression, a multi-layered security model (authentication → authorization → encryption → auditing), and an extensive toolbox for performance monitoring. Effective MSSQL design requires matching each feature to the workload: OLTP workloads favor narrow rowstore indexes and memory-optimized tables, while OLAP/DW workloads favor clustered columnstore indexes and partitioning. Overindexing is one of the most common design mistakes, as every additional index increases write overhead. A well-designed MSSQL database begins with proper normalization and schema separation, then layers indexes and partitioning only where query analysis and execution plans justify them.[^1]

---

## Architecture / System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SQL Server Instance                          │
│                                                                     │
│  ┌─────────────┐   ┌─────────────┐   ┌──────────────────────────┐  │
│  │   master    │   │    model    │   │          msdb            │  │
│  │  (system)   │   │ (template)  │   │   (agent / backup jobs)  │  │
│  └─────────────┘   └─────────────┘   └──────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    User Database                             │   │
│  │                                                              │   │
│  │   Schemas (dbo, Sales, HR, ...)                              │   │
│  │   ┌─────────┐  ┌─────────┐  ┌───────────┐  ┌───────────┐   │   │
│  │   │ Tables  │  │  Views  │  │   Procs   │  │ Functions │   │   │
│  │   └────┬────┘  └─────────┘  └───────────┘  └───────────┘   │   │
│  │        │                                                     │   │
│  │   ┌────▼──────────────────────────────────┐                 │   │
│  │   │           Index Layer                 │                 │   │
│  │   │  Clustered / Nonclustered / Columnstore│                 │   │
│  │   │  Filtered / Unique / Included Columns │                 │   │
│  │   └───────────────────────────────────────┘                 │   │
│  │                                                              │   │
│  │   Storage: Filegroups → Files (.mdf / .ndf / .ldf)          │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│   Security: Authentication → Authorization → Encryption → Audit     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 1. Schema Design

### Normalization

Database design typically starts with normalization to eliminate redundancy:

| Normal Form | Rule |
|-------------|------|
| 1NF | Atomic values, no repeating groups |
| 2NF | Remove partial dependencies (non-key columns depend on full PK) |
| 3NF | Remove transitive dependencies (non-key columns depend only on PK) |
| BCNF | Every determinant is a candidate key |

For OLTP workloads, target 3NF. For OLAP/reporting, controlled denormalization (star/snowflake schemas) is often preferred for query performance.

### Schemas as Namespaces

MSSQL supports user-defined schemas as named containers for objects, enabling security grouping and namespace separation.[^2]

```sql
-- Create logical domain schemas
CREATE SCHEMA Sales;
CREATE SCHEMA HR;
CREATE SCHEMA Finance;

-- Assign a table to a schema
CREATE TABLE Sales.Orders (
    OrderID      INT          NOT NULL IDENTITY(1,1),
    CustomerID   INT          NOT NULL,
    OrderDate    DATETIME2    NOT NULL DEFAULT SYSDATETIME(),
    TotalAmount  DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Sales_Orders PRIMARY KEY (OrderID)
);
```

The four-part naming convention for objects is `Server.Database.Schema.Object`.[^2]  
Key rules:
- The `dbo` schema is the default for all users.
- `sys` and `INFORMATION_SCHEMA` are reserved.
- Schema permissions are inherited by all objects within the schema — set permissions at the schema level rather than per-object.

### Data Types Best Practices

| Scenario | Recommended Type | Notes |
|----------|-----------------|-------|
| Surrogate primary key | `INT IDENTITY` or `BIGINT IDENTITY` | Avoid `UNIQUEIDENTIFIER` as clustered PK (fragmentation) |
| GUID/UUID key | `UNIQUEIDENTIFIER` with `NEWSEQUENTIALID()` | Reduces page splits vs `NEWID()` |
| Date + time | `DATETIME2(n)` | Higher precision and range than legacy `DATETIME` |
| Money | `DECIMAL(p,s)` | Never use `FLOAT`/`REAL` for money values |
| Unicode text | `NVARCHAR(n)` | Use `VARCHAR` for ASCII-only data to save space |
| Large objects | `VARBINARY(MAX)`, `VARCHAR(MAX)` | Store in FILESTREAM for files > 1 MB |
| Boolean flags | `BIT` | |
| Audit timestamps | `ROWVERSION` / `TIMESTAMP` | Optimistic concurrency |

### Table Types

SQL Server provides several specialized table types[^3]:

| Type | Use Case |
|------|----------|
| Standard heap | Intermediate staging |
| Clustered index table | Default — sorted physical storage |
| Memory-optimized table | Extreme OLTP throughput (lock/latch-free) |
| Partitioned table | Large tables needing manageability |
| Temporary (`#temp`, `##global`) | Session- or batch-scoped scratch space |
| Wide table (sparse columns) | Up to 30,000 columns with `NULL`-optimized storage |

---

## 2. Index Design

### Index Types Reference

| Index Type | Storage | Best For |
|-----------|---------|---------|
| Clustered (B+ tree) | Rowstore | Physical row ordering; one per table |
| Nonclustered (B+ tree) | Rowstore | Point lookups, selective range scans |
| Unique | Clustered or NC | Enforce uniqueness constraint |
| Filtered | Nonclustered subset | Sparse/nullable columns, well-defined subsets |
| Included columns | Nonclustered | Covering index without widening key |
| Clustered Columnstore | Columnar | DW/OLAP full-table scans (up to 10× faster) |
| Nonclustered Columnstore | Columnar | Real-time analytics on OLTP table |
| Hash (memory-optimized) | In-memory | Equality lookups on memory-optimized tables |
| XML index | Shredded XML | XML column queries |
| Spatial | R-tree | Geometric/geographic data |
| Full-text | Token-based | Natural language text search |

Columnstore indexes achieve up to **10× query performance** gains and **7× data compression** over uncompressed row-oriented storage.[^4]

### Clustered Index Design

```sql
-- Good: narrow integer key, monotonically increasing
CREATE TABLE Sales.OrderLines (
    LineID      INT          NOT NULL IDENTITY(1,1),
    OrderID     INT          NOT NULL,
    ProductID   INT          NOT NULL,
    Quantity    SMALLINT     NOT NULL,
    UnitPrice   DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_OrderLines PRIMARY KEY CLUSTERED (LineID)
);
```

Rules:
- Every table should have a clustered index (avoid heaps except for staging).
- Keep the clustered key **narrow** and **monotonically increasing** to avoid page splits.
- Never use `NEWID()` (random GUIDs) as a clustered key — use `NEWSEQUENTIALID()` instead.

### Nonclustered Index Design

```sql
-- Covering index: key columns + included columns
CREATE NONCLUSTERED INDEX IX_OrderLines_OrderID
    ON Sales.OrderLines (OrderID)
    INCLUDE (ProductID, Quantity, UnitPrice);

-- Filtered index: only index rows where Quantity > 100
CREATE NONCLUSTERED INDEX IX_OrderLines_LargeQty
    ON Sales.OrderLines (Quantity)
    WHERE Quantity > 100;
```

Guidelines[^1]:
- Index columns used in `WHERE`, `JOIN`, and `ORDER BY` clauses.
- Use **included columns** to create covering indexes without widening the key.
- Use **filtered indexes** for sparse values or well-defined subsets (e.g., `IsActive = 1`).
- Each additional index on a table increases `INSERT`/`UPDATE`/`DELETE` overhead — keep indexes narrow.
- Avoid more than ~5–8 nonclustered indexes on heavily written tables.
- Regularly review and **drop unused indexes** (query `sys.dm_db_index_usage_stats`).

### Columnstore Index Design

```sql
-- Clustered columnstore for a fact table
CREATE TABLE dbo.FactSales (
    DateKey      INT NOT NULL,
    CustomerKey  INT NOT NULL,
    ProductKey   INT NOT NULL,
    SalesAmount  DECIMAL(10,2) NOT NULL,
    Quantity     INT NOT NULL
);
CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales ON dbo.FactSales;

-- Nonclustered columnstore on an OLTP table (real-time analytics)
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI_Orders_Analytics
    ON Sales.Orders (OrderDate, TotalAmount, CustomerID);
```

### Index Maintenance

```sql
-- Check index fragmentation
SELECT 
    OBJECT_NAME(ips.object_id)   AS TableName,
    i.name                        AS IndexName,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') AS ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.avg_fragmentation_in_percent > 10
ORDER BY ips.avg_fragmentation_in_percent DESC;

-- Rebuild (offline/online) vs reorganize
-- < 30% fragmentation: REORGANIZE (online, minimal blocking)
ALTER INDEX IX_OrderLines_OrderID ON Sales.OrderLines REORGANIZE;
-- >= 30%: REBUILD
ALTER INDEX IX_OrderLines_OrderID ON Sales.OrderLines REBUILD WITH (ONLINE = ON);
```

---

## 3. Partitioning

Table and index partitioning divides data horizontally into units that can reside on different filegroups.[^5]

### Benefits

- Faster data transfers (OLTP → OLAP via partition switching — seconds vs hours).
- Targeted maintenance: rebuild only one partition of an index.
- Partition elimination: the optimizer scans only relevant partitions for range queries.
- Reduced lock contention via partition-level locking (`LOCK_ESCALATION = AUTO`).
- Up to **15,000 partitions** per table/index.[^5]

### Partition Function + Scheme + Table

```sql
-- Step 1: Partition function (split by year/month)
CREATE PARTITION FUNCTION PF_OrderDate (DATETIME2)
AS RANGE RIGHT
FOR VALUES (
    '2023-01-01', '2023-04-01', '2023-07-01', '2023-10-01',
    '2024-01-01', '2024-04-01', '2024-07-01', '2024-10-01',
    '2025-01-01'
);

-- Step 2: Partition scheme (map to filegroups)
CREATE PARTITION SCHEME PS_OrderDate
AS PARTITION PF_OrderDate
ALL TO ([PRIMARY]);           -- or spread across filegroups for tiered storage

-- Step 3: Partitioned table
CREATE TABLE Sales.Orders (
    OrderID    INT           NOT NULL IDENTITY,
    OrderDate  DATETIME2     NOT NULL,
    CustomerID INT           NOT NULL,
    Amount     DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (OrderID, OrderDate)
) ON PS_OrderDate(OrderDate);  -- partition column

-- Step 4: Fast data archiving via partition switching
ALTER TABLE Sales.Orders
    SWITCH PARTITION 1 TO Sales.OrdersArchive PARTITION 1;
```

> **Note:** The partition column must be part of the clustered index key (or heap has no restriction).

---

## 4. Storage: Files and Filegroups

Every SQL Server database consists of[^6]:

| File Type | Extension | Purpose |
|-----------|-----------|---------|
| Primary data | `.mdf` | Startup info + default object storage |
| Secondary data | `.ndf` | Additional data, spread across disks |
| Transaction log | `.ldf` | WAL for crash recovery and replication |

### Filegroup Design

```sql
CREATE DATABASE SalesDB
ON PRIMARY
    (NAME = SalesDB_Primary, FILENAME = 'D:\Data\SalesDB.mdf', SIZE = 512MB, FILEGROWTH = 256MB),
FILEGROUP FG_Current
    (NAME = SalesDB_Current, FILENAME = 'D:\Data\SalesDB_Current.ndf', SIZE = 2GB, FILEGROWTH = 512MB),
FILEGROUP FG_Archive
    (NAME = SalesDB_Archive, FILENAME = 'E:\Archive\SalesDB_Archive.ndf', SIZE = 10GB, FILEGROWTH = 1GB)
LOG ON
    (NAME = SalesDB_Log, FILENAME = 'L:\Logs\SalesDB.ldf', SIZE = 512MB, FILEGROWTH = 256MB);
```

Best practices[^6]:
- **Separate data and log files** onto different physical disks (avoid contention).
- Place frequently accessed data on fast storage (SSD/NVMe) and archive data on cheaper storage via filegroup mapping.
- Pre-size files to avoid frequent autogrowth events (autogrowth is a blocking operation).
- Set `FILEGROWTH` as a fixed MB value rather than a percentage.
- Enable **instant file initialization** on the OS for faster data file growth.
- Use `NTFS` (not FAT) for all SQL Server volumes; avoid NTFS compression on data/log files.

### Memory-Optimized Filegroup

Required for In-Memory OLTP tables:

```sql
ALTER DATABASE SalesDB
ADD FILEGROUP FG_InMemory CONTAINS MEMORY_OPTIMIZED_DATA;
ALTER DATABASE SalesDB
ADD FILE (NAME = 'InMemory', FILENAME = 'D:\InMemory\SalesDB_InMemory') TO FILEGROUP FG_InMemory;
```

---

## 5. Data Compression

MSSQL supports two primary compression strategies for rowstore objects[^7]:

| Level | Algorithm | Trade-off |
|-------|-----------|-----------|
| `ROW` | Removes storage overhead of fixed-length types with small values | Low CPU overhead |
| `PAGE` | Dictionary-based on 8 KB pages (superset of ROW) | Higher CPU, best compression |
| `COLUMNSTORE` | Always applied to columnstore indexes | Not user-configurable |
| `COLUMNSTORE_ARCHIVAL` | XPRESS algorithm on top of columnstore | Maximum compression, higher CPU |

```sql
-- Apply page compression to a table
ALTER TABLE Sales.Orders REBUILD WITH (DATA_COMPRESSION = PAGE);

-- Apply row compression to a specific index
ALTER INDEX IX_OrderLines_OrderID ON Sales.OrderLines
REBUILD WITH (DATA_COMPRESSION = ROW);

-- Estimate compression savings before applying
EXEC sp_estimate_data_compression_savings
    @schema_name = 'Sales',
    @object_name = 'Orders',
    @index_id    = NULL,
    @partition_number = NULL,
    @data_compression = 'PAGE';
```

Key constraints[^7]:
- Compression cannot be applied to **system tables**.
- Off-row data (XML > 8 KB, large LOBs) is **not** compressed.
- Nonclustered indexes do **not** inherit the table's compression setting — configure separately.
- Page compression on a heap requires an explicit `ALTER TABLE ... REBUILD`.

---

## 6. Security Design

MSSQL security is layered across four domains[^8]:

### 6.1 Authentication (Who are you?)

```sql
-- Windows Authentication login (preferred)
CREATE LOGIN [DOMAIN\AppServiceAccount] FROM WINDOWS;

-- SQL Authentication (use only when Windows auth is unavailable)
CREATE LOGIN AppUser WITH PASSWORD = 'S3cur3P@ssw0rd!',
    CHECK_EXPIRATION = ON,
    CHECK_POLICY = ON;

-- Database user mapped to login
USE SalesDB;
CREATE USER AppUser FOR LOGIN AppUser;
```

### 6.2 Authorization (What can you do?)

```sql
-- Grant schema-level permissions (best practice)
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Sales TO AppUser;
GRANT EXECUTE ON SCHEMA::dbo TO AppUser;

-- Role-based access
CREATE ROLE SalesReadOnly;
GRANT SELECT ON SCHEMA::Sales TO SalesReadOnly;
ALTER ROLE SalesReadOnly ADD MEMBER ReportUser;
```

### 6.3 Row-Level Security

```sql
-- Predicate function: filter orders by the current user
CREATE FUNCTION Security.fn_OrderFilter(@CustomerID INT)
RETURNS TABLE WITH SCHEMABINDING
AS RETURN SELECT 1 AS Result
WHERE @CustomerID = CAST(SESSION_CONTEXT(N'CustomerID') AS INT)
   OR IS_MEMBER('db_owner') = 1;

-- Bind to the table
CREATE SECURITY POLICY Sales.OrderRowPolicy
ADD FILTER PREDICATE Security.fn_OrderFilter(CustomerID)
ON Sales.Orders
WITH (STATE = ON);
```

### 6.4 Encryption

| Mechanism | Scope | Notes |
|-----------|-------|-------|
| TDE (Transparent Data Encryption) | File level | Encrypts `.mdf`/`.ndf`/`.ldf` at rest |
| Always Encrypted | Column level | Encryption at client; server never sees plaintext |
| Column Encryption | Column level | Server-side; transparent to queries |
| TLS/SSL | In transit | Enforce with `FORCE ENCRYPTION = ON` |
| Dynamic Data Masking | Display layer | Masks sensitive data for non-privileged users |

```sql
-- Dynamic data masking
ALTER TABLE HR.Employees
ALTER COLUMN SSN NVARCHAR(11) MASKED WITH (FUNCTION = 'partial(0,"XXX-XX-",4)');
```

---

## 7. Performance Monitoring and Tuning

### Key DMVs for Ongoing Tuning

```sql
-- Missing index recommendations
SELECT
    mig.equality_columns,
    mig.inequality_columns,
    mig.included_columns,
    mid.statement               AS TableName,
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS ImprovementMeasure
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
ORDER BY ImprovementMeasure DESC;

-- Most expensive queries by CPU
SELECT TOP 20
    qs.total_worker_time / qs.execution_count AS AvgCPU,
    qs.execution_count,
    SUBSTRING(qt.text, qs.statement_start_offset/2+1,
        (CASE WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
              ELSE qs.statement_end_offset END - qs.statement_start_offset)/2+1) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY AvgCPU DESC;

-- Index usage statistics
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name                    AS IndexName,
    us.user_seeks,
    us.user_scans,
    us.user_lookups,
    us.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats us
    ON i.object_id = us.object_id AND i.index_id = us.index_id AND us.database_id = DB_ID()
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY us.user_seeks + us.user_scans + us.user_lookups;
```

### Monitoring Toolbox

| Tool | Purpose |
|------|---------|
| **Query Store** | Automatic query plan history, plan forcing, regression detection |
| **Extended Events** | Lightweight trace capture; replacement for SQL Profiler |
| **Activity Monitor** | Live blocked processes, waits, expensive queries |
| **Performance Dashboard** | SSMS dashboard for bottleneck identification |
| **Database Engine Tuning Advisor** | Index and partitioning recommendations from a workload |
| **DBCC** commands | Physical and logical consistency checks (`DBCC CHECKDB`) |
| `sys.dm_exec_*` DMVs | Runtime execution stats |
| `sys.dm_os_wait_stats` | Wait-category analysis |

### Query Store Setup (Recommended for All Production DBs)

```sql
ALTER DATABASE SalesDB SET QUERY_STORE = ON;
ALTER DATABASE SalesDB SET QUERY_STORE
(
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 90),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 1000,
    QUERY_CAPTURE_MODE = AUTO,
    SIZE_BASED_CLEANUP_MODE = AUTO
);
```

---

## 8. High Availability Design Considerations

| Feature | RPO | RTO | Notes |
|---------|-----|-----|-------|
| Always On AG | ~0 (sync) | Seconds | Preferred for HA; supports readable secondaries |
| Database Mirroring | ~0 (sync) | Seconds | Deprecated; use AG instead |
| Log Shipping | Minutes | Minutes | Simple DR; read-only standby |
| Failover Cluster Instance (FCI) | ~0 | ~1 min | Shared storage; protects instance, not DB |
| Geo-replication (Azure SQL) | Seconds | Minutes | Cloud-native DR |

Always On Availability Groups design rules:
- Use **synchronous commit** for HA (same data center), **asynchronous** for DR (remote site).
- Readable secondary replicas offload reporting workloads.
- Design applications to use the AG Listener DNS name, not individual server names.

---

## 9. Design Patterns by Workload

### OLTP Pattern

```
- 3NF normalized schema
- Clustered index on surrogate INT/BIGINT identity PK
- Selective nonclustered indexes on FK + query predicates
- Memory-optimized tables for hottest entities
- Row or no compression (low CPU overhead)
- Short transactions; minimize lock duration
- Connection pooling at application layer
```

### OLAP / Data Warehouse Pattern

```
- Star or snowflake schema (dimension + fact tables)
- Clustered columnstore index on fact tables
- Partitioned fact tables by date (year/quarter/month)
- Page compression on dimension tables
- Batch loading via BULK INSERT or BCP
- Dedicated reporting filegroup on slower storage
- Query Store for plan stability
```

### Mixed (HTAP) Pattern

```
- Nonclustered columnstore on OLTP tables (SQL Server 2016+)
- Partition switching to move aged data to warehouse
- Always On readable secondary for reporting
- Snapshot isolation to avoid reader/writer blocking
```

---

## Key Concepts Summary

| Concept | Quick Reference |
|---------|----------------|
| Schema separation | Group objects by domain; apply security at schema level |
| Clustered index | One per table; keep key narrow and monotonically increasing |
| Nonclustered | Index FK, WHERE/JOIN columns; add included columns for coverage |
| Columnstore | OLAP/DW fact tables; up to 10× query speedup |
| Filtered index | Sparse/nullable/well-defined subset columns |
| Partitioning | Large tables; enables partition switching and targeted maintenance |
| Page compression | Best ratio for read-heavy workloads; adds CPU cost |
| TDE | Transparent file-level encryption at rest |
| Always Encrypted | Column-level; server never decrypts — strongest column protection |
| Row-Level Security | Filter rows via predicate functions; transparent to applications |
| Query Store | Always enable on production; captures plan history and regressions |

---

## Official Documentation References

| Topic | URL |
|-------|-----|
| Index Design Guide | https://learn.microsoft.com/sql/relational-databases/sql-server-index-design-guide |
| Table Types | https://learn.microsoft.com/sql/relational-databases/tables/tables |
| Partitioned Tables & Indexes | https://learn.microsoft.com/sql/relational-databases/partitions/partitioned-tables-and-indexes |
| Data Compression | https://learn.microsoft.com/sql/relational-databases/data-compression/data-compression |
| Database Files & Filegroups | https://learn.microsoft.com/sql/relational-databases/databases/database-files-and-filegroups |
| Security Center | https://learn.microsoft.com/sql/relational-databases/security/security-center-for-sql-server-database-engine-and-azure-sql-database |
| Performance Monitoring Tools | https://learn.microsoft.com/sql/relational-databases/performance/performance-monitoring-and-tuning-tools |
| Query Store Best Practices | https://learn.microsoft.com/sql/relational-databases/performance/best-practice-with-the-query-store |

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|-----------|-------|
| Index types and B+ tree architecture | **High** | Directly sourced from official MSSQL docs |
| Schema/security design | **High** | Sourced from official MSSQL security docs |
| Partitioning syntax | **High** | Sourced from official partitioning docs |
| Data compression details | **High** | Sourced from official compression docs |
| HA/DR comparison table | **Medium-High** | Based on well-known SQL Server HA features; RPO/RTO are approximate |
| HTAP pattern | **Medium** | General industry pattern; specific numbers depend on workload |
| No codebase-specific context | N/A | The `vasekNaus/AI` repository contains only a README with no MSSQL code |

---

## Footnotes

[^1]: [SQL Server and Azure SQL Index Architecture and Design Guide](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver16) — Index design tasks, database and query considerations, over-indexing warnings.

[^2]: [Ownership and User-Schema Separation](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/ownership-and-user-schema-separation?view=sql-server-ver16) — Four-part naming syntax, schema ownership, built-in schemas, `dbo` schema default behavior.

[^3]: [Tables (SQL Server)](https://learn.microsoft.com/en-us/sql/relational-databases/tables/tables?view=sql-server-ver16) — Table types: standard, partitioned, temporary, wide tables, sparse columns, system tables.

[^4]: [Indexes Overview (SQL Server)](https://learn.microsoft.com/en-us/sql/relational-databases/indexes/indexes?view=sql-server-ver16) — All index types including columnstore (10× query performance, 7× compression vs uncompressed).

[^5]: [Partitioned Tables and Indexes](https://learn.microsoft.com/en-us/sql/relational-databases/partitions/partitioned-tables-and-indexes?view=sql-server-ver16) — Partition functions, schemes, filegroups, partition elimination, lock escalation; 15,000 partition limit.

[^6]: [Database Files and Filegroups](https://learn.microsoft.com/en-us/sql/relational-databases/databases/database-files-and-filegroups?view=sql-server-ver16) — `.mdf`/`.ndf`/`.ldf` file types, filegroup types, page numbering, autogrowth, memory-optimized filegroup.

[^7]: [Data Compression](https://learn.microsoft.com/en-us/sql/relational-databases/data-compression/data-compression?view=sql-server-ver16) — ROW/PAGE/COLUMNSTORE/ARCHIVAL compression; constraints (no system tables, no off-row data); nonclustered indexes require explicit compression setting.

[^8]: [Security Center for SQL Server Database Engine](https://learn.microsoft.com/en-us/sql/relational-databases/security/security-center-for-sql-server-database-engine-and-azure-sql-database?view=sql-server-ver16) — Authentication (Windows/SQL/Entra ID), authorization (RBAC, RLS), encryption (TDE, Always Encrypted, DDM), auditing.
