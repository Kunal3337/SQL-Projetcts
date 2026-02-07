# SQL-Projects

This projects demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio projects highlights 
industry best practices in data engineering and analytics

# Data Architecture
The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers:

**Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.<br>
<br>
**Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.<br>
<br>
**Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

# Projects Overview

**Data Architecture:** Designing a Modern Data Warehouse Using Medallion Architecture Bronze, Silver, and Gold layers.<br>
<br>
**ETL Pipelines:** Extracting, transforming, and loading data from source systems into the warehouse.<br>
<br>
**Data Modeling:** Developing fact and dimension tables optimized for analytical queries.<br>
<br>
**Analytics & Reporting:** Creating SQL-based reports and dashboards for actionable insights.

### Building the datawarehouse

### Objective
Develop a modern data warehouse using SQL server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications

**Data Sources**: Import data from two source systems(ERP and CRM) provided as CSV files.<br>
**Data Quality**: Cleanse and resolve data quality issues prior to analysis.<br>
**Integration**: Combine both sources into a single, user friendly data model designed for analytical queries.<br>
**Scope**: Focus on the latest dataset only; historization of data is not required.<br>
**Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics team.

### BI: Analytics & Reporting (Data Analytics)

### Objective 
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behaviour**
- **Product Performance**
- **Sales Trends**

  These insights empower stakeholders with key business metrics, enabling strategic decision making.


### BI: Analytics & Reporting (Data Analysis)

**Objective**
Develop SQL-based analytics to deliver detailed insights into:

Customer Behavior
Product Performance
Sales Trends
These insights empower stakeholders with key business metrics, enabling strategic decision-making.
