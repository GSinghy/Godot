extends CanvasLayer

@onready var coin_label = $CoinIcon/Label  # Reference the coin label
@onready var health_bar = $HealthBar      # Reference the health bar

func _ready():
	# Debug connections
	print("GameScreen ready.")
	print("Coin label found?", coin_label != null)
	print("HealthBar found?", health_bar != null)

	# Connect the HealthManager signal to the HealthBar
	if HealthManager != null and not HealthManager.on_health_changed.is_connected(health_bar.update_health):
		HealthManager.on_health_changed.connect(health_bar.update_health)
	
	# Connect the CollectibleManager signal to the coin label update
	if CollectibleManager != null and not CollectibleManager.on_collectible_award_received.is_connected(on_collectible_award_received):
		CollectibleManager.on_collectible_award_received.connect(on_collectible_award_received)

	# Initialize health bar
	if health_bar != null:
		health_bar.update_health(HealthManager.current_health)

	# Initialize coin label
	if coin_label != null:
		coin_label.text = "0"  # Initialize with default value

func on_collectible_award_received(total_award: int):
	if coin_label != null:
		coin_label.text = str(total_award)
		print("Coin label updated to:", total_award)
	else:
		print("Error: Coin label is null!")
