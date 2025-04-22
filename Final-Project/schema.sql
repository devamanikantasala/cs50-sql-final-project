-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Database System name: Neighbourly - Local Marketplace Support System

-- I) TABLES
-- I.A) Lookup tables
-- table - 1: 'locations': Table that holds the information about the locations where this system hubs operates and manages it operations so that it users can use it for digital collaboration with their customers and business owners
CREATE TABLE "locations"(
    "id" INTEGER,
    "municipality" TEXT NOT NULL UNIQUE,
    "district" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "pincode" TEXT NOT NULL CHECK(LENGTH("pincode") BETWEEN 4 AND 10),
    PRIMARY KEY("id")
);

-- table - 2: 'market_domains': Table that holds the information about the different domains of the businesses
CREATE TABLE "market_domains"(
    "id" INTEGER,
    "type" TEXT NOT NULL CHECK("type" IN ('product', 'service', 'both')),
    "domain" TEXT NOT NULL,
    PRIMARY KEY("id")
);

-- table - 3: 'order_statuses': Table that holds the types of statuses information for all products and services orders
CREATE TABLE "order_statuses"(
    "id" INTEGER,
    "type" TEXT NOT NULL CHECK("type" IN ('product','service','both')),
    "status" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

-- table - 4: 'payment_statuses': Table that holds the types of statuses information for all product and service orders payments
CREATE TABLE "payment_statuses"(
    "id" INTEGER,
    "status" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

-- table - 5: 'payment_modes': Table that holds the types of modes information that a payment was made through for a product or service order
CREATE TABLE "payment_modes"(
    "id" INTEGER,
    "mode" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

-- I.B) Core tables

-- table - 6: 'users': Table that holds the information of every user, the user can be a customer, business_owner, and delivery_agent.
CREATE TABLE "users"(
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE CHECK(LENGTH("username") BETWEEN 8 AND 15),
    "password" TEXT NOT NULL CHECK(LENGTH("password") BETWEEN 8 AND 12),
    "age" INTEGER NOT NULL CHECK("age" >= 13 AND "age" <= 65),
    "gender" TEXT NOT NULL CHECK("gender" IN ('MALE','FEMALE','OTHER')),
    "phone" TEXT NOT NULL UNIQUE CHECK(LENGTH("phone") BETWEEN 13 AND 15 AND ("phone" LIKE '+%-%')),
    "email" TEXT DEFAULT NULL UNIQUE CHECK("email" IS NULL OR ("email" LIKE '%@%.%' AND LENGTH("email") >= 15)),
    "address" TEXT NOT NULL,
    "location_id" INTEGER NOT NULL,
    "user_role" TEXT NOT NULL CHECK("user_role" IN ('customer', 'business_owner', 'delivery_agent')),
    PRIMARY KEY("id"),
    FOREIGN KEY("location_id") REFERENCES "locations"("id")
    ON DELETE CASCADE
);

-- table - 7: 'businesses': Table that holds the basic info. of a business
CREATE TABLE "businesses"(
    "id" INTEGER,
    "owner_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL UNIQUE,
    "address" TEXT NOT NULL,
    "location_id" INTEGER NOT NULL,
    "open_time" NUMERIC NOT NULL DEFAULT '08:00',
    "close_time" NUMERIC NOT NULL DEFAULT '20:00',
    PRIMARY KEY("id"),
    FOREIGN KEY("owner_id") REFERENCES "users"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("location_id") REFERENCES "locations"("id")
    ON DELETE CASCADE
);

-- table - 8: 'business_associations': [associative-table] Table that holds the information which business belongs to which domain
CREATE TABLE "business_associations"(
    "business_id" INTEGER NOT NULL,
    "domain_id" INTEGER,
    PRIMARY KEY("business_id", "domain_id"),
    FOREIGN KEY("business_id") REFERENCES "businesses"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("domain_id") REFERENCES "market_domains"("id")
    ON DELETE SET NULL
);

-- table - 9: 'products': Table that holds the information of the product's name, owner info., etc details
CREATE TABLE "products"(
    "id" INTEGER,
    "business_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "category_id" INTEGER NOT NULL DEFAULT 0,
    UNIQUE("business_id", "name"),
    PRIMARY KEY("id"),
    FOREIGN KEY("business_id") REFERENCES "businesses"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("category_id") REFERENCES "market_domains"("id")
    ON DELETE SET DEFAULT
);

-- table - 10: 'product_models': Table that holds the information about the certain product's model.
CREATE TABLE "product_models"(
    "id" INTEGER,
    "product_id" INTEGER NOT NULL,
    "size" TEXT DEFAULT NULL,
    "color" TEXT DEFAULT NULL,
    "weight_kg" REAL CHECK("weight_kg" BETWEEN 0.001 AND 1000.0) DEFAULT NULL,
    "material" TEXT DEFAULT NULL,
    "price" REAL NOT NULL CHECK("price" >= 1.0),
    "available_stock" INTEGER NOT NULL DEFAULT 0 CHECK("available_stock" >= 0),
    "min_order_qty" INTEGER NOT NULL DEFAULT 1 CHECK("min_order_qty" >= 1),
    "mfg_date" NUMERIC DEFAULT CURRENT_DATE,
    "exp_date" NUMERIC DEFAULT NULL,
    UNIQUE("product_id", "size", "color", "weight_kg", "material", "price", "mfg_date", "exp_date"),
    PRIMARY KEY("id"),
    FOREIGN KEY("product_id") REFERENCES "products"("id")
    ON DELETE CASCADE
);

-- table - 11: 'user_carts': Table that holds the information of user's cart that allow user to order 1 or more than a product at a time.
CREATE TABLE "user_carts"(
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "ordered_on" NUMERIC DEFAULT NULL,
    "status_id" INTEGER NOT NULL DEFAULT 0,
    "delivery_agent_id" INTEGER DEFAULT 0,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("status_id") REFERENCES "order_statuses"("id")
    ON DELETE SET DEFAULT, -- I used this to set default value 0 as the id - 0 for order status, states the deleted status in referenced table
    FOREIGN KEY("delivery_agent_id") REFERENCES "users"("id")
    ON DELETE SET NULL -- whenever a delivery_agent from users quits it places NULL, and default 0 for the delivery_agent_id indicates picking ordered carts by user himself as this DB-System designed for local market place support
);

-- table - 12: 'product_orders': Table that holds the information of the each cart contains which product_model of a product that is ordered via user's cart
CREATE TABLE "product_orders"(
    "id" INTEGER,
    "cart_id" INTEGER NOT NULL,
    "product_model_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL DEFAULT 1 CHECK("qty" >= 1),
    "price_at_order" REAL NOT NULL CHECK("price_at_order" > 0),
    PRIMARY KEY("id"),
    FOREIGN KEY("cart_id") REFERENCES "user_carts"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("product_model_id") REFERENCES "product_models"("id")
    ON DELETE CASCADE
);

-- table - 13: 'cart_payments': Table that holds the information about cart_payment's statuses, recorded on, date-paid on etc.
CREATE TABLE "cart_payments"(
    "id" INTEGER,
    "cart_id" INTEGER NOT NULL,
    "total_price" REAL NOT NULL CHECK("total_price" > 0),
    "status_id" INTEGER NOT NULL DEFAULT 0,
    "mode_id" INTEGER NOT NULL DEFAULT 1,
    "paid_on" NUMERIC DEFAULT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("cart_id") REFERENCES "user_carts"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("status_id") REFERENCES "payment_statuses"("id")
    ON DELETE SET DEFAULT, -- I used default value to be set as 0 in which it references to the deleted payment-status!
    FOREIGN KEY("mode_id") REFERENCES "payment_modes"("id")
    ON DELETE SET DEFAULT -- I used default value to be set as 1 in which it references to the cash-mode! When a mode in referenced table is deleted!
);

-- table - 14: 'product_ratings': Table that holds the ratings of the product that ordered by the user, if user given rating on it.
CREATE TABLE "product_ratings"(
    "user_id" INTEGER NOT NULL,
    "product_model_id" INTEGER NOT NULL,
    "rating" REAL NOT NULL CHECK("rating" BETWEEN 1.00 AND 5.00),
    "comment" TEXT DEFAULT NULL CHECK(LENGTH("comment") <= 100),
    "rated_on" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("user_id", "product_model_id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("product_model_id") REFERENCES "product_models"("id")
    ON DELETE CASCADE
);

-- table - 15: 'services': Table that holds the information about all services provided by the businesses
CREATE TABLE "services"(
    "id" INTEGER,
    "business_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "category_id" INTEGER NOT NULL DEFAULT 0,
    "availability" BOOLEAN NOT NULL CHECK("availability" IN (0, 1)),
    "available_slots" INTEGER NOT NULL CHECK("available_slots" >= 5),
    "price" REAL NOT NULL CHECK("price" > 0),
    "est_wrk_dur_hrs" REAL NOT NULL CHECK("est_wrk_dur_hrs" >= ROUND(10.0/60.0, 4)),
    UNIQUE("business_id", "name"),
    PRIMARY KEY("id"),
    FOREIGN KEY("business_id") REFERENCES "businesses"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("category_id") REFERENCES "market_domains"("id")
    ON DELETE SET DEFAULT
);

-- table - 16: 'service_orders': Table that holds the information about the services that are ordered by users
CREATE TABLE "service_orders"(
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "service_id" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL DEFAULT 1 CHECK("qty" >= 1 AND "qty" <= 5),
    "price_at_order" REAL NOT NULL CHECK("price_at_order" > 0),
    "ordered_on" NUMERIC DEFAULT NULL,
    "status_id" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("service_id") REFERENCES "services"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("status_id") REFERENCES "order_statuses"("id")
    ON DELETE SET DEFAULT -- same as user_carts!
);

-- table - 17: 'service_payments': Table that holds the information about the services payments - statuses, date-paid on etc.
CREATE TABLE "service_payments"(
    "id" INTEGER,
    "service_order_id" INTEGER NOT NULL,
    "price" REAL NOT NULL CHECK("price" > 0),
    "status_id" INTEGER NOT NULL DEFAULT 0,
    "mode_id" INTEGER NOT NULL DEFAULT 1,
    "paid_on" NUMERIC DEFAULT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("service_order_id") REFERENCES "service_orders"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("status_id") REFERENCES "payment_statuses"("id")
    ON DELETE SET DEFAULT, -- same as cart_payments
    FOREIGN KEY("mode_id") REFERENCES "payment_modes"("id")
    ON DELETE SET DEFAULT -- same as cart_payments
);

-- table - 18: 'service_ratings': Table that holds the information of the ratings for the services that they ordered.
CREATE TABLE "service_ratings"(
    "user_id" INTEGER NOT NULL,
    "service_id" INTEGER NOT NULL,
    "rating" REAL NOT NULL CHECK("rating" BETWEEN 1.00 AND 5.00),
    "comment" TEXT DEFAULT NULL CHECK(LENGTH("comment") <= 100),
    "rated_on" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("user_id", "service_id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
    ON DELETE CASCADE,
    FOREIGN KEY("service_id") REFERENCES "services"("id")
    ON DELETE CASCADE
);

-- table - 19: 'logs': Table that holds the logs of all tables above
CREATE TABLE "logs"(
    "id" INTEGER,
    "record_id" INTEGER NOT NULL,
    "table" TEXT NOT NULL CHECK("table" IN ('users', 'businesses', 'products', 'product_models', 'services', 'user_carts', 'product_orders', 'service_orders', 'cart_payments', 'service_payments', 'product_ratings', 'service_ratings')),
    "operation" TEXT NOT NULL CHECK("operation" IN ('INSERT', 'UPDATE', 'DELETE')),
    "column" TEXT DEFAULT NULL,
    "old_value" TEXT DEFAULT NULL,
    "new_value" TEXT DEFAULT NULL,
    "description" TEXT NOT NULL,
    "timestamp" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id")
);
-- II. VIEWS

-- View-1: Number of users for each location seperated by roles
CREATE VIEW "users_in_locations" AS
SELECT "id", "municipality", "country", "pincode",
IFNULL("customers"."count", 0) AS "no_of_customers",
IFNULL("business_owners"."count", 0) AS "no_of_business_owners",
IFNULL("delivery_agents"."count", 0) AS "no_of_delivery_agents",
(
    IFNULL("customers"."count", 0) +
    IFNULL("business_owners"."count", 0) +
    IFNULL("delivery_agents"."count", 0)
) AS "no_of_users"
FROM "locations"
LEFT JOIN (
    SELECT "location_id", COUNT("id") AS "count"
    FROM "users"
    WHERE "user_role" = 'customer'
    GROUP BY "location_id"
) "customers" ON "customers"."location_id" = "locations"."id"
LEFT JOIN (
    SELECT "location_id", COUNT("id") AS "count"
    FROM "users"
    WHERE "user_role" = 'business_owner'
    GROUP BY "location_id"
) "business_owners" ON "business_owners"."location_id" = "locations"."id"
LEFT JOIN (
    SELECT "location_id", COUNT("id") AS "count"
    FROM "users"
    WHERE "user_role" = 'delivery_agent'
    GROUP BY "location_id"
) "delivery_agents" ON "delivery_agents"."location_id" = "locations"."id";

-- View-2: Detailed View that covers Every Customers details by JOINS
CREATE VIEW "customers_info" AS
SELECT "users"."id" AS "customer_id",
"users"."name"  AS "name",
"users"."username" AS "username",
"users"."age" AS "age",
"users"."gender" AS "gender",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode"
FROM "users"
LEFT JOIN "locations" ON "locations"."id" = "users"."location_id"
WHERE "users"."user_role" = 'customer';

-- View-3: Detailed View that covers Every Business Owners details by JOINS
CREATE VIEW "business_owners_info" AS
SELECT "users"."id" AS "business_owner_id",
"users"."name"  AS "name",
"users"."username" AS "username",
"users"."age" AS "age",
"users"."gender" AS "gender",
"businesses"."name" AS "business_name",
CONCAT('Open:[',"businesses"."open_time",']|Close:[',"businesses"."close_time",']') AS "working_hours",
"businesses"."address" AS "business_address",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode"
FROM "users"
LEFT JOIN "locations" ON "locations"."id" = "users"."location_id"
RIGHT JOIN "businesses" ON "businesses"."owner_id" = "users"."id"
WHERE "users"."user_role" = 'business_owner';

-- View-4: Number of Businesses owned by a Business Owner (uses view-3, can also be used as TEMPORARY VIEW)
CREATE VIEW "businesses_count_per_owner" AS
SELECT "business_owner_id", "name", COUNT(*) AS "no_of_businesses_owned"
FROM "business_owners_info" --used the view-3
GROUP BY "business_owner_id"
ORDER BY "business_owner_id" ASC;

-- View-5: Detailed View that covers Every Delivery Agents details by JOINS
CREATE VIEW "delivery_agents_info" AS
SELECT "users"."id" AS "delivery_agent_id",
"users"."name" AS "name",
"users"."username" AS "username",
"users"."age" AS "age",
"users"."gender" AS "gender",
"users"."phone" AS "phone",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
IFNULL("deliveries"."no_of_deliveries_dealed", 0) AS "orders_dealed"
FROM "users"
LEFT JOIN "locations" ON "locations"."id" = "users"."location_id"
LEFT JOIN (
    SELECT "delivery_agent_id", COUNT(*) AS "no_of_deliveries_dealed"
    FROM "user_carts"
    WHERE "delivery_agent_id" != 0
    GROUP BY "delivery_agent_id"
) "deliveries" ON "deliveries"."delivery_agent_id" = "users"."id"
WHERE "users"."user_role" = 'delivery_agent' AND "users"."id" != 0
ORDER BY "orders_dealed" DESC, "locations"."id" ASC;

-- View-6: Detailed View that covers Every Products details by JOINS
CREATE VIEW "products_info" AS
SELECT "businesses"."id" AS "business_id",
"businesses"."name" AS "business_name",
"users"."name" AS "owner_name",
"products"."id" AS "product_id",
"products"."name" AS "product_name",
"market_domains"."domain" AS "domain",
"product_models_info"."model_ids" AS "model_ids",
"product_models_info"."no_of_models" AS "no_of_models"
FROM "products"
LEFT JOIN "businesses" ON "businesses"."id" = "products"."business_id"
LEFT JOIN "users" ON "businesses"."owner_id" = "users"."id"
LEFT JOIN "market_domains" ON "products"."category_id" = "market_domains"."id"
LEFT JOIN (
    SELECT "product_id",
    IFNULL(COUNT(*),0) AS "no_of_models",
    IFNULL(GROUP_CONCAT("id"),'no-models') AS "model_ids"
    FROM "product_models"
    GROUP BY "product_id"
    ORDER BY "product_id" ASC
) "product_models_info" ON "products"."id" = "product_models_info"."product_id"
ORDER BY "businesses"."id" ASC;

-- View-7: Detailed View that covers Every Services details by JOINS
CREATE VIEW "services_info" AS
SELECT "businesses"."id" AS "business_id",
"businesses"."name" AS "business_name",
"users"."name" AS "owner_name",
"services"."id" AS "service_id",
"services"."name" AS "service_name",
"market_domains"."domain" AS "domain",
"services"."price" AS "service_price",
"services"."est_wrk_dur_hrs" AS "work_duration_hrs",
"services"."available_slots" AS "available_slots"
FROM "services"
LEFT JOIN "businesses" ON "businesses"."id" = "services"."business_id"
LEFT JOIN "users" ON "businesses"."owner_id" = "users"."id"
LEFT JOIN "market_domains" ON "services"."category_id" = "market_domains"."id";

-- View-8: Count of Product Orders made by every user
CREATE VIEW "users_product_orders_count" AS
SELECT "user_carts"."user_id" AS "user_id",
"users"."username" AS "username",
COUNT(*) AS "placed_orders_count"
FROM "user_carts"
LEFT JOIN "users" ON "users"."id" = "user_carts"."user_id"
WHERE "user_carts"."ordered_on" IS NOT NULL
AND "user_carts"."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-delivered', 'cart-order-self-pick-up', 'cart-order-returned')
)
GROUP BY "user_id";

-- View-9: Detailed View that covers Every User's Cart details by JOINS
CREATE VIEW "user_carts_info" AS
SELECT "user_carts"."id" AS "cart_id",
"users"."username" AS "username",
IFNULL("user_carts"."ordered_on", 'yet-to-be-ordered') AS "ordered_date",
"order_statuses"."status" AS "order_status",
"payment_statuses"."status" AS "payment_status",
"payment_modes"."mode" AS "payment_mode",
"cart_payments"."total_price" AS "cart_price",
CASE
    WHEN "delivery_agent_id" != 0 AND "delivery_agent_id" IS NOT NULL
        THEN "delivery_agents"."username"
    WHEN "delivery_agent_id" IS NULL
        THEN 'delivery_agent_removed'
    ELSE 'self-pick'
END AS "delivery_agent_username"
FROM "user_carts"
LEFT JOIN "users" ON "users"."id" = "user_carts"."user_id"
LEFT JOIN "order_statuses" ON "user_carts"."status_id" = "order_statuses"."id"
LEFT JOIN (
    SELECT "id", "username" FROM "users"
    WHERE "user_role" = 'delivery_agent'
) "delivery_agents" ON "delivery_agents"."id" = "user_carts"."delivery_agent_id"
LEFT JOIN "cart_payments" ON "cart_payments"."cart_id" = "user_carts"."id"
LEFT JOIN "payment_statuses" ON "payment_statuses"."id" = "cart_payments"."status_id"
LEFT JOIN "payment_modes" ON "payment_modes"."id" = "cart_payments"."mode_id";

-- View-10: Count of Services Orders by users count
CREATE VIEW "users_service_orders_count" AS
SELECT "service_orders"."user_id" AS "user_id",
"users"."username" AS "username",
IFNULL(COUNT(*), 0) AS "placed_orders_count"
FROM "service_orders"
LEFT JOIN "users" ON "users"."id" = "service_orders"."user_id"
WHERE "service_orders"."ordered_on" IS NOT NULL
AND "service_orders"."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-completed', 'service-order-in-progress')
)
GROUP BY "user_id";

-- View-11: Detailed View that covers Ordered Services by every user by JOINS
CREATE VIEW "service_orders_info" AS
SELECT "service_orders"."id" AS "order_id",
"users"."username" AS "username",
"services"."name" AS "service_name",
"service_orders"."qty" AS "quantity",
"service_orders"."price_at_order" AS "price",
IFNULL("service_orders"."ordered_on", 'yet-to-be-ordered') AS "ordered_date",
"order_statuses"."status" AS "order_status",
"payment_statuses"."status" AS "payment_status",
"payment_modes"."mode" AS "payment_mode",
"service_payments"."price" AS "service_price"
FROM "service_orders"
LEFT JOIN "users" ON "users"."id" = "service_orders"."user_id"
LEFT JOIN "services" ON "services"."id" = "service_orders"."service_id"
LEFT JOIN "order_statuses" ON "service_orders"."status_id" = "order_statuses"."id"
LEFT JOIN "service_payments" ON "service_payments"."service_order_id" = "service_orders"."id"
LEFT JOIN "payment_statuses" ON "service_payments"."status_id" = "payment_statuses"."id"
LEFT JOIN "payment_modes" ON "service_payments"."mode_id" = "payment_modes"."id";

-- View-12: Product based businesses information
CREATE VIEW "product_based_businesses" AS
SELECT "businesses"."name" AS "business_name",
"users"."name" AS "owner_name",
"market_domains"."type" AS "business_type",
"businesses"."address" AS "address",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
GROUP_CONCAT("market_domains"."domain") AS "domain_names",
CONCAT('Open:[',"businesses"."open_time",'] Close:[',
"businesses"."close_time",']') AS "working_hours"
FROM "business_associations"
LEFT JOIN "market_domains" ON "market_domains"."id" = "business_associations"."domain_id"
LEFT JOIN "businesses" ON "businesses"."id" = "business_associations"."business_id"
LEFT JOIN "locations" ON "locations"."id" = "businesses"."location_id"
LEFT JOIN "users" ON "users"."id" = "businesses"."owner_id"
WHERE "market_domains"."type" = 'product'
GROUP BY "businesses"."id";

-- View-13: Service based businesses information
CREATE VIEW "service_based_businesses" AS
SELECT "businesses"."name" AS "business_name",
"users"."name" AS "owner_name",
"market_domains"."type" AS "business_type",
"businesses"."address" AS "address",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
GROUP_CONCAT("market_domains"."domain") AS "domain_names",
CONCAT('Open:[',"businesses"."open_time",'] Close:[',
"businesses"."close_time",']') AS "working_hours"
FROM "business_associations"
LEFT JOIN "market_domains" ON "market_domains"."id" = "business_associations"."domain_id"
LEFT JOIN "businesses" ON "businesses"."id" = "business_associations"."business_id"
LEFT JOIN "locations" ON "locations"."id" = "businesses"."location_id"
LEFT JOIN "users" ON "users"."id" = "businesses"."owner_id"
WHERE "market_domains"."type" = 'service'
GROUP BY "businesses"."id";

-- View-14: Detailed View of different market_domains available in each location
CREATE VIEW "market_domains_by_locations" AS
SELECT "id" AS "location_id",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
IFNULL(GROUP_CONCAT(DISTINCT "product_based_business_categories"."domain"), 'no-domains') AS "product_based_business_domains",
IFNULL(GROUP_CONCAT(DISTINCT "service_based_business_categories"."domain"), 'no-domains') AS "service_based_business_domains"
FROM "locations"
LEFT JOIN (
    SELECT "businesses"."id" AS "business_id",
    "businesses"."name" AS "business_name",
    "market_domains"."domain" AS "domain",
    "market_domains"."type" AS "type",
    "locations"."id" AS "location_id"
    FROM "business_associations"
    LEFT JOIN "market_domains" ON "business_associations"."domain_id" = "market_domains"."id"
    LEFT JOIN "businesses" ON "business_associations"."business_id" = "businesses"."id"
    LEFT JOIN "locations" ON "locations"."id" = "businesses"."location_id"
    WHERE "market_domains"."type" = 'product'
) "product_based_business_categories" ON "product_based_business_categories"."location_id" = "locations"."id"
LEFT JOIN (
    SELECT "businesses"."id" AS "business_id",
    "businesses"."name" AS "business_name",
    "market_domains"."domain" AS "domain",
    "market_domains"."type" AS "type",
    "locations"."id" AS "location_id"
    FROM "business_associations"
    LEFT JOIN "market_domains" ON "business_associations"."domain_id" = "market_domains"."id"
    LEFT JOIN "businesses" ON "business_associations"."business_id" = "businesses"."id"
    LEFT JOIN "locations" ON "locations"."id" = "businesses"."location_id"
    WHERE "market_domains"."type" = 'service'
) "service_based_business_categories" ON "service_based_business_categories"."location_id" = "locations"."id"
GROUP BY "locations"."municipality"
ORDER BY "locations"."id";

-- View-15: Detailed View that gives all available products in each location
CREATE VIEW "available_products_by_locations" AS
SELECT "locations"."id" AS "location_id",
"locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
IFNULL(GROUP_CONCAT(DISTINCT "product_name"), 'No products yet!') AS "products_available"
FROM "locations"
LEFT JOIN (
    SELECT "products"."name" AS "product_name",
    "businesses"."location_id" AS "location_id"
    FROM "products"
    LEFT JOIN "businesses" ON "products"."business_id" = "businesses"."id"
)"available_products" ON "locations"."id" = "available_products"."location_id"
GROUP BY "locations"."id"
ORDER BY "location_id";

-- View-16: Detailed View that gives all available services in each location
CREATE VIEW "available_services_by_locations" AS
SELECT "locations"."id" AS "location_id","locations"."municipality" AS "municipality",
"locations"."country" AS "country", "locations"."pincode" AS "pincode",
IFNULL(GROUP_CONCAT(DISTINCT "service_name"), 'No services yet!') AS "services_available"
FROM "locations"
LEFT JOIN (
    SELECT "services"."name" AS "service_name", "businesses"."location_id" FROM "services"
    LEFT JOIN "businesses" ON "services"."business_id" = "businesses"."id"
    WHERE "services"."availability" <> 0
)"available_services" ON "locations"."id" = "available_services"."location_id"
GROUP BY "locations"."id"
ORDER BY "location_id";

-- View-17: Detailed View that gives all products average rating and no.of.ratings given, who owns it etc.
CREATE VIEW "products_ratings_summary" AS
SELECT "businesses"."id" AS "business_id",
"users"."name" AS "owner_name",
"businesses"."name" AS "business_name",
"products"."id" AS "product_id",
"products"."name" AS "product_name",
IFNULL(AVG("product_ratings"."rating"),0.0) AS "average_rating",
IFNULL(COUNT("product_ratings"."rating"), 0) AS "no_of_ratings",
"market_domains"."type" AS "business_type"
FROM "product_ratings"
RIGHT JOIN "product_models" ON "product_models"."id" = "product_ratings"."product_model_id"
RIGHT JOIN "products" ON "products"."id" = "product_models"."product_id"
RIGHT JOIN "businesses" ON "businesses"."id" = "products"."business_id"
LEFT JOIN "business_associations" ON "businesses"."id" = "business_associations"."business_id"
LEFT JOIN "market_domains" ON "business_associations"."domain_id" = "market_domains"."id"
LEFT JOIN "users" ON "businesses"."owner_id" = "users"."id"
GROUP BY "products"."id"
HAVING "products"."id" IS NOT NULL AND "products"."name" IS NOT NULL
ORDER BY "businesses"."id", "products"."id";

-- View-18: Detailed View that gives all services average rating and no.of.ratings given, who provides it etc.
CREATE VIEW "services_ratings_summary" AS
SELECT "businesses"."id" AS "business_id",
"users"."name" AS "owner_name",
"businesses"."name" AS "business_name",
"services"."id" AS "service_id",
"services"."name" AS "service_name",
IFNULL(AVG("service_ratings"."rating"),0.0) AS "average_rating",
IFNULL(COUNT("service_ratings"."rating"), 0) AS "no_of_ratings",
"market_domains"."type" AS "business_type"
FROM "service_ratings"
RIGHT JOIN "services" ON "services"."id" = "service_ratings"."service_id"
RIGHT JOIN "businesses" ON "businesses"."id" = "services"."business_id"
LEFT JOIN "business_associations" ON "businesses"."id" = "business_associations"."business_id"
LEFT JOIN "market_domains" ON "business_associations"."domain_id" = "market_domains"."id"
LEFT JOIN "users" ON "businesses"."owner_id" = "users"."id"
GROUP BY "services"."id"
HAVING "services"."id" IS NOT NULL AND "services"."name" IS NOT NULL
ORDER BY "businesses"."id", "services"."id";

-- View-19: Detailed View that gives information about payments pending for cart orders.
CREATE VIEW "pending_cart_order_payments" AS
SELECT "users"."username" AS "username",
"cart_payments"."cart_id" AS "cart_id",
'pending' AS "payment_status",
'product' AS "type"
FROM "cart_payments"
LEFT JOIN "payment_statuses" ON "cart_payments"."status_id" = "payment_statuses"."id"
LEFT JOIN "payment_modes" ON "cart_payments"."mode_id" = "payment_modes"."id"
LEFT JOIN "user_carts" ON "cart_payments"."cart_id" = "user_carts"."id"
LEFT JOIN "users" ON "user_carts"."user_id" = "users"."id"
WHERE "cart_payments"."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" LIKE 'pending'
);

-- View-20: Detailed View that gives information about payments pending for service orders.
CREATE VIEW "pending_service_order_payments" AS
SELECT "users"."username" AS "username",
"service_payments"."service_order_id" AS "order_id",
'pending' AS "payment_status",
'service' AS "type"
FROM "service_payments"
LEFT JOIN "payment_statuses" ON "service_payments"."status_id" = "payment_statuses"."id"
LEFT JOIN "payment_modes" ON "service_payments"."mode_id" = "payment_modes"."id"
LEFT JOIN "service_orders" ON "service_payments"."service_order_id" = "service_orders"."id"
LEFT JOIN "users" ON "service_orders"."user_id" = "users"."id"
WHERE "service_payments"."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" LIKE 'pending'
);

