extends Node
class_name PlayerVisualController

# Fallback tecnico temporario. Nao e o visual final do jogo.
const PLACEHOLDER_SCENE := preload("res://scenes/player/visuals/PlaceholderHumanoid.tscn")
const MAGE_PROXY_SCENE := preload("res://scenes/player/visuals/MageProxyHumanoid.tscn")
const CLASS_MODEL_PATHS := {
	"necromancer": "res://assets/characters/classes/necromancer.glb",
	"assassin": "res://assets/characters/classes/assassin.glb",
	"warrior": "res://assets/characters/classes/warrior.glb",
	"archer": "res://assets/characters/classes/archer.glb",
	"mage": "res://assets/characters/classes/mage.glb",
	"berserker": "res://assets/characters/classes/berserker.glb",
	"druid": "res://assets/characters/classes/druid.glb",
	"cleric": "res://assets/characters/classes/cleric.glb",
	"paladin": "res://assets/characters/classes/paladin.glb"
}

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

@onready var character_model_root: Node3D = get_node_or_null("../CharacterModelRoot") as Node3D

var current_class_id: String = "necromancer"
var current_appearance: CharacterAppearanceData = CharacterAppearanceData.new()
var current_model: Node3D = null
var animation_player: AnimationPlayer = null
var using_placeholder_model: bool = true
var requested_speed: float = 0.0
var current_animation_name: String = ""
var walk_anim_phase: float = 0.0
var idle_anim_time: float = 0.0
var jump_anim_timer: float = 0.0
var jump_anim_duration: float = 0.36
var visual_base_position: Vector3 = Vector3.ZERO
var base_positions: Dictionary = {}
var base_rotations: Dictionary = {}
var normal_material_overrides: Dictionary = {}

var body_mesh: MeshInstance3D = null
var head_mesh: MeshInstance3D = null
var left_arm: MeshInstance3D = null
var right_arm: MeshInstance3D = null
var left_leg: MeshInstance3D = null
var right_leg: MeshInstance3D = null
var magic_aura_root: Node3D = null
var burning_effect: MeshInstance3D = null
var wet_effect: MeshInstance3D = null

var body_material: StandardMaterial3D = null
var skin_material: StandardMaterial3D = null
var limb_material: StandardMaterial3D = null


func _ready() -> void:
	current_appearance = CharacterAppearanceData.from_dictionary(GameManager.get_default_appearance(), current_class_id)
	set_process(true)


func _process(delta: float) -> void:
	idle_anim_time += delta
	jump_anim_timer = maxf(0.0, jump_anim_timer - delta)
	if using_placeholder_model:
		_play_placeholder_animation(delta)
	else:
		_apply_real_animation_state()


func apply_appearance(data: CharacterAppearanceData) -> void:
	current_appearance = data
	if current_class_id != _resolve_class_id(data.class_id):
		apply_class_visual(data.class_id)
		return
	if using_placeholder_model:
		_apply_fallback_visual_preset(current_class_id)


func apply_class_visual(class_id: String) -> void:
	current_class_id = _resolve_class_id(class_id)
	if current_appearance != null:
		current_appearance.class_id = current_class_id
	var loaded_model: Node3D = load_class_model(current_class_id)
	_swap_model(loaded_model)
	if current_model != null:
		_align_model_to_ground(current_model)
	_cache_runtime_nodes()
	if using_placeholder_model:
		_apply_fallback_visual_preset(current_class_id)


func load_class_model(class_id: String) -> Node3D:
	return _load_class_model(class_id)


func play_movement_animation(speed: float) -> void:
	requested_speed = speed
	if not using_placeholder_model:
		_apply_real_animation_state()


func play_jump_animation() -> void:
	jump_anim_timer = jump_anim_duration
	if not using_placeholder_model:
		_play_anim(["Jump", "jump", "JUMP"])


func apply_environment_visual_status(status: String, active: bool) -> void:
	match status:
		"burning":
			if burning_effect != null:
				burning_effect.visible = active
		"wet":
			if wet_effect != null:
				wet_effect.visible = active


