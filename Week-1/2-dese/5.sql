SELECT "city" , COUNT("type") AS 'No.Of Public Schools' FROM "schools"
WHERE "type" = 'Public School'
GROUP BY "city"
HAVING "No.Of Public Schools" <= 3
ORDER BY "No.Of Public Schools" DESC, "city" ASC;
