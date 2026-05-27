extends Node

func has_save() -> bool:
	return FileAccess.file_exists(Constants.SAVE_PATH)


func save_game(data: Dictionary) -> bool:
	var file: FileAccess = FileAccess.open(Constants.SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


func load_game() -> Dictionary:
	if not has_save():
		return {}
	var file: FileAccess = FileAccess.open(Constants.SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed_variant: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed_variant) != TYPE_DICTIONARY:
		return {}
	var parsed: Dictionary = parsed_variant as Dictionary
	if parsed.has("player_state"):
		return parsed
	if parsed.has("class_id") and parsed.has("player_name"):
		return {
			"version": 2,
			"player_state": {
				"class_id": str(parsed.get("class_id", "warrior")),
				"player_name": str(parsed.get("player_name", "Desperto")),
				"level": 1,
				"xp": 0,
				"gold": 100,
				"rank": "F",
				"floor": 1,
				"max_health": 100.0,
				"current_health": 100.0,
				"max_mana": 50.0,
				"current_mana": 50.0,
				"strength": 10.0,
				"defense": 10.0,
				"intelligence": 10.0,
				"agility": 10.0,
				"luck": 10.0,
				"skill_ids": [],
				"inventory": {"small_potion": 3}
			}
		}
	return {}


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(Constants.SAVE_PATH))
