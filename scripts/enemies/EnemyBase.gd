extends CharacterBody3D
class_name EnemyBase

@export var enemy_id: String = "slime_human_eyes"

@onready var ai: EnemyAI = $AI
@onready var health_bar: ProgressBar = $SubViewport/EnemyUI/LifeBar
@onready var mesh: MeshInstance3D = $Visual

var enemy_name: String = "Inimigo"
var max_health: float = 30.0
var current_health: float = 30.0
var max_mana: float = 0.0
var current_mana: float = 0.0
var strength: float = 8.0
var defense: float = 4.0
var intelligence: float = 4.0
var luck: float = 3.0
var move_speed: float = 2.5
var detection_range: float = 10.0
var attack_range: float = 2.0
var attack_cooldown: float = 1.6
var attack_timer: float = 0.0
var is_dead: bool = false
var spawn_position: Vector3 = Vector3.ZERO
var patrol_seed: float = 0.0
var status_name: String = ""
var status_time: float = 0.0
var status_power: float = 1.0
var tags: Array[String] = []
var pending_critical: bool = false

func _ready() -> void:
	add_to_group("enemies")
	spawn_position = global_position
	patrol_seed = randf_range(0.0, 10.0)
	ai.setup(self)
	_load_data()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	if not is_on_floor():
		velocity.y -= 14.0 * delta
	else:
		velocity.y = -0.1
	ai.process_behavior(delta)
	health_bar.max_value = max_health
	health_bar.value = current_health


func receive_damage(amount: float, _source: Node) -> void:
	if is_dead:
		return
	current_health = maxf(0.0, current_health - amount)
	GameManager.spawn_damage_number(amount, global_position + Vector3.UP * 2.2, pending_critical)
	pending_critical = false
	if current_health <= 0.0:
		die()


func attack_player(player: PlayerController) -> void:
	attack_timer = attack_cooldown
	var base_damage: float = maxf(1.0, strength - player.stats.defense * 0.5)
	player.stats.receive_damage(snappedf(base_damage * randf_range(0.9, 1.1), 0.1))
	if enemy_id == "draconic_sprout" and randf() < 0.35:
		player.apply_temporary_modifier("pollen_slow", {"speed_mult": 0.7}, 2.0)
		GameManager.show_message("Você foi desacelerado.")


func get_player() -> PlayerController:
	return GameManager.current_player as PlayerController


func has_tag(tag: String) -> bool:
	return tags.has(tag)


func apply_status(new_status: String, duration: float, power: float) -> void:
	status_name = new_status
	status_time = duration
	if power > 0.0:
		status_power = power
	else:
		status_power = 1.0


func clear_status() -> void:
	status_name = ""
	status_power = 1.0
	status_time = 0.0


func die() -> void:
	is_dead = true
	mesh.visible = false
	$CollisionShape3D.disabled = true
	GameManager.show_message("%s derrotado." % enemy_name)
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _load_data() -> void:
	var data: Dictionary = EnemyData.get_enemy(enemy_id)
	enemy_name = data.get("display_name", "Inimigo")
	max_health = float(data.get("max_health", 30.0))
	current_health = max_health
	max_mana = float(data.get("max_mana", 0.0))
	current_mana = max_mana
	strength = float(data.get("strength", 8.0))
	defense = float(data.get("defense", 4.0))
	intelligence = float(data.get("intelligence", 2.0))
	luck = float(data.get("luck", 3.0))
	move_speed = float(data.get("move_speed", 2.5))
	detection_range = float(data.get("detection_range", 10.0))
	attack_range = float(data.get("attack_range", 2.0))
	attack_cooldown = float(data.get("attack_cooldown", 1.6))
	tags.clear()
	var raw_tags: Array = data.get("tags", [])
	for raw_tag in raw_tags:
		tags.append(str(raw_tag))
