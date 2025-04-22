UPDATE "users" SET "password" = '982c0381c279d139fd221fce974916e7'
WHERE "username" LIKE 'admin';

DELETE FROM "user_logs"
WHERE "old_username" LIKE 'admin';

INSERT INTO "user_logs"("type", "old_username", "new_username", "old_password", "new_password")
SELECT 'update', "username", NULL, "password", (
    SELECT "password" FROM "users"
    WHERE "username" LIKE 'emily33'
) AS "emily-password"
FROM "users"
WHERE "username" LIKE 'admin';
