extends Node3D

@onready var label: Label3D = $Label3D

var rise_speed := 1.5

func setup(amount: float, critical: bool) -> void:
	label.text = str(snappedf(amount, 0.1))
	if critical:
		label.modulate = Color(1.0, 0.88, 0.45, 1.0)
	else:
		label.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _process(delta: float) -> void:
	global_position.y += rise_speed * delta
	label.modulate.a = maxf(0.0, label.modulate.a - delta)
	if label.modulate.a <= 0.0:
		queue_free()
