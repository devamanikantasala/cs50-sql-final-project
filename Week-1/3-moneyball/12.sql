SELECT "first_name", "last_name"
FROM (
    SELECT "first_name", "last_name", "id"
    FROM (
        SELECT "first_name", "last_name", "players"."id" AS "id" FROM "performances"
        JOIN "players" ON "players"."id" = "performances"."player_id"
        JOIN "salaries" ON "salaries"."player_id" = "players"."id" AND "performances"."year" = "salaries"."year"
        WHERE "performances"."year" = 2001 AND "H" > 0
        ORDER BY "salary"/"H"
        LIMIT 10
    )

    INTERSECT

    SELECT "first_name", "last_name", "id"
    FROM (
        SELECT "first_name", "last_name", "players"."id" AS "id" FROM "performances"
        JOIN "players" ON "players"."id" = "performances"."player_id"
        JOIN "salaries" ON "salaries"."player_id" = "players"."id" AND "performances"."year" = "salaries"."year"
        WHERE "performances"."year" = 2001 AND "RBI" > 0
        ORDER BY "salary"/"RBI"
        LIMIT 10
    )
)
ORDER BY "id";
