extends Node

@onready var scene_host: Node = $SceneHost
@onready var ui_host: CanvasLayer = $UILayer


func _ready() -> void:
	GameManager.register_hosts(scene_host, ui_host)


func show_message(message: String) -> void:
	for child in scene_host.get_children():
		if child.has_method("show_message"):
			child.show_message(message)
			return
	print("[Main2D] ", message)
