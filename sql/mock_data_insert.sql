-- initial mock data sample


-- mock data insertion into source.raw_candidates
-- 15 records
-- 2 DQ issues: NULL source, NULL full_name
BEGIN;
INSERT INTO source.raw_candidates (full_name, source, profile_created_date)
VALUES ('Candidate One', 'LinkedIn', '2023-12-15'),
       ('Candidate Two', 'Referral', '2024-01-05'),
       ('Candidate Three', 'Career Page', '2024-01-10'),
       ('Candidate Four', 'LinkedIn', '2024-01-20'),
       ('Candidate Five', 'LinkedIn', '2024-02-01'),
       ('Candidate Six', 'Career Page', '2024-02-10'),
       ('Candidate Seven', 'Referral', '2024-03-05'),
       ('Candidate Eight', 'LinkedIn', '2024-04-10'),
       ('Candidate Nine', 'Career Page', '2024-05-01'),
       ('Candidate Ten', 'LinkedIn', '2024-06-15'),
       ('Candidate Eleven', 'LinkedIn', '2024-07-20'),
       ('Candidate Twelve', 'Referral', '2024-08-10'),
       -- predefined subset of data containing candidates with DQ issues
       ('Candidate Thirteen', NULL, '2024-09-01'), -- predefined DQ issue - NULL source
       (NULL, 'Career Page', '2024-09-15'), -- predefined DQ issue - NULL full_name
       ('Candidate Fifteen', 'LinkedIn', '2024-10-01')
;
COMMIT;


-- mock data insertion into source.raw_applications
-- 20 records
-- 5 DQ issues: invalid category, problematic DATEs, NULL values, missing FK
BEGIN;
INSERT INTO source.raw_applications (candidate_id, role_level, applied_date, decision_date, expected_salary)
VALUES (1, 'Senior', '2024-01-15', '2024-02-28', 95000),
       (2, 'Junior', '2024-01-20', '2024-03-05', 55000),
       (3, 'Executive', '2024-02-01', '2024-04-10', 150000),
       (5, 'Junior', '2024-02-15', '2024-03-20', 52000),
       (7, 'Senior', '2024-04-01', '2024-05-15', 88000),
       (9, 'Executive', '2024-06-10', '2024-08-05', 145000),
       (11, 'Senior', '2024-08-20', '2024-10-01', 93000),
       -- predefined subset of data containing candidates that will have rejected/no show interviews
       (4, 'Senior', '2024-02-10', '2024-03-10', 87000),
       (6, 'Junior', '2024-03-15', '2024-04-20', 53000),
       (8, 'Executive', '2024-05-05', '2024-06-15', 140000),
       (10, 'Junior', '2024-07-10', '2024-08-15', 51000),
       -- predefined subset of data containing candidates still in the hiring process
       (12, 'Senior', '2024-09-01', NULL, 94000),
       (15, 'Junior', '2024-10-10', NULL, 57000),
       (1, 'Executive', '2024-11-10', NULL, 160000), 
       (2, 'Senior', '2024-11-01', NULL, 87000), 
       -- predefined subset of data containing problematic records with DQ issues
       (4, 'Manager', '2024-02-10', '2024-03-15', 78000), -- predefined DQ issue - INVALID_CATEGORY role_level
       (6, 'Senior', '2024-04-01', '2024-03-15', 82000), -- predefined DQ issue - DATE_LOGIC_ERROR decision date before applied date
       (9999, 'Junior', '2024-03-20', '2024-04-25', 55000), -- predefined DQ issue - MISSING_FK so candidate_id references non-existent candidate
       (8, NULL, '2024-06-01', '2024-07-10', 60000), -- predefined DQ issue - NULL_VALUE role_level
       (10, 'Junior', NULL, '2024-08-20', 52000)  -- predefined DQ issue - NULL_VALUE applied_date
;
COMMIT;


-- mock data insertion into source.raw_interviews
-- 19 records
-- 5 DQ issues: duplicate, problematic DATE, invalid category, NULL value, missing FK
BEGIN;
INSERT INTO source.raw_interviews (app_id, interview_date, outcome)
VALUES (1, '2024-01-25', 'Passed'),
       (1, '2024-02-15', 'Passed'),
       (2, '2024-02-05', 'Passed'),
       (3, '2024-02-15', 'Passed'),
       (3, '2024-03-20', 'Passed'),
       (4, '2024-02-25', 'Passed'),
       (5, '2024-04-15', 'Passed'),
       (6, '2024-06-25', 'Passed'),
       (6, '2024-07-20', 'Passed'),
       (7, '2024-09-10', 'Passed'),
       -- predefined subset of data containing rejected/no show interviews
       (8, '2024-02-20', 'Rejected'),
       (9, '2024-03-28', 'No Show'),
       (10, '2024-05-20', 'Rejected'),
       (11, '2024-07-25', 'Rejected'),
       -- predefined subset of data containing records with DQ issues
       (1, '2024-01-25', 'Passed'),  -- predefined DQ issue - DUPLICATE of first interview for app_id 1
       (2, '2024-01-15', 'Passed'),  -- predefined DQ issue - DATE_LOGIC_ERROR interview before applied_date
       (5, '2024-04-10', 'Pending'), -- predefined DQ issue - INVALID_CATEGORY outcome
       (NULL, '2024-07-01', 'Passed'),  -- predefined DQ issue - NULL_VALUE, no app_id
       (9999, '2024-08-15', 'Passed')   -- predefined DQ issue - MISSING_FK, non-existent app_id
;
COMMIT;