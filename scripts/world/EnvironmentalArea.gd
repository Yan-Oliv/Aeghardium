extends Area3D
class_name EnvironmentalArea

@export_enum("fire", "heat", "water", "swamp", "healing", "safe")
var environment_type: String = "fire"

@export var status_duration: float = 3.0
@export var tick_interval: float = 1.0
@export var damage_per_tick: int = 2
@export var heal_per_tick: int = 2
@export var slow_multiplier: float = 0.6
@export var dry_near_fire: float = 0.8
@export var dry_on_fire: float = 1.2


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body == null or not body.has_method("apply_environment_status"):
		return
	print("[Environment] entered ", environment_type)
	body.apply_environment_status(environment_type, {
		"duration": status_duration,
		"tick_interval": tick_interval,
		"damage_per_tick": damage_per_tick,
		"heal_per_tick": heal_per_tick,
		"slow_multiplier": slow_multiplier,
		"dry_near_fire": dry_near_fire,
		"dry_on_fire": dry_on_fire
	})


func _on_body_exited(body: Node) -> void:
	if body == null or not body.has_method("remove_environment_status"):
		return
	print("[Environment] exited ", environment_type)
	body.remove_environment_status(environment_type)
