extends CharacterBody3D

var owner_player = null
var life_time := 15.0
var attack_timer := 0.0

func setup(player, duration: float) -> void:
	owner_player = player
	life_time = duration


func _physics_process(delta: float) -> void:
	life_time -= delta
	if life_time <= 0.0:
		queue_free()
		return
	attack_timer -= delta
	var target = _find_target()
	if target != null:
		var direction := (target.global_position - global_position).normalized()
		velocity = Vector3(direction.x, velocity.y, direction.z) * 3.2
		if global_position.distance_to(target.global_position) < 1.6 and attack_timer <= 0.0:
			target.receive_damage(6.0, owner_player)
			attack_timer = 1.0
	else:
		var follow := (owner_player.global_position - global_position).normalized()
		velocity = Vector3(follow.x, velocity.y, follow.z) * 2.8
	move_and_slide()


func _find_target():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy) and not enemy.is_dead and global_position.distance_to(enemy.global_position) < 6.0:
			return enemy
	return null

