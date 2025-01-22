# SQL_QUERIES-ON-SNOWFLAKE
SQL scripts for analyzing cricket match data in Snowflake, including JSON extraction, data transformations, and advanced queries for insights. Features include table creation, constraint management, and analytical functions tailored for structured and semi-structured data processing.

# Cricket Data Analysis and Snowflake SQL

This document provides an overview of two related SQL scripts designed for working with cricket match data in a Snowflake database. 
It includes details about JSON SQL queries and Snowflake SQL operations for data extraction, transformation, and analysis.

---

## JSON SQL Query Script for Cricket Data

This section contains SQL queries used for extracting, transforming, and analyzing cricket match data. It focuses on handling complex JSON and variant data types to retrieve meaningful insights.

### Features

1. **Data Extraction:**
   - Extracts JSON elements from the `meta` and `info` columns of the `cricket.raw.match_raw_tbl` table.
   - Processes nested and flattened JSON objects for detailed information.

2. **Transformations:**
   - Derives structured data such as match type, event details, venue, teams, players, and outcomes.
   - Converts JSON attributes to specific data types (`TEXT`, `DATE`, `NUMBER`).

3. **Analysis:**
   - Analyzes match outcomes, including winners, tied matches, and match stages.
   - Calculates derived metrics like event year, month, and day.

4. **Table Creation and Constraints:**
   - Creates a `player_clean_tbl` table for storing player information.
   - Adds primary and foreign key constraints for data integrity.

### Instructions

1. Use the provided queries sequentially to explore and manipulate cricket match data.
2. Modify schema and table names as necessary to suit your Snowflake database structure.
3. Ensure the required roles and permissions (`SYSADMIN`) are granted for table alterations and constraints.

### Key Notes

- Queries include handling of null values and data constraints.
- Contains examples of flattening JSON arrays to extract nested data (e.g., player names and teams).
- Provides commentary to guide query purpose and usage.

### Compatibility

- Designed for Snowflake databases.
- Requires a warehouse and schema to be active before execution.

### Example Usage

```sql
SELECT info:venue::text AS venue
FROM cricket.raw.match_raw_tbl
WHERE info:match_type_number::number = 3161;
```

---

## Snowflake SQL Script for Data Management and Analysis

This section (the second file) provides SQL queries and operations designed for managing and analyzing data in a Snowflake database. It includes schema setup, data extraction, and reporting functions.

### Features

1. **Data Setup:**
   - Configures roles, warehouses, and schemas for query execution.

2. **Data Management:**
   - Extracts and processes JSON/variant data types.
   - Demonstrates flattening nested data for relational storage.

3. **Analysis:**
   - Provides analytical queries for understanding key metrics and relationships.
   - Supports insights into match details, venues, teams, and players.

4. **Table Creation and Constraints:**
   - Includes table creation and primary/foreign key constraints.
   - Ensures normalized data structures for further processing.

### Instructions

1. Execute the script in the Snowflake SQL editor.
2. Update table and schema references to match your environment.
3. Use the queries incrementally for better understanding and debugging.

### Key Notes

- Make sure the required warehouse and roles are active.
- Handle potential null values using provided examples.

### Compatibility

- Exclusively for Snowflake databases.
- Requires appropriate permissions for schema modifications and data extraction.

### Example Usage

```sql
SELECT COUNT(*) AS tie_count 
FROM (SELECT DISTINCT info:match_type_number::string AS match_type_number, info:teams, info:dates
      FROM cricket.raw.match_raw_tbl
      WHERE info:outcome.result = 'tie');
```

---