-- View-21: Detailed View that gives information about users who placed orders in their carts the last 30 days.
CREATE VIEW "active_users_summary_cart_orders" AS
SELECT "join-1"."username" AS "username",
"user_carts"."id" AS "cart_id",
"user_carts"."ordered_on" AS "ordered_on",
IFNULL("join-2"."username", 'delivery-agent-not-assigned') AS "delivery_agent_username",
"order_statuses"."status" AS "order_status"
FROM "user_carts"
LEFT JOIN "order_statuses" ON "order_statuses"."id" = "user_carts"."status_id"
LEFT JOIN "users" "join-1" ON "join-1"."id" = "user_carts"."user_id"
LEFT JOIN "users" "join-2" ON "join-2"."id" = "user_carts"."delivery_agent_id"
WHERE DATE("ordered_on") >= DATE('now', '-30 days')
AND DATE("ordered_on") <= DATE('now')
AND "user_carts"."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN (
        'cart-order-confirmed',
        'cart-order-out-for-delivery',
        'cart-order-delivered',
        'cart-order-self-pick-up'
    )
);

-- View-22: Detailed View that gives information about users who placed service orders in last 30 days.
CREATE VIEW "active_users_summary_service_orders" AS
SELECT "join-1"."username" AS "username",
"service_orders"."id" AS "cart_id",
"service_orders"."ordered_on" AS "ordered_on",
"order_statuses"."status" AS "order_status"
FROM "service_orders"
LEFT JOIN "order_statuses" ON "order_statuses"."id" = "service_orders"."status_id"
LEFT JOIN "users" "join-1" ON "join-1"."id" = "service_orders"."user_id"
WHERE DATE("ordered_on") >= DATE('now', '-30 days')
AND DATE("ordered_on") <= DATE('now')
AND "service_orders"."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN (
        'service-order-confirmed',
        'service-order-in-progress',
        'service-order-completed'
    )
);

