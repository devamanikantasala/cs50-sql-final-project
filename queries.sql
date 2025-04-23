-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- A) The following are the lookup tables data and they are essential and play vital role for the schema functionality (except "locations", "market_domains")

-- A.1: The below insert-statement states the locations where NEIGHBOURLY HUBs exist, just for now India, the following is the sample (and imaginary!) data
INSERT INTO "locations"("municipality", "district", "state", "country", "pincode")
VALUES
('Anantapur', 'Anantapur', 'Andhra Pradesh', 'India', '515001'),
('Tadpatri', 'Anantapur', 'Andhra Pradesh', 'India', '515411'),
('Guntakal', 'Anantapur', 'Andhra Pradesh', 'India', '515801'),
('Chittoor', 'Chittoor', 'Andhra Pradesh', 'India', '517001'),
('Kolar', 'Kolar', 'Karnataka', 'India', '563101'),
('Mysore', 'Mysore', 'Karnataka', 'India', '570001'),
('Mandya', 'Mandya', 'Karnataka', 'India', '571401'),
('Hassan', 'Hassan', 'Karnataka', 'India', '573201'),
('Kanhangad', 'Kasaragod', 'Kerala', 'India', '671315'),
('Malappuram', 'Malappuram', 'Kerala', 'India', '676505'),
('Palakkad', 'Palakkad', 'Kerala', 'India', '678001'),
('Thrissur', 'Thrissur', 'Kerala', 'India', '680001'),
('Thane', 'Thane', 'Maharashtra', 'India', '400601'),
('Panvel', 'Raigarh', 'Maharashtra', 'India', '410206'),
('Pune', 'Pune', 'Maharashtra', 'India', '411001'),
('Solapur', 'Solapur', 'Maharashtra', 'India', '413001'),
('Secunderabad', 'Hyderabad', 'Telangana', 'India', '500003'),
('Adilabad', 'Adilabad', 'Telangana', 'India', '504001'),
('Karimnagar', 'Karimnagar', 'Telangana', 'India', '505001'),
('Ramagundam', 'Karimnagar', 'Telangana', 'India', '505208');

-- A.2: The below insert-statement states default domains that might available in each location's marketplace
INSERT INTO "market_domains"("id","type", "domain") VALUES
(0,'both', 'removed-domain'),
(1,'product', 'agri-farming-products'),
(2,'product', 'auto-accessories'),
(3,'product', 'beauty-personal-care'),
(4,'product', 'books-stationery'),
(5,'product', 'construction-home-goods'),
(6,'product', 'cultural-religious-goods'),
(7,'product', 'eco-sustainable-disposables'),
(8,'product', 'food-bev-retail'),
(9,'product', 'health-wellness-products'),
(10,'product', 'home-garden-accessories'),
(11,'product', 'industrial-mfg-equipment'),
(12,'product', 'jewelry-luxury-goods'),
(13,'product', 'music-entertainment-products'),
(14,'product', 'pet-animal-supplies'),
(15,'product', 'plastic-packaging-supplies'),
(16,'product', 'general-retail'),
(17,'product', 'used-refurbished-goods'),
(18,'product', 'sports-fitness-gear'),
(19,'product', 'tech-gadgets'),
(20,'product', 'textiles-fabrics-wholesale'),
(21,'product', 'wholesale-bulk-goods'),
(22,'service', 'agri-consulting-services'),
(23,'service', 'astrology-numerology-palmistry'),
(24,'service', 'auto-repair-services'),
(25,'service', 'construction-home-services'),
(26,'service', 'eco-pest-control-services'),
(27,'service', 'education-learning-services'),
(28,'service', 'electronics-repair-services'),
(29,'service', 'entertainment-recreation-services'),
(30,'service', 'event-wedding-planning'),
(31,'service', 'financial-business-services'),
(32,'service', 'food-bev-services'),
(33,'service', 'govt-civic-services'),
(34,'service', 'health-wellness-services'),
(35,'service', 'local-personal-services'),
(36,'service', 'luxury-lifestyle-services'),
(37,'service', 'media-advertising-services'),
(38,'service', 'misc-repair-services'),
(39,'service', 'private-investigation-security'),
(40,'service', 'senior-elder-care-services'),
(41,'service', 'solar-green-energy-services'),
(42,'service', 'tattoo-piercing-studios'),
(43,'service', 'travel-hospitality-services');

