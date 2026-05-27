extends Node3D
class_name CharacterPreview3D

@export var default_class_id: String = "warrior"
@export var idle_spin_speed: float = 0.35
@export var aura_pulse_speed: float = 2.1

@onready var preview_sun: DirectionalLight3D = $PreviewSun
@onready var preview_fill: OmniLight3D = $PreviewFill
@onready var preview_camera: Camera3D = $PreviewCamera
@onready var rig_root: Node3D = $RigRoot
@onready var torso: MeshInstance3D = $RigRoot/Torso
@onready var hips: MeshInstance3D = $RigRoot/Hips
@onready var head: MeshInstance3D = $RigRoot/Head
@onready var left_arm: MeshInstance3D = $RigRoot/LeftArm
@onready var right_arm: MeshInstance3D = $RigRoot/RightArm
@onready var left_leg: MeshInstance3D = $RigRoot/LeftLeg
@onready var right_leg: MeshInstance3D = $RigRoot/RightLeg
@onready var left_shoulder: MeshInstance3D = $RigRoot/LeftShoulder
@onready var right_shoulder: MeshInstance3D = $RigRoot/RightShoulder
@onready var mantle: MeshInstance3D = $RigRoot/Mantle
@onready var hood: MeshInstance3D = $RigRoot/Hood
@onready var crest: MeshInstance3D = $RigRoot/Crest
@onready var eye_left: MeshInstance3D = $RigRoot/EyeLeft
@onready var eye_right: MeshInstance3D = $RigRoot/EyeRight
@onready var hair_bob: MeshInstance3D = $RigRoot/HairBob
@onready var hair_spikes: MeshInstance3D = $RigRoot/HairSpikes
@onready var hair_crown: MeshInstance3D = $RigRoot/HairCrown
@onready var hair_tail: MeshInstance3D = $RigRoot/HairTail
@onready var hair_band: MeshInstance3D = $RigRoot/HairBand
@onready var staff_root: Node3D = $RigRoot/StaffRoot
@onready var blade_root: Node3D = $RigRoot/BladeRoot
@onready var bow_root: Node3D = $RigRoot/BowRoot
@onready var shield_root: Node3D = $RigRoot/ShieldRoot
@onready var aura_root: Node3D = $AuraRoot
@onready var aura_ring: MeshInstance3D = $AuraRoot/AuraRing
@onready var aura_core: MeshInstance3D = $AuraRoot/AuraCore
@onready var left_hand_aura: MeshInstance3D = $AuraRoot/LeftHandAura
@onready var right_hand_aura: MeshInstance3D = $AuraRoot/RightHandAura
@onready var floor_aura: MeshInstance3D = $AuraRoot/FloorAura
@onready var halo_aura: MeshInstance3D = $AuraRoot/HaloAura
@onready var stand_disc: MeshInstance3D = $StandDisc

var _pulse_time: float = 0.0
var _ui_preview_mode: bool = true
var _body_material: StandardMaterial3D
var _skin_material: StandardMaterial3D
var _accent_material: StandardMaterial3D
var _hair_material: StandardMaterial3D
var _eye_material: StandardMaterial3D
var _aura_material: StandardMaterial3D
var _stand_material: StandardMaterial3D
var _current_class_id: String = "warrior"
var _current_appearance: Dictionary = {}
var _current_aura_intensity: float = 1.0