-- View-23: Detailed View that gives info. about frequency of cart_orders and service_orders by users in monthly
CREATE VIEW "order_frequency_per_user" AS
SELECT "users"."id" AS "user_id",
"users"."username" AS "username",
IFNULL("cart_orders"."frequency",0) AS "cart_orders_count_in_one_month",
IFNULL("services_orders"."frequency",0) AS "service_order_in_one_month"
FROM "users"
LEFT JOIN (
    SELECT "id" AS "cart_id", "user_id",
    IFNULL(COUNT("user_carts"."user_id"),0) AS "frequency"
    FROM "user_carts"
    WHERE DATE("ordered_on") >= DATE('now', '-30 days')
    AND DATE("ordered_on") <= DATE('now')
    AND "status_id" IN (
       SELECT "id" FROM "order_statuses"
       WHERE "type" = 'product'
       AND "status" IN (
            'cart-order-confirmed',
            'cart-order-out-for-delivery',
            'cart-order-delivered',
            'cart-order-self-pick-up'
        )
    )
    GROUP BY "user_id"
) "cart_orders" ON "cart_orders"."user_id" = "users"."id"
LEFT JOIN (
    SELECT "id" AS "service_order_id", "user_id",
    IFNULL(COUNT("service_orders"."user_id"),0) AS "frequency"
    FROM "service_orders"
    WHERE DATE("ordered_on") >= DATE('now', '-30 days')
    AND DATE("ordered_on") <= DATE('now')
    AND "status_id" IN (
       SELECT "id" FROM "order_statuses"
       WHERE "type" = 'service'
       AND "status" IN (
            'service-order-confirmed',
            'service-order-in-progress',
            'service-order-completed'
        )
    )
    GROUP BY "user_id"
) "services_orders" ON "services_orders"."user_id" = "users"."id"
ORDER BY "user_id";

-- View-24: Detailed view that lists top 10 products based on total orders and price.
CREATE VIEW "top_selling_products" AS
SELECT "products"."name" AS "product_name",
CONCAT(
    '{ size: ',IFNULL("product_models"."size",'NULL'),';',
    ' color: ',IFNULL("product_models"."color",'NULL'),';',
    ' weight_kg: ',IFNULL("product_models"."weight_kg",'NULL'),';',
    ' material: ',IFNULL("product_models"."material",'NULL'),';',
    ' available_stock: ',IFNULL("product_models"."available_stock",'NULL'),';',
    ' min_order_qty: ',IFNULL("product_models"."min_order_qty",'NULL'),';',
    ' mfg_date: ',IFNULL("product_models"."mfg_date",'NULL'),';',
    ' exp_date: ',IFNULL("product_models"."exp_date",'NULL'),' }'
) AS "product_variant",
IFNULL(COUNT("product_model_id"),0) AS "total_orders",
"price_at_order"
FROM "product_orders"
LEFT JOIN "product_models" ON "product_models"."id" = "product_orders"."product_model_id"
LEFT JOIN "products" ON "products"."id" = "product_models"."product_id"
WHERE "cart_id" IN (
    SELECT "id" FROM "user_carts"
    WHERE "status_id" IN (
        SELECT "id" FROM "order_statuses"
        WHERE "type" = 'product'
        AND "status" IN (
            'cart-order-confirmed',
            'cart-order-out-for-delivery',
            'cart-order-delivered',
            'cart-order-self-pick-up'
        )
    )
)
GROUP BY "product_model_id"
ORDER BY "total_orders" DESC, "price_at_order" DESC
LIMIT 10;

-- View-25: Detailed view that lists top 10 services based on total orders and price.
CREATE VIEW "top_requested_services" AS
SELECT "services"."name" AS "service_name",
IFNULL(COUNT("service_id"),0) AS "total_orders",
"price_at_order"
FROM "service_orders"
LEFT JOIN "services" ON "services"."id" = "service_orders"."service_id"
WHERE "status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN (
        'service-order-confirmed',
        'service-order-in-progress',
        'service-order-completed'
    )
)
GROUP BY "service_id"
ORDER BY "total_orders" DESC, "price_at_order" DESC
LIMIT 10;

-- III. INDEXES

-- Index-1: If an admin wants to retrieve details of users by role (customer, business_owner, delivery_agent), this index speeds up queries
CREATE INDEX "idx_user_roles"
ON "users"("user_role");

