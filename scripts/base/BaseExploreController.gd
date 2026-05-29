extends Node3D
class_name BaseExploreController

const CHARACTER_PREVIEW_SCENE := preload("res://scenes/characters/CharacterPreview3D.tscn")

@onready var player: PlayerController = $Player
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var portal_area: BasePortalInteractable = $PortalArea
@onready var info_label: RichTextLabel = $BaseUI/TopLeft/InfoPanel/InfoLabel
@onready var message_label: Label = $BaseUI/BottomCenter/MessageLabel
@onready var mobile_controls: MobileControls = $BaseUI/MobileControls
@onready var rest_button: Button = get_node_or_null("BaseUI/TopRight/Buttons/RestButton")
@onready var save_button: Button = get_node_or_null("BaseUI/TopRight/Buttons/SaveButton")
@onready var title_button: Button = get_node_or_null("BaseUI/TopRight/Buttons/TitleButton")
@onready var prompt_panel: PanelContainer = $BaseUI/PromptPanel
@onready var prompt_label: Label = $BaseUI/PromptPanel/PromptVBox/PromptLabel
@onready var confirm_button: Button = get_node_or_null("BaseUI/PromptPanel/PromptVBox/PromptButtons/EnterButton")
@onready var cancel_button: Button = get_node_or_null("BaseUI/PromptPanel/PromptVBox/PromptButtons/CancelButton")
@onready var hint_label: Label = $BaseUI/BottomHint/HintLabel

var move_input: Vector2 = Vector2.ZERO
var portal_in_range: bool = false
var prompt_open: bool = false
var message_tween: Tween = null


func _ready() -> void:
	for control_path in [
		"BaseUI/TopLeft/InfoPanel",
		"BaseUI/TopRight/Buttons/RestButton",
		"BaseUI/TopRight/Buttons/SaveButton",
		"BaseUI/TopRight/Buttons/TitleButton",
		"BaseUI/PromptPanel",
		"BaseUI/PromptPanel/PromptVBox/PromptButtons/EnterButton",
		"BaseUI/PromptPanel/PromptVBox/PromptButtons/CancelButton",
		"BaseUI/MobileControls/TopRight/MenuButton",
		"BaseUI/MobileControls/BottomRight/InteractButton"
	]:
		UITheme.apply(get_node(control_path) as Control)
	if GameManager.get_player_state().is_empty():
		GameManager.show_title()
		return

	_setup_player()
	_refresh_info()
	_configure_ui_input()
	_connect_base_buttons()
	_log_button_references()
	call_deferred("_connect_mobile_camera")
	prompt_label.text = "Entrar na Dungeon?"
	if prompt_panel != null:
		prompt_panel.visible = false
	if mobile_controls != null:
		mobile_controls.set_interact_visible(false)
	message_label.modulate.a = 0.0
	hint_label.text = "A fogueira marca seu retorno. A dungeon aguarda."

	var pending: String = GameManager.consume_pending_message()
	if not pending.is_empty():
		show_message(pending)


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

	if not prompt_open and portal_in_range and Input.is_action_just_pressed("interact"):
		_open_portal_prompt()

	if mobile_controls != null:
		mobile_controls.set_interact_visible(portal_in_range and not prompt_open)


func show_message(message: String) -> void:
	message_label.text = message
	message_label.modulate.a = 1.0
	if message_tween != null:
		message_tween.kill()
	message_tween = create_tween()
	message_tween.tween_interval(1.6)
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

	var display_class_name: String = str(class_info.get("display_name", "Classe"))
	show_message("Base de %s, %s." % [state.get("player_name", "Desperto"), display_class_name])


func _refresh_info() -> void:
	var state: Dictionary = GameManager.get_player_state()
	var class_info: Dictionary = ClassData.get_class_data(str(state.get("class_id", "warrior")))
	info_label.text = "[b]%s[/b]\nClasse: %s\nNível: %s  Rank: %s\nOuro: %s\nAndar: %s\nVida: %.0f / %.0f\nMana: %.0f / %.0f\nPoções: %s" % [
		state.get("player_name", "Desperto"),
		class_info.get("display_name", "Classe"),
		state.get("level", 1),
		state.get("rank", "F"),
		state.get("gold", 0),
		state.get("floor", 1),
		state.get("current_health", 0.0),
		state.get("max_health", 0.0),
		state.get("current_mana", 0.0),
		state.get("max_mana", 0.0),
		state.get("inventory", {}).get("small_potion", 0)
	]


