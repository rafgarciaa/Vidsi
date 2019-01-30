-- reinitializes the tables in the database
DROP TABLE IF EXISTS subscribers;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS subscription_plans;
DROP TABLE IF EXISTS subscribers_subscription_plans;
DROP TABLE IF EXISTS content_creators;
DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS views;
DROP TABLE IF EXISTS licenses;

PRAGMA foreign_keys = ON; -- turn on foreign key constraints to ensure data integrity

-- USERS / SUBSCRIBERS
CREATE TABLE subscribers(
    id INTEGER PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_digest VARCHAR(255) NOT NULL,
    payment_info INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- SUBSCRIPTION PLANS
CREATE TABLE subscription_plans(
    id INTEGER PRIMARY KEY,
    plan_name VARCHAR(255) NOT NULL,
    plan_price FLOAT NOT NULL,
    streaming_time_limit INTEGER NOT NULL -- hours
);

-- SUBSCRIBERS SUBSCRIPTION PLANS
CREATE TABLE subscribers_subscription_plans(
    subscribers_subscription_plan_id INTEGER PRIMARY KEY,
    subscriber_id INTEGER NOT NULL,
    subscription_plan_id INTEGER NOT NULL,

    FOREIGN KEY (subscriber_id) REFERENCES subscribers(id),
    FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans(id)
);

-- INVOICES
CREATE TABLE invoices(
    id INTEGER PRIMARY KEY,
    subscriber_id INTEGER NOT NULL,
    amount_due FLOAT NOT NULL,
    amount_paid FLOAT NOT NULL,
    due_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (subscriber_id) REFERENCES subscribers(id)
);

-- CONTENT CREATORS
CREATE TABLE content_creators(
    id INTEGER PRIMARY KEY,
    creator_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_digest VARCHAR(255) NOT NULL
);

-- VIDEOS
CREATE TABLE videos(
    id INTEGER PRIMARY KEY,
    content_creator_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    video_description VARCHAR(255) NOT NULL,
    time_duration INTEGER NOT NULL, -- in minutes

    FOREIGN KEY (content_creator_id) REFERENCES content_creators(id)
);

-- VIEWS
CREATE TABLE views(
    id INTEGER PRIMARY KEY,
    subscriber_id INTEGER NOT NULL,
    video_id INTEGER NOT NULL,
    stream_time INTEGER NOT NULL, -- in minutes
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (subscriber_id) REFERENCES subscribers(id),
    FOREIGN KEY (video_id) REFERENCES videos(id)
);

-- LICENSES
CREATE TABLE licenses(
    id INTEGER PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    concurrent_views INTEGER NOT NULL,
    content_creator_id INTEGER NOT NULL,

    FOREIGN KEY (content_creator_id) REFERENCES content_creators(id)
);


-- SEEDS

-- USER/SUBSCRIBER SEEDS
INSERT INTO
    subscribers(first_name, last_name, email, password_digest, payment_info)
VALUES
    ('Raf', 'Garcia', 'rafgarcia@email.com', '$2a$10$rGmeqOkuIMpG7Sa22dC9YuEpELv8OPSUD5PBQ/PKioIBKh1tjU/yS', 4117236251193852),
    ('Andre', 'Chow', 'andrechow@email.com', '$2a$10$UuacvDiZIhIfa1r5RABHDupP1npyPLKDAkp.DoiWbjp74gZArinwK', 4117236251193852),
    ('Charles', 'Kitchen', 'charleskitchen@email.com', '$2a$10$rGmeqOkuIMpG7Sa22dC9YuEpELv8OPSUD5PBQ/PKioIBKh1tjU/yS', 4117236251193852);

-- SUBSCRIPTION PLAN SEEDS
INSERT INTO
    subscription_plans(plan_name, plan_price, streaming_time_limit)
VALUES
    ('Basic', 10, 72), -- 3 days streaming
    ('Plus', 20, 144), -- 6 days streaming
    ('Pro', 30, 240); -- 9 days streaming

-- SUBSCRIBERS SUBSCRIPTION PLAN SEEDS
INSERT INTO
    subscribers_subscription_plans(subscriber_id, subscription_plan_id)
VALUES
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM subscription_plans WHERE plan_name = 'Basic')),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM subscription_plans WHERE plan_name = 'Plus')),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM subscription_plans WHERE plan_name = 'Pro'));