-- A.3: The below insert-statement is the default-order statuses that might a product/service order might go through
INSERT INTO "order_statuses"("id","type", "status")
VALUES
(0,'both', 'order-status-deleted'),
(1,'product', 'cart-order-pending'),
(2,'product', 'cart-order-confirmed'),
(3, 'product', 'cart-order-out-for-delivery'),
(4,'product', 'cart-order-delivered'),
(5,'product', 'cart-order-self-pick-up'),
(6,'product', 'cart-order-returned'),
(7,'product', 'cart-order-cancelled'),
(8,'product', 'cart-order-failed'),
(9,'service', 'service-order-pending'),
(10,'service', 'service-order-confirmed'),
(11,'service', 'service-order-in-progress'),
(12,'service', 'service-order-completed'),
(13,'service', 'service-order-cancelled'),
(14,'service', 'service-order-failed');

-- A.4: The below insert-statement is the default-payment statuses that might a product/service order might go through
INSERT INTO "payment_statuses"("id","status")
VALUES
(0,'payment-status-deleted'),
(1,'pending'),
(2,'completed'),
(3,'failed'),
(4,'refunded'),
(5,'cancelled');

-- A.5: The below insert-statement is the default-payment modes that might a product/service order might go through
INSERT INTO "payment_modes"("mode")
VALUES
('cash-on-delivery'),
('debit-card'),
('credit-card'),
('UPI'),
('paypal'),
('apple-pay'),
('google-pay'),
('amazon-pay'),
('paytm'),
('phonepe');

-- A.6: The below insert-statement is the featured user that points to the self-pick up option selected by users, those who order items and pick themselves in their local store
INSERT INTO "users"("id", "name", "username", "password", "age", "gender", "phone", "email", "address", "location_id", "user_role")
VALUES
(0, 'self-pick-up', 'self_pickup', 'feature_user', 13, 'OTHER', '+91-XXXXXXXXX', NULL, 'street-1.A/D5', 1, 'delivery_agent');

-- B. The following are the typical queries that the users might run on the database

-- B.1 Queries that business_owner user_role users query

-- B.1.1 A business_owner might query, which product_model has less stock than expected, which requires restocking
SELECT "product_models"."product_id" AS "product_id",
"products"."name" AS "product_name",
"product_models"."id" AS "product_model_id",
"product_models"."available_stock" AS "available_stock",
"product_models"."price" AS "selling_price"
FROM "product_models"
LEFT JOIN "products" ON "products"."id" = "product_models"."product_id"
WHERE "products"."business_id" = 2 -- the user (business_owner's) business id
ORDER BY "product_models"."available_stock" ASC;

-- B.1.2 A business_owner might update, the available stock after getting new stock
UPDATE "product_models"
SET "available_stock" = 1000 -- New stock value
WHERE "id" = 4 -- User provides the model's id for new stocking product
AND "product_id" = 2; -- User also points the product's id for which product does he/she intended to re-stock

-- B.1.3 A business_owner might query the list of product_models which are expired
SELECT "product_models"."id" AS "product_model_id",
"product_models"."product_id" AS "product_id",
"products"."name" AS "product_name",
"product_models"."exp_date" AS "expire_date"
FROM "product_models"
LEFT JOIN "products" ON "products"."id" = "product_models"."product_id"
WHERE "products"."business_id" = 2 -- user's business_id for which he owns
AND DATE("product_models"."exp_date") < DATE('now');

-- B.1.4 A business_owner might query to assess the pending orders for their products.
SELECT "product_models"."id" AS "product_model_id",
"product_models"."product_id" AS "product_id",
"products"."name" AS "product_name",
"product_orders"."qty" AS "quantity_ordered",
"user_carts"."id" AS "cart_id",
"order_statuses"."status" AS "order_status"
FROM "product_models"
LEFT JOIN "products" ON "products"."id" = "product_models"."product_id"
LEFT JOIN "product_orders" ON "product_orders"."product_model_id" = "product_models"."id"
LEFT JOIN "user_carts" ON "user_carts"."id" = "product_orders"."cart_id"
LEFT JOIN "order_statuses" ON "order_statuses"."id" = "user_carts"."status_id"
WHERE "user_carts"."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" = 'cart-order-pending'
) AND "products"."business_id" = 2; -- User's business's id

