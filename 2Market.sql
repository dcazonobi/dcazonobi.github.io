CREATE TABLE marketing_data (
  ID               INT           PRIMARY KEY,
  Year_Birth       INT,
  Age              INT,
  Education        VARCHAR(50),
  Marital_Status   VARCHAR(50),
  Income           VARCHAR(12),
  Kidhome          INT,
  Teenhome         INT,
  Dt_Customer      VARCHAR(10),
  Recency          INT,
  AmtLiq           INT,
  AmtVege          INT,
  AmtNonVeg        INT,
  AmtPes           INT,
  AmtChocolates    INT,
  AmtComm          INT,
  Total_Spend      INT,
  NumDeals         INT,
  NumWebBuy        INT,
  NumWalkinPur     INT,
  NumVisits        INT,
  Response         BOOLEAN,
  Complain         BOOLEAN,
  Country          CHAR(3),
  Count_success    INT
);

SELECT * FROM public.marketing_data;

SELECT Country,Total_Spend
FROM marketing_data

SELECT Country,
SUM(Total_Spend)
FROM marketing_data
GROUP BY Country;

SELECT Country, AmtLiq, AmtVege, AmtNonVeg, AmtPes, AmtChocolates, AmtComm
FROM marketing_data;

SELECT Country,
SUM(AmtLiq) AS total_liq_spend
FROM marketing_data
GROUP BY Country
ORDER BY Country;

SELECT Country,
SUM(AmtLiq)AS liq,
SUM(AmtVege)AS veg,
SUM(AmtNonVeg)AS nonveg,
SUM(AmtPes)AS pesc,
SUM(AmtChocolates)AS choco,
SUM(AmtComm)AS comm
FROM marketing_data
GROUP BY Country;

SELECT 
SUM(AmtLiq)AS liq,
SUM(AmtVege)AS veg,
SUM(AmtNonVeg)AS nonveg,
SUM(AmtPes)AS pesc,
SUM(AmtChocolates)AS choco,
SUM(AmtComm)AS comm
FROM marketing_data
WHERE Country = 'GER';

SELECT 
SUM(AmtLiq)AS liq,
SUM(AmtVege)AS veg,
SUM(AmtNonVeg)AS nonveg,
SUM(AmtPes)AS pesc,
SUM(AmtChocolates)AS choco,
SUM(AmtComm)AS comm
FROM marketing_data
WHERE marital_status = 'Absurd';

SELECT *
FROM marketing_data
WHERE NULLIF(Kidhome + Teenhome, 0) IS NOT NULL;

SELECT
SUM(AmtLiq)AS liq,
SUM(AmtVege)AS veg,
SUM(AmtNonVeg)AS nonveg,
SUM(AmtPes)AS pesc,
SUM(AmtChocolates) AS choco,
SUM(AmtComm)AS comm
FROM marketing_data
WHERE NULLIF(Kidhome + Teenhome, 0) IS NOT NULL;


CREATE TABLE ad_data ( 
  ID           INTEGER PRIMARY KEY,
  Bulkmail_ad  INTEGER,
  Twitter_ad   INTEGER,
  Instagram_ad INTEGER,
  Facebook_ad  INTEGER,
  Brochure_ad  INTEGER
);

SELECT * FROM public.ad_data
ORDER BY id ASC 

ALTER TABLE marketing_data
  ALTER COLUMN response TYPE INTEGER USING response::INT,
  ALTER COLUMN complain TYPE INTEGER USING complain::INT;

SELECT
  m.*,
  a.Bulkmail_ad,
  a.Twitter_ad,
  a.Instagram_ad,
  a.Facebook_ad,
  a.Brochure_ad
FROM
  marketing_data AS m
LEFT JOIN
  ad_data AS a
  ON m.ID = a.ID;

SELECT
  SUM(instagram_ad) AS instagram,
  SUM(facebook_ad)  AS facebook,
  SUM(twitter_ad)   AS twitter
FROM ad_data;

SELECT
  m.country,
  SUM(a.instagram_ad) AS instagram_conversions,
  SUM(a.facebook_ad)  AS facebook_conversions,
  SUM(a.twitter_ad)   AS twitter_conversions,
  CASE
    WHEN SUM(a.instagram_ad) = 0
      AND SUM(a.facebook_ad) = 0
      AND SUM(a.twitter_ad) = 0
      THEN 'None'
    WHEN SUM(a.instagram_ad) >= GREATEST(
           SUM(a.facebook_ad),
           SUM(a.twitter_ad)
         ) THEN 'Instagram'
    WHEN SUM(a.facebook_ad) >= GREATEST(
           SUM(a.instagram_ad),
           SUM(a.twitter_ad)
         ) THEN 'Facebook'
    ELSE 'Twitter'
  END AS most_effective_platform
FROM
  marketing_data AS m
LEFT JOIN
  ad_data AS a USING (id)
GROUP BY
  m.country;

SELECT Country,
SUM(AmtLiq)AS liq,
SUM(AmtVege)AS veg,
SUM(AmtNonVeg)AS nonveg,
SUM(AmtPes)AS pesc,
SUM(AmtChocolates)AS choco,
SUM(AmtComm)AS comm
FROM marketing_data
GROUP BY Country;

SELECT
  m.country,
  SUM(m.AmtLiq)        AS liq,
  SUM(m.AmtVege)       AS veg,
  SUM(m.AmtNonVeg)     AS nonveg,
  SUM(m.AmtPes)        AS pesc,
  SUM(m.AmtChocolates) AS choco,
  SUM(m.AmtComm)       AS comm,
  SUM(
    a.Bulkmail_ad
    + a.Twitter_ad
    + a.Instagram_ad
    + a.Facebook_ad
    + a.Brochure_ad
  ) AS total_conversions,
  SUM(a.Bulkmail_ad)   AS bulkmail_conversions,
  SUM(a.Twitter_ad)    AS twitter_conversions,
  SUM(a.Instagram_ad)  AS instagram_conversions,
  SUM(a.Facebook_ad)   AS facebook_conversions,
  SUM(a.Brochure_ad)   AS brochure_conversions
FROM
  marketing_data AS m
LEFT JOIN
  ad_data AS a USING (ID)
GROUP BY
  m.country
ORDER BY
  total_conversions DESC;


SELECT
  m.country,
  SUM(
    m.AmtLiq
    + m.AmtVege
    + m.AmtNonVeg
    + m.AmtPes
    + m.AmtChocolates
    + m.AmtComm
  ) AS total_sales,
  SUM(
    a.Bulkmail_ad
    + a.Twitter_ad
    + a.Instagram_ad
    + a.Facebook_ad
    + a.Brochure_ad
  ) AS total_conversions,
  SUM(a.Bulkmail_ad)   AS bulkmail_conversions,
  SUM(a.Twitter_ad)    AS twitter_conversions,
  SUM(a.Instagram_ad)  AS instagram_conversions,
  SUM(a.Facebook_ad)   AS facebook_conversions,
  SUM(a.Brochure_ad)   AS brochure_conversions
FROM
  marketing_data AS m
LEFT JOIN
  ad_data AS a USING (ID)
GROUP BY
  m.country
ORDER BY
  total_conversions DESC; 