-- INVOICE SEEDS
INSERT INTO
    invoices (subscriber_id, amount_due, amount_paid, due_date)
VALUES
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), 10, 10, '2019-03-01'),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), 20, 10, '2019-03-01'),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), 20, 5, '2019-02-01'),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), 30, 15, '2019-03-01');

-- CONTENT CREATOR SEEDS
INSERT INTO
    content_creators(creator_name, email, password_digest)
VALUES
    ('BBC', 'main_account@bbc.com', '$2a$10$UuacvDiZIhIfa1r5RABHDupP1npyPLKDAkp.DoiWbjp74gZArinwK'),
    ('CBS', 'main_account@cbs.com', '$2a$10$rGmeqOkuIMpG7Sa22dC9YuEpELv8OPSUD5PBQ/PKioIBKh1tjU/yS'),
    ('Marvel', 'marvel_account@disney.com', '$2a$10$UuacvDiZIhIfa1r5RABHDupP1npyPLKDAkp.DoiWbjp74gZArinwK');

-- VIDEO SEEDS
INSERT INTO
    videos(content_creator_id, title, video_description, time_duration)
VALUES
    ((SELECT id FROM content_creators WHERE email = 'main_account@bbc.com'), 'A Study in Pink', 'Sherlock S01:E01', 88),
    ((SELECT id FROM content_creators WHERE email = 'main_account@bbc.com'), 'The Blind Banker', 'Sherlock S01:E02', 89),
    ((SELECT id FROM content_creators WHERE email = 'main_account@bbc.com'), 'The Great Game', 'Sherlock S01:E03', 90),
    ((SELECT id FROM content_creators WHERE email = 'main_account@cbs.com'), 'Pilot', 'The Big Bang Theory S01:E01', 23),
    ((SELECT id FROM content_creators WHERE email = 'main_account@cbs.com'), 'The Big Bran Hypothesis', 'The Big Bang Theory S01:E02', 21),
    ((SELECT id FROM content_creators WHERE email = 'main_account@cbs.com'), 'The Fuzzy Brown Boots Corollary', 'The Big Bang Theory S01:E03', 22),
    ((SELECT id FROM content_creators WHERE email = 'marvel_account@disney.com'), 'The Avengers', 'Earths mightiest heroes must come together and learn to fight as a team.', 143),
    ((SELECT id FROM content_creators WHERE email = 'marvel_account@disney.com'), 'Avengers: Age of Ultron', 'When Tony Stark and Bruce Banner try to jump-start a dormant peacekeeping program called Ultron, things go horribly wrong and its up to Earths mightiest heroes to stop the villainous Ultron from enacting his terrible plan.', 141),
    ((SELECT id FROM content_creators WHERE email = 'marvel_account@disney.com'), 'Avengers: Infinity War', 'The Avengers and their allies must be willing to sacrifice all in an attempt to defeat the powerful Thanos before his blitz of devastation and ruin puts an end to the universe.', 150);

-- VIEW SEEDS
INSERT INTO
    views(subscriber_id, video_id, stream_time)
VALUES
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'A Study in Pink'), 88),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'A Study in Pink'), 88),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Blind Banker'), 89),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Blind Banker'), 89),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Blind Banker'), 89),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Great Game'), 90),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Great Game'), 90),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Great Game'), 90),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'The Great Game'), 90),
    ((SELECT id FROM subscribers WHERE email = 'rafgarcia@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Infinity War'), 150),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'The Avengers'), 143),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'The Avengers'), 143),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'The Avengers'), 143),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'The Avengers'), 143),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'The Avengers'), 143),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Age of Ultron'), 141),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Age of Ultron'), 141),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Age of Ultron'), 141),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Age of Ultron'), 141),
    ((SELECT id FROM subscribers WHERE email = 'andrechow@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Infinity War'), 150),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'Pilot'), 23),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'Pilot'), 23),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'The Big Bran Hypothesis'), 21),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'The Big Bran Hypothesis'), 21),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'The Fuzzy Brown Boots Corollary'), 22),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'The Fuzzy Brown Boots Corollary'), 22),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Infinity War'), 150),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Infinity War'), 150),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Infinity War'), 150),
    ((SELECT id FROM subscribers WHERE email = 'charleskitchen@email.com'), (SELECT id FROM videos WHERE title = 'Avengers: Infinity War'), 150);