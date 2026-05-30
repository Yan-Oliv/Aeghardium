extends CharacterBody2D
class_name Player2DController

@export var move_speed: float = 140.0
@export var run_speed: float = 190.0
@export var wet_speed_multiplier: float = 0.94
@export var debug_input: bool = true

@onready var animated_sprite: AnimatedSprite2D = $VisualRoot/AnimatedSprite2D
@onready var wet_overlay: Sprite2D = $VisualRoot/StatusRoot/WetOverlay
@onready var burning_overlay: Sprite2D = $VisualRoot/StatusRoot/BurningOverlay
@onready var interaction_area: Area2D = $InteractionArea
@onready var fallback_humanoid: Node2D = $VisualRoot/FallbackHumanoid

@export_enum("mage", "necromancer", "warrior", "assassin", "paladin", "archer", "berserker", "druid", "cleric")
var class_id: String = "mage"
var facing: String = "down"
var current_anim_state: String = "idle"
var walk_time: float = 0.0
var environmental_statuses: Dictionary = {}
var environmental_area_counts: Dictionary = {}
var tick_timers: Dictionary = {}
var last_debug_input_vector: Vector2 = Vector2.ZERO
var equipped_visuals: Dictionary = {}
var appearance_visuals: Dictionary = {}

const DIRECTIONS: Array[String] = ["down", "up", "left", "right"]
const ANIM_STATES: Array[String] = ["idle", "walk"]

var class_visuals: Dictionary = {
	"mage": {"body": "robe", "weapon": "staff", "offhand": "book", "head": "long_hair", "accessory": "aura", "width": 8, "robe": Color8(48, 36, 118), "trim": Color8(81, 154, 236), "hair": Color8(122, 221, 255), "metal": Color8(86, 70, 132), "weapon_color": Color8(70, 44, 30)},
	"necromancer": {"body": "robe", "weapon": "staff", "offhand": "orb", "head": "hood", "accessory": "dark_aura", "width": 8, "robe": Color8(28, 20, 42), "trim": Color8(128, 54, 188), "hair": Color8(198, 198, 210), "metal": Color8(74, 55, 84), "weapon_color": Color8(58, 38, 64)},
	"warrior": {"body": "armor", "weapon": "sword", "offhand": "none", "head": "short_hair", "accessory": "shoulders", "width": 11, "robe": Color8(82, 88, 98), "trim": Color8(210, 170, 76), "hair": Color8(84, 55, 35), "metal": Color8(150, 158, 170), "weapon_color": Color8(188, 198, 212)},
	"assassin": {"body": "leather", "weapon": "daggers", "offhand": "dagger", "head": "hood", "accessory": "scarf", "width": 7, "robe": Color8(26, 31, 38), "trim": Color8(42, 92, 96), "hair": Color8(18, 18, 24), "metal": Color8(84, 92, 102), "weapon_color": Color8(178, 184, 196)},
	"paladin": {"body": "heavy_armor", "weapon": "sword", "offhand": "shield", "head": "blond_hair", "accessory": "halo", "width": 12, "robe": Color8(218, 210, 184), "trim": Color8(235, 194, 68), "hair": Color8(220, 184, 88), "metal": Color8(204, 210, 214), "weapon_color": Color8(218, 224, 230)},
	"archer": {"body": "ranger", "weapon": "bow", "offhand": "quiver", "head": "long_hair", "accessory": "cape", "width": 8, "robe": Color8(62, 92, 48), "trim": Color8(130, 88, 44), "hair": Color8(198, 180, 120), "metal": Color8(82, 108, 70), "weapon_color": Color8(116, 72, 36)},
	"berserker": {"body": "bare", "weapon": "axe", "offhand": "none", "head": "wild_hair", "accessory": "fur", "width": 12, "robe": Color8(132, 48, 38), "trim": Color8(78, 42, 28), "hair": Color8(154, 34, 24), "metal": Color8(122, 118, 116), "weapon_color": Color8(166, 166, 170)},
	"druid": {"body": "nature", "weapon": "staff", "offhand": "none", "head": "leaf_hair", "accessory": "leaves", "width": 9, "robe": Color8(70, 116, 58), "trim": Color8(118, 156, 72), "hair": Color8(92, 65, 36), "metal": Color8(58, 132, 76), "weapon_color": Color8(82, 52, 28)},
	"cleric": {"body": "vestment", "weapon": "mace", "offhand": "book", "head": "light_hair", "accessory": "holy_symbol", "width": 9, "robe": Color8(220, 212, 182), "trim": Color8(232, 196, 90), "hair": Color8(232, 222, 190), "metal": Color8(190, 168, 98), "weapon_color": Color8(170, 145, 82)}
}


func _ready() -> void:
	add_to_group("player_2d")
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	_configure_sprite_visibility()
	_load_class_from_game_state()
	_setup_status_overlays()
	apply_class_visual(class_id)
	print("[Player2D] ready, physics enabled")


