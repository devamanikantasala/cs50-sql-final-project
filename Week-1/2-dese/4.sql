SELECT "city" , COUNT("type") AS 'No.Of Public Schools' FROM "schools"
WHERE "type" = 'Public School'
GROUP BY "city"
ORDER BY "No.Of Public Schools" DESC, "city" ASC
LIMIT 10;
