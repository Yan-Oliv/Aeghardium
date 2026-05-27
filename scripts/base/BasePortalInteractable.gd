extends Area3D
class_name BasePortalInteractable

signal interaction_requested


func _ready() -> void:
	add_to_group("interactable")


func interact(_player) -> void:
	interaction_requested.emit()