-- Index-2: The below index helps in fast lookups when searching for a user by username
CREATE INDEX "idx_username"
ON "users"("username");

-- Index-3: The below index speeds up queries that involve filtering users based on age, gender
CREATE INDEX "idx_users"
ON "users"("age", "gender");

-- Index-4: The idx_locations is useful if admin is querying data based on municipality/state/country/pincode
CREATE INDEX "idx_locations"
ON "locations"("municipality", "state", "country", "pincode");

-- Index-5: Querying on locations can be more efficient if there is a seperate index on location's pincode
CREATE INDEX "idx_location_pincode"
ON "locations"("pincode");

-- Index-6: If a user want to find a business name, and the owner details efficiently brought up by the idx_businesses - index
CREATE INDEX "idx_businesses"
ON "businesses"("owner_id", "name");

-- Index-7: The below index optimizes the queries which require to find businesses by their domain
CREATE INDEX "idx_market_domains"
ON "market_domains"("type", "domain");

-- Index-8: If a user query's data of a product it can be by name so index-idx_products is defined
CREATE INDEX "idx_products"
ON "products"("name");

-- Index-9: As the user search for the product by name idx_products optimizes the search, but it should also bring the correct model details efficiently
CREATE INDEX "idx_product_models"
ON "product_models"("size", "weight_kg", "color", "price", "mfg_date", "exp_date");

-- Index-10: The below index improves order history lookups and delivery agent tracking
CREATE INDEX "idx_user_carts"
ON "user_carts"("ordered_on", "delivery_agent_id");

-- Index-10.5: The below index speeds up fetching a user's orders with specific status.
CREATE INDEX "idx_user_carts_2"
ON "user_carts"("user_id", "status_id", "delivery_agent_id");

-- Index-11: The below index speeds up order queries, when filtering by qty and price.
CREATE INDEX "idx_product_orders"
ON "product_orders"("qty", "price_at_order");

-- Index-12: To optimize the speed of data retrieval on a lookup table which has order's statuses for certain type, the idx_order_statuses optimizes retrieval
CREATE INDEX "idx_order_statuses"
ON "order_statuses"("type", "status");

-- Index-13: To optimize the speed of data retrieval on a lookup table which has payment's statuses, the idx_payment_statuses optimizes queries on that
CREATE INDEX "idx_payment_statuses"
ON "payment_statuses"("status");

-- Index-14: To optimize the speed of data retrieval on a lookup table which has payment's mode, the idx_payment_modes optimizes queries on that
CREATE INDEX "idx_payment_modes"
ON "payment_modes"("mode");

-- Index-15: To optimize the queries related to fetching data based on payment's made the idx_order_cart_payments optimizes queries on that
CREATE INDEX "idx_cart_order_payments"
ON "cart_payments"("paid_on");

-- Index-16: For admin/data_analyst the data of getting ratings sorted as +tive and -tive for each product so I used rating attribute of the table product_ratings and the idx_product_ratings index optimizes the queries on that
CREATE INDEX "idx_product_ratings"
ON "product_ratings"("rating");

-- Index-17: To optimize the user's search in the service by following parameters singlely or multi-paramented
CREATE INDEX "idx_services"
ON "services"("name", "availability", "price", "est_wrk_dur_hrs");

-- Index-18: To optimize searching for a service name from user can be efficient if there is a seperate index on
CREATE INDEX "idx_service_name"
ON "services"("name");

-- Index-19: The below index helps to analyze trending service order over time.
CREATE INDEX "idx_service_orders"
ON "service_orders"("ordered_on");

-- Index-20: To help the analyst to assess the time when payments made more or less, and to assess certain situations like to alter the business-timings being available analyzed situations
CREATE INDEX "idx_service_payments"
ON "service_payments"("paid_on");

-- Index-21: To optimize the performance when sorting or filtering service reviews by ratings
CREATE INDEX "idx_service_ratings"
ON "service_ratings"("rating");

-- IV) TRIGGERS

-- 1 - Triggers on 'users' table(6)

-- 1.1: Logging Triggers

-- 1.1.1: Trigger to log new user
CREATE TRIGGER "log_new_user"
AFTER INSERT ON "users"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "description", "operation")
    VALUES
    (NEW."id", 'users', CONCAT('new-user[username:',NEW."username",']-added'), 'INSERT');
END;

-- 1.1.2: Trigger to log left user
CREATE TRIGGER "log_left_user"
BEFORE DELETE ON "users"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "description", "operation")
    VALUES
    (OLD."id", 'users', CONCAT('user[username:',OLD."username",']-left'), 'DELETE');
END;

-- 1.1.3: Trigger to log user updates
CREATE TRIGGER "log_user_updates"
AFTER UPDATE ON "users"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'users', 'UPDATE','password',OLD."password", NEW."password", 'updated-user-password'
    WHERE OLD."password" != NEW."password";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'users', 'UPDATE','phone',OLD."phone", NEW."phone", 'updated-user-phone'
    WHERE OLD."phone" != NEW."phone";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'users', 'UPDATE','email', OLD."email", NEW."email", 'updated-user-email'
    WHERE IFNULL(OLD."email",'') != NEW."email";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'users', 'UPDATE','user_role', OLD."user_role", NEW."user_role", 'updated-user-user_role'
    WHERE OLD."user_role" != NEW."user_role";
END;

-- 1.2 Restricting Triggers

-- 1.2.1 Trigger on Restricting user to update his/her password that is already used or in use
CREATE TRIGGER "restrict_user_password_update"
BEFORE UPDATE OF "password" ON "users"
FOR EACH ROW
WHEN NEW."password" IN (
    SELECT "old_value" FROM "logs"
    WHERE "operation" = 'UPDATE'
    AND "table" = 'users'
    AND "column" = 'password'
    AND "record_id" = OLD."id"
    UNION
    SELECT "new_value" FROM "logs"
    WHERE "operation" = 'UPDATE'
    AND "table" = 'users'
    AND "column" = 'password'
    AND "record_id" = OLD."id"
)
BEGIN
    SELECT RAISE(ABORT, 'The password is already used or being in use. Choose a new password!');
END;

-- 2 - Triggers on 'businesses' table(7)

-- 2.1 - Logging Triggers

-- 2.1.1 - Trigger to Log new business
CREATE TRIGGER "log_new_business"
AFTER INSERT ON "businesses"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "description", "operation")
    VALUES
    (NEW."id", 'businesses', CONCAT('{owner[id]: ',NEW."owner_id",'; business-name: ',NEW."name",'; address: ',NEW."address",'; location[id]: ',NEW."location_id",'}=>business-added'),
    'INSERT');
END;

-- 2.1.2 - Trigger to Log closed business
CREATE TRIGGER "log_closed_business"
BEFORE DELETE ON "businesses"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "description", "operation")
    VALUES
    (OLD."id", 'businesses', CONCAT('{owner[id]:',OLD."owner_id",';business-name:',OLD."name",';address:',OLD."address",';location[id]:',OLD."location_id",'}=>business-closed'),
    'DELETE');
END;

-- 2.1.3 - Trigger to Log business updates
CREATE TRIGGER "log_business_updates"
AFTER UPDATE ON "businesses"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'businesses','UPDATE', 'name', OLD."name", NEW."name", 'updated-business-name'
    WHERE OLD."name" != NEW."name";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'businesses','UPDATE', 'address', OLD."address", NEW."address", 'updated-business-address'
    WHERE OLD."address" != NEW."address";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'businesses','UPDATE', 'owner_id', OLD."owner_id", NEW."owner_id", 'updated-business-owner_id'
    WHERE OLD."owner_id" != NEW."owner_id";
END;


-- 2.2 - Restricting Triggers

-- 2.2.1 - Trigger to restrict business name update not more than 5 times
CREATE TRIGGER "restrict_business_name_update"
BEFORE UPDATE OF "name" ON "businesses"
FOR EACH ROW
WHEN (
    SELECT IFNULL(COUNT(*), 0) FROM "logs"
    WHERE "operation" = 'UPDATE'
    AND "table" = 'businesses'
    AND "column" = 'name'
    AND "record_id" = OLD."id"
) >= 5
BEGIN
    SELECT RAISE(ABORT, 'Update on business-name allowed for only 5 times!');
END;

-- 2.3 - Validating Triggers

-- 2.3.1 - Trigger to validate whether the business already exists in the businesses table or not
CREATE TRIGGER "validate_business_existence"
BEFORE INSERT ON "businesses"
FOR EACH ROW
WHEN (
    SELECT 1 FROM "businesses"
    WHERE "owner_id" = NEW."owner_id"
    AND "name" = NEW."name"
) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'The business and the owner already exists!');
END;

-- 2.3.2 - Trigger to check whether the owner_id's role in 'businesses' table is business_owner with reference from 'users' table or not ON INSERT
CREATE TRIGGER "validate_owner_role_on_insert"
BEFORE INSERT ON "businesses"
FOR EACH ROW
WHEN (
    SELECT "user_role" FROM "users"
    WHERE "id" = NEW."owner_id"
) IS NOT 'business_owner'
BEGIN
    SELECT RAISE(ABORT, 'The user specified in owner_id, his/her role is not business_owner!');
END;

-- 2.3.3 - Trigger to check whether the owner_id on update role is business_owner or not ON UPDATE
CREATE TRIGGER "validate_owner_role_on_update"
BEFORE UPDATE OF "owner_id" ON "businesses"
FOR EACH ROW
WHEN (
    SELECT "user_role" FROM "users"
    WHERE "id" = NEW."owner_id"
) IS NOT 'business_owner'
BEGIN
    SELECT RAISE(ABORT, 'The user specified in owner_id, his/her role is not business_owner!');
END;

-- 2.3.4 - Trigger to check whether the owner's and business's location are the same
CREATE TRIGGER "validate_business_location"
BEFORE INSERT ON "businesses"
FOR EACH ROW
WHEN IFNULL(
    (
        SELECT "location_id" FROM "users"
        WHERE "id" = NEW."owner_id"
    ),0
) IS NOT NEW."location_id"
BEGIN
    SELECT RAISE(ABORT, 'The business owner must reside in the same location where he/she reside, address can differ!');
END;

-- 2.3.5 - Trigger to check the business working hours, can also be written for UPDATE
CREATE TRIGGER "validate_business_working_hours"
BEFORE INSERT ON "businesses"
FOR EACH ROW
WHEN (
    TIME(NEW."close_time") - TIME(NEW."open_time")
) < 5
BEGIN
    SELECT RAISE(ABORT, 'The Business should be available opened for atleast 5 hours!');
END;

-- 2.3.6 - Trigger to check the business timings format, can also be written for UPDATE
CREATE TRIGGER "validate_business_timings_format"
BEFORE INSERT ON "businesses"
FOR EACH ROW
WHEN (
    NEW."open_time" NOT LIKE '__:__'
    OR TIME(NEW."open_time") IS NULL
) OR (
    NEW."close_time" NOT LIKE '__:__'
    OR TIME(NEW."close_time") IS NULL
)
BEGIN
    SELECT RAISE(ABORT, 'Format of business open/close timings not valid!, It must be in hh:mm of 24-hr clock format!');
END;

-- 3 Triggers on 'business_associations' table(8)

-- 3.1 Restricting Triggers

-- 3.1.1 Trigger to restrict the direct update on business_id
CREATE TRIGGER "restrict_update_on_business_id"
BEFORE UPDATE OF "business_id" ON "business_associations"
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Direct business_id update is restricted!');
END;

-- 4 - Triggers on 'products' table(9)

-- 4.1 Logging Triggers

-- 4.1.1 Trigger to log new product
CREATE TRIGGER "log_new_product"
AFTER INSERT ON "products"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'products', 'INSERT', CONCAT('new-product-of-business[id]: ',NEW."business_id",'-added'));
END;

-- 4.1.2 Trigger to log removed product
CREATE TRIGGER "log_removed_product"
BEFORE DELETE ON "products"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'products', 'DELETE', CONCAT('product-of-business[id]:',OLD."business_id",'-removed'));
END;

