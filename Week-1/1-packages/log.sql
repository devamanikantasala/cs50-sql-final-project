
-- *** The Lost Letter ***
-- Question 1 and 2. To find the 'type of address' and 'address name' where the package ended up

SELECT "type", "address" FROM "addresses" WHERE "id" = (
    SELECT "address_id" FROM "scans" WHERE "package_id" = (
        SELECT "id" FROM "packages" WHERE "from_address_id" = (
            SELECT "id" FROM "addresses" WHERE "address" = "900 Somerville Avenue" -- finding the from_address_id to ensure that the specified address exist
        ) AND "to_address_id" = (
            SELECT "id" FROM "addresses" WHERE "address" LIKE '2 Fi%' -- finding the to_address_id as the specified address is misspelled and incorrect, so I thought I could use LIKE operator
        ) -- based on the "from_address_id" and "to_address_id" here I am getting to know the "id" of the package and I also ensured that the package is a "congratulatory letter" by running SELECT * from "packages".....
    ) AND "action" = 'Drop' -- to evaluate the delivered/package dropped address type I specified action = 'Drop' to ensure that difference between picked and dropped.
); -- This query brings up the type of address where the package ended up i.e Residential and the address name for the second question i.e 2 Finnigan Street.


-- *** The Devious Delivery ***

-- So As per the 1st question in the answers.txt to find the type of address where it is ended up

SELECT "type" FROM "addresses" WHERE "id" = (
    SELECT "address_id" FROM "scans" WHERE "package_id" = (
        SELECT "id" FROM "packages" WHERE "from_address_id" IS NULL -- As there is no "from address" based on the customer's statement, I need to find the package-id where the "from address" is NULL.
    ) AND "action" = 'Drop' -- So, package id = 5098, Now based on the inner query I got information about the package, Now I would like to find where does it ended up
    --As 'Drop' action of the package in "scans" table states that it was ended up at 348 address_id. Finally we need to find the type of address
); -- Hence 'Parent query' evaluates the type of the address that the package is ended up

-- Now as per the second question in the answers.txt thed contents of the devious delivery can be evaluated from

SELECT "contents" FROM "packages" WHERE "from_address_id" IS NULL;

-- so simply this states that "contents" of the package which has "from_address_id" is NULL, which was also stated in the customer request there is no from address
-- I used this simple line to find the contents of the package. This brings me up that content of the package is "Duck debugger"


-- *** The Forgotten Gift ***

-- As the first question questions - What are the contents of the package?
SELECT "contents" FROM "packages" WHERE "from_address_id" = (
    SELECT "id" FROM "addresses" WHERE "address" = '109 Tileston Street' -- I used this query to get insight(ID) on "from_address" where the customer stated.
); -- I used the "contents" column to find what are the contents of the package, based on the "from_address_id", where that was evaluated in "sub-query"

-- As the second question questions - Who has the forgotten gift?
SELECT "name" FROM "drivers" WHERE "id" = (
    SELECT "driver_id" FROM "scans" WHERE "package_id" = (
        SELECT "id" FROM "packages" WHERE "from_address_id" = (
            SELECT "id" FROM "addresses" WHERE "address" = '109 Tileston Street' -- here, I am getting the from-address ID
        ) -- here, I am trying to extract the driver_id who picked the package second time in the intermediary delivery processing station.
    ) ORDER BY "timestamp" DESC -- I used ORDER BY timestamp to find the latest record of the driver who picked up to show the difference between package pickup in customer address and address of the intermediary delivery station.
    -- through this I am getting the driver_id, where this could further helps me to evaluate who has the package i.e Forgotten Gift.
);