const CLASS_VISUALS: Dictionary = {
	"necromancer": {
		"height": 1.91,
		"torso_scale": Vector3(0.94, 1.16, 0.92),
		"head_scale": Vector3(0.95, 0.95, 0.95),
		"arm_scale": Vector3(0.86, 1.08, 0.86),
		"leg_scale": Vector3(0.88, 1.14, 0.88),
		"leg_offset": 0.15,
		"shoulder_scale": Vector3(0.78, 0.38, 0.78),
		"body_color": Color("3b3547"),
		"accent_color": Color("8d73c8"),
		"aura_color": Color("8d63df"),
		"mantle": true,
		"hood": true,
		"crest": false,
		"staff": true,
		"blade": false,
		"bow": false,
		"shield": false,
		"arm_pose": 0.24,
		"stance_yaw": 0.03,
		"spine_tilt": -0.08,
		"aura_mode": "hands",
		"aura_intensity": 1.24
	},
	"assassin": {
		"height": 1.74,
		"torso_scale": Vector3(0.86, 1.00, 0.80),
		"head_scale": Vector3(0.90, 0.90, 0.90),
		"arm_scale": Vector3(0.76, 1.08, 0.76),
		"leg_scale": Vector3(0.78, 1.02, 0.78),
		"leg_offset": 0.14,
		"shoulder_scale": Vector3(0.68, 0.20, 0.68),
		"body_color": Color("2a2f36"),
		"accent_color": Color("717985"),
		"aura_color": Color("47515e"),
		"mantle": false,
		"hood": true,
		"crest": false,
		"staff": false,
		"blade": true,
		"bow": false,
		"shield": false,
		"arm_pose": 0.66,
		"stance_yaw": -0.08,
		"spine_tilt": -0.04,
		"aura_mode": "feet",
		"aura_intensity": 0.88
	},
	"warrior": {
		"height": 1.88,
		"torso_scale": Vector3(1.14, 1.14, 1.02),
		"head_scale": Vector3(0.97, 0.97, 0.97),
		"arm_scale": Vector3(1.00, 1.10, 1.00),
		"leg_scale": Vector3(0.96, 1.12, 0.96),
		"leg_offset": 0.17,
		"shoulder_scale": Vector3(1.18, 0.46, 1.12),
		"body_color": Color("606a73"),
		"accent_color": Color("bc9160"),
		"aura_color": Color("cca157"),
		"mantle": false,
		"hood": false,
		"crest": true,
		"staff": false,
		"blade": true,
		"bow": false,
		"shield": false,
		"arm_pose": 0.28,
		"stance_yaw": 0.00,
		"spine_tilt": 0.02,
		"aura_mode": "core",
		"aura_intensity": 1.02
	},
	"archer": {
		"height": 1.80,
		"torso_scale": Vector3(0.92, 1.04, 0.88),
		"head_scale": Vector3(0.93, 0.93, 0.93),
		"arm_scale": Vector3(0.84, 1.06, 0.84),
		"leg_scale": Vector3(0.82, 1.08, 0.82),
		"leg_offset": 0.14,
		"shoulder_scale": Vector3(0.76, 0.22, 0.76),
		"body_color": Color("4d6544"),
		"accent_color": Color("8eaa6e"),
		"aura_color": Color("6ea566"),
		"mantle": false,
		"hood": false,
		"crest": false,
		"staff": false,
		"blade": false,
		"bow": true,
		"shield": false,
		"arm_pose": 0.34,
		"stance_yaw": 0.10,
		"spine_tilt": 0.01,
		"aura_mode": "feet",
		"aura_intensity": 0.92
	},
	"mage": {
		"height": 1.84,
		"torso_scale": Vector3(0.90, 1.08, 0.86),
		"head_scale": Vector3(0.95, 0.95, 0.95),
		"arm_scale": Vector3(0.82, 1.10, 0.82),
		"leg_scale": Vector3(0.84, 1.10, 0.84),
		"leg_offset": 0.15,
		"shoulder_scale": Vector3(0.82, 0.28, 0.82),
		"body_color": Color("35496d"),
		"accent_color": Color("7a95ff"),
		"aura_color": Color("5ca4ff"),
		"mantle": true,
		"hood": false,
		"crest": true,
		"staff": true,
		"blade": false,
		"bow": false,
		"shield": false,
		"arm_pose": 0.18,
		"stance_yaw": 0.06,
		"spine_tilt": -0.02,
		"aura_mode": "arcane",
		"aura_intensity": 1.22
	},
	"berserker": {
		"height": 1.95,
		"torso_scale": Vector3(1.20, 1.18, 1.08),
		"head_scale": Vector3(0.98, 0.98, 0.98),
		"arm_scale": Vector3(1.12, 1.16, 1.12),
		"leg_scale": Vector3(1.00, 1.16, 1.00),
		"leg_offset": 0.18,
		"shoulder_scale": Vector3(1.06, 0.30, 1.02),
		"body_color": Color("6a3834"),
		"accent_color": Color("d3624c"),
		"aura_color": Color("d74432"),
		"mantle": false,
		"hood": false,
		"crest": false,
		"staff": false,
		"blade": true,
		"bow": false,
		"shield": false,
		"arm_pose": 0.72,
		"stance_yaw": -0.04,
		"spine_tilt": 0.06,
		"aura_mode": "smoke",
		"aura_intensity": 1.26
	},
	"druid": {
		"height": 1.79,
		"torso_scale": Vector3(0.94, 1.05, 0.90),
		"head_scale": Vector3(0.94, 0.94, 0.94),
		"arm_scale": Vector3(0.84, 1.04, 0.84),
		"leg_scale": Vector3(0.84, 1.04, 0.84),
		"leg_offset": 0.15,
		"shoulder_scale": Vector3(0.74, 0.24, 0.74),
		"body_color": Color("475646"),
		"accent_color": Color("89be86"),
		"aura_color": Color("6ec473"),
		"mantle": true,
		"hood": false,
		"crest": false,
		"staff": true,
		"blade": false,
		"bow": false,
		"shield": false,
		"arm_pose": 0.14,
		"stance_yaw": 0.02,
		"spine_tilt": -0.01,
		"aura_mode": "nature",
		"aura_intensity": 1.10
	},
	"cleric": {
		"height": 1.84,
		"torso_scale": Vector3(1.00, 1.10, 0.94),
		"head_scale": Vector3(0.95, 0.95, 0.95),
		"arm_scale": Vector3(0.88, 1.08, 0.88),
		"leg_scale": Vector3(0.88, 1.08, 0.88),
		"leg_offset": 0.15,
		"shoulder_scale": Vector3(0.88, 0.32, 0.88),
		"body_color": Color("d8d3c4"),
		"accent_color": Color("ecd88f"),
		"aura_color": Color("f7e7a7"),
		"mantle": true,
		"hood": false,
		"crest": true,
		"staff": true,
		"blade": false,
		"bow": false,
		"shield": false,
		"arm_pose": 0.08,
		"stance_yaw": 0.00,
		"spine_tilt": -0.03,
		"aura_mode": "halo",
		"aura_intensity": 1.08
	},
	"paladin": {
		"height": 1.90,
		"torso_scale": Vector3(1.10, 1.14, 1.00),
		"head_scale": Vector3(0.97, 0.97, 0.97),
		"arm_scale": Vector3(0.96, 1.10, 0.96),
		"leg_scale": Vector3(0.96, 1.12, 0.96),
		"leg_offset": 0.17,
		"shoulder_scale": Vector3(1.10, 0.42, 1.08),
		"body_color": Color("717a82"),
		"accent_color": Color("d8b95f"),
		"aura_color": Color("f0cf70"),
		"mantle": true,
		"hood": false,
		"crest": true,
		"staff": false,
		"blade": true,
		"bow": false,
		"shield": true,
		"arm_pose": 0.18,
		"stance_yaw": 0.04,
		"spine_tilt": 0.01,
		"aura_mode": "radiant",
		"aura_intensity": 1.18
	}
}

