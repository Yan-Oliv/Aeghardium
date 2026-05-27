extends Node

@onready var scene_host: Node = $SceneHost
@onready var ui_host: CanvasLayer = $UILayer

func _ready() -> void:
	GameManager.register_hosts(scene_host, ui_host)

