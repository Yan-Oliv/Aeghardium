extends Control

@onready var title_label: Label = $MarginContainer/VBoxContainer/Header/TitleLabel
@onready var summary_label: RichTextLabel = $MarginContainer/VBoxContainer/MainSplit/SidePanel/InfoPanel/SummaryLabel
@onready var log_label: Label = $MarginContainer/VBoxContainer/Footer/MessageLabel
@onready var portal_label: Label = $MarginContainer/VBoxContainer/MainSplit/CenterRow/HeroScene/PortalPanel/PortalLabel
@onready var fire_light: ColorRect = $MarginContainer/VBoxContainer/MainSplit/CenterRow/HeroScene/FireGlow
@onready var fire_core: ColorRect = $MarginContainer/VBoxContainer/MainSplit/CenterRow/HeroScene/FireCore

var pulse_time: float = 0.0


func _ready() -> void:
	UITheme.apply(self)
	_tune_button_sizes()
	_refresh()
	var pending: String = GameManager.consume_pending_message()
	if not pending.is_empty():
		show_message(pending)


func _tune_button_sizes() -> void:
	for button_path in [
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/PrimaryButtons/DungeonButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/PrimaryButtons/RestButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/PrimaryButtons/SaveButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/PrimaryButtons/TitleButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/SecondaryPanel/SecondaryVBox/SecondaryScroll/SecondaryButtons/StoreButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/SecondaryPanel/SecondaryVBox/SecondaryScroll/SecondaryButtons/EquipButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/SecondaryPanel/SecondaryVBox/SecondaryScroll/SecondaryButtons/ForgeButton",
		"MarginContainer/VBoxContainer/MainSplit/SidePanel/ActionPanel/ActionPanelVBox/SecondaryPanel/SecondaryVBox/SecondaryScroll/SecondaryButtons/GardenButton"
	]:
		var button := get_node(button_path) as Button
		button.custom_minimum_size.y = 44


func show_message(message: String) -> void:
	log_label.text = message


func _refresh() -> void:
	var player: Dictionary = GameManager.get_player_state()
	if player.is_empty():
		summary_label.text = "Nenhum personagem carregado."
		return

	var class_id: String = str(player.get("class_id", "warrior"))
	var class_info: Dictionary = ClassData.get_class_data(class_id)
	title_label.text = "Base de %s" % player.get("player_name", "Desperto")
	portal_label.text = "Entrada da Dungeon\nAndar %s" % player.get("floor", 1)
	summary_label.text = "[b]%s[/b]\nClasse: %s\nNível: %s  Rank: %s\nOuro: %s\nAndar Atual: %s\n\nVida: %.0f / %.0f\nMana: %.0f / %.0f\nForça: %.0f  Defesa: %.0f\nInteligência: %.0f  Agilidade: %.0f\nSorte: %.0f\nPoções: %s" % [
		player.get("player_name", "Desperto"),
		class_info.get("display_name", "Classe"),
		player.get("level", 1),
		player.get("rank", "F"),
		player.get("gold", 0),
		player.get("floor", 1),
		player.get("current_health", 0.0),
		player.get("max_health", 0.0),
		player.get("current_mana", 0.0),
		player.get("max_mana", 0.0),
		player.get("strength", 0.0),
		player.get("defense", 0.0),
		player.get("intelligence", 0.0),
		player.get("agility", 0.0),
		player.get("luck", 0.0),
		player.get("inventory", {}).get("small_potion", 0)
	]


func _process(delta: float) -> void:
	pulse_time += delta
	var pulse: float = 0.75 + sin(pulse_time * 2.2) * 0.08
	fire_light.modulate.a = pulse
	fire_core.modulate.a = 0.88 + sin(pulse_time * 3.1) * 0.08


func _on_dungeon_button_pressed() -> void:
	GameManager.start_dungeon_battle()


func _on_rest_button_pressed() -> void:
	GameManager.rest_at_base()
	_refresh()


func _on_save_button_pressed() -> void:
	if GameManager.save_current_game():
		show_message("Progresso salvo localmente.")
	else:
		show_message("Falha ao salvar.")


func _on_title_button_pressed() -> void:
	GameManager.show_title()