const SKIN_TONES := {
	"skin_01": Color("f5d6bf"),
	"skin_02": Color("e6bb99"),
	"skin_03": Color("c98f68"),
	"skin_04": Color("9a6446"),
	"skin_05": Color("6b4330")
}

const EYE_COLORS := {
	"amber": Color("d8a64f"),
	"blue": Color("67a5ff"),
	"green": Color("69c971"),
	"violet": Color("9d83ff"),
	"silver": Color("cfd8e2")
}

const HAIR_COLORS := {
	"black": Color("262227"),
	"brown": Color("593c2a"),
	"chestnut": Color("7c5237"),
	"blonde": Color("d8c27b"),
	"white": Color("d9dce3"),
	"red": Color("a94d37"),
	"teal": Color("3f7e79"),
	"violet": Color("725299")
}


func _ready() -> void:
	_build_materials()
	set_preview_mode(true)
	_current_appearance = GameManager.get_default_appearance()
	_apply_visuals()


func _process(delta: float) -> void:
	_pulse_time += delta
	if _ui_preview_mode:
		rig_root.rotate_y(idle_spin_speed * delta)
	var pulse: float = 0.88 + sin(_pulse_time * aura_pulse_speed) * 0.08 * _current_aura_intensity
	aura_ring.scale = Vector3.ONE * pulse
	aura_core.scale = Vector3.ONE * (0.92 + sin(_pulse_time * (aura_pulse_speed + 0.8)) * 0.05 * _current_aura_intensity)
	left_hand_aura.scale = Vector3.ONE * (0.55 + sin(_pulse_time * (aura_pulse_speed + 0.5)) * 0.05 * _current_aura_intensity)
	right_hand_aura.scale = Vector3.ONE * (0.55 + sin(_pulse_time * (aura_pulse_speed + 0.7)) * 0.05 * _current_aura_intensity)
	floor_aura.scale = Vector3.ONE * (0.96 + sin(_pulse_time * (aura_pulse_speed - 0.2)) * 0.05 * _current_aura_intensity)
	halo_aura.scale = Vector3.ONE * (0.82 + sin(_pulse_time * (aura_pulse_speed + 0.4)) * 0.05 * _current_aura_intensity)
	_aura_material.albedo_color.a = 0.16 + sin(_pulse_time * aura_pulse_speed) * 0.03 * _current_aura_intensity
	_aura_material.emission_energy_multiplier = 1.1 + sin(_pulse_time * (aura_pulse_speed + 0.3)) * 0.15 * _current_aura_intensity