func _physics_process(delta: float) -> void:
	_update_environmental_statuses(delta)
	var input_vector: Vector2 = _get_input_vector()
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var speed_multiplier: float = wet_speed_multiplier if environmental_statuses.has("wet") else 1.0
	if environmental_statuses.has("slowed"):
		speed_multiplier *= float(environmental_statuses["slowed"].get("slow_multiplier", 0.6))

	velocity = input_vector * move_speed * speed_multiplier
	move_and_slide()
	_debug_movement_input(input_vector)
	if input_vector.length() > 0.05:
		last_debug_input_vector = input_vector
		_update_facing(input_vector)
		_play_walk_animation(input_vector)
	else:
		_play_idle_animation(last_debug_input_vector if last_debug_input_vector.length() > 0.05 else Vector2.DOWN)
	_update_animation_offsets(delta, input_vector)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()
	elif event.is_action_pressed("pause"):
		GameManager.toggle_pause_menu()


func apply_class_visual(new_class_id: String) -> void:
	class_id = _resolve_class_id(new_class_id)
	if equipped_visuals.is_empty():
		equipped_visuals = EquipmentVisualData.get_default_equipment_for_class(class_id)
	if animated_sprite != null:
		animated_sprite.sprite_frames = _build_sprite_frames(class_id)
		animated_sprite.scale = Vector2(3.0, 3.0)
	if fallback_humanoid != null:
		fallback_humanoid.visible = false
	_play_idle_animation(Vector2.DOWN)
	_ensure_visible_frame()
	_update_fallback_visual()


func apply_equipment_visuals(equipment: Dictionary) -> void:
	equipped_visuals = _normalize_equipment_visuals(equipment)
	if animated_sprite != null:
		animated_sprite.sprite_frames = _build_sprite_frames(class_id)
		animated_sprite.scale = Vector2(3.0, 3.0)
	_play_idle_animation(last_debug_input_vector if last_debug_input_vector.length() > 0.05 else Vector2.DOWN)
	_ensure_visible_frame()
	_update_fallback_visual()


func apply_appearance_visuals(appearance: Dictionary) -> void:
	appearance_visuals = GameManager.normalize_appearance(appearance)
	if animated_sprite != null:
		animated_sprite.sprite_frames = _build_sprite_frames(class_id)
		animated_sprite.scale = Vector2(3.0, 3.0)
	_play_idle_animation(last_debug_input_vector if last_debug_input_vector.length() > 0.05 else Vector2.DOWN)
	_ensure_visible_frame()
	_update_fallback_visual()


