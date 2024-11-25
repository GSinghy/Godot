extends Node2D

@export var facing_left: bool = false  # Default is facing right

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	# Flip the effect based on the player's facing direction
	animated_sprite_2d.flip_h = facing_left

func _on_timer_timeout() -> void:
	queue_free()  # Cleanup after timer completes
