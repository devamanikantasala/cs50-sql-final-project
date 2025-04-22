CREATE TABLE `users`(
    `id` INT UNSIGNED AUTO_INCREMENT,
    `first_name` VARCHAR(12) NOT NULL,
    `last_name` VARCHAR(9) NOT NULL,
    `user_name` VARCHAR(12) NOT NULL UNIQUE,
    `password` VARCHAR(128) NOT NULL,
    PRIMARY KEY(`id`)
);

CREATE TABLE `schools`(
    `id` INT UNSIGNED AUTO_INCREMENT,
    `school_name` VARCHAR(25) NOT NULL UNIQUE,
    `type` ENUM('Primary', 'Secondary', 'Higher-Education') NOT NULL,
    `location` TEXT,
    `founded_on` YEAR NOT NULL,
    PRIMARY KEY(`id`)
);

CREATE TABLE `companies`(
    `id` INT UNSIGNED AUTO_INCREMENT,
    `company_name` VARCHAR(25) NOT NULL UNIQUE,
    `company_industry` ENUM('Technology', 'Education', 'Business') NOT NULL,
    `location` TEXT,
    PRIMARY KEY(`id`)
);

CREATE TABLE `user_connections`(
    `person1_id` INT UNSIGNED,
    `person2_id` INT UNSIGNED,
    PRIMARY KEY(`person1_id`, `person2_id`),
    FOREIGN KEY(`person1_id`) REFERENCES `users`(`id`),
    FOREIGN KEY(`person2_id`) REFERENCES `users`(`id`)
);

CREATE TABLE `school_connections`(
    `user_id` INT UNSIGNED,
    `school_id` INT UNSIGNED,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `degree_type` VARCHAR(5) NOT NULL,
    PRIMARY KEY(`user_id`, `school_id`),
    FOREIGN KEY(`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY(`schoold_id`) REFERENCES `schools`(`id`)
);

CREATE TABLE `company_connections`(
    `user_id` INT UNSIGNED,
    `company_id` INT UNSIGNED,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    PRIMARY KEY(`user_id`, `company_id`),
    FOREIGN KEY(`user_id`) REFERENCES `users`(`id`),
    FOREIGN KEY(`company_id`) REFERENCES `companies`(`id`)
);
