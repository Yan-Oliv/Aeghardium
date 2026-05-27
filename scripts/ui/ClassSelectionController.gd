extends Control

var selected_class_id: String = "warrior"
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
var class_colors: Dictionary = {
	"necromancer": Color("6B4FA3"),
	"assassin": Color("5A5C66"),
	"warrior": Color("A9B2BC"),
	"archer": Color("4F8B5B"),
	"mage": Color("3A6EA5"),
	"berserker": Color("8B1E24"),
	"druid": Color("3D5A4A"),
	"cleric": Color("D8C89A"),
	"paladin": Color("C9A646")
}

@onready var class_list: ItemList = $MarginContainer/HBoxContainer/LeftPanel/LeftVBox/ClassList
@onready var icon_label: Label = $MarginContainer/HBoxContainer/DetailsPanel/VBoxContainer/Header/IconPanel/IconLabel
@onready var name_label: Label = $MarginContainer/HBoxContainer/DetailsPanel/VBoxContainer/Header/HeaderText/NameLabel
@onready var role_label: Label = $MarginContainer/HBoxContainer/DetailsPanel/VBoxContainer/Header/HeaderText/RoleLabel
@onready var details_label: RichTextLabel = $MarginContainer/HBoxContainer/DetailsPanel/VBoxContainer/DetailsLabel


func _ready() -> void:
	UITheme.apply(self)
	var all_classes: Dictionary = ClassData.get_all_classes()
	for class_id in Constants.CLASS_IDS:
		var class_info: Dictionary = all_classes[class_id]
		class_list.add_item("%s  %s" % [class_icons.get(class_id, "CLS"), class_info["display_name"]])
	class_list.select(0)
	_refresh_selection(0)


func _on_class_list_item_selected(index: int) -> void:
	_refresh_selection(index)


func _on_confirm_button_pressed() -> void:
	GameManager.choose_class(selected_class_id)
	GameManager.show_character_creation()


func _on_back_button_pressed() -> void:
	GameManager.show_intro()


func _refresh_selection(index: int) -> void:
	if index < 0 or index >= Constants.CLASS_IDS.size():
		return

	selected_class_id = Constants.CLASS_IDS[index]
	var data: Dictionary = ClassData.get_class_data(selected_class_id)
	var stats: Dictionary = data["stats"]
	var skills: Array = data["skills"]

	icon_label.text = str(class_icons.get(selected_class_id, "CLS"))
	icon_label.add_theme_color_override("font_color", class_colors.get(selected_class_id, UITheme.PARCHMENT))
	name_label.add_theme_color_override("font_color", class_colors.get(selected_class_id, UITheme.PARCHMENT))
	name_label.text = str(data["display_name"])
	role_label.text = str(data["role"])
	details_label.text = "[i]%s[/i]\n\n[b]Atributos[/b]\nVida: %s\nMana: %s\nForça: %s\nDefesa: %s\nInteligência: %s\nAgilidade: %s\nSorte: %s\n\n[b]Habilidades Iniciais[/b]\n• %s\n• %s\n\n[b]Descrição[/b]\n%s" % [
		data["phrase"],
		stats["vida"],
		stats["mana"],
		stats["forca"],
		stats["defesa"],
		stats["inteligencia"],
		stats["agilidade"],
		stats["sorte"],
		SkillData.get_skill(skills[0])["name"],
		SkillData.get_skill(skills[1])["name"],
		data.get("description", data["role"])
	]
