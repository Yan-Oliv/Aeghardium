extends Node

const TITLE_SCENE := "res://scenes/ui/TitleScreen.tscn"
const INTRO_SCENE := "res://scenes/ui/IntroScreen.tscn"
const CLASS_SCENE := "res://scenes/ui/ClassSelectionScreen.tscn"
const CHARACTER_CREATION_SCENE := "res://scenes/ui/CharacterCreationScreen.tscn"
const BASE_SCENE := "res://scenes/2d/maps/BaseVillage2D.tscn"
const LEGACY_BASE_SCENE := "res://scenes/ui/BaseScreen.tscn"
const DUNGEON_FLOOR_01_SCENE := "res://scenes/2d/maps/DungeonFloor2D.tscn"
const BATTLE_SCENE := "res://scenes/ui/BattleScreen.tscn"
const PAUSE_SCENE := "res://scenes/ui/PauseMenu.tscn"

var scene_host: Node = null
var overlay_host: Node = null
var current_scene: Node = null
var current_overlay: Node = null
var selected_class_id: String = ""
var player_name: String = ""
var player_state: Dictionary = {}
var current_battle_data: Dictionary = {}
var pending_message: String = ""
var current_battle_source: String = ""
var current_battle_enemy_id: String = ""
var defeated_dungeon_enemies: Array[String] = []

const DEFAULT_APPEARANCE := {
	"body_type": "masculine",
	"skin_tone": "skin_03",
	"eye_color": "amber",
	"hair_style": "short",
	"hair_color": "black",
	"outfit_variant": "class_default",
	"aura_enabled": true
}


func register_hosts(main_host: Node, ui_host: Node) -> void:
	scene_host = main_host
	overlay_host = ui_host
	show_title()


func show_title() -> void:
	current_battle_data = {}
	pending_message = ""
	_set_scene(TITLE_SCENE)


func show_intro() -> void:
	_set_scene(INTRO_SCENE)


func show_class_selection() -> void:
	_set_scene(CLASS_SCENE)


func show_character_creation() -> void:
	_set_scene(CHARACTER_CREATION_SCENE)


func show_base() -> void:
	_set_scene(BASE_SCENE)


func show_battle() -> void:
	_set_scene(BATTLE_SCENE)


func show_dungeon_floor_01() -> void:
	_set_scene(DUNGEON_FLOOR_01_SCENE)


func start_new_game() -> void:
	selected_class_id = ""
	player_name = ""
	player_state = {}
	current_battle_data = {}
	current_battle_source = ""
	current_battle_enemy_id = ""
	defeated_dungeon_enemies.clear()
	show_intro()


func choose_class(class_id: String) -> void:
	selected_class_id = class_id


func confirm_character(chosen_name: String, appearance: Dictionary = {}) -> void:
	player_name = chosen_name.strip_edges()
	if player_name.is_empty():
		player_name = "Desperto"
	player_state = _build_new_player(selected_class_id, player_name, appearance)
	save_current_game()
	show_base()


func load_saved_game() -> void:
	var data: Dictionary = SaveManager.load_game()
	var loaded_player: Dictionary = data.get("player_state", {})
	if loaded_player.is_empty():
		show_title()
		show_message("Nenhum save válido encontrado.")
		return
	player_state = loaded_player
	selected_class_id = str(player_state.get("class_id", "warrior"))
	player_name = str(player_state.get("player_name", "Desperto"))
	_normalize_player_state()
	show_base()


func save_current_game() -> bool:
	if player_state.is_empty():
		return false
	return SaveManager.save_game({
		"version": 3,
		"player_state": player_state
	})


func rest_at_base() -> void:
	if player_state.is_empty():
		return
	player_state["current_health"] = player_state.get("max_health", 1.0)
	player_state["current_mana"] = player_state.get("max_mana", 0.0)
	save_current_game()
	show_message("O grupo descansou e recuperou recursos.")