-- 4.1.3 Trigger to log updates on product
CREATE TRIGGER "log_product_updates"
AFTER UPDATE ON "products"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "column", "operation", "old_value", "new_value", "description")
    SELECT OLD."id", 'products', 'name', 'UPDATE', OLD."name", NEW."name", 'updated-product-name'
    WHERE OLD."name" != NEW."name";

    INSERT INTO "logs"("record_id", "table", "column", "operation", "old_value", "new_value", "description")
    SELECT OLD."id", 'products', 'category_id', 'UPDATE', OLD."category_id", NEW."category_id", 'updated-product-category_id'
    WHERE OLD."category_id" != NEW."category_id";

    INSERT INTO "logs"("record_id", "table", "column", "operation", "old_value", "new_value", "description")
    SELECT OLD."id", 'products', 'business_id', 'UPDATE', OLD."business_id", NEW."business_id", 'updated-product-business_id'
    WHERE OLD."business_id" != NEW."business_id";
END;

-- 4.2 Restricting Triggers

-- 4.2.1 Trigger to restrict category_id not zero ON INSERT
CREATE TRIGGER "restrict_product_category_id_zero_on_insert"
BEFORE INSERT ON "products"
FOR EACH ROW
WHEN NEW."category_id" = 0
BEGIN
    SELECT RAISE(ABORT, 'The category_id cannot be 0 on INSERT or UPDATE!');
END;

-- 4.2.2 Trigger to restrict category_id not zero ON UPDATE
CREATE TRIGGER "restrict_product_category_id_zero_on_update"
BEFORE UPDATE OF "category_id" ON "products"
FOR EACH ROW
WHEN NEW."category_id" = 0
BEGIN
    SELECT RAISE(ABORT, 'The category_id cannot be 0 on INSERT or UPDATE!');
END;

-- 4.3 Validating Triggers

-- 4.3.1 Trigger to validate product's-category_id ON INSERT
CREATE TRIGGER "validate_product_category_id_on_insert"
BEFORE INSERT ON "products"
FOR EACH ROW
WHEN NEW."category_id" NOT IN (
    SELECT "id" FROM "market_domains"
    WHERE "type" = 'product' OR "type" = 'both'
)
BEGIN
    SELECT RAISE(ABORT, 'The category_id is invalid and not belongs to products!');
END;

-- 4.3.2 Trigger to validate product's-category_id ON UPDATE
CREATE TRIGGER "validate_product_category_id_on_update"
BEFORE UPDATE OF "category_id" ON "products"
FOR EACH ROW
WHEN NEW."category_id" NOT IN (
    SELECT "id" FROM "market_domains"
    WHERE "type" = 'product' OR "type" = 'both'
)
BEGIN
    SELECT RAISE(ABORT, 'The category_id is invalid and not belongs to products!');
END;

-- 5 Triggers on 'product_models' table(10)

-- 5.1 Logging Triggers

-- 5.1.1 Trigger to log new product_model
CREATE TRIGGER "log_new_product_model"
AFTER INSERT ON "product_models"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'product_models', 'INSERT', CONCAT('new-product-model-for-product[id]: ',NEW."product_id",'-added'));
END;

-- 5.1.2 Trigger to log remove product_model
CREATE TRIGGER "log_removed_product_model"
BEFORE DELETE ON "product_models"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'product_models', 'DELETE', CONCAT('product-model-for-product[id]: ',OLD."product_id",'-removed'));
END;

-- 5.1.3 Trigger to log product_model updates
CREATE TRIGGER "log_product_model_updates"
AFTER UPDATE ON "product_models"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "column", "old_value", "new_value", "operation", "description")
    SELECT NEW."id", 'product_models', 'price', OLD."price", NEW."price", 'UPDATE', 'updated-product_model-price'
    WHERE OLD."price" != NEW."price";

    INSERT INTO "logs"("record_id", "table", "column", "old_value", "new_value", "operation", "description")
    SELECT NEW."id", 'product_models', 'available_stock', OLD."available_stock", NEW."available_stock", 'UPDATE', 'updated-product_model-available_stock'
    WHERE OLD."available_stock" != NEW."available_stock";
END;

-- 5.2 Validating Triggers

-- 5.2.1 Trigger to validate and compare whether the product_model's mfg_date is not later than exp_date ON INSERT
CREATE TRIGGER "compare_product_model_mfg_exp_date_on_insert"
BEFORE INSERT ON "product_models"
FOR EACH ROW
WHEN (
    NEW."exp_date" IS NOT NULL
    AND NEW."mfg_date" IS NOT NULL
) AND (
    DATE(NEW."mfg_date") > DATE(NEW."exp_date")
)
BEGIN
    SELECT RAISE(ABORT, 'The product_model(s) mfg_date is later than the exp_date!');
END;

-- 5.2.2 Trigger to validate and compare whether the product_model's mfg_date is not later than exp_date ON UPDATE
CREATE TRIGGER "compare_product_model_mfg_exp_date_on_update"
BEFORE UPDATE OF "mfg_date", "exp_date" ON "product_models"
FOR EACH ROW
WHEN (
    NEW."exp_date" IS NOT NULL
    AND NEW."mfg_date" IS NOT NULL
) AND (
    DATE(NEW."mfg_date") > DATE(NEW."exp_date")
)
BEGIN
    SELECT RAISE(ABORT, 'The product_model(s) mfg_date is later than the exp_date!');
END;

-- 5.2.3 Trigger to validate format of both mfg_date and exp_date ON INSERT
CREATE TRIGGER "validate_format_of_mfg_exp_dates_on_insert"
BEFORE INSERT ON "product_models"
FOR EACH ROW
WHEN (
    NEW."mfg_date" IS NOT NULL
    AND DATE(NEW."mfg_date") IS NULL
) OR (
    NEW."exp_date" IS NOT NULL
    AND DATE(NEw."exp_date") IS NULL
)
BEGIN
    SELECT RAISE(ABORT, 'The product_model(s) mfg_date or exp_date are not in valid (yyyy-mm-dd) format!');
END;

-- 5.2.4 Trigger to validate format of both mfg_date and exp_date ON UPDATE
CREATE TRIGGER "validate_format_of_mfg_exp_dates_on_update"
BEFORE UPDATE OF "mfg_date", "exp_date" ON "product_models"
FOR EACH ROW
WHEN (
    NEW."mfg_date" IS NOT NULL
    AND DATE(NEW."mfg_date") IS NULL
) OR (
    NEW."exp_date" IS NOT NULL
    AND DATE(NEW."exp_date") IS NULL
)
BEGIN
    SELECT RAISE(ABORT, 'The product_model(s) mfg_date or exp_date are not in valid (yyyy-mm-dd) format!');
END;

-- 6 Triggers on 'services' table(15)

-- 6.1 Logging Triggers

-- 6.1.1 Trigger to log new service
CREATE TRIGGER "log_new_service"
AFTER INSERT ON "services"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'services', 'INSERT', CONCAT('new-service-of-business[id]: ', NEW."business_id", '-added'));
END;

-- 6.1.2 Trigger to log removed service
CREATE TRIGGER "log_removed_service"
BEFORE DELETE ON "services"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'services', 'DELETE', CONCAT('service-of-business[id]: ',OLD."business_id",'-removed'));
END;

-- 6.1.3 Trigger to log service updates
CREATE TRIGGER "log_service_updates"
AFTER UPDATE ON "services"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "column", "operation", "old_value", "new_value", "description")
    SELECT OLD."id", 'services', 'category_id', 'UPDATE', OLD."category_id", NEW."category_id", 'updated-service-order-category_id'
    WHERE OLD."category_id" != NEW."category_id";

    INSERT INTO "logs"("record_id", "table", "column", "operation", "old_value", "new_value", "description")
    SELECT OLD."id", 'services', 'availability', 'UPDATE', OLD."availability", NEW."availability", 'updated-service-order-availability'
    WHERE OLD."availability" != NEW."availability";

    INSERT INTO "logs"("record_id", "table", "column", "operation", "old_value", "new_value", "description")
    SELECT OLD."id", 'services', 'price', 'UPDATE', OLD."price", NEW."price", 'updated-service-order-price'
    WHERE OLD."price" != NEW."price";
END;

-- 6.2 Restricting Triggers

-- 6.2.1 Trigger to restrict category_id not zero ON INSERT
CREATE TRIGGER "restrict_service_category_id_zero_on_insert"
BEFORE INSERT ON "services"
FOR EACH ROW
WHEN NEW."category_id" = 0
BEGIN
    SELECT RAISE(ABORT, 'The category_id cannot be 0 on INSERT or UPDATE!');
END;

-- 6.2.2 Trigger to restrict category_id not zero ON UPDATE
CREATE TRIGGER "restrict_service_category_id_zero_on_update"
BEFORE UPDATE OF "category_id" ON "services"
FOR EACH ROW
WHEN NEW."category_id" = 0
BEGIN
    SELECT RAISE(ABORT, 'The category_id cannot be 0 on INSERT or UPDATE!');
END;

-- 6.3 Validating Triggers

-- 6.3.1 Trigger to validate that the category_id of the service is actually related to service's ON INSERT
CREATE TRIGGER "validate_service_category_id_on_insert"
BEFORE INSERT ON "services"
FOR EACH ROW
WHEN NEW."category_id" NOT IN (
    SELECT "id" FROM "market_domains"
    WHERE "type" = 'service' OR "type" = 'both'
)
BEGIN
    SELECT RAISE(ABORT, 'The category_id is invalid and does not belongs to services!');
END;

-- 6.3.2 Trigger to validate that the category_id of the service is actually related to service's ON UPDATE
CREATE TRIGGER "validate_service_category_id_on_update"
BEFORE UPDATE OF "category_id" ON "services"
FOR EACH ROW
WHEN NEW."category_id" NOT IN (
    SELECT "id" FROM "market_domains"
    WHERE "type" = 'service' OR "type" = 'both'
)
BEGIN
    SELECT RAISE(ABORT, 'The category_id is invalid and does not belongs to services!');
END;

-- 7 Triggers on 'user_carts' table(11)

-- 7.1 Logging Triggers

-- 7.1.1 Trigger for Logging a detail of new cart
CREATE TRIGGER "log_new_cart"
AFTER INSERT ON "user_carts"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'user_carts', 'INSERT', CONCAT('new-cart from user[id]: ',NEW."user_id",'-initiated'));
END;

-- 7.1.2 Trigger for Logging a detail of abandoned/deleted cart
CREATE TRIGGER "log_removed_cart"
BEFORE DELETE ON "user_carts"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'user_carts', 'DELETE', CONCAT('cart belongs to user[id]: ',OLD."user_id",'-abandoned'));
END;

-- 7.1.3 Trigger for Logging updates of a cart in user_carts
CREATE TRIGGER "log_cart_updates"
AFTER UPDATE OF "status_id", "ordered_on", "delivery_agent_id" ON "user_carts"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'user_carts', 'UPDATE', 'status_id', OLD."status_id", NEW."status_id", 'updated-status-of-cart'
    WHERE OLD."status_id" != NEW."status_id";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'user_carts', 'UPDATE', 'ordered_on', OLD."ordered_on", NEW."ordered_on", 'updated-cart-ordered-date'
    WHERE OLD."ordered_on" != NEW."ordered_on";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'user_carts', 'UPDATE', 'delivery_agent_id', OLD."delivery_agent_id", NEW."delivery_agent_id", 'updated-delivery_agent-information'
    WHERE OLD."delivery_agent_id" != NEW."delivery_agent_id";
END;

-- 7.2 Restricting Triggers

-- 7.2.1 Trigger to restrict updating status to delivered, self-pick-up, returned or cancelled, if the cart was never confirmed.
CREATE TRIGGER "restrict_cart_status_if_it_not_confirmed"
BEFORE UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "status" IN ('cart-order-delivered', 'cart-order-self-pick-up', 'cart-order-returned', 'cart-order-cancelled')
    AND "type" = 'product'
) AND OLD."status_id" NOT IN (
    SELECT "id" FROM "order_statuses"
    WHERE "status" IN ('cart-order-confirmed', 'cart-order-out-for-delivery')
    AND "type" = 'product'
)
BEGIN
    SELECT RAISE(ABORT, 'The status_id cannot be updated to delivered/self-pick-up/returned/cancelled, when it was never confirmed at first.');
