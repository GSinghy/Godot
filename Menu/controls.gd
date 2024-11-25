extends CanvasLayer

func _on_back_pressed() -> void:
	print("Controls Menu: Back to main menu")
	GameManager.return_to_main_menu_from_controls()
	print("Controls Menu: Transitioned back to main menu.")
