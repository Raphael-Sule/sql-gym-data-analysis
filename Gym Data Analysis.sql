/*

workout types: 
percentage of each workout across all locations
percentage of each workout in each location + most common to least common workout type in each location
percentage of each workout in each gym type + most common to least common workout type in each gym type

gym types:
percentage of each gym type across all locations
percentage of each gym type in each location
most common to least common workout type in each gym type

*/

ALTER TABLE `checkin_checkout_history` ADD INDEX `checkin_history_idx_workout_type` (`workout_type` (255));
ALTER TABLE `gym_locations_data` ADD INDEX `gym_data_idx_gym_id` (`gym_id` (255));

SELECT * FROM checkin_checkout_history;


-- finding percentage of each workout across all locations
WITH cte AS
(
SELECT workout_type, COUNT(workout_type) workout_freq
FROM checkin_checkout_history
GROUP BY workout_type
ORDER BY NULL
)
SELECT t2.workout_type, (t2.workout_freq / COUNT(t1.workout_type) * 100)
FROM checkin_checkout_history t1, cte t2
GROUP BY t2.workout_type
ORDER BY NULL;


-- finding percentage of each workout in each location + most common to least common workout type in each location
WITH cte AS
(
SELECT t1.workout_type workout, t2.location, COUNT(t1.workout_type) workout_freq
FROM checkin_checkout_history t1
JOIN gym_locations_data t2
	ON t1.gym_id = t2.gym_id
GROUP BY t1.workout_type, t2.location
ORDER BY workout
)
SELECT location, workout, workout_freq /SUM(workout_freq) OVER (PARTITION BY location) * 100 workout_freq
FROM cte
ORDER BY location, workout_freq DESC;


-- finding percentage of each workout in each gym type + most common to least common workout type in each gym type
WITH cte AS
(
SELECT t1.workout_type workout, t2.gym_type gym_type, COUNT(t1.workout_type) workout_freq
FROM checkin_checkout_history t1
JOIN gym_locations_data t2
	ON t1.gym_id = t2.gym_id
GROUP BY workout, gym_type
ORDER BY gym_type
)
SELECT gym_type, workout, workout_freq / SUM(cte.workout_freq) OVER (PARTITION BY gym_type) * 100 workout_freq
FROM cte
ORDER BY gym_type, workout_freq DESC;

-- identical --> can create stored procedure

select *
from gym_locations_data;