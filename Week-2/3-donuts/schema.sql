CREATE TABLE "ingredients"(
    "id" INTEGER,
    "name" TEXT UNIQUE NOT NULL,
    "cost_per_unit" REAL NOT NULL,
    "unit_type" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "donuts"(
    "id" INTEGER,
    "name" TEXT UNIQUE,
    "is_glutton_free" INTEGER CHECK("is_glutton_free" IN (0, 1)), --  0 indicates glutton-exists, 1 indicates glutton-free
    "price" REAL NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "donut_ingredients"(
    "donut_id" INTEGER,
    "ingredient_id" INTEGER,
    PRIMARY KEY("donut_id", "ingredient_id"),
    FOREIGN KEY("donut_id") REFERENCES "donuts"("id"),
    FOREIGN KEY("ingredient_id") REFERENCES "ingredients"("id")
);

CREATE TABLE "customers"(
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "orders"(
    "id" INTEGER,
    "customer_id" INTEGER,
    PRIMARY KEY("id", "customer_id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id")
);

CREATE TABLE "ordered_donuts"(
    "order_id" INTEGER,
    "donut_id" INTEGER,
    "quantity" INTEGER NOT NULL,
    PRIMARY KEY("order_id", "donut_id"),
    FOREIGN KEY("order_id") REFERENCES "orders"("id"),
    FOREIGN KEY("donut_id") REFERENCES "donuts"("id")
)