func _sync_local_resources_from_game_state() -> void:
	var state: Dictionary = GameManager.get_player_state()
	player.stats.current_health = float(state.get("current_health", player.stats.current_health))
	player.stats.current_mana = float(state.get("current_mana", player.stats.current_mana))
	player.stats.max_health = float(state.get("max_health", player.stats.max_health))
	player.stats.max_mana = float(state.get("max_mana", player.stats.max_mana))
	player.stats.stats_changed.emit()


func _open_portal_prompt() -> void:
	prompt_open = true
	move_input = Vector2.ZERO
	if mobile_controls != null:
		mobile_controls.reset_controls()
	if prompt_panel != null:
		prompt_panel.visible = true
	show_message("O portal vibra com energia antiga.")


func _close_portal_prompt() -> void:
	prompt_open = false
	if prompt_panel != null:
		prompt_panel.visible = false
	if mobile_controls != null:
		mobile_controls.set_interact_visible(portal_in_range)


func _on_portal_area_body_entered(body: Node3D) -> void:
	if body == player:
		portal_in_range = true
		show_message("Pressione E ou toque em Interagir para acessar o portal.")


func _on_portal_area_body_exited(body: Node3D) -> void:
	if body == player:
		portal_in_range = false
		if prompt_open:
			_close_portal_prompt()


func _on_portal_interaction_requested() -> void:
	if portal_in_range:
		_open_portal_prompt()


func _on_enter_button_pressed() -> void:
	_close_portal_prompt()
	GameManager.start_dungeon_floor_01()


func _on_cancel_button_pressed() -> void:
	_close_portal_prompt()
	show_message("Você permanece na base.")


func _on_rest_pressed() -> void:
	print("[UI] Rest pressed")
	GameManager.rest_at_base()
	_sync_local_resources_from_game_state()
	_refresh_info()
	show_message("Voce descansou.")


func _on_save_pressed() -> void:
	print("[UI] Save pressed")
	if GameManager.save_current_game():
		show_message("Progresso salvo localmente.")
	else:
		show_message("Falha ao salvar.")


func _on_return_title_pressed() -> void:
	print("[UI] Return title pressed")
	GameManager.show_title()


func _on_rest_button_pressed() -> void:
	_on_rest_pressed()


func _on_save_button_pressed() -> void:
	_on_save_pressed()


func _on_title_button_pressed() -> void:
	_on_return_title_pressed()


func _on_interact_button_pressed() -> void:
	if portal_in_range and not prompt_open:
		_open_portal_prompt()


func _on_mobile_move_input_changed(value: Vector2) -> void:
	move_input = value


func _on_mobile_camera_dragged(relative: Vector2) -> void:
	print("[MobileCamera] drag received=", relative)
	if not prompt_open:
		if player != null and player.has_method("add_camera_input"):
			player.add_camera_input(relative, true)
		else:
			print("[MobileCamera] player missing or has no add_camera_input")


func _on_menu_button_pressed() -> void:
	print("[UI] Menu pressed")
	GameManager.toggle_pause_menu()


func _input(event: InputEvent) -> void:
	if not is_instance_valid(player) or prompt_open:
		return
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_drag"):
		player.add_camera_input(event.relative, false)


func _connect_base_buttons() -> void:
	print("[BaseButtons] rest_button=", rest_button)
	print("[BaseButtons] save_button=", save_button)
	print("[BaseButtons] title_button=", title_button)
	if rest_button != null:
		rest_button.add_to_group("ui_action_button")
		rest_button.mouse_filter = Control.MOUSE_FILTER_STOP
		rest_button.z_index = 50
		if not rest_button.pressed.is_connected(_on_rest_pressed):
			rest_button.pressed.connect(_on_rest_pressed)
	if save_button != null:
		save_button.add_to_group("ui_action_button")
		save_button.mouse_filter = Control.MOUSE_FILTER_STOP
		save_button.z_index = 50
		if not save_button.pressed.is_connected(_on_save_pressed):
			save_button.pressed.connect(_on_save_pressed)
	if title_button != null:
		title_button.add_to_group("ui_action_button")
		title_button.mouse_filter = Control.MOUSE_FILTER_STOP
		title_button.z_index = 50
		if not title_button.pressed.is_connected(_on_return_title_pressed):
			title_button.pressed.connect(_on_return_title_pressed)
	if confirm_button != null and not confirm_button.pressed.is_connected(_on_enter_button_pressed):
		confirm_button.pressed.connect(_on_enter_button_pressed)
	if cancel_button != null and not cancel_button.pressed.is_connected(_on_cancel_button_pressed):
		cancel_button.pressed.connect(_on_cancel_button_pressed)


