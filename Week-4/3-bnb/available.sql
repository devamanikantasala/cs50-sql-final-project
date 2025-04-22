CREATE VIEW "available" AS
SELECT "listings"."id" AS "id", "property_type", "host_name", "availabilities"."date" AS "date"
FROM "listings"
JOIN "availabilities" ON "availabilities"."listing_id" = "listings"."id"
WHERE "availabilities"."available" = 'TRUE';
