-- Question : Write a query that lists all first five / atleast 5 episodes with their
-- titles, season number, episode number in season from each season
SELECT "title", "season", "episode_in_season"
FROM "episodes"
WHERE "episode_in_season" >= 1 AND "episode_in_season" <= 5;
