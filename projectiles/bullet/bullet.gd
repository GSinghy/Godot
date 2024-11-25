extends AnimatedSprite2D

@export var damage: int = 1  # Damage amount the bullet deals
@export var speed: int = 1200
var direction: Vector2 = Vector2(1, 0)  # Default direction (right)
var bullet_impact_effect = preload("res://player/bullet_impact_effect.tscn")

@onready var shot_sound: AudioStreamPlayer2D = $ShotSound

func _ready():
	# Play the default animation, if set
	play("default")  # Replace "default" with the actual animation name if needed
	print("Bullet ready. Shot sound node found?", shot_sound != null)
	
	# Debugging to test if shot sound is ready
	if shot_sound and shot_sound.stream != null:
		print("Shot sound stream loaded successfully.")
	else:
		print("Warning: Shot sound stream is missing!")

	# Play the shot sound at the start
	play_shot_sound()

func _physics_process(delta: float):
	position += direction * speed * delta

# Set the bullet direction and flip/rotate sprite accordingly
func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()
	print("Bullet direction set:", direction)
	play_shot_sound()  # Ensure sound plays when direction is set
	update_sprite_orientation()

func play_shot_sound():
	if shot_sound:
		print("Playing shot sound!")
		shot_sound.play()
	else:
		print("ShotSound node not found or not working.")

func update_sprite_orientation() -> void:
	if direction.y == -1:
		rotation_degrees = -90
		flip_h = false
	elif direction.y == 1:
		rotation_degrees = 90
		flip_h = false
	else:
		rotation_degrees = 0
		flip_h = direction.x < 0
	print("Bullet direction:", direction, "Rotation:", rotation_degrees, "Flip H:", flip_h)

# Provide damage to the enemy when requested
func get_damage() -> int:
	print("Bullet damage requested:", damage)
	return damage

func _on_hitbox_area_entered(area):
	print("Bullet hitbox area entered by:", area)
	bullet_impact()

func _on_hitbox_body_entered(body):
	print("Bullet hitbox body entered by:", body)
	bullet_impact()

# Trigger bullet impact effect and free the bullet instance
func bullet_impact():
	print("Bullet impact at position:", global_position)
	var bullet_impact_effect_instance = bullet_impact_effect.instantiate() as Node2D
	bullet_impact_effect_instance.global_position = global_position
	get_parent().add_child(bullet_impact_effect_instance)
	queue_free()

# Debugging sound manually if needed
func _process(delta: float):
	if Input.is_action_just_pressed("ui_accept"):  # Use a testing key like Enter
		print("Manually triggering shot sound...")
		play_shot_sound()
