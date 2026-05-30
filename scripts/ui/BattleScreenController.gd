extends Control

var player_state: Dictionary = {}
var enemy_state: Dictionary = {}
var player_status: Dictionary = {}
var enemy_status: Dictionary = {}
var turn_order: Array[String] = []
var turn_index: int = 0
var battle_finished: bool = false
var round_count: int = 1
var player_flash_alpha: float = 0.0
var enemy_flash_alpha: float = 0.0
var class_icons: Dictionary = {
	"necromancer": "NEC",
	"assassin": "DAG",
	"warrior": "SWD",
	"archer": "BOW",
	"mage": "ARC",
	"berserker": "AXE",
	"druid": "LEF",
	"cleric": "LUX",
	"paladin": "SHD"
}

@onready var battle_title: Label = $MarginContainer/VBoxContainer/Header/HeaderBox/BattleTitle
@onready var biome_label: Label = $MarginContainer/VBoxContainer/Header/HeaderBox/BiomeLabel
@onready var turn_label: Label = $MarginContainer/VBoxContainer/Header/HeaderBox/TurnLabel
@onready var enemy_name_label: Label = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyRow/EnemyColumn/EnemyName
@onready var enemy_hp_bar: ProgressBar = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyRow/EnemyColumn/Stats/EnemyHPBar
@onready var enemy_hp_label: Label = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyRow/EnemyColumn/Stats/EnemyHP
@onready var enemy_meta_label: Label = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyRow/EnemyColumn/EnemyMeta
@onready var player_name_label: Label = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/PlayerColumn/PlayerName
@onready var player_hp_bar: ProgressBar = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/PlayerColumn/Stats/PlayerHPBar
@onready var player_mp_bar: ProgressBar = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/PlayerColumn/Stats/PlayerMPBar
@onready var player_hp_label: Label = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/PlayerColumn/Stats/PlayerHP
@onready var player_mp_label: Label = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/PlayerColumn/Stats/PlayerMP
@onready var player_meta_label: Label = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/PlayerColumn/PlayerMeta
@onready var skill_one_button: Button = $MarginContainer/VBoxContainer/Actions/SkillOneButton
@onready var skill_two_button: Button = $MarginContainer/VBoxContainer/Actions/SkillTwoButton
@onready var log_label: RichTextLabel = $MarginContainer/VBoxContainer/LogPanel/LogLabel
@onready var sky_rect: ColorRect = $Background/Sky
@onready var mist_rect: ColorRect = $Background/Mist
@onready var backdrop_props: Control = $Background/BackdropProps
@onready var ground_rect: ColorRect = $Background/Ground
@onready var enemy_banner: Label = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyRow/Portrait/EnemyGlyph
@onready var player_banner: Label = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/Portrait/PlayerGlyph
@onready var enemy_texture: TextureRect = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyRow/Portrait/EnemyTexture
@onready var player_texture: TextureRect = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerRow/Portrait/PlayerTexture
@onready var player_panel: PanelContainer = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel
@onready var enemy_panel: PanelContainer = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel
@onready var player_flash: ColorRect = $MarginContainer/VBoxContainer/CombatRow/PlayerPanel/PlayerFlash
@onready var enemy_flash: ColorRect = $MarginContainer/VBoxContainer/CombatRow/EnemyPanel/EnemyFlash


func _ready() -> void:
	UITheme.apply(self)
	_tune_action_buttons()
	player_state = GameManager.get_player_state().duplicate(true)
	enemy_state = GameManager.get_current_battle_data().duplicate(true)
	if player_state.is_empty() or enemy_state.is_empty():
		GameManager.show_base()
		return
	_apply_biome()
	_prepare_portraits()
	var skills: Array = player_state.get("skill_ids", [])
	skill_one_button.text = str(SkillData.get_skill(skills[0] if skills.size() > 0 else "").get("name", "Skill 1"))
	skill_two_button.text = str(SkillData.get_skill(skills[1] if skills.size() > 1 else "").get("name", "Skill 2"))
	_append_log("[color=#d8c89a]Um inimigo apareceu no andar %s.[/color]" % enemy_state.get("floor", 1))
	_update_labels()
	_start_round()


