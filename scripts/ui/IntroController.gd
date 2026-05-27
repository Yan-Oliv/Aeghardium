extends Control

func _ready() -> void:
	UITheme.apply(self)
	$MarginContainer/CenterContainer/Panel/VBoxContainer/TextWrap/IntroLabel.text = Constants.INTRO_TEXT


func _on_continue_button_pressed() -> void:
	GameManager.show_class_selection()
