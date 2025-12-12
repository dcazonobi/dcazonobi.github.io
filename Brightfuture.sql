SELECT * FROM public.players_personal
ORDER BY "ID" ASC 

--What are the names of all the players older than 25?
SELECT "Name"
FROM players_personal
WHERE "Age" > '25'
ORDER BY "Name";
--3939 players over 25

-- What if there are multiple players with the same name?
SELECT "Name", 
COUNT(*) as cnt 
FROM players_personal  
WHERE "Age" > 25 
GROUP BY "Name" 
ORDER BY count(*) DESC;
--3878 names in total, Felipe being the most popular

SELECT * 
FROM players_personal 
WHERE "Name" = 'Felipe' 
ORDER BY "Age";
--Quick look into players with the name 'Felipe', All Brazilian

--From what country is L. Sigali, and for what club do they play?
SELECT "Name", "Nationality", "Club"
FROM players_personal
WHERE "Name" = 'L. Sigali'
--Argentinian and plays for 'Racing Club'

--What is the height, weight, and age of E. Kalinski?
SELECT "Name", "Height_cm", "Weight_kg", "Age"
FROM players_personal
WHERE "Name" = 'E. Kalinski'
-- Height 183cm, weight 77kg, age 31

--What is the average weight of players with a height of 183cm?
SELECT ROUND(AVG("Weight_kg"),2) AS Weight_kg
FROM players_personal
WHERE "Height_cm" = '183'

SELECT * FROM public.brightfuture_stakeholder_report
ORDER BY "ID" ASC 

--Who are the players from Spain?
SELECT "Name", "Nationality"
FROM players_personal
WHERE "Nationality" = 'Spain';
--496 Spanish Players in total

--Who are the players from Brazil?
SELECT "Name", "Nationality"
FROM players_personal
WHERE "Nationality" = 'Brazil';
--485 Brazilian Players in total

--How many players are there per country?
SELECT "Nationality" 
 ,COUNT("Nationality") AS No_of_players
FROM players_personal
GROUP BY "Nationality"
ORDER BY No_of_players DESC;
--Top is England with 871 players 

--What is the average age, height, weight, and wage of the players?
SELECT 
    'All Players' AS Group_Category,
    ROUND(AVG("Age"), 0) AS Avg_Age,
    ROUND(AVG("Height_cm"), 2) AS Avg_Height,
    ROUND(AVG("Weight_kg"), 2) AS Avg_Weight,
    ROUND(AVG("Wage_K"), 2) AS Avg_Wage
FROM players_personal
-- avg age 25, avg height 180.6cm, avg weight 74.91kg, avg wage 10.75k euro

UNION ALL

--What is the average age, height, weight, and wage of the players from Brazil?
SELECT 
    'Brazil' AS Group_Category,
    ROUND(AVG("Age"), 0) AS Avg_Age,
    ROUND(AVG("Height_cm"), 2) AS Avg_Height,
    ROUND(AVG("Weight_kg"), 2) AS Avg_Weight,
    ROUND(AVG("Wage_K"), 2) AS Avg_Wage
FROM players_personal
WHERE "Nationality" = 'Brazil'
-- avg age 28, avg height 180.46cm, avg weight 75.65kg, avg wage 19.69k euro

UNION ALL

--What is the average age, height, weight, and wage of the players from Spain?
SELECT 
    'Spain' AS Group_Category,
    ROUND(AVG("Age"), 0) AS Avg_Age,
    ROUND(AVG("Height_cm"), 2) AS Avg_Height,
    ROUND(AVG("Weight_kg"), 2) AS Avg_Weight,
    ROUND(AVG("Wage_K"), 2) AS Avg_Wage
FROM players_personal
WHERE "Nationality" = 'Spain';
-- avg age 26, avg height 180.31cm, avg weight 73.91kg, avg wage 17.66k euro