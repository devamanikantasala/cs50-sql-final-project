SELECT COUNT("print_number") AS 'Prints by Hokusai that include Fuji in English title'
FROM "views" WHERE "artist" LIKE 'Hokusai' AND "english_title" LIKE '%Fuji%';
