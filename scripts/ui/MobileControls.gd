extends Control
class_name MobileControls

signal move_input_changed(value: Vector2)
signal camera_dragged(relative: Vector2)
signal interact_pressed
signal menu_pressed

@export var debug_show_in_editor: bool = true
@export var force_show_mobile_controls: bool = true
@export var joystick_deadzone: float = 0.16
@export var joystick_response_curve: float = 1.35
@export var move_joystick_radius: float = 145.0
@export var camera_joystick_radius: float = 115.0
@export var camera_deadzone: float = 0.10
@export var camera_joystick_response_curve: float = 1.15

@onready var move_joystick_touch: Control = get_node_or_null("BottomLeft/JoystickTouch")
@onready var move_joystick_base: Control = get_node_or_null("BottomLeft/JoystickTouch/MoveJoystickBase")
@onready var move_joystick_knob: Control = get_node_or_null("BottomLeft/JoystickTouch/MoveJoystickKnob")
@onready var camera_joystick_touch: Control = get_node_or_null("CameraJoystickTouch")
@onready var camera_joystick_base: Control = get_node_or_null("CameraJoystickTouch/CameraJoystickBase")
@onready var camera_joystick_knob: Control = get_node_or_null("CameraJoystickTouch/CameraJoystickKnob")
@onready var menu_button: Button = get_node_or_null("TopRight/MenuButton")
@onready var interact_button: Button = get_node_or_null("BottomRight/InteractButton")
@onready var camera_drag_area: Control = get_node_or_null("CameraDragArea")
@onready var camera_touch_hint: Control = get_node_or_null("CameraTouchHint")

var current_move_vector: Vector2 = Vector2.ZERO
var current_camera_vector: Vector2 = Vector2.ZERO
var move_touch_index: int = -1
var camera_touch_index: int = -1
var _mouse_move_active: bool = false
var _mouse_camera_active: bool = false
var _last_logged_move_vector: Vector2 = Vector2.ZERO
var _last_logged_camera_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_process_input(true)
	if not is_in_group("mobile_controls"):
		add_to_group("mobile_controls")
	visible = force_show_mobile_controls or OS.has_feature("android") or OS.has_feature("mobile")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_configure_ui_layers()
	_connect_buttons()
	_position_joysticks()
	emit_signal("move_input_changed", current_move_vector)
	set_interact_visible(false)
	print("[MobileControls] ready visible=", visible, " viewport=", get_viewport_rect().size)
	print("[MobileControls] move_joystick_base=", move_joystick_base)
	print("[MobileControls] move_joystick_knob=", move_joystick_knob)
	print("[MobileControls] camera_joystick_base=", camera_joystick_base)
	print("[MobileControls] camera_joystick_knob=", camera_joystick_knob)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_joysticks()


func get_move_vector() -> Vector2:
	return current_move_vector


func get_camera_vector() -> Vector2:
	return current_camera_vector


func set_interact_visible(should_show: bool) -> void:
	if interact_button != null:
		interact_button.visible = should_show


func reset_controls() -> void:
	_reset_move_joystick()
	_reset_camera_state()


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
	if _is_touch_over_ui_button(event.position):
		return

	if event.pressed:
		if _is_inside_control(move_joystick_touch, event.position):
			move_touch_index = event.index
			_update_move_joystick(event.position)
			print("[MobileControls] joystick start index=", event.index, " pos=", event.position)
			get_viewport().set_input_as_handled()
			return
		if _is_inside_control(camera_joystick_touch, event.position):
			camera_touch_index = event.index
			_update_camera_joystick(event.position)
			print("[MobileControls] camera joystick start index=", event.index)
			get_viewport().set_input_as_handled()
			return
	else:
		if event.index == move_touch_index:
			_reset_move_joystick()
			get_viewport().set_input_as_handled()
			return
		if event.index == camera_touch_index:
			_reset_camera_state()
			get_viewport().set_input_as_handled()
			return


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == move_touch_index:
		_update_move_joystick(event.position)
		get_viewport().set_input_as_handled()
		return

	if event.index == camera_touch_index:
		_update_camera_joystick(event.position)
		get_viewport().set_input_as_handled()
		return


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if _is_touch_over_ui_button(event.position):
		return
	if event.pressed:
		if _is_inside_control(move_joystick_touch, event.position):
			_mouse_move_active = true
			_update_move_joystick(event.position)
			print("[MobileControls] mouse joystick start=", event.position)
		elif _is_inside_control(camera_joystick_touch, event.position):
			_mouse_camera_active = true
			print("[MobileControls] mouse camera start=", event.position)
	else:
		if _mouse_move_active:
			print("[MobileControls] mouse joystick end")
			_reset_move_joystick()
		if _mouse_camera_active:
			print("[MobileControls] mouse camera end")
			_reset_camera_state()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _mouse_move_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_move_joystick(event.position)
		print("[MobileControls] mouse drag=", event.position, " vector=", current_move_vector)
		return

	if _mouse_camera_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_camera_joystick(event.position)
		print("[MobileControls] mouse camera drag=", event.position, " relative=", event.relative)
		get_viewport().set_input_as_handled()


