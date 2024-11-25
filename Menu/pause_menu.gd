extends CanvasLayer

func _ready():
	print("Pause Menu: Initialized successfully!")

func _on_continue_pressed():
	print("Pause Menu: Continue button pressed!")
	GameManager.continue_game()
	queue_free()

func _on_main_menu_pressed():
	print("Pause Menu: Main Menu button pressed!")
	GameManager.main_menu()
	queue_free()

func _on_options_pressed():
	print("Pause Menu: Options button pressed!")
	GameManager.open_options_menu()
	print("Pause Menu: Transitioned to Options menu.")
