# Airbnb dbt Project

A comprehensive dbt project for transforming and analyzing Airbnb listing and review data. This project implements a modern data transformation pipeline with multiple model layers, data quality tests, and comprehensive documentation.

## Project Overview

The Airbnb dbt project transforms raw data from three main sources (listings, hosts, and reviews) into a well-structured, documented data warehouse. The pipeline follows dbt best practices with a multi-layered architecture including source models, staging models, dimension tables, and fact tables.

### Key Features

- **Multi-layer Modeling Architecture**: Source (src) → Dimension (dim) → Fact (fct) → Mart layers
- **Data Quality Testing**: Comprehensive tests including uniqueness, not-null, referential integrity, and custom validation
- **Incremental Loading**: Efficient incremental processing for large fact tables
- **Audit Logging**: Automatic tracking of model transformations with timestamps
- **Custom Macros**: Reusable functions for common data quality checks
- **Snapshot Capability**: Historical tracking of slowly changing dimensions

## Project Structure

```
airbnb_dbt_project/
├── analyses/              # Ad-hoc analyses and exploratory queries
│   └── full_moon_no_sleep.sql
├── assets/                # Documentation images and static files
├── macros/                # Custom dbt macros and generic tests
│   ├── logging.sql        # Audit logging functionality
│   ├── no_empty_strings.sql
│   ├── variables.sql
│   └── generic_tests/     # Reusable test definitions
│       └── positive_values.sql
├── models/                # dbt transformation models
│   ├── src/               # Source models (ephemeral materialization)
│   │   ├── src_hosts.sql
│   │   ├── src_listings.sql
│   │   └── src_reviews.sql
│   ├── dim/               # Dimension tables (table materialization)
│   │   ├── dim_hosts_cleansed.sql
│   │   ├── dim_listing_cleansed.sql
│   │   └── dim_listing_w_hosts_cleansed.sql
│   ├── fct/               # Fact tables (incremental)
│   │   ├── fct_reviews.sql
│   │   └── test_model.sql
│   ├── mart/              # Mart/reporting layer
│   │   ├── mart_fullmoon_reviews.sql
│   │   └── test.sql
│   ├── base_airbnb_reviews.sql
│   ├── schema.yml         # Model definitions and tests
│   ├── sources.yml        # Source definitions
│   ├── docs.md            # Model documentation
│   └── overview.md        # Project overview
├── seeds/                 # Static reference data (CSV files)
│   └── seed_full_moon_dates.csv
├── snapshots/             # Snapshot configurations for SCD Type 2
│   ├── raw_hosts_snapshot.yml
│   └── raw_listings_snapshot.yml
├── tests/                 # dbt tests
│   ├── consistent_created_at.sql
│   ├── dim_listings_minimum_nights.sql
│   ├── mart_unit_test.yml
│   └── generic/           # Custom generic tests
│       └── minimum_row_count.sql
├── dbt_project.yml        # dbt project configuration
├── packages.yml           # Package dependencies
├── profiles.yml           # Database connection profiles
└── README.md             # This file
```

## Data Models

### Source Models (src/)
Raw data transformations with minimal business logic. Materialized as **ephemeral** for efficiency.

- **src_hosts.sql**: Transforms raw host data with field renaming
- **src_listings.sql**: Cleans and prepares listing data
- **src_reviews.sql**: Prepares review data for fact table

### Dimension Models (dim/)
Cleaned, conformed dimension tables materialized as **tables**.

- **dim_hosts_cleansed**: Host dimension with superhost flags, timestamps, and contract enforcement
- **dim_listing_cleansed**: Listing dimension with room types, pricing, and minimum night requirements
  - Tests: unique & not-null listing_id, accepted values for room_type, positive values for minimum_nights
  - Relationships: validated host_id foreign key reference
- **dim_listing_w_hosts_cleansed**: Combined listing and host information for convenient analysis

### Fact Models (fct/)
Event and transaction fact tables, materialized as **incremental** for efficient updates.

- **fct_reviews**: Review facts with incremental loading support
  - Generates surrogate key from listing_id, review_date, reviewer_name, and review_text
  - Supports parameterized date range loading via `start_date` and `end_date` variables
  - Filters out null review texts
  - Uses dbt_utils for surrogate key generation

### Mart Models (mart/)
Business-specific aggregations and reporting tables.

- **mart_fullmoon_reviews**: Specialized reporting for full moon review analysis
- Additional mart models for specific business use cases

## Data Sources

Sources are defined in [models/sources.yml](models/sources.yml) and connect to raw database objects:

| Source | Schema | Table | Identifier |
|--------|--------|-------|------------|
| Airbnb | raw | listings | raw_listings |
| Airbnb | raw | hosts | raw_hosts |
| Airbnb | raw | reviews | raw_reviews |

**Freshness Check**: Review data has a 1-hour warning threshold for staleness

## Tests & Data Quality

