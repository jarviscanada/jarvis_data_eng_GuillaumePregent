-- Q1
INSERT INTO cd.facilities
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);

-- Q2
INSERT INTO cd.facilities
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
    (
        (
            SELECT
                MAX(facid)
            FROM
                cd.facilities
        )+ 1,
        'Spa',
        20,
        30,
        100000,
        800
    );

-- Q3
UPDATE
    cd.facilities
SET
    initialoutlay = 10000
WHERE
    facid = 1;

-- Q4
UPDATE
    cd.facilities
SET
    membercost = (
                     SELECT
                         membercost
                     FROM
                         cd.facilities
                     WHERE
                         facid = 0
                 ) * 1.1,
    guestcost = (
                    SELECT
                        guestcost
                    FROM
                        cd.facilities
                    WHERE
                        facid = 0
                ) * 1.1
WHERE
    facid = 1;

-- Q5
DELETE FROM
    cd.bookings;

-- Q6
DELETE FROM
    cd.members
WHERE
    memid = 37;

-- Q7
SELECT
    facid,
    name,
    membercost,
    monthlymaintenance
FROM
    cd.facilities
WHERE
    membercost > 0
  AND membercost < monthlymaintenance / 50;

-- Q8
SELECT
    *
FROM
    cd.facilities
WHERE
    name LIKE '%Tennis%';

-- Q9
SELECT
    *
FROM
    cd.facilities
WHERE
    facid IN (1, 5);

-- Q10
SELECT
    memid,
    surname,
    firstname,
    joindate
FROM
    cd.members
WHERE
    joindate >= '2012-09-01';

-- Q11
SELECT
    surname
FROM
    cd.members
UNION
SELECT
    name
FROM
    cd.facilities;

-- Q12
SELECT
    starttime
FROM
    cd.bookings AS b
        JOIN cd.members AS m ON m.memid = b.memid
WHERE
    firstname = 'David'
  AND surname = 'Farrell';

-- Q13
SELECT
    b.starttime AS start,
    f.name AS name
FROM
    cd.bookings AS b
        JOIN cd.facilities AS f ON f.facid = b.facid
WHERE
    f.name LIKE 'Tennis Court%'
  AND b.starttime >= '2012-09-21'
  AND b.starttime < '2012-09-22'
ORDER BY
    b.starttime;

-- Q14
SELECT
    m.firstname AS memfname,
    m.surname AS memsname,
    r.firstname AS recfname,
    r.surname AS recsname
FROM
    cd.members AS m
        LEFT JOIN cd.members AS r ON r.memid = m.recommendedby
ORDER BY
    m.surname,
    m.firstname;

-- Q15
SELECT DISTINCT
    r.firstname,
    r.surname
FROM
    cd.members AS m
        JOIN cd.members AS r ON r.memid = m.recommendedby
ORDER BY
    r.surname,
    r.firstname;

-- Q16
SELECT
    DISTINCT m.firstname || ' ' || m.surname as member,
             (
                 SELECT
                     r.firstname || ' ' || r.surname as recommender
                 FROM
                     cd.members r
                 WHERE
                     r.memid = m.recommendedby
             )
FROM
    cd.members m
ORDER BY
    member;

-- Q17
SELECT
    recommendedby,
    COUNT(*) AS count
FROM
    cd.members
WHERE
    recommendedby IS NOT NULL
GROUP BY
    recommendedby
ORDER BY
    recommendedby

-- Q18
SELECT
    facid,
    SUM(slots) AS Total_Slots
FROM
    cd.bookings
GROUP BY
    facid
ORDER BY
    facid;

-- Q19
SELECT
    facid,
    SUM(slots) AS Total_Slots
FROM
    cd.bookings
WHERE
    starttime >= '2012-09-01'
  AND starttime < '2012-10-01'
GROUP BY
    facid
ORDER BY
    SUM(slots);

-- Q20
SELECT
    facid,
    EXTRACT(
            MONTH
            FROM
            starttime
    ) AS month,
  SUM(slots) AS Total_Slots
FROM
    cd.bookings
WHERE
    EXTRACT(
    YEAR
    FROM
    starttime
    ) = '2012'
GROUP BY
    facid,
    month
ORDER BY
    facid,
    month;

-- Q21
SELECT
    COUNT(DISTINCT memid)
FROM
    cd.bookings;

-- Q22
SELECT
    m.surname,
    m.firstname,
    m.memid,
    MIN(b.starttime) AS starttime
FROM
    cd.members AS m
        JOIN cd.bookings AS b ON b.memid = m.memid
WHERE
    b.starttime >= '2012-09-01'
GROUP BY
    m.memid
ORDER BY
    m.memid;


-- Q23
SELECT
    (
        SELECT
            COUNT(memid)
        FROM
            cd.members
    ) AS count,
  firstname,
  surname
FROM
    cd.members
GROUP BY
    memid
ORDER BY
    joindate;

-- Q24
SELECT
    ROW_NUMBER() OVER (ORDER BY JOINDATE),
    firstname,
    surname
FROM
    cd.members
ORDER BY
    joindate;

-- Q25
SELECT
    facid,
    total
FROM
    (
        SELECT
            facid,
            SUM(slots) AS total,
            RANK() OVER (
        ORDER BY
          SUM(slots) DESC
      ) AS rank
        FROM
            cd.bookings
        GROUP BY
            facid
    ) AS ranked
WHERE
    rank = 1

-- Q26
SELECT
    surname || ', ' || firstname AS name
FROM
    cd.members;

-- Q27
SELECT
    memid,
    telephone
FROM
    cd.members
WHERE
    telephone LIKE '(%)%'
ORDER BY
    memid;

-- Q28
SELECT
    SUBSTR(surname, 1, 1) AS letter,
    COUNT(memid) AS count
FROM
    cd.members
GROUP BY
    letter
ORDER BY
    letter;
