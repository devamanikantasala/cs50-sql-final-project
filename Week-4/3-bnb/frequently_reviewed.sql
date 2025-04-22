CREATE VIEW "frequently_reviewed" AS
SELECT "listings"."id", "property_type", "host_name", "accommodates"
FROM "listings"
JOIN "reviews" ON "reviews"."listing_id" = "listings"."id"
GROUP BY "reviews"."listing_id"
ORDER BY COUNT("reviews"."id") DESC, "property_type", "host_name"
LIMIT 100;