### Generic Tests
Configured in [models/schema.yml](models/schema.yml):
- **unique**: Ensures primary key uniqueness
- **not_null**: Validates required fields
- **accepted_values**: Validates categorical values (room types)
- **relationships**: Enforces foreign key integrity
- **positive_values**: Custom test for numeric minimum value constraints

### Singular Tests
- **consistent_created_at.sql**: Validates that listing creation dates are before review dates
- **dim_listings_minimum_nights.sql**: Validates minimum night requirements
- **minimum_row_count.sql**: Ensures models return expected row counts

### Test Configuration
- Test failures are stored in the `__test_failures` schema for analysis
- Full test output available via `dbt test` command

## Custom Macros

Located in [macros/](macros/) directory:

- **logging.sql**: Implements audit logging for model transformations
- **no_empty_strings.sql**: Data quality check for empty strings
- **variables.sql**: Project-wide variable definitions
- **positive_values.sql**: Generic test for ensuring positive numeric values

## Packages

This project depends on:
- **dbt_utils** (v1.3.3): Provides utility macros like `generate_surrogate_key`

Install dependencies with: `dbt deps`

## Getting Started

### Prerequisites
- dbt installed (version compatible with this project)
- Access to Snowflake database
- Python virtual environment (if using venv)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd airbnb_dbt_project
```

2. Install dbt dependencies:
```bash
dbt deps
```

3. Set up database connection in [profiles.yml](profiles.yml) with your Snowflake credentials

### Running Models

Build all models in the project:
```bash
dbt run
```

Run specific model(s):
```bash
dbt run --select dim_listing_cleansed
dbt run --select dim,fct
```

Run incrementally (only new/changed data):
```bash
dbt run --select fct_reviews
```

Run with custom date parameters:
```bash
dbt run --select fct_reviews --vars '{"start_date": "2024-01-01", "end_date": "2024-01-31"}'
```

### Testing

Run all tests:
```bash
dbt test
```

Run tests for specific model:
```bash
dbt test --select dim_listing_cleansed
```

Run with failure reporting:
```bash
dbt test --store-failures
```

### Generating Documentation

Create and serve dbt documentation:
```bash
dbt docs generate
dbt docs serve
```

### Seed Data

Load reference data:
```bash
dbt seed
```

This loads static CSV files like `seed_full_moon_dates.csv` into the database.

### Snapshots

Create snapshots for slowly changing dimensions:
```bash
dbt snapshot
```

## Execution Flow

```
Raw Data (raw_*)
    ↓
Source Models (src_*)        [Ephemeral]
    ↓
Dimension Models (dim_*)     [Tables]
    ├── dim_hosts_cleansed
    ├── dim_listing_cleansed
    └── dim_listing_w_hosts_cleansed
    ↓
Fact Models (fct_*)          [Incremental]
    └── fct_reviews
    ↓
Mart Models (mart_*)         [Views]
    └── mart_fullmoon_reviews
    ↓
Reporting & Analysis
```

## Configuration

### dbt_project.yml
- **Project Name**: airbnb
- **Version**: 1.0.0
- **Profile**: airbnb
- **Default Materialization**: view (except where overridden)
- **Audit Logging**: Enabled - creates audit_log table on each run

Key configurations:
```yaml
models:
  dim:
    +materialized: table      # Dimension tables materialized as tables
  src:
    +materialized: ephemeral  # Source models ephemeral for efficiency
```

## Profile Configuration

Database connections are configured in [profiles.yml](profiles.yml). Update with your credentials before running dbt.

## Conventions & Best Practices

- **Naming**: 
  - `src_*` for source models
  - `dim_*` for dimension tables
  - `fct_*` for fact tables
  - `mart_*` for reporting tables

- **Materialization**:
  - Ephemeral: Source and intermediate models
  - Table: Dimension tables (frequently queried)
  - Incremental: Fact tables (large, append-only)
  - View: Mart models (join-friendly)

- **Testing**: Every primary key and foreign key relationship is tested

- **Documentation**: All models have descriptions in schema.yml

## Dependencies

```
dbt_utils (v1.3.3)
  └── Used for: surrogate_key_generation, SQL utilities
```

## Useful Resources

- [dbt Documentation](https://docs.getdbt.com/docs/introduction)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Discourse Community](https://discourse.getdbt.com/)
- [dbt Community Slack](https://community.slack.com/)

## Troubleshooting

### Profile Connection Issues
Ensure your Snowflake credentials are properly set in `profiles.yml` and the account/user/password are correct.

### Missing Dependencies
Run `dbt deps` to install package dependencies defined in `packages.yml`.

### Incremental Model Issues
For `fct_reviews`, ensure the table exists before running incremental loads. First run with `--full-refresh`:
```bash
dbt run --select fct_reviews --full-refresh
```

### Test Failures
Check the `__test_failures` schema for detailed failure information:
```bash
dbt test --store-failures
```

## Project Status

- Version: 1.0.0
- Status: Active
- Last Updated: January 2026

## Contributing

Follow dbt best practices when contributing:
1. Add tests for new models
2. Update documentation in schema.yml
3. Use appropriate materializations
4. Follow naming conventions
5. Ensure all tests pass before committing
