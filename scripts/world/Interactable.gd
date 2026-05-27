extends Area3D

@export var message := ""

func _ready() -> void:
	add_to_group("interactable")


func interact(_player) -> void:
	GameManager.show_message(message)

