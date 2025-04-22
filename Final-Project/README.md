# Design Document

By Deva Manikanta Sala

## Video overview
<iframe width="560" height="315" src="https://www.youtube.com/watch?v=MMgJIS7Ynz0" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
## Scope

The database for CS50 SQL project, I worked on this project and named as **Neighbourly**, which is a **Local Marketplace Support System**. The database that I had designed includes all entities which are necessary to support the process of local businesses, connecting customers, business owners, and delivery agents. The database handles the listing of products and services, order placement, payment tracking, delivery agent assignment, and user's ratings, and system logging. As such, included in the database's scope is:
* **Users**, like Customers, Business-Owners, Delivery-Agents, including basic information like name, username, password, location, address and role etc.
* **Businesses**, which include owner information, location & address, operating hours, and the market domains they belong to.
* **Products**, that are offered by businesses, including the particular product's models, pricing, stock levels, and category they belong.
* **Services**, that are also offered by businesses, which includes the information about their availability, pricing, duration, and categories.
* **Product Orders**, the orders are done through and represented by **User Carts**, which hold information related to order status, items ordered, quantities, price at time of order, and assigned delivery agents or user's self pick (as the system is dedicated to local marketplace support).
* **Service Orders**, the orders that are requested or booked by the users to receive service, which includes order status, service details, quantity, and price at the time of order.
* **Payments**, for both product and service orders, the payment section holds information like payment-status, payment-mode, amount-paid or to-be-paid, and paid-on (date or timestamp).
* **Ratings and comments**, which are provided by users for products and services they have received.
* Operational **Locations**, including the information about the areas where this system operates and manages its operations.
* **Market Domains**, to determine in classifying businesses, products, and services.
* **System Logs**, as tracking is the significant aspect for data movements (Insertions, Deletions, Updations) across **core** and **lookup** tables, which extends scope for, analysis for future assessments, and for decision making.

Out of scope for this project involve aspects like direct user-to-user messaging, complex promotional or discount systems, delivery agent commission tracking, detailed inventory management, specific payment gateway operations, and advanced delivery route optimization.

## Functional Requirements

The database will support:

