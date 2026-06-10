-- Data Validation
SELECT COUNT(*) FROM airline_fares;

-- Missing values
SELECT *
FROM airline_fares
WHERE price IS NULL;


-- Create Revenue Management Dimensions

-- Create Route
ALTER TABLE airline_fares
ADD route VARCHAR(100);

-- Update
UPDATE airline_fares
SET route =
CONCAT(
source_city,
' - ',
destination_city
);


-- Booking Window Segmentation

ALTER TABLE airline_fares
ADD COLUMN booking_window VARCHAR(30);

UPDATE airline_fares
SET booking_window =
CASE
    WHEN days_left <= 7 THEN 'Last Minute'
    WHEN days_left <= 15 THEN 'Short Term'
    WHEN days_left <= 30 THEN 'Medium Term'
    WHEN days_left <= 60 THEN 'Early Booking'
    ELSE 'Advance Booking'
END;



-- BOOKING WINDOW ANALYSIS

SELECT
booking_window,
ROUND(AVG(price),2) avg_fare,
COUNT(*) flights
FROM airline_fares
GROUP BY booking_window
ORDER BY avg_fare DESC;



-- FARE ESCALATION ANALYSIS

SELECT
days_left,
ROUND(AVG(price),2) avg_fare
FROM airline_fares
GROUP BY days_left
ORDER BY days_left;

-- COMPETITOR PRICING ANALYSIS
SELECT
airline,
ROUND(AVG(price),2) avg_fare,
MIN(price) min_fare,
MAX(price) max_fare,
ROUND(STDDEV(price),2) fare_volatility
FROM airline_fares
GROUP BY airline
ORDER BY avg_fare DESC;


-- ROUTE ANALYSIS
SELECT
route,
ROUND(AVG(price),2) avg_fare,
COUNT(*) total_records
FROM airline_fares
GROUP BY route
ORDER BY avg_fare DESC;


-- TOP 10 PREMIUM ROUTES
SELECT
route,
ROUND(AVG(price),2) avg_fare
FROM airline_fares
GROUP BY route
ORDER BY avg_fare DESC
LIMIT 10;

-- BOTTOM 10 ROUTES
SELECT
route,
ROUND(AVG(price),2) avg_fare
FROM airline_fares
GROUP BY route
ORDER BY avg_fare ASC
LIMIT 10;

-- BUSINESS VS ECONOMY ANALYSIS
SELECT
travel_class,
ROUND(AVG(price),2) avg_fare,
COUNT(*) records
FROM airline_fares
GROUP BY travel_class;

-- MOST EXPENSIVE AIRLINE ON EACH ROUTE
WITH route_airline AS
(
SELECT
route,
airline,
AVG(price) avg_price
FROM airline_fares
GROUP BY route,airline
)

SELECT *
FROM route_airline
ORDER BY route,avg_price DESC;

-- EXPORT TABLE FOR PYTHON
CREATE VIEW rm_analysis_dataset AS
SELECT
airline,
route,
travel_class,
stops,
departure_time,
arrival_time,
days_left,
booking_window,
duration,
price
FROM airline_fares;


