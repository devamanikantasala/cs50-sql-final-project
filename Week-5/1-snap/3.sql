SELECT "to_user_id" AS "user_id"FROM "messages"
JOIN "users" ON "users"."id" = "messages"."to_user_id"
WHERE "from_user_id" = (
    SELECT "id" FROM "users"
    WHERE "username" = 'creativewisdom377'
)
GROUP BY "to_user_id"
ORDER BY COUNT("to_user_id") DESC
LIMIT 3;
