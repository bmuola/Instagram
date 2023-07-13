--Let's find out the Top 10 most followed accounts
--First we'll find out a common KEY in order to perform a join function

SELECT *
FROM instagram.public.users;

SELECT *
FROM instagram.public.follows;

--We'll join both tables on users.id and follows.followee_id

SELECT users.username AS Username,
        COUNT(follows.follower_id)
FROM instagram.public.users
LEFT JOIN instagram.public.follows
    ON users.id = follows.followee_id
GROUP BY users.username
ORDER BY COUNT(follows.follower_id) DESC 
LIMIT 10;

--OUTPUT
+----+---------------------+-------+
| id |      username       | count |
+----+---------------------+-------+
|  1 |     Eveline95       |   77  |
|  2 |   Tierra.Trantow    |   77  |
|  3 |   Donald.Fritsch    |   77  |
|  4 |    Darby_Herzog     |   77  |
|  5 |  Kasandra_Homenick  |   77  |
|  6 |  Franco_Keebler64   |   77  |
|  7 | Delfina_VonRueden68 |   77  |
|  8 |  Esmeralda.Mraz57   |   77  |
|  9 |  Morgan.Kassulke    |   77  |
| 10 |      Cesar93        |   77  |
+----+---------------------+-------+

-- Now let's find the total number of registrations.

SELECT COUNT(created_at) AS COUNT
FROM instagram.public.users

--Output

+-------+
| count |
+-------+
|  100  |
+-------+

--Let's now find total number of posts for every insta account
--We'll join users and photos table on users.id and photos.user_id

SELECT users.username,
        COUNT(image_url) AS COUNT
FROM instagram.public.users
LEFT JOIN instagram.public.photos
    ON users.id = photos.user_id
GROUP BY users.ID
ORDER BY COUNT(image_url) DESC

--Output
+----+---------------------+-------+
| id |      username       | count |
+----+---------------------+-------+
|  1 |     Eveline95       |   12  |
|  2 |       Clint27       |   11  |
|  3 |      Cesar93        |   10  |
|  4 | Delfina_VonRueden68 |    9  |
|  5 |       Jaime53       |    8  |
|  6 |      Aurelie71      |    8  |
|  7 |   Donald.Fritsch    |    6  |
|  8 |    Kenton_Kirlin    |    5  |
|  9 |   Janet.Armstrong   |    5  |
| 10 |      Adelle96       |    5  |
| 11 |    Alexandro35      |    5  |
--there are 89 others
+----+---------------------+-------+


--Now let's take a look at number of sign-ins per day
--Assuming that users interacts with posts every time they're on the platform
--we can derive number of logins in a day from likes

WITH like_counts AS (
    SELECT created_at,
           user_id,
           COUNT(photo_id) AS count
    FROM instagram.public.likes
    GROUP BY created_at, user_id
)
SELECT TO_CHAR(created_at, 'YYYY-MM-DD') AS Date,
       COUNT(user_id) AS Sign_in
FROM like_counts
GROUP BY Date;



--OUTPUT
+----+------------+---------+
| id |    date    | sign_in |
+----+------------+---------+
|  1 | 2023-07-13 |    77   |
+----+------------+---------+



--Let's now find number of inactive users
--Similar to the assumption above, we can query a list of users who did'nt like pictures


CREATE TEMPORARY TABLE temp_likes AS (
    SELECT user_id, COUNT(photo_id) AS like_count
    FROM instagram.public.likes
    GROUP BY user_id
);
SELECT COUNT(users.ID)
FROM instagram.public.users
LEFT JOIN temp_likes
    ON temp_likes.user_id = users.id
WHERE like_count IS NULL

--OUTPUT
+-------+
| count |
+-------+
|   23  |
+-------+


--Let's find out which photo has the most likes

SELECT photos.image_url,
        COUNT(likes.photo_id)
FROM instagram.public.photos
LEFT JOIN instagram.public.likes
    ON photos.id = likes.photo_id
GROUP BY photos.image_url
LIMIT 1

--OUTPUT

+--------------+-----------+
|  image_url   | count     |
+--------------+-----------+
| http://moses.biz |   33  |
+--------------+-----------+

-- Let's now find most popular tag name by usage

SELECT tags.tag_name,
        COUNT(photo_tags.photo_id) AS Used
FROM instagram.public.tags
LEFT JOIN instagram.public.photo_tags
        ON tags.id = photo_tags.tag_id
GROUP BY tags.tag_name
ORDER BY COUNT(photo_tags.photo_id) DESC
LIMIT 5

--OUTPUT
+----------+------+
| tag_name | used |
+----------+------+
|  smile   |  59  |
|  beach   |  42  |
|  party   |  39  |
|   fun    |  38  |
|   food   |  24  |
+----------+------+


--Let's now find most popular tags by likes


SELECT tags.tag_name,
        COUNT(likes.created_at) AS Used
FROM instagram.public.tags
LEFT JOIN instagram.public.photo_tags
        ON tags.id = photo_tags.tag_id
LEFT JOIN instagram.public.likes
    ON photo_tags.photo_id = likes.photo_id
GROUP BY tags.tag_name
ORDER BY COUNT(likes.created_at) DESC
LIMIT 5

--OUTPUT

+-----------+------+
| tag_name  | used |
+-----------+------+
|   smile   | 2033 |
|   beach   | 1448 |
|   party   | 1323 |
|    fun    | 1301 |
|  concert  |  825 |
+-----------+------+


--Let's now find users who have liked every photo on the platform

CREATE TEMPORARY TABLE like_user AS (
    SELECT users.id AS ID,
           users.username AS Username,
           COUNT(DISTINCT likes.photo_id) AS like_count
    FROM instagram.public.users
    JOIN instagram.public.likes
        ON users.id = likes.user_id
    GROUP BY users.id, users.username
);

SELECT lu.Username,
       lu.like_count
FROM like_user lu
JOIN instagram.public.likes l
    ON lu.ID = l.user_id
JOIN instagram.public.photos p
    ON l.photo_id = p.id
GROUP BY lu.Username, lu.like_count
HAVING lu.like_count = (SELECT COUNT(*) FROM instagram.public.photos)
ORDER BY lu.like_count DESC;

--OUTPUT

+------------------+------------+
|     username     | like_count |
+------------------+------------+
|    Mike.Auer39   |    257     |
|  Julien_Schmidt  |    257     |
|     Bethany20    |    257     |
|     Jaclyn81     |    257     |
| Maxwell.Halvorson|    257     |
| Janelle.Nikolaus81|   257     |
|     Nia_Haag     |    257     |
|     Rocio33      |    257     |
|   Aniya_Hackett  |    257     |
|     Duane60      |    257     |
|    Leslie67      |    257     |
| Ollie_Ledner37   |    257     |
|     Mckenna17    |    257     |
+------------------+------------+


--Percentage of users who have never commented on a photo

SELECT COUNT(subquery.ID)::FLOAT / COUNT(u.id) * 100 AS Percentage
FROM (
    SELECT users.id AS ID,
           COUNT(comments.created_at) as comment_count
    FROM instagram.public.users
    LEFT JOIN instagram.public.comments
        ON users.id = comments.user_id
    GROUP BY users.id
    HAVING COUNT(comments.created_at) = 0
) AS subquery
RIGHT JOIN instagram.public.users AS u
    ON subquery.ID = u.id;

--OUTPUT

+------------+
| percentage |
+------------+
|     23     |
+------------+

--

