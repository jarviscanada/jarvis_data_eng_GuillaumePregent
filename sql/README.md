# Introduction

# SQL Queries

###### Table Setup (DDL)
```sql
CREATE TABLE cd.members (
  memid INTEGER NOT NULL, 
  surname VARCHAR(200) NOT NULL, 
  firstname VARCHAR(200) NOT NULL, 
  address VARCHAR(300) NOT NULL, 
  zipcode INTEGER NOT NULL, 
  telephone VARCHAR(20) NOT NULL, 
  recommendedby INTEGER, 
  joindate TIMESTAMP NOT NULL, 
  CONSTRAINT members_pk PRIMARY KEY (memid), 
  CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) 
    REFERENCES cd.member(memid) ON DELETE SET NULL
);
```

```sql
CREATE TABLE cd.facilities (
    facid INTEGER NOT NULL,
    name VARCHAR(100) NOT NULL,
    membercost NUMERIC NOT NULL,
    guestcost NUMERIC NOT NULL,
    initialoutlay NUMERIC NOT NULL,
    monthlymaintenance NUMERIC NOT NULL,
    CONSTRAINT failicty_pk PRIMARY KEY (facid)   
);
```

```sql
CREATE TABLE cd.bookings (
    bookid INTEGER NOT NULL,
    facid INTEGER NOT NULL,
    memid INTEGER NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots INTEGER NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (bookid),
    CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) 
        REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid FOREIGN KEY (memid)
        REFERENCES cd.members(memid)
);
```
###### Question 1: Insert new facility spa
```sql
INSERT INTO cd.facilities
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);
```

###### Question 2: Insert new facility spa with autoincremental id

```sql
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
```

###### Question 3: Update the second tennis court's initial outlay
```sql
UPDATE 
  cd.facilities 
SET 
  initialoutlay = 10000 
WHERE 
  facid = 1;
```

###### Question 4: Update the prices of the second tennis court to a 10% increase of the first court
```sql
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
```

###### Question 5: Delete all bookings
```sql
DELETE FROM 
  cd.bookings;
```

###### Question 6: Delete member 37
```sql
DELETE FROM 
  cd.members 
WHERE 
  memid = 37;
```

###### Question 7: Get a list of facilities that charge a member fee that is less than 1/50th of 
###### their monthly maintenance cost
```sql
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
```

###### Question 8: Get a list of facilities with 'Tennis' in their name
```sql
SELECT 
  * 
FROM 
  cd.facilities 
WHERE 
  name LIKE '%Tennis%';
```

###### Question 9: Select facilites 1 and 5
```sql
SELECT 
  * 
FROM 
  cd.facilities 
WHERE 
  facid IN (1, 5);
```

###### Question 10: Select the members that joined after the start of September 2012
```sql
SELECT 
  memid, 
  surname, 
  firstname, 
  joindate 
FROM 
  cd.members 
WHERE 
  joindate >= '2012-09-01';
```

###### Question 11: Get a combined list of surnames and facilities
```sql
SELECT 
  surname 
FROM 
  cd.members 
UNION 
SELECT 
  name 
FROM 
  cd.facilities;
```

###### Question 12: Get the start time of the bookings of member David Farrell
```sql
SELECT 
  starttime 
FROM 
  cd.bookings AS b 
  JOIN cd.members AS m ON m.memid = b.memid 
WHERE 
  firstname = 'David' 
  AND surname = 'Farrell';
```

###### Question 13: Get the start time and facilities for tennis courts on 2012-09-21
```sql
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
```

###### Question 14: Get the names of the members and the person who recommended them
```sql
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
```

###### Question 15: Get the firstname and lastname of people who recommend someone
```sql
SELECT DISTINCT
	r.firstname, 
	r.surname
FROM 
	cd.members AS m
JOIN cd.members AS r ON r.memid = m.recommendedby
ORDER BY
	r.surname, 
	r.firstname;
```

###### Question 16: Get the members and the people who recommended them without using joins
```sql
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
```

###### Question 17: Get the number of person each member recommended
```sql
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
```

###### Question 18: Get the total number of slots of each facility
```sql
SELECT
    facid,
    SUM(slots) AS Total_Slots
FROM
    cd.bookings
GROUP BY
    facid
ORDER BY
    facid;
```

###### Question 19: Get the total number of slots of each facility for the month of september 2012
```sql
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
```

###### Question 20: Get the total number of sloths per facility per month of 2012
```sql
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
```

###### Question 21: Get the number of people who have made at least one booking
```sql
SELECT 
  COUNT(DISTINCT memid) 
FROM 
  cd.bookings;
```

###### Question 22: Get the people and their first start time after September 2012
```sql
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
```

###### Question 23: Get the list of members with the total number of members
```sql
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
```

###### Question 24: Get the list of members ordered by their date of joining. 
###### Add a monotonically increasing row number.
```sql
SELECT
    ROW_NUMBER() OVER (ORDER BY JOINDATE),
    firstname,
    surname
FROM 
    cd.members
ORDER BY 
    joindate;
```

###### Question 25: Get the facility id that has the highest number of slots booked
```sql
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
```

###### Question 26: Get the surname, firstname of all members
```sql
SELECT 
  surname || ', ' || firstname AS name 
FROM 
  cd.members;
```

###### Question 27: Get the phone numbers containing parentheses sorted by id
```sql
SELECT 
  memid, 
  telephone 
FROM 
  cd.members 
WHERE 
  telephone LIKE '(%)%' 
ORDER BY 
  memid;
```

###### Question 28: Get number of patients whose surname starts with a letter
```sql
SELECT 
  SUBSTR(surname, 1, 1) AS letter, 
  COUNT(memid) AS count 
FROM 
  cd.members 
GROUP BY 
  letter 
ORDER BY 
  letter;
```