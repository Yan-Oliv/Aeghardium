extends Node3D
class_name DungeonFloorController

const CHARACTER_PREVIEW_SCENE := preload("res://scenes/characters/CharacterPreview3D.tscn")

@onready var player: PlayerController = $Player
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var enemy_trigger: Area3D = $EnemyTrigger
@onready var exit_portal: Area3D = $ExitPortal
@onready var info_label: RichTextLabel = $DungeonUI/TopLeft/InfoPanel/InfoLabel
@onready var message_label: Label = $DungeonUI/BottomCenter/MessageLabel
@onready var hint_label: Label = $DungeonUI/BottomHint/HintLabel
@onready var mobile_controls: MobileControls = $DungeonUI/MobileControls
@onready var prompt_panel: PanelContainer = $DungeonUI/PromptPanel
@onready var prompt_label: Label = $DungeonUI/PromptPanel/PromptVBox/PromptLabel
@onready var enter_button: Button = $DungeonUI/PromptPanel/PromptVBox/PromptButtons/EnterButton
@onready var cancel_button: Button = $DungeonUI/PromptPanel/PromptVBox/PromptButtons/CancelButton

var move_input: Vector2 = Vector2.ZERO
var prompt_open: bool = false
var near_exit_portal: bool = false
var enemy_defeated: bool = false
var message_tween: Tween = null


func _ready() -> void:
	for control_path in [
		"DungeonUI/TopLeft/InfoPanel",
		"DungeonUI/PromptPanel",
		"DungeonUI/PromptPanel/PromptVBox/PromptButtons/EnterButton",
		"DungeonUI/PromptPanel/PromptVBox/PromptButtons/CancelButton",
		"DungeonUI/MobileControls/TopRight/MenuButton",
		"DungeonUI/MobileControls/BottomRight/InteractButton"
	]:
		UITheme.apply(get_node(control_path) as Control)

	if GameManager.get_player_state().is_empty():
		GameManager.show_title()
		return

	_setup_player()
	_refresh_info()
	if mobile_controls != null:
		mobile_controls.move_input_changed.connect(_on_mobile_move_input_changed)
		mobile_controls.camera_dragged.connect(_on_mobile_camera_dragged)
		mobile_controls.interact_pressed.connect(_on_interact_pressed)
		mobile_controls.menu_pressed.connect(_on_menu_pressed)
		mobile_controls.set_interact_visible(false)

	prompt_label.text = "Retornar para a Base?"
	if prompt_panel != null:
		prompt_panel.visible = false
	message_label.modulate.a = 0.0
	hint_label.text = "Andar 1: avance pela trilha e toque o portal para voltar."
	show_message("Você entrou no Andar 1: Floresta do Início.")


func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var active_input: Vector2 = move_input
	if active_input == Vector2.ZERO and not prompt_open:
		active_input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if active_input == Vector2.ZERO:
			active_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if prompt_open:
		active_input = Vector2.ZERO
	player.set_move_input(active_input)

	if not prompt_open and near_exit_portal and Input.is_action_just_pressed("interact"):
		_open_exit_prompt()

	if mobile_controls != null:
		mobile_controls.set_interact_visible(near_exit_portal and not prompt_open)


func show_message(message: String) -> void:
	message_label.text = message
	message_label.modulate.a = 1.0
	if message_tween != null:
		message_tween.kill()
	message_tween = create_tween()
	message_tween.tween_interval(1.5)
	message_tween.tween_property(message_label, "modulate:a", 0.0, 0.4)


