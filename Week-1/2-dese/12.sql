SELECT "name", "per_pupil_expenditure", "exemplary"
FROM "expenditures"
JOIN "districts" ON "districts"."id" = "expenditures"."district_id"
JOIN "staff_evaluations" ON "staff_evaluations"."district_id" = "districts"."id"
WHERE "type" = 'Public School District' AND "per_pupil_expenditure" > (
    SELECT AVG("per_pupil_expenditure")
    FROM "expenditures"
) AND "exemplary" > (
    SELECT AVG("exemplary") FROM "staff_evaluations"
)
ORDER BY "exemplary" DESC, "per_pupil_expenditure" DESC;
