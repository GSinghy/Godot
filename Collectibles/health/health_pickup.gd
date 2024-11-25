extends Node2D

@export var pickup_amount: int = 1  # Amount of health restored

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Collision detected with:", body.name)
	if body.is_in_group("Player"):
		print("Health pickup collected by Player!")
		HealthManager.increase_health(pickup_amount)
		queue_free()