func start_dungeon_battle(enemy_id: String = "", battle_source: String = "base") -> void:
	if player_state.is_empty():
		return
	current_battle_data = _build_battle_for_floor_v2(int(player_state.get("floor", 1)))
	current_battle_source = battle_source
	current_battle_enemy_id = enemy_id
	show_battle()


func start_dungeon_floor_01() -> void:
	if player_state.is_empty():
		return
	show_dungeon_floor_01()


func resolve_battle(victory: bool, rewards: Dictionary = {}) -> void:
	if player_state.is_empty():
		show_title()
		return
	if bool(rewards.get("fled", false)):
		pending_message = "Você voltou para a base sem penalidade."
		save_current_game()
		current_battle_data = {}
		current_battle_source = ""
		current_battle_enemy_id = ""
		show_base()
		return
	if victory:
		player_state["gold"] = int(player_state.get("gold", 0)) + int(rewards.get("gold", 0))
		player_state["xp"] = int(player_state.get("xp", 0)) + int(rewards.get("xp", 0))
		player_state["floor"] = min(25, int(player_state.get("floor", 1)) + 1)
		player_state["current_mana"] = minf(float(player_state.get("max_mana", 0.0)), float(player_state.get("current_mana", 0.0)) + maxf(4.0, float(player_state.get("max_mana", 0.0)) * 0.2))
		_apply_level_ups()
		if current_battle_source == "dungeon_floor_2d" and not current_battle_enemy_id.is_empty():
			if not defeated_dungeon_enemies.has(current_battle_enemy_id):
				defeated_dungeon_enemies.append(current_battle_enemy_id)
		pending_message = "Vitória! Ouro +%s | XP +%s" % [rewards.get("gold", 0), rewards.get("xp", 0)]
		save_current_game()
	else:
		var loss: int = max(10, int(rewards.get("xp_loss", 15)))
		player_state["xp"] = max(0, int(player_state.get("xp", 0)) - loss)
		player_state["current_health"] = maxf(1.0, float(player_state.get("max_health", 1.0)) * 0.7)
		player_state["current_mana"] = maxf(0.0, float(player_state.get("max_mana", 0.0)) * 0.5)
		pending_message = "Derrota. Você perdeu %s XP e retornou à base." % loss
		save_current_game()
	current_battle_data = {}
	var return_to_dungeon: bool = victory and current_battle_source == "dungeon_floor_2d"
	current_battle_source = ""
	current_battle_enemy_id = ""
	if return_to_dungeon:
		show_dungeon_floor_01()
	else:
		show_base()


func get_player_state() -> Dictionary:
	return player_state


func get_default_appearance() -> Dictionary:
	return DEFAULT_APPEARANCE.duplicate(true)


func normalize_appearance(appearance: Dictionary) -> Dictionary:
	var normalized: Dictionary = get_default_appearance()
	for key in normalized.keys():
		if appearance.has(key):
			normalized[key] = appearance[key]
	normalized["body_type"] = str(normalized.get("body_type", "masculine"))
	normalized["skin_tone"] = str(normalized.get("skin_tone", "skin_03"))
	normalized["eye_color"] = str(normalized.get("eye_color", "amber"))
	normalized["hair_style"] = str(normalized.get("hair_style", "short"))
	normalized["hair_color"] = str(normalized.get("hair_color", "black"))
	normalized["outfit_variant"] = str(normalized.get("outfit_variant", "class_default"))
	normalized["aura_enabled"] = bool(normalized.get("aura_enabled", true))
	return normalized


func get_current_battle_data() -> Dictionary:
	return current_battle_data


func is_dungeon_enemy_defeated(enemy_id: String) -> bool:
	return defeated_dungeon_enemies.has(enemy_id)


