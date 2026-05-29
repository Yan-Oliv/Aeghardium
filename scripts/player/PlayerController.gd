extends CharacterBody3D
class_name PlayerController

@export var walk_speed: float = 4.2
@export var run_speed: float = 6.0
@export var acceleration: float = 12.0
@export var player_rotation_speed: float = 5.0
@export var gravity: float = 24.0
@export var mouse_camera_sensitivity: float = 0.00075
@export var touch_camera_sensitivity: float = 0.00022
@export var camera_smoothing: float = 8.0
@export var auto_camera_follow_enabled: bool = false
@export var auto_camera_delay: float = 2.0
@export var auto_camera_follow_speed: float = 2.5
@export var mobile_camera_yaw_speed: float = 3.2
@export var mobile_camera_pitch_speed: float = 1.8
@export var mobile_camera_deadzone: float = 0.05
@export var min_camera_pitch_degrees: float = -35.0
@export var max_camera_pitch_degrees: float = 55.0
@export var camera_orbit_distance: float = 5.2
@export var camera_orbit_target_height: float = 1.45
@export var jump_velocity: float = 6.2
@export var wet_speed_multiplier: float = 0.92
@export var wet_jump_multiplier: float = 0.88
@export var heat_wet_dry_rate: float = 2.0
@export var fire_wet_dry_rate: float = 4.0

@onready var stats: PlayerStats = $Stats
@onready var combat: PlayerCombat = $Combat
@onready var skills: SkillController = $Skills
@onready var visual_root: Node3D = get_node_or_null("VisualRoot") as Node3D
@onready var visual_controller: PlayerVisualController = get_node_or_null("VisualRoot/PlayerVisualController") as PlayerVisualController
@onready var mesh: MeshInstance3D = get_node_or_null("VisualRoot/Body") as MeshInstance3D
@onready var fallback_visual: MeshInstance3D = get_node_or_null("Visual") as MeshInstance3D
@onready var body_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Body") as MeshInstance3D
@onready var head_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Head") as MeshInstance3D
@onready var left_arm: MeshInstance3D = get_node_or_null("VisualRoot/LeftArm") as MeshInstance3D
@onready var right_arm: MeshInstance3D = get_node_or_null("VisualRoot/RightArm") as MeshInstance3D
@onready var left_leg: MeshInstance3D = get_node_or_null("VisualRoot/LeftLeg") as MeshInstance3D
@onready var right_leg: MeshInstance3D = get_node_or_null("VisualRoot/RightLeg") as MeshInstance3D
@onready var chest_armor: MeshInstance3D = get_node_or_null("VisualRoot/ChestArmor") as MeshInstance3D
@onready var left_shoulder: MeshInstance3D = get_node_or_null("VisualRoot/LeftShoulder") as MeshInstance3D
@onready var right_shoulder: MeshInstance3D = get_node_or_null("VisualRoot/RightShoulder") as MeshInstance3D
@onready var hair_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Hair") as MeshInstance3D
@onready var hood_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Hood") as MeshInstance3D
@onready var helmet_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Helmet") as MeshInstance3D
@onready var cape_mesh: MeshInstance3D = get_node_or_null("VisualRoot/Cape") as MeshInstance3D
@onready var weapon_placeholder: Node3D = get_node_or_null("VisualRoot/WeaponPlaceholder") as Node3D
@onready var weapon_main: MeshInstance3D = get_node_or_null("VisualRoot/WeaponPlaceholder/WeaponMain") as MeshInstance3D
@onready var weapon_tip: MeshInstance3D = get_node_or_null("VisualRoot/WeaponPlaceholder/WeaponTip") as MeshInstance3D
@onready var weapon_offhand: MeshInstance3D = get_node_or_null("VisualRoot/WeaponPlaceholder/WeaponOffhand") as MeshInstance3D
@onready var aura_root: Node3D = get_node_or_null("VisualRoot/AuraRoot") as Node3D
@onready var aura_core: MeshInstance3D = get_node_or_null("VisualRoot/AuraRoot/AuraCore") as MeshInstance3D
@onready var left_hand_glow: MeshInstance3D = get_node_or_null("VisualRoot/AuraRoot/LeftHandGlow") as MeshInstance3D
@onready var right_hand_glow: MeshInstance3D = get_node_or_null("VisualRoot/AuraRoot/RightHandGlow") as MeshInstance3D
@onready var floor_aura: MeshInstance3D = get_node_or_null("VisualRoot/AuraRoot/FloorAura") as MeshInstance3D
@onready var burning_effect: Node3D = get_node_or_null("VisualRoot/BurningEffect") as Node3D
@onready var wet_effect: Node3D = get_node_or_null("VisualRoot/WetEffect") as Node3D
@onready var camera_pivot: Node3D = get_node_or_null("CameraPivot") as Node3D
@onready var spring_arm: SpringArm3D = get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
@onready var camera: Camera3D = get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D

var hud: HUDController = null
var class_id: String = "necromancer"
var player_name: String = "Desperto"
var move_input: Vector2 = Vector2.ZERO
var camera_pitch: float = deg_to_rad(-15.0)
var camera_yaw: float = 0.0
var target_camera_pitch: float = deg_to_rad(-15.0)
var target_camera_yaw: float = 0.0
var is_dead: bool = false
var invisible_until: float = 0.0
var active_timers: Dictionary = {}
var base_stats: Dictionary = {}
var spawn_position: Vector3 = Vector3.ZERO
var appearance: Dictionary = {}
var _missing_mobile_controls_logged: bool = false
var _last_logged_mobile_vector: Vector2 = Vector2.ZERO
var time_since_camera_input: float = 0.0
var environmental_statuses: Dictionary = {}
var environmental_area_counts: Dictionary = {}
var _visual_base_position: Vector3 = Vector3.ZERO
var _walk_anim_phase: float = 0.0
var _idle_anim_time: float = 0.0
var _last_horizontal_speed: float = 0.0
var _visual_meshes: Array[MeshInstance3D] = []
var _normal_material_overrides: Dictionary = {}
var _burn_material: StandardMaterial3D = null
var _wet_material: StandardMaterial3D = null
var _body_material: StandardMaterial3D = null
var _skin_material: StandardMaterial3D = null
var _limb_material: StandardMaterial3D = null
var _hair_material: StandardMaterial3D = null
var _cape_material: StandardMaterial3D = null
var _weapon_material: StandardMaterial3D = null
var _weapon_accent_material: StandardMaterial3D = null
var _aura_material: StandardMaterial3D = null
var _current_class_id: String = "necromancer"
var _base_positions: Dictionary = {}
var _base_rotations: Dictionary = {}

const LEG_BASE_TOTAL_HEIGHT: float = 0.92
const FOOT_CLEARANCE: float = 0.04
const BODY_VERTICAL_OFFSET: float = 0.58
const HEAD_VERTICAL_OFFSET: float = 0.62

