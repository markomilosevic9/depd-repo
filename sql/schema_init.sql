-- the script contains DDL SQL code for initialization of schemas and tables according to the task description


-- source schema for raw data coming from ATS
-- stores data in "as-is" format - may contain NULL values, duplicates and other data quality issues
CREATE SCHEMA IF NOT EXISTS source;

-- raw tables within source schema:

-- 1)
-- DDL for table source.raw_candidates
-- natural/composite key for later deduplication - full_name + source + profile_created_date
CREATE TABLE IF NOT EXISTS source.raw_candidates (candidate_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK
                                                  full_name VARCHAR(200),
                                                  source VARCHAR(100),
                                                  profile_created_date DATE
);

-- 2)
-- DDL for table source.raw_applications
-- natural/composite key for later deduplication - candidate_id + role_level + applied_date
CREATE TABLE IF NOT EXISTS source.raw_applications (app_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK
                                                    candidate_id BIGINT,
                                                    role_level VARCHAR(100),
                                                    applied_date DATE,
                                                    decision_date DATE,
                                                    expected_salary NUMERIC(12,2)
);

-- 3)
-- DDL for table source.raw_interviews
-- natural/composite key for later deduplication - app_id + interview_date + outcome
CREATE TABLE IF NOT EXISTS source.raw_interviews (interview_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK
                                                  app_id BIGINT,
                                                  interview_date DATE,
                                                  outcome VARCHAR(100)
);


-- dwh/datawarehouse schema 
CREATE SCHEMA IF NOT EXISTS dwh;

-- helper tables within dwh schema:

-- 1) 
-- DDL for table dwh.etl_runs
-- stores 1 row per pipeline execution
-- stores run_id used across dq_log to correlate all DQ issues that appears within a particular pipeline run
CREATE TABLE IF NOT EXISTS dwh.etl_runs (run_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK
                                         started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 2)
-- DDL for table dwh.dq_log
-- simple log of DQ issues found during pipeline runs
-- each unique issue is logged once when first detected - please see the documentation for further explanation
-- run_id records which pipeline run first detected the issue; detected_at is the corresponding timestamp
-- generally, it covers following 7 predefined/possible DQ issues (please see the documentation for more details)
CREATE TABLE IF NOT EXISTS dwh.dq_log (log_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- PK
                                       run_id BIGINT NOT NULL REFERENCES dwh.etl_runs(run_id), -- FK (captures which run first detected the issue)
                                       table_name VARCHAR(100) NOT NULL,
                                       record_id BIGINT,
                                       issue_type VARCHAR(50) NOT NULL CHECK (issue_type IN ('NULL_VALUE',
                                                                                             'INVALID_CATEGORY',
                                                                                             'DATE_LOGIC_ERROR',
                                                                                             'DATE_OUT_OF_RANGE',
                                                                                             'NEGATIVE_NUMBER',
                                                                                             'DUPLICATE',
                                                                                             'MISSING_FK')),
                                       detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       CONSTRAINT unique_dq_log_record_issue UNIQUE (table_name, record_id, issue_type)
);


-- staging tables within dwh schema:

-- 1)
-- DDL for table dwh.stg_candidates
-- natural/composite key for later deduplication - full_name + source + profile_created_date
CREATE TABLE IF NOT EXISTS dwh.stg_candidates (candidate_id BIGINT PRIMARY KEY, -- PK
                                               full_name VARCHAR(200) NOT NULL,
                                               source VARCHAR(100) NOT NULL,
                                               profile_created_date DATE NOT NULL,
                                               created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                               updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2)
-- DDL for table dwh.stg_applications
-- natural/composite key for later deduplication - canddidate_id + role_level + applied_date
CREATE TABLE IF NOT EXISTS dwh.stg_applications ( app_id BIGINT PRIMARY KEY, -- PK
                                                  candidate_id BIGINT NOT NULL REFERENCES dwh.stg_candidates (candidate_id), -- FK
                                                  role_level VARCHAR(100) NOT NULL CHECK (role_level IN ('Junior', 
                                                                                                         'Senior', 
                                                                                                         'Executive')),
                                                  applied_date DATE NOT NULL,
                                                  decision_date DATE,
                                                  expected_salary NUMERIC(12,2),
                                                  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  CONSTRAINT check_decision_after_applied CHECK (decision_date IS NULL OR decision_date >= applied_date)
);

-- 3)
-- DDL for table dwh.stg_interviews
-- natural/composite key for later deduplication - app_id + interview_date + outcome
CREATE TABLE IF NOT EXISTS dwh.stg_interviews (interview_id BIGINT PRIMARY KEY, -- PK
                                               app_id BIGINT NOT NULL REFERENCES dwh.stg_applications (app_id), -- FK
                                               interview_date DATE NOT NULL,
                                               outcome VARCHAR(100) NOT NULL CHECK (outcome IN ('Passed', 
                                                                                                'Rejected', 
                                                                                                'No Show')),
                                               created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                               updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- data mart table within dwh schema

-- DDL for table dwh.dm_hiring_process
-- stores 1 row per application
CREATE TABLE IF NOT EXISTS dwh.dm_hiring_process (app_id BIGINT PRIMARY KEY, -- PK
                                                  candidate_name VARCHAR(200) NOT NULL,
                                                  candidate_source VARCHAR(100) NOT NULL,
                                                  time_to_decision INTEGER, -- represents difference in days from applied_date to decision_date; NULL if still active
                                                  total_passed_interviews INTEGER NOT NULL DEFAULT 0,
                                                  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);