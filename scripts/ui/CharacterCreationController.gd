extends Control

@onready var class_name_label: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/InfoColumn/ClassNameLabel
@onready var class_phrase_label: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/InfoColumn/ClassPhraseLabel
@onready var name_input: LineEdit = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/NamePanel/NameColumn/NameInput
@onready var summary_label: RichTextLabel = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/InfoColumn/SummaryPanel/SummaryLabel
@onready var preview_icon: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/PreviewPanel/IconLabel
@onready var helper_label: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/NamePanel/NameColumn/HelperLabel

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


func _ready() -> void:
	UITheme.apply(self)
	if GameManager.selected_class_id.is_empty():
		GameManager.show_class_selection()
		return

	var class_info: Dictionary = ClassData.get_class_data(GameManager.selected_class_id)
	var stats: Dictionary = class_info.get("stats", {})
	var skills: Array = class_info.get("skills", [])

	preview_icon.text = str(class_icons.get(GameManager.selected_class_id, "CLS"))
	class_name_label.text = str(class_info.get("display_name", "Classe"))
	class_phrase_label.text = str(class_info.get("phrase", ""))
	helper_label.text = "Máximo de 12 caracteres."
	summary_label.text = _build_summary(stats, skills)

	name_input.max_length = 12
	name_input.grab_focus()


func _build_summary(stats: Dictionary, skills: Array) -> String:
	var skill_one_name: String = "--"
	var skill_two_name: String = "--"
	if skills.size() > 0:
		skill_one_name = str(SkillData.get_skill(skills[0]).get("name", "--"))
	if skills.size() > 1:
		skill_two_name = str(SkillData.get_skill(skills[1]).get("name", "--"))

	return "[b]Atributos[/b]\nVida: %s  Mana: %s\nForça: %s  Defesa: %s\nInteligência: %s  Agilidade: %s\nSorte: %s\n\n[b]Habilidades[/b]\n• %s\n• %s" % [
		stats.get("vida", 0),
		stats.get("mana", 0),
		stats.get("forca", 0),
		stats.get("defesa", 0),
		stats.get("inteligencia", 0),
		stats.get("agilidade", 0),
		stats.get("sorte", 0),
		skill_one_name,
		skill_two_name
	]


func _on_back_button_pressed() -> void:
	GameManager.show_class_selection()


func _on_start_button_pressed() -> void:
	GameManager.confirm_character(name_input.text)