func get_biome_for_floor(floor_value: int) -> Dictionary:
	if floor_value <= 5:
		return {
			"name": "Floresta do Início",
			"sky": Color(0.04, 0.07, 0.08, 1.0),
			"mist": Color(0.24, 0.34, 0.28, 0.42),
			"ground": Color(0.09, 0.12, 0.08, 1.0)
		}
	if floor_value <= 10:
		return {
			"name": "Pântano Sombrio",
			"sky": Color(0.06, 0.07, 0.06, 1.0),
			"mist": Color(0.20, 0.32, 0.24, 0.45),
			"ground": Color(0.09, 0.10, 0.07, 1.0)
		}
	if floor_value <= 15:
		return {
			"name": "Minas Abandonadas",
			"sky": Color(0.08, 0.06, 0.05, 1.0),
			"mist": Color(0.28, 0.22, 0.16, 0.40),
			"ground": Color(0.12, 0.09, 0.06, 1.0)
		}
	if floor_value <= 20:
		return {
			"name": "Templo dos Ventos",
			"sky": Color(0.07, 0.09, 0.12, 1.0),
			"mist": Color(0.35, 0.37, 0.33, 0.35),
			"ground": Color(0.10, 0.11, 0.10, 1.0)
		}
	return {
		"name": "Catacumbas de Ossos",
		"sky": Color(0.06, 0.05, 0.06, 1.0),
		"mist": Color(0.32, 0.30, 0.28, 0.32),
		"ground": Color(0.11, 0.10, 0.09, 1.0)
	}


func update_player_resources(current_health: float, current_mana: float) -> void:
	if player_state.is_empty():
		return
	player_state["current_health"] = clampf(current_health, 0.0, float(player_state.get("max_health", current_health)))
	player_state["current_mana"] = clampf(current_mana, 0.0, float(player_state.get("max_mana", current_mana)))


func consume_item(item_id: String) -> bool:
	if player_state.is_empty():
		return false
	var inventory: Dictionary = player_state.get("inventory", {})
	var amount: int = int(inventory.get(item_id, 0))
	if amount <= 0:
		return false
	inventory[item_id] = amount - 1
	player_state["inventory"] = inventory
	return true


func add_item(item_id: String, amount: int) -> void:
	if player_state.is_empty() or amount <= 0:
		return
	var inventory: Dictionary = player_state.get("inventory", {})
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	player_state["inventory"] = inventory


func show_message(message: String) -> void:
	if current_scene != null and is_instance_valid(current_scene) and current_scene.has_method("show_message"):
		current_scene.show_message(message)


func toggle_pause_menu() -> void:
	if overlay_host == null or not is_instance_valid(overlay_host):
		return
	if current_overlay != null and is_instance_valid(current_overlay):
		current_overlay.queue_free()
		current_overlay = null
		get_tree().paused = false
		return
	var packed: PackedScene = load(PAUSE_SCENE) as PackedScene
	if packed == null:
		return
	current_overlay = packed.instantiate()
	overlay_host.add_child(current_overlay)
	get_tree().paused = true


func consume_pending_message() -> String:
	var message: String = pending_message
	pending_message = ""
	return message


func _set_scene(scene_path: String) -> void:
	if current_overlay != null and is_instance_valid(current_overlay):
		current_overlay.queue_free()
	current_overlay = null
	get_tree().paused = false
	if current_scene != null and is_instance_valid(current_scene):
		current_scene.queue_free()
	current_scene = null
	if scene_host == null or not is_instance_valid(scene_host):
		return
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		return
	current_scene = packed.instantiate()
	scene_host.add_child(current_scene)


func _build_new_player(class_id: String, chosen_name: String, appearance: Dictionary = {}) -> Dictionary:
	var class_info: Dictionary = ClassData.get_class_data(class_id)
	var stats: Dictionary = class_info.get("stats", {})
	return {
		"class_id": class_id,
		"player_name": chosen_name,
		"level": 1,
		"xp": 0,
		"gold": 100,
		"rank": "F",
		"floor": 1,
		"max_health": float(stats.get("vida", 100)),
		"current_health": float(stats.get("vida", 100)),
		"max_mana": float(stats.get("mana", 50)),
		"current_mana": float(stats.get("mana", 50)),
		"strength": float(stats.get("forca", 10)),
		"defense": float(stats.get("defesa", 10)),
		"intelligence": float(stats.get("inteligencia", 10)),
		"agility": float(stats.get("agilidade", 10)),
		"luck": float(stats.get("sorte", 10)),
		"skill_ids": class_info.get("skills", []),
		"inventory": {"small_potion": 3},
		"equipment_visuals": _default_equipment_visuals_for_class(class_id),
		"appearance": normalize_appearance(appearance)
	}