-- B.1.5 A business_owner might query to assess completed product_orders in last week for revenue calculations
SELECT "product_models"."id" AS "product_model_id",
"products"."id" AS "product_id",
"products"."name" AS "product_name",
"product_orders"."qty" AS "quantity_ordered",
"product_orders"."price_at_order" AS "price_per_item",
"user_carts"."id" AS "cart_id",
"order_statuses"."status" AS "order_status",
"user_carts"."ordered_on" AS "ordered_on"
FROM "product_models"
INNER JOIN "products" ON "products"."id" = "product_models"."product_id"
INNER JOIN "product_orders" ON "product_orders"."product_model_id" = "product_models"."id"
INNER JOIN "user_carts" ON "user_carts"."id" = "product_orders"."cart_id"
INNER JOIN "order_statuses" ON "order_statuses"."id" = "user_carts"."status_id"
WHERE "user_carts"."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-delivered', 'cart-order-self-pick-up')
) AND DATE("user_carts"."ordered_on") >= DATE('now', '-7 days') -- it can vary, whether it is for last week or last month based on user's selection
AND DATE("user_carts"."ordered_on") <= DATE('now')
AND "products"."business_id" = 2; -- user's business's id

-- B.1.5.1 A business_owner might query to assess his/her revenue on completed product_orders for last week
SELECT SUM("product_orders"."qty" * "product_orders"."price_at_order") AS "total_revenue_last_week"
FROM "product_models"
INNER JOIN "products" ON "products"."id" = "product_models"."product_id"
INNER JOIN "product_orders" ON "product_orders"."product_model_id" = "product_models"."id"
INNER JOIN "user_carts" ON "user_carts"."id" = "product_orders"."cart_id"
WHERE "user_carts"."status_id" IN (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'product'
    AND "status" IN ('cart-order-delivered', 'cart-order-self-pick-up')
) AND DATE("user_carts"."ordered_on") >= DATE('now', '-7 days') -- it can vary, whether it is for last week or last month based on user's selection
AND DATE("user_carts"."ordered_on") <= DATE('now')
AND "products"."business_id" = 2; -- user's business's id

-- B.1.6 A business_owner might assess the average rating for his/her all products
SELECT "products"."id" AS "product_id",
"products"."name" AS "products"."name",
"product_models"."id" AS "product_model_id",
IFNULL("product_ratings"."rating", 0.0) AS "model_avg_rating",
IFNULL(COUNT("product_ratings"."rating"),0) AS "number_of_ratings"
FROM "products"
INNER JOIN "product_models" ON "product_models"."product_id" = "products"."id"
LEFT JOIN "product_ratings" ON "product_ratings"."product_model_id" = "product_models"."id"
WHERE "products"."business_id" = 2 -- user's business's id
GROUP BY "products"."id",
"products"."name",
"product_models"."id"
ORDER BY "products"."id",
"product_models"."id";

-- B.1.7 A business_owner might assess the average rating for his/her all services
SELECT "services"."id" AS "service_id",
"services"."name" AS "service_name",
IFNULL("service_ratings"."rating", 0.0) AS "service_avg_rating",
IFNULL(COUNT("service_ratings"."rating"),0) AS "number_of_ratings"
FROM "services"
LEFT JOIN "service_ratings" ON "service_ratings"."service_id" = "services"."id"
WHERE "services"."business_id" = 2 -- user's business's id
GROUP BY "services"."id",
"services"."name"
ORDER BY "services"."id";

