extends CanvasLayer

func _on_start_pressed():
	print("Start Game pressed!")
	GameManager.start_game()
	queue_free()

func _on_options_pressed():
	print("Options button pressed!")
	GameManager.open_options_menu()
	queue_free()


func _on_how_to_play_pressed():
	print("How to Play button pressed!")
	GameManager.open_controls_menu()  # Redirect to Controls Menu
	queue_free()

func _on_exit_pressed():
	print("Exit button pressed!")
	GameManager.exit_game()
