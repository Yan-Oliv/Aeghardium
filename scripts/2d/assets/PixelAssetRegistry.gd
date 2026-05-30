extends Node
class_name PixelAssetRegistry

const PLAYER_CLASS_SPRITES := {
	"mage": "res://assets/pixel/characters/player/mage_sheet.png",
	"necromancer": "res://assets/pixel/characters/player/necromancer_sheet.png",
	"warrior": "res://assets/pixel/characters/player/warrior_sheet.png",
	"assassin": "res://assets/pixel/characters/player/assassin_sheet.png",
	"paladin": "res://assets/pixel/characters/player/paladin_sheet.png"
}

const PLAYER_CLASS_FRAMES := {
	"mage": {
		"idle": Rect2i(170, 40, 92, 116),
		"walk": Rect2i(170, 168, 92, 116),
		"portrait": Rect2i(1042, 430, 182, 382)
	},
	"necromancer": {
		"idle": Rect2i(168, 42, 86, 112),
		"walk": Rect2i(167, 168, 90, 116),
		"portrait": Rect2i(1048, 434, 178, 382)
	},
	"warrior": {
		"idle": Rect2i(168, 44, 94, 114),
		"walk": Rect2i(166, 168, 98, 118),
		"portrait": Rect2i(1042, 430, 192, 390)
	},
	"assassin": {
		"idle": Rect2i(172, 48, 84, 108),
		"walk": Rect2i(174, 184, 84, 112),
		"portrait": Rect2i(1182, 320, 170, 402)
	},
	"paladin": {
		"idle": Rect2i(172, 38, 96, 120),
		"walk": Rect2i(171, 170, 96, 116),
		"portrait": Rect2i(1182, 308, 176, 402)
	}
}

const ENEMY_SPRITES := {
	"slime_green": "res://assets/pixel/characters/enemies/slime_pack.webp",
	"blue_slime": "res://assets/pixel/characters/enemies/slime_pack.webp",
	"goblin_thief": "res://assets/pixel/characters/enemies/goblin_pack.webp",
	"skeletal_guard": "res://assets/pixel/characters/enemies/skeleton_pack.webp",
	"fallen_necromancer": "res://assets/pixel/characters/enemies/lich_pack.webp",
	"iron_golem": "res://assets/pixel/characters/enemies/golem_pack.webp"
}

const ENEMY_FRAMES := {
	"slime_green": {
		"map": Rect2i(74, 108, 126, 126),
		"portrait": Rect2i(62, 100, 150, 146)
	},
	"blue_slime": {
		"map": Rect2i(74, 108, 126, 126),
		"portrait": Rect2i(62, 100, 150, 146)
	},
	"goblin_thief": {
		"map": Rect2i(252, 102, 170, 176),
		"portrait": Rect2i(238, 90, 194, 190)
	},
	"skeletal_guard": {
		"map": Rect2i(418, 64, 54, 58),
		"portrait": Rect2i(222, 104, 150, 176),
		"portrait_path": "res://assets/pixel/characters/enemies/lich_pack.webp"
	},
	"fallen_necromancer": {
		"map": Rect2i(218, 98, 174, 190),
		"portrait": Rect2i(198, 88, 214, 214)
	},
	"iron_golem": {
		"map": Rect2i(232, 116, 190, 196),
		"portrait": Rect2i(220, 98, 216, 218)
	}
}

const BATTLE_PORTRAITS := {
	"mage": "res://assets/pixel/portraits/player/mage_sheet.png",
	"necromancer": "res://assets/pixel/portraits/player/necromancer_sheet.png",
	"warrior": "res://assets/pixel/portraits/player/warrior_sheet.png",
	"assassin": "res://assets/pixel/portraits/player/assassin_sheet.png",
	"paladin": "res://assets/pixel/portraits/player/paladin_sheet.png",
	"slime_green": "res://assets/pixel/portraits/enemies/slime_pack.webp",
	"blue_slime": "res://assets/pixel/portraits/enemies/slime_pack.webp",
	"goblin_thief": "res://assets/pixel/portraits/enemies/goblin_pack.webp",
	"skeletal_guard": "res://assets/pixel/portraits/enemies/skeleton_pack.webp",
	"fallen_necromancer": "res://assets/pixel/portraits/enemies/lich_pack.webp",
	"iron_golem": "res://assets/pixel/portraits/enemies/golem_pack.webp"
}

const BATTLE_BACKGROUNDS := {
	"forest": "res://assets/pixel/tilesets/battle_forest.webp",
	"swamp": "res://assets/pixel/tilesets/battle_swamp.webp",
	"mine": "res://assets/pixel/tilesets/battle_mine.webp",
	"wind_temple": "res://assets/pixel/tilesets/battle_wind_temple.webp",
	"catacombs": "res://assets/pixel/tilesets/battle_catacombs.webp"
}