-- B.1.8 A business owner might query to assess completed service_orders in last week for revenue calculations
SELECT "services"."id" AS "service_id",
"services"."name" AS "service_name",
"service_orders"."qty" AS "quantity_ordered",
"service_orders"."price_at_order" AS "price_per_item",
"service_orders"."id" AS "order_id",
"order_statuses"."status" AS "order_status",
"service_orders"."ordered_on" AS "ordered_on"
FROM "services"
INNER JOIN "service_orders" ON "service_orders"."service_id" = "services"."id"
LEFT JOIN "order_statuses" ON "service_orders"."status_id" = "order_statuses"."id"
WHERE "service_orders"."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" = 'service-order-completed'
) AND DATE("service_orders"."ordered_on") >= DATE('now', '-7 days') -- it can vary, whether it is for last week or last month based on user's selection
AND DATE("service_orders"."ordered_on") <= DATE('now')
AND "services"."business_id" = 3; --user's business's id

-- B.1.8.1 A business_owner might query to assess his/her revenue on completed service_orders for last week
SELECT SUM("service_orders"."qty" * "service_orders"."price_at_order") AS "total_revenue_last_week"
FROM "services"
INNER JOIN "service_orders" ON "service_orders"."service_id" = "services"."id"
WHERE "service_orders"."status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "type" = 'service'
    AND "status" = 'service-order-completed'
) AND DATE("service_orders"."ordered_on") >= DATE('now', '-7 days') -- it can vary, whether it is for last week or last month based on user's selection
AND DATE("service_orders"."ordered_on") <= DATE('now')
AND "services"."business_id" = 3; -- user's business's id

-- B.2 Queries that customer user_role users query
-- B.2.1: A customer might search for a product or service by name
SELECT "business_id", "name", "price"
FROM "products"
WHERE "name" LIKE '%glue%'
ORDER BY "price" DESC; -- as some customers prefer to go with high cost

SELECT "business_id", "name", "price"
FROM "services"
WHERE "name" LIKE '%engine%-repair%'
ORDER BY "price" ASC; -- as some customers prefer to go with low cost

-- B.2.2: A customer might search for a product's model, based on price low-to-high
SELECT "products"."name" AS "product_name",
"product_models"."id" AS "product_model_id",
"size", "color",
"weight_kg", "material",
"price", "available_stock",
"min_order_qty", "mfg_date", "exp_date"
FROM "product_models"
LEFT JOIN "products" ON "products"."id" = "product_models"."product_id"
WHERE "products"."name" LIKE '%millet%'
ORDER BY "price" ASC;

-- B.2.3: A customer might also search for the all available businesses in his/her location
SELECT "name" FROM "businesses"
WHERE "location_id" = (
    SELECT "id" FROM "locations"
    WHERE "pincode" LIKE '534260' -- Some location attribute, it can also be municipality name
);

-- B.2.4: A customer might also search for all the available products/services in his/her location
-- B.2.4.1 Available Products
SELECT "locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
GROUP_CONCAT("products"."name") AS "products"
FROM "locations"
LEFT JOIN "businesses" ON "businesses"."location_id" = "locations"."id"
LEFT JOIN "products" ON "products"."business_id" = "businesses"."id"
WHERE "locations"."municipality" LIKE 'kakinada' -- a city in andhra-pradesh state in India, a user can also search by using the locations.id
GROUP BY "locations"."id";

-- B.2.4.2 Available Services
SELECT "locations"."municipality" AS "municipality",
"locations"."country" AS "country",
"locations"."pincode" AS "pincode",
GROUP_CONCAT("services"."name") AS "services"
FROM "locations"
LEFT JOIN "businesses" ON "businesses"."location_id" = "locations"."id"
LEFT JOIN "services" ON "services"."business_id" = "businesses"."id"
WHERE "locations"."municipality" LIKE 'kakinada' -- a city in andhra-pradesh state in India, a user can also search by using the locations.id
GROUP BY "locations"."id";

-- B.2.5 A customer can give rating to the product_model or service that he/she ordered
-- B.2.5.1 Product_Model Rating
INSERT INTO "product_ratings"("user_id", "product_model_id", "rating", "comment")
VALUES
(4, 5, 4.2, 'Very good product, the price is so reasonable.'); -- here, user-4 giving rating for model-5 with 4.2 rating and comment

-- B.2.5.2 Service Rating
INSERT INTO "service_ratings"("user_id", "service_id", "rating", "comment")
VALUES
(2, 3, 4.0, 'Very good service, the price is a bit high though.'); -- here, user-2 giving rating for model-3 with 4.0 rating and comment

