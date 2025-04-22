SELECT "first_name", "last_name", "salary" / "H" AS "dollars per hit" FROM "performances"
JOIN "players" ON "players"."id" = "performances"."player_id"
JOIN "salaries" ON "salaries"."player_id" = "players"."id" AND "performances"."year" = "salaries"."year"
WHERE "performances"."year" = 2001 AND "H" > 0
ORDER BY "dollars per hit", "first_name", "last_name"
LIMIT 10;
