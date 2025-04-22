CREATE TABLE "meteorites_temp"(
    "name" TEXT,
    "id" INTEGER,
    "nametype" TEXT,
    "class" TEXT,
    "mass" TEXT,
    "discovery" TEXT,
    "year" TEXT,
    "lat" TEXT,
    "long" TEXT,
    PRIMARY KEY("id")
);
.import --csv --skip 1 meteorites.csv meteorites_temp

--1. Setting NULL for any empty values for mass, year, lat, long
UPDATE "meteorites_temp"
SET "mass" = NULL
WHERE "mass" = '';

UPDATE "meteorites_temp"
SET "year" = NULL
WHERE "year" = '';

UPDATE "meteorites_temp"
SET "lat" = NULL
WHERE "lat" = '';

UPDATE "meteorites_temp"
SET "long" = NULL
WHERE "long" = '';

-- 2. Rounding the values of mass, lat, and long
UPDATE "meteorites_temp"
SET "mass" = ROUND("mass", 2),
"lat" = ROUND("lat", 2),
"long" = ROUND("long", 2);

-- 3. Removing data where nametype is Relict
DELETE FROM "meteorites_temp"
WHERE "nametype" LIKE 'relict';

-- 4. Ordering based on the year and name as instructed
-- 5. Auto generating ids for meteorites from 1 using primary-key constraint
CREATE TABLE "meteorites"(
    "id" INTEGER,
    "name" TEXT,
    "class" TEXT,
    "mass" REAL,
    "discovery" TEXT,
    "year" INTEGER,
    "lat" REAL,
    "long" REAL,
    PRIMARY KEY("id")
);

-- referred CAST() from w3schools : https://www.w3schools.com/sql/func_sqlserver_cast.asp

INSERT INTO "meteorites"("name", "class", "mass", "discovery", "year", "lat", "long")
SELECT "name", "class", "mass", "discovery", "year", "lat", "long" FROM "meteorites_temp"
ORDER BY CAST("year" AS INTEGER), "name";

DROP TABLE "meteorites_temp";