func set_preview_mode(in_ui: bool) -> void:
	_ui_preview_mode = in_ui
	preview_sun.visible = in_ui
	preview_fill.visible = in_ui
	preview_camera.current = in_ui
	stand_disc.visible = in_ui
	if not in_ui:
		rig_root.rotation.y = 0.0


func setup_class_visual(class_id: String) -> void:
	_current_class_id = class_id
	_apply_visuals()


func apply_appearance(class_id: String, appearance: Dictionary) -> void:
	_current_class_id = class_id
	_current_appearance = GameManager.normalize_appearance(appearance)
	_apply_visuals()


func _apply_visuals() -> void:
	var resolved_class_id: String = _current_class_id
	if not CLASS_VISUALS.has(resolved_class_id):
		resolved_class_id = "warrior"
	var config: Dictionary = CLASS_VISUALS[resolved_class_id]
	var appearance: Dictionary = GameManager.normalize_appearance(_current_appearance)
	_apply_palette(config, appearance)
	_apply_proportions(config, appearance)
	_apply_accessories(config)
	_apply_hair_style(appearance)
	_apply_face(appearance)
	_apply_aura_layout(config, appearance)


func _build_materials() -> void:
	_body_material = StandardMaterial3D.new()
	_body_material.roughness = 0.72
	_body_material.metallic = 0.12

	_skin_material = StandardMaterial3D.new()
	_skin_material.roughness = 0.86
	_skin_material.metallic = 0.01

	_accent_material = StandardMaterial3D.new()
	_accent_material.roughness = 0.34
	_accent_material.metallic = 0.18
	_accent_material.emission_enabled = true
	_accent_material.emission_energy_multiplier = 0.55

	_hair_material = StandardMaterial3D.new()
	_hair_material.roughness = 0.68
	_hair_material.metallic = 0.02

	_eye_material = StandardMaterial3D.new()
	_eye_material.roughness = 0.16
	_eye_material.metallic = 0.0
	_eye_material.emission_enabled = true
	_eye_material.emission_energy_multiplier = 0.28

	_aura_material = StandardMaterial3D.new()
	_aura_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_aura_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_aura_material.no_depth_test = true
	_aura_material.emission_enabled = true
	_aura_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	_stand_material = StandardMaterial3D.new()
	_stand_material.roughness = 0.95
	_stand_material.metallic = 0.0
	_stand_material.albedo_color = Color(0.09, 0.10, 0.12, 1.0)
	stand_disc.material_override = _stand_material


