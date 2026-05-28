extends Control
class_name MobileControls

signal move_input_changed(value: Vector2)
signal camera_dragged(relative: Vector2)
signal interact_pressed
signal menu_pressed

@export var debug_show_in_editor: bool = true
@export var force_show_mobile_controls: bool = true
@export var joystick_radius: float = 110.0
@export var camera_drag_scale: float = 0.55

@onready var joystick_touch_area: Control = get_node_or_null("BottomLeft/JoystickTouch")
@onready var joystick_base: Control = get_node_or_null("BottomLeft/JoystickTouch/Base")
@onready var joystick_knob: Control = get_node_or_null("BottomLeft/JoystickTouch/Knob")
@onready var menu_button: Button = get_node_or_null("TopRight/MenuButton")
@onready var interact_button: Button = get_node_or_null("BottomRight/InteractButton")
@onready var right_drag_area: Control = get_node_or_null("RightDragArea")

var current_move_vector: Vector2 = Vector2.ZERO
var joystick_active: bool = false
var joystick_touch_index: int = -1
var camera_touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var _mouse_joystick_active: bool = false
var _mouse_camera_active: bool = false
var _last_logged_move_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not is_in_group("mobile_controls"):
		add_to_group("mobile_controls")
	visible = force_show_mobile_controls or OS.has_feature("android") or OS.has_feature("mobile")
	mouse_filter = Control.MOUSE_FILTER_PASS
	_configure_ui_layers()
	_connect_buttons()
	_position_joystick()
	emit_signal("move_input_changed", current_move_vector)
	set_interact_visible(false)
	print("[MobileControls] ready visible=", visible, " viewport=", get_viewport_rect().size)
	print("[MobileControls] joystick_base=", joystick_base)
	print("[MobileControls] joystick_knob=", joystick_knob)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_position_joystick()


func get_move_vector() -> Vector2:
	return current_move_vector


func set_interact_visible(should_show: bool) -> void:
	if interact_button != null:
		interact_button.visible = should_show


func reset_controls() -> void:
	_reset_joystick_state()
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
		if event.position.x < get_viewport_rect().size.x * 0.50 and not joystick_active:
			joystick_active = true
			joystick_touch_index = event.index
			_update_joystick_from_position(event.position)
			print("[MobileControls] joystick start index=", event.index, " pos=", event.position)
			get_viewport().set_input_as_handled()
		elif event.position.x >= get_viewport_rect().size.x * 0.50 and camera_touch_index == -1:
			camera_touch_index = event.index
			print("[MobileControls] camera start index=", event.index, " pos=", event.position)
			get_viewport().set_input_as_handled()
	else:
		if event.index == joystick_touch_index:
			print("[MobileControls] joystick end index=", event.index)
			_reset_joystick_state()
			get_viewport().set_input_as_handled()
		if event.index == camera_touch_index:
			print("[MobileControls] camera end")
			_reset_camera_state()
			get_viewport().set_input_as_handled()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_index and joystick_active:
		_update_joystick_from_position(event.position)
		print("[MobileControls] joystick drag index=", event.index, " vector=", current_move_vector)
		get_viewport().set_input_as_handled()
		return

	if event.index == camera_touch_index:
		emit_signal("camera_dragged", event.relative * camera_drag_scale)
		print("[MobileControls] camera drag=", event.position, " relative=", event.relative)
		get_viewport().set_input_as_handled()


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if _is_touch_over_ui_button(event.position):
		return
	if event.pressed:
		if event.position.x < get_viewport_rect().size.x * 0.50:
			_mouse_joystick_active = true
			_update_joystick_from_position(event.position)
			print("[MobileControls] mouse joystick start=", event.position)
		elif event.position.x >= get_viewport_rect().size.x * 0.50:
			_mouse_camera_active = true
			print("[MobileControls] mouse camera start=", event.position)
	else:
		if _mouse_joystick_active:
			print("[MobileControls] mouse joystick end")
			_reset_joystick_state()
		if _mouse_camera_active:
			print("[MobileControls] mouse camera end")
			_reset_camera_state()


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _mouse_joystick_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_joystick_from_position(event.position)
		print("[MobileControls] mouse drag=", event.position, " vector=", current_move_vector)
		return

	if _mouse_camera_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		emit_signal("camera_dragged", event.relative * camera_drag_scale)
		print("[MobileControls] mouse camera drag=", event.position, " relative=", event.relative)


