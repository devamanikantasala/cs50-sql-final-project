CREATE VIEW "june_vacancies" AS
SELECT "listings"."id", "property_type", "host_name", COUNT("date") AS "days_vacant"
FROM "listings"
JOIN "availabilities" ON "availabilities"."listing_id" = "listings"."id"
WHERE "date" LIKE '2023-06-%' AND "available" = 'TRUE'
GROUP BY "listings"."id";