func _tune_action_buttons() -> void:
	var attack_button: Button = $MarginContainer/VBoxContainer/Actions/AttackButton
	var item_button: Button = $MarginContainer/VBoxContainer/Actions/ItemButton
	var defend_button: Button = $MarginContainer/VBoxContainer/Actions/DefendButton
	for button in [
		attack_button,
		$MarginContainer/VBoxContainer/Actions/SkillOneButton,
		$MarginContainer/VBoxContainer/Actions/SkillTwoButton,
		item_button,
		defend_button,
		$MarginContainer/VBoxContainer/Actions/FleeButton
	]:
		button.custom_minimum_size.y = 44
	attack_button.icon = PixelAssetRegistry.get_item_icon_texture("short_sword")
	item_button.icon = PixelAssetRegistry.get_item_icon_texture("small_potion")
	defend_button.icon = PixelAssetRegistry.get_item_icon_texture("light_shield")
	player_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	player_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	player_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	enemy_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	enemy_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	player_banner.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	enemy_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	enemy_banner.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	player_banner.modulate = Color(1, 1, 1, 0.82)
	enemy_banner.modulate = Color(1, 1, 1, 0.82)


func _prepare_portraits() -> void:
	player_texture.texture = null
	enemy_texture.texture = null


func _process(delta: float) -> void:
	player_flash_alpha = move_toward(player_flash_alpha, 0.0, delta * 1.8)
	enemy_flash_alpha = move_toward(enemy_flash_alpha, 0.0, delta * 1.8)
	player_flash.color.a = player_flash_alpha
	enemy_flash.color.a = enemy_flash_alpha


func show_message(message: String) -> void:
	_append_log(message)


func _start_round() -> void:
	if battle_finished:
		return
	if _check_battle_end():
		return
	turn_order = ["player", "enemy"]
	if _effective_agility(enemy_state, enemy_status) > _effective_agility(player_state, player_status):
		turn_order = ["enemy", "player"]
	turn_index = 0
	turn_label.text = "Rodada %s" % round_count
	round_count += 1
	_append_log("\n[color=#c9a646][b]Nova rodada[/b][/color]")
	_advance_turn()


func _advance_turn() -> void:
	if battle_finished:
		return
	if _check_battle_end():
		return
	if turn_index >= turn_order.size():
		_tick_statuses()
		_start_round()
		return
	var actor: String = turn_order[turn_index]
	turn_index += 1
	_apply_turn_highlight(actor)
	if actor == "player":
		_set_action_buttons_enabled(true)
		_append_log("[color=#d8c89a]Seu turno.[/color]")
	else:
		_set_action_buttons_enabled(false)
		_append_log("[color=#b8aa8a]Turno inimigo.[/color]")
		_enemy_take_turn()


func _apply_turn_highlight(actor: String) -> void:
	var player_style := UITheme.panel_style()
	var enemy_style := UITheme.panel_style()
	if actor == "player":
		player_style.border_color = UITheme.GOLD.lightened(0.15)
		player_style.shadow_size = 12
		turn_label.text = "%s  •  Você" % turn_label.text.split("  •  ")[0]
	else:
		enemy_style.border_color = UITheme.BLOOD.lightened(0.20)
		enemy_style.shadow_size = 12
		turn_label.text = "%s  •  Inimigo" % turn_label.text.split("  •  ")[0]
	player_panel.add_theme_stylebox_override("panel", player_style)
	enemy_panel.add_theme_stylebox_override("panel", enemy_style)


func _enemy_take_turn() -> void:
	if int(enemy_status.get("skip_turns", 0)) > 0:
		enemy_status["skip_turns"] = int(enemy_status.get("skip_turns", 0)) - 1
		_append_log("%s perdeu o turno." % enemy_state.get("display_name", "Inimigo"))
		_advance_turn()
		return
	if int(enemy_status.get("blind_turns", 0)) > 0 and randf() < 0.5:
		_append_log("%s errou o ataque." % enemy_state.get("display_name", "Inimigo"))
		_advance_turn()
		return
	var damage: float = _compute_damage(enemy_state, player_state, 1.0, false, "")
	if int(player_status.get("dodge_turns", 0)) > 0:
		player_status["dodge_turns"] = int(player_status.get("dodge_turns", 0)) - 1
		_append_log("%s evitou o golpe com sucesso." % player_state.get("player_name", "Herói"))
	else:
		player_state["current_health"] = maxf(0.0, float(player_state.get("current_health", 0.0)) - damage)
		_flash_target("player")
		_append_log("[color=#d97c6c]%s atacou e causou %.0f de dano.[/color]" % [enemy_state.get("display_name", "Inimigo"), damage])
	_update_labels()
	_advance_turn()


