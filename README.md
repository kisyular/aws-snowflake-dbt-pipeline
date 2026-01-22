# AWS - Snowflake - DBT Integration Guide

A comprehensive guide for setting up an end-to-end data pipeline using AWS S3, Snowflake, and dbt (Data Build Tool) for Airbnb analytics. This project demonstrates modern data engineering practices including medallion architecture (Bronze, Silver, Gold layers), incremental data loading, custom macros, and comprehensive testing.

---

## Table of Contents

- [AWS - Snowflake - DBT Integration Guide](#aws---snowflake---dbt-integration-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Project Architecture](#project-architecture)
    - [Technology Stack](#technology-stack)
    - [Data Flow Diagram](#data-flow-diagram)
  - [Prerequisites](#prerequisites)
    - [Required Software](#required-software)
      - [Verify Installations](#verify-installations)
    - [Required Accounts](#required-accounts)
    - [Data Files](#data-files)
      - [bookings.csv Structure](#bookingscsv-structure)
      - [hosts.csv Structure](#hostscsv-structure)
      - [listings.csv Structure](#listingscsv-structure)
  - [AWS Setup](#aws-setup)
    - [1. Create an AWS Account](#1-create-an-aws-account)
    - [2. Create S3 Bucket](#2-create-s3-bucket)
    - [3. Create Folder Structure](#3-create-folder-structure)
    - [4. Upload CSV Files](#4-upload-csv-files)
    - [5. Create IAM User for Snowflake](#5-create-iam-user-for-snowflake)
      - [Create IAM User](#create-iam-user)
      - [Set Permissions](#set-permissions)
      - [Generate Access Keys](#generate-access-keys)
  - [Snowflake Setup](#snowflake-setup)
    - [1. Create Snowflake Account](#1-create-snowflake-account)
    - [2. Access Snowflake Console](#2-access-snowflake-console)
    - [3. Create Database and Schema](#3-create-database-and-schema)
    - [4. Create Tables](#4-create-tables)
    - [5. Configure File Format and Stage](#5-configure-file-format-and-stage)
    - [6. Load Data into Tables](#6-load-data-into-tables)
    - [7. Verify Data Load](#7-verify-data-load)
  - [dbt Configuration](#dbt-configuration)
    - [1. Set Up Python Virtual Environment](#1-set-up-python-virtual-environment)
    - [2. Install dbt Dependencies](#2-install-dbt-dependencies)
    - [3. Initialize dbt Project](#3-initialize-dbt-project)
    - [4. Verify dbt Connection](#4-verify-dbt-connection)
    - [5. Run Initial dbt Models](#5-run-initial-dbt-models)
  - [Project Structure](#project-structure)
  - [Next Steps](#next-steps)
    - [1. Create Advanced dbt Models](#1-create-advanced-dbt-models)
      - [Gold Layer Analytics Models](#gold-layer-analytics-models)
    - [2. Add Comprehensive Tests](#2-add-comprehensive-tests)
    - [3. Set Up dbt Documentation](#3-set-up-dbt-documentation)
    - [4. Schedule dbt Runs](#4-schedule-dbt-runs)
      - [Option A: Using cron (Linux/macOS)](#option-a-using-cron-linuxmacos)
      - [Option B: Using Apache Airflow](#option-b-using-apache-airflow)
    - [5. Implement CI/CD](#5-implement-cicd)
      - [GitHub Actions Workflow](#github-actions-workflow)
  - [Project Structure](#project-structure-1)
  - [Medallion Architecture](#medallion-architecture)
    - [Bronze Layer (Raw)](#bronze-layer-raw)
    - [Silver Layer (Cleaned)](#silver-layer-cleaned)
    - [Gold Layer (Business)](#gold-layer-business)
  - [dbt Models](#dbt-models)
    - [Bronze Layer Models](#bronze-layer-models)
      - [bronze\_bookings.sql](#bronze_bookingssql)
      - [bronze\_hosts.sql](#bronze_hostssql)
      - [bronze\_listings.sql](#bronze_listingssql)
    - [Silver Layer Models](#silver-layer-models)
      - [silver\_bookings.sql](#silver_bookingssql)
      - [silver\_hosts.sql](#silver_hostssql)
      - [silver\_listings.sql](#silver_listingssql)
    - [Demo Models](#demo-models)
      - [snowflake\_dbt\_bookings.sql](#snowflake_dbt_bookingssql)
      - [snowflake\_dbt\_listing\_id.sql](#snowflake_dbt_listing_idsql)
  - [Custom Macros](#custom-macros)
    - [multiply Macro](#multiply-macro)
    - [upper\_case Macro](#upper_case-macro)
    - [trimmer Macro](#trimmer-macro)
    - [tag Macro](#tag-macro)
    - [generate\_schema\_name Macro](#generate_schema_name-macro)
  - [Jinja Control Structures](#jinja-control-structures)
    - [If-Else Statements](#if-else-statements)
    - [For Loops](#for-loops)
  - [Testing](#testing)
    - [Schema Tests](#schema-tests)
    - [Custom Tests](#custom-tests)
  - [Documentation](#documentation)
    - [Doc Blocks](#doc-blocks)
    - [Schema Documentation](#schema-documentation)
    - [Generating Documentation](#generating-documentation)
  - [dbt Commands Reference](#dbt-commands-reference)
    - [Core Commands](#core-commands)
    - [Selection Commands](#selection-commands)
    - [Full vs Incremental Runs](#full-vs-incremental-runs)
    - [Documentation Commands](#documentation-commands)
    - [Other Useful Commands](#other-useful-commands)
  - [Best Practices](#best-practices)
    - [Model Organization](#model-organization)
    - [SQL Style Guide](#sql-style-guide)
    - [Performance Optimization](#performance-optimization)
    - [Testing Strategy](#testing-strategy)
    - [Documentation](#documentation-1)
  - [Troubleshooting](#troubleshooting)
    - [Connection Issues](#connection-issues)
      - [dbt debug Fails](#dbt-debug-fails)
      - [Profile Not Found](#profile-not-found)
    - [S3 Access Errors](#s3-access-errors)
      - [LIST @snowflakestage Fails](#list-snowflakestage-fails)
      - [Permission Denied Errors](#permission-denied-errors)
    - [Data Load Errors](#data-load-errors)
      - [COPY INTO Fails](#copy-into-fails)
    - [dbt Run Errors](#dbt-run-errors)
      - [Model Compilation Errors](#model-compilation-errors)
      - [Incremental Model Issues](#incremental-model-issues)
  - [Advanced Topics](#advanced-topics)
    - [Snapshots (Slowly Changing Dimensions)](#snapshots-slowly-changing-dimensions)
    - [Seeds (Static Data)](#seeds-static-data)
    - [Hooks (Pre/Post Operations)](#hooks-prepost-operations)
    - [Packages](#packages)
    - [Environment Variables](#environment-variables)
    - [Multiple Environments](#multiple-environments)
    - [Custom Generic Tests](#custom-generic-tests)
    - [Source Freshness](#source-freshness)
  - [Frequently Asked Questions](#frequently-asked-questions)
    - [General Questions](#general-questions)
    - [Model Questions](#model-questions)
    - [Testing Questions](#testing-questions)
    - [Performance Questions](#performance-questions)
  - [Resources](#resources)
    - [Official Documentation](#official-documentation)
    - [Learning Resources](#learning-resources)
    - [Community](#community)
    - [Books and Blogs](#books-and-blogs)
    - [Tools and Utilities](#tools-and-utilities)
  - [Contributing](#contributing)
    - [Reporting Issues](#reporting-issues)
    - [Suggesting Improvements](#suggesting-improvements)
    - [Pull Requests](#pull-requests)
    - [Code Style](#code-style)
  - [License](#license)
  - [Changelog](#changelog)
    - [Version 1.0.0 (Initial Release)](#version-100-initial-release)
  - [Acknowledgments](#acknowledgments)

---

## Overview

### Project Architecture

This project implements a modern data engineering pipeline that follows the **ELT (Extract, Load, Transform)** paradigm. Raw data is extracted from CSV files, loaded into AWS S3, ingested into Snowflake's staging area, and then transformed through dbt using a medallion architecture approach.

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   CSV Files     │────▶│    AWS S3       │────▶│   Snowflake     │
│  (Data Source)  │     │  (Data Lake)    │     │ (Data Warehouse)│
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                                                         ▼
                        ┌─────────────────────────────────────────────┐
                        │              dbt Transformations            │
                        │  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
                        │  │ Bronze  │─▶│ Silver  │─▶│  Gold   │     │
                        │  │ (Raw)   │  │(Cleaned)│  │(Business)│    │
                        │  └─────────┘  └─────────┘  └─────────┘     │
                        └─────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Cloud Storage | AWS S3 | Raw data storage and staging |
| Data Warehouse | Snowflake | Scalable cloud data warehouse |
| Transformation | dbt Core | SQL-based data transformation |
| Language | Python 3.12 | Runtime environment for dbt |
| Version Control | Git | Code versioning and collaboration |
| Template Engine | Jinja2 | Dynamic SQL generation |

### Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           DATA PIPELINE FLOW                              │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. DATA EXTRACTION                                                      │
│     ├── bookings.csv    → Booking transactions                           │
│     ├── hosts.csv       → Host information                               │
│     └── listings.csv    → Property listings                              │
│                                                                          │
│  2. DATA STAGING (AWS S3)                                                │
│     └── s3://your-bucket/source/                                         │
│         ├── bookings.csv                                                 │
│         ├── hosts.csv                                                    │
│         └── listings.csv                                                 │
│                                                                          │
│  3. DATA INGESTION (Snowflake)                                           │
│     └── AIRBNB.STAGING                                                   │
│         ├── BOOKINGS table                                               │
│         ├── HOSTS table                                                  │
│         └── LISTINGS table                                               │
│                                                                          │
│  4. DATA TRANSFORMATION (dbt)                                            │
│     ├── Bronze Layer (AIRBNB.BRONZE)                                     │
│     │   ├── bronze_bookings (incremental)                                │
│     │   ├── bronze_hosts (incremental)                                   │
│     │   └── bronze_listings (incremental)                                │
│     │                                                                    │
│     ├── Silver Layer (AIRBNB.SILVER)                                     │
│     │   ├── silver_bookings (cleaned, enriched)                          │
│     │   ├── silver_hosts (cleaned, enriched)                             │
│     │   └── silver_listings (cleaned, enriched)                          │
│     │                                                                    │
│     └── Gold Layer (AIRBNB.GOLD) - Business-ready aggregates             │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Required Software

| Software | Version | Installation Guide |
|----------|---------|-------------------|
| Python | 3.12+ | [python.org](https://www.python.org/downloads/) |
| Git | Latest | [git-scm.com](https://git-scm.com/downloads) |
| pip | Latest | Included with Python |
| Virtual Environment | venv | Included with Python |

#### Verify Installations

```bash
# Check Python version
python3 --version
# Expected: Python 3.12.x

# Check pip version
pip --version
# Expected: pip 24.x.x

# Check Git version
git --version
# Expected: git version 2.x.x
```

### Required Accounts

| Service | Type | Sign Up Link |
|---------|------|--------------|
| AWS | Free Tier / Paid | [aws.amazon.com](https://aws.amazon.com/) |
| Snowflake | 30-day Free Trial | [signup.snowflake.com](https://signup.snowflake.com/) |

### Data Files

The project uses three CSV files representing Airbnb data:

#### bookings.csv Structure
```
booking_id,listing_id,booking_date,nights_booked,booking_amount,cleaning_fee,service_fee,booking_status,created_at
```

| Column | Data Type | Description |
|--------|-----------|-------------|
| booking_id | STRING | Unique identifier for each booking |
| listing_id | NUMBER | Foreign key to listings table |
| booking_date | TIMESTAMP | Date and time of booking |
| nights_booked | NUMBER | Number of nights in the booking |
| booking_amount | NUMBER | Base amount per night |
| cleaning_fee | NUMBER | One-time cleaning fee |
| service_fee | NUMBER | Platform service fee |
| booking_status | STRING | Status (confirmed, cancelled, completed) |
| created_at | TIMESTAMP | Record creation timestamp |

#### hosts.csv Structure
```
host_id,host_name,host_since,is_superhost,response_rate,created_at
```

| Column | Data Type | Description |
|--------|-----------|-------------|
| host_id | NUMBER | Unique identifier for each host |
| host_name | STRING | Host's display name |
| host_since | DATE | Date host joined platform |
| is_superhost | BOOLEAN | Superhost status indicator |
| response_rate | NUMBER | Response rate percentage (0-100) |
| created_at | TIMESTAMP | Record creation timestamp |

#### listings.csv Structure
```
listing_id,host_id,property_type,room_type,city,country,accommodates,bedrooms,bathrooms,price_per_night,created_at
```

| Column | Data Type | Description |
|--------|-----------|-------------|
| listing_id | NUMBER | Unique identifier for each listing |
| host_id | NUMBER | Foreign key to hosts table |
| property_type | STRING | Type of property (Apartment, House, etc.) |
| room_type | STRING | Room type (Entire, Private, Shared) |
| city | STRING | City location |
| country | STRING | Country location |
| accommodates | NUMBER | Maximum number of guests |
| bedrooms | NUMBER | Number of bedrooms |
| bathrooms | NUMBER | Number of bathrooms |
| price_per_night | NUMBER | Nightly rate |
| created_at | TIMESTAMP | Record creation timestamp |

## AWS Setup

### 1. Create an AWS Account

1. Navigate to [AWS Console](https://aws.amazon.com/)
2. Click "Create an AWS Account"
3. Follow the registration process
4. Complete email verification and payment setup

### 2. Create S3 Bucket

1. Log into AWS Console
2. Navigate to **S3** service
3. Click **"Create bucket"**
4. Configure bucket:
   - **Bucket name**: `your-airbnb-data-bucket` (must be globally unique)
   - **Region**: Select your preferred region (e.g., `us-east-1`)
   - **Block Public Access**: Keep all boxes checked
5. Click **"Create bucket"**

### 3. Create Folder Structure

1. Open your newly created bucket
2. Click **"Create folder"**
3. Create folder named: `source`
4. Click **"Create folder"**

### 4. Upload CSV Files

1. Navigate into the `source` folder
2. Click **"Upload"**
3. Click **"Add files"**
4. Select your three CSV files:
   - `bookings.csv`
   - `hosts.csv`
   - `listings.csv`
5. Click **"Upload"**
6. Wait for upload completion

### 5. Create IAM User for Snowflake

#### Create IAM User

1. Navigate to **IAM** service in AWS Console
2. Click **"Users"** in left sidebar
3. Click **"Create user"**
4. User details:
   - **User name**: `snowflake-s3-access`
5. Click **"Next"**

#### Set Permissions

1. Select **"Attach policies directly"**
2. Click **"Create policy"**
3. Switch to **JSON** tab
4. Paste the following policy (replace `your-airbnb-data-bucket`):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::your-airbnb-data-bucket",
                "arn:aws:s3:::your-airbnb-data-bucket/*"
            ]
        }
    ]
}
```

5. Click **"Next"**
6. Policy details:
   - **Policy name**: `SnowflakeS3ReadAccess`
7. Click **"Create policy"**
8. Go back to user creation tab, refresh policies
9. Search and select `SnowflakeS3ReadAccess`
10. Click **"Next"** → **"Create user"**

#### Generate Access Keys

1. Click on the newly created user `snowflake-s3-access`
2. Navigate to **"Security credentials"** tab
3. Scroll to **"Access keys"** section
4. Click **"Create access key"**
5. Select **"Third-party service"**
6. Check confirmation box
7. Click **"Next"**
8. Click **"Create access key"**
9. **IMPORTANT**: Save these credentials securely:
   - **Access Key ID**: `AKIA...`
   - **Secret Access Key**: `xxxxx...`
10. Click **"Done"**

> **Security Note**: Never commit these credentials to version control. Store them in a secure password manager.

## Snowflake Setup

### 1. Create Snowflake Account

1. Navigate to [Snowflake Trial](https://signup.snowflake.com/)
2. Fill in registration details
3. Select:
   - **Cloud Provider**: AWS
   - **Region**: Same as your S3 bucket region
4. Complete email verification
5. Set password and log in

### 2. Access Snowflake Console

1. Note your account identifier from the URL:
   - Format: `https://<account_identifier>.snowflakecomputing.com`
   - Example: `xy12345.us-east-1`
2. Click **"Worksheets"** in left navigation

### 3. Create Database and Schema

Run the following SQL commands in a new worksheet:

```sql
-- Create database
CREATE DATABASE IF NOT EXISTS AIRBNB;

-- Use the database
USE DATABASE AIRBNB;

-- Create schema
CREATE SCHEMA IF NOT EXISTS STAGING;

-- Use the schema
USE SCHEMA STAGING;
```

**Expected Output:**
```
Database AIRBNB successfully created.
Schema STAGING successfully created.
```

### 4. Create Tables

Execute the following DDL statements:

```sql
-- Create HOSTS table
CREATE OR REPLACE TABLE HOSTS (
    host_id NUMBER,
    host_name STRING,
    host_since DATE,
    is_superhost BOOLEAN,
    response_rate NUMBER,
    created_at TIMESTAMP,
    PRIMARY KEY (host_id)
);

-- Create LISTINGS table
CREATE OR REPLACE TABLE LISTINGS (
    listing_id NUMBER,
    host_id NUMBER,
    property_type STRING,
    room_type STRING,
    city STRING,
    country STRING,
    accommodates NUMBER,
    bedrooms NUMBER,
    bathrooms NUMBER,
    price_per_night NUMBER,
    created_at TIMESTAMP,
    PRIMARY KEY (listing_id)
);

-- Create BOOKINGS table
CREATE OR REPLACE TABLE BOOKINGS (
    booking_id STRING,
    listing_id NUMBER,
    booking_date TIMESTAMP,
    nights_booked NUMBER,
    booking_amount NUMBER,
    cleaning_fee NUMBER,
    service_fee NUMBER,
    booking_status STRING,
    created_at TIMESTAMP,
    PRIMARY KEY (booking_id)
);
```

**Expected Output:**
```
Table HOSTS successfully created.
Table LISTINGS successfully created.
Table BOOKINGS successfully created.
```

### 5. Configure File Format and Stage

Replace placeholders with your actual values:

```sql
-- Create CSV file format
CREATE FILE FORMAT IF NOT EXISTS csv_format
  TYPE = 'CSV' 
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- Verify file format creation
SHOW FILE FORMATS;
```

**Expected Output:**
```
+---------------------+-----+----------+
| name                | type| owner    |
+---------------------+-----+----------+
| csv_format          | CSV | SYSADMIN |
+---------------------+-----+----------+
```

```sql
-- Create external stage pointing to S3
-- Replace: your-airbnb-data-bucket, AWS_KEY_ID, AWS_SECRET_KEY
CREATE OR REPLACE STAGE snowflakestage
  URL = 's3://your-airbnb-data-bucket/source/'
  FILE_FORMAT = csv_format
  CREDENTIALS = (AWS_KEY_ID='AKIA...' AWS_SECRET_KEY='xxxxx...');

-- Verify stage creation
SHOW STAGES;
```

**Expected Output:**
```
+----------------+---------------+-------------+
| name           | url           | owner       |
+----------------+---------------+-------------+
| snowflakestage | s3://your-... | ACCOUNTADMIN|
+----------------+---------------+-------------+
```

```sql
-- List files in stage to verify connection
LIST @snowflakestage;
```

**Expected Output:**
```
+----------------------------------+------+----------+
| name                             | size | md5      |
+----------------------------------+------+----------+
| source/bookings.csv              | 2048 | abc123...|
| source/hosts.csv                 | 1024 | def456...|
| source/listings.csv              | 3072 | ghi789...|
+----------------------------------+------+----------+
```

### 6. Load Data into Tables

```sql
-- Load BOOKINGS data
COPY INTO BOOKINGS
FROM @snowflakestage/bookings.csv
FILE_FORMAT = (FORMAT_NAME = csv_format);
```

**Expected Output:**
```
+---------------+--------+-------------+
| file          | status | rows_parsed |
+---------------+--------+-------------+
| bookings.csv  | LOADED | 1000        |
+---------------+--------+-------------+
```

```sql
-- Load HOSTS data
COPY INTO HOSTS
FROM @snowflakestage/hosts.csv
FILE_FORMAT = (FORMAT_NAME = csv_format);
```

**Expected Output:**
```
+---------------+--------+-------------+
| file          | status | rows_parsed |
+---------------+--------+-------------+
| hosts.csv     | LOADED | 250         |
+---------------+--------+-------------+
```

```sql
-- Load LISTINGS data
COPY INTO LISTINGS
FROM @snowflakestage/listings.csv
FILE_FORMAT = (FORMAT_NAME = csv_format);
```

**Expected Output:**
```
+---------------+--------+-------------+
| file          | status | rows_parsed |
+---------------+--------+-------------+
| listings.csv  | LOADED | 500         |
+---------------+--------+-------------+
```

### 7. Verify Data Load

```sql
-- Check BOOKINGS data
SELECT * FROM BOOKINGS LIMIT 5;
```

**Expected Output:**
```
+------------+------------+---------------------+--------------+
| booking_id | listing_id | booking_date        | nights_booked|
+------------+------------+---------------------+--------------+
| BK001      | 101        | 2024-01-15 10:30:00 | 3            |
| BK002      | 102        | 2024-01-16 14:20:00 | 5            |
+------------+------------+---------------------+--------------+
```

```sql
-- Check HOSTS data
SELECT * FROM HOSTS LIMIT 5;
```

**Expected Output:**
```
+---------+-----------+------------+--------------+
| host_id | host_name | host_since | is_superhost |
+---------+-----------+------------+--------------+
| 1       | John Doe  | 2020-01-15 | TRUE         |
| 2       | Jane Smith| 2019-05-20 | FALSE        |
+---------+-----------+------------+--------------+
```

```sql
-- Check LISTINGS data
SELECT * FROM LISTINGS LIMIT 5;
```

**Expected Output:**
```
+------------+---------+---------------+-----------+
| listing_id | host_id | property_type | room_type |
+------------+---------+---------------+-----------+
| 101        | 1       | Apartment     | Entire    |
| 102        | 1       | House         | Private   |
+------------+---------+---------------+-----------+
```

## dbt Configuration

### 1. Set Up Python Virtual Environment

Navigate to your project directory and create a virtual environment:

```bash
# Create project directory
mkdir -p ~/SnowFlake
cd ~/SnowFlake

# Create virtual environment
python3.12 -m venv .venv

# Activate virtual environment
source .venv/bin/activate
```

**Expected Output:**
```
(.venv) root@system ~/SnowFlake>
```

### 2. Install dbt Dependencies

```bash
# Install dbt-core and dbt-snowflake
pip install dbt-core dbt-snowflake
```

**Expected Output:**
```
Successfully installed dbt-core-1.11.2 dbt-snowflake-1.11.1
```

### 3. Initialize dbt Project

```bash
dbt init aws_snowflake_dbt
```

Follow the interactive prompts:

**Prompts and Responses:**
```
Which database would you like to use?
[1] snowflake
Enter a number: 1

account (https://<this_value>.snowflakecomputing.com): xy12345.us-east-1
user (dev username): your_snowflake_username
[1] password
[2] keypair
[3] sso
Desired authentication type option (enter a number): 1
password (dev password): ********
role (dev role): ACCOUNTADMIN
warehouse (warehouse name): COMPUTE_WH
database (default database that dbt will build objects in): AIRBNB
schema (default schema that dbt will build objects in): dbt_schema
threads (1 or more) [1]: 1
```

**Expected Output:**
```
Your new dbt project "aws_snowflake_dbt" was created!
Profile aws_snowflake_dbt written to /Users/username/.dbt/profiles.yml
```

### 4. Verify dbt Connection

```bash
cd aws_snowflake_dbt
dbt debug
```

**Expected Output:**
```
Running with dbt=1.11.2
dbt version: 1.11.2
python version: 3.12.2
python path: /path/to/.venv/bin/python3
os info: macOS-26.2-x86_64-i386-64bit

Using profiles dir at /Users/username/.dbt
Using profiles.yml file at /Users/username/.dbt/profiles.yml
Using dbt_project.yml file at /path/to/aws_snowflake_dbt/dbt_project.yml

adapter type: snowflake
adapter version: 1.11.1

Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  account: xy12345.us-east-1
  user: your_snowflake_username
  database: AIRBNB
  warehouse: COMPUTE_WH
  role: ACCOUNTADMIN
  schema: dbt_schema
  Connection test: [OK connection ok]

All checks passed!
```

### 5. Run Initial dbt Models

```bash
dbt run
```

**Expected Output:**
```
Running with dbt=1.11.2
Found 2 models, 0 tests, 0 snapshots

Concurrency: 1 threads

Building catalog
Building model example.my_first_model
Building model example.my_second_model

Completed successfully
Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```

## Project Structure

After initialization, your project structure should look like:

```
aws_snowflake_dbt/
├── models/
│   ├── example/
│   │   ├── my_first_dbt_model.sql
│   │   └── my_second_dbt_model.sql
│   └── schema.yml
├── tests/
├── macros/
├── snapshots/
├── analyses/
├── seeds/
├── dbt_project.yml
└── README.md
```

## Next Steps

### 1. Create Advanced dbt Models

After the initial setup, consider creating additional models for:

#### Gold Layer Analytics Models

Create business-ready aggregation models in the Gold layer:

```sql
-- models/gold/gold_booking_metrics.sql
{{ config(materialized="table") }}

SELECT
    DATE_TRUNC('month', booking_date) as booking_month,
    COUNT(DISTINCT booking_id) as total_bookings,
    SUM(total_amount) as total_revenue,
    AVG(nights_booked) as avg_nights_per_booking,
    COUNT(DISTINCT listing_id) as unique_listings_booked
FROM {{ ref('silver_bookings') }}
WHERE booking_status = 'CONFIRMED'
GROUP BY 1
ORDER BY 1
```

```sql
-- models/gold/gold_host_performance.sql
{{ config(materialized="table") }}

SELECT
    h.host_id,
    h.host_name,
    h.is_superhost,
    h.response_rate_quality,
    COUNT(DISTINCT l.listing_id) as total_listings,
    COUNT(DISTINCT b.booking_id) as total_bookings,
    COALESCE(SUM(b.total_amount), 0) as total_revenue
FROM {{ ref('silver_hosts') }} h
LEFT JOIN {{ ref('silver_listings') }} l ON h.host_id = l.host_id
LEFT JOIN {{ ref('silver_bookings') }} b ON l.listing_id = b.listing_id
GROUP BY 1, 2, 3, 4
```

### 2. Add Comprehensive Tests

Implement data quality tests to ensure data integrity:

```yaml
# models/silver/schema.yml
version: 2

models:
  - name: silver_bookings
    description: "Cleaned and enriched booking data"
    columns:
      - name: booking_id
        tests:
          - unique
          - not_null
      - name: total_amount
        tests:
          - not_null
          - positive_values:
              config:
                severity: warn
      - name: booking_status
        tests:
          - accepted_values:
              values: ['CONFIRMED', 'CANCELLED', 'COMPLETED', 'PENDING']
```

### 3. Set Up dbt Documentation

Generate and serve documentation:

```bash
# Generate documentation
dbt docs generate

# Serve documentation locally
dbt docs serve --port 8080
```

**Expected Output:**
```
Running with dbt=1.11.2
Catalog written to /path/to/target/catalog.json
Docs generated successfully!

Serving docs at: http://localhost:8080
Press Ctrl+C to exit.
```

### 4. Schedule dbt Runs

Implement scheduling using orchestration tools:

#### Option A: Using cron (Linux/macOS)
```bash
# Edit crontab
crontab -e

# Add daily run at 2 AM
0 2 * * * cd /path/to/project && source .venv/bin/activate && dbt run --target prod
```

#### Option B: Using Apache Airflow

```python
# dags/dbt_airbnb_dag.py
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'dbt_airbnb_pipeline',
    default_args=default_args,
    schedule_interval='0 2 * * *',  # Daily at 2 AM
    catchup=False
) as dag:

    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /path/to/project && source .venv/bin/activate && dbt run'
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /path/to/project && source .venv/bin/activate && dbt test'
    )

    dbt_run >> dbt_test
```

### 5. Implement CI/CD

Set up automated testing and deployment:

#### GitHub Actions Workflow

```yaml
# .github/workflows/dbt-ci.yml
name: dbt CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  dbt-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install dbt-core dbt-snowflake
      
      - name: Configure dbt profile
        run: |
          mkdir -p ~/.dbt
          echo "${{ secrets.DBT_PROFILES_YML }}" > ~/.dbt/profiles.yml
      
      - name: dbt deps
        run: dbt deps
        working-directory: ./aws_snowflake_dbt
      
      - name: dbt compile
        run: dbt compile
        working-directory: ./aws_snowflake_dbt
      
      - name: dbt test
        run: dbt test
        working-directory: ./aws_snowflake_dbt
```

---

## Project Structure

After initialization, your project structure should look like:

```
aws_snowflake_dbt/
├── models/
│   ├── bronze/                    # Raw data layer
│   │   ├── bronze_bookings.sql
│   │   ├── bronze_hosts.sql
│   │   ├── bronze_listings.sql
│   │   └── docs/
│   │       ├── doc_blocks.md
│   │       └── schema.yml
│   ├── silver/                    # Cleaned data layer
│   │   ├── silver_bookings.sql
│   │   ├── silver_hosts.sql
│   │   └── silver_listings.sql
│   ├── demo/                      # Demo models
│   │   ├── snowflake_dbt_bookings.sql
│   │   ├── snowflake_dbt_listing_id.sql
│   │   └── docs/
│   │       ├── doc_blocks.md
│   │       └── schema.yml
│   └── sources/
│       └── sources.yml
├── macros/                        # Reusable SQL macros
│   ├── generate_schema_name.sql
│   ├── multiply.sql
│   ├── tag.sql
│   ├── trimmer.sql
│   └── upper_case.sql
├── analyses/                      # Ad-hoc SQL analyses
│   ├── if_else.sql
│   └── loop.sql
├── tests/                         # Custom tests
├── seeds/                         # Static CSV data
├── snapshots/                     # SCD Type 2 snapshots
├── target/                        # Compiled SQL output
├── logs/                          # dbt run logs
├── dbt_project.yml               # Project configuration
└── README.md
```

---

## Medallion Architecture

This project implements the **Medallion Architecture** pattern, which organizes data into three distinct layers:

### Bronze Layer (Raw)

The Bronze layer contains raw data exactly as it was received from the source systems. This layer:

- Preserves the original data format and structure
- Implements incremental loading to capture new records
- Serves as the single source of truth for raw data
- Enables data replay and reprocessing if needed

**Configuration:**
```yaml
bronze:
  +materialized: table
  +schema: bronze
```

### Silver Layer (Cleaned)

The Silver layer contains cleaned, validated, and enriched data. This layer:

- Applies data quality rules and transformations
- Standardizes data formats (dates, strings, numbers)
- Adds derived columns and business logic
- Resolves data quality issues from the Bronze layer

**Configuration:**
```yaml
silver:
  +materialized: table
  +schema: silver
```

### Gold Layer (Business)

The Gold layer contains business-ready aggregations and metrics. This layer:

- Provides pre-computed aggregations for reporting
- Implements business KPIs and metrics
- Optimizes for query performance
- Serves as the primary layer for BI tools

**Configuration:**
```yaml
gold:
  +materialized: table
  +schema: gold
```

---

## dbt Models

### Bronze Layer Models

#### bronze_bookings.sql

This model loads raw booking data from the staging area with incremental processing:

```sql
{{ config(materialized="incremental") }}

select *
from {{ source("staging", "bookings") }}

{% if is_incremental() %}
    where created_at > (select coalesce(max(created_at), '1900-01-01') from {{ this }})
{% endif %}
```

**Key Features:**
- **Incremental Materialization**: Only processes new records based on `created_at`
- **Source Reference**: Uses `source()` function to reference staging tables
- **Idempotent Loading**: Can be run multiple times without duplicating data

#### bronze_hosts.sql

This model loads raw host data with the same incremental pattern:

```sql
{{ config(materialized="incremental") }}

select *
from {{ source("staging", "hosts") }}

{% if is_incremental() %}
    where created_at > (select coalesce(max(created_at), '1900-01-01') from {{ this }})
{% endif %}
```

#### bronze_listings.sql

This model loads raw listing data:

```sql
{{ config(materialized="incremental") }}

select *
from {{ source("staging", "listings") }}

{% if is_incremental() %}
    where created_at > (select coalesce(max(created_at), '1900-01-01') from {{ this }})
{% endif %}
```

### Silver Layer Models

#### silver_bookings.sql

This model transforms and enriches booking data:

```sql
{{ config(materialized="incremental", unique_key="booking_id") }}

select
    booking_id,
    listing_id,
    booking_date,
    nights_booked,
    booking_amount,
    -- Using macro to calculate total amount
    {{ multiply("nights_booked", "booking_amount", 2) }} as total_amount,
    service_fee,
    cleaning_fee,
    -- Using macro to standardize status to uppercase
    {{ upper_case("booking_status") }} as booking_status,
    created_at
from {{ ref("bronze_bookings") }}
```

**Transformations Applied:**
| Column | Transformation | Description |
|--------|----------------|-------------|
| total_amount | `multiply()` macro | Calculates nights × amount with 2 decimal precision |
| booking_status | `upper_case()` macro | Standardizes status to uppercase |

#### silver_hosts.sql

This model transforms and enriches host data:

```sql
{{ config(materialized="incremental", unique_key="host_id") }}

select
    host_id,
    replace(host_name, ' ', '_') as host_name,
    host_since,
    is_superhost,
    response_rate,
    case
        when response_rate > 95 then 'very good'
        when response_rate > 80 then 'good'
        when response_rate > 60 then 'fair'
        else 'poor'
    end as response_rate_quality,
    created_at
from {{ ref("bronze_hosts") }}
```

**Transformations Applied:**
| Column | Transformation | Description |
|--------|----------------|-------------|
| host_name | `REPLACE()` | Replaces spaces with underscores |
| response_rate_quality | CASE statement | Categorizes response rate into quality tiers |

#### silver_listings.sql

This model transforms and enriches listing data:

```sql
{{ config(materialized="incremental", unique_key="listing_id") }}

select
    listing_id,
    host_id,
    property_type,
    {{ trimmer("property_type") }} as property_type_cleaned,
    room_type,
    city,
    country,
    accommodates,
    bedrooms,
    bathrooms,
    price_per_night,
    {{ tag("cast(price_per_night as int)") }} as price_per_night_tag,
    created_at
from {{ ref("bronze_listings") }}
```

**Transformations Applied:**
| Column | Transformation | Description |
|--------|----------------|-------------|
| property_type_cleaned | `trimmer()` macro | Trims whitespace and converts to uppercase |
| price_per_night_tag | `tag()` macro | Categorizes price into low/medium/high |

### Demo Models

#### snowflake_dbt_bookings.sql

A simple demo model showing basic source selection:

```sql
{{ config(materialized="table") }}

select * from {{ source("staging", "bookings") }}
```

#### snowflake_dbt_listing_id.sql

A demo model showing model references with filtering:

```sql
select * from {{ ref("snowflake_dbt_bookings") }} where listing_id = 1
```

---

## Custom Macros

### multiply Macro

**File:** `macros/multiply.sql`

```sql
{% macro multiply(x, y, precision) %}
    round({{ x }} * {{ y }}, {{ precision }})
{% endmacro %}
```

**Purpose:** Multiplies two numeric values and rounds the result to a specified precision.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| x | numeric/column | First operand |
| y | numeric/column | Second operand |
| precision | integer | Number of decimal places |

**Usage Examples:**
```sql
-- In a model
{{ multiply("nights_booked", "booking_amount", 2) }}
-- Compiles to: round(nights_booked * booking_amount, 2)

{{ multiply(10, 3, 0) }}
-- Compiles to: round(10 * 3, 0) = 30
```

### upper_case Macro

**File:** `macros/upper_case.sql`

```sql
{% macro upper_case(column_name) %}
    upper({{ column_name }})
{% endmacro %}
```

**Purpose:** Converts a string column to uppercase.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| column_name | string/column | Column to convert |

**Usage Examples:**
```sql
-- In a model
{{ upper_case("booking_status") }}
-- Compiles to: upper(booking_status)

{{ upper_case("'hello'") }}
-- Compiles to: upper('hello') = 'HELLO'
```

### trimmer Macro

**File:** `macros/trimmer.sql`

```sql
{% macro trimmer(column_name) %}
    upper(trim({{ column_name }}))
{% endmacro %}
```

**Purpose:** Trims whitespace and converts to uppercase in one operation.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| column_name | string/column | Column to trim and uppercase |

**Usage Examples:**
```sql
-- In a model
{{ trimmer("property_type") }}
-- Compiles to: upper(trim(property_type))

-- For "  Apartment  " returns "APARTMENT"
```

### tag Macro

**File:** `macros/tag.sql`

```sql
{% macro tag(col) %}
    case
        when {{ col }} < 100 then 'low'
        when {{ col }} < 200 then 'medium'
        else 'high'
    end
{% endmacro %}
```

**Purpose:** Categorizes numeric values into low, medium, or high categories.

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| col | numeric/column | Column or expression to categorize |

**Categorization Logic:**
| Value Range | Tag |
|-------------|-----|
| < 100 | low |
| 100 - 199 | medium |
| >= 200 | high |

**Usage Examples:**
```sql
-- In a model
{{ tag("price_per_night") }}
-- Compiles to: case when price_per_night < 100 then 'low' ...

{{ tag("cast(price_per_night as int)") }}
-- With type casting
```

### generate_schema_name Macro

**File:** `macros/generate_schema_name.sql`

```sql
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

**Purpose:** Overrides dbt's default schema naming behavior to use custom schema names directly without the target schema prefix.

**Default dbt Behavior:**
```
target_schema + '_' + custom_schema = dbt_schema_bronze
```

**Custom Behavior:**
```
custom_schema only = bronze
```

**Why Override?**
This allows cleaner schema names in Snowflake:
- Without override: `DBT_SCHEMA_BRONZE`
- With override: `BRONZE`

---

## Jinja Control Structures

### If-Else Statements

**File:** `analyses/if_else.sql`

dbt uses Jinja templating to enable dynamic SQL generation. Here's an example of conditional logic:

```sql
-- Setting variables
{% set flag = 1 %}
{% set night_booked_greater_than_10 = 10 %}
{% set night_booked_equal_to_two = 2 %}

-- Using if-else for table selection
{% if flag == 1 %}
    select * from {{ source("staging", "listings") }}
{% else %}
    select * from {{ source("staging", "bookings") }}
{% endif %}

-- Using if-else for WHERE clause
select *
from {{ ref("bronze_bookings") }}
{% if flag == 1 %}
    where night_booked > {{ night_booked_greater_than_10 }}
{% else %}
    where night_booked = {{ night_booked_equal_to_two }}
{% endif %}
```

**Compiled Output (when flag = 1):**
```sql
select * from AIRBNB.STAGING.LISTINGS

select *
from AIRBNB.BRONZE.BRONZE_BOOKINGS
where night_booked > 10
```

### For Loops

**File:** `analyses/loop.sql`

For loops enable dynamic column generation:

```sql
{% set cols = ["NIGHTS_BOOKED", "BOOKING_ID", "BOOKING_AMOUNT"] %}

select
    {% for col in cols %}
        {{ col }}{% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref("bronze_bookings") }}
```

**Compiled Output:**
```sql
select
    NIGHTS_BOOKED,
    BOOKING_ID,
    BOOKING_AMOUNT
from AIRBNB.BRONZE.BRONZE_BOOKINGS
```

**Loop Variables:**
| Variable | Description |
|----------|-------------|
| `loop.index` | Current iteration (1-indexed) |
| `loop.index0` | Current iteration (0-indexed) |
| `loop.first` | True if first iteration |
| `loop.last` | True if last iteration |
| `loop.length` | Total number of items |

---

## Testing

### Schema Tests

Schema tests are defined in YAML files and test specific column properties:

**File:** `models/bronze/docs/schema.yml`

```yaml
models:
  - name: bronze_bookings
    description: "{{ doc('table_bronze_bookings') }}"
    columns:
      - name: booking_id
        description: "{{ doc('booking_id') }}"
        data_tests:
          - unique
          - not_null
      - name: listing_id
        description: "{{ doc('listing_id') }}"
      - name: booking_date
        description: "{{ doc('booking_date') }}"

  - name: bronze_hosts
    columns:
      - name: host_id
        data_tests:
          - unique
          - not_null

  - name: bronze_listings
    columns:
      - name: listing_id
        data_tests:
          - unique
          - not_null
```

**Built-in Tests:**
| Test | Description |
|------|-------------|
| `unique` | Ensures no duplicate values in the column |
| `not_null` | Ensures no NULL values in the column |
| `accepted_values` | Ensures values are within a specified list |
| `relationships` | Ensures referential integrity |

**Running Tests:**
```bash
# Run all tests
dbt test

# Run tests for specific model
dbt test --select bronze_bookings

# Run tests for all models in a directory
dbt test --select bronze.*
```

**Expected Output:**
```
Running with dbt=1.11.2
Found 6 tests

Running tests:
  ✓ unique_bronze_bookings_booking_id
  ✓ not_null_bronze_bookings_booking_id
  ✓ unique_bronze_hosts_host_id
  ✓ not_null_bronze_hosts_host_id
  ✓ unique_bronze_listings_listing_id
  ✓ not_null_bronze_listings_listing_id

Completed successfully
Done. PASS=6 WARN=0 ERROR=0 SKIP=0 TOTAL=6
```

### Custom Tests

Create custom tests in the `tests/` directory:

```sql
-- tests/assert_positive_booking_amount.sql
-- This test will fail if any booking has a negative amount

select *
from {{ ref('silver_bookings') }}
where total_amount < 0
```

**How Custom Tests Work:**
- If the query returns 0 rows → Test PASSES
- If the query returns any rows → Test FAILS

---

## Documentation

### Doc Blocks

Doc blocks allow reusable documentation definitions:

**File:** `models/bronze/docs/doc_blocks.md`

```markdown
{% docs table_bronze_bookings %}
This table contains raw booking data from the Airbnb platform.
Each row represents a single booking transaction.

**Update Frequency:** Incremental (new records only)
**Source System:** AIRBNB.STAGING.BOOKINGS
{% enddocs %}

{% docs booking_id %}
The unique identifier for each booking transaction.
Format: BK followed by numeric sequence (e.g., BK001, BK002)
{% enddocs %}

{% docs listing_id %}
Foreign key reference to the listings table.
Links a booking to its associated property listing.
{% enddocs %}
```

### Schema Documentation

Reference doc blocks in schema files:

```yaml
models:
  - name: bronze_bookings
    description: "{{ doc('table_bronze_bookings') }}"
    columns:
      - name: booking_id
        description: "{{ doc('booking_id') }}"
```

### Generating Documentation

```bash
# Generate documentation
dbt docs generate

# Serve documentation website
dbt docs serve
```

---

## dbt Commands Reference

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `dbt run` | Execute all models | `dbt run` |
| `dbt test` | Run all tests | `dbt test` |
| `dbt build` | Run + Test in dependency order | `dbt build` |
| `dbt compile` | Compile models without executing | `dbt compile` |
| `dbt debug` | Test connection and configuration | `dbt debug` |

### Selection Commands

| Command | Description |
|---------|-------------|
| `dbt run --select model_name` | Run specific model |
| `dbt run --select +model_name` | Run model and all upstream |
| `dbt run --select model_name+` | Run model and all downstream |
| `dbt run --select bronze.*` | Run all models in bronze folder |
| `dbt run --select tag:daily` | Run models with specific tag |

### Full vs Incremental Runs

| Command | Description |
|---------|-------------|
| `dbt run` | Incremental run (new records only) |
| `dbt run --full-refresh` | Full refresh (rebuild tables) |
| `dbt run --select model_name --full-refresh` | Full refresh specific model |

### Documentation Commands

| Command | Description |
|---------|-------------|
| `dbt docs generate` | Generate documentation catalog |
| `dbt docs serve` | Start documentation website |
| `dbt docs serve --port 8080` | Serve on specific port |

### Other Useful Commands

| Command | Description |
|---------|-------------|
| `dbt deps` | Install dbt packages |
| `dbt seed` | Load CSV files from seeds directory |
| `dbt snapshot` | Run snapshot models |
| `dbt source freshness` | Check source data freshness |
| `dbt clean` | Remove target and dbt_packages directories |
| `dbt ls` | List resources in the project |

---

## Best Practices

### Model Organization

1. **Use Medallion Architecture**: Organize models into Bronze, Silver, and Gold layers
2. **One Model Per File**: Each SQL file should contain one model
3. **Descriptive Names**: Use clear, descriptive model names (e.g., `silver_bookings` not `sb`)
4. **Consistent Naming**: Follow a naming convention across all models

### SQL Style Guide

1. **Lowercase Keywords**: Use lowercase for SQL keywords (`select`, `from`, `where`)
2. **Trailing Commas**: Place commas at the end of lines, not the beginning
3. **CTEs Over Subqueries**: Use Common Table Expressions for readability
4. **Explicit Column Selection**: Avoid `SELECT *` in production models

```sql
-- Good
select
    booking_id,
    listing_id,
    booking_date
from {{ ref('bronze_bookings') }}

-- Avoid
select * from {{ ref('bronze_bookings') }}
```

### Performance Optimization

1. **Incremental Models**: Use incremental materialization for large tables
2. **Unique Keys**: Always specify `unique_key` for incremental models
3. **Clustering**: Consider clustering keys for frequently filtered columns
4. **Partitioning**: Partition large tables by date columns

```sql
{{ config(
    materialized='incremental',
    unique_key='booking_id',
    cluster_by=['booking_date']
) }}
```

### Testing Strategy

1. **Test Primary Keys**: Always test uniqueness and not_null on primary keys
2. **Test Foreign Keys**: Use relationships tests for referential integrity
3. **Test Business Rules**: Create custom tests for business logic
4. **Test Data Quality**: Implement tests for data quality rules

### Documentation

1. **Document All Models**: Add descriptions to all models and columns
2. **Use Doc Blocks**: Create reusable documentation with doc blocks
3. **Update Documentation**: Keep documentation up to date with code changes
4. **Generate Regularly**: Regenerate documentation after changes

---

## Troubleshooting

### Connection Issues

#### dbt debug Fails

**Symptom:** `dbt debug` shows connection errors

**Common Causes and Solutions:**

| Issue | Solution |
|-------|----------|
| Invalid credentials | Verify username/password in `~/.dbt/profiles.yml` |
| Wrong account identifier | Check format: `xy12345.us-east-1` |
| Network issues | Ensure firewall allows Snowflake connections |
| Warehouse suspended | Start warehouse in Snowflake console |
| Invalid role | Verify role exists and user has access |

**Debugging Steps:**
```bash
# Check profiles.yml location
cat ~/.dbt/profiles.yml

# Test Snowflake connection directly
snowsql -a <account> -u <username>

# Verify network connectivity
ping <account>.snowflakecomputing.com
```

#### Profile Not Found

**Symptom:** `Could not find profile named 'aws_snowflake_dbt'`

**Solution:** Ensure profile name in `dbt_project.yml` matches `profiles.yml`:

```yaml
# dbt_project.yml
profile: 'aws_snowflake_dbt'

# ~/.dbt/profiles.yml
aws_snowflake_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      ...
```

### S3 Access Errors

#### LIST @snowflakestage Fails

**Symptom:** `SQL execution error: Unable to access files in S3 bucket`

**Common Causes and Solutions:**

| Issue | Solution |
|-------|----------|
| Invalid credentials | Regenerate AWS access keys |
| Bucket not found | Verify bucket name is correct |
| Region mismatch | Ensure stage URL matches bucket region |
| Insufficient permissions | Update IAM policy with correct permissions |

**Debugging Steps:**
```sql
-- Check stage configuration
SHOW STAGES;

-- Describe stage details
DESCRIBE STAGE snowflakestage;

-- Test with explicit credentials
LIST @snowflakestage;
```

#### Permission Denied Errors

**Symptom:** `Access Denied` when accessing S3

**Solution:** Verify IAM policy has all required permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        }
    ]
}
```

### Data Load Errors

#### COPY INTO Fails

**Symptom:** `COPY INTO` command returns errors

**Common Causes and Solutions:**

| Issue | Solution |
|-------|----------|
| Column count mismatch | Set `ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE` |
| Data type mismatch | Cast columns or update table schema |
| Invalid date format | Specify date format in file format |
| Encoding issues | Set proper encoding in file format |

**Debugging Steps:**
```sql
-- Check file format settings
SHOW FILE FORMATS;

-- Validate data before loading
SELECT $1, $2, $3 FROM @snowflakestage/bookings.csv LIMIT 10;

-- Load with error handling
COPY INTO BOOKINGS
FROM @snowflakestage/bookings.csv
FILE_FORMAT = (FORMAT_NAME = csv_format)
ON_ERROR = 'CONTINUE';

-- Check load history
SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'BOOKINGS',
    START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
));
```

### dbt Run Errors

#### Model Compilation Errors

**Symptom:** `Compilation Error` during dbt run

**Common Causes:**
- Invalid Jinja syntax
- Missing source or ref
- Undefined macro

**Debugging:**
```bash
# Compile specific model to see generated SQL
dbt compile --select model_name

# Check compiled SQL
cat target/compiled/aws_snowflake_dbt/models/bronze/bronze_bookings.sql
```

#### Incremental Model Issues

**Symptom:** Incremental model not picking up new records

**Solutions:**
```bash
# Force full refresh
dbt run --select model_name --full-refresh

# Check incremental logic
dbt compile --select model_name
```

---

## Advanced Topics

### Snapshots (Slowly Changing Dimensions)

Snapshots capture historical changes to data using SCD Type 2:

```sql
-- snapshots/hosts_snapshot.sql
{% snapshot hosts_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='host_id',
        strategy='timestamp',
        updated_at='updated_at'
    )
}}

select * from {{ source('staging', 'hosts') }}

{% endsnapshot %}
```

**Running Snapshots:**
```bash
dbt snapshot
```

### Seeds (Static Data)

Load static reference data from CSV files:

```bash
# Place CSV in seeds/ directory
# seeds/country_codes.csv

dbt seed
```

**Referencing Seeds:**
```sql
select * from {{ ref('country_codes') }}
```

### Hooks (Pre/Post Operations)

Execute SQL before or after model runs:

```sql
{{ config(
    pre_hook="ALTER SESSION SET TIMEZONE = 'UTC'",
    post_hook="GRANT SELECT ON {{ this }} TO ROLE ANALYST"
) }}
```

### Packages

Install community packages:

**File:** `packages.yml`
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
  - package: calogica/dbt_expectations
    version: 0.10.1
```

**Install:**
```bash
dbt deps
```

**Using Package Macros:**
```sql
select
    {{ dbt_utils.generate_surrogate_key(['booking_id', 'listing_id']) }} as surrogate_key,
    *
from {{ ref('bronze_bookings') }}
```

### Environment Variables

Use environment variables for sensitive data:

**profiles.yml:**
```yaml
aws_snowflake_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      ...
```

**Setting Variables:**
```bash
export SNOWFLAKE_ACCOUNT=xy12345.us-east-1
export SNOWFLAKE_USER=your_username
export SNOWFLAKE_PASSWORD=your_password
```

### Multiple Environments

Configure multiple environments (dev, staging, prod):

```yaml
aws_snowflake_dbt:
  target: dev  # Default target
  outputs:
    dev:
      type: snowflake
      database: AIRBNB_DEV
      schema: dbt_schema
      ...
    staging:
      type: snowflake
      database: AIRBNB_STAGING
      schema: dbt_schema
      ...
    prod:
      type: snowflake
      database: AIRBNB_PROD
      schema: dbt_schema
      ...
```

**Running Against Specific Target:**
```bash
dbt run --target staging
dbt run --target prod
```

### Custom Generic Tests

Create reusable generic tests:

```sql
-- macros/test_positive_value.sql
{% test positive_value(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
```

**Using in Schema:**
```yaml
columns:
  - name: total_amount
    tests:
      - positive_value
```

### Source Freshness

Monitor data freshness:

```yaml
# sources.yml
sources:
  - name: staging
    database: AIRBNB
    schema: staging
    freshness:
      warn_after: {count: 12, period: hour}
      error_after: {count: 24, period: hour}
    loaded_at_field: created_at
    tables:
      - name: bookings
      - name: hosts
      - name: listings
```

**Check Freshness:**
```bash
dbt source freshness
```

---

## Frequently Asked Questions

### General Questions

**Q: What is dbt?**

A: dbt (data build tool) is an open-source command-line tool that enables data analysts and engineers to transform data in their warehouses using SQL and software engineering best practices like version control, testing, and documentation.

**Q: Why use dbt with Snowflake?**

A: dbt leverages Snowflake's scalable compute to perform transformations directly in the warehouse (ELT pattern), eliminating the need for external processing infrastructure. This approach is more cost-effective and maintainable than traditional ETL.

**Q: What is the medallion architecture?**

A: The medallion architecture is a data design pattern that organizes data into three layers:
- **Bronze**: Raw data exactly as received from source systems
- **Silver**: Cleaned, validated, and enriched data
- **Gold**: Business-ready aggregations and metrics

### Model Questions

**Q: When should I use incremental vs table materialization?**

A: 
- Use **incremental** for:
  - Large tables (millions of rows)
  - Append-only data patterns
  - When full refreshes are time/cost prohibitive
  
- Use **table** for:
  - Small to medium tables
  - Data requiring full recalculation
  - Development and testing

**Q: How do I handle late-arriving data?**

A: Use a lookback window in your incremental logic:

```sql
{% if is_incremental() %}
    where created_at > (
        select dateadd(day, -3, max(created_at))
        from {{ this }}
    )
{% endif %}
```

**Q: Can I use Python in dbt?**

A: Yes, dbt supports Python models in Snowflake:

```python
# models/my_python_model.py
def model(dbt, session):
    df = dbt.ref("silver_bookings")
    # Pandas operations
    return df.groupby("listing_id").agg({"total_amount": "sum"})
```

### Testing Questions

**Q: How many tests should I write?**

A: At minimum, test:
- Primary key uniqueness and not_null
- Foreign key relationships
- Critical business rules
- Data quality thresholds

**Q: How do I test data freshness?**

A: Configure source freshness in your sources.yml and run `dbt source freshness`.

### Performance Questions

**Q: Why is my dbt run slow?**

A: Common causes:
1. Too many full table scans (add clustering)
2. Large tables without incremental (convert to incremental)
3. Sequential model runs (increase threads)
4. Inefficient SQL (optimize queries)

**Q: How do I optimize Snowflake costs?**

A: 
1. Use appropriate warehouse sizes
2. Implement incremental models
3. Schedule runs during off-peak hours
4. Use transient tables where appropriate

---

## Resources

### Official Documentation

- [dbt Core Documentation](https://docs.getdbt.com/)
- [dbt Snowflake Adapter](https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)

### Learning Resources

- [dbt Learn Courses](https://courses.getdbt.com/)
- [Snowflake University](https://learn.snowflake.com/)
- [AWS Training](https://aws.amazon.com/training/)

### Community

- [dbt Community Slack](https://community.getdbt.com/)
- [dbt Discourse Forum](https://discourse.getdbt.com/)
- [Snowflake Community](https://community.snowflake.com/)
- [Stack Overflow - dbt Tag](https://stackoverflow.com/questions/tagged/dbt)

### Books and Blogs

- [The Analytics Engineering Guide](https://www.getdbt.com/analytics-engineering/)
- [Snowflake's Modern Data Stack](https://www.snowflake.com/guides/)

### Tools and Utilities

- [dbt Power User VSCode Extension](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user)
- [SQLFluff - SQL Linter](https://sqlfluff.com/)
- [Elementary - Data Observability](https://www.elementary-data.com/)

---

## Contributing

We welcome contributions to improve this guide! Here's how you can contribute:

### Reporting Issues

1. Check existing issues to avoid duplicates
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (dbt version, Snowflake edition)

### Suggesting Improvements

1. Open a discussion or issue
2. Describe the proposed improvement
3. Provide examples if applicable

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-improvement`
3. Make your changes
4. Test your changes
5. Commit with clear messages: `git commit -m "Add section on X"`
6. Push to your fork: `git push origin feature/my-improvement`
7. Open a pull request

### Code Style

- Use lowercase for SQL keywords
- Follow existing naming conventions
- Add comments for complex logic
- Update documentation for new features

---

## License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Changelog

### Version 1.0.0 (Initial Release)

- Initial project setup with AWS S3, Snowflake, and dbt integration
- Bronze layer models with incremental loading
- Silver layer models with data transformations
- Custom macros for common operations
- Comprehensive testing framework
- Full documentation

---

## Acknowledgments

- [dbt Labs](https://www.getdbt.com/) for creating the amazing dbt tool
- [Snowflake](https://www.snowflake.com/) for their cloud data platform
- [AWS](https://aws.amazon.com/) for S3 storage services
- The data engineering community for best practices and patterns

---

**Happy Data Engineering!**