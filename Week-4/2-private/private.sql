CREATE TABLE "triplets"(
    "sentence_id" INTEGER,
    "begin_index" INTEGER,
    "length" INTEGER,
    FOREIGN KEY("sentence_id") REFERENCES "sentences"("id")
);

INSERT INTO "triplets"("sentence_id", "begin_index", "length")
VALUES
(14, 98, 4),
(114, 3, 5),
(618, 72, 9),
(630, 7, 3),
(932, 12, 5),
(2230, 50, 7),
(2346, 44, 10),
(3041, 14, 5);

CREATE VIEW "message" AS
SELECT SUBSTR("sentence", "begin_index", "length") AS "phrase" FROM "triplets"
LEFT JOIN "sentences" ON "sentences"."id" = "triplets"."sentence_id";

SELECT "phrase" FROM "message";