func _normalize_player_state() -> void:
	if player_state.is_empty():
		return
	var normalized_class_id: String = str(player_state.get("class_id", "warrior"))
	var class_info: Dictionary = ClassData.get_class_data(normalized_class_id)
	var stats: Dictionary = class_info.get("stats", {})
	player_state["class_id"] = str(player_state.get("class_id", "warrior"))
	player_state["player_name"] = str(player_state.get("player_name", "Desperto"))
	player_state["level"] = int(player_state.get("level", 1))
	player_state["xp"] = int(player_state.get("xp", 0))
	player_state["gold"] = int(player_state.get("gold", 100))
	player_state["rank"] = str(player_state.get("rank", "F"))
	player_state["floor"] = int(player_state.get("floor", 1))
	player_state["max_health"] = float(player_state.get("max_health", stats.get("vida", 100)))
	player_state["current_health"] = float(player_state.get("current_health", player_state.get("max_health", 100.0)))
	player_state["max_mana"] = float(player_state.get("max_mana", stats.get("mana", 50)))
	player_state["current_mana"] = float(player_state.get("current_mana", player_state.get("max_mana", 50.0)))
	player_state["strength"] = float(player_state.get("strength", stats.get("forca", 10)))
	player_state["defense"] = float(player_state.get("defense", stats.get("defesa", 10)))
	player_state["intelligence"] = float(player_state.get("intelligence", stats.get("inteligencia", 10)))
	player_state["agility"] = float(player_state.get("agility", stats.get("agilidade", 10)))
	player_state["luck"] = float(player_state.get("luck", stats.get("sorte", 10)))
	player_state["skill_ids"] = player_state.get("skill_ids", class_info.get("skills", []))
	player_state["inventory"] = player_state.get("inventory", {"small_potion": 3})
	player_state["equipment_visuals"] = player_state.get("equipment_visuals", _default_equipment_visuals_for_class(normalized_class_id))
	player_state["appearance"] = normalize_appearance(player_state.get("appearance", {}))


func _default_equipment_visuals_for_class(class_id: String) -> Dictionary:
	match class_id:
		"warrior":
			return {"main_hand": "long_sword", "chest": "iron_armor"}
		"paladin":
			return {"main_hand": "long_sword", "offhand": "light_shield", "chest": "iron_armor"}
		"assassin":
			return {"main_hand": "twin_daggers", "cape": "shadow_cape"}
		"archer":
			return {"main_hand": "wooden_bow", "cape": "shadow_cape"}
		"berserker":
			return {"main_hand": "hand_axe"}
		"mage", "necromancer", "druid", "cleric":
			return {"main_hand": "simple_staff", "chest": "basic_robe"}
	return {"main_hand": "short_sword"}


func _build_battle_for_floor(floor_value: int) -> Dictionary:
	var enemy_id := "slime_green"
	match floor_value:
		1:
			enemy_id = "slime_green"
		2:
			enemy_id = "young_wolf"
		_:
			enemy_id = "blue_slime" if floor_value % 2 == 0 else "young_wolf"
	var enemy_data: Dictionary = EnemyData.get_enemy(enemy_id).duplicate(true)
	enemy_data["enemy_id"] = enemy_id
	enemy_data["current_health"] = float(enemy_data.get("max_health", 1.0))
	enemy_data["current_mana"] = float(enemy_data.get("max_mana", 0.0))
	enemy_data["floor"] = floor_value
	return enemy_data


