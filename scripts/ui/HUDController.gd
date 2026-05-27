extends Control
class_name HUDController

var player: PlayerController = null
var move_input: Vector2 = Vector2.ZERO
var skill_cooldowns: Dictionary = {1: 0.0, 2: 0.0}

@onready var life_bar: ProgressBar = $TopLeft/LifeBar
@onready var life_label: Label = $TopLeft/LifeLabel
@onready var mana_bar: ProgressBar = $TopLeft/ManaBar
@onready var mana_label: Label = $TopLeft/ManaLabel
@onready var class_label: Label = $TopLeft/ClassLabel
@onready var level_label: Label = $TopLeft/LevelLabel
@onready var target_label: Label = $TopCenter/TargetLabel
@onready var message_label: Label = $BottomCenter/MessageLabel
@onready var joystick_touch: Control = $BottomLeft/JoystickTouch
@onready var knob: ColorRect = $BottomLeft/JoystickTouch/Knob
@onready var attack_button: Button = $BottomRight/AttackButton
@onready var skill_one: Button = $BottomRight/Skill1Button
@onready var skill_two: Button = $BottomRight/Skill2Button

func _ready() -> void:
	message_label.modulate.a = 0.0


func _process(delta: float) -> void:
	if player == null:
		return
	_update_bars()
	_update_target()
	_update_cooldowns(delta)
	player.set_move_input(move_input)
	if Input.is_action_just_pressed("attack"):
		player.request_basic_attack()
	if Input.is_action_just_pressed("skill_1"):
		player.request_skill(0)
	if Input.is_action_just_pressed("skill_2"):
		player.request_skill(1)
	if Input.is_action_just_pressed("interact"):
		player.try_interact()
	if Input.is_action_just_pressed("pause"):
		GameManager.toggle_pause_menu()


func bind_player(target_player: PlayerController) -> void:
	player = target_player
	player.set_hud(self)
	_set_skill_labels()


func set_class_name(display_class_name: String) -> void:
	class_label.text = display_class_name
	level_label.text = "Nivel 1"


func show_message(message: String) -> void:
	message_label.text = message
	var tween: Tween = create_tween()
	message_label.modulate.a = 1.0
	tween.tween_interval(1.2)
	tween.tween_property(message_label, "modulate:a", 0.0, 0.4)


func start_skill_cooldown(slot: int, duration: float) -> void:
	skill_cooldowns[slot] = duration


func _update_bars() -> void:
	life_bar.max_value = player.stats.max_health
	life_bar.value = player.stats.current_health
	life_label.text = "Vida %.0f / %.0f" % [player.stats.current_health, player.stats.max_health]
	mana_bar.max_value = player.stats.max_mana
	mana_bar.value = player.stats.current_mana
	mana_label.text = "Mana %.0f / %.0f" % [player.stats.current_mana, player.stats.max_mana]


func _update_target() -> void:
	var target: EnemyBase = player.combat.get_current_target()
	if target != null:
		target_label.text = "Alvo: %s" % target.enemy_name
	else:
		target_label.text = "Alvo: --"


func _update_cooldowns(delta: float) -> void:
	for slot in skill_cooldowns.keys():
		skill_cooldowns[slot] = maxf(0.0, skill_cooldowns[slot] - delta)
	skill_one.text = _skill_button_text(0, skill_cooldowns[1])
	skill_two.text = _skill_button_text(1, skill_cooldowns[2])


func _skill_button_text(index: int, remaining: float) -> String:
	if player == null:
		return "--"
	var skill_name: String = player.skills.get_skill_name(index)
	if remaining > 0.0:
		return "%s\n%.1f" % [skill_name, remaining]
	return skill_name


func _set_skill_labels() -> void:
	skill_one.text = _skill_button_text(0, 0.0)
	skill_two.text = _skill_button_text(1, 0.0)


func _on_attack_button_pressed() -> void:
	if player != null:
		player.request_basic_attack()


func _on_skill_1_button_pressed() -> void:
	if player != null:
		player.request_skill(0)


func _on_skill_2_button_pressed() -> void:
	if player != null:
		player.request_skill(1)


func _on_interact_button_pressed() -> void:
	if player != null:
		player.try_interact()


func _on_menu_button_pressed() -> void:
	GameManager.toggle_pause_menu()


func _on_joystick_touch_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var pressed: bool = event.pressed
		if not pressed:
			move_input = Vector2.ZERO
			knob.position = Vector2(56, 56)
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		var local_pos: Vector2 = joystick_touch.get_local_mouse_position()
		var center: Vector2 = Vector2(96, 96)
		var offset: Vector2 = (local_pos - center).limit_length(54.0)
		move_input = offset / 54.0
		knob.position = center + offset - Vector2(40, 40)


func _unhandled_input(event: InputEvent) -> void:
	if player == null:
		return
	if event is InputEventScreenDrag:
		if event.position.x > size.x * 0.4:
			player.add_camera_input(event.relative)
	if event is InputEventMouseMotion and Input.is_action_pressed("camera_drag"):
		player.add_camera_input(event.relative)
