extends Node

@export var max_health: int = 3  # Maximum health
var current_health: int = max_health  # Player starts with full health

signal on_health_changed  # Signal emitted when health changes

func _ready():
	print("HealthManager ready. Current health:", current_health)

func decrease_health(health_amount: int):
	current_health -= health_amount
	if current_health < 0:
		current_health = 0
	print("Decrease health called. Current health:", current_health)
	on_health_changed.emit(current_health)

func increase_health(health_amount: int):
	current_health += health_amount
	if current_health > max_health:
		current_health = max_health
	print("Increase health called. Current health:", current_health)
	on_health_changed.emit(current_health)
