extends CharacterBody2D

var enemy_death_effect = preload("res://Enemy/enemybugdeath.tscn")

@export var patrol_points: Node  # Ensure this points to the correct PatrolPoints node
@export var speed: int = 4500
@export var wait_time: int = 3
@export var health_amount: int = 3
@export var damage_amount: int = 1
@export var flash_duration: float = 0.5  # Duration for flashing effect

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer  # Ensure this references the correct Timer node

const GRAVITY = 1000

enum State { Idle, Walk, Dead }
var current_state: State
var direction: Vector2 = Vector2.LEFT
var point_positions: Array[Vector2] = []
var current_point: Vector2 = Vector2()  # Initialize current_point as a default Vector2
var current_point_position: int = 0
var can_walk: bool = true
var flash_timer: float = 0.0  # Timer for the flash effect

func _ready():
	setup_patrol_points()
	timer.wait_time = wait_time
	current_state = State.Idle

func _physics_process(delta: float):
	if current_state == State.Dead:
		return  # Stop all actions if the enemy is dead

	# Process flash effect if active
	if flash_timer > 0:
		flash_timer -= delta
		animated_sprite_2d.modulate = Color(1, 1, 1) if int(flash_timer * 10) % 2 == 0 else Color(1, 1, 1, 0.5)
	else:
		animated_sprite_2d.modulate = Color(1, 1, 1)  # Reset to normal

	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	move_and_slide()
	enemy_animations()

func setup_patrol_points() -> void:
	if patrol_points != null:
		for point in patrol_points.get_children():
			if point is Marker2D:
				point_positions.append(point.global_position)
		if point_positions.size() > 0:
			current_point = point_positions[current_point_position]
		else:
			print("Error: Patrol points array is empty.")
	else:
		print("Error: patrol_points node is not assigned in Inspector.")

func enemy_gravity(delta: float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta: float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle

func enemy_walk(delta: float):
	if point_positions.size() == 0:
		print("Error: No patrol points available.")
		return

	if !can_walk:
		return

	if abs(position.x - current_point.x) > 5:
		velocity.x = direction.x * speed * delta
		current_state = State.Walk
	else:
		update_current_point()

	animated_sprite_2d.flip_h = direction.x > 0

func update_current_point():
	current_point_position = (current_point_position + 1) % point_positions.size()
	current_point = point_positions[current_point_position]
	direction = Vector2.RIGHT if current_point.x > position.x else Vector2.LEFT
	can_walk = false
	timer.start()

func enemy_animations():
	if current_state == State.Dead:
		if animated_sprite_2d != null and !animated_sprite_2d.is_playing():
			queue_free()  # Remove the enemy after the death animation completes
	elif current_state == State.Idle and !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk and can_walk:
		animated_sprite_2d.play("walk")

# Called when the timer finishes
func _on_timer_timeout():
	can_walk = true  # Resume walking after the timer ends

# Handle collision with hurtbox
func _on_hurtbox_area_entered(area: Area2D):
	print("Hurtbox area entered")
	if area.get_parent().has_method("get_damage"):
		var node = area.get_parent() as Node
		health_amount -= node.get_damage()
		print("Health amount:", health_amount)

		# Trigger the flash effect
		flash_timer = flash_duration

		if health_amount <= 0:
			var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
			enemy_death_effect_instance.global_position = global_position
			get_parent().add_child(enemy_death_effect_instance)
			queue_free()
