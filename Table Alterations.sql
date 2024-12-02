ALTER TABLE `checkin_checkout_history` ADD INDEX `checkin_history_idx_workout_type` (`workout_type` (255));
ALTER TABLE `gym_locations_data` ADD INDEX `gym_data_idx_gym_id` (`gym_id` (255));

-- modifying user_id from VARCHAR to INT
UPDATE `checkin_checkout_history`
SET user_id = REPLACE (user_id,'user_','');
ALTER TABLE `checkin_checkout_history`
MODIFY user_id INTEGER;

UPDATE `users_data`
SET user_id = REPLACE (user_id,'user_','');
ALTER TABLE `users_data`
MODIFY user_id INTEGER;

-- modifying gym_id from VARCHAR to INT
UPDATE `gym_locations_data`
SET gym_id = REPLACE (gym_id,'gym_','');
ALTER TABLE `gym_locations_data`
MODIFY gym_id INTEGER;

UPDATE `checkin_checkout_history`
SET gym_id = REPLACE (gym_id,'gym_','');
ALTER TABLE `checkin_checkout_history`
MODIFY gym_id INTEGER;