func _position_joystick() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if joystick_touch_area != null:
		joystick_touch_area.size = Vector2(180.0, 180.0)
		joystick_touch_area.global_position = Vector2(70.0, viewport_size.y - 250.0)
		joystick_touch_area.visible = true
		joystick_touch_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if joystick_base != null:
		joystick_base.size = Vector2(180.0, 180.0)
		joystick_base.position = Vector2.ZERO
		joystick_base.visible = true
		joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if joystick_knob != null:
		joystick_knob.size = Vector2(70.0, 70.0)
		joystick_knob.visible = true
		joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reset_joystick_knob()
	_update_joystick_center()


func _update_joystick_center() -> void:
	joystick_center = _get_joystick_center()


func _get_joystick_center() -> Vector2:
	if joystick_touch_area != null:
		return joystick_touch_area.global_position + (joystick_touch_area.size * 0.5)
	return Vector2.ZERO


func _update_joystick_from_position(screen_position: Vector2) -> void:
	var center: Vector2 = _get_joystick_center()
	var delta: Vector2 = screen_position - center
	var clamped: Vector2 = delta.limit_length(joystick_radius)
	current_move_vector = clamped / joystick_radius
	if joystick_knob != null:
		joystick_knob.global_position = center + clamped - (joystick_knob.size * 0.5)
	emit_signal("move_input_changed", current_move_vector)
	_log_move_vector(current_move_vector)


func _reset_joystick_knob() -> void:
	if joystick_knob != null:
		joystick_knob.global_position = _get_joystick_center() - (joystick_knob.size * 0.5)


func _connect_buttons() -> void:
	print("[MobileControls] menu_button=", menu_button)
	print("[MobileControls] interact_button=", interact_button)
	if menu_button != null and not menu_button.pressed.is_connected(_on_menu_button_pressed):
		menu_button.pressed.connect(_on_menu_button_pressed)
	if interact_button != null and not interact_button.pressed.is_connected(_on_interact_button_pressed):
		interact_button.pressed.connect(_on_interact_button_pressed)


func _configure_ui_layers() -> void:
	if joystick_touch_area != null:
		joystick_touch_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if joystick_base != null:
		joystick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if joystick_knob != null:
		joystick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if menu_button != null:
		menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if not menu_button.is_in_group("ui_action_button"):
			menu_button.add_to_group("ui_action_button")
	if interact_button != null:
		interact_button.mouse_filter = Control.MOUSE_FILTER_STOP
		if not interact_button.is_in_group("ui_action_button"):
			interact_button.add_to_group("ui_action_button")
	if right_drag_area != null:
		right_drag_area.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _is_touch_over_ui_button(screen_position: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group("ui_action_button"):
		if node is Control and _is_screen_position_over_control(node as Control, screen_position):
			return true
	return false


func _is_screen_position_over_control(control: Control, screen_position: Vector2) -> bool:
	if control == null or not control.visible:
		return false
	return control.get_global_rect().has_point(screen_position)


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


func _reset_joystick_state() -> void:
	joystick_active = false
	joystick_touch_index = -1
	_mouse_joystick_active = false
	current_move_vector = Vector2.ZERO
	_reset_joystick_knob()
	emit_signal("move_input_changed", current_move_vector)
	_log_move_vector(current_move_vector)
	print("[MobileControls] joystick reset")


func _reset_camera_state() -> void:
	camera_touch_index = -1
	_mouse_camera_active = false
