INSERT INTO people (user_id, email, username)
VALUES
	(1, 'user1@example.com', 'user1');

INSERT INTO genre (genre_id, genre_name, description)
VALUES
	(1, 'Action', 'Action games are characterized by fast-paced gameplay, dynamic combat, and a focus on physical challenges.');

INSERT INTO publisher (publisher_id, publisher_name, publisher_description)
VALUES
	(1, 'IVAN', 'IVAN is a company that makes games.');

INSERT INTO developer (developer_id, developer_name, developer_country)
VALUES
	(1, 'Kirill', 'Russia');

INSERT INTO platform (platform_id, platform_name, platform_type)
VALUES
	(1, 'PS5', 'console');

INSERT INTO game (game_id, game_name, game_description, genre_id, publisher_id, developer_id, platform_id)
VALUES
	(1, 'Game 1', 'Game 1 is a game about a boy who is a ninja.', 1, 1, 1, 1);

INSERT INTO review (review_id, review_text, review_rating, user_id, game_id)
VALUES
	(1, 'This game is great!', 5, 1, 1);

INSERT INTO order_item (order_id, number_order, count)
VALUES
	(1, 1, 1);

INSERT INTO payment_method (payment_method_id, description, payment_method_name)
VALUES
	(1, 'Payment by card', 'card');

INSERT INTO delivery_method (delivery_method_id, delivery_name, price)
VALUES
	(1, 'Delivery by courier', 100);

INSERT INTO "order" (order_id, status, all_price, created_at, number, order_item_id, payment_method_id, delivery_method_id, user_id, game_id)
VALUES
	(1, 'In progress', 100, '2021-01-01', 1, 1, 1, 1, 1, 1);
