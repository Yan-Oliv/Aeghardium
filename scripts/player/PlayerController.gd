extends CharacterBody3D
class_name PlayerController

@export var walk_speed: float = 4.2
@export var run_speed: float = 6.0
@export var acceleration: float = 12.0
@export var player_rotation_speed: float = 6.5
@export var gravity: float = 22.0
@export var mouse_camera_sensitivity: float = 0.0010
@export var touch_camera_sensitivity: float = 0.00055
@export var camera_smoothing: float = 8.0

@onready var stats: PlayerStats = $Stats
@onready var combat: PlayerCombat = $Combat
@onready var skills: SkillController = $Skills
@onready var mesh: MeshInstance3D = $Visual
@onready var pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

var hud: HUDController = null
var class_id: String = "warrior"
var player_name: String = "Desperto"
var move_input: Vector2 = Vector2.ZERO
var camera_pitch: float = -0.35
var camera_yaw: float = 0.0
var target_camera_pitch: float = -0.35
var target_camera_yaw: float = 0.0
var is_dead: bool = false
var invisible_until: float = 0.0
var active_timers: Dictionary = {}
var base_stats: Dictionary = {}
var spawn_position: Vector3 = Vector3.ZERO
var appearance: Dictionary = {}
var _missing_mobile_controls_logged: bool = false
var _last_logged_mobile_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	combat.setup(self)
	stats.died.connect(_on_died)
	stats.damaged.connect(_on_damaged)
	if not is_in_group("player_controller"):
		add_to_group("player_controller")
	target_camera_pitch = camera_pitch
	target_camera_yaw = camera_yaw
	_update_camera_pivot()


func _process(delta: float) -> void:
	var weight: float = clampf(camera_smoothing * delta, 0.0, 1.0)
	camera_yaw = lerp_angle(camera_yaw, target_camera_yaw, weight)
	camera_pitch = lerpf(camera_pitch, target_camera_pitch, weight)
	_update_camera_pivot()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_handle_mana_regen(delta)
	_apply_gravity(delta)
	_handle_movement(delta)
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


func load_from_save(data: Dictionary) -> void:
	class_id = str(data.get("class_id", "warrior"))
	player_name = str(data.get("player_name", "Desperto"))
	appearance = GameManager.normalize_appearance(data.get("appearance", {}))
	var class_info: Dictionary = ClassData.get_class_data(class_id)
	stats.configure_from_class(class_info)
	var snapshot: Dictionary = data.get("stats", {})
	stats.load_snapshot(snapshot)
	base_stats = stats.to_dictionary()
	skills.setup(self, _to_string_array(class_info.get("skills", [])))
	var saved_position: Array = data.get("position", [0.0, 0.5, 0.0])
	global_position = _vector3_from_array(saved_position)
	spawn_position = global_position


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


func set_hud(target_hud: HUDController) -> void:
	hud = target_hud


func set_move_input(value: Vector2) -> void:
	move_input = value


func add_camera_input(relative: Vector2, is_touch_input: bool = false) -> void:
	var sensitivity: float = touch_camera_sensitivity if is_touch_input else mouse_camera_sensitivity
	target_camera_yaw -= relative.x * sensitivity
	target_camera_pitch = clampf(
		target_camera_pitch - relative.y * sensitivity,
		deg_to_rad(-35.0),
		deg_to_rad(55.0)
	)


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
	mesh.visible = true
	stats.current_health = stats.max_health
	stats.current_mana = stats.max_mana
	stats.stats_changed.emit()


func _handle_mana_regen(delta: float) -> void:
	if not stats.in_combat():
		stats.restore_mana(delta * 3.0)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0


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
	mesh.visible = false
	GameManager.handle_player_death()


func _on_damaged(_amount: float) -> void:
	stats.last_combat_time = Time.get_ticks_msec() / 1000.0


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
				if _last_logged_mobile_vector.distance_to(mobile_vector) >= 0.15:
					print("[PlayerController] mobile_vector=", mobile_vector)
					_last_logged_mobile_vector = mobile_vector
				input_vector = mobile_vector
			elif _last_logged_mobile_vector != Vector2.ZERO:
				print("[PlayerController] mobile_vector=", mobile_vector)
				_last_logged_mobile_vector = Vector2.ZERO
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

	var forward: Vector3 = -global_transform.basis.z
	var right: Vector3 = global_transform.basis.x
	if pivot != null:
		forward = -pivot.global_transform.basis.z
		right = pivot.global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()

	var direction: Vector3 = (right * input_vector.x) + (forward * -input_vector.y)
	return direction.normalized()


func _update_camera_pivot() -> void:
	if pivot == null:
		return
	pivot.rotation = Vector3(camera_pitch, camera_yaw, 0.0)