func _tick_statuses() -> void:
	_reduce_status(player_status, "defend_turns")
	_reduce_status(player_status, "stone_turns")
	_reduce_status(player_status, "war_cry_turns")
	_reduce_status(enemy_status, "blind_turns")
	_reduce_status(enemy_status, "slow_turns")
	_reduce_status(enemy_status, "skip_turns")
	_reduce_status(player_status, "protection_turns")


func _reduce_status(target: Dictionary, key: String) -> void:
	if int(target.get(key, 0)) > 0:
		target[key] = int(target.get(key, 0)) - 1


func _check_battle_end() -> bool:
	if float(enemy_state.get("current_health", 0.0)) <= 0.0:
		battle_finished = true
		var gold_reward: int = randi_range(int(enemy_state.get("gold_min", 0)), int(enemy_state.get("gold_max", 0)))
		var xp_reward: int = int(enemy_state.get("xp_reward", 0))
		_append_log("\n[color=#c9a646][b]Vitória![/b][/color] Ouro +%s | XP +%s" % [gold_reward, xp_reward])
		GameManager.update_player_resources(float(player_state.get("current_health", 0.0)), float(player_state.get("current_mana", 0.0)))
		GameManager.resolve_battle(true, {"gold": gold_reward, "xp": xp_reward})
		return true
	if float(player_state.get("current_health", 0.0)) <= 0.0:
		battle_finished = true
		_append_log("\n[color=#d97c6c][b]Derrota.[/b][/color] Você retorna para a base.")
		GameManager.update_player_resources(0.0, float(player_state.get("current_mana", 0.0)))
		GameManager.resolve_battle(false, {"xp_loss": int(enemy_state.get("xp_reward", 15))})
		return true
	return false


func _set_action_buttons_enabled(enabled: bool) -> void:
	for button in [
		$MarginContainer/VBoxContainer/Actions/AttackButton,
		skill_one_button,
		skill_two_button,
		$MarginContainer/VBoxContainer/Actions/ItemButton,
		$MarginContainer/VBoxContainer/Actions/DefendButton,
		$MarginContainer/VBoxContainer/Actions/FleeButton
	]:
		button.disabled = not enabled


func _update_labels() -> void:
	battle_title.text = "Andar %s - Batalha" % enemy_state.get("floor", 1)
	enemy_name_label.text = "%s  Rank %s" % [enemy_state.get("display_name", "Inimigo"), enemy_state.get("rank", "F")]
	enemy_hp_bar.max_value = float(enemy_state.get("max_health", 0.0))
	enemy_hp_bar.value = float(enemy_state.get("current_health", 0.0))
	enemy_hp_label.text = "HP %.0f / %.0f" % [enemy_state.get("current_health", 0.0), enemy_state.get("max_health", 0.0)]
	enemy_meta_label.text = "FOR %.0f  DEF %.0f  INT %.0f  AGI %.0f  FRQ %s" % [
		enemy_state.get("strength", 0.0),
		enemy_state.get("defense", 0.0),
		enemy_state.get("intelligence", 0.0),
		enemy_state.get("agility", 0.0),
		str(enemy_state.get("weakness", "-")).to_upper()
	]
	var player_class_id: String = str(player_state.get("class_id", "warrior"))
	var player_class_info: Dictionary = ClassData.get_class_data(player_class_id)
	player_name_label.text = "%s - %s" % [player_state.get("player_name", "Herói"), player_class_info.get("display_name", "Classe")]
	player_hp_bar.max_value = float(player_state.get("max_health", 0.0))
	player_hp_bar.value = float(player_state.get("current_health", 0.0))
	player_mp_bar.max_value = float(player_state.get("max_mana", 0.0))
	player_mp_bar.value = float(player_state.get("current_mana", 0.0))
	player_hp_label.text = "HP %.0f / %.0f" % [player_state.get("current_health", 0.0), player_state.get("max_health", 0.0)]
	player_mp_label.text = "MP %.0f / %.0f" % [player_state.get("current_mana", 0.0), player_state.get("max_mana", 0.0)]
	player_meta_label.text = "FOR %.0f  DEF %.0f  INT %.0f  AGI %.0f  Poções %s" % [
		player_state.get("strength", 0.0),
		player_state.get("defense", 0.0),
		player_state.get("intelligence", 0.0),
		player_state.get("agility", 0.0),
		GameManager.get_player_state().get("inventory", {}).get("small_potion", 0)
	]
	player_banner.text = _class_icon(player_class_id)
	enemy_banner.text = _enemy_icon(str(enemy_state.get("enemy_id", "")))
	var player_real_portrait := PixelAssetRegistry.get_player_portrait_texture(player_class_id)
	var enemy_real_portrait := PixelAssetRegistry.get_enemy_portrait_texture(str(enemy_state.get("enemy_id", "")))
	player_texture.texture = player_real_portrait
	enemy_texture.texture = enemy_real_portrait
	if player_texture.texture == null:
		player_texture.texture = PixelArtFactory.make_battle_actor_texture(player_state, "", player_class_id, false)
	if enemy_texture.texture == null:
		enemy_texture.texture = PixelArtFactory.make_battle_actor_texture(enemy_state, str(enemy_state.get("enemy_id", "")), "", true)
	player_banner.visible = player_real_portrait == null
	enemy_banner.visible = enemy_real_portrait == null


