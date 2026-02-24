-- queries made per requirements in part B) of task description

-- for both queries, details about approach are provided in documentation file

-- query 1: monthly active pipeline
SELECT TO_CHAR(reporting_month, 'YYYY-MM') AS reporting_month,
       COUNT(*) AS active_applications
FROM (SELECT generate_series(DATE_TRUNC('month', applied_date), -- generate one row per calendar month (when the application was open)
                             DATE_TRUNC('month', COALESCE(decision_date, CURRENT_DATE)),
                             INTERVAL '1 month') AS reporting_month
      FROM dwh.stg_applications) AS month_hiring_activity
GROUP BY reporting_month
ORDER BY reporting_month
;

-- query 2: cumulative hires by source
WITH hires AS (SELECT dm.candidate_source,
                      DATE_TRUNC('month', a.decision_date) AS hire_month,
                      EXTRACT(YEAR FROM a.decision_date) AS hire_year
               FROM dwh.dm_hiring_process AS dm
               INNER JOIN dwh.stg_applications AS a
               ON a.app_id = dm.app_id
               WHERE a.decision_date IS NOT NULL
               AND dm.total_passed_interviews > 0),
monthly_hires AS (SELECT candidate_source,
                         hire_month,
                         hire_year,
                         COUNT(*) AS hires_this_month
                  FROM hires
                  GROUP BY candidate_source,
                           hire_month,
                           hire_year)
SELECT TO_CHAR(hire_month, 'YYYY-MM') AS hire_month,
       candidate_source,
       hires_this_month,
       SUM(hires_this_month) OVER (PARTITION BY candidate_source,
                                                hire_year
                                   ORDER BY hire_month) AS cumulative_hires
FROM monthly_hires
ORDER BY candidate_source,
         hire_month
;
