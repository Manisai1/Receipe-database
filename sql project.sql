CREATE DATABASE recipe_manager;
USE recipe_manager;

-- --users--
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    diet_preference VARCHAR(50)
);

-- Recipe --

CREATE TABLE recipes (
    recipe_id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_name VARCHAR(100) NOT NULL,
    cuisine VARCHAR(50),
    difficulty VARCHAR(20),
    prep_time INT,
    cooking_method VARCHAR(50),
    calories INT,
    protein FLOAT,
    carbs FLOAT,
    fats FLOAT,
    is_vegetarian BOOLEAN,
    is_gluten_free BOOLEAN,
    user_id INT,
    created_at DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE(recipe_name, user_id)
);


-- Ingredients-- 
CREATE TABLE ingredients (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_name VARCHAR(100) UNIQUE
);
CREATE TABLE recipe_ingredients (
    recipe_id INT,
    ingredient_id INT,
    quantity VARCHAR(50),
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);


-- pantry-- 
CREATE TABLE pantry (
    user_id INT,
    ingredient_id INT,
    quantity VARCHAR(50),
    expiry_date DATE,
    PRIMARY KEY (user_id, ingredient_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);

-- ratings--
CREATE TABLE ratings (
    user_id INT,
    recipe_id INT,
    stars INT CHECK (stars BETWEEN 1 AND 5),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    recipe_id INT,
    comment TEXT,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);


-- meal planning --
CREATE TABLE meal_plan (
    meal_plan_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    recipe_id INT,
    meal_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);


-- cooking histry --
CREATE TABLE cooking_history (
    user_id INT,
    recipe_id INT,
    cooked_date DATE,
    PRIMARY KEY (user_id, recipe_id, cooked_date)
);

CREATE TABLE favorites (
    user_id INT,
    recipe_id INT,
    PRIMARY KEY (user_id, recipe_id)
);
ALTER TABLE users
ADD diet_preference VARCHAR(50);

INSERT INTO users (user_name, email, diet_preference) VALUES
('Ravi', 'ravi@gmail.com', 'Vegetarian'),
('Anu', 'anu@gmail.com', 'Low Carb');



INSERT INTO ingredients (ingredient_name) VALUES
('Egg'),
('Onion'),
('Salt'),
('Rice'),
('Flour'),
('Bread'),
('Butter'),
('Vegetables'),
('Avocado'),
('Milk'),
('Cheese');


INSERT INTO recipes
(recipe_name, cuisine, difficulty, prep_time, cooking_method,
 calories, protein, carbs, fats,
 is_vegetarian, is_gluten_free, user_id, created_at)
VALUES
('Vegetable Omelette', 'Breakfast', 'Easy', 15, 'Pan Fry',
 250, 18, 5, 15, FALSE, TRUE, 1, CURDATE()),

('Veg Rice', 'Lunch', 'Medium', 30, 'Boil',
 400, 12, 60, 10, TRUE, TRUE, 2, CURDATE()),

('Chapati', 'Dinner', 'Easy', 20, 'Pan Fry',
 200, 6, 30, 5, TRUE, FALSE, 1, CURDATE()),

('Avocado Salad', 'Salad', 'Easy', 10, 'No-Cook',
 180, 8, 10, 12, TRUE, TRUE, 3, CURDATE()),

('Cheese Sandwich', 'Snacks', 'Easy', 10, 'No-Cook',
 300, 10, 25, 18, TRUE, FALSE, 3, CURDATE());


INSERT INTO recipe_ingredients VALUES
-- Vegetable Omelette
(1, 1, '2 eggs'),
(1, 2, '1 chopped'),
(1, 3, 'to taste'),

-- Veg Rice
(2, 4, '2 cups'),
(2, 8, '1 cup'),
(2, 3, 'to taste'),

-- Chapati
(3, 5, '2 cups'),
(3, 3, 'to taste'),

-- Avocado Salad
(4, 9, '1 sliced'),
(4, 8, '1 cup'),
(4, 3, 'to taste'),

-- Cheese Sandwich
(5, 6, '2 slices'),
(5, 11, '1 slice'),
(5, 7, '1 spoon');


INSERT INTO pantry (user_id, ingredient_id, quantity, expiry_date) VALUES
(1, 1, '6 eggs', CURDATE() + INTERVAL 2 DAY),
(1, 2, '3 onions', CURDATE() + INTERVAL 5 DAY),
(1, 3, '100 g', CURDATE() + INTERVAL 20 DAY),
(1, 9, '2 avocados', CURDATE() + INTERVAL 1 DAY),

(2, 4, '5 kg rice', CURDATE() + INTERVAL 30 DAY),
(2, 8, '1 kg vegetables', CURDATE() + INTERVAL 3 DAY);

INSERT INTO ratings VALUES
(1, 1, 5),
(2, 1, 4),
(3, 2, 5),
(1, 4, 5),
(2, 4, 4),
(3, 5, 3);
INSERT INTO reviews (user_id, recipe_id, comment) VALUES
(1, 1, 'Very tasty and easy'),
(2, 2, 'Healthy and filling'),
(3, 4, 'Fresh and quick recipe');

INSERT INTO meal_plan (user_id, recipe_id, meal_date) VALUES
(1, 1, CURDATE()),
(1, 4, CURDATE() + INTERVAL 1 DAY),
(2, 2, CURDATE() + INTERVAL 2 DAY);
INSERT INTO cooking_history VALUES
(1, 1, CURDATE()),
(1, 4, CURDATE() - INTERVAL 1 DAY),
(2, 2, CURDATE());
INSERT INTO favorites VALUES
(1, 1),
(1, 2),
(1, 4),
(2, 2),
(3, 4),
(3, 5);


USE recipe_manager;
SELECT r.recipe_name
FROM recipes r
WHERE NOT EXISTS (
  SELECT *
  FROM recipe_ingredients ri
  WHERE ri.recipe_id = r.recipe_id
  AND ri.ingredient_id NOT IN
      (SELECT ingredient_id FROM pantry WHERE user_id = 1)
);


SELECT recipe_id, AVG(stars) AS avg_rating
FROM ratings
GROUP BY recipe_id
ORDER BY avg_rating DESC;

SELECT recipe_name
FROM recipes
WHERE is_vegetarian = TRUE AND prep_time <= 30;

SELECT recipe_name
FROM recipes
WHERE protein > 20 AND carbs < 15;

SELECT ingredient_id, COUNT(*) AS usage_count
FROM recipe_ingredients
GROUP BY ingredient_id
ORDER BY usage_count DESC
LIMIT 5;

SELECT recipe_name
FROM recipes
WHERE cooking_method = 'No-Cook';


SELECT recipe_name
FROM recipes
WHERE user_id = 1;

SELECT user_id, COUNT(*) AS recipe_count
FROM recipes
WHERE created_at >= CURDATE() - INTERVAL 1 MONTH
GROUP BY user_id
ORDER BY recipe_count DESC;

SELECT i.ingredient_name, ri.quantity
FROM meal_plan mp
JOIN recipe_ingredients ri ON mp.recipe_id = ri.recipe_id
JOIN ingredients i ON ri.ingredient_id = i.ingredient_id
WHERE mp.meal_plan_id = 1;

SELECT ingredient_id
FROM recipe_ingredients
WHERE recipe_id = 2
AND ingredient_id NOT IN
(SELECT ingredient_id FROM pantry WHERE user_id = 1);

select * from recipes;
SELECT r.recipe_name
FROM recipes r
JOIN ratings rt ON r.recipe_id = rt.recipe_id
WHERE r.is_gluten_free = TRUE
GROUP BY r.recipe_id
HAVING AVG(rt.stars) > 4;

SELECT recipe_id, cooked_date
FROM cooking_history
WHERE user_id = 1;

SELECT user_id
FROM favorites
GROUP BY user_id
HAVING COUNT(*) > 1;

SELECT cooking_method, COUNT(*)
FROM recipes
GROUP BY cooking_method
ORDER BY COUNT(*) DESC;


SELECT user_id, ingredient_id
FROM pantry
WHERE expiry_date <= CURDATE() + INTERVAL 3 DAY;