func _append_log(message: String) -> void:
	log_label.append_text("%s\n" % message)
	log_label.scroll_to_line(log_label.get_line_count())


func _flash_target(target: String) -> void:
	if target == "enemy":
		enemy_flash_alpha = 0.50
	else:
		player_flash_alpha = 0.42


func _effective_agility(source: Dictionary, status: Dictionary) -> float:
	var value: float = float(source.get("agility", 1.0))
	if int(status.get("slow_turns", 0)) > 0:
		value *= 0.7
	return value


func _compute_damage(attacker: Dictionary, defender: Dictionary, multiplier: float, magic: bool, element: String) -> float:
	var defense_value: float = float(defender.get("defense", 0.0))
	var base: float = 0.0
	if magic:
		base = float(attacker.get("intelligence", 0.0)) * multiplier - defense_value * 0.3
	else:
		var strength_value: float = float(attacker.get("strength", 0.0))
		if attacker == player_state and int(player_status.get("war_cry_turns", 0)) > 0:
			strength_value *= 1.25
		base = strength_value * multiplier - defense_value * 0.5
	base = maxf(1.0, base)
	if element != "" and str(defender.get("weakness", "")) == element:
		base *= 1.5
	if defender == player_state:
		if int(player_status.get("protection_turns", 0)) > 0:
			base *= 0.5
		if int(player_status.get("stone_turns", 0)) > 0:
			base *= 0.7
		if int(player_status.get("defend_turns", 0)) > 0:
			base *= 0.5
	return round(base)


