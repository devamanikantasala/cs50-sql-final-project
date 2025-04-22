SELECT "artist" AS 'Artist Name', "english_title" AS 'Print Title', "brightness" AS 'Brightness <= 0.7'
FROM "views"
WHERE "brightness" <= 0.7 ORDER BY "brightness" ASC;
