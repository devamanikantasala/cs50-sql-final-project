SELECT "name", "proficient"
FROM "districts"
JOIN "staff_evaluations" ON "staff_evaluations"."district_id" = "districts"."id"
WHERE "type" = 'Public School District' AND "proficient" > (
    SELECT AVG("proficient") FROM "staff_evaluations"
)
ORDER BY "proficient" DESC
LIMIT 10;
-- through this query I answered my question - "What are the top 10 districts that has the highest proficient staff?"