func get_visual_biome_for_floor(floor_value: int) -> Dictionary:
	var biome := get_biome_for_floor(floor_value).duplicate(true)
	if floor_value <= 5:
		biome.merge({
			"name": "Floresta do Inicio",
			"accent": Color8(90, 180, 122),
			"glow": Color8(114, 214, 166),
			"stone": Color8(94, 104, 98),
			"grass_base": Color8(54, 92, 56),
			"grass_accent": Color8(74, 122, 72),
			"grass_detail": Color8(40, 76, 48),
			"stone_base": Color8(92, 96, 94),
			"stone_accent": Color8(120, 126, 122),
			"path_base": Color8(94, 76, 50),
			"path_accent": Color8(122, 96, 66),
			"water_base": Color8(42, 118, 162),
			"water_accent": Color8(82, 176, 212),
			"props": ["trees", "bushes", "ruins", "crystals"]
		}, true)
	elif floor_value <= 10:
		biome.merge({
			"name": "Pantano Sombrio",
			"accent": Color8(110, 166, 96),
			"glow": Color8(154, 214, 138),
			"stone": Color8(88, 92, 82),
			"grass_base": Color8(58, 72, 48),
			"grass_accent": Color8(84, 108, 62),
			"grass_detail": Color8(46, 58, 36),
			"stone_base": Color8(76, 80, 74),
			"stone_accent": Color8(98, 102, 92),
			"path_base": Color8(82, 68, 46),
			"path_accent": Color8(96, 84, 56),
			"mud_base": Color8(66, 60, 42),
			"mud_accent": Color8(94, 80, 56),
			"water_base": Color8(44, 82, 80),
			"water_accent": Color8(82, 132, 114),
			"props": ["reeds", "swamp", "bones", "fungi"]
		}, true)
	elif floor_value <= 15:
		biome.merge({
			"name": "Minas Abandonadas",
			"accent": Color8(214, 112, 72),
			"glow": Color8(242, 172, 92),
			"stone": Color8(104, 88, 74),
			"grass_base": Color8(62, 58, 48),
			"grass_accent": Color8(88, 74, 56),
			"grass_detail": Color8(48, 44, 36),
			"stone_base": Color8(92, 80, 70),
			"stone_accent": Color8(122, 104, 88),
			"path_base": Color8(98, 76, 54),
			"path_accent": Color8(130, 98, 72),
			"water_base": Color8(72, 98, 128),
			"water_accent": Color8(106, 132, 166),
			"props": ["crystals", "chains", "ore", "lava"]
		}, true)
	elif floor_value <= 20:
		biome.merge({
			"name": "Templo dos Ventos",
			"accent": Color8(164, 204, 220),
			"glow": Color8(212, 240, 246),
			"stone": Color8(102, 108, 112),
			"grass_base": Color8(72, 80, 84),
			"grass_accent": Color8(98, 112, 116),
			"grass_detail": Color8(58, 64, 70),
			"stone_base": Color8(104, 108, 112),
			"stone_accent": Color8(134, 142, 146),
			"path_base": Color8(96, 98, 104),
			"path_accent": Color8(138, 144, 148),
			"water_base": Color8(82, 124, 166),
			"water_accent": Color8(118, 166, 212),
			"props": ["pillars", "feathers", "wind_crystals", "altars"]
		}, true)
	else:
		biome.merge({
			"name": "Catacumbas de Ossos",
			"accent": Color8(176, 110, 214),
			"glow": Color8(218, 186, 255),
			"stone": Color8(92, 84, 88),
			"grass_base": Color8(66, 60, 64),
			"grass_accent": Color8(88, 80, 86),
			"grass_detail": Color8(48, 44, 50),
			"stone_base": Color8(88, 80, 84),
			"stone_accent": Color8(114, 106, 114),
			"path_base": Color8(76, 66, 74),
			"path_accent": Color8(106, 90, 102),
			"water_base": Color8(76, 82, 126),
			"water_accent": Color8(118, 124, 174),
			"props": ["bones", "altars", "sarcophagi", "cursed_crystals"]
		}, true)
	return biome


