SELECT "id" AS 'ID', "first_name" AS 'First Name', "last_name" AS 'Last Name'
FROM "players"
WHERE "birth_country" = 'USA' AND "birth_state" = 'NY'
ORDER BY "id" ASC LIMIT 20;
