extends RefCounted
class_name EnemyData

static func get_enemy(enemy_id: String) -> Dictionary:
	return get_all_enemies().get(enemy_id, {})


static func get_all_enemies() -> Dictionary:
	return {
		"slime_green": {
			"display_name": "Slime Verde",
			"rank": "F",
			"level": 1,
			"max_health": 40.0,
			"max_mana": 0.0,
			"strength": 5.0,
			"defense": 2.0,
			"intelligence": 1.0,
			"agility": 3.0,
			"luck": 1.0,
			"xp_reward": 15,
			"gold_min": 5,
			"gold_max": 15,
			"weakness": "fire"
		},
		"young_wolf": {
			"display_name": "Lobo Jovem",
			"rank": "F",
			"level": 2,
			"max_health": 55.0,
			"max_mana": 0.0,
			"strength": 8.0,
			"defense": 3.0,
			"intelligence": 2.0,
			"agility": 10.0,
			"luck": 2.0,
			"xp_reward": 20,
			"gold_min": 10,
			"gold_max": 25,
			"weakness": "fire"
		},
		"blue_slime": {
			"display_name": "Slime Azul",
			"rank": "F",
			"level": 2,
			"max_health": 45.0,
			"max_mana": 15.0,
			"strength": 4.0,
			"defense": 3.0,
			"intelligence": 6.0,
			"agility": 4.0,
			"luck": 2.0,
			"xp_reward": 18,
			"gold_min": 8,
			"gold_max": 18,
			"weakness": "fire"
		}
	}
