CREATE TABLE "users"(
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "user_name" TEXT NOT NULL UNIQUE,
    "passwords" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "schools"(
    "id" INTEGER,
    "school_name" TEXT NOT NULL UNIQUE,
    "type" TEXT NOT NULL,
    "location" TEXT,
    "founded_on" INTEGER,
    PRIMARY KEY("id")
);

CREATE TABLE "companies"(
    "id" INTEGER,
    "company_name" TEXT NOT NULL UNIQUE,
    "company_industry" TEXT NOT NULL,
    "location" TEXT,
    PRIMARY KEY("id")
);

CREATE TABLE "user_connections"(
    "person1_id" INTEGER,
    "person2_id" INTEGER,
    PRIMARY KEY("person1_id", "person2_id"),
    FOREIGN KEY("person1_id") REFERENCES "users"("id"),
    FOREIGN KEY("person2_id") REFERENCES "users"("id")
);

CREATE TABLE "school_connections"(
    "user_id" INTEGER,
    "school_id" INTEGER,
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC NOT NULL,
    "degree_type" TEXT NOT NULL,
    PRIMARY KEY("user_id", "school_id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("school_id") REFERENCES "schools"("id")
);

CREATE TABLE "company_connections"(
    "user_id" INTEGER,
    "company_id" INTEGER,
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC NOT NULL,
    "company_type" TEXT NOT NULL,
    PRIMARY KEY("user_id", "company_id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("company_id") REFERENCES "companies"("id")
);