func _apply_palette(config: Dictionary, appearance: Dictionary) -> void:
	var body_color: Color = config.get("body_color", Color(0.5, 0.5, 0.5, 1.0))
	var accent_color: Color = config.get("accent_color", Color(0.9, 0.8, 0.6, 1.0))
	var aura_color: Color = config.get("aura_color", accent_color)
	var skin_color: Color = SKIN_TONES.get(str(appearance.get("skin_tone", "skin_03")), SKIN_TONES["skin_03"])
	var eye_color: Color = EYE_COLORS.get(str(appearance.get("eye_color", "amber")), EYE_COLORS["amber"])
	var hair_color: Color = HAIR_COLORS.get(str(appearance.get("hair_color", "black")), HAIR_COLORS["black"])

	_body_material.albedo_color = body_color
	_skin_material.albedo_color = skin_color
	_accent_material.albedo_color = accent_color
	_accent_material.emission = accent_color
	_hair_material.albedo_color = hair_color
	_eye_material.albedo_color = eye_color
	_eye_material.emission = eye_color
	_aura_material.albedo_color = Color(aura_color.r, aura_color.g, aura_color.b, 0.18)
	_aura_material.emission = aura_color

	for mesh_instance in [torso, hips, left_leg, right_leg]:
		mesh_instance.material_override = _body_material
	for mesh_instance in [head, left_arm, right_arm]:
		mesh_instance.material_override = _skin_material
	for mesh_instance in [left_shoulder, right_shoulder, mantle, hood, crest]:
		mesh_instance.material_override = _accent_material
	for mesh_instance in [eye_left, eye_right]:
		mesh_instance.material_override = _eye_material
	for mesh_instance in [hair_bob, hair_spikes, hair_crown, hair_tail, hair_band]:
		mesh_instance.material_override = _hair_material
	for root in [staff_root, blade_root, bow_root, shield_root]:
		for child in root.get_children():
			if child is MeshInstance3D:
				(child as MeshInstance3D).material_override = _accent_material
	for aura_mesh in [aura_ring, aura_core, left_hand_aura, right_hand_aura, floor_aura, halo_aura]:
		aura_mesh.material_override = _aura_material


