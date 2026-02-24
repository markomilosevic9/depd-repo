-- incremental mock data sample

-- 1st batch - update existing source records
-- simulation of ATS sending final decisions for candidates that were still active after 1st pipeline run
-- updates propagate through staging to data mart on next pipeline execution

-- hired in the meantime
BEGIN;
UPDATE source.raw_applications
SET decision_date = '2025-01-15'
WHERE app_id = 12
;
COMMIT;

-- hired in the meantime
BEGIN;
UPDATE source.raw_applications
SET decision_date = '2025-01-20'
WHERE app_id = 13
;
COMMIT;

-- hired in the meantime 
BEGIN;
UPDATE source.raw_applications
SET decision_date = '2025-02-01'
WHERE app_id = 14
;
COMMIT;


-- 2nd batch - new candidates added to the pool
-- 3 clean records, 2 with predefined DQ issues
BEGIN;
INSERT INTO source.raw_candidates (full_name, source, profile_created_date)
VALUES ('Candidate Sixteen',   'LinkedIn',  '2025-01-03'),
       ('Candidate Seventeen', 'LinkedIn',   '2025-01-08'),
       ('Candidate Eighteen',  'Referral',   '2025-01-15'),
       -- predefined subset of data containing candidates with DQ issues
       (NULL,                  'Career Page', '2025-01-10'), -- predefined DQ issue - NULL full_name
       ('Candidate Twenty',    'LinkedIn',    '1990-06-01')  -- predefined DQ issue - DATE_OUT_OF_RANGE profile_created_date is unreasonable
;
COMMIT;


-- 3rd batch - new applications
-- mix of returning candidates applying for new roles and 1st time applicants, plus a subset with DQ issues
BEGIN;
INSERT INTO source.raw_applications (candidate_id, role_level, applied_date, decision_date, expected_salary)
VALUES (3,  'Junior',    '2025-01-05', NULL,         48000),  -- overlap
       -- predefined subset of data containing 1st time applicants
       (16, 'Senior',    '2025-01-08', '2025-02-15', 90000),
       (17, 'Junior',    '2025-01-10', NULL,          53000),
       (18, 'Executive', '2025-01-15', NULL,         148000),
       -- predefined subset of data containing records with DQ issues
       (3,  'Analyst',   '2025-01-20', NULL,          72000), -- predefined DQ issue - INVALID_CATEGORY role_level
       (16, 'Senior',    '2025-02-10', '2025-01-25',  91000), -- predefined DQ issue - DATE_LOGIC_ERROR decision date before applied date
       (17, 'Junior',    '1900-03-01', NULL,           53000), -- predefined DQ issue - DATE_OUT_OF_RANGE applied_date
       (18, 'Executive', '2025-01-20', NULL,          -8000)   -- predefined DQ issue - NEGATIVE_NUMBER expected_salary
;
COMMIT;


-- 4th batch - new interviews
-- interviews for apps that received decisions in 1st batch, interviews for new applications, and a subset with DQ issues
BEGIN;
INSERT INTO source.raw_interviews (app_id, interview_date, outcome)
VALUES (12, '2025-01-10', 'Passed'),
       (13, '2025-01-15', 'Passed'),
       (14, '2025-01-20', 'Passed'),
       (14, '2025-01-28', 'Passed'),
       (22, '2025-01-25', 'Passed'),
       -- predefined subset of data containing records with DQ issues
       (12,   '2025-01-10', 'Passed'),  -- predefined DQ issue - duplicate of first interview for app_id 12
       (23,   '2025-01-05', 'Passed'),  -- predefined DQ issue - DATE_LOGIC_ERROR interview date before applied_date
       (24,   '2025-01-20', 'Hired'),   -- predefined DQ issue - INVALID_CATEGORY outcome
       (8888, '2025-01-30', 'Passed'),  -- predefined DQ issue - MISSING_FK, non-existent app_id
       (22,   '2035-01-15', 'Passed')   -- predefined DQ issue - DATE_OUT_OF_RANGE interview_date
;
COMMIT;