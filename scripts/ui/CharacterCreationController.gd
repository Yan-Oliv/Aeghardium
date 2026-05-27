extends Control

@onready var class_name_label: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/InfoColumn/ClassNameLabel
@onready var class_phrase_label: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/InfoColumn/ClassPhraseLabel
@onready var name_input: LineEdit = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/NamePanel/NameColumn/NameInput
@onready var summary_label: RichTextLabel = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/InfoColumn/SummaryPanel/SummaryLabel
@onready var preview_icon: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/PreviewPanel/PreviewVBox/IconLabel
@onready var preview_3d: CharacterPreview3D = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/TopRow/PreviewPanel/PreviewVBox/PreviewViewportContainer/PreviewViewport/CharacterPreview3D
@onready var helper_label: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/NamePanel/NameColumn/HelperLabel
@onready var body_type_value: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/AppearancePanel/AppearanceVBox/BodyTypeRow/ValueLabel
@onready var skin_tone_value: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/AppearancePanel/AppearanceVBox/SkinToneRow/ValueLabel
@onready var eye_color_value: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/AppearancePanel/AppearanceVBox/EyeColorRow/ValueLabel
@onready var hair_style_value: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/AppearancePanel/AppearanceVBox/HairStyleRow/ValueLabel
@onready var hair_color_value: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/AppearancePanel/AppearanceVBox/HairColorRow/ValueLabel
@onready var aura_value: Label = $MarginContainer/PanelContainer/OuterVBox/ScrollContainer/VBoxContainer/AppearancePanel/AppearanceVBox/AuraRow/ValueLabel

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

const BODY_TYPE_OPTIONS := [
	{"id": "masculine", "label": "Masculino"},
	{"id": "feminine", "label": "Feminino"},
	{"id": "stylized_neutral", "label": "Neutro estilizado"}
]

const SKIN_TONE_OPTIONS := [
	{"id": "skin_01", "label": "Tom 1"},
	{"id": "skin_02", "label": "Tom 2"},
	{"id": "skin_03", "label": "Tom 3"},
	{"id": "skin_04", "label": "Tom 4"},
	{"id": "skin_05", "label": "Tom 5"}
]

const EYE_COLOR_OPTIONS := [
	{"id": "amber", "label": "Âmbar"},
	{"id": "blue", "label": "Azul"},
	{"id": "green", "label": "Verde"},
	{"id": "violet", "label": "Violeta"},
	{"id": "silver", "label": "Prata"}
]

const HAIR_STYLE_OPTIONS := [
	{"id": "short", "label": "Curto"},
	{"id": "spiked", "label": "Espetado"},
	{"id": "bob", "label": "Bob"},
	{"id": "ponytail", "label": "Rabo de cavalo"},
	{"id": "crown", "label": "Coroa"}
]

const HAIR_COLOR_OPTIONS := [
	{"id": "black", "label": "Preto"},
	{"id": "brown", "label": "Castanho"},
	{"id": "chestnut", "label": "Acobreado"},
	{"id": "blonde", "label": "Loiro"},
	{"id": "white", "label": "Branco"},
	{"id": "red", "label": "Vermelho"},
	{"id": "teal", "label": "Verde-azulado"},
	{"id": "violet", "label": "Violeta"}
]

const AURA_OPTIONS := [
	{"id": true, "label": "Ativa"},
	{"id": false, "label": "Desativada"}
]

var appearance: Dictionary = {}


func _ready() -> void:
	UITheme.apply(self)
	if GameManager.selected_class_id.is_empty():
		GameManager.show_class_selection()
		return

	var class_info: Dictionary = ClassData.get_class_data(GameManager.selected_class_id)
	var stats: Dictionary = class_info.get("stats", {})
	var skills: Array = class_info.get("skills", [])

	appearance = GameManager.get_default_appearance()
	preview_icon.text = str(class_icons.get(GameManager.selected_class_id, "CLS"))
	class_name_label.text = str(class_info.get("display_name", "Classe"))
	class_phrase_label.text = str(class_info.get("phrase", ""))
	helper_label.text = "Máximo de 12 caracteres."
	summary_label.text = _build_summary(stats, skills)

	name_input.max_length = 12
	_refresh_appearance_ui()
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


func _refresh_appearance_ui() -> void:
	appearance = GameManager.normalize_appearance(appearance)
	body_type_value.text = _option_label(BODY_TYPE_OPTIONS, appearance.get("body_type", "masculine"))
	skin_tone_value.text = _option_label(SKIN_TONE_OPTIONS, appearance.get("skin_tone", "skin_03"))
	eye_color_value.text = _option_label(EYE_COLOR_OPTIONS, appearance.get("eye_color", "amber"))
	hair_style_value.text = _option_label(HAIR_STYLE_OPTIONS, appearance.get("hair_style", "short"))
	hair_color_value.text = _option_label(HAIR_COLOR_OPTIONS, appearance.get("hair_color", "black"))
	aura_value.text = _option_label(AURA_OPTIONS, appearance.get("aura_enabled", true))
	preview_3d.apply_appearance(GameManager.selected_class_id, appearance)


func _option_label(options: Array, value: Variant) -> String:
	for option in options:
		if option.get("id") == value:
			return str(option.get("label", value))
	return str(value)


func _cycle_option(key: String, options: Array, direction: int) -> void:
	var current_value: Variant = appearance.get(key)
	var current_index: int = 0
	for index in options.size():
		if options[index].get("id") == current_value:
			current_index = index
			break
	var next_index: int = wrapi(current_index + direction, 0, options.size())
	appearance[key] = options[next_index].get("id")
	_refresh_appearance_ui()


func _on_back_button_pressed() -> void:
	GameManager.show_class_selection()


func _on_start_button_pressed() -> void:
	GameManager.confirm_character(name_input.text, appearance)


func _on_body_type_prev_pressed() -> void:
	_cycle_option("body_type", BODY_TYPE_OPTIONS, -1)


func _on_body_type_next_pressed() -> void:
	_cycle_option("body_type", BODY_TYPE_OPTIONS, 1)


func _on_skin_tone_prev_pressed() -> void:
	_cycle_option("skin_tone", SKIN_TONE_OPTIONS, -1)


func _on_skin_tone_next_pressed() -> void:
	_cycle_option("skin_tone", SKIN_TONE_OPTIONS, 1)


func _on_eye_color_prev_pressed() -> void:
	_cycle_option("eye_color", EYE_COLOR_OPTIONS, -1)


func _on_eye_color_next_pressed() -> void:
	_cycle_option("eye_color", EYE_COLOR_OPTIONS, 1)


func _on_hair_style_prev_pressed() -> void:
	_cycle_option("hair_style", HAIR_STYLE_OPTIONS, -1)


func _on_hair_style_next_pressed() -> void:
	_cycle_option("hair_style", HAIR_STYLE_OPTIONS, 1)


func _on_hair_color_prev_pressed() -> void:
	_cycle_option("hair_color", HAIR_COLOR_OPTIONS, -1)


func _on_hair_color_next_pressed() -> void:
	_cycle_option("hair_color", HAIR_COLOR_OPTIONS, 1)


func _on_aura_prev_pressed() -> void:
	_cycle_option("aura_enabled", AURA_OPTIONS, -1)


func _on_aura_next_pressed() -> void:
	_cycle_option("aura_enabled", AURA_OPTIONS, 1)