func _use_skill(index: int) -> void:
	var skills: Array = player_state.get("skill_ids", [])
	if index < 0 or index >= skills.size():
		return
	var skill_id: String = str(skills[index])
	var info: Dictionary = SkillData.get_skill(skill_id)
	var mana_cost: float = float(info.get("mana_cost", 0.0))
	if float(player_state.get("current_mana", 0.0)) < mana_cost:
		_append_log("Mana insuficiente.")
		return
	player_state["current_mana"] = float(player_state.get("current_mana", 0.0)) - mana_cost
	match skill_id:
		"death_touch":
			var dmg: float = _compute_damage(player_state, enemy_state, 1.0, true, "")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Toque Mortal causou %.0f de dano.[/color]" % dmg)
			if float(enemy_state.get("current_health", 0.0)) <= 0.0:
				player_state["current_mana"] = minf(float(player_state.get("max_mana", 0.0)), float(player_state.get("current_mana", 0.0)) + 5.0)
		"essence_drain":
			var dmg: float = _compute_damage(player_state, enemy_state, 0.9, true, "")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			player_state["current_health"] = minf(float(player_state.get("max_health", 0.0)), float(player_state.get("current_health", 0.0)) + dmg * 0.5)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Drenar Essência causou %.0f de dano e curou %.0f.[/color]" % [dmg, dmg * 0.5])
		"backstab":
			var mult: float = 1.0
			if _effective_agility(player_state, player_status) >= _effective_agility(enemy_state, enemy_status):
				mult = 1.5
			var dmg: float = _compute_damage(player_state, enemy_state, mult, false, "")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Ataque Furtivo causou %.0f de dano.[/color]" % dmg)
		"shadow_step":
			player_status["dodge_turns"] = 1
			_append_log("Passo Sombrio: o próximo golpe inimigo será evitado.")
		"steady_slash":
			var dmg: float = _compute_damage(player_state, enemy_state, 1.35, false, "")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Golpe Firme causou %.0f de dano.[/color]" % dmg)
		"stone_stance":
			player_status["stone_turns"] = 2
			player_status["defend_turns"] = max(int(player_status.get("defend_turns", 0)), 2)
			_append_log("Postura Defensiva aumentou sua resistência por 2 turnos.")
		"piercing_arrow":
			var defender_backup: float = float(enemy_state.get("defense", 0.0))
			enemy_state["defense"] = defender_backup * 0.8
			var dmg: float = _compute_damage(player_state, enemy_state, 1.2, false, "")
			enemy_state["defense"] = defender_backup
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Flecha Perfurante causou %.0f de dano.[/color]" % dmg)
		"rapid_shot":
			var total: float = 0.0
			for _i in range(2):
				var dmg: float = _compute_damage(player_state, enemy_state, 0.7, false, "")
				total += dmg
				enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Chuva de Flechas causou %.0f de dano total.[/color]" % total)
		"spark":
			var dmg: float = _compute_damage(player_state, enemy_state, 1.2, true, "fire")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Bola de Fogo causou %.0f de dano.[/color]" % dmg)
		"ice_circle":
			var dmg: float = _compute_damage(player_state, enemy_state, 0.9, true, "ice")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			enemy_status["slow_turns"] = 2
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Círculo de Gelo causou %.0f de dano e reduziu a agilidade inimiga.[/color]" % dmg)
		"frenzy_attack":
			var hp_ratio: float = 1.0 - (float(player_state.get("current_health", 0.0)) / maxf(1.0, float(player_state.get("max_health", 1.0))))
			var dmg: float = _compute_damage(player_state, enemy_state, 1.0 + hp_ratio, false, "")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Fúria causou %.0f de dano.[/color]" % dmg)
		"war_cry":
			player_status["war_cry_turns"] = 3
			_append_log("Grito de Batalha aumentou sua força.")
		"creeping_thorns":
			var dmg: float = _compute_damage(player_state, enemy_state, 0.8, true, "nature")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			enemy_status["skip_turns"] = 1
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Espinhos causaram %.0f de dano e atrasaram o inimigo.[/color]" % dmg)
		"healing_touch":
			player_state["current_health"] = minf(float(player_state.get("max_health", 0.0)), float(player_state.get("current_health", 0.0)) + 25.0)
			_append_log("[color=#d8c89a]Toque Curativo restaurou 25 de vida.[/color]")
		"blinding_light":
			enemy_status["blind_turns"] = 2
			_append_log("Luz Ofuscante cegou o inimigo.")
		"lesser_blessing":
			player_state["current_health"] = minf(float(player_state.get("max_health", 0.0)), float(player_state.get("current_health", 0.0)) + 30.0)
			player_status.erase("blind_turns")
			_append_log("[color=#d8c89a]Bênção Leve restaurou 30 de vida.[/color]")
		"holy_strike":
			var dmg: float = _compute_damage(player_state, enemy_state, 1.25, false, "")
			enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - dmg)
			_flash_target("enemy")
			_append_log("[color=#d97c6c]Golpe Sagrado causou %.0f de dano.[/color]" % dmg)
		"protection_aura":
			player_status["protection_turns"] = 2
			_append_log("Proteção do Escudo reduziu o dano recebido.")
		_:
			_append_log("A habilidade falhou.")
	_update_labels()
	_set_action_buttons_enabled(false)
	_advance_turn()


func _on_attack_button_pressed() -> void:
	var damage: float = _compute_damage(player_state, enemy_state, 1.0, false, "")
	enemy_state["current_health"] = maxf(0.0, float(enemy_state.get("current_health", 0.0)) - damage)
	_flash_target("enemy")
	_append_log("[color=#d97c6c]Ataque básico causou %.0f de dano.[/color]" % damage)
	_update_labels()
	_set_action_buttons_enabled(false)
	_advance_turn()


func _on_skill_one_button_pressed() -> void:
	_use_skill(0)


func _on_skill_two_button_pressed() -> void:
	_use_skill(1)


func _on_item_button_pressed() -> void:
	if GameManager.consume_item("small_potion"):
		player_state["current_health"] = minf(float(player_state.get("max_health", 0.0)), float(player_state.get("current_health", 0.0)) + 50.0)
		_append_log("[color=#d8c89a]Você usou uma Poção Pequena e recuperou 50 de vida.[/color]")
	else:
		_append_log("Você não tem Poções Pequenas.")
	_update_labels()
	_set_action_buttons_enabled(false)
	_advance_turn()


