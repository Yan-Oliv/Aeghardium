extends Control

func _on_resume_button_pressed() -> void:
	GameManager.toggle_pause_menu()


func _on_save_button_pressed() -> void:
	var ok := GameManager.save_current_game()
	if ok:
		GameManager.show_message("Jogo salvo.")
	else:
		GameManager.show_message("Falha ao salvar.")


func _on_title_button_pressed() -> void:
	get_tree().paused = false
	GameManager.show_title()