func _load_class_model(class_id: String) -> Node3D:
	var path: String = str(CLASS_MODEL_PATHS.get(class_id, ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		var packed := load(path) as PackedScene
		if packed != null:
			using_placeholder_model = false
			return packed.instantiate() as Node3D
	using_placeholder_model = true
	if class_id == "mage":
		return MAGE_PROXY_SCENE.instantiate() as Node3D
	return PLACEHOLDER_SCENE.instantiate() as Node3D


func _swap_model(model: Node3D) -> void:
	if character_model_root == null:
		return
	for child in character_model_root.get_children():
		child.queue_free()
	character_model_root.add_child(model)
	current_model = model
	animation_player = _find_animation_player(model)
	current_animation_name = ""


func _cache_runtime_nodes() -> void:
	base_positions.clear()
	base_rotations.clear()
	normal_material_overrides.clear()
	body_mesh = _find_mesh("Body")
	head_mesh = _find_mesh("Head")
	left_arm = _find_mesh("LeftArm")
	right_arm = _find_mesh("RightArm")
	left_leg = _find_mesh("LeftLeg")
	right_leg = _find_mesh("RightLeg")
	magic_aura_root = _find_node3d("AuraRoot")
	burning_effect = _find_mesh("BurningEffect")
	wet_effect = _find_mesh("WetEffect")
	_ensure_runtime_status_effects()
	visual_base_position = current_model.position if current_model != null else Vector3.ZERO

	for node in [body_mesh, head_mesh, left_arm, right_arm, left_leg, right_leg]:
		if node != null:
			base_positions[node.get_path()] = node.position
			base_rotations[node.get_path()] = node.rotation

	for mesh_node in [body_mesh, head_mesh, left_arm, right_arm, left_leg, right_leg]:
		if mesh_node != null:
			normal_material_overrides[mesh_node.get_path()] = mesh_node.material_override


func _ensure_runtime_status_effects() -> void:
	if current_model == null:
		return
	if burning_effect == null:
		burning_effect = _create_status_effect_mesh(
			"BurningEffect",
			_make_status_capsule_mesh(0.46, 1.35),
			_make_status_material(Color(1.0, 0.22, 0.02, 0.42), Color(1.0, 0.12, 0.0), 1.55),
			Vector3(0.0, 0.92, 0.0)
		)
	if wet_effect == null:
		wet_effect = _create_status_effect_mesh(
			"WetEffect",
			_make_status_capsule_mesh(0.48, 1.32),
			_make_status_material(Color(0.20, 0.55, 1.0, 0.30), Color(0.08, 0.32, 0.75), 0.18),
			Vector3(0.0, 0.90, 0.0)
		)


func _create_status_effect_mesh(node_name: String, mesh_resource: Mesh, material: StandardMaterial3D, local_position: Vector3) -> MeshInstance3D:
	var effect := MeshInstance3D.new()
	effect.name = node_name
	effect.mesh = mesh_resource
	effect.material_override = material
	effect.position = local_position
	effect.visible = false
	effect.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	current_model.add_child(effect)
	return effect


func _make_status_capsule_mesh(radius: float, mid_height: float) -> CapsuleMesh:
	var mesh_resource := CapsuleMesh.new()
	mesh_resource.radius = radius
	mesh_resource.mid_height = mid_height
	return mesh_resource


func _make_status_material(color: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.emission_enabled = emission_energy > 0.0
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	material.roughness = 0.22
	return material


func _apply_fallback_visual_preset(class_id: String) -> void:
	var preset: Dictionary = CLASS_VISUAL_PRESETS.get(class_id, CLASS_VISUAL_PRESETS["necromancer"])
	var body_scale: Vector3 = preset.get("body_scale", Vector3.ONE)
	var arm_scale: Vector3 = preset.get("arm_scale", Vector3.ONE)
	var leg_scale: Vector3 = preset.get("leg_scale", Vector3.ONE)
	var head_scale: Vector3 = preset.get("head_scale", Vector3.ONE)
	var leg_y: float = (LEG_BASE_TOTAL_HEIGHT * leg_scale.y * 0.5) + FOOT_CLEARANCE
	var body_y: float = leg_y + BODY_VERTICAL_OFFSET
	var head_y: float = body_y + HEAD_VERTICAL_OFFSET
	var arm_y: float = body_y + float(preset.get("arm_y_offset", 0.0))
	var arm_side: float = float(preset.get("arm_side", 0.42))

	body_material = _make_material(preset.get("body", Color.WHITE))
	skin_material = _make_material(preset.get("skin", Color.WHITE))
	limb_material = _make_material(preset.get("limb", Color.WHITE))

	if body_mesh != null:
		body_mesh.material_override = body_material
		body_mesh.scale = body_scale
		body_mesh.position = Vector3(0.0, body_y, 0.0)
	if head_mesh != null:
		head_mesh.material_override = skin_material
		head_mesh.scale = head_scale
		head_mesh.position = Vector3(0.0, head_y, 0.0)
	if left_arm != null:
		left_arm.material_override = limb_material
		left_arm.scale = arm_scale
		left_arm.position = Vector3(-arm_side, arm_y, 0.0)
	if right_arm != null:
		right_arm.material_override = limb_material
		right_arm.scale = arm_scale
		right_arm.position = Vector3(arm_side, arm_y, 0.0)
	if left_leg != null:
		left_leg.material_override = limb_material
		left_leg.scale = leg_scale
		left_leg.position = Vector3(-0.16, leg_y, 0.0)
	if right_leg != null:
		right_leg.material_override = limb_material
		right_leg.scale = leg_scale
		right_leg.position = Vector3(0.16, leg_y, 0.0)
	_cache_runtime_nodes()


func _apply_real_animation_state() -> void:
	if animation_player == null:
		return
	if jump_anim_timer > 0.0:
		_play_anim(["Jump", "jump", "JUMP"])
		return
	if requested_speed < 0.1:
		_play_anim(["Idle", "idle", "IDLE"])
	elif requested_speed < 4.0:
		_play_anim(["Walk", "walk", "WALK"])
	else:
		_play_anim(["Run", "run", "RUN"])


func _play_placeholder_animation(delta: float) -> void:
	if current_model == null:
		return
	var move_ratio: float = clampf(requested_speed / 6.0, 0.0, 1.0)
	var is_moving: bool = requested_speed > 0.12
	var bob_target: float = 0.0
	var root_tilt_target: float = 0.0

	if is_moving:
		var anim_speed: float = lerpf(5.4, 10.2, move_ratio)
		var leg_amp: float = lerpf(0.65, 1.05, move_ratio)
		var arm_amp: float = lerpf(0.45, 0.75, move_ratio)
		walk_anim_phase += delta * anim_speed
		var step_a: float = sin(walk_anim_phase)
		var step_b: float = sin(walk_anim_phase + PI)
		bob_target = abs(step_a) * lerpf(0.028, 0.065, move_ratio)
		root_tilt_target = lerpf(-0.03, -0.09, move_ratio)
		_apply_limb_rot_x(left_leg, step_a * leg_amp, delta)
		_apply_limb_rot_x(right_leg, step_b * leg_amp, delta)
		_apply_limb_rot_x(left_arm, step_b * arm_amp, delta)
		_apply_limb_rot_x(right_arm, step_a * arm_amp, delta)
	else:
		walk_anim_phase = 0.0
		for limb in [left_leg, right_leg, left_arm, right_arm]:
			_apply_limb_rot_x(limb, 0.0, delta)

	var breathing: float = sin(idle_anim_time * 1.8) * 0.018
	var jump_progress: float = 1.0 - (jump_anim_timer / maxf(jump_anim_duration, 0.01))
	var jump_lift: float = sin(clampf(jump_progress, 0.0, 1.0) * PI) * 0.10 if jump_anim_timer > 0.0 else 0.0
	current_model.position = current_model.position.lerp(visual_base_position + Vector3(0.0, bob_target + breathing + jump_lift, 0.0), clampf(delta * 10.0, 0.0, 1.0))
	current_model.rotation.x = lerpf(current_model.rotation.x, root_tilt_target, clampf(delta * 8.0, 0.0, 1.0))
	current_model.rotation.y = lerpf(current_model.rotation.y, sin(idle_anim_time * 0.9) * 0.02, clampf(delta * 4.0, 0.0, 1.0))

	if head_mesh != null:
		head_mesh.position = head_mesh.position.lerp(_get_base_position(head_mesh) + Vector3(0.0, breathing * 0.3, sin(idle_anim_time * 1.2) * 0.01), clampf(delta * 8.0, 0.0, 1.0))
	if magic_aura_root != null:
		magic_aura_root.rotation.y += delta * 0.95
	if burning_effect != null and burning_effect.visible:
		burning_effect.rotation.y += delta * 5.0
		burning_effect.scale = Vector3.ONE * (1.0 + sin(idle_anim_time * 9.0) * 0.08)
	if wet_effect != null and wet_effect.visible:
		wet_effect.scale = Vector3.ONE * (1.0 + sin(idle_anim_time * 3.0) * 0.035)


func _align_model_to_ground(model: Node3D) -> void:
	var combined := _get_combined_aabb(model)
	if combined.size == Vector3.ZERO:
		return
	var min_y_global: float = combined.position.y
	model.position.y -= min_y_global - model.global_position.y


func _get_combined_aabb(root: Node3D) -> AABB:
	var found: bool = false
	var combined := AABB()
	for child in _find_mesh_nodes(root):
		if child.mesh == null:
			continue
		if _is_alignment_helper_mesh(child):
			continue
		var mesh_aabb: AABB = child.mesh.get_aabb()
		var global_aabb: AABB = child.global_transform * mesh_aabb
		if not found:
			combined = global_aabb
			found = true
		else:
			combined = combined.merge(global_aabb)
	return combined


func _is_alignment_helper_mesh(mesh_node: MeshInstance3D) -> bool:
	if not mesh_node.visible:
		return true
	var node_name: String = String(mesh_node.name)
	if node_name == "BurningEffect" or node_name == "WetEffect":
		return true
	if node_name.begins_with("Aura") or node_name == "FloorAura":
		return true
	var parent_node: Node = mesh_node.get_parent()
	while parent_node != null:
		if String(parent_node.name) == "AuraRoot":
			return true
		parent_node = parent_node.get_parent()
	return false


func _find_mesh_nodes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child in root.get_children():
		if child is MeshInstance3D:
			result.append(child as MeshInstance3D)
		result.append_array(_find_mesh_nodes(child))
	return result


func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for child in root.get_children():
		var found: AnimationPlayer = _find_animation_player(child)
		if found != null:
			return found
	return null


func _find_node_recursive(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		var found: Node = _find_node_recursive(child, target_name)
		if found != null:
			return found
	return null


func _find_mesh(name: String) -> MeshInstance3D:
	return _find_node_recursive(current_model, name) as MeshInstance3D


func _find_node3d(name: String) -> Node3D:
	return _find_node_recursive(current_model, name) as Node3D


func _play_anim(candidates: Array[String]) -> void:
	if animation_player == null:
		return
	for candidate in candidates:
		if animation_player.has_animation(candidate):
			if current_animation_name != candidate:
				animation_player.play(candidate)
				current_animation_name = candidate
			return


func _get_base_position(node: Node3D) -> Vector3:
	if node == null:
		return Vector3.ZERO
	return base_positions.get(node.get_path(), node.position)


func _apply_limb_rot_x(limb: Node3D, target_x: float, delta: float) -> void:
	if limb == null:
		return
	var base_rotation: Vector3 = base_rotations.get(limb.get_path(), limb.rotation)
	limb.rotation.x = lerpf(limb.rotation.x, base_rotation.x + target_x, clampf(delta * 10.0, 0.0, 1.0))


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
