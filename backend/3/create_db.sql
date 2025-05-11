CREATE DATABASE game_store;

USE game_store;

CREATE TABLE order_item (
	order_id INT PRIMARY KEY,
	number_order INT NOT NULL,
	count INT NOT NULL
);

CREATE TABLE payment_method (
	payment_method_id INT PRIMARY KEY,
	description VARCHAR(255),
	payment_method_name VARCHAR(255) NOT NULL
);

CREATE TABLE delivery_method (
	delivery_method_id INT PRIMARY KEY,
	delivery_name VARCHAR(255) NOT NULL,
	price INT NOT NULL
);

CREATE TABLE user (
	user_id INT PRIMARY KEY,
	email VARCHAR(255) NOT NULL,
);

ALTER TABLE user ADD COLUMN username VARCHAR(255) NOT NULL;

ALTER TABLE user ADD COLUMN surname VARCHAR(255) NOT NULL;

ALTER TABLE user DROP COLUMN surname;

UPDATE user SET email = 'user1@example.com' WHERE user_id = 1;

CREATE TABLE genre (
	genre_id INT PRIMARY KEY,
	genre_name VARCHAR(255) NOT NULL,
	description VARCHAR(255)
);

CREATE TABLE publisher (
	publisher_id INT PRIMARY KEY,
	publisher_name VARCHAR(255) NOT NULL,
	publisher_description VARCHAR(255)
);

CREATE TABLE developer (
	developer_id INT PRIMARY KEY,
	developer_name VARCHAR(255) NOT NULL,
	developer_country VARCHAR(255)
);

CREATE TABLE platform (
	platform_id INT PRIMARY KEY,
	platform_name VARCHAR(255) NOT NULL,
	platform_type VARCHAR(255) NOT NULL
);

CREATE TABLE review (
	review_id INT PRIMARY KEY,
	review_text VARCHAR(255) NOT NULL,
	review_rating INT NOT NULL,
	review_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL REFERENCES user(user_id),
	game_id INT NOT NULL REFERENCES game(game_id)
);

CREATE TABLE game (
	game_id INT PRIMARY KEY,
	game_name VARCHAR(255) NOT NULL,
	game_description VARCHAR(255),
	genre_id INT NOT NULL REFERENCES genre(genre_id),
	publisher_id INT NOT NULL REFERENCES publisher(publisher_id),
	developer_id INT NOT NULL REFERENCES developer(developer_id),
	platform_id INT NOT NULL REFERENCES platform(platform_id)
);

CREATE TABLE "order" (
	order_id INT PRIMARY KEY,
	status VARCHAR(255) NOT NULL,
	all_price INT NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	number INT NOT NULL,
	order_item_id INT NOT NULL REFERENCES order_item(order_id),
	payment_method_id INT NOT NULL REFERENCES payment_method(payment_method_id),
	delivery_method_id INT NOT NULL REFERENCES delivery_method(delivery_method_id),
	user_id INT NOT NULL REFERENCES user(user_id),
	game_id INT NOT NULL REFERENCES game(game_id)
);
