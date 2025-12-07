CREATE TABLE artists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE albums (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    release_year INTEGER NOT NULL CHECK (release_year >= 1900 AND release_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tracks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    duration INTEGER NOT NULL CHECK (duration > 0),
    album_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE
);

CREATE TABLE compilations (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    release_year INTEGER NOT NULL CHECK (release_year >= 1900 AND release_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artist_genres (
    artist_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (artist_id, genre_id),
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

CREATE TABLE album_artists (
    album_id INTEGER NOT NULL,
    artist_id INTEGER NOT NULL,
    PRIMARY KEY (album_id, artist_id),
    FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE CASCADE,
    FOREIGN KEY (artist_id) REFERENCES artists(id) ON DELETE CASCADE
);

CREATE TABLE compilation_tracks (
    compilation_id INTEGER NOT NULL,
    track_id INTEGER NOT NULL,
    PRIMARY KEY (compilation_id, track_id),
    FOREIGN KEY (compilation_id) REFERENCES compilations(id) ON DELETE CASCADE,
    FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
);

-- ==================== ЧАСТЬ 2: ОСНОВНЫЕ ДАННЫЕ ====================
INSERT INTO genres (name) VALUES 
('Рок'),
('Поп'),
('Джаз');

INSERT INTO artists (name) VALUES 
('The Beatles'),
('Madonna'),
('Miles Davis'),
('Queen');

INSERT INTO albums (title, release_year) VALUES 
('Abbey Road', 1969),
('Like a Prayer', 1989),
('Kind of Blue', 1959);

INSERT INTO compilations (title, release_year) VALUES 
('Best of 60s', 2005),
('Pop Hits 80s-90s', 2010),
('Jazz Classics', 1998),
('Rock Legends', 2020);

INSERT INTO tracks (title, duration, album_id) VALUES 
('Come Together', 259, 1),
('Something', 183, 1),
('Here Comes the Sun', 185, 1),
('Like a Prayer', 335, 2),
('Express Yourself', 280, 2),
('So What', 562, 3);

INSERT INTO artist_genres (artist_id, genre_id) VALUES 
(1, 1),  
(2, 2),  
(3, 3),  
(4, 1);  

INSERT INTO album_artists (album_id, artist_id) VALUES 
(1, 1), 
(2, 2),  
(3, 3);  

INSERT INTO compilation_tracks (compilation_id, track_id) VALUES 
(1, 1),  
(1, 2),  
(2, 4),  
(3, 6),  
(4, 1),  
(4, 4);  


SELECT title, duration 
FROM tracks 
ORDER BY duration DESC 
LIMIT 1;

SELECT title, duration 
FROM tracks 
WHERE duration >= 210 
ORDER BY duration DESC;

SELECT title, release_year 
FROM compilations 
WHERE release_year BETWEEN 2018 AND 2020 
ORDER BY release_year;


SELECT name 
FROM artists 
WHERE name NOT LIKE '% %' 
ORDER BY name;

SELECT title 
FROM tracks 
WHERE LOWER(title) LIKE '%my%' 
ORDER BY title;


SELECT 
    g.name as "Жанр",
    COUNT(DISTINCT ag.artist_id) as "Количество исполнителей"
FROM genres g
LEFT JOIN artist_genres ag ON g.id = ag.genre_id
GROUP BY g.id, g.name
HAVING COUNT(DISTINCT ag.artist_id) > 0
ORDER BY "Количество исполнителей" DESC;




SELECT 
    COUNT(DISTINCT t.id) as "Треков в альбомах 2019-2020"
FROM tracks t
JOIN albums a ON t.album_id = a.id
WHERE a.release_year BETWEEN 2019 AND 2020;




SELECT 
    a.title as "Альбом",
    ROUND(AVG(t.duration), 2) as "Средняя длительность (сек)",
    COUNT(t.id) as "Количество треков"
FROM albums a
JOIN tracks t ON a.id = t.album_id
GROUP BY a.id, a.title
ORDER BY "Средняя длительность (сек)" DESC;



SELECT DISTINCT
    ar.name as "Исполнитель"
FROM artists ar
WHERE NOT EXISTS (
    SELECT 1 
    FROM album_artists aa 
    JOIN albums a ON aa.album_id = a.id 
    WHERE aa.artist_id = ar.id AND a.release_year = 2020
)
ORDER BY ar.name;



SELECT DISTINCT
    c.title as "Сборник",
    c.release_year as "Год выпуска"
FROM compilations c
JOIN compilation_tracks ct ON c.id = ct.compilation_id
JOIN tracks t ON ct.track_id = t.id
JOIN albums a ON t.album_id = a.id
JOIN album_artists aa ON a.id = aa.album_id
JOIN artists ar ON aa.artist_id = ar.id
WHERE ar.name = 'Queen'
ORDER BY c.release_year DESC;
