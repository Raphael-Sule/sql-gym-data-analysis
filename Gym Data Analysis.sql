/*
workout data: 
percentage of each workout across all locations (query done)
descending workout % in each location (query done)
descending gym type % in each location (query done)


gym data:
percentage of each gym type across all locations
percentage of each gym type in each location
most common to least common workout type in each gym type


subscription data:
spread of subscription plans in each gym (basic query done)
spread of subscription plans in each location (query done)

gym data:
spread of sign-up dates by month (query done)

PREMIUM, BUDGET, STANDARD:
	- number of times people attend each type of gym
    

user data:
oldest, youngest and average age in each gym
oldest, youngest and average age in each subscription plan
distribution of ages in each gym
spread of genders in each gym
number of people who live in the same location of their gym vs number who don't
*/

SELECT *
FROM   checkin_checkout_history
ORDER  BY user_id,
          checkin_time;

SELECT *
FROM   gym_locations_data;

SELECT *
FROM   subscription_plans;

SELECT *
FROM   users_data
ORDER  BY user_id; 

-- 		workout data 		--

-- descending % of each workout across all locations
WITH workouts_across_locations
     AS (SELECT 
			workout_type,
			Count(workout_type) workout_freq
        FROM 
			checkin_checkout_history
        GROUP BY 
			workout_type
        ORDER BY 
			NULL)
SELECT 
	wal.workout_type,
	CONCAT(ROUND((wal.workout_freq / Count(cch.workout_type) * 100 ),2), '%') AS percentage_of_total
FROM   
	checkin_checkout_history AS cch,
	workouts_across_locations AS wal
GROUP BY 
	wal.workout_type
ORDER BY
	NULL;

-- descending workout % in each location 
WITH workouts_in_locations
     AS (SELECT 
			cch.workout_type AS workout,
            gld.location AS location,
			Count(cch.workout_type) AS workout_freq
         FROM   
			checkin_checkout_history AS cch
			JOIN gym_locations_data AS gld
                  ON cch.gym_id = gld.gym_id
         GROUP BY 
			cch.workout_type,
			gld.location
         ORDER BY 
			workout
		)
SELECT 
	location,
	workout,
	workout_freq / Sum(workout_freq) OVER (
		PARTITION BY location) * 100 AS workout_freq
FROM
	workouts_in_locations
ORDER BY 
	location,
	workout_freq DESC;

-- descending workout % in each gym type
WITH workouts_by_gym_type
     AS (SELECT 
			cch.workout_type AS workout,
			gld.gym_type AS gym_type,
			Count(cch.workout_type) workout_freq
         FROM   
			checkin_checkout_history AS cch
			JOIN gym_locations_data AS gld
				ON cch.gym_id = gld.gym_id
         GROUP BY 
			workout,
			gym_type
         ORDER BY 
			gym_type)
SELECT 
	gym_type,
	workout,
	CONCAT(ROUND((workout_freq / Sum(wbgt.workout_freq) OVER (
		PARTITION BY gym_type) * 100), 2), '%') AS workout_frequency
FROM
	workouts_by_gym_type AS wbgt
ORDER BY 
	gym_type,
	workout_freq DESC;

-- create a temp table and query it?

-- 		subscription  data 		--
  
  -- spread of subscription plans in each location
  
WITH user_gym_counts AS (
     SELECT gld.location,
     ud.subscription_plan,
     COUNT(DISTINCT ud.user_id) AS user_count,
     COUNT(DISTINCT ud.user_id) * 100.0 / SUM(COUNT(DISTINCT ud.user_id)) OVER (
		PARTITION BY gld.location) AS percentage
    FROM
      users_data AS ud
      JOIN checkin_checkout_history AS cch 
		   ON ud.user_id = cch.user_id
      JOIN gym_locations_data AS gld 
		   ON cch.gym_id = gld.gym_id
    GROUP BY
      gld.location,
      ud.subscription_plan
  )
SELECT
  location,
  subscription_plan,
  user_count,
  CONCAT(ROUND(percentage, 2), '%') AS percentage
FROM
  user_gym_counts
ORDER BY
  location,
  subscription_plan;
  
-- spread of subscription plans in each gym
SELECT
	gld.gym_type,
	COUNT(cch.user_id) AS attendance_count
FROM
	checkin_checkout_history cch
		JOIN gym_locations_data gld
			 ON cch.gym_id = gld.gym_id
GROUP BY
	gld.gym_type;
    

-- 		user data 		--

-- spread of sign-up dates by month
WITH
  monthly_signups AS (
    SELECT
      MONTH(sign_up_date) AS month_num,
      DATE_FORMAT(sign_up_date, '%M') AS month_name,
      COUNT(*) AS signup_count,
      ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) AS percentage
    FROM
      users_data
    GROUP BY
      MONTH(sign_up_date),
      DATE_FORMAT(sign_up_date, '%M')
  )
SELECT
  month_name,
  signup_count,
  CONCAT(percentage, '%') AS percentage_of_total
FROM
  monthly_signups
ORDER BY
  month_num;