-- B.2.6 A customer can update his/her rating on product_model or service that they ordered
-- B.2.6.1 Product_Model Rating
UPDATE "product_ratings"
SET "rating" = 3.5,
"comment" = 'Product looks okay, but dis-satisfied with quality'
WHERE "user_id" = 4; -- Customer updates the product_model's rating

-- B.2.6.2 Service Rating
UPDATE "service_ratings"
SET "rating" = 2.3,
"comment" = 'Service is done in time, but the quality of their work is doomed.'
WHERE "user_id" = 2; -- Customer updates the service's rating

-- B.2.7 A Customer reviews the ratings and comments before buying anything so he can access the ratings and comments for the product_model/service
-- B.2.7.1 Product_Model Rating Access
SELECT "rating", "comment" FROM "product_ratings"
WHERE "product_model_id" IN (
    SELECT "id" FROM "product_models"
    WHERE "product_id" IN (
        SELECT "id" FROM "products"
        WHERE "name" = '%glue%' -- as the customer initially searches for the product he/she wants
    )
);

-- B.2.7.2 Service Rating Access
SELECT "rating", "comment" FROM "service_ratings"
WHERE "service_id" IN (
    SELECT "id" FROM "services"
    WHERE "name" = '%auto%repair' -- as the customer initially searches for the service he/she wants
);

-- B.2.8 A Customer can update his account's username, address, phone etc. Example:
UPDATE "users"
SET "phone" = '+91-1234567890'
WHERE "id" = 3
AND "user_role" = 'customer';

-- B.3 Queries that delivery_agent users query

-- B.3.1 A delivery_agent might view his/her assigned deliveries for the day
SELECT "user_carts"."id" AS "cart_id",
"users"."name" AS "customer_name",
"users"."phone" AS "customer_phone",
"users"."address" AS "delivery_address",
"order_statuses"."status" AS "order_status"
FROM "user_carts"
INNER JOIN "users" ON "user_carts"."user_id" = "users"."id"
INNER JOIN "order_statuses" ON "user_carts"."status_id" = "order_statuses"."id"
WHERE "user_carts"."delivery_agent_id" = 11 -- the id of the user who queries and is a delivery agent
AND "order_statuses"."status" = 'cart-order-out-for-delivery';

-- B.3.2 A delivery_agent update the status to delivered/failed after deliverying the product
UPDATE "user_carts"
SET "status_id" = (
    SELECT "id" FROM "order_statuses"
    WHERE "status" = 'cart-order-delivered' -- it can also be done for failed delivery
    AND "type" = 'product'
)
WHERE "id" = 3 -- The cart_id where the it needs to be updated
AND "delivery_agent_id" = 11; -- the id of the user who updates the status of a particular cart

-- B.3.3 A delivery_agent might assess completed deliveries for commission calculation in last 30 days
SELECT COUNT("user_carts"."id") AS "completed_deliveries_last_30_days"
FROM "user_carts"
INNER JOIN "order_statuses" ON "user_carts"."status_id" = "order_statuses"."id"
WHERE "user_carts"."delivery_agent_id" = 11 -- delivery_agent's id who accessing the data
AND "order_statuses"."status" = 'cart-order-delivered'
AND DATE("user_carts"."ordered_on") >= DATE('now', '-30 days')
AND DATE("user_carts"."ordered_on") <= DATE('now');

-- B.3.4 A delivery_agent might assess the upcoming or scheduled deliveries like orders which are confirmed and not yet for out for delivery
SELECT "user_carts"."id" AS "cart_id",
"users"."name" AS "customer_name",
"users"."address" AS "delivery_address",
"order_statuses"."status" AS "order_status",
"user_carts"."ordered_on" AS "ordered_on"
FROM "user_carts"
INNER JOIN "users" ON "users"."id" = "user_carts"."user_id"
INNER JOIN "order_statuses" ON "order_statuses"."id" = "user_carts"."status_id"
WHERE "user_carts"."delivery_agent_id" = 11 -- the delivery_agent_id where he/she is assessing their upcoming deliveries
AND "order_statuses"."status" = 'cart-order-confirmed' -- which states the upcoming orders or scheduled deliveries for the orders
ORDER BY "user_carts"."ordered_on";