const CLASS_VISUAL_PRESETS: Dictionary = {
	"necromancer": {"body_scale": Vector3(0.98, 1.10, 0.86), "arm_scale": Vector3(0.82, 1.10, 0.82), "leg_scale": Vector3(0.88, 1.04, 0.88), "head_scale": Vector3(0.94, 0.94, 0.94), "skin": Color(0.82, 0.79, 0.84, 1.0), "body": Color(0.18, 0.15, 0.22, 1.0), "limb": Color(0.10, 0.09, 0.14, 1.0), "hair": Color(0.08, 0.08, 0.10, 1.0), "cape_color": Color(0.30, 0.18, 0.42, 1.0), "weapon": Color(0.36, 0.34, 0.40, 1.0), "accent": Color(0.58, 0.30, 0.84, 1.0), "aura": Color(0.56, 0.26, 0.88, 1.0), "aura_mode": "hands", "weapon_type": "staff", "offhand": "none", "show_cape": true, "show_hair": false, "show_hood": true, "show_helmet": false, "show_shoulders": false, "show_armor": false, "weapon_tilt": -6.0, "arm_y_offset": -0.03, "arm_side": 0.42},
	"assassin": {"body_scale": Vector3(0.92, 1.00, 0.82), "arm_scale": Vector3(0.78, 1.10, 0.78), "leg_scale": Vector3(0.82, 1.00, 0.82), "head_scale": Vector3(0.92, 0.92, 0.92), "skin": Color(0.70, 0.62, 0.54, 1.0), "body": Color(0.16, 0.18, 0.22, 1.0), "limb": Color(0.10, 0.11, 0.14, 1.0), "hair": Color(0.12, 0.12, 0.14, 1.0), "cape_color": Color(0.20, 0.22, 0.26, 1.0), "weapon": Color(0.46, 0.48, 0.54, 1.0), "accent": Color(0.18, 0.26, 0.34, 1.0), "aura": Color(0.18, 0.28, 0.36, 1.0), "aura_mode": "floor", "weapon_type": "dagger", "offhand": "dagger", "show_cape": false, "show_hair": false, "show_hood": true, "show_helmet": false, "show_shoulders": false, "show_armor": false, "weapon_tilt": -18.0, "arm_y_offset": -0.02, "arm_side": 0.40},
	"warrior": {"body_scale": Vector3(1.16, 1.12, 1.02), "arm_scale": Vector3(0.98, 1.12, 0.98), "leg_scale": Vector3(0.96, 1.08, 0.96), "head_scale": Vector3(0.96, 0.96, 0.96), "skin": Color(0.64, 0.54, 0.46, 1.0), "body": Color(0.42, 0.46, 0.52, 1.0), "limb": Color(0.28, 0.30, 0.36, 1.0), "hair": Color(0.28, 0.18, 0.10, 1.0), "cape_color": Color(0.60, 0.48, 0.20, 1.0), "weapon": Color(0.58, 0.60, 0.66, 1.0), "accent": Color(0.82, 0.68, 0.34, 1.0), "aura": Color(0.84, 0.72, 0.36, 1.0), "aura_mode": "core", "weapon_type": "sword", "offhand": "none", "show_cape": false, "show_hair": true, "show_hood": false, "show_helmet": false, "show_shoulders": true, "show_armor": true, "weapon_tilt": -16.0, "arm_y_offset": 0.02, "arm_side": 0.46},
	"archer": {"body_scale": Vector3(0.96, 1.02, 0.88), "arm_scale": Vector3(0.82, 1.08, 0.82), "leg_scale": Vector3(0.84, 1.04, 0.84), "head_scale": Vector3(0.93, 0.93, 0.93), "skin": Color(0.70, 0.58, 0.44, 1.0), "body": Color(0.28, 0.38, 0.22, 1.0), "limb": Color(0.36, 0.24, 0.14, 1.0), "hair": Color(0.20, 0.16, 0.10, 1.0), "cape_color": Color(0.40, 0.54, 0.28, 1.0), "weapon": Color(0.38, 0.26, 0.16, 1.0), "accent": Color(0.56, 0.74, 0.34, 1.0), "aura": Color(0.42, 0.78, 0.40, 1.0), "aura_mode": "floor", "weapon_type": "bow", "offhand": "none", "show_cape": false, "show_hair": true, "show_hood": false, "show_helmet": false, "show_shoulders": false, "show_armor": true, "weapon_tilt": 72.0, "arm_y_offset": -0.01, "arm_side": 0.42},
	"mage": {"body_scale": Vector3(0.94, 1.08, 0.86), "arm_scale": Vector3(0.80, 1.10, 0.80), "leg_scale": Vector3(0.84, 1.06, 0.84), "head_scale": Vector3(0.94, 0.94, 0.94), "skin": Color(0.78, 0.72, 0.66, 1.0), "body": Color(0.22, 0.30, 0.50, 1.0), "limb": Color(0.18, 0.20, 0.32, 1.0), "hair": Color(0.62, 0.70, 0.84, 1.0), "cape_color": Color(0.42, 0.28, 0.68, 1.0), "weapon": Color(0.42, 0.38, 0.50, 1.0), "accent": Color(0.48, 0.72, 1.00, 1.0), "aura": Color(0.36, 0.68, 1.00, 1.0), "aura_mode": "hands", "weapon_type": "staff", "offhand": "none", "show_cape": true, "show_hair": true, "show_hood": false, "show_helmet": false, "show_shoulders": false, "show_armor": true, "weapon_tilt": -8.0, "arm_y_offset": -0.02, "arm_side": 0.41},
	"berserker": {"body_scale": Vector3(1.22, 1.18, 1.10), "arm_scale": Vector3(1.12, 1.18, 1.12), "leg_scale": Vector3(1.02, 1.12, 1.02), "head_scale": Vector3(0.98, 0.98, 0.98), "skin": Color(0.58, 0.42, 0.30, 1.0), "body": Color(0.44, 0.20, 0.16, 1.0), "limb": Color(0.30, 0.14, 0.12, 1.0), "hair": Color(0.38, 0.08, 0.06, 1.0), "cape_color": Color(0.52, 0.16, 0.14, 1.0), "weapon": Color(0.52, 0.50, 0.54, 1.0), "accent": Color(0.88, 0.28, 0.18, 1.0), "aura": Color(0.88, 0.22, 0.16, 1.0), "aura_mode": "core", "weapon_type": "axe", "offhand": "none", "show_cape": false, "show_hair": true, "show_hood": false, "show_helmet": false, "show_shoulders": true, "show_armor": true, "weapon_tilt": -16.0, "arm_y_offset": 0.04, "arm_side": 0.48},
	"druid": {"body_scale": Vector3(0.98, 1.04, 0.90), "arm_scale": Vector3(0.84, 1.06, 0.84), "leg_scale": Vector3(0.86, 1.04, 0.86), "head_scale": Vector3(0.94, 0.94, 0.94), "skin": Color(0.48, 0.38, 0.28, 1.0), "body": Color(0.28, 0.40, 0.24, 1.0), "limb": Color(0.22, 0.30, 0.18, 1.0), "hair": Color(0.22, 0.18, 0.10, 1.0), "cape_color": Color(0.44, 0.58, 0.32, 1.0), "weapon": Color(0.36, 0.24, 0.14, 1.0), "accent": Color(0.56, 0.82, 0.48, 1.0), "aura": Color(0.48, 0.88, 0.54, 1.0), "aura_mode": "floor", "weapon_type": "staff", "offhand": "none", "show_cape": true, "show_hair": true, "show_hood": false, "show_helmet": false, "show_shoulders": false, "show_armor": true, "weapon_tilt": -10.0, "arm_y_offset": -0.01, "arm_side": 0.42},
	"cleric": {"body_scale": Vector3(1.04, 1.08, 0.96), "arm_scale": Vector3(0.90, 1.08, 0.90), "leg_scale": Vector3(0.90, 1.06, 0.90), "head_scale": Vector3(0.95, 0.95, 0.95), "skin": Color(0.74, 0.66, 0.58, 1.0), "body": Color(0.78, 0.76, 0.68, 1.0), "limb": Color(0.64, 0.58, 0.42, 1.0), "hair": Color(0.74, 0.68, 0.42, 1.0), "cape_color": Color(0.90, 0.84, 0.52, 1.0), "weapon": Color(0.66, 0.62, 0.52, 1.0), "accent": Color(1.00, 0.92, 0.62, 1.0), "aura": Color(1.00, 0.92, 0.68, 1.0), "aura_mode": "core", "weapon_type": "staff", "offhand": "book", "show_cape": true, "show_hair": true, "show_hood": false, "show_helmet": true, "show_shoulders": true, "show_armor": true, "weapon_tilt": -4.0, "arm_y_offset": 0.01, "arm_side": 0.44},
	"paladin": {"body_scale": Vector3(1.16, 1.14, 1.04), "arm_scale": Vector3(1.00, 1.12, 1.00), "leg_scale": Vector3(0.96, 1.10, 0.96), "head_scale": Vector3(0.96, 0.96, 0.96), "skin": Color(0.72, 0.64, 0.56, 1.0), "body": Color(0.82, 0.80, 0.74, 1.0), "limb": Color(0.62, 0.62, 0.66, 1.0), "hair": Color(0.66, 0.54, 0.24, 1.0), "cape_color": Color(0.96, 0.88, 0.50, 1.0), "weapon": Color(0.80, 0.80, 0.84, 1.0), "accent": Color(1.00, 0.90, 0.52, 1.0), "aura": Color(1.00, 0.88, 0.46, 1.0), "aura_mode": "all", "weapon_type": "sword", "offhand": "shield", "show_cape": true, "show_hair": false, "show_hood": false, "show_helmet": true, "show_shoulders": true, "show_armor": true, "weapon_tilt": -12.0, "arm_y_offset": 0.02, "arm_side": 0.46}
}