func _on_defend_button_pressed() -> void:
	player_status["defend_turns"] = 1
	_append_log("[color=#d8c89a]Você entrou em postura defensiva.[/color]")
	_set_action_buttons_enabled(false)
	_advance_turn()


func _on_flee_button_pressed() -> void:
	if int(enemy_state.get("floor", 1)) <= 2:
		_append_log("Você fugiu da batalha.")
		GameManager.update_player_resources(float(player_state.get("current_health", 0.0)), float(player_state.get("current_mana", 0.0)))
		GameManager.resolve_battle(false, {"fled": true})
	else:
		_append_log("Não é possível fugir deste andar.")


func _apply_biome() -> void:
	var biome: Dictionary = GameManager.get_visual_biome_for_floor(int(enemy_state.get("floor", 1)))
	biome_label.text = str(biome.get("name", "Floresta do Início"))
	sky_rect.color = biome.get("sky", UITheme.BG_DARK)
	mist_rect.color = biome.get("mist", UITheme.MIST)
	ground_rect.color = biome.get("ground", Color(0.10, 0.12, 0.08, 1.0))
	enemy_hp_bar.add_theme_stylebox_override("fill", UITheme.progress_fill(UITheme.BLOOD))
	player_hp_bar.add_theme_stylebox_override("fill", UITheme.progress_fill(UITheme.BLOOD))
	player_mp_bar.add_theme_stylebox_override("fill", UITheme.progress_fill(UITheme.MANA))
	_build_battle_backdrop(biome)


func _build_battle_backdrop(biome: Dictionary) -> void:
	var viewport_size := get_viewport_rect().size
	for child in backdrop_props.get_children():
		child.queue_free()
	var background_texture := PixelAssetRegistry.get_battle_background_texture(
		PixelAssetRegistry.get_biome_key_for_floor(int(enemy_state.get("floor", 1)))
	)
	if background_texture != null:
		var background_rect := TextureRect.new()
		background_rect.texture = background_texture
		background_rect.position = Vector2.ZERO
		background_rect.size = viewport_size
		background_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background_rect.stretch_mode = TextureRect.STRETCH_SCALE
		background_rect.modulate = Color(1, 1, 1, 0.92)
		backdrop_props.add_child(background_rect)
		return
	_add_backdrop_texture(
		PixelArtFactory.make_tree_texture(biome.get("grass_accent", Color8(74, 122, 72)), Color8(82, 52, 28)),
		Vector2(viewport_size.x * 0.08, viewport_size.y * 0.36),
		Vector2(2.5, 2.5),
		Color(1, 1, 1, 0.74)
	)
	_add_backdrop_texture(
		PixelArtFactory.make_tree_texture(biome.get("grass_base", Color8(54, 92, 56)).darkened(0.12), Color8(74, 42, 24)),
		Vector2(viewport_size.x * 0.86, viewport_size.y * 0.37),
		Vector2(2.3, 2.3),
		Color(1, 1, 1, 0.70)
	)
	_add_backdrop_texture(
		PixelArtFactory.make_crystal_texture(biome.get("glow", Color8(154, 214, 138)), biome.get("accent", Color8(114, 86, 154)), biome.get("stone_base", Color8(92, 96, 94))),
		Vector2(viewport_size.x * 0.48, viewport_size.y * 0.30),
		Vector2(1.9, 1.9),
		Color(1, 1, 1, 0.90)
	)
	_add_backdrop_texture(
		PixelArtFactory.make_rubble_texture(biome.get("stone_base", Color8(92, 96, 94)), biome.get("accent", Color8(114, 86, 154))),
		Vector2(viewport_size.x * 0.47, viewport_size.y * 0.66),
		Vector2(2.0, 2.0),
		Color(1, 1, 1, 0.86)
	)


func _add_backdrop_texture(texture: Texture2D, position_value: Vector2, scale_value: Vector2, tint: Color = Color.WHITE) -> void:
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = position_value
	rect.scale = scale_value
	rect.modulate = tint
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	backdrop_props.add_child(rect)


func _class_icon(class_id: String) -> String:
	return str(class_icons.get(class_id, "CLS"))


func _enemy_icon(enemy_id: String) -> String:
	if enemy_id == "young_wolf":
		return "WLF"
	if enemy_id == "blue_slime":
		return "ICE"
	return "SLM"