END;

-- 7.2.2 Trigger to restrict changing status back to pending after confirmation
CREATE TRIGGER "restrict_cart_status_if_it_moves_back_from_confirmed_to_pending"
BEFORE UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN NEW."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "status" = 'cart-order-pending'
    AND "type" = 'product'
) AND OLD."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "status" = 'cart-order-confirmed'
    AND "type" = 'product'
)
BEGIN
    SELECT RAISE(ABORT, 'The status_id cannot be updated to pending if it was confirmed.');
END;

-- 7.2.3 Trigger to restrict updating delivery_agent_id if the order is already out-for-delivery or delivered
CREATE TRIGGER "restrict_delivery_agent_update_on_delivered_orders"
BEFORE UPDATE OF "delivery_agent_id" ON "user_carts"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "status" IN ('cart-order-out-for-delivery', 'cart-order-delivered')
)
BEGIN
    SELECT RAISE(ABORT, 'The delivery_agent_id cannot be updated, as the cart-order status is either out-for-delivery or delivered.');
END;

-- 7.2.4 Trigger to restrict update on ordered_on if the order is confirmed, out-for-delivery, delivered, cancelled, failed, self-pick-up
CREATE TRIGGER "restrict_update_on_cart_ordered_date"
BEFORE UPDATE OF "ordered_on" ON "user_carts"
FOR EACH ROW
WHEN OLD."ordered_on" IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'The ordered_on cannot be updated once it is set.');
END;

-- 7.2.5 Trigger to restrict delete user_cart if status is confirmed, out-for-delivery, delivered, self-pick-up, returned or cancelled
CREATE TRIGGER "restrict_confirmed_cart_order_deletion"
BEFORE DELETE ON "user_carts"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" NOT IN ('cart-order-pending', 'cart-order-failed')
)
BEGIN
    SELECT RAISE(ABORT, 'The user_cart cannot be deleted as its status is confirmed/out-for-delivery/delivered/self-pick-up/returned/cancelled');
END;

-- 7.2.6 Restricting trigger to transition from pending to confirmed when the cart is empty - [OK]
CREATE TRIGGER "restrict_cart_status_confirmed_when_cart_is_empty"
BEFORE UPDATE ON "user_carts"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-pending'
) AND NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-confirmed', 'cart-order-out-for-delivery', 'cart-order-delivered', 'cart-order-returned', 'cart-order-cancelled')
) AND (
    SELECT 1 FROM "product_orders"
    WHERE "cart_id" = OLD."id"
) IS NULL
BEGIN
    SELECT RAISE(ABORT, "The cart is empty with no products in it, the cart-order cannot be confirmed/out-for-delivery/delivered/returned/cancelled!");
END;

-- 7.3 Validating Triggers

-- 7.3.1 Trigger to validate stock availability BEFORE confirming a cart order
CREATE TRIGGER "validate_stock_before_cart_confirmed"
BEFORE UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN NEW."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-confirmed'
)
BEGIN
    SELECT RAISE(ABORT, 'Insufficient stock for the product_model_id.')
    FROM (
        SELECT
            "product_orders"."product_model_id",
            "product_orders"."qty",
            "product_models"."available_stock"
        FROM "product_orders"
        JOIN "product_models" ON "product_models"."id" = "product_orders"."product_model_id"
        WHERE "product_orders"."cart_id" = NEW."id"
        AND "product_orders"."qty" > "product_models"."available_stock"
    )
    LIMIT 1;
END;

-- 7.4 Automating Triggers

-- 7.4.1 Trigger to auto-set cart_payment status to pending when an order is confirmed
CREATE TRIGGER "auto_update_payment_status_as_cart_status_change"
AFTER UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN OLD."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-pending'
)
AND NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-confirmed', 'cart-order-out-for-delivery')
)
BEGIN
    UPDATE "cart_payments"
    SET "status_id" = (
        SELECT "id" FROM "payment_statuses"
        WHERE "status" = 'pending'
    )
    WHERE "cart_id" = OLD."id";
END;

-- 7.4.2 Trigger to auto-update cart_payments to refunded if the cart is cancelled after being paid.
CREATE TRIGGER "auto_update_payment_after_cart_cancelled_if_paid"
AFTER UPDATE ON "user_carts"
FOR EACH ROW
WHEN (
    (
        SELECT "status_id" FROM "cart_payments"
        WHERE "cart_id" = OLD."id"
    ) = (
        SELECT "id" FROM "payment_statuses"
        WHERE "status" = 'completed'
    )
) AND NEW."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-cancelled'
)
BEGIN
    UPDATE "cart_payments"
    SET "status_id" = (
        SELECT "id" FROM "payment_statuses"
        WHERE "status" = 'refunded'
    )
    WHERE "cart_id" = OLD."id";
END;

-- 7.4.3 Trigger to auto-update (decrease) the available_stock when the product's order in product_orders table is confirmed
CREATE TRIGGER "auto_update_available_stock_when_order_is_confirmed"
AFTER UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN NEW."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-confirmed'
) AND OLD."status_id" != (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-confirmed'
)
BEGIN
    UPDATE "product_models"
    SET "available_stock" = "available_stock" - (
        SELECT "qty" FROM "product_orders"
        WHERE "cart_id" = NEW."id"
        AND "product_model_id" = "product_models"."id"
    )
    WHERE "id" IN (
        SELECT "product_model_id" FROM "product_orders"
        WHERE "cart_id" = NEW."id"
    );
END;

-- 7.4.4 Trigger to auto-update (increase) the available_stock if a confirmed order is cancelled or returned
CREATE TRIGGER "auto_increase_stock_on_cancel_return"
AFTER UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN OLD."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-confirmed'
) AND NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-cancelled', 'cart-order-returned')
)
BEGIN
    UPDATE "product_models"
    SET "available_stock" = "available_stock" + (
        SELECT "qty"
        FROM "product_orders"
        WHERE "cart_id" = NEW."id"
        AND "product_model_id" = "product_models"."id"
    )
    WHERE "id" IN (
        SELECT "product_model_id"
        FROM "product_orders"
        WHERE "cart_id" = NEW."id"
    );
END;

-- 8 Triggers on 'product_orders' table(12)

-- 8.1 Logging Triggers

-- 8.1.1 Trigger to log new-product_model order from user_carts
CREATE TRIGGER "log_new_product_order"
AFTER INSERT ON "product_orders"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'product_orders', 'INSERT', CONCAT('product_model[id]: ',NEW."product_model_id",'-added to cart[id]: ',NEW."cart_id"));
END;

-- 8.1.2 Trigger to log removed-product_model order from user_carts
CREATE TRIGGER "log_removed_product_order"
BEFORE DELETE ON "product_orders"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'product_orders', 'DELETE', CONCAT('product_model[id]: ',OLD."product_model_id",'-removed from cart[id]: ',OLD."cart_id"));
END;

-- 8.1.3 Trigger to log updates of product_model order from user_carts
CREATE TRIGGER "log_product_orders_updates"
AFTER UPDATE OF "qty", "price_at_order" ON "product_orders"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'product_orders', 'UPDATE', 'qty', OLD."qty", NEW."qty", 'updated-product_order-quantity'
    WHERE OLD."qty" != NEW."qty";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'product_orders', 'UPDATE', 'price_at_order', OLD."price_at_order", NEW."price_at_order", 'updated-product_order-price_at_order'
    WHERE OLD."price_at_order" != NEW."price_at_order";
END;

-- 8.2 Restricting Triggers