func _build_battle_for_floor_v2(floor_value: int) -> Dictionary:
	var enemy_id := "slime_green"
	match floor_value:
		1:
			enemy_id = "slime_green"
		2:
			enemy_id = "young_wolf"
		3:
			enemy_id = "carnivorous_plant"
		4:
			enemy_id = "goblin_thief"
		5:
			enemy_id = "skeletal_guard"
		6:
			enemy_id = "poison_toad"
		7:
			enemy_id = "wailing_spirit"
		8:
			enemy_id = "giant_bee"
		9:
			enemy_id = "vampire_bat"
		10:
			enemy_id = "skeletal_guard"
		15:
			enemy_id = "iron_golem"
		20:
			enemy_id = "wind_king"
		25:
			enemy_id = "fallen_necromancer"
		_:
			if floor_value <= 10:
				enemy_id = "blue_slime" if floor_value % 2 == 0 else "young_wolf"
			elif floor_value <= 15:
				enemy_id = "iron_golem" if floor_value % 3 == 0 else "wailing_spirit"
			elif floor_value <= 20:
				enemy_id = "giant_bee" if floor_value % 2 == 0 else "iron_golem"
			else:
				enemy_id = "fallen_necromancer" if floor_value % 4 == 0 else "skeletal_guard"
	var enemy_data: Dictionary = EnemyData.get_enemy(enemy_id).duplicate(true)
	enemy_data["enemy_id"] = enemy_id
	enemy_data["current_health"] = float(enemy_data.get("max_health", 1.0))
	enemy_data["current_mana"] = float(enemy_data.get("max_mana", 0.0))
	enemy_data["floor"] = floor_value
	return enemy_data


func _apply_level_ups() -> void:
	while int(player_state.get("xp", 0)) >= _xp_to_next_level(int(player_state.get("level", 1))):
		player_state["xp"] = int(player_state.get("xp", 0)) - _xp_to_next_level(int(player_state.get("level", 1)))
		player_state["level"] = int(player_state.get("level", 1)) + 1
		_apply_level_growth()
		_update_rank()


func _xp_to_next_level(level_value: int) -> int:
	return int(ceil(100.0 * pow(max(1, level_value), 1.4)))


func _apply_level_growth() -> void:
	var class_id: String = str(player_state.get("class_id", "warrior"))
	player_state["max_health"] = float(player_state.get("max_health", 100.0)) + 10.0
	player_state["max_mana"] = float(player_state.get("max_mana", 50.0)) + 6.0
	player_state["strength"] = float(player_state.get("strength", 10.0)) + 1.0
	player_state["defense"] = float(player_state.get("defense", 10.0)) + 1.0
	player_state["intelligence"] = float(player_state.get("intelligence", 10.0)) + 1.0
	player_state["agility"] = float(player_state.get("agility", 10.0)) + 1.0
	player_state["luck"] = float(player_state.get("luck", 10.0)) + 0.5
	match class_id:
		"necromancer", "mage", "cleric", "druid":
			player_state["intelligence"] += 1.5
			player_state["max_mana"] += 4.0
		"assassin", "archer":
			player_state["agility"] += 1.5
			player_state["luck"] += 0.5
		"warrior", "paladin":
			player_state["strength"] += 1.0
			player_state["defense"] += 1.0
		"berserker":
			player_state["strength"] += 2.0
			player_state["max_health"] += 6.0
	player_state["current_health"] = player_state.get("max_health", 1.0)
	player_state["current_mana"] = player_state.get("max_mana", 0.0)


func _update_rank() -> void:
	var level_value: int = int(player_state.get("level", 1))
	var floor_value: int = int(player_state.get("floor", 1))
	var rank_value := "F"
	if level_value >= 45 and floor_value >= 25:
		rank_value = "A"
	elif level_value >= 30 and floor_value >= 20:
		rank_value = "B"
	elif level_value >= 20 and floor_value >= 15:
		rank_value = "C"
	elif level_value >= 10 and floor_value >= 10:
		rank_value = "D"
	elif level_value >= 5 and floor_value >= 5:
		rank_value = "E"
	player_state["rank"] = rank_value
