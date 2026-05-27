extends Control
class_name MobileControls

signal move_input_changed(value: Vector2)
signal camera_dragged(relative: Vector2)
signal interact_pressed
signal menu_pressed

@export var joystick_radius: float = 54.0
@export var camera_drag_scale: float = 0.75

@onready var joystick_touch: Control = get_node_or_null("BottomLeft/JoystickTouch")
@onready var knob: ColorRect = get_node_or_null("BottomLeft/JoystickTouch/Knob")
@onready var interact_button: Button = get_node_or_null("BottomRight/InteractButton")
@onready var menu_button: Button = get_node_or_null("TopRight/MenuButton")
@onready var camera_drag_area: Control = get_node_or_null("RightDragArea")

var _dragging_camera: bool = false
var _active_move_input: Vector2 = Vector2.ZERO


func _ready() -> void:
	if not is_in_group("mobile_controls"):
		add_to_group("mobile_controls")
	emit_signal("move_input_changed", Vector2.ZERO)
	set_interact_visible(false)


func set_interact_visible(should_show: bool) -> void:
	if interact_button == null:
		return
	interact_button.visible = should_show


func reset_controls() -> void:
	_active_move_input = Vector2.ZERO
	_dragging_camera = false
	if knob != null:
		knob.position = Vector2(56, 56)
	emit_signal("move_input_changed", Vector2.ZERO)


func _on_joystick_touch_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if not event.pressed:
			reset_controls()
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if joystick_touch == null or knob == null:
			return
		var local_pos: Vector2 = joystick_touch.get_local_mouse_position()
		var center: Vector2 = Vector2(96, 96)
		var offset: Vector2 = (local_pos - center).limit_length(joystick_radius)
		_active_move_input = offset / joystick_radius
		knob.position = center + offset - Vector2(40, 40)
		emit_signal("move_input_changed", _active_move_input)


func _on_right_drag_area_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		_dragging_camera = event.pressed
	if event is InputEventScreenDrag:
		emit_signal("camera_dragged", event.relative * camera_drag_scale)
	elif event is InputEventMouseMotion and _dragging_camera and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		emit_signal("camera_dragged", event.relative * camera_drag_scale)


func _on_interact_button_pressed() -> void:
	emit_signal("interact_pressed")


func _on_menu_button_pressed() -> void:
	emit_signal("menu_pressed")


func get_move_vector() -> Vector2:
	return _active_move_input
