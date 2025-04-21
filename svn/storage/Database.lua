local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")

local class = require("class")

local sql = [[
CREATE TABLE IF NOT EXISTS `users` (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`name` TEXT UNIQUE,
	`email` TEXT UNIQUE,
	`password` TEXT,
	`creation_date` INTEGER,
	`level` INTEGER,
	`experience` INTEGER,
	`coins` REAL
);

CREATE TABLE IF NOT EXISTS `sessions` (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`user_id` INTEGER,
	`active` INTEGER,
	`ip` TEXT,
	`created_at` INTEGER,
	`updated_at` INTEGER
);

CREATE TABLE IF NOT EXISTS `loadouts` (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`owner_id` INTEGER NOT NULL,
	`slot_first_waifu` INTEGER,
	`slot_second_waifu` INTEGER,
	`slot_third_waifu` INTEGER,
	`slot_head` INTEGER,
	`slot_hands` INTEGER,
	`slot_charm` INTEGER,
	FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`)
);

CREATE TABLE IF NOT EXISTS `items` (
	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
	`template_id` INTEGER NOT NULL,
	`owner_id` INTEGER,
	`amount` INTEGER NOT NULL,
	FOREIGN KEY (`owner_id`) REFERENCES `users`(`id`)
);

CREATE TABLE IF NOT EXISTS `wearable_params` (
	`id` INTEGER PRIMARY KEY,
	`upgrade_count` INTEGER,
	`marvelous_points` INTEGER,
	`combo_multiplier` INTEGER,
	`fever_fill_rate` INTEGER,
	`fever_multiplier` INTEGER,
	`fever_time` INTEGER,
	`red_points` INTEGER,
	`blue_points` INTEGER,
	`white_points` INTEGER,
	FOREIGN KEY (`id`) REFERENCES `items`(`id`)
);

CREATE TABLE IF NOT EXISTS `chart_power_elements` (
	`chartdiff_hash` TEXT,
	`element` INTEGER
);

CREATE TEMPORARY VIEW IF NOT EXISTS `inventory_entries` AS
SELECT 
	items.id AS id,
	items.template_id AS template_id,
	items.amount AS amount,
	items.owner_id AS owner_id,
	wearable_params.upgrade_count AS upgrade_count,
	wearable_params.marvelous_points AS marvelous_points,
	wearable_params.combo_multiplier AS combo_multiplier,
	wearable_params.fever_fill_rate AS fever_fill_rate,
	wearable_params.fever_multiplier AS fever_multiplier,
	wearable_params.fever_time AS fever_time,
	wearable_params.red_points AS red_points,
	wearable_params.blue_points AS blue_points,
	wearable_params.white_points AS white_points
FROM 
	items
LEFT JOIN 
	wearable_params ON items.id = wearable_params.id;

CREATE INDEX IF NOT EXISTS item_owner_idx ON `items` (`owner_id`);
CREATE INDEX IF NOT EXISTS loadout_owner_idx ON `loadouts` (`owner_id`);
]]

---@class svn.Database
---@operator call: svn.Database
local Database = class()

function Database:new()
	local db = LjsqliteDatabase()
	self.db = db
end

function Database:load()
	self.db:open("server.db")
	self.db:exec(sql)
	self.db:exec("PRAGMA foreign_keys = ON;")
	self.orm = TableOrm(self.db)
	self.models = Models(autoload("svn.storage.models", true), self.orm)
end

return Database
