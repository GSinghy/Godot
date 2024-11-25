extends CanvasLayer

func _on_back_pressed() -> void:
	print("Options Menu: Back to pause menu")
	GameManager.return_to_pause_menu()
	print("Options Menu: Transitioned back to pause menu.")

func _on_resolution_pressed() -> void:
	print("Options Menu: Resolution settings pressed!")
	# Add logic for resolution settings here

func _on_window_pressed() -> void:
	print("Options Menu: Window mode settings pressed!")
	# Add logic for window mode settings here