func _apply_proportions(config: Dictionary, appearance: Dictionary) -> void:
	var body_type: String = str(appearance.get("body_type", "masculine"))
	var body_multipliers := {
		"masculine": {
			"height": 1.02,
			"shoulders": Vector3(1.08, 1.0, 1.04),
			"torso": Vector3(1.03, 1.0, 1.02),
			"head": Vector3(0.98, 0.98, 0.98),
			"leg_offset": 1.02
		},
		"feminine": {
			"height": 0.98,
			"shoulders": Vector3(0.88, 0.90, 0.90),
			"torso": Vector3(0.95, 0.98, 0.92),
			"head": Vector3(1.04, 1.04, 1.04),
			"leg_offset": 0.94
		},
		"stylized_neutral": {
			"height": 1.0,
			"shoulders": Vector3(0.96, 1.04, 0.96),
			"torso": Vector3(0.98, 1.03, 0.96),
			"head": Vector3(1.08, 1.08, 1.08),
			"leg_offset": 0.98
		}
	}
	var body_config: Dictionary = body_multipliers.get(body_type, body_multipliers["masculine"])
	var height: float = float(config.get("height", 1.8)) * float(body_config.get("height", 1.0))
	var height_scale: float = height / 1.82
	var spine_tilt: float = float(config.get("spine_tilt", 0.0))
	var leg_offset: float = float(config.get("leg_offset", 0.15)) * float(body_config.get("leg_offset", 1.0))
	var arm_pose: float = float(config.get("arm_pose", 0.2))

	rig_root.scale = Vector3.ONE * height_scale
	rig_root.rotation = Vector3(spine_tilt, float(config.get("stance_yaw", 0.0)), 0.0)

	torso.scale = config.get("torso_scale", Vector3.ONE) * body_config.get("torso", Vector3.ONE)
	hips.scale = Vector3(0.92, 0.82, 0.86) * torso.scale
	head.scale = config.get("head_scale", Vector3.ONE) * body_config.get("head", Vector3.ONE)
	left_arm.scale = config.get("arm_scale", Vector3.ONE)
	right_arm.scale = config.get("arm_scale", Vector3.ONE)
	left_leg.scale = config.get("leg_scale", Vector3.ONE)
	right_leg.scale = config.get("leg_scale", Vector3.ONE)
	left_shoulder.scale = config.get("shoulder_scale", Vector3.ONE) * body_config.get("shoulders", Vector3.ONE)
	right_shoulder.scale = config.get("shoulder_scale", Vector3.ONE) * body_config.get("shoulders", Vector3.ONE)

	head.position = Vector3(0.0, 1.59, 0.0)
	torso.position = Vector3(0.0, 1.01, 0.0)
	hips.position = Vector3(0.0, 0.54, 0.0)
	left_arm.position = Vector3(-0.42, 1.00, 0.0)
	right_arm.position = Vector3(0.42, 1.00, 0.0)
	left_leg.position = Vector3(-leg_offset, 0.19, 0.0)
	right_leg.position = Vector3(leg_offset, 0.19, 0.0)
	left_shoulder.position = Vector3(-0.36, 1.23, 0.0)
	right_shoulder.position = Vector3(0.36, 1.23, 0.0)
	mantle.position = Vector3(0.0, 0.96, -0.12)
	hood.position = Vector3(0.0, 1.51, -0.03)
	crest.position = Vector3(0.0, 1.86, 0.0)
	eye_left.position = Vector3(-0.07, 1.59, 0.16)
	eye_right.position = Vector3(0.07, 1.59, 0.16)
	hair_bob.position = Vector3(0.0, 1.70, -0.02)
	hair_spikes.position = Vector3(0.0, 1.81, -0.02)
	hair_crown.position = Vector3(0.0, 1.73, -0.02)
	hair_tail.position = Vector3(0.0, 1.63, -0.15)
	hair_band.position = Vector3(0.0, 1.72, 0.02)

	left_arm.rotation = Vector3(0.0, 0.0, deg_to_rad(-8.0 - arm_pose * 20.0))
	right_arm.rotation = Vector3(0.0, 0.0, deg_to_rad(8.0 + arm_pose * 20.0))
	left_leg.rotation = Vector3(0.0, 0.0, deg_to_rad(1.5))
	right_leg.rotation = Vector3(0.0, 0.0, deg_to_rad(-1.5))

	staff_root.position = Vector3(0.56, 0.85, 0.0)
	staff_root.rotation = Vector3(0.0, 0.0, deg_to_rad(10.0))
	blade_root.position = Vector3(0.54, 0.72, 0.05)
	blade_root.rotation = Vector3(0.0, 0.0, deg_to_rad(18.0 + arm_pose * 8.0))
	bow_root.position = Vector3(0.54, 1.03, -0.20)
	bow_root.rotation = Vector3(0.0, deg_to_rad(74.0), deg_to_rad(16.0))
	shield_root.position = Vector3(-0.54, 0.92, 0.04)
	shield_root.rotation = Vector3(0.0, deg_to_rad(8.0), deg_to_rad(12.0))


func _apply_accessories(config: Dictionary) -> void:
	mantle.visible = bool(config.get("mantle", false))
	hood.visible = bool(config.get("hood", false))
	crest.visible = bool(config.get("crest", false))
	staff_root.visible = bool(config.get("staff", false))
	blade_root.visible = bool(config.get("blade", false))
	bow_root.visible = bool(config.get("bow", false))
	shield_root.visible = bool(config.get("shield", false))

	var accent_color: Color = config.get("accent_color", Color(1, 1, 1, 1))
	var shoulder_visible: bool = bool(
		config.get("blade", false)
		or config.get("staff", false)
		or config.get("shield", false)
		or float(config.get("height", 1.8)) > 1.82
	)
	left_shoulder.visible = shoulder_visible
	right_shoulder.visible = shoulder_visible
	stand_disc.scale = Vector3(1.25, 1.0, 1.25)
	_stand_material.albedo_color = Color(
		0.07 + accent_color.r * 0.08,
		0.08 + accent_color.g * 0.08,
		0.10 + accent_color.b * 0.08,
		1.0
	)