const BATTLE_BACKGROUND_RECTS := {
	"forest": Rect2i(0, 72, 720, 404),
	"swamp": Rect2i(0, 72, 720, 404),
	"mine": Rect2i(0, 72, 720, 404),
	"wind_temple": Rect2i(0, 72, 720, 404),
	"catacombs": Rect2i(0, 72, 720, 404)
}

const ITEM_ICON_SOURCES := {
	"small_potion": "res://assets/pixel/ui/treasure_icons.webp",
	"short_sword": "res://assets/pixel/ui/treasure_icons.webp",
	"light_shield": "res://assets/pixel/ui/treasure_icons.webp",
	"chest": "res://assets/pixel/ui/treasure_icons.webp",
	"key": "res://assets/pixel/ui/treasure_icons.webp"
}

const ITEM_ICON_RECTS := {
	"small_potion": Rect2i(146, 88, 68, 76),
	"short_sword": Rect2i(24, 264, 82, 74),
	"light_shield": Rect2i(256, 88, 90, 88),
	"chest": Rect2i(220, 76, 104, 98),
	"key": Rect2i(278, 156, 98, 70)
}

static var _texture_cache: Dictionary = {}


static func build_player_sprite_frames(class_id: String) -> SpriteFrames:
	var idle_texture := get_player_map_texture(class_id, "idle")
	var walk_texture := get_player_map_texture(class_id, "walk")
	if idle_texture == null:
		return null
	if walk_texture == null:
		walk_texture = idle_texture
	var frames := SpriteFrames.new()
	for state in ["idle", "walk"]:
		for direction in ["down", "up", "left", "right"]:
			var animation_name := "%s_%s" % [state, direction]
			frames.add_animation(animation_name)
			frames.set_animation_loop(animation_name, true)
			frames.set_animation_speed(animation_name, 4.0 if state == "idle" else 8.0)
			var frame_texture: Texture2D = idle_texture if state == "idle" else walk_texture
			var frame_count := 2 if state == "idle" else 4
			for _i in range(frame_count):
				frames.add_frame(animation_name, frame_texture)
	return frames


static func get_player_map_texture(class_id: String, state: String = "idle") -> Texture2D:
	var normalized_class_id := _normalize_class_id(class_id)
	var sprite_path: String = str(PLAYER_CLASS_SPRITES.get(normalized_class_id, ""))
	var frame_data: Dictionary = PLAYER_CLASS_FRAMES.get(normalized_class_id, {})
	if sprite_path.is_empty() or frame_data.is_empty():
		return null
	var rect: Rect2i = frame_data.get(state, Rect2i())
	if rect.size == Vector2i.ZERO:
		return null
	return _load_cropped_texture(sprite_path, rect, true, 0.11)


static func get_player_portrait_texture(class_id: String) -> Texture2D:
	var normalized_class_id := _normalize_class_id(class_id)
	var portrait_path: String = str(BATTLE_PORTRAITS.get(normalized_class_id, ""))
	var frame_data: Dictionary = PLAYER_CLASS_FRAMES.get(normalized_class_id, {})
	if portrait_path.is_empty() or frame_data.is_empty():
		return null
	var rect: Rect2i = frame_data.get("portrait", Rect2i())
	if rect.size == Vector2i.ZERO:
		return null
	return _load_cropped_texture(portrait_path, rect, true, 0.12)


static func get_enemy_map_texture(enemy_id: String) -> Texture2D:
	var normalized_enemy_id := _normalize_enemy_id(enemy_id)
	var sprite_path: String = str(ENEMY_SPRITES.get(normalized_enemy_id, ""))
	var frame_data: Dictionary = ENEMY_FRAMES.get(normalized_enemy_id, {})
	if sprite_path.is_empty() or frame_data.is_empty():
		return null
	var rect: Rect2i = frame_data.get("map", Rect2i())
	if rect.size == Vector2i.ZERO:
		return null
	return _load_cropped_texture(sprite_path, rect, true, 0.16)


static func get_enemy_portrait_texture(enemy_id: String) -> Texture2D:
	var normalized_enemy_id := _normalize_enemy_id(enemy_id)
	var frame_data: Dictionary = ENEMY_FRAMES.get(normalized_enemy_id, {})
	var portrait_path: String = str(frame_data.get("portrait_path", BATTLE_PORTRAITS.get(normalized_enemy_id, "")))
	if portrait_path.is_empty() or frame_data.is_empty():
		return null
	var rect: Rect2i = frame_data.get("portrait", Rect2i())
	if rect.size == Vector2i.ZERO:
		return null
	return _load_cropped_texture(portrait_path, rect, true, 0.15)


