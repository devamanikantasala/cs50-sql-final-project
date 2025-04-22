SELECT "name" FROM "teams"
WHERE "id" IN (
    SELECT "team_id" FROM "performances"
    WHERE "player_id" = (
        SELECT "id" FROM "players"
        WHERE ("first_name" = 'Satchel' AND "last_name" = 'Paige') AND "birth_year" = 1906 -- reffered birth_year from given link to wikipedia
    )
);