-- 8.2.1 Trigger to restrict modifying price_at_order after the order is place.
CREATE TRIGGER "restrict_update_price_after_ordered"
BEFORE UPDATE OF "price_at_order" ON "product_orders"
FOR EACH ROW
WHEN ( (
        SELECT "status_id" FROM "user_carts"
        WHERE "id" = OLD."cart_id"
    ) NOT IN (
        SELECT "id" FROM "order_statuses"
        WHERE "type" = 'product'
        AND "status" IN ('cart-order-pending', 'cart-order-failed', 'cart-order-cancelled')
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The price_at_order cannot be updated as the product_order is confirmed/out-for-delivery/delivered/self-pick-up/returned.');
END;

-- 8.2.2 Trigger to restrict quantity updates after the cart order is confirmed, delivered
CREATE TRIGGER "restrict_qty_update_after_order_confirmed"
BEFORE UPDATE OF "qty" ON "product_orders"
FOR EACH ROW
WHEN ( (
        SELECT "status_id" FROM "user_carts"
        WHERE "id" = OLD."cart_id"
    ) IN (
        SELECT "id" FROM "order_statuses"
        WHERE "type" = 'product'
        AND "status" IN ('cart-order-confirmed', 'cart-order-delivered', 'cart-order-out-for-delivery', 'cart-order-self-pick-up')
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The qty(quantity) of the product_model that ordered cannot be updated as the product_order is confirmed/delivered/out-for-delivery/self-picked-up.');
END;

-- 8.2.3 Trigger to restrict adding products to carts that are already confirmed, delivered, or cancelled
CREATE TRIGGER "restrict_adding_product_orders_to_confirmed_carts"
BEFORE INSERT ON "product_orders"
FOR EACH ROW
WHEN ( (
        SELECT "status_id" FROM "user_carts"
        WHERE "id" = NEW."cart_id"
    ) IN (
        SELECT "id" FROM "order_statuses"
        WHERE "type" = 'product'
        AND "status" IN ('cart-order-confirmed', 'cart-order-delivered', 'cart-order-cancelled', 'cart-order-out-for-delivery', 'cart-order-self-pick-up')
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The cart_id(s) status of order is confirmed/delivered/out-for-delivery/self-picked/cancelled, so adding more products to same cart is restricted.');
END;

-- 8.2.4 Trigger to restrict order if the quantity (qty) is greater than available_stock in product_models table(10)
CREATE TRIGGER "restrict_qty_exceeding_stock"
BEFORE INSERT ON "product_orders"
FOR EACH ROW
WHEN NEW."qty" > (
    SELECT "available_stock" FROM "product_models"
    WHERE "id" = NEW."product_model_id"
)
BEGIN
    SELECT RAISE(ABORT, 'The product_model_id which is being ordered has less stock is available than mention in the quantity (qty in product_orders).');
END;

-- 8.3 Validating Triggers

-- 8.3.1 Trigger to validate the price at the order is same for the actual product_model before inserting in product_orders
CREATE TRIGGER "validate_product_order_price_on_insert"
BEFORE INSERT ON "product_orders"
FOR EACH ROW
WHEN (
    NEW."price_at_order" != (
        SELECT "price" FROM "product_models"
        WHERE "id" = NEW."product_model_id"
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The price_at_order does not match to the actual price of product_model.');
END;

-- 8.3.2 Trigger to validate the price at the order is same for the actual product_model before updating in product_orders
CREATE TRIGGER "validate_product_order_price_on_update"
BEFORE UPDATE OF "price_at_order" ON "product_orders"
FOR EACH ROW
WHEN (
    NEW."price_at_order" != (
        SELECT "price" FROM "product_models"
        WHERE "id" = NEW."product_model_id"
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The price_at_order does not match to the acutal price of product_model.');
END;

-- 8.4 Automating Triggers

-- 8.4.1 Trigger to auto calculate and store total_price in cart_payments ON INSERT
CREATE TRIGGER "auto_update_cart_total_price_on_insert"
AFTER INSERT ON "product_orders"
FOR EACH ROW
WHEN (
    SELECT 1 FROM "cart_payments"
    WHERE "cart_id" = NEW."cart_id"
) IS NULL
BEGIN
    INSERT INTO "cart_payments"("cart_id", "total_price", "status_id", "mode_id")
    VALUES
    (NEW."cart_id", (
        SELECT SUM("qty" * "price_at_order") AS "total_price"
        FROM "product_orders"
        WHERE "cart_id" = NEW."cart_id"
    ),(
        SELECT "id" AS "status_id"
        FROM "payment_statuses"
        WHERE "status" = 'pending'
    ),(
        SELECT "id" AS "mode_id"
        FROM "payment_modes"
        WHERE "mode" = 'cash-on-delivery'
    ));
END;

-- 8.4.2 Trigger to auto calculate and store total_price in cart_payments ON UPDATE
CREATE TRIGGER "auto_update_cart_total_price_on_update"
AFTER INSERT ON "product_orders"
FOR EACH ROW
WHEN (
    SELECT 1 FROM "cart_payments"
    WHERE "cart_id" = NEW."cart_id"
) IS NOT NULL
BEGIN
    UPDATE "cart_payments"
    SET "total_price" = (
        SELECT SUM("qty" * "price_at_order") FROM "product_orders"
        WHERE "cart_id" = NEW."cart_id"
    )
    WHERE "cart_payments"."cart_id" = NEW."cart_id";
END;

-- 8.4.3 Trigger to auto calculate and store total_price in cart_payments ON DELETE
CREATE TRIGGER "auto_update_cart_total_price_on_delete"
AFTER DELETE ON "product_orders"
FOR EACH ROW
WHEN (
    SELECT 1 FROM "cart_payments"
    WHERE "cart_id" = NEW."cart_id"
) IS NOT NULL
BEGIN
    UPDATE "cart_payments"
    SET "total_price" = IFNULL((
        SELECT SUM("qty" * "price_at_order") FROM "product_orders"
        WHERE "cart_id" = OLD."cart_id"
    ), 0.0)
    WHERE "cart_id" = OLD."cart_id";
END;

-- 8.4.4 Trigger to auto-update quantity(qty) if the same product is added again to the same cart instead of creating duplicate rows
CREATE TRIGGER "auto_merge_duplicate_product_orders"
BEFORE INSERT ON "product_orders"
FOR EACH ROW
WHEN (
    SELECT 1 FROM "product_orders"
    WHERE "cart_id" = NEW."cart_id"
    AND "product_model_id" = NEW."product_model_id"
) = 1
BEGIN
    UPDATE "product_orders"
    SET "qty" = "qty" + NEW."qty"
    WHERE "cart_id" = NEW."cart_id"
    AND "product_model_id" = NEW."product_model_id";

    SELECT RAISE(IGNORE);
END;

-- 9 Triggers on 'service_orders' table(16)

-- 9.1 Logging Triggers

-- 9.1.1 Trigger to log new service orders
CREATE TRIGGER "log_new_service_order"
AFTER INSERT ON "service_orders"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'service_orders', 'INSERT', CONCAT('service[id]:',NEW."service_id",'-order added, placed by user[id]:',NEW."user_id"));
END;

-- 9.1.2 Trigger to log removed/cancelled service orders
CREATE TRIGGER "log_cancelled_service_order"
BEFORE DELETE ON "service_orders"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'service_orders', 'DELETE', CONCAT('service[id]:',OLD."service_id", '-order removed, placed by user[id]:',OLD."user_id"));
END;

-- 9.1.3 Trigger to log updates of service orders
CREATE TRIGGER "log_service_order_updates"
AFTER UPDATE ON "service_orders"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'service_orders', 'UPDATE', 'status_id', OLD."status_id", NEW."status_id", CONCAT('updated-status_id-for-service_order[id]:',OLD."id")
    WHERE OLD."status_id" != NEW."status_id";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'service_orders', 'UPDATE', 'price_at_order', OLD."price_at_order", NEW."price_at_order", CONCAT('updated-price_at_order-for-service_order[id]:',OLD."id")
    WHERE OLD."price_at_order" != NEW."price_at_order";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'service_orders', 'UPDATE', 'ordered_on', OLD."ordered_on", NEW."ordered_on", CONCAT('updated-ordered_on-for-service_order[id]:',OLD."id")
    WHERE OLD."ordered_on" != NEW."ordered_on";
END;

-- 9.2 Restricting Triggers

-- 9.2.1 Trigger to restrict modifying price_at_order after the service_order is placed
CREATE TRIGGER "restrict_price_update_after_service_order_placed"
BEFORE UPDATE OF "price_at_order" ON "service_orders"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" NOT IN ('service-order-pending', 'service-order-failed', 'service-order-cancelled')
)
BEGIN
    SELECT RAISE(ABORT, 'The price_at_order in the service_order cannot be updated!');
END;

-- 9.2.2 Trigger to restrict updating quantity (qty) once service_order is service-order-confirmed, service-order-in-progress, service-order-completed
CREATE TRIGGER "restrict_update_on_quantity_once_service_order_is_started"
BEFORE UPDATE OF "qty" ON "service_orders"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-confirmed', 'service-order-in-progress', 'service-order-completed')
)
BEGIN
    SELECT RAISE(ABORT, 'The quantity (qty) cannot be updated for already confirmed/in-progress/completed service_orders.');
END;

-- 9.2.3 Trigger to restrict updating service_id after service order placed
CREATE TRIGGER "restrict_update_on_service_id_if_order_was_placed"
BEFORE UPDATE OF "service_id" ON "service_orders"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" NOT IN ('service-order-pending', 'service-order-failed', 'service-order-cancelled')
)
BEGIN
    SELECT RAISE(ABORT, "The service_id cannot be updated when the service_order[id] status is confirmed/in-progress/completed.");
END;

-- 9.2.4 Trigger to restrict to delete service orders if status is confirmed, in-progress, completed, or cancelled
CREATE TRIGGER "restrict_confirmed_service_orders_delete"
BEFORE DELETE ON "service_orders"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-confirmed', 'service-order-in-progress', 'service-order-completed', 'service-order-cancelled')
)
BEGIN
    SELECT RAISE(ABORT, 'The service_order cannot be deleted as its status is confirmed/in-progress/completed/cancelled');
END;

-- 9.2.5 Trigger to restrict service order if the quantity (qty) is greater than available_slots in services table(15)
CREATE TRIGGER "restrict_exceeding_available_service_slots"
BEFORE INSERT ON "service_orders"
FOR EACH ROW
WHEN NEW."qty" > (
    SELECT "available_slots" FROM "services"
    WHERE "id" = NEW."service_id"
)
BEGIN
    SELECT RAISE(ABORT, 'The service_id which is being ordered has less slots available than mention in the quantity (qty in service_orders).');
END;

-- 9.3 Validating Triggers

-- 9.3.1 Trigger to validate price_at_order matches with table(15) services price
CREATE TRIGGER "validate_price_in_service_orders"
BEFORE INSERT ON "service_orders"
FOR EACH ROW
WHEN NEW."price_at_order" != (
    SELECT "price" FROM "services"
    WHERE "id" = NEW."service_id"
)
BEGIN
    SELECT RAISE(ABORT, 'The service_id price do not match with the actual price.');
END;

-- 9.3.2 Trigger to validate that a user is ordering an available service or not
CREATE TRIGGER "validate_ordering_available_services"
BEFORE INSERT ON "service_orders"
FOR EACH ROW
WHEN (
    SELECT "availability" FROM "services"
    WHERE "id" = NEW."service_id"
) = 0
BEGIN
    SELECT RAISE(ABORT, 'The service_id is not available, and the order cannot be placed.');
END;

-- 9.4 Automating Triggers

-- 9.4.1 Trigger to auto-decrease available slots when a service is ordered
CREATE TRIGGER "auto_update_slots_on_service_order"
AFTER UPDATE ON "service_orders"
FOR EACH ROW
WHEN NEW."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" = 'service-order-confirmed'
) AND OLD."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN  ('service-order-pending', 'service-order-failed', 'service-order-cancelled')
)
BEGIN
    UPDATE "services"
    SET "available_slots" = "available_slots" - NEW."qty"
    WHERE "id" = NEW."service_id";
END;

-- 9.4.2 Trigger to auto-increase available slots when a service order status is completed/cancelled
CREATE TRIGGER "auto_restore_slots_on_service_order_completion_or_cancellation"
AFTER UPDATE ON "service_orders"
FOR EACH ROW
WHEN NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-completed', 'service-order-cancelled')
) AND OLD."status_id" NOT IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-completed', 'service-order-cancelled')
)
BEGIN
    UPDATE "services"
    SET "available_slots" = "available_slots" + NEW."qty"
    WHERE "id" = NEW."service_id";
END;

-- 9.4.3 Trigger to auto-set payment status to pending when service order is confirmed
CREATE TRIGGER "auto_update_payment_status_as_service_order_status_change"
AFTER UPDATE OF "status_id" ON "service_orders"
FOR EACH ROW
WHEN NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-confirmed')
)
BEGIN
    UPDATE "service_payments"
    SET "status_id" = (
        SELECT "id" FROM "payment_statuses"
        WHERE "status" = 'pending'
    )
    WHERE "service_order_id" = OLD."id";
END;

-- 9.4.4 Trigger to auto-refund on service-order-Cancellation
CREATE TRIGGER "auto_refund_payment_after_service_status_on_cancellation"
AFTER UPDATE OF "status_id" ON "service_orders"
FOR EACH ROW
WHEN NEW."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" = 'service-order-cancelled'
) AND OLD."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" = 'service-order-confirmed'
)
AND (
    SELECT "status_id" FROM "service_payments"
    WHERE "service_order_id" = OLD."id"
) = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
)
BEGIN
    UPDATE "service_payments"
    SET "status_id" = (
        SELECT "id" FROM "payment_statuses"
        WHERE "status" = 'refunded'
    )
    WHERE "service_order_id" = OLD."id";
END;

-- 10 Triggers on 'cart_payments' table(13)

-- 10.1 Logging Triggers

-- 10.1.1 Trigger to Log new cart's payment record
CREATE TRIGGER "log_new_cart_payment"
AFTER INSERT ON "cart_payments"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'cart_payments', 'INSERT', CONCAT('new-cart-order-payment-for-cart[id]:',NEW."cart_id",'-added'));
END;

-- 10.1.2 Trigger to Log removed cart's payment record
CREATE TRIGGER "log_removed_cart_payment"
BEFORE DELETE ON "cart_payments"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'cart_payments', 'DELETE', CONCAT('cart-order-payment-for-cart[id]:',OLD."cart_id",'-deleted'));
END;

-- 10.1.3 Trigger to Log updates of cart's payment record
CREATE TRIGGER "log_cart_payment_update"
AFTER UPDATE OF "status_id", "paid_on", "mode_id" ON "cart_payments"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'cart_payments', 'UPDATE', 'status_id', OLD."status_id", NEW."status_id", 'updated-cart(s)_payment-status_id'
    WHERE OLD."status_id" != NEW."status_id";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'cart_payments', 'UPDATE', 'paid_on', OLD."paid_on", NEW."paid_on", 'updated-cart(s)_payment-paid_on'
    WHERE OLD."paid_on" != NEW."paid_on";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'cart_payments', 'UPDATE', 'mode_id', OLD."mode_id", NEW."mode_id", 'updated-cart(s)_payment-mode_id'
    WHERE OLD."mode_id" != NEW."mode_id";
END;

-- 10.2 Restricting Triggers

-- 10.2.1 Trigger to restrict status_id in cart_payments transition if cart's status in user_carts is pending ON INSERT
CREATE TRIGGER "restrict_pending_cart_payment_status_change_on_insert"
BEFORE INSERT ON "cart_payments"
FOR EACH ROW
WHEN (
    (
        SELECT "status_id" FROM "user_carts"
        WHERE "id" = NEW."cart_id"
    ) = (
        SELECT "id" FROM "order_statuses"
        WHERE "status" = 'cart-order-pending'
    )
) AND NEW."status_id" != (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'pending'
)
BEGIN
    SELECT RAISE(ABORT, 'The cart_id status in user_carts is pending, so pending cart(s) cart_payments.status_id cannot be other than pending.');
END;

-- 10.2.2 Trigger to restrict status_id in cart_payments transition if cart's status in user_carts is pending ON UPDATE
CREATE TRIGGER "restrict_pending_cart_payment_status_change_on_update"
BEFORE UPDATE OF "status_id" ON "cart_payments"
FOR EACH ROW
WHEN (
    (
        SELECT "status_id" FROM "user_carts"
        WHERE "id" = NEW."cart_id"
    ) = (
        SELECT "id" FROM "order_statuses"
        WHERE "status" = 'cart-order-pending'
    )
) AND NEW."status_id" != (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'pending'
)
BEGIN
    SELECT RAISE(ABORT, 'The cart_id status in user_carts is pending, so pending cart(s) cart_payments.status_id cannot be other than pending.');