func _connect_mobile_camera() -> void:
	var controls: Node = get_tree().get_first_node_in_group("mobile_controls")
	print("[MobileCamera] mobile_controls=", controls)
	if controls == null:
		return
	if controls.has_signal("move_input_changed") and not controls.move_input_changed.is_connected(_on_mobile_move_input_changed):
		controls.move_input_changed.connect(_on_mobile_move_input_changed)
	if controls.has_signal("camera_dragged"):
		var callable := Callable(self, "_on_mobile_camera_dragged")
		if not controls.is_connected("camera_dragged", callable):
			controls.connect("camera_dragged", callable)
			print("[MobileCamera] camera_dragged connected")
	else:
		print("[MobileCamera] mobile_controls has no camera_dragged signal")
	if controls.has_signal("interact_pressed") and not controls.interact_pressed.is_connected(_on_interact_button_pressed):
		controls.interact_pressed.connect(_on_interact_button_pressed)
	if controls.has_signal("menu_pressed") and not controls.menu_pressed.is_connected(_on_menu_button_pressed):
		controls.menu_pressed.connect(_on_menu_button_pressed)


func _configure_ui_input() -> void:
	if info_label != null:
		info_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if message_label != null:
		message_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if hint_label != null:
		hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if prompt_label != null:
		prompt_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var info_panel: Control = get_node_or_null("BaseUI/TopLeft/InfoPanel")
	if info_panel != null:
		info_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top_right: Control = get_node_or_null("BaseUI/TopRight")
	if top_right != null:
		top_right.mouse_filter = Control.MOUSE_FILTER_PASS
		top_right.z_index = 50
	var buttons_box: Control = get_node_or_null("BaseUI/TopRight/Buttons")
	if buttons_box != null:
		buttons_box.mouse_filter = Control.MOUSE_FILTER_PASS
		buttons_box.z_index = 50
	if rest_button != null:
		rest_button.mouse_filter = Control.MOUSE_FILTER_STOP
		rest_button.disabled = false
		if not rest_button.is_in_group("ui_action_button"):
			rest_button.add_to_group("ui_action_button")
	if save_button != null:
		save_button.mouse_filter = Control.MOUSE_FILTER_STOP
		save_button.disabled = false
		if not save_button.is_in_group("ui_action_button"):
			save_button.add_to_group("ui_action_button")
	if title_button != null:
		title_button.mouse_filter = Control.MOUSE_FILTER_STOP
		title_button.disabled = false
		if not title_button.is_in_group("ui_action_button"):
			title_button.add_to_group("ui_action_button")
	if prompt_panel != null:
		prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		prompt_panel.z_index = 50
	var prompt_vbox: Control = get_node_or_null("BaseUI/PromptPanel/PromptVBox")
	if prompt_vbox != null:
		prompt_vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	var prompt_buttons: Control = get_node_or_null("BaseUI/PromptPanel/PromptVBox/PromptButtons")
	if prompt_buttons != null:
		prompt_buttons.mouse_filter = Control.MOUSE_FILTER_PASS
	if confirm_button != null:
		confirm_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if not confirm_button.is_in_group("ui_action_button"):
			confirm_button.add_to_group("ui_action_button")
	if cancel_button != null:
		cancel_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if not cancel_button.is_in_group("ui_action_button"):
			cancel_button.add_to_group("ui_action_button")


func _log_button_references() -> void:
	var menu_button: Button = null
	if mobile_controls != null:
		menu_button = mobile_controls.get_node_or_null("TopRight/MenuButton") as Button
	print("[UI] menu_button=", menu_button)
	print("[UI] rest_button=", rest_button)
	print("[UI] save_button=", save_button)
	print("[UI] title_button=", title_button)
	print("[UI] enter_button=", confirm_button)
	print("[UI] cancel_button=", cancel_button)