func _position_joysticks() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if move_joystick_touch != null:
		move_joystick_touch.size = Vector2(210.0, 210.0)
		move_joystick_touch.global_position = Vector2(70.0, viewport_size.y - 280.0)
		move_joystick_touch.visible = true
		move_joystick_touch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if move_joystick_base != null:
		move_joystick_base.size = Vector2(210.0, 210.0)
		move_joystick_base.position = Vector2.ZERO
		move_joystick_base.visible = true
		move_joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if move_joystick_knob != null:
		move_joystick_knob.size = Vector2(76.0, 76.0)
		move_joystick_knob.visible = true
		move_joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_joystick_touch != null:
		camera_joystick_touch.size = Vector2(180.0, 180.0)
		camera_joystick_touch.global_position = Vector2(viewport_size.x - 250.0, viewport_size.y - 250.0)
		camera_joystick_touch.visible = true
		camera_joystick_touch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_joystick_base != null:
		camera_joystick_base.size = Vector2(180.0, 180.0)
		camera_joystick_base.position = Vector2.ZERO
		camera_joystick_base.visible = true
		camera_joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_joystick_knob != null:
		camera_joystick_knob.size = Vector2(64.0, 64.0)
		camera_joystick_knob.visible = true
		camera_joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_drag_area != null:
		camera_drag_area.visible = false
	if camera_touch_hint != null:
		camera_touch_hint.visible = false
	_reset_move_joystick()
	_reset_camera_joystick_visual()


func _get_move_center() -> Vector2:
	if move_joystick_touch != null:
		return move_joystick_touch.global_position + (move_joystick_touch.size * 0.5)
	return Vector2.ZERO


func _get_camera_center() -> Vector2:
	if camera_joystick_base != null:
		return camera_joystick_base.global_position + (camera_joystick_base.size * 0.5)
	return Vector2.ZERO


func _update_move_joystick(screen_position: Vector2) -> void:
	var center: Vector2 = _get_move_center()
	var delta: Vector2 = screen_position - center
	var clamped: Vector2 = delta.limit_length(move_joystick_radius)
	var raw_vector: Vector2 = clamped / move_joystick_radius
	if raw_vector.length() < joystick_deadzone:
		current_move_vector = Vector2.ZERO
	else:
		var strength: float = inverse_lerp(joystick_deadzone, 1.0, raw_vector.length())
		strength = pow(strength, joystick_response_curve)
		current_move_vector = raw_vector.normalized() * strength
	if move_joystick_knob != null:
		move_joystick_knob.global_position = center + clamped - (move_joystick_knob.size * 0.5)
	emit_signal("move_input_changed", current_move_vector)
	_log_move_vector(current_move_vector)


