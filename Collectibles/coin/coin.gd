extends Node2D

@export var award_amount: int = 1  # Amount this coin adds to the total

@onready var animated_sprite_2d = $AnimatedSprite2D  # Reference the Sprite2D for visuals
@onready var label = $Label  # Reference the Label node for displaying the award

func _ready():
	label.hide()  # Hide the label initially

func _on_area_2d_body_entered(body: Node):
	if body.is_in_group("Player"):  # Ensure only the player can collect the coin
		print("Coin collected! Award:", award_amount)

		# Hide the coin's sprite
		animated_sprite_2d.hide()

		# Update and show the label
		label.text = str(award_amount)
		label.show()

		# Add the award to CollectibleManager
		CollectibleManager.give_pickup_award(award_amount)

		# Animate the label floating upward and remove the coin
		var tween = get_tree().create_tween()
		tween.tween_property(label, "position", label.position + Vector2(0, -10), 0.5).from_current()
		tween.tween_callback(queue_free)  # Corrected to only pass the function name
