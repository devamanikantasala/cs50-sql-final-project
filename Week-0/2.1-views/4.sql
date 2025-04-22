SELECT COUNT("print_number") AS 'Count of prints by Hiroshige with English Titles have Eastern Capital'
FROM "views"
WHERE "artist" = 'Hiroshige' AND "english_title" LIKE '%Eastern Capital%';
