extends Node

var lv1 = preload("res://levels/baselevel.tscn")  # Path to your first level
var pause = preload("res://Menu/pause_menu.tscn")  # Path to your pause menu
var main = preload("res://Menu/main_menu.tscn")    # Path to your main menu
var options = preload("res://Menu/options_menu.tscn")  # Path to your options menu
var controls = preload("res://Menu/controls.tscn")  # Path to your controls menu

var options_menu_instance: CanvasLayer = null
var controls_menu_instance: CanvasLayer = null
var pause_menu_instance: CanvasLayer = null

func _ready():
	print("GameManager is running!")
	RenderingServer.set_default_clear_color(Color(0.44, 0.12, 0.53, 1.00))

func _process(delta):
	if Input.is_action_just_pressed("Pause"):
		print("Pause key pressed!")
		if get_tree().paused:
			continue_game()
		else:
			pause_game()

# Start the game (transition to the first level)
func start_game():
	print("GameManager: Starting the game...")
	get_tree().paused = false  # Ensure the game is not paused
	transition_to_scene(lv1.resource_path)

# Exit the game
func exit_game():
	print("GameManager: Exiting the game...")
	get_tree().quit()

# Pause the game
func pause_game():
	print("GameManager: Pausing the game...")
	get_tree().paused = true
	if pause_menu_instance == null:
		pause_menu_instance = pause.instantiate()
		get_tree().get_root().add_child(pause_menu_instance)
		print("Pause menu added to the scene tree.")

# Continue the game (unpause)
func continue_game():
	print("GameManager: Continuing the game...")
	get_tree().paused = false
	if pause_menu_instance != null:
		pause_menu_instance.queue_free()
		pause_menu_instance = null

# Open the options menu
func open_options_menu():
	print("GameManager: Opening options menu...")
	if options_menu_instance == null:
		options_menu_instance = options.instantiate()
		get_tree().get_root().add_child(options_menu_instance)
		print("Options menu added to the scene tree.")

# Return to the pause menu from options
func return_to_pause_menu():
	print("GameManager: Returning to pause menu...")
	if options_menu_instance != null:
		options_menu_instance.queue_free()
		options_menu_instance = null

	if pause_menu_instance == null:
		pause_menu_instance = pause.instantiate()
		get_tree().get_root().add_child(pause_menu_instance)
		print("Pause menu instantiated and added.")

# Open the controls menu (used as "How to Play")
func open_controls_menu():
	print("GameManager: Opening controls menu...")
	if controls_menu_instance == null:
		controls_menu_instance = controls.instantiate()
		get_tree().get_root().add_child(controls_menu_instance)
		print("Controls menu instantiated and added to the scene tree.")

# Return to main menu from controls
func return_to_main_menu_from_controls():
	print("GameManager: Returning to main menu from controls...")
	if controls_menu_instance != null:
		controls_menu_instance.queue_free()
		controls_menu_instance = null
	main_menu()

# Return to main menu
func main_menu():
	print("GameManager: Returning to main menu...")
	get_tree().paused = false  # Ensure the game is not paused
	transition_to_scene(main.resource_path)

# Transition to a new scene
func transition_to_scene(scene_path: String):
	print("GameManager: Transitioning to scene:", scene_path)
	await get_tree().create_timer(0.1).timeout  # Optional delay for smooth transitions
	get_tree().change_scene_to_file(scene_path)
