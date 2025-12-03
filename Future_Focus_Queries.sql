--1. What is the top-selling item?
SELECT
  description, count(description) as number_of_transaction
FROM sales 
GROUP BY description
ORDER BY number_of_transaction DESC
--Black Velvet is the top-selling item, with 81,095 sales

--2. What are the top two products with the highest volume of transactions? 
SELECT
  description, item, count(description) as number_of_transaction
FROM sales 
GROUP BY description, item
ORDER BY number_of_transaction DESC, description
--Black Velvet and Hawkeye Vodka are the top two products with the highest volume of transactions.

--3. Who are the top 10 vendors with the broadest product line-up? 
SELECT vendor_name, count(distinct item_no) as product_count
FROM products
GROUP BY vendor_name
ORDER BY product_count DESC
LIMIT 10
-- Top 10 Ranked : "Jim Beam Brands""Diageo Americas""Pernod Ricard Usa/austin Nichols""Yahara Bay Distillers Inc""Heaven Hill Distilleries Inc.""Bacardi U.s.a. Inc.""Luxco-st Louis""Mhw Ltd""Sazerac Co. Inc.""Sazerac North America"

--4. Which counties have a population large enough to provide a substantial customer base? 
SELECT county, population,
COUNT(item) as qty_sold, 
SUM(total) as total_sold
FROM public.sales 
LEFT JOIN counties USING(county)
WHERE description IN('Black Velvet', 'Hawkeye Vodka')
AND counties.population > 150000
GROUP BY county, counties.population
ORDER BY total_sold DESC;
-- Polk, Linn, and Scott counties each has a population size greater than 150,000.

--5. What are the top revenue-producing stores in Iowa, and what is the amount spent on alcohol purchases per capita within various Iowa counties?  
SELECT 
    store, 
    county,
    SUM(total) AS store_revenue
FROM public.sales
GROUP BY store, county
ORDER BY store_revenue DESC
LIMIT 10;
--Top revenue producing stores ranked by ID : 2633, 4829, 3420, 3385, 2512, 3814, 3952, 3354, 2625, 3773
SELECT a.county, 
SUM(a.total) as total_sales, b.population,
(SUM(a.total)/(b.population)) AS per_capita_spend
FROM public.sales a 
INNER JOIN public.counties b
USING(county)
GROUP BY a.county, b.population
ORDER BY per_capita_spend DESC
-- Dickinson spends a large amount on alcohol per person

--6. How many stores are in the top four Iowa counties with the greatest per capita spending?
SELECT county, count(store) as store_count
FROM stores_convenience
WHERE county in ('Dickinson', 'Polk', 'Johnson', 'Cerro Gordo')
GROUP BY county
-- "Dickinson 5" "Johnson 15" "Polk 70" "Cerro Gordo 6" 
--or
SELECT COUNT(store) as total_store_count
FROM public.stores_convenience
WHERE county IN ('Dickinson', 'Polk', 'Johnson', 'Cerro Gordo');
-- 96 stores total

--7. How do the sales of single malt Scotch compare by county?
SELECT sales.item,
       sales.store,
       sales.county_number,
       sales.county,
       sales.total
 FROM sales
WHERE EXISTS (
             SELECT 1
             FROM counties
             WHERE counties.population > 75000
             AND sales.county_number = counties.county_number)
AND sales.category_name = 'SINGLE MALT SCOTCH'
ORDER BY sales.county;
--see each sale
--or 
SELECT 
    sales.county,
    SUM(sales.total) AS total_sales
FROM public.sales
WHERE sales.category_name = 'SINGLE MALT SCOTCH'
  AND sales.county_number IN (
      SELECT county_number 
      FROM public.counties 
      WHERE population > 75000
  )
GROUP BY sales.county
ORDER BY sales.county;
-- Ranked from top to bottom :"Black Hawk 154731""Dubuque 86586""Johnson 491640""Linn 385137""Polk 1325568""Pottawattamie 108190""Scott 334673""Story 213413""Woodbury 83941"

--8. How many retail outlets exist in counties that have a population size greater than 75,000? 
WITH store_list AS (
   SELECT a.store, a.name, a.store_address, b.county
    FROM public.stores a 
 JOIN public.stores_convenience b
 USING (store)
)
SELECT store_list.county, c.population, count(*) AS count_retail_locations,
     c.population/count(*) AS ratio_population_per_store
FROM store_list 
JOIN public.counties c
ON store_list.county = c.county
WHERE c.population > 75000
GROUP BY store_list.county, c.population
ORDER BY ratio_population_per_store;
--"Pottawattamie 22" "Linn 40" "Story 15" "Woodbury 17" "Polk 70" "Black Hawk 18" "Johnson 15" "Dubuque 9" "Scott 11"
--or
SELECT 
    COUNT(DISTINCT s.store) AS total_retail_locations
FROM public.stores s
JOIN public.stores_convenience sc ON s.store = sc.store
JOIN public.counties c ON sc.county = c.county
WHERE c.population > 75000;
-- 217 retail stores total

--9. What items have a high carrying cost (greater than US$150)? 
SELECT 
    item_description, 
    category_name, 
    bottle_price
FROM public.products
WHERE bottle_price > 150
ORDER BY bottle_price DESC;
-- There are 90 products in total that have a carrying cost greater than $150

--10. Which county spends the most on items that have a high carrying cost (greater than US$150) per capita?
SELECT 
    s.county, 
    c.population,
    SUM(s.total) AS total_high_end_spend,
    (SUM(s.total) / c.population) AS high_end_spend_per_capita
FROM public.sales s
JOIN public.products p ON s.item = p.item_no
JOIN public.counties c ON s.county = c.county
WHERE p.bottle_price > 150
GROUP BY s.county, c.population
ORDER BY high_end_spend_per_capita DESC;
-- Lyon 