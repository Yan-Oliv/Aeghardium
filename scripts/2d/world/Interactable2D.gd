extends Area2D
class_name Interactable2D

@export var interaction_label: String = "Interagir"
@export_enum("generic", "portal_dungeon", "portal_base", "chest", "battle_trigger", "rest", "save", "shop", "character", "inventory", "skills", "forge")
var interaction_type: String = "generic"
@export var target_scene: String = ""
@export var enemy_id: String = "slime_green"
@export var auto_interact_on_player_touch: bool = false

var used: bool = false


func _ready() -> void:
	add_to_group("interactable_2d")
	monitoring = true
	monitorable = true
	collision_layer = 4
	collision_mask = 2
	if interaction_type == "battle_trigger" and GameManager.is_dungeon_enemy_defeated(enemy_id):
		queue_free()
		return
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func interact(player: Node) -> void:
	if used and interaction_type == "chest":
		_show_message("O bau ja esta vazio.")
		return
	print("[Interactable2D] interacted with ", interaction_type)
	match interaction_type:
		"portal_dungeon":
			if GameManager.scene_host != null:
				GameManager.start_dungeon_floor_01()
			else:
				_go_to_scene("res://scenes/2d/maps/DungeonFloor2D.tscn")
		"portal_base":
			if GameManager.scene_host != null:
				GameManager.show_base()
			else:
				_go_to_scene("res://scenes/2d/maps/BaseVillage2D.tscn")
		"chest":
			used = true
			GameManager.add_item("small_potion", 1)
			_show_message("Bau aberto: pocao pequena +1.")
		"battle_trigger":
			if GameManager.player_state.is_empty() or GameManager.scene_host == null:
				_show_message("[Dungeon2D] battle trigger")
			else:
				GameManager.start_dungeon_battle(enemy_id, "dungeon_floor_2d")
		"rest":
			GameManager.rest_at_base()
			_show_message("Voce descansou na base.")
		"save":
			if GameManager.save_current_game():
				_show_message("Jogo salvo.")
			else:
				_show_message("Nao ha personagem para salvar.")
		"shop":
			_show_message("Loja da base: sistema de compra entra na proxima etapa.")
		"character":
			_show_message("Personagem: status/equipamentos entram na proxima etapa.")
		"inventory":
			_show_message("Inventario: mochila entra na proxima etapa.")
		"skills":
			_show_message("Habilidades: teia entra na proxima etapa.")
		"forge":
			_show_message("Forja: aprimoramentos entram na proxima etapa.")
		_:
			_show_message(interaction_label)


func _on_body_entered(body: Node) -> void:
	if not auto_interact_on_player_touch:
		return
	if body == null or not body.is_in_group("player_2d"):
		return
	interact(body)


func _go_to_scene(fallback_scene: String) -> void:
	var scene_path := target_scene if not target_scene.is_empty() else fallback_scene
	get_tree().change_scene_to_file(scene_path)


func _show_message(message: String) -> void:
	var current := get_tree().current_scene
	if current != null and current.has_method("show_message"):
		current.show_message(message)
	else:
		GameManager.show_message(message)
