extends Control
class_name MobileControls2D

signal interact_pressed

@export var debug_show_in_editor: bool = true
@export var joystick_radius: float = 82.0
@export var joystick_deadzone: float = 0.14
@export var joystick_response_curve: float = 1.2

@onready var joystick_base: Control = %JoystickBase
@onready var joystick_knob: Control = %JoystickKnob
@onready var menu_button: Button = %MenuButton
@onready var interact_button: Button = %InteractButton

var current_move_vector: Vector2 = Vector2.ZERO
var joystick_touch_index: int = -1


func _ready() -> void:
	add_to_group("mobile_controls_2d")
	visible = debug_show_in_editor or OS.has_feature("android") or OS.has_feature("mobile")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_resolve_node_refs()
	_position_controls()
	if menu_button != null and not menu_button.pressed.is_connected(_on_menu_pressed):
		menu_button.pressed.connect(_on_menu_pressed)
	if interact_button != null and not interact_button.pressed.is_connected(_on_interact_pressed):
		interact_button.pressed.connect(_on_interact_pressed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_controls()


func get_move_vector() -> Vector2:
	return current_move_vector


func _resolve_node_refs() -> void:
	if joystick_base == null:
		joystick_base = get_node_or_null("JoystickBase") as Control
	if joystick_knob == null:
		joystick_knob = get_node_or_null("JoystickKnob") as Control
	if menu_button == null:
		menu_button = get_node_or_null("MenuButton") as Button
	if interact_button == null:
		interact_button = get_node_or_null("InteractButton") as Button


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _is_over_button(event.position):
			return
		if _is_inside_control(joystick_base, event.position):
			joystick_touch_index = event.index
			_update_joystick(event.position)
			get_viewport().set_input_as_handled()
	else:
		if event.index == joystick_touch_index:
			_reset_joystick()
			get_viewport().set_input_as_handled()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_index:
		_update_joystick(event.position)
		get_viewport().set_input_as_handled()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if not debug_show_in_editor or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed and _is_inside_control(joystick_base, event.position):
		joystick_touch_index = 0
		_update_joystick(event.position)
	elif not event.pressed and joystick_touch_index == 0:
		_reset_joystick()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if debug_show_in_editor and joystick_touch_index == 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_joystick(event.position)


func _position_controls() -> void:
	var viewport_size := get_viewport_rect().size
	if joystick_base != null:
		joystick_base.size = Vector2(176, 176)
		joystick_base.global_position = Vector2(52, viewport_size.y - 228)
		joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if joystick_knob != null:
		joystick_knob.size = Vector2(72, 72)
		joystick_knob.global_position = _get_joystick_center() - joystick_knob.size * 0.5
		joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if menu_button != null:
		menu_button.size = Vector2(120, 46)
		menu_button.global_position = Vector2(viewport_size.x - 140, 24)
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP

	if interact_button != null:
		interact_button.size = Vector2(132, 54)
		interact_button.global_position = Vector2(viewport_size.x - 160, viewport_size.y - 112)
		interact_button.mouse_filter = Control.MOUSE_FILTER_STOP


func _update_joystick(screen_position: Vector2) -> void:
	var center := _get_joystick_center()
	var delta := screen_position - center
	var clamped := delta.limit_length(joystick_radius)
	var raw_vector := clamped / joystick_radius
	if raw_vector.length() < joystick_deadzone:
		current_move_vector = Vector2.ZERO
	else:
		var strength := inverse_lerp(joystick_deadzone, 1.0, raw_vector.length())
		strength = pow(strength, joystick_response_curve)
		current_move_vector = raw_vector.normalized() * strength
	joystick_knob.global_position = center + clamped - joystick_knob.size * 0.5


func _reset_joystick() -> void:
	joystick_touch_index = -1
	current_move_vector = Vector2.ZERO
	joystick_knob.global_position = _get_joystick_center() - joystick_knob.size * 0.5


func _get_joystick_center() -> Vector2:
	if joystick_base == null:
		return Vector2.ZERO
	return joystick_base.global_position + joystick_base.size * 0.5


func _is_inside_control(control: Control, screen_position: Vector2) -> bool:
	if control == null or not control.visible:
		return false
	return Rect2(control.global_position, control.size).has_point(screen_position)


func _is_over_button(screen_position: Vector2) -> bool:
	return _is_inside_control(menu_button, screen_position) or _is_inside_control(interact_button, screen_position)


func _on_menu_pressed() -> void:
	GameManager.toggle_pause_menu()


func _on_interact_pressed() -> void:
	interact_pressed.emit()
	var player := get_tree().get_first_node_in_group("player_2d")
	if player != null and player.has_method("try_interact"):
		player.try_interact()