* CRUD operations for users (all roles), businesses, products (and product's models), and services.
* Association of businesses with relevant market domains (products/services).
* Tracking product orders (via carts) through various statuses (pending, confirmed, out-for-delivery, delivered, cancelled, etc.).
* Tracking service orders through various statuses (pending, confirmed, in-progress, completed, cancelled, etc.).
* Managing product stock levels automatically, based on order confirmation and cancellation/returns (with triggers).
* Managing service availability slots automatically based on order confirmation and completion/cancellation (with triggers).
* Assigning delivery agents to product orders (user's carts).
* Recording payments associated with product carts and service orders, including different payment modes and statuses (pending, completed, refunded, etc.).
* Allowing users to rate and comment on products (and product's models) and services they have completed/received.
* Implementing business logic and data integrity through use of column-constraints, table-constraints, foreign-key-constraints and triggers (e.g., user role validation for business ownership, status transition restrictions, password history checks, rating eligibility etc.).
* Logging significant data movements, changes in core tables with a dedicated **logs** table.
* Provides various pre-defined views for simplified querying of common information patterns (e.g., user counts per location, product/service summaries, active users, pending payments, top sellers etc.).

## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities:

#### `A. LOOKUP TABLES`

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-1`: **`locations`**</u>
The `locations` table holds information about the locations where this system's hubs operates and manages it operations so that the users can use it for digital collaboration with their customers and business owners.

It includes:
* `id`, which specifies the unique ID for each location as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `municipality`, which specifies the town, city or village name as `TEXT`.
* `district`, which specifies the district name as `TEXT` that the corresponding `municipality` exist.
* `state`, which specifies the state name as `TEXT` that the corresponding `municipality` and `district` exist in.
* `country`, which specifies the country name as `TEXT` that the corresponding `municipality`, `district`, and `state` exist in.
* `pincode`, which specifies the zip-code or pincode of the location as `TEXT`, which helps uniquely identifies a location precisely, the reason for storing it as a `TEXT` is, as some pincodes involve special characters and can be of any length between 4 and 10.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-2`: **`market_domains`**</u>
The `market_domains` table holds information about the different domains of the businesses that are available in most of the markets.

It includes:
* `id`, which specifies the unique ID for each market domain as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `type`, which specifies the type of the domain as `TEXT`, which has few pre-defined values with a `CHECK` constraint applied, that determines whether the domain belongs to *product*, *service* or *both*.
* `domain`, which specifies the name of the domain as `TEXT`.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-3`: **`order_statuses`**</u>
The `order_statuses` table holds information for the types of statuses for all products and services orders.

It includes:
* `id`, which specifies the unique ID for each order status as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `type`, which specifies the type of the order as `TEXT`, which has few pre-defined values with a `CHECK` constraint applied, that determines whether the order belongs to *product*, *service* or *both*.
* `status`, which specifies the name of the order-status as `TEXT`, and each order-status is unique, thus `UNIQUE` constraint applied.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-4`: **`payment_statuses`**</u>
The `payment_statuses` table holds information for the types of statuses for all product and service orders payments.

It includes:
* `id`, which specifies the unique ID for each order's payment status as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `status`, which specifies the name of the payment-status as `TEXT`, and each payment-status is unique, thus `UNIQUE` constraint applied.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-5`: **`payment_modes`**</u>
The `payment_modes` table holds information for the types of modes that a payment was made through for a product or service order.

It includes:
* `id`, which specifies the unique ID for each order's payment mode as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `mode`, which specifies the name of the payment-mode as `TEXT`, and each payment-mode is unique, thus `UNIQUE` constraint applied.

#### `B. CORE TABLES`

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-6`: **`users`**</u>
The `users` table holds information of every user, the user can be a customer, business_owner, and delivery_agent.

It includes:
* `id`, which specifies the unique ID for each user as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `name`, which specifies the full-name or actual-name of the user as `TEXT`.
* `username`, which specifies the user's simple identifiable name i.e username as `TEXT`, and to ensure each and every user has unique username `UNIQUE` constraint applied, including that a `CHECK` constraint also applied to check the length of the username of user's.
* `password`, which specifies the user's password that he/she uses to sign in or sign up to the system, at the application level it can be hashed with a specific algorithm, but due to the limitations of SQLite3 I applied `TEXT` as it's type, and also applied `CHECK` constraint to check the length of the user's password.
* `age`, which specifies the user's age as an `INTEGER`, and I enforced a `CHECK` constraint to check whether the `age` mentioned is valid or not.
* `gender`, which specifies the gender of the user as `TEXT`, and included a `CHECK` constraint to validate the gender to be in pre-defined values.
* `phone`, which specifies the mobile/phone number of the user's, having a `CHECK` constraint to validate the format and length of the user's phone-number, as a phone number contains the special characters `TEXT` type used, and as the phone number must needs to be unique for each and every user `UNIQUE` constraint used.
* `email`, which specifies the email of the user's as `TEXT`, and included a `CHECK` constraint to validate the format and length of the email, enforced a `UNIQUE` constraint to ensure the user's email must be unique to another users, and added a `DEFAULT` constraint with `NULL` value, as some user's might not interested to provide the email based on their consent.
* `address`, which specifies the address of the user's as `TEXT`.
* `location_id`, which specifies the `PRIMARY KEY` of the `locations` table, that is being referenced to as the id of the location where the `address` might correspond to, thus the `FOREIGN KEY` constraint links this to `locations` table.
* `user_role`, which specifies the role of the user that the system is being used as `TEXT`, included pre-defined user roles to the schema by using `CHECK` constraint to validate the `user_role`.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-7`: **`businesses`**</u>
The `businesses` table holds the basic information about all the businesses.

It includes:
* `id`, which specifies the unique ID for each business as an `INTEGER`. This column thus has the `PRIMARY KEY` constraint applied.
* `owner_id`, which specifies the ID of the user who has `business_owner` role in `users` table, that is being referenced to as id of the user in `users`, , thus the `FOREIGN KEY` constraint links this to `users` table.
* `name`, which specifies the name of the business as `TEXT`.
* `address`, which specifies the address of the business as `TEXT`.
* `location_id`, which specifies the `PRIMARY KEY` of the `locations` table, that is being referenced to as the id of the location where the `address` might correspond to, thus the `FOREIGN KEY` constraint links this to `locations` table.
* `open_time` and `close_time`, the both specifies the timing of the business working hours which has given `NUMERIC` type, which is relevant to store time/date type data, and also implemented `DEFAULT` values to maintain `NULL` free records.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-8`: **`business_associations`**</u>
The `business_associations` is the associative/junction table that holds the information which business belongs to which domain

It includes:
* `business_id`, which specifies `INTEGER` that references to the `id` in `businesses` table, to point out the one or more domains maintained by the same business. For example: A restaurant can deliver the food they make as a product `(product-based-domain)`, and the same restaurant can also serve their customers as a service `(service-based-domain)`, thus the `FOREIGN KEY` constraint links this to `business` table.
* `domain_id`, which specifies `INTEGER` that references to the `id` in `market_domains` table, that points the actual domain the business is pointing out, thus the `FOREIGN KEY` constraint links this to `market_domains` table.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-9`: **`products`**</u>
The `products` table holds the information of the product's name, business that is selling, and what category or market domain does it belong etc.

It includes:
* `id`, which specifies the unique ID for the product as `INTEGER`. Thus this column has the `PRIMARY KEY` constraint applied.
* `business_id`, which specifies the ID as `INTEGER`, that the business that owns the product, and that ID is being referenced from `businesses` table, thus the `FOREIGN KEY` constraint links this to `businesses` table.
* `name`, which specifies the name of the product as `TEXT`.
* `category_id`, which specifies the ID of the domain i.e category, which is being referenced from `market_domains` table, as a product might belong to certain category or domain for extra detail, thus the `FOREIGN KEY` constraint links this to `market_domains` table.
* `UNIQUE("business_id", "name")`, which specifies the pair of `business_id` and product's `name` is needs to be `UNIQUE`, to avoid the redundancy the `UNIQUE` constraint applied.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-10`: **`product_models`**</u>
The `product_models` table holds the information about the certain product's models/variants.

It includes:
* `id`, which specifies the unique ID for product model as `INTEGER`. Thus this column has the `PRIMARY KEY` constraint applied.
* `product_id`, which specifies the ID of the product in `products` table as `INTEGER`, to identify where the certain model points to which product in `products` table, thus the `FOREIGN KEY` constraint links this to `products` table.
* `size`, which specifies the size parameter of the product model as `TEXT`, whereas it can involve the various metrics of size based on products and their models so `TEXT` is appropriate to apply, and the `DEFAULT` value as `NULL` is applied as all product-models don't have size parameter.
* `color`, which specifies the color parameter of the product model as `TEXT`, and the `DEFAULT` values as `NULL` is applied as all product-models don't actually rely on color parameter. So, the `TEXT` is appropriate to store color based values. (For more in advance we can also store HEX-codes as `BIGINTEGER` or `INTEGER`).
* `weight_kg`, which specifies the weight parameter of the product model as `REAL`, and the `CHECK` constraint is applied to allow the product-model's weight to be **greater than 1 gram** and **less than 1000 kilo gram**, to avoid unrealistic weights as input, for the cases when there is no-need for weight parameter for the product-model's `DEFAULT NULL` constraint used.
* `material`, which specifies the type of material that the product-model made up of as `TEXT`, and similarly to `weight_kg` for the cases when there is no-need for material parameter for the product-model's `DEFAULT NULL` constraint applied, and the `TEXT` type is appropriate to hold the name-type fields.
* `price`, which specifies the price of the product-model as `REAL`, and a `CHECK` constraint applied to make the price **greater than 1**.
* `available_stock`, which specifies the stock that is available for the product-model as `INTEGER`, and the `CHECK` constraint applied to validate the stock not going in to negative values, and `DEFAULT 0` constraint used incase of incorrect input given.
* `min_order_qty`, which specifies the minimum stock to order as `INTEGER` value, a `CHECK` constraint is used to specify the minimum order requirement value **should not be less than 1**, and `DEFAULT 1` constraint used incase of incorrect input given.
* `mfg_date` and `exp_date`, the both specifies the dates of product-model's manufacture date and expire date (in case if it has) as `NUMERIC` values, and `DEFAULT CURRENT_TIMESTAMP` constraint applied in case of not manufacture date given.
* `UNIQUE("product_id", "size", "color", "weight_kg", "material", "price", "mfg_date", "exp_date")`, which specifies the set of a product-model for a certain product referenced from `id` as `product_id` must have a `UNIQUE` record of product-model, to avoid redundancy the `UNIQUE` constraint applied for the set of columns.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-11`: **`user_carts`**</u>
The `user_carts` table holds the information of user's cart that allows user to order 1 or more than a product at a time.

It includes:
* `id`, which specifies the unique ID for user's cart as `INTEGER`. Thus this column has the `PRIMARY KEY` constraint applied.
* `user_id`, which specifies the ID of the user as `INTEGER`, that is being referenced from `users` table, to point out which user ordered which cart at a particular period of time/days/months, thus the `FOREIGN KEY` constraint links this to `users` table.
* `ordered_on`, which specifies the date of the cart was ordered as `NUMERIC`, and `DEFAULT NULL` is applied pending carts hold ordered-on date to be NULL.
* `status_id`, which specifies the ID of the status in `order_statuses` table, which states the status of the order whether it is delivered, returned, or cancelled etc., here `DEFAULT 0` constraint used for the reason it can only be 0 when a `DELETE` was made on `order_statuses` based on `FOREIGN KEY` constraint.
* `delivery_agent_id`, which specifies the ID of the user who is a `delivery_agent` in `user_role` of `users` table as `INTEGER`, here `DEFAULT 0` points to the imaginary `delivery_agent` named `self-pick-up` in `users` table as the name suggests, as this is a local marketplace support system, some users might pick their cart on their own rather than getting it delivered, so for those cases there is a key user in `users` table with `id-0`, and it is the `DEFAULT` value when a `delivery_agent` is not assigned for the certain cart, and for the `FOREIGN KEY` constraint used to set `NULL` value as the `delivery_agent` lefts (`DELETE ON` `"users"` table) from the system, thus the `FOREIGN KEY` constraint links this to `users` table.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-12`: **`product_orders`**</u>
The `product_orders` table holds the information of each cart contains which product_model of a product that is ordered through a user's cart.

It includes:
* `id`, which specifies the unique ID of the order-id for the product-model that is being ordered under certain cart as `INTEGER`. Thus this column has the `PRIMARY KEY` constraint applied.
* `cart_id`, which specifies the ID of the cart as `INTEGER`, that is being referenced from `user_carts` table to point out to which cart does the certain product-order belongs to, thus the `FOREIGN KEY` constraint links this to `user_carts` table.
* `product_model_id`, which specifies the ID of the product_model that is being ordered in a cart as `INTEGER`, that is being referenced from `product_models` table, thus the `FOREIGN KEY` constraint links this to `product_models` table.
* `qty`, which specifies the quantity of the product_model that is being ordered as `INTEGER`, a `CHECK` constraint is applied to validate the **quantity when being ordering must be greater than or equal to 1**.
* `price_at_order`, which specifies the price of the product_model as `REAL` when it is ordered via a cart, a `CHECK` constraint is applied to validate the **price needs to be greater than 0**.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-13`: **`cart_payments`**</u>
The `cart_payments` table holds the information about cart's payments statuses and mode, paid on information, and total price of cart etc.

It includes:
* `id`, which specifies the unique ID of the payment-id for the cart's payment as `INTEGER`. Thus this column has the `PRIMARY KEY` constraint applied.
* `cart_id`, which specifies the ID of the cart as `INTEGER`, that is being referenced from `user_carts` table to point out to which cart does the certain payment is associated, thus the `FOREIGN KEY` constraint links this to `user_carts` table.
* `total_price`, which specifies the total-price of the cart that is being ordered as `REAL`, a `CHECK` constraint is applied to validate the `total_price` should be **greater than 0**.
* `status_id`, which specifies the ID of the payment's status as `INTEGER`, that is being referenced from `payment_statuses` table to map the status of the payment - whether it is pending, completed, cancelled etc., thus the `FOREIGN KEY` constraint is applied to link this to `payment_statuses` table, and a `DEFAULT 0` value is used in the case of `FOREIGN KEY` constraint `ON DELETE` action the default value 0 is placed, as the value-0 points to the deleted status in linked table (`payment_statuses`).
* `mode_id`, which specifies the ID of the payment's mode as `INTEGER`, that is being referenced from `payment_modes` table to map the mode of the payment that done or being done - whether it is cash, phonepe, google-pay, etc., thus the `FOREIGN KEY` constraint links this to `payment_modes` table, and a `DEFAULT 1` value is used in the case of `FOREIGN KEY` constraint `ON DELETE` action the default value 1 is placed, as the value-1 points to the cash payment-mode in the linked table (`payment_modes`).
* `paid_on`, which specifies the date, when were the payment was made.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-14`: **`product_ratings`**</u>
The `product_ratings` table holds the ratings of the product-models that are ordered by the users, if user given rating on it.

It includes:
* `user_id`, which specifies the ID of the user as `INTEGER`, that is being referenced from `users` table to point out which user given rating to which product-model, thus the `FOREIGN KEY` constraint links this to `users` table.
* `product_model_id`, which specifies the ID of the product-model as `INTEGER`, that is being referenced from `product_models` table to point out which product-model was rated, thus the `FOREIGN KEY` constraint links this to `product_models` table.
* `rating`, which specifies the rating on the product-model that the user given as `REAL`, a `CHECK` constraint implemented to check rating should be in between 1.00 AND 5.00.
* `comment`, which specifies the comment on the product-model that the user given as `TEXT`, a `CHECK` constraint is used to ensure the comment length should exceed 100 characters.
* `rated_on`, which specifies the timestamp (date + time) as `NUMERIC` in which the comment or rating recorded.
* `PRIMARY KEY("user_id", "product_model_id")`, this defines a composite primary key using the combination of `user_id` and `product_model_id`. This constraint is applied to uniquely identify each rating record, furthermore it ensures that each combination of `user_id` and `product_model_id` can only appear once to avoid redundancy.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-15`: **`services`**</u>
The `services` table holds the information of the service's name, business that is providing, what category or market domain does it belong etc., price of service, availability, and estimate work duration for a service etc.

It includes:
* `id`, which specifies the unique ID for the service as `INTEGER`. Thus this column has the `PRIMARY KEY` constraint applied.
* `business_id`, which specifies the ID as `INTEGER`, that the business that provides the service, and that ID is being referenced from `businesses` table, thus the `FOREIGN KEY` constraint links this to `businesses` table.
* `name`, which specifies the name of the service as `TEXT`, given that `TEXT` is appropriate for the name fields.
* `category_id`, which specifies the ID of the domain i.e category, which is being referenced from `market_domains` table, as a service might belong to certain category or domain for extra detail, thus the `FOREIGN KEY` constraint links this to `market_domains` table.
* `availability`, which indicates the `BOOLEAN` value, which indicates the availability of the service like whether it is available (1) or not-available (0). Thus a `CHECK` constraint applied to validate the `availability` must be in pre-defined values.
* `available_slots`, which indicates the slots as `INTEGER`, to showcase how many times whether the service can be booked or performed concurrently, as per maintaining requirement for the available-slots should be **more than or equal to 5**, for this reason the `CHECK` constraint is applied.
* `price`, which specifies the price of the service as `REAL`, a `CHECK` constraint is applied to ensure the price is **greater than 0**.
* `est_wrk_dur_hrs`, which specifies the **`estimated work duration hours`** as `REAL`, which indicates only the value in hours, a `CHECK` constraint is applied to validate the work-duration must be **greater than or equal to 10 minutes** (`ROUND(10.0/60.0, 4)`).
* `UNIQUE("business_id", "name")`, which specifies the pair of `business_id` and product's `name` is needs to be `UNIQUE`, to avoid the redundancy the `UNIQUE` constraint applied.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-16`: **`service_orders`**</u>
The `service_orders` table holds the information about the services that are ordered by the users

It includes:
* `id`, which specifies the unique ID as `INTEGER`, that the service-order can be indicated, thus this column has the `PRIMARY KEY` constraint.
* `user_id`, which specifies the ID of the user as `INTEGER`, who was ordered/ordering the service, thus the `FOREIGN KEY` constraint links this to `users` table.
* `service_id`, which specifies the ID of the service as `INTEGER`, that is being ordered/getting ordered by the user, thus the `FOREIGN KEY` constraint links this to `services` table.
* `qty`, which specifies the quantity of slots as `INTEGER`, that is booked or requested at the time of being ordered/getting ordered, a `CHECK` constraint is applied to validate the `qty` should be **greater than or equal to 1 and less than or equal to 5**.
* `price_at_order`, which specifies the price of the service at the time when that is being ordered/getting ordered as `REAL`, a `CHECK` constraint is applied to validate that price is **greater than 0**.
* `ordered_on`, which specifies the date in which the service is ordered as `NUMERIC` data.
* `status_id`, which specifies the ID as `INTEGER` of the order-status from the `order_statuses` table, thus the `FOREIGN KEY` constraint links this to `order_statuses` table.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-17`: **`service_payments`**</u>
The `service_payments` table holds the information about the services payments-statuses, date-paid on etc.

It includes:
* `id`, which specifies the unique ID as `INTEGER` for the payment associated with a service-order, thus this column has the `PRIMARY KEY` constraint.
* `service_order_id`, which specifies the ID of the service-order as `INTEGER`, that is associated to the `service_orders` table, thus the `FOREIGN KEY` constraint links this to `service_orders` table.
* `price`, which indicates the price of the service-order.
* `status_id`, which indicates the ID of the payment-status as `INTEGER`, that is associated to the `payment_statuses` table, thus the `FOREIGN KEY` constraint links this to `payment_statuses` table.
* `mode_id`, which indicates the ID of the payment-mode as `INTEGER`, that is associated to the `payment_modes` table, thus the `FOREIGN KEY` constraint links this to `payment_modes` table.
* `paid_on`, which indicates the date when the payment was made or done as `NUMERIC`.

##### <u style="text-decoration: none; border-bottom: 3px dashed">`TABLE-18`: **`service_ratings`**</u>
The `service_ratings` table holds the ratings of the services that are ordered by the users, if user given rating on it.

It includes:
* `user_id`, which specifies the ID of the user as `INTEGER`, that is being referenced from `users` table to point out which user given rating to which service, thus the `FOREIGN KEY` constraint links this to `users` table.
* `service_id`, which specifies the ID of the service as `INTEGER`, that is being referenced from `services` table to point out which service was rated, thus the `FOREIGN KEY` constraint links this to `services` table.
* `rating`, which specifies the rating on the service that the user given as `REAL`, a `CHECK` constraint implemented to check rating should be in between 1.00 AND 5.00.
* `comment`, which specifies the comment on the service that the user given as `TEXT`, a `CHECK` constraint is used to ensure the comment length should exceed 100 characters.
* `rated_on`, which specifies the timestamp (date + time) as `NUMERIC` in which the comment or rating recorded.
* `PRIMARY KEY("user_id", "service_id")`, this defines a composite primary key using the combination of `user_id` and `service_id`. This constraint is applied to uniquely identify each rating record, furthermore it ensures that each combination of `user_id` and `service_id` can only appear once to avoid redundancy.

### Relationships

#### <u style="text-decoration: none; border-bottom: 2px solid;">Entity Relationship Diagram:</u> `Neighbourly` - `Local Marketplace Support System`

![ER-DIAGRAM](er-diagram.svg)

As detailed by the diagram:

* A `location` can be associated with zero, one, or many `users`, and each `user` must be associated with exactly one `location`. Furthermore for businesses, a `location` can contain one, or many businesses. Each `business` must reside in exactly one `location`.
* A `user` can own zero, one or many businesses. Each `business` must be owned by exactly one `user`.
* A `business` can be associated with one or many `market_domains` through the `business_associations` table. On the other hand, a `market_domain` can categorize one or many `businesses` through the same association table. Each entry in `business_associations` links exactly one `business` to exactly one `market_domain`.
* A `business` can offer (own) zero, one or many `products`. Each `product` must be offered by exactly one `business`.
* A `business` can provide zero, one or many `services`. Each `service` must be provided by exactly one `business`.
* A `market_domain` can act as a category for zero, one or many `products`. Each `product` must belong to exactly one `market_domain` (category). Similar to that, a `market_domain` can act as a category for zero, one or many `services`. Each `service` must belong to exactly one `market_domain` (category).
* A `product` can have zero, one or many specific `product_models` (variants). Each `product_model` must belong to exactly one `product`.
* A `user` (customer) can create zero, one or many `user_carts`. Each `user_cart` must belong to exactly one `product`. In addition to that, A `user` (delivery_agent) can be assigned to deliver zero, one or many `user_carts`. A `user_cart` can be assigned to at most one delivery agent.
* A `user_cart` (representing an order) can contain one or many `product_orders`. Each `product_order` must belong to exactly one `user_cart`.
* A `product_model` can include in zero, one or many `product_orders`. Each `product_order` must refer to exactly one `product_model`.
* An `order_status` can apply to zero, one or many `user_carts`. Each `user_cart` must have exactly one `order_status`.
* A `user_cart` can have zero or one `cart_payment` associated with it. Each `cart_payment` must be associated  with exactly one `user_cart`.
* A `payment_status` can apply to zero, one or many `cart_payments`. Each `cart_payment` must have exactly one `payment_status`.
* A `payment_mode` can be used for zero, one or many `cart_payments`. Each `cart_payment` must have exactly one `payment_mode`.
* A `user` can give zero, one or many `product_ratings`, but only one rating per specific `product_model`. Each `product_rating` must be give by exactly one `user`.
* A `user` (customer) can place zero, one or many `service_orders`. Each `service_order` must be placed by exactly one `user`.
* A `service` can be part of zero, one or many `service_orders`. Each `service_order` must refer to exactly one `service`.
* A `order_status` can apply to zero, one or many `service_orders`. Each `service_order` must have exactly one `order_status`.
* A `service_order` can have zero or one `service_payment` associate with it. Each `service_payment` must be associated with exactly one `service_order`.
* A `payment_status` can apply to zero, one or many `service_payments`. Each `service_payment` must have exactly one `payment_status`.
* A `payment_mode` can be used for zero, one or many `service_payments`. Each `service_payment` uses at most one `payment_mode`.
* A `user`can give zero, one or many `service_ratings`, but only one rating per specific `service`. Each `service_rating` must be given by exactly one `user`.
* A `service` can receive zero, one or many `service_ratings`. Each `service_rating` must be for exactly one `service`.

## Optimizations
The following `VIEWs`, `INDEXes`, `TRIGGERs` are the optimizations that I had made to increase the performance and functionality of the schema.
### A. Views
The views in this schema give a pre-defined result set that will optimize the data access, which in turn they optimize the way of querying.

***The following are the `views` that I came up with:***

1. **`users_in_locations`** : This view provides information about the number of users in each location, who are categorized by their roles (`customers`, `business_owners`, `delivery_agents`).

2. **`customer_info`** : This view contains detailed information about each `customer`, which includes their `name`, `username`, `age`, `gender`, and `location`, thus this view don't expose the sensitive information like `password`, `address`, `phone`, `email` etc..

3. **`business_owners_info`** : This view provides detailed information about each `business_owner`, which includes their `name`, `username`, `age`, `gender`, `business-name`, `working hours` and `location`.

4. **`business_count_per_owner`** : This views shows the number of businesses owned by each business owner. This view uses the above view (i.e., `business_owners_info`), on the other hand, this view can also be a `TEMPORARY VIEW`.

5. **`delivery_agent_info`** : This view contains detailed information about each `delivery_agent`, which includes their `name`, `username`, `age`, `gender`, `phone`, `location`, and the number of order they have dealt with.

6. **`products_info`** : This view contains detailed information about each product, which includes the business it belongs to (`business_id`), `product-name`, `domain`, and the product's models information.

7. **`services_info`** : This view contains detailed information about each service, which includes the business it belongs to (`business_id`), `service-name`, `domain`, `price`, and `working-duration`.

8. **`users_products_orders_count`** : This view shows the number of product orders made by each user.

9. **`user_carts_info`** : This view provides the detailed information about each user's cart, which includes the ordered date (`ordered_on`), order status (`order_status`), payment status (`payment_status`), and `delivery_agent`- information.

10. **`users_service_orders_count`** : This view shows the number of service orders made by each user.

11. **`service_orders_info`** : This view contains detailed information about each service order, which includes the user who ordered it, `name` of the service, `qty` (quantity), `price_at_order` (price), and payment information (from `service_payments` table).

12. **`product_based_businesses`** : This view provides information about product-based businesses, which includes their `name`, `owner`, `type`, `address` and `working-hours`.

13. **`service_based_businesses`** : This view provides information about service-based businesses, which includes their `name`, `owner`, `type`, `address` and `working-hours`.

14. **`market_domains_by_locations`** : This view shows the different market domains available in each location, which are categorized by product-based and service-based businesses.

15. **`available_products_by_locations`** : This view provides information about the products available in each location.

16. **`available_services_by_locations`** : This view contains information about the services available in each location.

17. **`products_ratings_summary`** : This view shows the average (`AVG`) rating and number of ratings of each product, along with the business and owner information.

18. **`service_ratings_summary`** : This view contains the average rating (`AVG`) and number of ratings of each service, along with business and owner information.

19. **`pending_cart_order_payments`** : This view shows the pending payments for the cart orders, which includes the users and their corresponding cart information.

20. **`pending_service_order_payments`** : This view contains the pending payments for the service orders, which includes the user and order information.

21. **`active_users_summary_cart_orders`** : This view provides information about users who have placed orders in their carts in the last 30 days, which includes the ordered date (`ordered_on`), delivery agent (`delivery_agent_id`), and order status (`order_status`).

22. **`active_users_summary_service_orders`** : This view contains information about users who have place services orders in the last 30 days, which includes the ordered date (`ordered_on`), delivery agent (`delivery_agent_id`), and order status (`order_status`).

23. **`order_frequency_per_user`** : This view shows the frequency of cart orders and service orders for each user in the last month.

24. **`top_selling_products`** : This view lists the top 10 products based on total orders and price.

25. **`top_selling_services`** : This view lists the top 10 services based on total orders and price.

### B. Indexes
The indexes that are defined in this schema will optimize the query performance, and provides efficient data retrieval and manipulation. The following indexes play a crucial role in enhancing the overall performance and scalability of the system.

***The following are the `indexes` that I came up with:***

1. **`idx_user_roles`** : This index speeds up queries that retrieve the user details by their role (`customer`, `business_owner`, `delivery_agent`), which enables efficient user management.

2. **`idx_username`** : This index enables fast lookups when searching for users by `username`, which coordinates user authentication and profile management.

3. **`idx_users`** : This index optimizes queries that filter users by `age` and `gender`, which facilitates the demographic analysis.

4. **`idx_locations`** : This index enhances query performance when searching for locations by `municipality`, `state`, `country`, or `pincode`, which supports efficient location-based services.

5. **`idx_location_pincode`** : This index provides fast lookups for locations by pincode, facilitating efficient delivery and logistics operations.

6. **`idx_businesses`** : This index speeds up queries that retrieve business details by `owner_id`, and `name`, which enables efficient business management and customer search.

7. **`idx_market_domains`** : This index optimizes queries that filter businesses by domain `type` or `category`, which supports market analysis and trend based analysis.

8. **`idx_products`** : This index enables fast lookups for products by `name`, in which it facilitates efficient product search and discovery.

9. **`idx_product_models`** : This index speeds up queries that retrieve product model details by attributes like `size`, `weight`, `color`, `price` and `mfg_date`, in turn this index supports efficient product management.

10. **`idx_user_carts`** : This index enhances order history lookups and delivery agent tracking, which further enables efficient order management and logistics operations.<li style="list-style: '10.5.'">&nbsp;<b><code>idx_user_carts_2</code></b> : This index enhances the speed when fetching a user's orders with specific status.</li><br><li style="list-style: '11.'"> **`idx_product_orders`** : This index optimizes queries that filter product orders by quantity (`qty`), and `price`, which supports sales analysis and revenue tracking.</li><br><li style="list-style: '12.'"> **`idx_order_statuses`** : This index speeds up queries that retrieve order statuses by `type` and `status`, which enables efficient order management and tracking.</li><br><li style="list-style: '13.'"> **`idx_payment_statuses`** : This index optimizes queries that retrieve payment statuses, which support efficient payment processing and tracking.</li><br><li style="list-style: '14.'"> **`idx_payment_modes`** : This index enables fast lookups for payment modes, which facilitates in  efficient payment processing and transaction management.</li><br><li style="list-style: '15.'"> **`idx_cart_order_payments`** : This index speeds up queries that retrieve payment data by payment date, which assists in financial analysis and revenue tracking.</li><br><li style="list-style: '16.'"> **`idx_product_ratings`** : This index optimizes queries that sort product ratings, which in turn enables efficient review management and product ranking.</li><br><li style="list-style: '17.'"> **`idx_services`** : This index enhances the search performance for services by attributes like `name`, `availability`, `price`, and estimated work duration (`est_wrk_dur_hrs`), which supports efficient service discovery.</li><br><li style="list-style: '18.'"> **`idx_service_name`** : This index provides fast lookups for services by `name`, which facilitates efficinet service searching and discovery.</li><br><li style="list-style: '19.'"> **`idx_service_orders`** : This index speeds up queries that analyze trending service orders over time, which supports businesses to gain insights and also assist in identifying trend.</li><br><li style="list-style: '20.'"> **`idx_service_payments`** : This index optimizes queries that retrieve payment data by payment date, which in turn it supports the financial analysis and revenue tracking for service.</li><br><li style="list-style: '21.'"> **`idx_service_ratings`** : This index enables efficient sorting and filtering of service reviews by `rating`, which supports review management and service ranking.</li>

### C. Triggers
I came up with the following triggers the increase the functionality of the schema very much, although most of them can be handled in application level but I had taken a deep consideration on data-integrity and consistency, thus made the following comprehensive triggers for the schema.
Logically, I came up with `4 types of triggers` they are:
* **<u style="text-decoration: none; border-bottom: 2px dashed">Logging Triggers</u>**, triggers that keep track of data movements within database.
    -<details open>
        <summary>
            <b><u style="text-decoration: none; border-bottom: 2px dotted;">Information about logging.</u></b>
        </summary>
        I came up with a separate, dedicated table called `TABLE-19: logs` that holds and records the data movements with the help of **<u style="text-decoration: none; border-bottom: 2px dashed">Logging Triggers</u>**.
                <br><b>`TABLE-19:` logs</b><br>
                The `logs` table that holds the logs of all tables in the database, which further help in analysis, historical tracking, recording crucial changes etc.
                <br>
                It includes:
                <ul style="list-style-type: disc">
                    <li>`id`, which specifies the unique ID of the log that has recorded by the `triggers`. Thus this column is the `PRIMARY KEY` constraint.</li>
                    <li>`record_id`, which specifies the ID of the specific record in target tables when there is a movement in data through operations in it.</li>
                    <li>`table`, which specifies the name of the table that had affect with data movements, and stores it as `TEXT`, a `CHECK` constraint is applied to validate only valid table names come in input.</li>
                    <li>`operation`, which specifies the type of operation made on corresponding `table`, the operation can be `INSERT`, `UPDATE` or `DELETE`, and this data is stored in `TEXT`, as `CHECK` constraint is applied to validate the `operation` value is falls under pre-defined values.</li>
                    <li>`column`, which specifies the name of the column of the corresponding `table` that had affected after/before the `operation` it is stored as `TEXT`.</li>
                    <li>`old_value`, which specifies the old-value whenever an `UPDATE` - `operation` takes place on
                     a `table` and this column `old_value` holds the record of old-value of a `UPDATE`.</li>
                    <li>`new_value`, which specifies the new-value whenever an `UPDATE` - `operation` takes place on a `table` and this column `new_value` holds the record of new-value of a `UPDATE`.</li>
                    <li>`description`, which specifies the description of the `operation` that made on target-`table` on a certain `column`.</li>
                    <li>`timestamp`, which specifies the timestamp of the `operation` when it was recorded, to keep real-time tracking `DEFAULT CURRENT_TIMESTAMP` was applied.</li>
                </ul>
     </details>

* **<u style="text-decoration: none; border-bottom: 2px dashed">Restricting Triggers</u>**, triggers that restrict certain operations on certain tables based on certain conditions to maintain integrity and security of the data.
* **<u style="text-decoration: none; border-bottom: 2px dashed">Validating Triggers</u>**, triggers that validate whether the data is valid enough to get in through operations like `INSERT`,`UPDATE`, and `DELETE`.
* **<u style="text-decoration: none; border-bottom: 2px dashed">Automating Triggers</u>**, triggers that automate (automatically process data in corresponding tables) certain when certain changes occur in certain table with certain operation.

***The following are the `triggers` tables wise:***
#### 1. Triggers on `users` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">1.1 Logging Triggers:</u>
* **`log_new_user`**
* **`log_left_user`**
* **`log_user_updates`**

The above triggers are used for logging user's data movements like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_user` - automatically logs the bit information of new-users along with a `timestamp` states that when their account was created. The `log_left_user` - logs the deletion of users (users who left from the system) by records their `username` and the `timestamp` states that when did they actually left. The `log_user_updates` - tracks the updates of user's information like `password`, `phone`,`email` and `user_role` to monitor the user activity, thus these triggers assist in maintaining logs which are useful for tracking and monitoring user's activity.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">1.2 Restricting Triggers:</u>
1. **`restrict_user_password_update`** : The trigger that prevents users to reusing previously used passwords, which is dedicated to increase the security by ensuring password uniqueness and reducing the risk of compromised accounts.

#### 2. Triggers on `businesses` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">2.1 Logging Triggers:</u>
* **`log_new_business`**
* **`log_closed_business`**
* **`log_business_updates`**

The above triggers are used for logging business's data movements like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_business` - automatically logs the creation of new businesses by recording `owner_id`, business's-`name`, `address`, and `location_id`. The `log_closed_business` - logs the records of deleted (closed) businesses, again by recording `owner_id`,business's-`name`,`address`, and `location_id` to track when businesses are closed. The `log_business_updates` - tracks the updates to business's information like business's-`name`, `address`, and `owner_id`, to monitor business activity, thus these triggers assist in maintaining logs which are useful for tracking and monitoring business's activity.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">2.2 Restricting Triggers:</u>
1. **`restrict_business_name_update`** : The trigger that limits the number of times a business name can be updated to 5, which prevents excessive changes and maintain data consistency.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">2.3 Validating Triggers:</u>
1. **`validate_business_existence`** : The trigger that prevents duplicate businesses from being created by checking for existing businesses with the same `name` and `owner_id`.<br>
><b><i>The triggers 2.3.2, 2.3.3 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>
2. **`validate_owner_role_on_insert`** **&** **`validate_owner_role_on_update`** : These triggers ensures that that only `users` with their `user_role` as `business_owner` can be assigned as owners of the businesses on both `INSERT` and `UPDATE` cases separately. Thus these both triggers prevents unauthorized assignments and increase the data integrity.

3. **`validate_business_location`** : The trigger that ensures that businesses are located in the same location as their owners, which contributes in maintaining data consistency and preventing invalid location assignments.

4. **`validate_business_working_hours`** : The trigger that ensures that businesses are open for at least 5 hours, this allows the system to maintain a standard for business operations and also prevents invalid working hours.

5. **`validate_business_timings_format`** : The trigger that validates the format of business `open_time` and `close_time`, by ensuring they are in required format in 24-hour clock notation.

#### 3. Triggers on `business_associations` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">3.1 Restricting Triggers:</u>
1. **`restrict_update_on_business_id`** : The trigger that restricts direct update to the `business_id` on `business_associations` table, in which it prevents unauthorized changes and maintains the data integrity by ensuring that business associations are not changed without proper authorization.

#### 4. Triggers on `products` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">4.1 Logging Triggers:</u>
* **`log_new_product`**
* **`log_removed_product`**
* **`log_product_updates`**

The above triggers are used for logging the data movements in product's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_product` - automatically logs the creation of new product, by recording the `business_id`, and the product's - `id`. The `log_removed_product` - logs the deletion of products, and it records the `business_id` and product's - `id` to track product removals. The `log_product_updates` - logs the updates of the product's information like `name`, `category_id`, and `business_id`, to track product activity for ensuring data consistency.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">4.2 Restricting Triggers:</u>
><b><i>The triggers 4.2.1, 4.2.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>
<br>

1. **`restrict_product_category_id_zero_on_insert`** **&** **`restrict_product_category_id_zero_on_update`** : These triggers prevents the`category_id` from being set to `0`, which ensures valid category assignments and prevents data inconsistencies upon `INSERT` and `UPDATE` operations, as `0` of `category_id` indicates `deleted-domain/category` value.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">4.3 Validating Triggers:</u>
><b><i>The triggers 4.3.1, 4.3.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>
<br>

1. **`validate_product_category_id_on_insert`** **&** **`validate_product_category_id_on_update`** : These triggers validates that `category_id` only belong to `products` under `market_domains` table upon `INSERT` and `UPDATE` operations, whereas this further assists in maintaining data integrity and prevent invalid category assignments.

#### 5. Triggers on `product_models` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">5.1 Logging Triggers:</u>
* **`log_new_product_model`**
* **`log_removed_product_model`**
* **`log_product_model_updates`**

The above triggers are used for logging the data movements in product-model's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_product_model` - logs the creation of new-product model, which captures the `product_id`, and product-model's - `id`, which helps in tracking product-model additions. The `log_removed_product_model` - logs the deletion of product-models, which the records the `product_id`, and product_model's - `id`, to track product-model removals. The `log_product_model_updates` - tracks the updates of the product-model information which includes `price` (to track trends in price changes), and `available_stock` (to track the demand of the product-model).

##### <u style="text-decoration: none; border-bottom: 2px dashed;">5.2 Validating Triggers:</u>
><b><i>The triggers 5.2.1, 5.2.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>
1. **`compare_product_model_mfg_exp_date_on_insert`** **&** **`compare_product_model_mfg_exp_date_on_update`** : These triggers ensures that the `mfg_date` (manufacture-date) is not later than `exp_date` (expiration-date) upon both `INSERT` and `UPDATE` operations, thus these triggers prevents invalid date assignments and maintains data consistency and integrity.<br>
><b><i>The triggers 5.2.3, 5.2.4 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>
<br>
2. **`validate_format_of_mfg_exp_dates_on_insert`** **&** **`validate_format_of_mfg_exp-dates_on_update`** : These triggers validates that the formats of the `mfg_date` (manufacture-date) and `exp_date` (expiration-date) upon `INSERT` and `UPDATE` operations, thus these triggers ensures that they are in required format and prevents inconsistent data.

#### 6. Triggers on `services` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">6.1 Logging Triggers:</u>

* **`log_new_service`**
* **`log_removed_service`**
* **`log_service_updates`**

The above triggers are used for logging the data movement in service's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_service` - logs the creation of new services, which records the `business_id`, and the service's - `id`, which tracks the service additions. The `log_removed_service` - logs the deletion of services, by recording the `business_id`, and the service's - `id`, to track service removals. The `log_service_updates` - tracks the updates on service's information like its `category_id` (to track the trends in category updates of a business's service or services), `availablility` (to track the service demand), and `price` (to track the price trends of the service).

##### <u style="text-decoration: none; border-bottom: 2px dashed;">6.2 Restricting Triggers:</u>
><b><i>The triggers 6.2.1, 6.2.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>
1. **`restrict_service_category_id_zero_on_insert`** **&** **`restrict_service_category_id_zero_on_update`** : These triggers prevents the `category_id` from being set to `0` as it refers to the `deleted-domain/category` in referenced table `market_domains` upon `INSERT` and `UPDATE` operations, thus these triggers ensures the valid category assignments.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">6.3 Validating Triggers:</u>
><b><i>The triggers 6.3.1, 6.3.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>

1. **`validate_service_category_id_on_insert`** **&** **`validate_service_category_id_on_update`** : These triggers validates that `category_id` only belong to `services` under `market_domains` table upon `INSERT` and `UPDATE` operations, whereas this further assists in maintaining data integrity and prevent invalid category assignments.

#### 7. Triggers on `user_carts` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">7.1 Logging Triggers:</u>
* **`log_new_cart`**
* **`log_removed_cart`**
* **`log_cart_updates`**

The above triggers are used for logging the data movement in users-cart's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_cart` - logs the creation of new carts, which records the `user_id`, and the user-cart's - `id`, which tracks the cart initiations. The `log_removed_cart` - logs the deletion or abandonment of carts, by recording the `user_id`, and the user-cart's - `id`, to track cart removals. The `log_cart_updates` - tracks the updates on user-cart's information like its `status_id` (to track the status's updates (transitions) on carts), `ordered_on` (to observe the trends when the orders hiked and dropped), and `delivery_agent_id` (to keep track of which delivery-agent was assigned).

##### <u style="text-decoration: none; border-bottom: 2px dashed;">7.2 Restricting Triggers:</u>
1. **`restrict_cart_status_if_it_not_confirmed`** : The trigger that prevents updating the cart status to `cart-order-delivered`, `cart-order-self-pick-up`, `cart-order-returned`, or `cart-order-cancelled` if the cart was never confirmed (`cart-order-confirmed`) or out-for-delivery (`cart-order-out-for-delivery`), for ensuring valid status transitions.

2. **`restrict_cart_status_if_it_moves_back_from_confirmed_to_pending`** : The trigger that restricts changing cart status back to `cart-order-pending` after confirmed (`cart-order-confirmed`), which is essential for maintaining a logical status flow.

3. **`restrict_delivery_agent_update_on_delivered_orders`** : The trigger that prevents updating `delivery_agent_id` if the order is already `cart-order-out-for-delivery` or `cart-order-delivered`, which is essential to maintain the data consistency.

4. **`restrict_update_on_cart_ordered_date`** : The trigger that restricts updating `ordered_on` date once it is already set, this ensures the data integrity.

5. **`restrict_confirmed_cart_order_deletion`** : The trigger that prevents deleting user-carts status is confirmed (`cart-order-confirmed`), out-for-delivery (`cart-order-out-for-delivery`), delivered (`cart-order-delivered`), self-picked (`cart-order-self-pick-up`), returned (`cart-order-returned`), or cancelled (`cart-order-cancelled`). Thus this enhances the data consistency.

6. **`restrict_cart_status_confirmed_when_cart_is_empty`** : The trigger that restricts confirming cart-orders when the cart is empty, thus preventing invalid order-confirmations.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">7.3 Validating Triggers:</u>
1. **`validate_stock_before_cart_confirmed`** : The trigger that validates stock availability before confirming a cart order (`cart-order-confirmed`), which ensures that sufficient stock is being ordered for products.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">7.4 Automating Triggers:</u>
1. **`auto_update_payment_status_as_cart_status_change`** : The trigger automatically sets the payment status of corresponding `user_cart's` in `cart_payments` status to `pending`, when a cart-order is confirmed (`cart-order-confirmed`), thus this trigger assists in streamlining payment processing.

2. **`auto_update_payment_after_cart_cancelled_if_paid`** : The trigger automatically updates the `cart_id` of particular `user_carts` in `cart_payments` status (i.e. `payment_status`) to `refunded` if the cart is cancelled (`cart-order-cancelled`) after being paid, as this ensures accurate payment status.

3. **`auto_update_available_stock_when_order_is_confirmed`** : The trigger automatically decreases the `available_stock` in `product_models` table, when a product-order is confirmed (`cart-order-confirmed`), which make maintaining accurate inventory levels.

4. **`auto_increase_stock_on_cancel_return`** : The trigger that automatically increases the `available_stock` in `product_models` after a `user_cart` order is cancelled (`cart-order-cancelled`) or returned (`cart-order-returned`), which in further ensures accurate inventory levels.

#### 8. Triggers on `product_orders` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">8.1 Logging Triggers:</u>

* **`log_new_product_order`**
* **`log_removed_product_order`**
* **`log_product_orders_updates`**

The above triggers are used for logging the data movement in product-order's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_product_order` - logs new product orders, which records the `product_model_id` and `cart_id` to track the product additions in carts and user order trends. The `log_removed_product_order` - logs the removed product orders, by recording the `product_model_id`, and `cart_id`, to track product removals in carts to assess the demand of the product. The `log_product_orders_update` - tracks the updates on product-order's information, by tracking the `qty` (quantity - to track the demand of the product), and `price_at_order` (to track the discounts and price-trends at orders).

##### <u style="text-decoration: none; border-bottom: 2px dashed;">8.2 Restricting Triggers:</u>
1. **`restrict_update_price_after_ordered`** : The trigger prevents updating `price_at_order` after the order is confirmed (`cart-order-confirmed`), out-for-delivery (`cart-order-out-for-delivery`), delivered (`cart-order-delivered`), self-picked (`cart-order-self-pick-up`) or returned (`cart-order-returned`), thus improves data integrity.

2. **`restrict_qty_update_after_order_confirmed`** : The trigger restricts updating quantity (`qty`) after the cart order is confirmed (`cart-order-confirmed`), out-for-delivery (`cart-order-out-for-delivery`), delivered (`cart-order-delivered`) or self-picked (`cart-order-self-pick-up`), which in further maintains the accurate order information.

3. **`restrict_adding_product_orders_to_confirmed_carts`** : The trigger prevents adding products to carts that are already confirmed (`cart-order-confirmed`), out-for-delivery (`cart-order-out-for-delivery`), delivered (`cart-order-delivered`), self-picked (`cart-order-self-pick-up`) or cancelled (`cart-order-cancelled`), thus ensures valid cart status and their transitions.

4. **`restrict_qty_exceeding_stock`** : The trigger that restricts ordering products with quantity (`qty`) which exceeds available-stock (`available_stock`), thus this trigger prevents overselling and maintains inventory accuracy.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">8.3 Validating Triggers:</u>
><b><i>The triggers 8.3.1, 8.3.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>

1. **`validate_product_order_price_on_insert`** **&** **`validate_product_order_price_on_update`** : These triggers validates that `price_at_order` (price at the time of order) against the product-model's price (`product_models`.`price`) upon `BEFORE INSERT` and `BEFORE UPDATE` operations, which ensures accurate pricing.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">8.4 Automating Triggers:</u>
><b><i>The triggers 8.4.1, 8.4.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>

1. **`auto_update_cart_total_price_on_insert`** **&** **`auto_update_cart_total_price_on_update`** : These triggers that automatically computes/calculates and stores the `total_price` in `cart_payments` table whenever a new product-order (in `product_orders` table) is added (upon `INSERT` operation) to the cart or existing product-order's product price is updated (upon `UPDATE` operation) in the `product_orders` table.

2. **`auto_update_cart_total_price_on_delete`** : The trigger that updates `total_price` in `cart_payments` when a product order (in `product_orders` table) is deleted (upon `DELETE` operation), which maintains accurate payment information.

3. **`auto_merge_duplicate_product_orders`** : The trigger that automatically merges duplicate product order (in `product_orders` table) by updating quantity (`qty`), in which this trigger also prevents duplicate rows and ensures data consistency.

#### 9. Triggers on `service_orders` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">9.1 Logging Triggers:</u>

* **`log_new_service_order`**
* **`log_cancelled_service_order`**
* **`log_service_orders_updates`**

The above triggers are used for logging the data movement in service-order's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_service_order` - logs new service orders, which records the `service_id` and `user_id` to track the service order additions. The `log_cancelled_service_order` - logs the cancelled or removed service orders, by recording the `service_id`, and `user_id`, to track service order removals in order to assess the demand of the service. The `log_service_orders_update` - tracks the updates on service-order's information, by tracking the `status_id` (order status - to track the transistions of the service orders), `price_at_order` (to track the discounts and price-trends at orders), and `orderd_on` (to assess the demand of orders in particular period of time).

##### <u style="text-decoration: none; border-bottom: 2px dashed;">9.2 Restricting Triggers:</u>
1. **`restrict_price_update_after_service_order_placed`** : The trigger that prevents updating price at order (`price_at_order`) after the service order is placed, which ensures data integrity and prevents unauthorized changes.

2. **`restrict_update_on_quantity_once_service_order_is_started`** : The trigger that restricts updating quantity (`qty`) once the service order is confirmed (`service-order-confirmed`), in-progress (`service-order-in-progress`) or completed (`service-order-completed`), which maintains accurate order information.

3. **`restrict_update_on_service_id_if_order_was_placed`** : The trigger that prevents updating `service_id` after the service order is placed, which ensures the data consistency and prevents the unauthorized changes.

4. **`restrict_confirmed_service_orders_delete`** : The trigger that restricts deleting service orders with confirmed (`service-order-confirmed`), in-progress (`service-order-in-progress`), completed (`service-order-completed`), or cancelled (`service-order-cancelled`) status, which in turn maintains data integrity and prevents accidental deletions.

5. **`restrict_exceeding_available_service_slots`** : The trigger that restricts ordering services with quantity (`qty`) exceeding available_slots (`available_slots`), which prevents overselling and maintaining accurate service availability.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">9.3 Validating Triggers:</u>
1. **`validate_price_in_service_orders`** : The trigger that validates price at order (`price_at_order`) against the actual service `price`, which ensures the accurate pricing and prevents unauthorized changes.

2. **`validate_ordering_available_services`** : The trigger that validates a user is ordering an available (`services`.`availability` as `1`) service or not. This prevents orders for unavailable (`services`.`availability` as `0`) services.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">9.4 Automating Triggers:</u>
1. **`auto_update_slots_on_service_order`** : The trigger that automatically decreases available slots (`services`.`available_slots`) when a service is ordered and confirmed (`service-order-confirmed`), thus this ensures the accurate service availability.

2. **`auto_restore_slots_on_service_order_completion_or_cancellation`** : The trigger that automatically increases available slots (`services`.`available_slots`) when a service order status is completed (`service-order-completed`) or cancelled (`service-order-cancelled`), which maintains accurate service availability.

3. **`auto_update_payment_status_as_service_order_status_change`** : The trigger that automatically sets payment status (`service_payments`.`status_id`) to pending (`service-order-pending`) when service order is confirmed (`service-order-confirmed`), which streamlines payment processing.

4. **`auto_refund_payment_after_service_status_on_cancellation`** : The trigger that auto-refunds payment when service order is cancelled (`service-order-cancelled`) after being confirmed (`service-order-confirmed`) and paid (`service_payments`.`status_id` as `id` of `'completed'` in `payment_statuses`), which further ensures accurate payment status.

#### 10. Triggers on `cart_payments` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">10.1 Logging Triggers:</u>

* **`log_new_cart_payment`**
* **`log_removed_cart_payment`**
* **`log_cart_payments_updates`**

The above triggers are used for logging the data movement in cart-payments's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_cart_payment` - logs new cart's payment records, which records the `cart_id` and cart-payments-`id` to track the payment activity and monitor user transactions. The `log_removed_cart_payment` - logs the removed cart-payments records, by recording the `cart_id`, and cart-payments-`id`, to track payment removals. The `log_cart_payments_update` - tracks the updates on cart-payment records, which include `status_id` (to keep track of the payment's status transitions), `paid_on` (to assess the support of users towards businesses) and `mode_id` (to assess the popular trends of payment-modes).

##### <u style="text-decoration: none; border-bottom: 2px dashed;">10.2 Restricting Triggers:</u>
><b><i>The triggers 10.2.1, 10.2.2 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>

1. **`restrict_pending_cart_payment_status_change_on_insert`** **&** **`restrict_pending_cart_payment_status_change_on_update`** : These triggers prevents setting the payment-status (`status_id`) to anything other than `pending` when the cart-status is pending (`cart-order-pending`), upon `INSERT` and `UPDATE` operations, thus these triggers ensures a valid payment status transitions.

2. **`restrict_price_mode_update_if_completed_for_cart_payment`** : The trigger that restricts updating payment-amount (`total_price`) or mode (`mode_id`) after payment-status is `completed`, which maintains accurate payment information.

><b><i>The triggers 10.2.4, 10.2.5 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>

3. **`restrict_setting_payment_completed_on_insert_for_cart_payment`** **&** **`restrict_setting_payment_completed_on_update_for_cart_payment`** : These triggers prevents setting the payment-status (`status_id`) to `completed`, if payment hasn't been made (i.e., `paid_on` is `NULL`) upon `INSERT` and `UPDATE` operations, in which these triggers ensures the accurate payment status.

4. **`restrict_confirmed_payments_delete`** : The trigger that restricts deleting payments that are completed, refunded, or cancelled upon `DELETE` operation, thus allows the data integrity to be maintained and prevents accidental deletions.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">10.3 Automating Triggers:</u>
1. **`auto_refund_payment_after_cart_status_return_or_cancelled`** : The trigger that automatically updates payment-status to `refunded` when a cart order is returned (`cart-order-returned`) or cancelled (`cart-order-cancelled`) after being delivered (`cart-order-delivered`) and paid (i.e., `cart_payments`.`paid_on` is not NULL), thus streamline refund processing.

#### 11. Triggers on `service_payments` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">11.1 Logging Triggers:</u>

* **`log_new_service_payment`**
* **`log_removed_service_payment`**
* **`log_service_payments_updates`**

The above triggers are used for logging the data movement in service-payments's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_service_payment` - automatically logs the new service payment records, which records the `service_order_id` and `user_id` (user-who ordered it). The `log_removed_service_payment` - logs removed service payment records, which captures the `service_order_id` and `user_id` (user-who ordered it),  both `log_new_service_payment` and `log_removed_service_payment` triggers allow us to track the payment activity and monitor user transactions. The `log_service_payments_update` - tracks the updates to the service-payment records, which it include `status_id` (to assess the status transitions), `paid_on` (to assess the hikes and drops of payments made over a period) and `mode_id` (to assess the popular mode of payment).


##### <u style="text-decoration: none; border-bottom: 2px dashed;">11.2 Restricting Triggers:</u>
1. **`restrict_price_mode_update_if_completed_for_service_payment`** : The trigger that restricts updating (upon `UPDATE` operation) payment amount or mode after payment is `completed`, which allows the data to be maintained with accuracy in payment information.

><b><i>The triggers 11.2.2, 11.2.3 (in `schema.sql`) context is similar and are used for both <code>INSERT</code> and <code>UPDATE</code> operation</i></b>

2. **`restrict_setting_payment_completed_on_insert_for_service_payment`** **&** **`restrict_setting_payment_completed_on_update_for_service_payment`** : These triggers prevents setting the payment-status (`status_id`) to `completed`, if payment hasn't been made (i.e., `paid_on` is `NULL`) upon `INSERT` and `UPDATE` operations, in which these triggers ensures the accurate payment status.

3. **`restrict_confirmed_service_payment_deleted`** : The trigger that prevents deleting `completed`, `refunded`, or `cancelled` payment's statuses for service orders, thus this allows the data integrity to be maintained and prevents accidental deletions.

#### 12. Triggers on `product_ratings` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">12.1 Logging Triggers:</u>

* **`log_new_product_rating`**
* **`log_removed_product_rating`**

The above triggers are used for logging the data movement in product-rating's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_product_rating` - automatically logs the new product ratings, by recording `user_id` and `product_model_id`. The `log_removed_product_rating` - that automatically logs the removed product ratings, which records `user_id` and `product_model_id`. Therefore, these two triggers assist in tracking customer feedback and monitor product-model's-sales performance.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">12.2 Validating Triggers:</u>
1. **`validate_user_eligibility_to_give_product_rating_on_insert`** : The trigger that ensures that only users who have ordered and received a product can leave a rating or review, thus preventing unauthorized feedback.

2. **`validate_product_model_rating_correctly_updated`** : The trigger that prevents users from updating ratings or reviews for the wrong product or user, which ensures that feedback is accurate and trustworthy.

#### 13. Triggers on `service_ratings` table
##### <u style="text-decoration: none; border-bottom: 2px dashed;">13.1 Logging Triggers:</u>

* **`log_new_service_rating`**
* **`log_removed_service_rating`**

The above triggers are used for logging the data movement in service-rating's like when operations (`INSERT`, `UPDATE`, `DELETE`) takes place. The `log_new_service_rating` - automatically logs the new service ratings, by recording `user_id` and `service_id`. The `log_removed_service_rating` - that automatically logs the removed service ratings, which records `user_id` and `service_id`. Therefore, these two triggers assist in tracking customer feedback and monitor product-model's-sales performance.

##### <u style="text-decoration: none; border-bottom: 2px dashed;">13.2 Validating Triggers:</u>
1. **`validate_user_eligibility_to_give_service_rating_on_insert`** : The trigger ensures that only users who have ordered and received a service can give rating or review, hence this prevents unauthorized feedback.

2. **`validate_service_rating_correctly_updated`** : The trigger that prevents users from updating ratings or reviews for the wrong service or user, which ensures that feedback is accurate and trustworthy.

## Limitations
There are several limitations when compared to the real-world application, and yet I tried my utmost to work on this project to make it aligns with the real-world applications.
***The following are the `limitations` that are observed:***
* The current schema assumes a business is owned by only one user account. The partnerships or multiple owners would require changes in the schema.
* The schema doesn't handle complex inventory concepts like batch tracking, stock reservations, or varying service slot durations within a single service.
* The `passwords` in the schema are stored as `TEXT`, but in a real-world application, they absolutely hashed before storing, whereas the triggers checking password changes history (`logs` table) works on stored values, which is very insecure if not hashed.
* There is no built-in mechanism for communication between users (for example, `customer` asking a `business owner` a question).