END;

-- 10.2.3 Trigger to restrict updating payment amount/payment mode after payment status is completed
CREATE TRIGGER "restrict_price_mode_update_if_completed_for_cart_payment"
BEFORE UPDATE OF "total_price", "mode_id" ON "cart_payments"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" IN ('completed', 'refunded')
)
BEGIN
    SELECT RAISE(ABORT, 'The total_price/mode_id cannot be updated for a completed payment!');
END;

-- 10.2.4 Trigger to restrict setting payment status to completed if not paid ON INSERT
CREATE TRIGGER "restrict_setting_payment_completed_on_insert_for_cart_payment"
BEFORE INSERT ON "cart_payments"
FOR EACH ROW
WHEN NEW."mode_id" != (
    SELECT "id" FROM "payment_modes"
    WHERE "mode" = 'cash-on-delivery'
) AND NEW."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
) AND NEW."paid_on" IS NULL
BEGIN
    SELECT RAISE(ABORT, 'The status_id cannot be updated as completed as paid_on is NULL!');
END;

-- 10.2.5 Trigger to restrict setting payment status to completed if not paid ON UPDATE
CREATE TRIGGER "restrict_setting_payment_completed_on_update_for_cart_payment"
BEFORE UPDATE OF "status_id", "mode_id", "paid_on" ON "cart_payments"
FOR EACH ROW
WHEN NEW."mode_id" != (
    SELECT "id" FROM "payment_modes"
    WHERE "mode" = 'cash-on-delivery'
) AND NEW."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
) AND NEW."paid_on" IS NULL
BEGIN
    SELECT RAISE(ABORT, 'The status_id cannot be updated as completed as paid_on is NULL!');
END;

-- 10.2.6 Trigger to restrict delete for payments that are either completed/refunded/cancelled
CREATE TRIGGER "restrict_confirmed_payments_delete"
BEFORE DELETE ON "cart_payments"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" NOT IN ('pending', 'failed', 'payment-status-deleted')
)
BEGIN
    SELECT RAISE(ABORT, 'The payment of cart cannot be deleted as its status is completed/refunded/cancelled');
END;

-- 10.3 Automating Triggers

-- 10.3.1 Trigger to auto-update refund logic on Cart-order-Return/Cancellation
CREATE TRIGGER "auto_refund_payment_after_cart_status_return_or_cancelled"
AFTER UPDATE OF "status_id" ON "user_carts"
FOR EACH ROW
WHEN OLD."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-delivered'
) AND NEW."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-returned', 'cart-order-cancelled')
) AND (
    SELECT "status_id" FROM "cart_payments"
    WHERE "cart_id" = OLD."id"
) = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
)
BEGIN
    UPDATE "cart_payments"
    SET "status_id" = (
        SELECT "id" FROM "payment_statuses"
        WHERE "status" = 'refunded'
    )
    WHERE "cart_id" = OLD."id";
END;

-- 11 Triggers on 'service_payments' table(17)

-- 11.1 Logging Triggers

-- 11.1.1 Trigger to Log new service's payment record
CREATE TRIGGER "log_new_service_payment"
AFTER INSERT ON "service_payments"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."id", 'service_payments', 'INSERT', CONCAT('new-service-order-payment-for-service_order[id]:',NEW."service_order_id",'-added'));
END;

-- 11.1.2 Trigger to Log removed service's payment record
CREATE TRIGGER "log_removed_service_payment"
BEFORE DELETE ON "service_payments"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."id", 'service_payments', 'DELETE', CONCAT('service-order-payment-for-service_order[id]:',OLD."service_order_id",'-deleted'));
END;

-- 11.1.3 Trigger to Log updates of service's payment record
CREATE TRIGGER "log_service_payment_update"
AFTER UPDATE OF "status_id", "paid_on", "mode_id" ON "service_payments"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'service_payments', 'UPDATE', 'status_id', OLD."status_id", NEW."status_id", 'updated-service(s)_payment-status_id'
    WHERE OLD."status_id" != NEW."status_id";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'service_payments', 'UPDATE', 'paid_on', OLD."paid_on", NEW."paid_on", 'updated-service(s)_payment-paid_on'
    WHERE OLD."paid_on" != NEW."paid_on";

    INSERT INTO "logs"("record_id", "table", "operation", "column", "old_value", "new_value", "description")
    SELECT OLD."id", 'service_payments', 'UPDATE', 'mode_id', OLD."mode_id", NEW."mode_id", 'updated-service(s)_payment-mode_id'
    WHERE OLD."mode_id" != NEW."mode_id";
END;

-- 11.2 Restricting Triggers

-- 11.2.1 Trigger to restrict payment before service completion or in-progress on order ON INSERT
CREATE TRIGGER "restrict_payment_before_service_completion_or_in_progress_on_insert"
BEFORE INSERT ON "service_payments"
FOR EACH ROW
WHEN NEW."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
) AND (
    SELECT "status_id" FROM "service_orders"
    WHERE "id" = NEW."service_order_id"
) NOT IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-completed', 'service-order-in-progress')
)
BEGIN
    SELECT RAISE(ABORT, "The service_order_id status is not completed/in-progress to mark the payment as completed!");
END;

-- 11.2.2 Trigger to restrict payment before service completion or in-progress on order ON UPDATE
CREATE TRIGGER "restrict_payment_before_service_completion_or_in_progress_on_update"
BEFORE UPDATE OF "status_id" ON "service_payments"
FOR EACH ROW
WHEN OLD."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
) AND (
    SELECT "status_id" FROM "service_orders"
    WHERE "id" = OLD."service_order_id"
) NOT IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" IN ('service-order-completed', 'service-order-in-progress')
)
BEGIN
    SELECT RAISE(ABORT, "The service_order_id status is not completed/in-progress to mark the payment as completed!");
END;

-- 11.2.3 Trigger to restrict changing payment amount after completion
CREATE TRIGGER "restrict_price_mode_update_if_completed_for_service_payment"
BEFORE UPDATE OF "price", "mode_id" ON "service_payments"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" IN ('completed', 'refunded')
)
BEGIN
    SELECT RAISE(ABORT, 'The service_order_id payment was completed! Cannot update the price of completed order!');
END;

-- 11.2.4 Trigger to restrict setting payment status to completed if not paid ON INSERT
CREATE TRIGGER "restrict_setting_payment_completed_on_insert_for_service_payment"
BEFORE INSERT ON "service_payments"
FOR EACH ROW
WHEN NEW."mode_id" != (
    SELECT "id" FROM "payment_modes"
    WHERE "mode" = 'cash-on-delivery'
) AND NEW."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
) AND NEW."paid_on" IS NULL
BEGIN
    SELECT RAISE(ABORT, 'The status_id cannot be updated as completed as paid_on is NULL!');
END;

-- 11.2.5 Trigger to restrict setting payment status to completed if not paid ON UPDATE
CREATE TRIGGER "restrict_setting_payment_completed_on_update_for_service_payment"
BEFORE UPDATE OF "status_id", "mode_id", "paid_on" ON "service_payments"
FOR EACH ROW
WHEN NEW."mode_id" != (
    SELECT "id" FROM "payment_modes"
    WHERE "mode" = 'cash-on-delivery'
) AND NEW."status_id" = (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" = 'completed'
) AND NEW."paid_on" IS NULL
BEGIN
    SELECT RAISE(ABORT, 'The status_id cannot be updated as completed as paid_on is NULL!');
END;

-- 11.2.6 Trigger to restrict delete of completed/refunded/cancelled service orders payments
CREATE TRIGGER "restrict_confirmed_service_payment_delete"
BEFORE DELETE ON "service_payments"
FOR EACH ROW
WHEN OLD."status_id" IN (
    SELECT "id" FROM "payment_statuses"
    WHERE "status" NOT IN ('pending', 'failed', 'payment-status-deleted')
)
BEGIN
    SELECT RAISE(ABORT, 'The service_order payment record cannot be deleted as its status is completed/refunded/cancelled.');
END;

-- 12 Triggers on 'product_ratings' table(14)

-- 12.1 Logging Triggers

-- 12.1.1 Trigger to log new rating for a product_model
CREATE TRIGGER "log_new_product_rating"
AFTER INSERT ON "product_ratings"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."user_id", 'product_ratings', 'INSERT', CONCAT('new-rating-for-product_model[id]:',NEW."product_model_id",'-added'));
END;

-- 12.1.2 Trigger to log removed rating for a product_model
CREATE TRIGGER "log_removed_product_rating"
BEFORE DELETE ON "product_ratings"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."user_id", 'product_ratings', 'DELETE', CONCAT('rating-for-product_model[id]:',OLD."product_model_id",'-deleted'));
END;

-- 12.2 Validating Triggers

-- 12.2.1 Trigger to validate whether the user is eligible to write a review or give a rating ON INSERT
CREATE TRIGGER "validate_user_eligibility_to_give_product_rating_on_insert"
BEFORE INSERT ON "product_ratings"
FOR EACH ROW
WHEN NEW."product_model_id" NOT IN (
    SELECT "product_model_id" FROM "product_orders"
    WHERE "cart_id" IN (
        SELECT "id" FROM "user_carts"
        WHERE "user_id" = NEW."user_id"
        AND "status_id" IN (
            SELECT "id" FROM "order_statuses"
            WHERE "status" IN ('cart-order-delivered', 'cart-order-returned', 'cart-order-self-pick-up')
        )
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The user_id mentioned has not yet ordered/received the product_model to give rating!');
END;

-- 12.2.2 Trigger to validate whether the update of rating or comment was done for the intended user's ordered-product-model
CREATE TRIGGER "validate_product_model_rating_correctly_updated"
BEFORE UPDATE OF "rating", "comment" ON "product_ratings"
FOR EACH ROW
WHEN (
    OLD."user_id" != NEW."user_id"
    OR OLD."product_model_id" != NEW."product_model_id"
)
BEGIN
    SELECT RAISE(ABORT, 'The update on rating/comment is not being intending for the target user_id or product_model_id!');
END;

-- 13 Triggers on 'service_ratings' table(18)

-- 13.1 Logging Triggers

-- 13.1.1 Trigger to log the new service_ratings
CREATE TRIGGER "log_new_service_rating"
AFTER INSERT ON "service_ratings"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (NEW."user_id", 'service_ratings', 'INSERT', CONCAT('new-rating-for-service[id]:',NEW."service_id",'-added'));
END;

-- 13.1.2 Trigger to log the removed service_ratings
CREATE TRIGGER "log_removed_service_rating"
BEFORE DELETE ON "service_ratings"
FOR EACH ROW
BEGIN
    INSERT INTO "logs"("record_id", "table", "operation", "description")
    VALUES
    (OLD."user_id", 'service_ratings', 'DELETE', CONCAT('rating-for-service[id]:',OLD."service_id",'-deleted'));
END;

-- 13.2 Validating Triggers

-- 13.2.1 Trigger to validate whether the user is eligible to write a review or give a rating ON INSERT
CREATE TRIGGER "validate_user_eligibility_to_give_service_rating_on_insert"
BEFORE INSERT ON "service_ratings"
FOR EACH ROW
WHEN NEW."service_id" NOT IN (
    SELECT "service_id" FROM "service_orders"
    WHERE "service_orders"."user_id" = NEW."user_id"
    AND "service_orders"."status_id" IN (
        SELECT "id" FROM "order_statuses"
        WHERE "status" IN ('service-order-in-progress', 'service-order-completed')
        AND "type" = 'service'
    )
)
BEGIN
    SELECT RAISE(ABORT, 'The user_id mentioned has not yet ordered/received the service to give rating!');
END;

-- 13.2.2 Trigger to validate whether the update of rating or comment was done for the intended user's ordered-product-model
CREATE TRIGGER "validate_service_rating_correctly_updated"
BEFORE UPDATE OF "rating", "comment" ON "service_ratings"
FOR EACH ROW
WHEN (
    OLD."user_id" != NEW."user_id"
    OR OLD."service_id" != NEW."service_id"
)
BEGIN
    SELECT RAISE(ABORT, 'The update on rating/comment is not being intending for the target user_id or service_id!');
END;