func _apply_hair_style(appearance: Dictionary) -> void:
	var hair_style: String = str(appearance.get("hair_style", "short"))
	for mesh_instance in [hair_bob, hair_spikes, hair_crown, hair_tail, hair_band]:
		mesh_instance.visible = false

	match hair_style:
		"short":
			hair_bob.visible = true
		"spiked":
			hair_spikes.visible = true
		"bob":
			hair_bob.visible = true
			hair_band.visible = true
		"ponytail":
			hair_crown.visible = true
			hair_tail.visible = true
		"crown":
			hair_crown.visible = true
			hair_band.visible = true
		_:
			hair_bob.visible = true


func _apply_face(appearance: Dictionary) -> void:
	var body_type: String = str(appearance.get("body_type", "masculine"))
	var eye_scale := {
		"masculine": Vector3(0.88, 0.88, 0.88),
		"feminine": Vector3(1.0, 1.0, 1.0),
		"stylized_neutral": Vector3(1.12, 1.12, 1.12)
	}
	var scale_value: Vector3 = eye_scale.get(body_type, Vector3.ONE)
	eye_left.scale = scale_value
	eye_right.scale = scale_value


func _apply_aura_layout(config: Dictionary, appearance: Dictionary) -> void:
	var aura_enabled: bool = bool(appearance.get("aura_enabled", true))
	_current_aura_intensity = float(config.get("aura_intensity", 1.0)) if aura_enabled else 0.0
	aura_root.visible = aura_enabled
	aura_ring.visible = false
	aura_core.visible = false
	left_hand_aura.visible = false
	right_hand_aura.visible = false
	floor_aura.visible = false
	halo_aura.visible = false

	if not aura_enabled:
		return

	var aura_mode: String = str(config.get("aura_mode", "core"))
	match aura_mode:
		"hands":
			left_hand_aura.visible = true
			right_hand_aura.visible = true
			left_hand_aura.position = Vector3(-0.54, 0.74, 0.02)
			right_hand_aura.position = Vector3(0.54, 0.74, 0.02)
		"feet":
			floor_aura.visible = true
			floor_aura.position = Vector3(0.0, 0.06, 0.0)
			aura_ring.visible = true
			aura_ring.position = Vector3(0.0, 0.10, 0.0)
		"arcane":
			aura_ring.visible = true
			aura_core.visible = true
			left_hand_aura.visible = true
			right_hand_aura.visible = true
			aura_core.position = Vector3(0.0, 1.10, -0.08)
			left_hand_aura.position = Vector3(-0.54, 0.80, 0.02)
			right_hand_aura.position = Vector3(0.54, 0.80, 0.02)
		"smoke":
			floor_aura.visible = true
			aura_core.visible = true
			floor_aura.position = Vector3(0.0, 0.08, 0.0)
			aura_core.position = Vector3(0.0, 0.95, -0.10)
			aura_core.scale = Vector3.ONE * 1.10
		"nature":
			floor_aura.visible = true
			left_hand_aura.visible = true
			right_hand_aura.visible = true
			floor_aura.position = Vector3(0.0, 0.06, 0.0)
			left_hand_aura.position = Vector3(-0.52, 0.78, 0.02)
			right_hand_aura.position = Vector3(0.52, 0.78, 0.02)
		"halo":
			halo_aura.visible = true
			aura_core.visible = true
			halo_aura.position = Vector3(0.0, 1.95, 0.0)
			aura_core.position = Vector3(0.0, 0.98, -0.08)
		"radiant":
			aura_ring.visible = true
			aura_core.visible = true
			left_hand_aura.visible = true
			right_hand_aura.visible = true
			halo_aura.visible = true
			aura_core.position = Vector3(0.0, 1.00, -0.08)
			left_hand_aura.position = Vector3(-0.52, 0.80, 0.02)
			right_hand_aura.position = Vector3(0.52, 0.80, 0.02)
			halo_aura.position = Vector3(0.0, 1.93, 0.0)
		_:
			aura_ring.visible = true
			aura_core.visible = true
			aura_ring.position = Vector3(0.0, 0.12, 0.0)
			aura_core.position = Vector3(0.0, 0.86, -0.10)