func try_interact() -> void:
	var closest: Area2D = null
	var closest_distance: float = INF
	for area in interaction_area.get_overlapping_areas():
		if area == null or not area.has_method("interact"):
			continue
		var distance := global_position.distance_to(area.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = area
	if closest != null:
		closest.interact(self)


func apply_environment_status(environment_type: String, payload: Dictionary = {}) -> void:
	environmental_area_counts[environment_type] = int(environmental_area_counts.get(environment_type, 0)) + 1
	match environment_type:
		"fire":
			environmental_statuses["burning"] = {
				"remaining": float(payload.get("duration", 3.0)),
				"damage_per_tick": float(payload.get("damage_per_tick", 2.0)),
				"tick_interval": float(payload.get("tick_interval", 1.0))
			}
			tick_timers["burning"] = float(payload.get("tick_interval", 1.0))
			_show_status_message("Queimando.")
		"water":
			environmental_statuses.erase("burning")
			environmental_statuses["wet"] = {"remaining": float(payload.get("duration", 5.0))}
			_show_status_message("Molhado.")
		"swamp":
			environmental_statuses["slowed"] = {"remaining": -1.0, "slow_multiplier": float(payload.get("slow_multiplier", 0.6))}
			_show_status_message("Lama reduzindo movimento.")
		"healing":
			environmental_statuses["regenerating"] = {
				"remaining": -1.0,
				"heal_per_tick": float(payload.get("heal_per_tick", 2.0)),
				"tick_interval": float(payload.get("tick_interval", 1.0))
			}
			tick_timers["regenerating"] = float(payload.get("tick_interval", 1.0))
		"safe":
			environmental_statuses.erase("burning")
			environmental_statuses.erase("slowed")
	_update_status_visuals()


func remove_environment_status(environment_type: String) -> void:
	var count: int = max(0, int(environmental_area_counts.get(environment_type, 0)) - 1)
	environmental_area_counts[environment_type] = count
	if count > 0:
		return
	match environment_type:
		"fire":
			environmental_statuses.erase("burning")
			tick_timers.erase("burning")
		"swamp":
			environmental_statuses.erase("slowed")
		"healing":
			environmental_statuses.erase("regenerating")
			tick_timers.erase("regenerating")
		"safe":
			pass
	_update_status_visuals()


func _get_input_vector() -> Vector2:
	var keyboard_vector: Vector2 = _get_keyboard_input()
	var mobile_vector: Vector2 = _get_mobile_input()
	if mobile_vector.length() > 0.05:
		return mobile_vector
	return keyboard_vector


func _get_keyboard_input() -> Vector2:
	var result := Vector2.ZERO
	result.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	result.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if result == Vector2.ZERO:
		result = _get_raw_keyboard_vector()
	return result


func _get_mobile_input() -> Vector2:
	var mobile_controls := get_tree().get_first_node_in_group("mobile_controls_2d")
	if mobile_controls != null and mobile_controls.has_method("get_move_vector"):
		var value: Variant = mobile_controls.call("get_move_vector")
		if value is Vector2:
			return value
	return Vector2.ZERO


func _get_raw_keyboard_vector() -> Vector2:
	var result := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		result.x += 1.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		result.x -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		result.y += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		result.y -= 1.0
	return result


func _debug_movement_input(input_vector: Vector2) -> void:
	if not debug_input:
		return
	if input_vector.length() <= 0.05:
		if velocity.length() > 0.05:
			print("[Player2D] input stopped")
		return
	if input_vector.distance_to(last_debug_input_vector) > 0.15 or velocity.length() > 0.05:
		print("[Player2D] input=", input_vector, " velocity=", velocity, " position=", global_position)


func _update_facing(input_vector: Vector2) -> void:
	if input_vector.length() <= 0.05:
		return
	if absf(input_vector.x) > absf(input_vector.y):
		facing = "right" if input_vector.x > 0.0 else "left"
	else:
		facing = "down" if input_vector.y > 0.0 else "up"


func _update_animation_offsets(delta: float, input_vector: Vector2) -> void:
	var moving := input_vector.length() > 0.05
	if moving:
		walk_time += delta * 8.0
	else:
		walk_time += delta * 2.0
	if animated_sprite != null:
		animated_sprite.position.y = sin(walk_time) * (1.5 if moving else 0.5)
	if burning_overlay != null and animated_sprite != null:
		burning_overlay.position = animated_sprite.position
	if wet_overlay != null and animated_sprite != null:
		wet_overlay.position = animated_sprite.position
	if burning_overlay.visible:
		burning_overlay.modulate.a = 0.45 + sin(walk_time * 2.5) * 0.16
	if wet_overlay.visible:
		wet_overlay.modulate.a = 0.26 + sin(walk_time * 0.8) * 0.06


func _play_walk_animation(direction: Vector2) -> void:
	_safe_play("walk_" + _get_direction_name(direction))
	current_anim_state = "walk"


func _play_idle_animation(direction: Vector2) -> void:
	_safe_play("idle_" + _get_direction_name(direction))
	current_anim_state = "idle"


func _get_direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"


func _safe_play(animation_name: String) -> void:
	if animated_sprite == null:
		return
	if animated_sprite.animation == animation_name and animated_sprite.is_playing():
		return
	if animated_sprite.sprite_frames == null:
		return
	if not animated_sprite.sprite_frames.has_animation(animation_name):
		return
	animated_sprite.play(animation_name)


func _build_sprite_frames(sprite_class_id: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	for state in ANIM_STATES:
		for direction in DIRECTIONS:
			var animation_name := "%s_%s" % [state, direction]
			frames.add_animation(animation_name)
			frames.set_animation_loop(animation_name, true)
			frames.set_animation_speed(animation_name, 3.0 if state == "idle" else 8.0)
			var frame_count := 2 if state == "idle" else 4
			for frame_index in range(frame_count):
				frames.add_frame(animation_name, _build_class_texture(sprite_class_id, direction, state, frame_index))
	return frames


func _build_class_texture(sprite_class_id: String, direction: String, state: String, frame_index: int) -> ImageTexture:
	var colors: Dictionary = _get_render_visuals(sprite_class_id)
	var image := Image.create(24, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	var robe: Color = colors["robe"]
	var trim: Color = colors["trim"]
	var hair: Color = colors["hair"]
	var metal: Color = colors["metal"]
	var weapon: Color = colors["weapon_color"]
	var skin := _skin_for_class(sprite_class_id)
	var shadow := Color8(18, 18, 24, 150)
	var step := _walk_step(state, frame_index)
	var body_width := int(colors.get("width", 8))
	var center_x := 12
	var body_left := center_x - int(body_width * 0.5)
	var body_right := body_left + body_width

	_draw_rect(image, Rect2i(5, 28, 14, 3), shadow)
	_draw_class_accessory_back(image, colors, direction, step)
	_draw_legs(image, colors, step, body_left, body_right)
	_draw_body(image, colors, direction, body_left, body_width, skin)
	_draw_arms(image, colors, direction, step, body_left, body_right, skin)
	_draw_head(image, colors, direction, skin, hair)
	_draw_weapon(image, colors, direction, step, weapon, metal)
	_draw_class_accessory_front(image, colors, direction, trim, metal)

	var texture := ImageTexture.create_from_image(image)
	return texture


func _walk_step(state: String, frame_index: int) -> int:
	if state != "walk":
		return 0
	match frame_index % 4:
		1:
			return 1
		3:
			return -1
	return 0


func _skin_for_class(sprite_class_id: String) -> Color:
	if not appearance_visuals.is_empty():
		match str(appearance_visuals.get("skin_tone", "skin_03")):
			"skin_01":
				return Color8(236, 200, 166)
			"skin_02":
				return Color8(220, 174, 132)
			"skin_03":
				return Color8(198, 150, 112)
			"skin_04":
				return Color8(150, 96, 68)
			"skin_05":
				return Color8(92, 58, 42)
	match sprite_class_id:
		"necromancer":
			return Color8(205, 198, 210)
		"berserker", "druid":
			return Color8(172, 116, 86)
		"assassin", "archer":
			return Color8(198, 150, 112)
		_:
			return Color8(214, 174, 138)


func _draw_class_accessory_back(image: Image, colors: Dictionary, direction: String, step: int) -> void:
	var accessory := str(colors.get("accessory", ""))
	var robe: Color = colors["robe"]
	var trim: Color = colors["trim"]
	match accessory:
		"cape":
			_draw_rect(image, Rect2i(6, 10, 12, 18 + abs(step)), robe.darkened(0.25))
		"fur":
			_draw_rect(image, Rect2i(5, 8, 14, 5), Color8(75, 52, 40))
		"dark_aura":
			_draw_rect(image, Rect2i(3, 12, 2, 11), trim.darkened(0.25))
			_draw_rect(image, Rect2i(19, 13, 2, 10), trim.darkened(0.25))
		"leaves":
			_draw_rect(image, Rect2i(5, 9, 3, 4), trim)
			_draw_rect(image, Rect2i(16, 10, 3, 4), trim)


func _draw_legs(image: Image, colors: Dictionary, step: int, body_left: int, body_right: int) -> void:
	var robe: Color = colors["robe"]
	var leg_color: Color = robe.darkened(0.28)
	var left_height: int = 6 + maxi(step, 0)
	var right_height: int = 6 + maxi(-step, 0)
	_draw_rect(image, Rect2i(body_left + 2, 23, 3, left_height), leg_color)
	_draw_rect(image, Rect2i(body_right - 5, 23, 3, right_height), leg_color)
	_draw_rect(image, Rect2i(body_left + 1, 28 + max(step, 0), 5, 2), Color8(42, 32, 34))
	_draw_rect(image, Rect2i(body_right - 6, 28 + max(-step, 0), 5, 2), Color8(42, 32, 34))


func _draw_body(image: Image, colors: Dictionary, direction: String, body_left: int, body_width: int, skin: Color) -> void:
	var body_type := str(colors.get("body", "robe"))
	var robe: Color = colors["robe"]
	var trim: Color = colors["trim"]
	var metal: Color = colors["metal"]
	var body_height := 15
	var body_top := 10
	match body_type:
		"heavy_armor":
			_draw_rect(image, Rect2i(body_left - 1, body_top, body_width + 2, body_height), metal)
			_draw_rect(image, Rect2i(body_left + 2, body_top + 2, body_width - 4, body_height - 3), robe)
			_draw_rect(image, Rect2i(body_left - 3, body_top + 2, 3, 6), metal.lightened(0.08))
			_draw_rect(image, Rect2i(body_left + body_width, body_top + 2, 3, 6), metal.lightened(0.08))
		"armor":
			_draw_rect(image, Rect2i(body_left, body_top, body_width, body_height), metal)
			_draw_rect(image, Rect2i(body_left + 2, body_top + 2, body_width - 4, body_height - 4), robe.darkened(0.1))
			_draw_rect(image, Rect2i(body_left - 2, body_top + 3, 3, 5), metal.lightened(0.1))
			_draw_rect(image, Rect2i(body_left + body_width - 1, body_top + 3, 3, 5), metal.lightened(0.1))
		"bare":
			_draw_rect(image, Rect2i(body_left, body_top, body_width, 8), skin)
			_draw_rect(image, Rect2i(body_left, body_top + 8, body_width, 7), robe.darkened(0.15))
			_draw_rect(image, Rect2i(body_left + 2, body_top + 2, body_width - 4, 1), Color8(120, 64, 54))
		_:
			_draw_rect(image, Rect2i(body_left, body_top, body_width, body_height), robe)
			_draw_rect(image, Rect2i(body_left - 1, body_top + 8, body_width + 2, 9), robe.darkened(0.08))
	_draw_rect(image, Rect2i(11, body_top + 1, 2, body_height), trim)
	if body_type in ["vestment", "heavy_armor"]:
		_draw_rect(image, Rect2i(9, body_top + 5, 6, 1), trim.lightened(0.15))
	if body_type == "nature":
		_draw_rect(image, Rect2i(body_left + 1, body_top + 4, 3, 3), trim)
		_draw_rect(image, Rect2i(body_left + body_width - 4, body_top + 8, 3, 3), trim)


func _draw_arms(image: Image, colors: Dictionary, direction: String, step: int, body_left: int, body_right: int, skin: Color) -> void:
	var robe: Color = colors["robe"]
	var arm_color: Color = skin if str(colors.get("body", "")) == "bare" else robe.darkened(0.10)
	var left_y: int = 12 + maxi(-step, 0)
	var right_y: int = 12 + maxi(step, 0)
	if direction == "left":
		left_y += 1
	elif direction == "right":
		right_y += 1
	_draw_rect(image, Rect2i(body_left - 3, left_y, 3, 10), arm_color)
	_draw_rect(image, Rect2i(body_right, right_y, 3, 10), arm_color)
	_draw_rect(image, Rect2i(body_left - 3, left_y + 9, 3, 2), skin)
	_draw_rect(image, Rect2i(body_right, right_y + 9, 3, 2), skin)


func _draw_head(image: Image, colors: Dictionary, direction: String, skin: Color, hair: Color) -> void:
	var head_type := str(colors.get("head", "short_hair"))
	var robe: Color = colors["robe"]
	_draw_rect(image, Rect2i(8, 5, 8, 7), skin)
	match head_type:
		"hood":
			_draw_rect(image, Rect2i(7, 3, 10, 7), robe.darkened(0.18))
			_draw_rect(image, Rect2i(8, 6, 8, 5), skin)
		"long_hair":
			_draw_rect(image, Rect2i(7, 3, 10, 5), hair)
			_draw_rect(image, Rect2i(6, 7, 2, 10), hair)
			_draw_rect(image, Rect2i(16, 7, 2, 10), hair)
		"wild_hair":
			_draw_rect(image, Rect2i(6, 2, 12, 5), hair)
			_draw_rect(image, Rect2i(5, 5, 3, 4), hair)
			_draw_rect(image, Rect2i(16, 5, 3, 4), hair)
		"leaf_hair":
			_draw_rect(image, Rect2i(7, 3, 10, 5), hair)
			_draw_rect(image, Rect2i(6, 2, 3, 3), colors["trim"])
			_draw_rect(image, Rect2i(15, 2, 3, 3), colors["trim"])
		_:
			_draw_rect(image, Rect2i(7, 3, 10, 4), hair)
	if direction == "down":
		var eye_color: Color = _eye_color()
		_draw_rect(image, Rect2i(10, 8, 1, 1), eye_color)
		_draw_rect(image, Rect2i(14, 8, 1, 1), eye_color)
	elif direction == "up":
		_draw_rect(image, Rect2i(8, 4, 8, 7), hair)


func _draw_weapon(image: Image, colors: Dictionary, direction: String, step: int, weapon: Color, metal: Color) -> void:
	var weapon_type := str(colors.get("weapon", "staff"))
	var offhand := str(colors.get("offhand", "none"))
	match weapon_type:
		"staff":
			var x := 3 if direction != "right" else 19
			_draw_rect(image, Rect2i(x, 7, 2, 20), weapon)
			_draw_rect(image, Rect2i(x - 1, 5, 4, 4), colors["trim"])
		"sword":
			_draw_rect(image, Rect2i(18, 9 + step, 2, 15), metal.lightened(0.2))
			_draw_rect(image, Rect2i(17, 20 + step, 4, 2), weapon.darkened(0.2))
		"daggers":
			_draw_rect(image, Rect2i(3, 15 + max(step, 0), 4, 2), metal.lightened(0.15))
			_draw_rect(image, Rect2i(17, 15 + max(-step, 0), 4, 2), metal.lightened(0.15))
		"bow":
			_draw_rect(image, Rect2i(18, 7, 2, 19), weapon)
			_draw_rect(image, Rect2i(19, 9, 1, 15), colors["trim"].lightened(0.1))
		"axe":
			_draw_rect(image, Rect2i(18, 9 + step, 2, 16), weapon)
			_draw_rect(image, Rect2i(15, 7 + step, 7, 4), metal.lightened(0.05))
		"mace":
			_draw_rect(image, Rect2i(18, 10 + step, 2, 13), weapon)
			_draw_rect(image, Rect2i(16, 7 + step, 6, 5), metal.lightened(0.08))
	if offhand == "shield":
		_draw_rect(image, Rect2i(3, 14, 5, 8), metal.lightened(0.05))
		_draw_rect(image, Rect2i(4, 16, 3, 4), colors["trim"])
	elif offhand == "book":
		_draw_rect(image, Rect2i(4, 15, 5, 6), Color8(92, 52, 72))
		_draw_rect(image, Rect2i(5, 16, 3, 4), Color8(220, 205, 164))
	elif offhand == "quiver":
		_draw_rect(image, Rect2i(5, 7, 3, 12), Color8(96, 58, 34))
	elif offhand == "orb":
		_draw_rect(image, Rect2i(4, 15, 3, 3), colors["trim"])


func _draw_class_accessory_front(image: Image, colors: Dictionary, direction: String, trim: Color, metal: Color) -> void:
	match str(colors.get("accessory", "")):
		"halo":
			_draw_rect(image, Rect2i(8, 1, 8, 1), trim.lightened(0.2))
		"holy_symbol":
			_draw_rect(image, Rect2i(11, 13, 2, 5), trim)
			_draw_rect(image, Rect2i(9, 15, 6, 1), trim)
		"shoulders":
			_draw_rect(image, Rect2i(5, 10, 4, 3), metal)
			_draw_rect(image, Rect2i(15, 10, 4, 3), metal)
		"scarf":
			_draw_rect(image, Rect2i(8, 11, 8, 2), trim.darkened(0.1))
		"aura":
			_draw_rect(image, Rect2i(2, 23, 2, 2), trim)
			_draw_rect(image, Rect2i(20, 21, 2, 2), trim)


func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
				image.set_pixel(x, y, color)


func _setup_status_overlays() -> void:
	wet_overlay.texture = _build_overlay_texture(Color8(50, 150, 255, 95))
	burning_overlay.texture = _build_overlay_texture(Color8(255, 70, 12, 130))
	wet_overlay.visible = false
	burning_overlay.visible = false


func _build_overlay_texture(color: Color) -> ImageTexture:
	var image := Image.create(28, 34, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_rect(image, Rect2i(5, 4, 18, 26), color)
	return ImageTexture.create_from_image(image)


func _update_environmental_statuses(delta: float) -> void:
	if environmental_statuses.has("wet"):
		var wet_data: Dictionary = environmental_statuses["wet"]
		var remaining: float = float(wet_data.get("remaining", 0.0)) - delta
		if int(environmental_area_counts.get("fire", 0)) > 0:
			remaining -= delta * 3.0
		elif int(environmental_area_counts.get("heat", 0)) > 0:
			remaining -= delta * 1.5
		if remaining <= 0.0:
			environmental_statuses.erase("wet")
		else:
			wet_data["remaining"] = remaining
			environmental_statuses["wet"] = wet_data

	for status_name in ["burning", "regenerating"]:
		if not environmental_statuses.has(status_name):
			continue
		var data: Dictionary = environmental_statuses[status_name]
		tick_timers[status_name] = float(tick_timers.get(status_name, data.get("tick_interval", 1.0))) - delta
		if float(tick_timers[status_name]) <= 0.0:
			tick_timers[status_name] = float(data.get("tick_interval", 1.0))
			_process_status_tick(status_name, data)
		var remaining: float = float(data.get("remaining", -1.0))
		if remaining > 0.0:
			remaining -= delta
			if remaining <= 0.0:
				environmental_statuses.erase(status_name)
			else:
				data["remaining"] = remaining
				environmental_statuses[status_name] = data
	_update_status_visuals()


func _process_status_tick(status_name: String, data: Dictionary) -> void:
	if GameManager.player_state.is_empty():
		return
	if status_name == "burning":
		var hp := float(GameManager.player_state.get("current_health", 1.0))
		GameManager.player_state["current_health"] = maxf(1.0, hp - float(data.get("damage_per_tick", 2.0)))
	elif status_name == "regenerating":
		var hp := float(GameManager.player_state.get("current_health", 1.0))
		var max_hp := float(GameManager.player_state.get("max_health", hp))
		GameManager.player_state["current_health"] = minf(max_hp, hp + float(data.get("heal_per_tick", 2.0)))


func _update_status_visuals() -> void:
	burning_overlay.visible = environmental_statuses.has("burning")
	wet_overlay.visible = environmental_statuses.has("wet") and not burning_overlay.visible


func _show_status_message(message: String) -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.has_method("show_message"):
		scene.show_message(message)
	else:
		print("[Player2D] ", message)


func _load_class_from_game_state() -> void:
	if not GameManager.player_state.is_empty():
		class_id = str(GameManager.player_state.get("class_id", class_id))
		equipped_visuals = _normalize_equipment_visuals(GameManager.player_state.get("equipment_visuals", {}))
		appearance_visuals = GameManager.normalize_appearance(GameManager.player_state.get("appearance", {}))
	elif not GameManager.selected_class_id.is_empty():
		class_id = GameManager.selected_class_id


func _resolve_class_id(candidate: String) -> String:
	var normalized := candidate.strip_edges().to_lower()
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
		"arqueiro":
			return "archer"
		"druida":
			return "druid"
		"clerigo", "clérigo":
			return "cleric"
	if class_visuals.has(normalized):
		return normalized
	return "mage"


func _configure_sprite_visibility() -> void:
	z_index = 80
	visible = true
	fallback_humanoid.visible = true
	fallback_humanoid.z_index = 100
	animated_sprite.visible = true
	animated_sprite.z_index = 120
	animated_sprite.scale = Vector2(3.0, 3.0)
	animated_sprite.centered = true
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	wet_overlay.z_index = 91
	wet_overlay.scale = Vector2(3.0, 3.0)
	wet_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	burning_overlay.z_index = 92
	burning_overlay.scale = Vector2(3.0, 3.0)
	burning_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _ensure_visible_frame() -> void:
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames == null:
		animated_sprite.sprite_frames = _build_emergency_sprite_frames()
	if not animated_sprite.sprite_frames.has_animation("idle_down"):
		animated_sprite.sprite_frames = _build_emergency_sprite_frames()
	if animated_sprite.animation.is_empty():
		_safe_play("idle_down")


func _build_emergency_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	for state in ANIM_STATES:
		for direction in DIRECTIONS:
			var animation_name := "%s_%s" % [state, direction]
			frames.add_animation(animation_name)
			frames.set_animation_loop(animation_name, true)
			frames.set_animation_speed(animation_name, 4.0 if state == "idle" else 8.0)
			frames.add_frame(animation_name, _build_emergency_texture(direction))
	return frames


func _build_emergency_texture(direction: String) -> ImageTexture:
	var image := Image.create(24, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	_draw_rect(image, Rect2i(5, 28, 14, 3), Color8(10, 10, 12, 160))
	_draw_rect(image, Rect2i(8, 5, 8, 7), Color8(225, 178, 138))
	_draw_rect(image, Rect2i(7, 3, 10, 4), Color8(110, 210, 255))
	_draw_rect(image, Rect2i(7, 11, 10, 14), Color8(52, 42, 132))
	_draw_rect(image, Rect2i(11, 11, 2, 14), Color8(98, 178, 255))
	_draw_rect(image, Rect2i(4, 12, 3, 10), Color8(44, 34, 112))
	_draw_rect(image, Rect2i(17, 12, 3, 10), Color8(44, 34, 112))
	_draw_rect(image, Rect2i(8, 24, 3, 5), Color8(28, 22, 72))
	_draw_rect(image, Rect2i(13, 24, 3, 5), Color8(28, 22, 72))
	_draw_rect(image, Rect2i(3, 7, 2, 20), Color8(72, 46, 30))
	_draw_rect(image, Rect2i(2, 5, 4, 4), Color8(80, 170, 255))
	if direction == "down":
		_draw_rect(image, Rect2i(10, 8, 1, 1), Color8(110, 240, 255))
		_draw_rect(image, Rect2i(14, 8, 1, 1), Color8(110, 240, 255))
	return ImageTexture.create_from_image(image)


func _update_fallback_visual() -> void:
	var colors: Dictionary = _get_render_visuals(class_id)
	var robe_color: Color = colors.get("robe", Color8(48, 36, 118))
	var trim_color: Color = colors.get("trim", Color8(81, 154, 236))
	var hair_color: Color = colors.get("hair", Color8(122, 221, 255))
	var metal_color: Color = colors.get("metal", Color8(150, 158, 170))
	var weapon_color: Color = colors.get("weapon_color", Color8(70, 44, 30))
	var body_type: String = str(colors.get("body", "robe"))
	var weapon_type: String = str(colors.get("weapon", "staff"))
	var offhand_type: String = str(colors.get("offhand", "none"))

	_set_polygon_color("Cape", robe_color.darkened(0.22))
	_set_polygon_color("Robe", robe_color)
	_set_polygon_color("Trim", trim_color)
	_set_polygon_color("Head", _skin_for_class(class_id))
	_set_polygon_color("Hair", hair_color)
	_set_polygon_color("LeftArm", robe_color.darkened(0.12))
	_set_polygon_color("RightArm", robe_color.darkened(0.12))
	_set_polygon_color("Staff", weapon_color)
	_set_polygon_color("StaffGem", trim_color.lightened(0.18))
	_set_polygon_color("Offhand", metal_color)

	var cape: CanvasItem = fallback_humanoid.get_node_or_null("Cape") as CanvasItem
	var staff: CanvasItem = fallback_humanoid.get_node_or_null("Staff") as CanvasItem
	var staff_gem: CanvasItem = fallback_humanoid.get_node_or_null("StaffGem") as CanvasItem
	var offhand: CanvasItem = fallback_humanoid.get_node_or_null("Offhand") as CanvasItem
	if cape != null:
		cape.visible = body_type in ["robe", "vestment", "nature", "ranger"]
	if staff != null:
		staff.visible = weapon_type in ["staff", "mace", "axe", "bow"]
	if staff_gem != null:
		staff_gem.visible = weapon_type == "staff"
	if offhand != null:
		offhand.visible = offhand_type != "none"


func _set_polygon_color(node_name: String, color: Color) -> void:
	var polygon: Polygon2D = fallback_humanoid.get_node_or_null(node_name) as Polygon2D
	if polygon != null:
		polygon.color = color


func _normalize_equipment_visuals(equipment: Dictionary) -> Dictionary:
	var normalized: Dictionary = EquipmentVisualData.get_default_equipment_for_class(class_id)
	for slot in ["main_hand", "offhand", "chest", "cape", "accessory"]:
		if equipment.has(slot):
			normalized[slot] = str(equipment.get(slot, ""))
	return normalized


func _get_render_visuals(sprite_class_id: String) -> Dictionary:
	var visuals: Dictionary = class_visuals.get(sprite_class_id, class_visuals["mage"]).duplicate(true)
	var main_hand: Dictionary = EquipmentVisualData.get_item(str(equipped_visuals.get("main_hand", "")))
	var offhand: Dictionary = EquipmentVisualData.get_item(str(equipped_visuals.get("offhand", "")))
	var chest: Dictionary = EquipmentVisualData.get_item(str(equipped_visuals.get("chest", "")))
	var cape: Dictionary = EquipmentVisualData.get_item(str(equipped_visuals.get("cape", "")))

	if not main_hand.is_empty():
		visuals["weapon"] = str(main_hand.get("weapon_type", visuals.get("weapon", "staff")))
		visuals["weapon_color"] = EquipmentVisualData.color_from_hex(str(main_hand.get("color", "")), visuals.get("weapon_color", Color.WHITE))
		if main_hand.has("gem_color"):
			visuals["trim"] = EquipmentVisualData.color_from_hex(str(main_hand.get("gem_color", "")), visuals.get("trim", Color.WHITE))
	if not offhand.is_empty():
		visuals["offhand"] = str(offhand.get("offhand_type", visuals.get("offhand", "none")))
		visuals["metal"] = EquipmentVisualData.color_from_hex(str(offhand.get("color", "")), visuals.get("metal", Color.WHITE))
	if not chest.is_empty():
		visuals["body"] = str(chest.get("body_type", visuals.get("body", "robe")))
		visuals["robe"] = EquipmentVisualData.color_from_hex(str(chest.get("robe_color", "")), visuals.get("robe", Color.WHITE))
		visuals["trim"] = EquipmentVisualData.color_from_hex(str(chest.get("trim_color", "")), visuals.get("trim", Color.WHITE))
		visuals["metal"] = EquipmentVisualData.color_from_hex(str(chest.get("metal_color", "")), visuals.get("metal", Color.WHITE))
	if not cape.is_empty():
		visuals["accessory"] = str(cape.get("accessory", visuals.get("accessory", "")))
		visuals["robe"] = EquipmentVisualData.color_from_hex(str(cape.get("color", "")), visuals.get("robe", Color.WHITE))
	_apply_appearance_overrides(visuals)
	return visuals


func _apply_appearance_overrides(visuals: Dictionary) -> void:
	if appearance_visuals.is_empty():
		return
	match str(appearance_visuals.get("hair_color", "black")):
		"black":
			visuals["hair"] = Color8(24, 24, 30)
		"brown":
			visuals["hair"] = Color8(92, 58, 34)
		"chestnut":
			visuals["hair"] = Color8(142, 74, 42)
		"blonde":
			visuals["hair"] = Color8(218, 184, 92)
		"white":
			visuals["hair"] = Color8(226, 224, 214)
		"red":
			visuals["hair"] = Color8(172, 42, 30)
		"teal":
			visuals["hair"] = Color8(80, 210, 210)
		"violet":
			visuals["hair"] = Color8(158, 84, 210)

	match str(appearance_visuals.get("hair_style", "short")):
		"short":
			visuals["head"] = "short_hair"
		"spiked":
			visuals["head"] = "wild_hair"
		"bob":
			visuals["head"] = "bob_hair"
		"ponytail":
			visuals["head"] = "long_hair"
		"crown":
			visuals["head"] = "leaf_hair"

	match str(appearance_visuals.get("body_type", "masculine")):
		"feminine":
			visuals["width"] = max(7, int(visuals.get("width", 8)) - 1)
		"stylized_neutral":
			visuals["width"] = int(visuals.get("width", 8))
		_:
			visuals["width"] = int(visuals.get("width", 8))

	match str(appearance_visuals.get("outfit_variant", "class_default")):
		"dark":
			visuals["robe"] = (visuals.get("robe", Color.WHITE) as Color).darkened(0.28)
			visuals["trim"] = (visuals.get("trim", Color.WHITE) as Color).darkened(0.12)
		"bright":
			visuals["robe"] = (visuals.get("robe", Color.WHITE) as Color).lightened(0.22)
			visuals["trim"] = (visuals.get("trim", Color.WHITE) as Color).lightened(0.18)

	if not bool(appearance_visuals.get("aura_enabled", true)):
		if str(visuals.get("accessory", "")) in ["aura", "dark_aura", "leaves", "halo"]:
			visuals["accessory"] = ""


func _eye_color() -> Color:
	match str(appearance_visuals.get("eye_color", "amber")):
		"blue":
			return Color8(86, 190, 255)
		"green":
			return Color8(95, 220, 130)
		"violet":
			return Color8(185, 112, 255)
		"silver":
			return Color8(220, 230, 235)
	return Color8(255, 190, 84)
