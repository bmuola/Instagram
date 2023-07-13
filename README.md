![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/bmuola)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/bmuola?tab=repositories)

# Dummy Instagram Case Study

> 
## 📕 **Table of contents**
<!--ts-->
   * 🛠️ [Overview](#️-overview)
   * 🚀 [Solutions](#-solutions).

## 🛠️ Overview
With the **Instagram Case Study**, I queried data to bring insights to the following questions:<br>
1.Top 10 followed users on the platform<br>
2.Total number of registrations<br>
3.Total number of posts per instagram account<br>
4.Number of Sign-ins per Day<br>
5.Inactive users<br>
6.Most likes on a photo<br>
7.Number of photo posted by most active users<br>
8.Most popular tag names by usage<br>
9.Most popular tag names by likes<br>
10.Users who have liked every single photo on the platform<br>
11.Percentage of users who have either never commented on a photo<br>

---
## 🚀 Solutions

![Question 1](https://img.shields.io/badge/Question-1-971901)

**Let's find out the Top 10 most followed accounts**
```sql
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
```

<br>

**Output:**

```sql

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
```

---

![Question 2](https://img.shields.io/badge/Question-2-971901)

**Now let's find the total number of registrations.**
```sql
SELECT COUNT(created_at) AS RegistrationCount
FROM instagram.public.users;
```

**Output:**

```sql
+-------+
| count |
+-------+
|  100  |
+-------+
```

---

![Question 3](https://img.shields.io/badge/Question-3-971901)

**Let's now find the total number of posts for every Instagram account.**
```sql
-- We'll join the users and photos table on users.id and photos.user_id
SELECT users.username,
        COUNT(image_url) AS PostCount
FROM instagram.public.users
LEFT JOIN instagram.public.photos
    ON users.id = photos.user_id
GROUP BY users.ID
ORDER BY PostCount DESC;
```

**Output:**

```sql
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
-- there are 89 others
+----+---------------------+-------+
```

---

![Question 4](https://img.shields.io/badge/Question-4-971901)

**Now let's take a look at the number of sign-ins per day.**
```sql
-- Assuming that users interact with posts every time they're on the platform,
-- we can derive the number of logins in a day from likes.
WITH like_counts AS (
    SELECT created_at,
           user_id,
           COUNT(photo_id) AS LikeCount
    FROM instagram.public.likes
    GROUP BY created_at, user_id
)
SELECT TO_CHAR(created_at, 'YYYY-MM-DD') AS Date,
       COUNT(user_id) AS SignInCount
FROM like_counts
GROUP BY Date;
```

**Output:**

```sql
+----+------------+-------------+
| id |    date    | SignInCount |
+----+------------+-------------+
|  1 | 2023-07-13 |     77      |
+----+------------+-------------+
```

---

![Question 5](https://img.shields.io/badge/Question-5-971901)

**Let's now find the number of inactive users.**
```sql
-- Similar to the assumption above, we can query a list of users who didn't like any pictures.
CREATE TEMPORARY TABLE temp_likes AS (
    SELECT user_id, COUNT(photo_id) AS LikeCount
    FROM instagram.public.likes
    GROUP BY user_id
);
SELECT COUNT(users.ID) AS InactiveUserCount
FROM instagram.public.users
LEFT JOIN temp_likes
    ON temp_likes.user_id = users.id
WHERE LikeCount IS NULL;
```

**Output:**

```sql
+-------+
| count |
+-------+
|   23  |
+-------+
```

---

![Question 6](https://img.shields.io/badge/Question-6-971901)

**Let's find out which photo has the most likes.**
```sql
SELECT photos.image_url,
        COUNT(likes.photo_id) AS LikeCount
FROM instagram.public.photos
LEFT JOIN instagram.public.likes
    ON photos.id = likes.photo_id
GROUP BY photos.image_url
ORDER BY LikeCount DESC
LIMIT 1;
```

**Output:**

```sql
+--------------+-----------+
|  image_url   | LikeCount |
+--------------+-----------+
| http://moses.biz |    33     |
+--------------+-----------+
```

---

![Question 7](https://img.shields.io/badge/Question-7-971901)

**Let's now find the most popular tag names by usage.**
```sql
SELECT tags.tag_name,
        COUNT(photo_tags.photo_id) AS UsedCount
FROM instagram.public.tags
LEFT JOIN instagram.public.photo_tags
        ON tags.id = photo_tags.tag_id
GROUP BY tags.tag_name
ORDER BY UsedCount DESC
LIMIT 5;
```

**Output:**

```sql
+----------+------+
| tag_name | UsedCount |
+----------+------+
|  smile   |   59  |
|  beach   |   42  |
|  party   |   39  |
|   fun    |   38  |
|   food   |   24  |
+----------+------+
```

---

![Question 8](https://img.shields.io/badge/Question-8-971901)

**Let's now find the most popular tags by likes.**
```sql
SELECT tags.tag_name,
        COUNT(likes.created_at) AS LikeCount
FROM instagram.public.tags
LEFT JOIN instagram.public.photo_tags


        ON tags.id = photo_tags.tag_id
LEFT JOIN instagram.public.likes
    ON photo_tags.photo_id = likes.photo_id
GROUP BY tags.tag_name
ORDER BY LikeCount DESC
LIMIT 5;
```

**Output:**

```sql
+-----------+------+
| tag_name  | LikeCount |
+-----------+------+
|   smile   |  2033 |
|   beach   |  1448 |
|   party   |  1323 |
|    fun    |  1301 |
|  concert  |   825 |
+-----------+------+
```

---

![Question 9](https://img.shields.io/badge/Question-9-971901)

**Let's find users who have liked every photo on the platform.**
```sql
CREATE TEMPORARY TABLE like_user AS (
    SELECT users.id AS ID,
           users.username AS Username,
           COUNT(DISTINCT likes.photo_id) AS LikeCount
    FROM instagram.public.users
    JOIN instagram.public.likes
        ON users.id = likes.user_id
    GROUP BY users.id, users.username
);

SELECT lu.Username,
       lu.LikeCount
FROM like_user lu
JOIN instagram.public.likes l
    ON lu.ID = l.user_id
JOIN instagram.public.photos p
    ON l.photo_id = p.id
GROUP BY lu.Username, lu.LikeCount
HAVING lu.LikeCount = (SELECT COUNT(*) FROM instagram.public.photos)
ORDER BY lu.LikeCount DESC;
```

**Output:**

```sql
+------------------+------------+
|     username     | LikeCount  |
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
```

---

![Question 10](https://img.shields.io/badge/Question-10-971901)

**Let's calculate the percentage of users who have never commented on a photo.**
```sql
SELECT COUNT(subquery.ID)::FLOAT / COUNT(u.id) * 100 AS Percentage
FROM (
    SELECT users.id AS ID,
           COUNT(comments.created_at) AS CommentCount
    FROM instagram.public.users
    LEFT JOIN instagram.public.comments
        ON users.id = comments.user_id
    GROUP BY users.id
    HAVING COUNT(comments.created_at) = 0
) AS subquery
RIGHT JOIN instagram.public.users AS u
    ON subquery.ID = u.id;
```

**Output:**

```sql
+------------+
| Percentage |
+------------+
|     23     |
+------------+
```

---