func _setup_player() -> void:
	var state: Dictionary = GameManager.get_player_state()
	var class_id: String = str(state.get("class_id", "warrior"))
	var class_info: Dictionary = ClassData.get_class_data(class_id)
	var appearance: Dictionary = GameManager.normalize_appearance(state.get("appearance", {}))

	player.global_position = spawn_point.global_position
	player.initialize_new_character(class_id, str(state.get("player_name", "Desperto")))
	player.stats.max_health = float(state.get("max_health", player.stats.max_health))
	player.stats.current_health = float(state.get("current_health", player.stats.max_health))
	player.stats.max_mana = float(state.get("max_mana", player.stats.max_mana))
	player.stats.current_mana = float(state.get("current_mana", player.stats.max_mana))
	player.stats.strength = float(state.get("strength", player.stats.strength))
	player.stats.defense = float(state.get("defense", player.stats.defense))
	player.stats.intelligence = float(state.get("intelligence", player.stats.intelligence))
	player.stats.luck = float(state.get("luck", player.stats.luck))
	player.stats.stats_changed.connect(_refresh_info)
	if player.mesh != null:
		player.mesh.visible = false

	var preview := CHARACTER_PREVIEW_SCENE.instantiate() as CharacterPreview3D
	preview.set_preview_mode(false)
	preview.default_class_id = class_id
	preview.apply_appearance(class_id, appearance)
	preview.position = Vector3.ZERO
	player.add_child(preview)
	player.apply_appearance(appearance)

	show_message("Explore a clareira e encontre o Slime Verde.")
	info_label.text = "[b]%s[/b]\nClasse: %s\nAndar: 1\nObjetivo: derrotar o slime e encontrar a saída." % [
		state.get("player_name", "Desperto"),
		class_info.get("display_name", "Classe")
	]


func _refresh_info() -> void:
	var state: Dictionary = GameManager.get_player_state()
	info_label.text = "[b]%s[/b]\nAndar 1\nVida: %.0f / %.0f\nMana: %.0f / %.0f\nPoções: %s\nSlime: %s" % [
		state.get("player_name", "Desperto"),
		state.get("current_health", 0.0),
		state.get("max_health", 0.0),
		state.get("current_mana", 0.0),
		state.get("max_mana", 0.0),
		state.get("inventory", {}).get("small_potion", 0),
		"derrotado" if enemy_defeated else "ativo"
	]


func _start_enemy_battle() -> void:
	if enemy_defeated:
		return
	enemy_defeated = true
	enemy_trigger.monitoring = false
	if has_node("EnemyPlaceholder"):
		$EnemyPlaceholder.visible = false
	if has_node("EnemyMarker"):
		$EnemyMarker.visible = false
	show_message("O Slime Verde investe contra você.")
	GameManager.start_dungeon_battle()


func _open_exit_prompt() -> void:
	prompt_open = true
	move_input = Vector2.ZERO
	if mobile_controls != null:
		mobile_controls.reset_controls()
	if prompt_panel != null:
		prompt_panel.visible = true


func _close_exit_prompt() -> void:
	prompt_open = false
	if prompt_panel != null:
		prompt_panel.visible = false


func _on_enemy_trigger_body_entered(body: Node3D) -> void:
	if body == player:
		_start_enemy_battle()


func _on_exit_portal_body_entered(body: Node3D) -> void:
	if body == player:
		near_exit_portal = true
		show_message("Pressione E ou toque em Interagir para retornar à base.")


func _on_exit_portal_body_exited(body: Node3D) -> void:
	if body == player:
		near_exit_portal = false
		if prompt_open:
			_close_exit_prompt()


func _on_enter_button_pressed() -> void:
	_close_exit_prompt()
	GameManager.show_base()


func _on_cancel_button_pressed() -> void:
	_close_exit_prompt()
	show_message("Você permanece na dungeon.")


func _on_interact_pressed() -> void:
	if near_exit_portal and not prompt_open:
		_open_exit_prompt()


func _on_menu_pressed() -> void:
	GameManager.toggle_pause_menu()


func _on_mobile_move_input_changed(value: Vector2) -> void:
	move_input = value


func _on_mobile_camera_dragged(relative: Vector2) -> void:
	if not prompt_open:
		player.add_camera_input(relative)


func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(player) or prompt_open:
		return
	if event is InputEventScreenDrag:
		if event.position.x > get_viewport().get_visible_rect().size.x * 0.42:
			player.add_camera_input(event.relative)
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_drag"):
		player.add_camera_input(event.relative)
