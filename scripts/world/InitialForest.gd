extends Node3D

@onready var player: PlayerController = $Player
@onready var spawn_marker: Marker3D = $SpawnPoint

func setup_world(_save_data: Dictionary) -> void:
	player.spawn_position = spawn_marker.global_position


func get_player() -> PlayerController:
	return player


func respawn_player() -> void:
	player.respawn_at(spawn_marker.global_position)


func spawn_damage_number(amount: float, world_position: Vector3, critical: bool) -> void:
	var packed: PackedScene = load("res://scenes/effects/DamageNumber.tscn") as PackedScene
	if packed == null:
		return
	var instance: Node = packed.instantiate()
	instance.global_position = world_position
	add_child(instance)
	if instance.has_method("setup"):
		instance.setup(amount, critical)