func _update_camera_joystick(screen_position: Vector2) -> void:
	var center: Vector2 = _get_camera_center()
	var delta: Vector2 = screen_position - center
	var clamped: Vector2 = delta.limit_length(camera_joystick_radius)
	var raw_vector: Vector2 = clamped / camera_joystick_radius
	if raw_vector.length() < camera_deadzone:
		current_camera_vector = Vector2.ZERO
	else:
		var strength: float = inverse_lerp(camera_deadzone, 1.0, raw_vector.length())
		strength = pow(strength, camera_joystick_response_curve)
		current_camera_vector = raw_vector.normalized() * strength
	if camera_joystick_knob != null:
		camera_joystick_knob.global_position = center + clamped - (camera_joystick_knob.size * 0.5)
	_log_camera_vector(current_camera_vector)


func _reset_camera_joystick_visual() -> void:
	if camera_joystick_knob != null:
		camera_joystick_knob.global_position = _get_camera_center() - (camera_joystick_knob.size * 0.5)


func _connect_buttons() -> void:
	print("[MobileControls] menu_button=", menu_button)
	print("[MobileControls] interact_button=", interact_button)
	if menu_button != null and not menu_button.pressed.is_connected(_on_menu_button_pressed):
		menu_button.pressed.connect(_on_menu_button_pressed)
	if interact_button != null and not interact_button.pressed.is_connected(_on_interact_button_pressed):
		interact_button.pressed.connect(_on_interact_button_pressed)


func _configure_ui_layers() -> void:
	if move_joystick_touch != null:
		move_joystick_touch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if move_joystick_base != null:
		move_joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if move_joystick_knob != null:
		move_joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_joystick_touch != null:
		camera_joystick_touch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_joystick_base != null:
		camera_joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if camera_joystick_knob != null:
		camera_joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if menu_button != null:
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
		menu_button.z_index = 60
		if not menu_button.is_in_group("ui_action_button"):
			menu_button.add_to_group("ui_action_button")
	if interact_button != null:
		interact_button.mouse_filter = Control.MOUSE_FILTER_STOP
		interact_button.z_index = 60
		if not interact_button.is_in_group("ui_action_button"):
			interact_button.add_to_group("ui_action_button")
	if camera_drag_area != null:
		camera_drag_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
		camera_drag_area.z_index = 1
	if camera_touch_hint != null:
		camera_touch_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		camera_touch_hint.z_index = 2


func _is_touch_over_ui_button(screen_position: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group("ui_action_button"):
		if node is Control and _is_screen_position_over_control(node as Control, screen_position):
			return true
	return false


func _is_screen_position_over_control(control: Control, screen_position: Vector2) -> bool:
	if control == null or not control.visible:
		return false
	return control.get_global_rect().has_point(screen_position)


func _is_inside_control(control: Control, screen_position: Vector2) -> bool:
	if control == null or not control.visible:
		return false
	var rect := Rect2(control.global_position, control.size)
	return rect.has_point(screen_position)


func _on_interact_button_pressed() -> void:
	print("[UI] Interact pressed")
	emit_signal("interact_pressed")


func _on_menu_button_pressed() -> void:
	print("[UI] Menu pressed")
	emit_signal("menu_pressed")


func _log_move_vector(value: Vector2) -> void:
	if value == Vector2.ZERO or _last_logged_move_vector.distance_to(value) >= 0.15:
		print("[MobileControls] joystick vector=", value)
		_last_logged_move_vector = value


func _log_camera_vector(value: Vector2) -> void:
	if value == Vector2.ZERO or _last_logged_camera_vector.distance_to(value) >= 0.12:
		print("[MobileControls] current_camera_vector=", value)
		_last_logged_camera_vector = value


func _reset_move_joystick() -> void:
	move_touch_index = -1
	_mouse_move_active = false
	current_move_vector = Vector2.ZERO
	if move_joystick_knob != null:
		move_joystick_knob.global_position = _get_move_center() - (move_joystick_knob.size * 0.5)
	emit_signal("move_input_changed", current_move_vector)
	_log_move_vector(current_move_vector)
	print("[MobileControls] joystick reset")


func _reset_camera_state() -> void:
	camera_touch_index = -1
	_mouse_camera_active = false
	current_camera_vector = Vector2.ZERO
	_reset_camera_joystick_visual()
	_log_camera_vector(current_camera_vector)
	print("[MobileControls] camera joystick reset")
