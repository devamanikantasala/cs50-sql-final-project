SELECT "title" FROM "episodes"
WHERE strftime('%m-%d', "air_date") -- referred it from w3schools
BETWEEN '12-01' AND '12-31'
ORDER BY "air_date";
