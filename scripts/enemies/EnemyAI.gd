extends Node
class_name EnemyAI

var enemy: EnemyBase = null

func setup(owner_enemy: EnemyBase) -> void:
	enemy = owner_enemy


func process_behavior(delta: float) -> void:
	if enemy == null or enemy.is_dead:
		return
	enemy.status_time = maxf(0.0, enemy.status_time - delta)
	if enemy.status_name == "root":
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		enemy.move_and_slide()
		if enemy.status_time <= 0.0:
			enemy.clear_status()
		return
	var player: PlayerController = enemy.get_player()
	if player == null or player.is_dead:
		_patrol(delta)
		return
	if Time.get_ticks_msec() / 1000.0 < player.invisible_until:
		_patrol(delta)
		return
	var distance: float = enemy.global_position.distance_to(player.global_position)
	if distance <= enemy.detection_range:
		_chase(player, delta, distance)
	else:
		_patrol(delta)
	if enemy.status_time <= 0.0:
		enemy.clear_status()


func _patrol(delta: float) -> void:
	var patrol_offset: Vector3 = Vector3(sin(Time.get_ticks_msec() * 0.001 + enemy.patrol_seed), 0.0, cos(Time.get_ticks_msec() * 0.001 + enemy.patrol_seed))
	var target: Vector3 = enemy.spawn_position + patrol_offset * 2.0
	_move_towards(target, delta, 0.5)


func _chase(player: PlayerController, delta: float, distance: float) -> void:
	if enemy.status_name == "blind":
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		enemy.move_and_slide()
		return
	if distance > enemy.attack_range:
		_move_towards(player.global_position, delta, 1.0)
	else:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		if enemy.attack_timer <= 0.0:
			enemy.attack_player(player)


func _move_towards(target: Vector3, _delta: float, speed_mult: float) -> void:
	var direction: Vector3 = (target - enemy.global_position).normalized()
	var actual_speed: float = enemy.move_speed * speed_mult
	if enemy.status_name == "slow":
		actual_speed *= enemy.status_power
	enemy.velocity.x = direction.x * actual_speed
	enemy.velocity.z = direction.z * actual_speed
	if direction != Vector3.ZERO:
		var target_yaw: float = atan2(direction.x, direction.z)
		enemy.rotation.y = lerp_angle(enemy.rotation.y, target_yaw, 0.12)
	enemy.move_and_slide()