func _ready() -> void:
	combat.setup(self)
	stats.died.connect(_on_died)
	stats.damaged.connect(_on_damaged)
	if not is_in_group("player_controller"):
		add_to_group("player_controller")
	if not is_in_group("player"):
		add_to_group("player")
	if camera != null:
		camera.current = true
		camera.make_current()
	target_camera_pitch = camera_pitch
	target_camera_yaw = camera_yaw
	_update_camera_pivot()
	_apply_initial_class_visual()


func _process(delta: float) -> void:
	time_since_camera_input += delta
	_update_environmental_statuses(delta)
	_update_environment_visuals()
	_apply_mobile_camera_joystick(delta)
	if auto_camera_follow_enabled:
		_apply_auto_camera_follow(delta)
	_update_camera_rotation(delta)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_mana_regen(delta)
	_apply_gravity(delta)
	_handle_movement(delta)
	if visual_controller != null:
		visual_controller.play_movement_animation(Vector2(velocity.x, velocity.z).length())
	move_and_slide()


func initialize_new_character(new_class_id: String, new_name: String) -> void:
	class_id = new_class_id
	player_name = new_name
	appearance = GameManager.get_default_appearance()
	var data: Dictionary = ClassData.get_class_data(class_id)
	stats.configure_from_class(data)
	base_stats = stats.to_dictionary()
	skills.setup(self, _to_string_array(data.get("skills", [])))
	spawn_position = global_position
	apply_class_visual(class_id)


func load_from_save(data: Dictionary) -> void:
	class_id = str(data.get("class_id", "necromancer"))
	player_name = str(data.get("player_name", "Desperto"))
	appearance = GameManager.normalize_appearance(data.get("appearance", {}))
	var class_info: Dictionary = ClassData.get_class_data(class_id)
	stats.configure_from_class(class_info)
	var snapshot: Dictionary = data.get("stats", {})
	stats.load_snapshot(snapshot)
	base_stats = stats.to_dictionary()
	skills.setup(self, _to_string_array(class_info.get("skills", [])))
	var saved_position: Array = data.get("position", [0.0, 0.0, 0.0])
	global_position = _vector3_from_array(saved_position)
	spawn_position = global_position
	apply_class_visual(class_id)


func build_save_data() -> Dictionary:
	return {
		"stats": stats.to_dictionary(),
		"position": [global_position.x, global_position.y, global_position.z],
		"appearance": appearance
	}


func apply_appearance(new_appearance: Dictionary) -> void:
	appearance = GameManager.normalize_appearance(new_appearance)
	for child in get_children():
		if child is CharacterPreview3D:
			(child as CharacterPreview3D).apply_appearance(class_id, appearance)
	if visual_controller != null:
		visual_controller.apply_appearance(CharacterAppearanceData.from_dictionary(appearance, class_id))
	else:
		apply_class_visual(class_id)


func apply_class_visual(new_class_id: String) -> void:
	_current_class_id = _resolve_class_id(new_class_id)
	class_id = _current_class_id
	_hide_preview_children()
	if visual_controller != null:
		visual_controller.apply_class_visual(_current_class_id)
		visual_controller.apply_appearance(CharacterAppearanceData.from_dictionary(appearance, _current_class_id))
	else:
		_apply_visual_preset(_current_class_id)


func set_hud(target_hud: HUDController) -> void:
	hud = target_hud


func set_move_input(value: Vector2) -> void:
	move_input = value


func add_camera_input(relative: Vector2, is_touch: bool = false) -> void:
	var sensitivity: float = touch_camera_sensitivity if is_touch else mouse_camera_sensitivity
	target_camera_yaw -= relative.x * sensitivity
	target_camera_pitch = clampf(
		target_camera_pitch - relative.y * sensitivity,
		deg_to_rad(min_camera_pitch_degrees),
		deg_to_rad(max_camera_pitch_degrees)
	)
	time_since_camera_input = 0.0


func request_basic_attack() -> void:
	combat.try_basic_attack()


func request_skill(index: int) -> void:
	skills.trigger_skill(index)


func on_attack_performed() -> void:
	stats.last_combat_time = Time.get_ticks_msec() / 1000.0


