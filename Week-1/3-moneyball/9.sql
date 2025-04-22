SELECT "name", ROUND(AVG("salary"), 2) AS 'average salary'
FROM "salaries"
JOIN "teams" ON "teams"."id" = "salaries"."team_id"
WHERE "salaries"."year" = 2001
GROUP BY "team_id"
ORDER BY "average salary" ASC
LIMIT 5;
