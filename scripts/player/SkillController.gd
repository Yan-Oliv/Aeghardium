extends Node
class_name SkillController

var owner_player: PlayerController = null
var skill_ids: Array[String] = []
var cooldowns: Dictionary = {}

func setup(player: PlayerController, skills: Array[String]) -> void:
	owner_player = player
	skill_ids = skills
	cooldowns.clear()
	for index in range(skill_ids.size()):
		cooldowns[index] = 0.0


func _process(delta: float) -> void:
	for key in cooldowns.keys():
		cooldowns[key] = maxf(0.0, cooldowns[key] - delta)


func trigger_skill(index: int) -> void:
	if index < 0 or index >= skill_ids.size() or owner_player.is_dead:
		return
	if cooldowns.get(index, 0.0) > 0.0:
		return
	var skill_id: String = skill_ids[index]
	var skill_info: Dictionary = SkillData.get_skill(skill_id)
	var mana_cost: float = float(skill_info.get("mana_cost", 0.0))
	if not owner_player.stats.spend_mana(mana_cost):
		GameManager.show_message("Mana insuficiente.")
		return
	var cooldown: float = float(skill_info.get("cooldown", 1.0))
	var executed: bool = _execute_skill(skill_id)
	if not executed:
		owner_player.stats.restore_mana(mana_cost)
		return
	cooldowns[index] = cooldown
	if owner_player.hud != null:
		owner_player.hud.start_skill_cooldown(index + 1, cooldown)


func get_skill_name(index: int) -> String:
	if index >= skill_ids.size():
		return "--"
	return str(SkillData.get_skill(skill_ids[index]).get("name", "--"))


func _execute_skill(skill_id: String) -> bool:
	match skill_id:
		"death_touch":
			return _death_touch()
		"essence_drain":
			return _essence_drain()
		"backstab":
			owner_player.combat._melee_attack(1.0, true, false)
		"shadow_step":
			owner_player.shadow_step()
		"steady_slash":
			owner_player.combat._melee_attack(1.25, false, false)
		"stone_stance":
			owner_player.apply_temporary_modifier("stone_stance", {"defense_mult": 1.5, "speed_mult": 0.6}, 4.0)
		"piercing_arrow":
			_piercing_arrow()
		"rapid_shot":
			_rapid_shot()
		"spark":
			owner_player.combat._ranged_attack(1.2, 10.0, true)
		"ice_circle":
			_ice_circle()
		"frenzy_attack":
			_frenzy_attack()
		"war_cry":
			owner_player.apply_temporary_modifier("war_cry", {"strength_mult": 1.2, "defense_mult": 0.7}, 6.0)
		"creeping_thorns":
			_creeping_thorns()
		"healing_touch":
			owner_player.stats.heal(20.0)
		"blinding_light":
			_blinding_light()
		"lesser_blessing":
			owner_player.stats.weak_poison = false
			owner_player.stats.heal(25.0)
		"holy_strike":
			owner_player.combat._melee_attack(1.15, false, true)
		"protection_aura":
			owner_player.activate_protection_aura()
		_:
			return false
	return true


func _death_touch() -> bool:
	var killed: bool = false
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		var enemy: EnemyBase = enemy_node as EnemyBase
		if enemy == null:
			continue
		if owner_player.global_position.distance_to(enemy.global_position) <= 3.8:
			var damage: float = owner_player.combat.calculate_magic_damage(owner_player.stats, enemy, 1.05)
			var alive_before: bool = not enemy.is_dead
			enemy.receive_damage(damage, owner_player)
			if alive_before and enemy.is_dead:
				killed = true
	if killed:
		owner_player.spawn_skeleton_minion(15.0)
	return true


func _essence_drain() -> bool:
	var target: EnemyBase = owner_player.combat.get_current_target()
	if target == null:
		return false
	_channel_drain(target)
	return true


func _channel_drain(target: EnemyBase) -> void:
	for _index in range(4):
		if not is_instance_valid(target) or target.is_dead:
			return
		var damage: float = owner_player.combat.calculate_magic_damage(owner_player.stats, target, 0.45)
		target.receive_damage(damage, owner_player)
		owner_player.stats.heal(3.0)
		await get_tree().create_timer(0.5).timeout


func _piercing_arrow() -> void:
	var targets: Array = []
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		var enemy: EnemyBase = enemy_node as EnemyBase
		if enemy == null:
			continue
		if owner_player.global_position.distance_to(enemy.global_position) <= 10.0:
			targets.append(enemy)
	targets.sort_custom(Callable(self, "_sort_targets_by_distance"))
	for index in range(min(2, targets.size())):
		var enemy: EnemyBase = targets[index] as EnemyBase
		var damage: float = owner_player.combat.calculate_physical_damage(owner_player.stats, enemy, 1.1, false)
		enemy.receive_damage(damage, owner_player)


func _rapid_shot() -> void:
	for _index in range(3):
		owner_player.combat._ranged_attack(0.65, 10.0, false)
		await get_tree().create_timer(0.33).timeout


func _ice_circle() -> void:
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		var enemy: EnemyBase = enemy_node as EnemyBase
		if enemy == null:
			continue
		if owner_player.global_position.distance_to(enemy.global_position) <= 4.5:
			enemy.apply_status("slow", 4.0, 0.45)


func _frenzy_attack() -> void:
	var hp_ratio: float = owner_player.stats.current_health / maxf(1.0, owner_player.stats.max_health)
	var bonus: float = 1.0
	if hp_ratio < 0.25:
		bonus = 1.6
	elif hp_ratio < 0.5:
		bonus = 1.35
	elif hp_ratio < 0.75:
		bonus = 1.15
	owner_player.combat._melee_attack(bonus, false, false)


func _creeping_thorns() -> void:
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		var enemy: EnemyBase = enemy_node as EnemyBase
		if enemy == null:
			continue
		if owner_player.global_position.distance_to(enemy.global_position) <= 3.6:
			var damage: float = owner_player.combat.calculate_magic_damage(owner_player.stats, enemy, 0.85)
			enemy.receive_damage(damage, owner_player)
			enemy.apply_status("root", 1.0, 0.0)


func _blinding_light() -> void:
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		var enemy: EnemyBase = enemy_node as EnemyBase
		if enemy == null:
			continue
		if owner_player.global_position.distance_to(enemy.global_position) <= 4.5:
			if enemy.has_tag(Constants.ENEMY_TAGS["HUMAN"]) or enemy.has_tag(Constants.ENEMY_TAGS["UNDEAD"]) or enemy.has_tag(Constants.ENEMY_TAGS["CORRUPTED"]):
				enemy.apply_status("blind", 3.0, 0.0)


func _sort_targets_by_distance(a: EnemyBase, b: EnemyBase) -> bool:
	return owner_player.global_position.distance_to(a.global_position) < owner_player.global_position.distance_to(b.global_position)
