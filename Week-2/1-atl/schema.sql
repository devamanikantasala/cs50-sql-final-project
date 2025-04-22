CREATE TABLE "passengers"(
    "id" INTEGER NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "age" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "airlines"(
    "id" INTEGER NOT NULL,
    "airline_name" TEXT NOT NULL,
    "concourse" TEXT NOT NULL CHECK("concourse" IN ('A', 'B', 'C', 'D', 'E', 'F', 'T')),
    PRIMARY KEY("id")
);

CREATE TABLE "flights"(
    "id" INTEGER NOT NULL,
    "airline_id" INTEGER NOT NULL,
    "flight_number" INTEGER NOT NULL,
    "airport_departing_from" TEXT NOT NULL,
    "expected_departure_time" DATETIME NOT NULL,
    "airport_heading_to" TEXT NOT NULL,
    "expected_arrival_time" DATETIME NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("airline_id") REFERENCES "airlines"("id")
);

CREATE TABLE "check_ins"(
    "id" INTEGER NOT NULL,
    "passenger_id" INTEGER NOT NULL,
    "datetime" DATETIME,
    "flight_id" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("passenger_id") REFERENCES "passengers"("id"),
    FOREIGN KEY("flight_id") REFERENCES "flights"("id")
);
