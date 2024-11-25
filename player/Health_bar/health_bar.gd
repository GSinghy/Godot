extends Node2D

@export var power_cell: Texture2D  # Full health icon texture
@export var power_cell0: Texture2D  # Empty health icon texture

@onready var power_cell1 = $Powercell1  # First health icon
@onready var power_cell2 = $Powercell2  # Second health icon
@onready var power_cell3 = $Powercell3  # Third health icon

func _ready():
	print("HealthBar ready.")
	update_health(HealthManager.current_health)  # Sync with current health

func update_health(new_health: int):
	print("Updating health bar. Current health:", new_health)

	if new_health >= 3:
		power_cell3.texture = power_cell
	else:
		power_cell3.texture = power_cell0

	if new_health >= 2:
		power_cell2.texture = power_cell
	else:
		power_cell2.texture = power_cell0

	if new_health >= 1:
		power_cell1.texture = power_cell
	else:
		power_cell1.texture = power_cell0