func try_interact() -> void:
	var closest: Node3D = null
	var best_distance: float = 3.0
	for item in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(item):
			continue
		var distance: float = global_position.distance_to(item.global_position)
		if distance < best_distance:
			best_distance = distance
			closest = item
	if closest != null and closest.has_method("interact"):
		closest.interact(self)


func shadow_step() -> void:
	var step: Vector3 = -global_basis.z * 4.0
	global_position += step
	invisible_until = Time.get_ticks_msec() / 1000.0 + 2.0
	GameManager.show_message("Passo Sombrio.")


func activate_protection_aura() -> void:
	apply_temporary_modifier("protection_aura", {"defense_flat": 10.0}, 5.0)


func apply_temporary_modifier(modifier_name: String, payload: Dictionary, duration: float) -> void:
	active_timers[modifier_name] = payload
	_recalculate_stats()
	await get_tree().create_timer(duration).timeout
	if active_timers.has(modifier_name):
		active_timers.erase(modifier_name)
		_recalculate_stats()


func apply_environment_status(environment_type: String, payload: Dictionary = {}) -> void:
	var count: int = int(environmental_area_counts.get(environment_type, 0)) + 1
	environmental_area_counts[environment_type] = count
	match environment_type:
		"fire":
			if environmental_statuses.has("wet"):
				_shorten_environment_status("wet", float(payload.get("dry_on_fire", 1.2)))
			_upsert_environment_status("burning", {
				"remaining": float(payload.get("duration", 3.0)),
				"tick_interval": float(payload.get("tick_interval", 1.0)),
				"tick_timer": float(payload.get("tick_interval", 1.0)),
				"damage_per_tick": float(payload.get("damage_per_tick", 2.0))
			})
		"heat":
			if environmental_statuses.has("wet"):
				_shorten_environment_status("wet", float(payload.get("dry_near_fire", 0.8)))
		"water":
			_clear_environment_status("burning")
			_upsert_environment_status("wet", {"remaining": float(payload.get("duration", 4.0))})
			_apply_wet_physics()
		"swamp":
			_upsert_environment_status("slowed", {"remaining": -1.0, "slow_multiplier": float(payload.get("slow_multiplier", 0.6))})
			_apply_environment_slow(float(payload.get("slow_multiplier", 0.6)))
		"healing":
			_upsert_environment_status("regenerating", {
				"remaining": -1.0,
				"tick_interval": float(payload.get("tick_interval", 1.0)),
				"tick_timer": float(payload.get("tick_interval", 1.0)),
				"heal_per_tick": float(payload.get("heal_per_tick", 2.0))
			})
		"safe":
			_upsert_environment_status("safe", {"remaining": -1.0})
			_clear_environment_status("burning")
			_clear_environment_status("slowed")
			_clear_environment_slow()


func remove_environment_status(environment_type: String) -> void:
	var count: int = max(0, int(environmental_area_counts.get(environment_type, 0)) - 1)
	environmental_area_counts[environment_type] = count
	if count > 0:
		return
	match environment_type:
		"heat":
			pass
		"swamp":
			_clear_environment_status("slowed")
			_clear_environment_slow()
		"healing":
			_clear_environment_status("regenerating")
		"safe":
			_clear_environment_status("safe")


func spawn_skeleton_minion(duration: float) -> void:
	var scene: PackedScene = load("res://scenes/player/SkeletonMinion.tscn") as PackedScene
	var minion: Node3D = scene.instantiate() as Node3D
	minion.global_position = global_position + Vector3(1.2, 0.0, 0.8)
	minion.setup(self, duration)
	get_parent().add_child(minion)


func respawn_at(respawn_position: Vector3) -> void:
	global_position = respawn_position
	velocity = Vector3.ZERO
	is_dead = false
	_set_visuals_visible(true)
	stats.current_health = stats.max_health
	stats.current_mana = stats.max_mana
	stats.stats_changed.emit()


func _handle_mana_regen(delta: float) -> void:
	if not stats.in_combat():
		stats.restore_mana(delta * 3.0)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = -0.1
	else:
		velocity.y = 0.0
	_handle_jump()


func _handle_jump() -> void:
	if not is_on_floor():
		return
	if InputMap.has_action("jump") and Input.is_action_just_pressed("jump"):
		var jump_mult: float = wet_jump_multiplier if environmental_statuses.has("wet") else 1.0
		velocity.y = jump_velocity * jump_mult
		if visual_controller != null and visual_controller.has_method("play_jump_animation"):
			visual_controller.play_jump_animation()


func _handle_movement(delta: float) -> void:
	var input_dir: Vector2 = _get_movement_input()
	var direction: Vector3 = _input_to_world_direction(input_dir)
	var speed_mult: float = 1.0
	for modifier in active_timers.values():
		speed_mult *= float(modifier.get("speed_mult", 1.0))
	var target_speed: float = lerpf(walk_speed, run_speed, clampf(input_dir.length(), 0.0, 1.0)) * speed_mult
	if direction.length() > 0.05:
		var target_velocity: Vector3 = direction * target_speed
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
		var target_yaw: float = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(player_rotation_speed * delta, 0.0, 1.0))
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)