static func get_battle_background_texture(biome_key: String) -> Texture2D:
	var normalized_biome := biome_key.strip_edges().to_lower()
	var texture_path: String = str(BATTLE_BACKGROUNDS.get(normalized_biome, ""))
	if texture_path.is_empty():
		return null
	var rect: Rect2i = BATTLE_BACKGROUND_RECTS.get(normalized_biome, Rect2i())
	if rect.size == Vector2i.ZERO:
		return _load_full_texture(texture_path)
	return _load_cropped_texture(texture_path, rect, false, 0.0)


static func get_item_icon_texture(item_id: String) -> Texture2D:
	var normalized_item_id := item_id.strip_edges().to_lower()
	var texture_path: String = str(ITEM_ICON_SOURCES.get(normalized_item_id, ""))
	var rect: Rect2i = ITEM_ICON_RECTS.get(normalized_item_id, Rect2i())
	if texture_path.is_empty() or rect.size == Vector2i.ZERO:
		return null
	return _load_cropped_texture(texture_path, rect, true, 0.10)


static func get_biome_key_for_floor(floor_value: int) -> String:
	if floor_value <= 5:
		return "forest"
	if floor_value <= 10:
		return "swamp"
	if floor_value <= 15:
		return "mine"
	if floor_value <= 20:
		return "wind_temple"
	return "catacombs"


static func get_world_sprite_scale(texture: Texture2D, target_width: float = 72.0) -> Vector2:
	if texture == null or texture.get_width() <= 0:
		return Vector2.ONE
	var scale_value := target_width / float(texture.get_width())
	return Vector2(scale_value, scale_value)


static func _load_full_texture(texture_path: String) -> Texture2D:
	if not _resource_exists(texture_path):
		return null
	var cache_key := "full|%s" % texture_path
	if _texture_cache.has(cache_key):
		return _texture_cache[cache_key]
	var texture := load(texture_path) as Texture2D
	if texture != null:
		_texture_cache[cache_key] = texture
	return texture


static func _load_cropped_texture(texture_path: String, rect: Rect2i, remove_background: bool, tolerance: float) -> Texture2D:
	if not _resource_exists(texture_path):
		return null
	var cache_key := "crop|%s|%s|%s|%.3f" % [texture_path, rect, remove_background, tolerance]
	if _texture_cache.has(cache_key):
		return _texture_cache[cache_key]
	var image := Image.load_from_file(texture_path)
	if image == null or image.is_empty():
		return null
	var start_x := clampi(rect.position.x, 0, image.get_width() - 1)
	var start_y := clampi(rect.position.y, 0, image.get_height() - 1)
	var safe_rect := Rect2i(
		start_x,
		start_y,
		clampi(rect.size.x, 1, image.get_width() - start_x),
		clampi(rect.size.y, 1, image.get_height() - start_y)
	)
	var cropped := image.get_region(safe_rect)
	if remove_background:
		_remove_edge_background(cropped, tolerance)
	var texture := ImageTexture.create_from_image(cropped)
	_texture_cache[cache_key] = texture
	return texture


static func _resource_exists(texture_path: String) -> bool:
	return ResourceLoader.exists(texture_path) or FileAccess.file_exists(texture_path)


static func _normalize_class_id(class_id: String) -> String:
	var normalized := class_id.strip_edges().to_lower()
	match normalized:
		"mago":
			return "mage"
		"necromante":
			return "necromancer"
		"guerreiro":
			return "warrior"
		"assassino":
			return "assassin"
		"paladino":
			return "paladin"
	return normalized


static func _normalize_enemy_id(enemy_id: String) -> String:
	var normalized := enemy_id.strip_edges().to_lower()
	match normalized:
		"slime":
			return "slime_green"
		"goblin":
			return "goblin_thief"
		"skeleton_guard":
			return "skeletal_guard"
	return normalized


static func _remove_edge_background(image: Image, tolerance: float) -> void:
	var edge_samples: Array[Color] = [
		image.get_pixel(0, 0),
		image.get_pixel(image.get_width() - 1, 0),
		image.get_pixel(0, image.get_height() - 1),
		image.get_pixel(image.get_width() - 1, image.get_height() - 1)
	]
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var color := image.get_pixel(x, y)
			if _matches_any_edge_color(color, edge_samples, tolerance):
				image.set_pixel(x, y, Color(color.r, color.g, color.b, 0.0))


static func _matches_any_edge_color(color: Color, edge_samples: Array[Color], tolerance: float) -> bool:
	for sample in edge_samples:
		if _color_distance(color, sample) <= tolerance:
			return true
	return false


static func _color_distance(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
