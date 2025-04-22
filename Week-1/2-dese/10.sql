SELECT "name", "per_pupil_expenditure"
FROM "expenditures"
JOIN "districts" ON "districts"."id" = "expenditures"."district_id"
WHERE "type" = 'Public School District'
ORDER BY "per_pupil_expenditure" DESC
LIMIT 10;
