extends Node
class_name PlayerCombat

var owner_player: PlayerController = null
var attack_cooldown: float = 0.0
var current_target: EnemyBase = null

func setup(player: PlayerController) -> void:
	owner_player = player


func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	current_target = _find_target()


func get_current_target() -> EnemyBase:
	return current_target


func try_basic_attack() -> void:
	if attack_cooldown > 0.0 or owner_player.is_dead:
		return
	var class_id: String = owner_player.class_id
	match class_id:
		"archer":
			_ranged_attack(1.0, 9.0, false)
		"mage":
			_ranged_attack(1.0, 9.0, true)
		_:
			_melee_attack(1.0, false, false)
	attack_cooldown = 0.7
	owner_player.on_attack_performed()


func _melee_attack(multiplier: float, guaranteed_crit: bool, holy_bonus: bool) -> float:
	var target: EnemyBase = _find_target()
	if target == null:
		return 0.0
	var backstab_bonus: float = 1.0
	if owner_player.class_id == "assassin":
		var to_player: Vector3 = (owner_player.global_position - target.global_position).normalized()
		if target.global_basis.z.dot(to_player) > 0.4:
			guaranteed_crit = true
			backstab_bonus = 2.0
	var damage: float = calculate_physical_damage(owner_player.stats, target, multiplier * backstab_bonus, guaranteed_crit)
	if holy_bonus and (target.has_tag(Constants.ENEMY_TAGS["UNDEAD"]) or target.has_tag(Constants.ENEMY_TAGS["DEMON"])):
		damage += 6.0
	target.receive_damage(damage, owner_player)
	return damage


func _ranged_attack(multiplier: float, range_limit: float, magic: bool) -> float:
	var target: EnemyBase = _find_target(range_limit)
	if target == null:
		return 0.0
	var damage: float = 0.0
	if magic:
		damage = calculate_magic_damage(owner_player.stats, target, multiplier)
	else:
		damage = calculate_physical_damage(owner_player.stats, target, multiplier, false)
	target.receive_damage(damage, owner_player)
	return damage


func calculate_physical_damage(attacker_stats: PlayerStats, target: EnemyBase, multiplier: float = 1.0, guaranteed_crit: bool = false) -> float:
	var value: float = maxf(1.0, attacker_stats.strength - target.defense * 0.5) * multiplier
	var variation: float = randf_range(0.9, 1.1)
	value *= variation
	var crit: bool = guaranteed_crit or randf() < get_crit_chance(attacker_stats.luck)
	if crit:
		value *= 1.5
	target.pending_critical = crit
	return snappedf(value, 0.1)


func calculate_magic_damage(attacker_stats: PlayerStats, target: EnemyBase, multiplier: float) -> float:
	var value: float = maxf(1.0, attacker_stats.intelligence * multiplier - target.defense * 0.25)
	value *= randf_range(0.9, 1.1)
	var crit: bool = randf() < get_crit_chance(attacker_stats.luck)
	if crit:
		value *= 1.5
	target.pending_critical = crit
	return snappedf(value, 0.1)


func get_crit_chance(luck_value: float) -> float:
	return clampf(Constants.BASE_CRIT_CHANCE + luck_value * 0.005, Constants.BASE_CRIT_CHANCE, Constants.MAX_CRIT_CHANCE)


func _find_target(range_override: float = 2.6) -> EnemyBase:
	var best: EnemyBase = null
	var best_distance: float = INF
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		var enemy: EnemyBase = enemy_node as EnemyBase
		if enemy == null:
			continue
		if not is_instance_valid(enemy) or enemy.is_dead:
			continue
		var distance: float = owner_player.global_position.distance_to(enemy.global_position)
		if distance > range_override:
			continue
		if distance < best_distance:
			best = enemy
			best_distance = distance
	return best
