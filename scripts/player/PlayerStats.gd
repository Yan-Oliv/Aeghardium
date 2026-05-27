extends Node
class_name PlayerStats

signal stats_changed
signal died
signal damaged(amount: float)

var max_health: float = 100.0
var current_health: float = 100.0
var max_mana: float = 50.0
var current_mana: float = 50.0
var strength: float = 10.0
var defense: float = 10.0
var intelligence: float = 10.0
var luck: float = 10.0
var weak_poison := false
var last_combat_time := -99.0
var active_modifiers := {}

func configure_from_class(class_info: Dictionary) -> void:
	var base: Dictionary = class_info.get("stats", {})
	max_health = float(base.get("vida", 100))
	current_health = max_health
	max_mana = float(base.get("mana", 50))
	current_mana = max_mana
	strength = float(base.get("forca", 10))
	defense = float(base.get("defesa", 10))
	intelligence = float(base.get("inteligencia", 10))
	luck = float(base.get("sorte", 10))
	stats_changed.emit()


func load_snapshot(data: Dictionary) -> void:
	max_health = float(data.get("max_health", max_health))
	current_health = float(data.get("current_health", max_health))
	max_mana = float(data.get("max_mana", max_mana))
	current_mana = float(data.get("current_mana", max_mana))
	strength = float(data.get("strength", strength))
	defense = float(data.get("defense", defense))
	intelligence = float(data.get("intelligence", intelligence))
	luck = float(data.get("luck", luck))
	weak_poison = bool(data.get("weak_poison", false))
	stats_changed.emit()


func to_dictionary() -> Dictionary:
	return {
		"max_health": max_health,
		"current_health": current_health,
		"max_mana": max_mana,
		"current_mana": current_mana,
		"strength": strength,
		"defense": defense,
		"intelligence": intelligence,
		"luck": luck,
		"weak_poison": weak_poison
	}


func receive_damage(amount: float) -> void:
	last_combat_time = Time.get_ticks_msec() / 1000.0
	current_health = maxf(0.0, current_health - amount)
	damaged.emit(amount)
	stats_changed.emit()
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	current_health = minf(max_health, current_health + amount)
	stats_changed.emit()


func spend_mana(amount: float) -> bool:
	if current_mana < amount:
		return false
	current_mana -= amount
	last_combat_time = Time.get_ticks_msec() / 1000.0
	stats_changed.emit()
	return true


func restore_mana(amount: float) -> void:
	current_mana = minf(max_mana, current_mana + amount)
	stats_changed.emit()


func in_combat() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	return now - last_combat_time < Constants.OUT_OF_COMBAT_DELAY


func apply_modifier(modifier_name: String, payload: Dictionary) -> void:
	active_modifiers[modifier_name] = payload


func clear_modifier(modifier_name: String) -> void:
	active_modifiers.erase(modifier_name)
