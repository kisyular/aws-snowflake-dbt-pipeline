# AWS - Snowflake - DBT Integration Guide

A comprehensive guide for setting up an end-to-end data pipeline using AWS S3, Snowflake, and dbt (Data Build Tool) for Airbnb analytics.

## Table of Contents

- [Prerequisites](#prerequisites)
- [AWS Setup](#aws-setup)
- [Snowflake Setup](#snowflake-setup)
- [dbt Configuration](#dbt-configuration)
- [Data Loading](#data-loading)
- [Verification](#verification)

## Prerequisites

- AWS Account
- Snowflake Account (30-day free trial available)
- Python 3.12 installed
- Git installed
- CSV files: `bookings.csv`, `hosts.csv`, `listings.csv`

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
mkdir -p ~/Documents/CLASSES/D-E/SnowFlake
cd ~/Documents/CLASSES/D-E/SnowFlake

# Create virtual environment
python3.12 -m venv .venv

# Activate virtual environment
source .venv/bin/activate
```

**Expected Output:**
```
(.venv) root@system ~/Documents/CLASSES/D-E/SnowFlake>
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

1. **Create dbt models** for transforming your Airbnb data
2. **Add tests** to ensure data quality
3. **Set up documentation** using `dbt docs generate`
4. **Schedule dbt runs** using orchestration tools
5. **Implement CI/CD** for automated testing and deployment

## Troubleshooting

### Connection Issues

If `dbt debug` fails:
- Verify Snowflake credentials in `~/.dbt/profiles.yml`
- Check network connectivity to Snowflake
- Ensure warehouse is running in Snowflake console

### S3 Access Errors

If `LIST @snowflakestage` fails:
- Verify IAM user has correct permissions
- Check S3 bucket name and region
- Confirm AWS credentials are correct

### Data Load Errors

If `COPY INTO` fails:
- Verify CSV file format matches table schema
- Check file delimiter and header settings
- Review error messages in Snowflake query history

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)