func _update_placeholder_walk_animation(delta: float) -> void:
	var animated_root: Node3D = visual_root
	if animated_root == null:
		animated_root = fallback_visual
	if animated_root == null:
		return

	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	_last_horizontal_speed = horizontal_velocity.length()
	_idle_anim_time += delta

	var is_moving: bool = _last_horizontal_speed > 0.12 and is_on_floor()
	var move_ratio: float = clampf(_last_horizontal_speed / maxf(run_speed, 0.01), 0.0, 1.0)
	var bob_target: float = 0.0
	var root_tilt_target: float = 0.0

	if is_moving:
		var anim_speed: float = lerpf(5.4, 10.2, move_ratio)
		var leg_amp: float = lerpf(0.65, 1.05, move_ratio)
		var arm_amp: float = lerpf(0.45, 0.75, move_ratio)
		_walk_anim_phase += delta * anim_speed
		var step_a: float = sin(_walk_anim_phase)
		var step_b: float = sin(_walk_anim_phase + PI)
		bob_target = abs(step_a) * lerpf(0.028, 0.065, move_ratio)
		root_tilt_target = lerpf(-0.03, -0.09, move_ratio)
		_apply_limb_rot_x(left_leg, step_a * leg_amp, delta)
		_apply_limb_rot_x(right_leg, step_b * leg_amp, delta)
		_apply_limb_rot_x(left_arm, step_b * arm_amp, delta)
		_apply_limb_rot_x(right_arm, step_a * arm_amp, delta)
	else:
		_walk_anim_phase = 0.0
		for limb in [left_leg, right_leg, left_arm, right_arm]:
			_apply_limb_rot_x(limb, 0.0, delta)

	var breathing: float = sin(_idle_anim_time * 1.8) * 0.018
	animated_root.position = animated_root.position.lerp(_visual_base_position + Vector3(0.0, bob_target + breathing, 0.0), clampf(delta * 10.0, 0.0, 1.0))
	animated_root.rotation.x = lerpf(animated_root.rotation.x, root_tilt_target, clampf(delta * 8.0, 0.0, 1.0))
	animated_root.rotation.y = lerpf(animated_root.rotation.y, sin(_idle_anim_time * 0.9) * 0.02, clampf(delta * 4.0, 0.0, 1.0))

	if body_mesh != null:
		body_mesh.position = body_mesh.position.lerp(_get_base_position(body_mesh) + Vector3(0.0, breathing * 0.15, 0.0), clampf(delta * 8.0, 0.0, 1.0))
	if head_mesh != null:
		head_mesh.position = head_mesh.position.lerp(_get_base_position(head_mesh) + Vector3(0.0, breathing * 0.3, sin(_idle_anim_time * 1.2) * 0.01), clampf(delta * 8.0, 0.0, 1.0))
		head_mesh.rotation.y = lerpf(head_mesh.rotation.y, sin(_idle_anim_time * 0.8) * 0.08, clampf(delta * 5.0, 0.0, 1.0))
	if cape_mesh != null and cape_mesh.visible:
		cape_mesh.rotation.x = lerpf(cape_mesh.rotation.x, deg_to_rad(8.0) + sin(_idle_anim_time * 2.2 + _walk_anim_phase) * lerpf(0.06, 0.18, move_ratio), clampf(delta * 7.0, 0.0, 1.0))
	if weapon_placeholder != null:
		var weapon_base_rotation: Vector3 = _base_rotations.get(weapon_placeholder.get_path(), weapon_placeholder.rotation)
		weapon_placeholder.rotation.z = lerpf(weapon_placeholder.rotation.z, weapon_base_rotation.z + sin(_walk_anim_phase + 0.6) * lerpf(0.03, 0.12, move_ratio), clampf(delta * 7.0, 0.0, 1.0))
		weapon_placeholder.position = weapon_placeholder.position.lerp(_get_base_position(weapon_placeholder) + Vector3(0.0, bob_target * 0.35, 0.0), clampf(delta * 7.0, 0.0, 1.0))
	if aura_root != null:
		aura_root.rotation.y += delta * 0.85
	if floor_aura != null and floor_aura.visible:
		floor_aura.scale = Vector3.ONE * (0.9 + sin(_idle_anim_time * 2.6) * 0.08)
	if left_hand_glow != null and left_hand_glow.visible:
		left_hand_glow.scale = Vector3.ONE * (1.0 + sin(_idle_anim_time * 4.0) * 0.12)
	if right_hand_glow != null and right_hand_glow.visible:
		right_hand_glow.scale = Vector3.ONE * (1.0 + sin(_idle_anim_time * 4.0 + 1.2) * 0.12)


func _setup_visual_root() -> void:
	if visual_root != null:
		visual_root.position = Vector3.ZERO
		_visual_base_position = visual_root.position
	elif fallback_visual != null:
		fallback_visual.position.y = maxf(fallback_visual.position.y, 1.05)
		_visual_base_position = fallback_visual.position
	elif mesh != null:
		_visual_base_position = mesh.position
	_capture_visual_defaults()


func _setup_environment_visuals() -> void:
	_visual_meshes.clear()
	_normal_material_overrides.clear()
	if visual_root != null:
		_collect_visual_meshes(visual_root)
	elif fallback_visual != null:
		_visual_meshes.append(fallback_visual)
	_cache_current_visual_materials()

	_burn_material = _make_material(Color(1.0, 0.28, 0.06, 1.0), Color(1.0, 0.18, 0.02, 1.0), 0.65)
	_wet_material = _make_material(Color(0.35, 0.58, 1.0, 1.0))
	_wet_material.roughness = 0.18


