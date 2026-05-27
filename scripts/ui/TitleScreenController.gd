extends Control

@onready var load_button: Button = $MarginContainer/CenterContainer/Panel/VBoxContainer/Buttons/LoadButton
@onready var delete_button: Button = $MarginContainer/CenterContainer/Panel/VBoxContainer/Buttons/DeleteButton
@onready var title_label: Label = $MarginContainer/CenterContainer/Panel/VBoxContainer/Title
@onready var subtitle_label: Label = $MarginContainer/CenterContainer/Panel/VBoxContainer/Subtitle

func _ready() -> void:
	UITheme.apply(self)
	title_label.add_theme_color_override("font_color", UITheme.PARCHMENT)
	subtitle_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	load_button.disabled = not SaveManager.has_save()
	delete_button.disabled = not SaveManager.has_save()


func _on_new_game_pressed() -> void:
	GameManager.start_new_game()


func _on_load_button_pressed() -> void:
	GameManager.load_saved_game()


func _on_delete_button_pressed() -> void:
	SaveManager.delete_save()
	load_button.disabled = true
	delete_button.disabled = true


func _on_exit_button_pressed() -> void:
	get_tree().quit()