func _collect_visual_meshes(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			var child_mesh: MeshInstance3D = child as MeshInstance3D
			if child_mesh.name != "BurningEffect" and child_mesh.name != "WetEffect":
				_visual_meshes.append(child_mesh)
		_collect_visual_meshes(child)


func _cache_current_visual_materials() -> void:
	_normal_material_overrides.clear()
	for visual_mesh in _visual_meshes:
		_normal_material_overrides[visual_mesh.get_path()] = visual_mesh.material_override


func _update_environment_visuals() -> void:
	var is_burning: bool = environmental_statuses.has("burning")
	var is_wet: bool = environmental_statuses.has("wet")
	if visual_controller != null:
		visual_controller.apply_environment_visual_status("burning", is_burning)
		visual_controller.apply_environment_visual_status("wet", is_wet and not is_burning)
	if burning_effect != null:
		burning_effect.visible = is_burning
	if wet_effect != null:
		wet_effect.visible = is_wet and not is_burning

	var target_material: Material = null
	if is_burning:
		target_material = _burn_material
	elif is_wet:
		target_material = _wet_material

	for visual_mesh in _visual_meshes:
		if target_material != null:
			visual_mesh.material_override = target_material
		elif _normal_material_overrides.has(visual_mesh.get_path()):
			visual_mesh.material_override = _normal_material_overrides[visual_mesh.get_path()]


func _set_visuals_visible(is_visible: bool) -> void:
	if visual_root != null:
		visual_root.visible = is_visible
	if fallback_visual != null:
		fallback_visual.visible = is_visible
	for visual_mesh in _visual_meshes:
		if visual_mesh != null:
			visual_mesh.visible = is_visible


func _recalculate_stats() -> void:
	var preserved_health: float = stats.current_health
	var preserved_mana: float = stats.current_mana
	stats.max_health = float(base_stats.get("max_health", stats.max_health))
	stats.max_mana = float(base_stats.get("max_mana", stats.max_mana))
	stats.strength = float(base_stats.get("strength", stats.strength))
	stats.defense = float(base_stats.get("defense", stats.defense))
	stats.intelligence = float(base_stats.get("intelligence", stats.intelligence))
	stats.luck = float(base_stats.get("luck", stats.luck))
	for modifier in active_timers.values():
		stats.defense += float(modifier.get("defense_flat", 0.0))
		stats.strength *= float(modifier.get("strength_mult", 1.0))
		stats.defense *= float(modifier.get("defense_mult", 1.0))
	stats.current_health = minf(preserved_health, stats.max_health)
	stats.current_mana = minf(preserved_mana, stats.max_mana)
	stats.stats_changed.emit()


func _on_died() -> void:
	is_dead = true
	velocity = Vector3.ZERO
	_set_visuals_visible(false)
	GameManager.handle_player_death()


func _on_damaged(_amount: float) -> void:
	stats.last_combat_time = Time.get_ticks_msec() / 1000.0


func _update_environmental_statuses(delta: float) -> void:
	if environmental_statuses.is_empty():
		return
	var expired: Array[String] = []
	for status_name in environmental_statuses.keys():
		var data: Dictionary = environmental_statuses[status_name]
		var remaining: float = float(data.get("remaining", 0.0))
		if remaining > 0.0:
			remaining -= delta
			if status_name == "wet":
				remaining -= _get_wet_extra_dry_rate() * delta
			data["remaining"] = remaining
		var tick_interval: float = float(data.get("tick_interval", 0.0))
		if tick_interval > 0.0:
			var tick_timer: float = float(data.get("tick_timer", tick_interval)) - delta
			while tick_timer <= 0.0:
				tick_timer += tick_interval
				_process_environment_tick(status_name, data)
			data["tick_timer"] = tick_timer
		environmental_statuses[status_name] = data
		if remaining <= 0.0 and float(data.get("remaining", 0.0)) >= 0.0:
			expired.append(status_name)
	for status_name in expired:
		_clear_environment_status(status_name)


func _process_environment_tick(status_name: String, data: Dictionary) -> void:
	match status_name:
		"burning":
			stats.receive_damage(float(data.get("damage_per_tick", 2.0)))
		"regenerating":
			stats.heal(float(data.get("heal_per_tick", 2.0)))


func _upsert_environment_status(status_name: String, data: Dictionary) -> void:
	var existing: Dictionary = environmental_statuses.get(status_name, {})
	var merged: Dictionary = existing.duplicate()
	for key in data.keys():
		merged[key] = data[key]
	if not merged.has("remaining"):
		merged["remaining"] = -1.0
	environmental_statuses[status_name] = merged
	print("[Status] ", status_name.capitalize(), " applied")
	_update_environment_visuals()


func _clear_environment_status(status_name: String) -> void:
	if not environmental_statuses.has(status_name):
		return
	environmental_statuses.erase(status_name)
	if status_name == "wet":
		_clear_wet_physics()
	print("[Status] ", status_name.capitalize(), " removed")
	_update_environment_visuals()


func _apply_environment_slow(multiplier: float) -> void:
	active_timers["environment_slowed"] = {"speed_mult": multiplier}
	print("[Status] Slowed applied multiplier=", multiplier)


func _clear_environment_slow() -> void:
	if active_timers.has("environment_slowed"):
		active_timers.erase("environment_slowed")
		print("[Status] Slowed removed")


func _apply_wet_physics() -> void:
	active_timers["environment_wet"] = {"speed_mult": wet_speed_multiplier}
	print("[Status] Wet physics applied multiplier=", wet_speed_multiplier)


func _clear_wet_physics() -> void:
	if active_timers.has("environment_wet"):
		active_timers.erase("environment_wet")
		print("[Status] Wet physics removed")


func _shorten_environment_status(status_name: String, amount: float) -> void:
	if not environmental_statuses.has(status_name):
		return
	var data: Dictionary = environmental_statuses[status_name]
	var remaining: float = float(data.get("remaining", 0.0))
	if remaining < 0.0:
		return
	data["remaining"] = maxf(0.0, remaining - amount)
	environmental_statuses[status_name] = data
	print("[Status] ", status_name.capitalize(), " drying amount=", amount)


func _get_wet_extra_dry_rate() -> float:
	if int(environmental_area_counts.get("fire", 0)) > 0:
		return fire_wet_dry_rate
	if int(environmental_area_counts.get("heat", 0)) > 0:
		return heat_wet_dry_rate
	return 0.0


func _vector3_from_array(values: Array) -> Vector3:
	if values.size() < 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _to_string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(values) != TYPE_ARRAY:
		return result
	for value in values:
		result.append(str(value))
	return result


func _get_movement_input() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	if input_vector == Vector2.ZERO:
		input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	var mobile_controls: Node = get_tree().get_first_node_in_group("mobile_controls")
	if mobile_controls != null and mobile_controls.has_method("get_move_vector"):
		var mobile_value: Variant = mobile_controls.call("get_move_vector")
		if mobile_value is Vector2:
			var mobile_vector: Vector2 = mobile_value
			if mobile_vector.length() > 0.05:
				input_vector = mobile_vector
		_missing_mobile_controls_logged = false
	elif move_input.length() > 0.05:
		input_vector = move_input
	elif not _missing_mobile_controls_logged:
		print("[PlayerController] mobile_controls not found")
		_missing_mobile_controls_logged = true

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	return input_vector


func _input_to_world_direction(input_vector: Vector2) -> Vector3:
	if input_vector.length() < 0.05:
		return Vector3.ZERO
	var forward: Vector3 = Vector3(-sin(camera_yaw), 0.0, -cos(camera_yaw))
	var right: Vector3 = Vector3(cos(camera_yaw), 0.0, -sin(camera_yaw))
	var direction: Vector3 = (right * input_vector.x) + (forward * -input_vector.y)
	if direction.length() < 0.05:
		return Vector3.ZERO
	return direction.normalized()


func _update_camera_pivot() -> void:
	if camera_pivot == null:
		return
	camera_pivot.rotation.y = camera_yaw
	camera_pivot.rotation.x = camera_pitch


func _apply_mobile_camera_joystick(delta: float) -> void:
	var mobile_controls: Node = get_tree().get_first_node_in_group("mobile_controls")
	if mobile_controls == null or not mobile_controls.has_method("get_camera_vector"):
		return
	var value: Variant = mobile_controls.call("get_camera_vector")
	if not (value is Vector2):
		return
	var camera_vector: Vector2 = value
	if camera_vector.length() < mobile_camera_deadzone:
		return
	target_camera_yaw -= camera_vector.x * mobile_camera_yaw_speed * delta
	target_camera_pitch -= camera_vector.y * mobile_camera_pitch_speed * delta
	target_camera_pitch = clampf(target_camera_pitch, deg_to_rad(min_camera_pitch_degrees), deg_to_rad(max_camera_pitch_degrees))
	time_since_camera_input = 0.0


func _update_camera_rotation(delta: float) -> void:
	var weight: float = clampf(camera_smoothing * delta, 0.0, 1.0)
	camera_yaw = lerp_angle(camera_yaw, target_camera_yaw, weight)
	camera_pitch = lerpf(camera_pitch, target_camera_pitch, weight)
	if camera_pivot != null:
		camera_pivot.rotation.y = camera_yaw
		camera_pivot.rotation.x = camera_pitch
	if camera != null:
		camera.current = true
		camera.make_current()
		var target: Vector3 = global_position + Vector3.UP * camera_orbit_target_height
		var pitch_for_position: float = -camera_pitch
		var horizontal_distance: float = cos(pitch_for_position) * camera_orbit_distance
		var vertical_offset: float = sin(pitch_for_position) * camera_orbit_distance
		var offset: Vector3 = Vector3(
			sin(camera_yaw) * horizontal_distance,
			vertical_offset,
			cos(camera_yaw) * horizontal_distance
		)
		camera.global_position = target + offset
		camera.look_at(target, Vector3.UP)


func _apply_auto_camera_follow(delta: float) -> void:
	var is_moving: bool = _get_movement_input().length() > 0.05
	if not is_moving or time_since_camera_input < auto_camera_delay:
		return
	target_camera_yaw = lerp_angle(target_camera_yaw, rotation.y, clampf(auto_camera_follow_speed * delta, 0.0, 1.0))


func _apply_initial_class_visual() -> void:
	var resolved_class_id: String = "necromancer"
	if not GameManager.get_player_state().is_empty():
		resolved_class_id = str(GameManager.get_player_state().get("class_id", "necromancer"))
	elif not String(GameManager.selected_class_id).is_empty():
		resolved_class_id = String(GameManager.selected_class_id)
	elif not class_id.is_empty():
		resolved_class_id = class_id
	apply_class_visual(resolved_class_id)


func _resolve_class_id(candidate: String) -> String:
	var normalized: String = candidate.strip_edges().to_lower()
	if CLASS_VISUAL_PRESETS.has(normalized):
		return normalized
	match normalized:
		"necromante":
			return "necromancer"
		"assassino":
			return "assassin"
		"guerreiro":
			return "warrior"
		"arqueiro":
			return "archer"
		"mago":
			return "mage"
		"druida":
			return "druid"
		"clerigo", "clérigo":
			return "cleric"
		"paladino":
			return "paladin"
	return "necromancer"


func _apply_visual_preset(resolved_class_id: String) -> void:
	if visual_root == null:
		return
	var preset: Dictionary = CLASS_VISUAL_PRESETS.get(resolved_class_id, CLASS_VISUAL_PRESETS["necromancer"])
	var body_scale: Vector3 = preset.get("body_scale", Vector3.ONE)
	var arm_scale: Vector3 = preset.get("arm_scale", Vector3.ONE)
	var leg_scale: Vector3 = preset.get("leg_scale", Vector3.ONE)
	var head_scale: Vector3 = preset.get("head_scale", Vector3.ONE)
	var leg_y: float = (LEG_BASE_TOTAL_HEIGHT * leg_scale.y * 0.5) + FOOT_CLEARANCE
	var body_y: float = leg_y + BODY_VERTICAL_OFFSET
	var head_y: float = body_y + HEAD_VERTICAL_OFFSET
	var arm_y: float = body_y + float(preset.get("arm_y_offset", 0.0))
	var arm_side: float = float(preset.get("arm_side", 0.42))
	var leg_side: float = float(preset.get("leg_side", 0.16))
	var shoulder_y: float = body_y + 0.24
	var weapon_y: float = body_y - 0.04
	_set_visuals_visible(true)
	_body_material = _make_material(preset.get("body", Color.WHITE))
	_skin_material = _make_material(preset.get("skin", Color.WHITE))
	_limb_material = _make_material(preset.get("limb", Color.WHITE))
	_hair_material = _make_material(preset.get("hair", Color.WHITE))
	_cape_material = _make_material(preset.get("cape_color", Color.WHITE))
	_weapon_material = _make_material(preset.get("weapon", Color.WHITE))
	_weapon_accent_material = _make_material(preset.get("accent", Color.WHITE), preset.get("accent", Color.WHITE), 0.15)
	_aura_material = _make_material(preset.get("aura", Color.WHITE), preset.get("aura", Color.WHITE), 1.0)

	if body_mesh != null:
		body_mesh.visible = true
		body_mesh.material_override = _body_material
		body_mesh.scale = body_scale
		body_mesh.position = Vector3(0.0, body_y, 0.0)
	if head_mesh != null:
		head_mesh.visible = true
		head_mesh.material_override = _skin_material
		head_mesh.scale = head_scale
		head_mesh.position = Vector3(0.0, head_y, 0.0)
	if left_arm != null:
		left_arm.visible = true
		left_arm.material_override = _limb_material
		left_arm.scale = arm_scale
		left_arm.position = Vector3(-arm_side, arm_y, 0.0)
	if right_arm != null:
		right_arm.visible = true
		right_arm.material_override = _limb_material
		right_arm.scale = arm_scale
		right_arm.position = Vector3(arm_side, arm_y, 0.0)
	if left_leg != null:
		left_leg.visible = true
		left_leg.material_override = _limb_material
		left_leg.scale = leg_scale
		left_leg.position = Vector3(-leg_side, leg_y, 0.0)
	if right_leg != null:
		right_leg.visible = true
		right_leg.material_override = _limb_material
		right_leg.scale = leg_scale
		right_leg.position = Vector3(leg_side, leg_y, 0.0)
	if chest_armor != null:
		chest_armor.visible = bool(preset.get("show_armor", true))
		chest_armor.material_override = _weapon_accent_material
		chest_armor.scale = Vector3(body_scale.x * 0.94, body_scale.y * 0.92, body_scale.z * 1.05)
		chest_armor.position = Vector3(0.0, body_y + 0.02, 0.06)
	if left_shoulder != null:
		left_shoulder.visible = bool(preset.get("show_shoulders", false))
		left_shoulder.material_override = _weapon_accent_material
		left_shoulder.position = Vector3(-(arm_side - 0.02), shoulder_y, 0.0)
		left_shoulder.scale = Vector3(0.95, 0.9, 0.95)
	if right_shoulder != null:
		right_shoulder.visible = bool(preset.get("show_shoulders", false))
		right_shoulder.material_override = _weapon_accent_material
		right_shoulder.position = Vector3(arm_side - 0.02, shoulder_y, 0.0)
		right_shoulder.scale = Vector3(0.95, 0.9, 0.95)
	if hair_mesh != null:
		hair_mesh.visible = bool(preset.get("show_hair", true)) and not bool(preset.get("show_hood", false)) and not bool(preset.get("show_helmet", false))
		hair_mesh.material_override = _hair_material
		hair_mesh.position = Vector3(0.0, head_y + 0.08, -0.03)
	if hood_mesh != null:
		hood_mesh.visible = bool(preset.get("show_hood", false))
		hood_mesh.material_override = _cape_material
		hood_mesh.position = Vector3(0.0, head_y + 0.02, -0.04)
		hood_mesh.scale = Vector3(1.0, 1.0, 1.0)
	if helmet_mesh != null:
		helmet_mesh.visible = bool(preset.get("show_helmet", false))
		helmet_mesh.material_override = _weapon_accent_material
		helmet_mesh.position = Vector3(0.0, head_y + 0.05, 0.0)
	if cape_mesh != null:
		cape_mesh.visible = bool(preset.get("show_cape", false))
		cape_mesh.material_override = _cape_material
		cape_mesh.position = Vector3(0.0, body_y - 0.06, -0.20)
	if weapon_placeholder != null:
		weapon_placeholder.position = Vector3(0.55, weapon_y, 0.12)
		weapon_placeholder.rotation_degrees = Vector3(0.0, 0.0, float(preset.get("weapon_tilt", -20.0)))

	_apply_weapon_visuals(str(preset.get("weapon_type", "staff")), str(preset.get("offhand", "none")), float(preset.get("weapon_tilt", -20.0)))
	_apply_aura_visuals(str(preset.get("aura_mode", "core")))
	_capture_visual_defaults()
	_cache_current_visual_materials()


func _apply_weapon_visuals(weapon_type: String, offhand_type: String, weapon_tilt: float) -> void:
	if weapon_placeholder != null:
		weapon_placeholder.rotation_degrees = Vector3(0.0, 0.0, weapon_tilt)
	if weapon_main != null:
		weapon_main.material_override = _weapon_material
	if weapon_tip != null:
		weapon_tip.material_override = _weapon_accent_material
		weapon_tip.visible = true
	if weapon_offhand != null:
		weapon_offhand.material_override = _weapon_accent_material
		weapon_offhand.visible = offhand_type != "none"

	match weapon_type:
		"staff":
			if weapon_main != null:
				weapon_main.mesh = _make_cylinder_mesh(0.05, 0.06, 1.32)
				weapon_main.scale = Vector3(0.28, 1.55, 0.28)
				weapon_main.position = Vector3(0.0, 0.52, 0.0)
			if weapon_tip != null:
				weapon_tip.mesh = _make_sphere_mesh(0.11)
				weapon_tip.position = Vector3(0.0, 1.18, 0.0)
				weapon_tip.scale = Vector3(1.0, 1.0, 1.0)
		"sword":
			if weapon_main != null:
				weapon_main.mesh = _make_box_mesh(Vector3(0.18, 1.20, 0.10))
				weapon_main.scale = Vector3(0.42, 1.35, 0.18)
				weapon_main.position = Vector3(0.0, 0.40, 0.0)
			if weapon_tip != null:
				weapon_tip.mesh = _make_box_mesh(Vector3(0.34, 0.12, 0.14))
				weapon_tip.position = Vector3(0.0, 0.98, 0.0)
				weapon_tip.scale = Vector3(0.55, 1.55, 0.30)
		"dagger":
			if weapon_main != null:
				weapon_main.mesh = _make_box_mesh(Vector3(0.16, 0.66, 0.10))
				weapon_main.scale = Vector3(0.24, 0.62, 0.16)
				weapon_main.position = Vector3(0.0, 0.20, 0.0)
			if weapon_tip != null:
				weapon_tip.mesh = _make_box_mesh(Vector3(0.24, 0.12, 0.12))
				weapon_tip.position = Vector3(0.0, 0.44, 0.0)
				weapon_tip.scale = Vector3(0.36, 0.82, 0.22)
		"bow":
			if weapon_main != null:
				weapon_main.mesh = _make_torus_mesh(0.12, 0.52)
				weapon_main.scale = Vector3(0.85, 1.30, 0.18)
				weapon_main.position = Vector3(0.0, 0.36, 0.0)
			if weapon_tip != null:
				weapon_tip.mesh = _make_box_mesh(Vector3(0.08, 1.10, 0.08))
				weapon_tip.position = Vector3(0.0, 0.0, 0.0)
				weapon_tip.scale = Vector3(1.12, 2.55, 0.24)
		"axe":
			if weapon_main != null:
				weapon_main.mesh = _make_cylinder_mesh(0.05, 0.06, 1.12)
				weapon_main.scale = Vector3(0.26, 1.32, 0.26)
				weapon_main.position = Vector3(0.0, 0.38, 0.0)
			if weapon_tip != null:
				weapon_tip.mesh = _make_box_mesh(Vector3(0.56, 0.32, 0.12))
				weapon_tip.position = Vector3(0.20, 0.84, 0.0)
				weapon_tip.scale = Vector3(1.10, 1.30, 0.36)
		_:
			if weapon_tip != null:
				weapon_tip.visible = false

	if weapon_offhand != null:
		match offhand_type:
			"shield":
				weapon_offhand.mesh = _make_box_mesh(Vector3(0.42, 0.62, 0.10))
				weapon_offhand.scale = Vector3(1.18, 1.32, 0.36)
				weapon_offhand.position = Vector3(-0.92, 0.08, 0.05)
			"book":
				weapon_offhand.mesh = _make_box_mesh(Vector3(0.26, 0.30, 0.16))
				weapon_offhand.scale = Vector3(0.58, 0.82, 0.34)
				weapon_offhand.position = Vector3(-0.82, 0.14, 0.06)
			"dagger":
				weapon_offhand.mesh = _make_box_mesh(Vector3(0.14, 0.52, 0.08))
				weapon_offhand.scale = Vector3(0.26, 0.72, 0.18)
				weapon_offhand.position = Vector3(-0.74, -0.02, 0.06)
			_:
				weapon_offhand.visible = false


func _apply_aura_visuals(aura_mode: String) -> void:
	for aura_mesh in [aura_core, left_hand_glow, right_hand_glow, floor_aura]:
		if aura_mesh != null:
			aura_mesh.material_override = _aura_material
			aura_mesh.visible = false
	match aura_mode:
		"hands":
			if left_hand_glow != null:
				left_hand_glow.visible = true
			if right_hand_glow != null:
				right_hand_glow.visible = true
		"floor":
			if floor_aura != null:
				floor_aura.visible = true
		"all":
			if aura_core != null:
				aura_core.visible = true
			if left_hand_glow != null:
				left_hand_glow.visible = true
			if right_hand_glow != null:
				right_hand_glow.visible = true
			if floor_aura != null:
				floor_aura.visible = true
		_:
			if aura_core != null:
				aura_core.visible = true


func _make_material(color: Color, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material


func _make_box_mesh(size: Vector3) -> BoxMesh:
	var mesh_resource := BoxMesh.new()
	mesh_resource.size = size
	return mesh_resource


func _make_sphere_mesh(radius: float) -> SphereMesh:
	var mesh_resource := SphereMesh.new()
	mesh_resource.radius = radius
	mesh_resource.height = radius * 2.0
	return mesh_resource


func _make_cylinder_mesh(top_radius: float, bottom_radius: float, height: float) -> CylinderMesh:
	var mesh_resource := CylinderMesh.new()
	mesh_resource.top_radius = top_radius
	mesh_resource.bottom_radius = bottom_radius
	mesh_resource.height = height
	return mesh_resource


func _make_torus_mesh(inner_radius: float, outer_radius: float) -> TorusMesh:
	var mesh_resource := TorusMesh.new()
	mesh_resource.inner_radius = inner_radius
	mesh_resource.outer_radius = outer_radius
	mesh_resource.ring_sides = 10
	mesh_resource.rings = 20
	return mesh_resource


func _capture_visual_defaults() -> void:
	_base_positions.clear()
	_base_rotations.clear()
	for node in [body_mesh, head_mesh, left_arm, right_arm, left_leg, right_leg, chest_armor, left_shoulder, right_shoulder, hair_mesh, hood_mesh, helmet_mesh, cape_mesh, weapon_placeholder, aura_root]:
		if node != null:
			_base_positions[node.get_path()] = node.position
			_base_rotations[node.get_path()] = node.rotation


func _get_base_position(node: Node3D) -> Vector3:
	if node == null:
		return Vector3.ZERO
	return _base_positions.get(node.get_path(), node.position)


func _apply_limb_rot_x(limb: Node3D, target_x: float, delta: float) -> void:
	if limb == null:
		return
	var base_rotation: Vector3 = _base_rotations.get(limb.get_path(), limb.rotation)
	limb.rotation.x = lerpf(limb.rotation.x, base_rotation.x + target_x, clampf(delta * 10.0, 0.0, 1.0))


func _hide_preview_children() -> void:
	for child in get_children():
		if child is CharacterPreview3D:
			child.visible = false
