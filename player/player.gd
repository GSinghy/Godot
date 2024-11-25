extends CharacterBody2D

var bullet_scene = preload("res://player/bullet.tscn")
var player_death_effect = preload("res://player/player_death_effect/player_death_effect.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var muzzle2: Marker2D = $Muzzle2
@onready var muzzle_up: Marker2D = $Muzzle4  # Muzzle for shooting up
@onready var hit_animation: AnimationPlayer = $HitAnimationPlayer
@onready var health_bar = get_parent().get_node("GameScreen/HealthBar")  # Direct reference to HealthBar

# Constants
const GRAVITY = 3000
@export var SPEED: int = 1000
@export var JUMP_FORCE = -1000
const KNOCKBACK_FORCE: Vector2 = Vector2(-700, -300)
const KNOCKBACK_DURATION: float = 0.2

# Health and Invincibility Variables
@export var max_health: int = 3
var health: int = max_health
var is_invincible: bool = false
var invincibility_duration: float = 1.0
var invincibility_timer: float = 0.0
var flashing_timer: float = 0.1  # Duration of each flash when hit
var flash_count: int = 5  # Number of times the player flashes after getting hit

enum State { Idle, Run, Shoot, Jump, Crouch, Hit, Dead }
var current_state: State = State.Idle
var knockback_timer: float = 0.0

func _ready():
	if animated_sprite_2d == null:
		print("Error: animated_sprite_2d is null. Check the path.")
	else:
		animated_sprite_2d.play("idle")

	if health_bar != null:
		health_bar.update_health(health)  # Initialize the health icons
	print("Player ready. Health initialized to:", health)

func _physics_process(delta: float) -> void:
	if current_state == State.Dead:
		return

	_apply_gravity(delta)

	# Handle crouch state
	_handle_crouch()

	# Prevent movement and jumping if crouching
	if current_state != State.Crouch and current_state != State.Hit:
		_handle_movement(delta)
		_handle_jump()

	# Shooting should be possible even when crouching
	_handle_shoot()

	if current_state == State.Hit:
		knockback_timer -= delta
		if knockback_timer <= 0:
			current_state = State.Idle

	# Handle invincibility and flashing
	if is_invincible:
		invincibility_timer -= delta
		flashing_timer -= delta
		if flashing_timer <= 0:
			if animated_sprite_2d != null:
				animated_sprite_2d.visible = not animated_sprite_2d.visible
			flashing_timer = 0.1
			flash_count -= 1
		if invincibility_timer <= 0.0 or flash_count <= 0:
			is_invincible = false
			if animated_sprite_2d != null:
				animated_sprite_2d.visible = true

	_update_muzzle_positions()
	move_and_slide()
	_update_animations()

func _apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y += GRAVITY * delta
	elif current_state == State.Jump:
		current_state = State.Idle

func _handle_crouch() -> void:
	if Input.is_action_pressed("crouch"):
		if current_state != State.Crouch:
			current_state = State.Crouch
			velocity.x = 0
			if animated_sprite_2d != null:
				animated_sprite_2d.play("crouch")
	elif current_state == State.Crouch:
		current_state = State.Idle  # Return to idle when crouch is released

func _handle_movement(delta: float) -> void:
	if current_state == State.Crouch:
		velocity.x = 0
		return

	var direction = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED
		if is_on_floor() and current_state != State.Hit:
			current_state = State.Run
		if animated_sprite_2d != null:
			animated_sprite_2d.flip_h = (direction < 0)
	else:
		if is_on_floor():
			velocity.x = 0
		if current_state != State.Shoot and current_state != State.Hit:
			current_state = State.Idle

func _handle_jump() -> void:
	if current_state == State.Crouch:
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE
		current_state = State.Jump
		if animated_sprite_2d != null:
			animated_sprite_2d.play("jump")

func _handle_shoot() -> void:
	var is_aiming_up = Input.is_action_pressed("aim_up")
	var is_crouching = Input.is_action_pressed("crouch")

	if Input.is_action_just_pressed("shoot") and current_state != State.Hit:
		var shoot_position: Vector2
		var direction = -1 if animated_sprite_2d != null and animated_sprite_2d.flip_h else 1
		var angle = 0.0
		var bullet_direction = Vector2(direction, 0)

		if is_aiming_up:
			shoot_position = muzzle_up.global_position
			bullet_direction = Vector2(0, -1)
			angle = -90
			if animated_sprite_2d != null:
				animated_sprite_2d.play("shootup")
		elif is_crouching:
			shoot_position = muzzle2.global_position
			if animated_sprite_2d != null:
				animated_sprite_2d.play("shoot")
		else:
			shoot_position = muzzle.global_position
			if animated_sprite_2d != null:
				animated_sprite_2d.play("shoot")

		_spawn_bullet(shoot_position, bullet_direction, angle)
		current_state = State.Shoot

func _spawn_bullet(position: Vector2, bullet_direction: Vector2, angle: float) -> void:
	var bullet_instance = bullet_scene.instantiate() as AnimatedSprite2D
	bullet_instance.global_position = position
	bullet_instance.rotation_degrees = angle
	bullet_instance.call("set_direction", bullet_direction)

	get_parent().add_child(bullet_instance)

func _update_muzzle_positions() -> void:
	var flip_multiplier = -1 if animated_sprite_2d != null and animated_sprite_2d.flip_h else 1
	muzzle.position.x = abs(muzzle.position.x) * flip_multiplier
	muzzle2.position.x = abs(muzzle2.position.x) * flip_multiplier
	muzzle_up.position.x = abs(muzzle_up.position.x)

func _update_animations() -> void:
	if current_state == State.Hit:
		if animated_sprite_2d != null and !animated_sprite_2d.is_playing():
			current_state = State.Idle
		return

	if current_state == State.Dead:
		if animated_sprite_2d != null and animated_sprite_2d.animation != "dead":
			animated_sprite_2d.play("dead")
		return

	if Input.is_action_pressed("crouch"):
		if current_state != State.Crouch:
			current_state = State.Crouch
			if animated_sprite_2d != null:
				animated_sprite_2d.play("crouch")
	elif current_state == State.Idle and is_on_floor():
		if animated_sprite_2d != null and animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
	elif current_state == State.Run:
		if animated_sprite_2d != null and animated_sprite_2d.animation != "run":
			animated_sprite_2d.play("run")
	elif current_state == State.Jump and !is_on_floor():
		if animated_sprite_2d != null and animated_sprite_2d.animation != "jump":
			animated_sprite_2d.play("jump")
	elif current_state == State.Shoot:
		if animated_sprite_2d != null and !animated_sprite_2d.is_playing():
			current_state = State.Idle

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and !is_invincible:
		print("Player hit!")
		HealthManager.decrease_health(1)  # Use centralized health manager
		if HealthManager.current_health > 0:
			_trigger_hit()
		else:
			_trigger_death()

func _trigger_hit() -> void:
	current_state = State.Hit
	is_invincible = true
	invincibility_timer = invincibility_duration
	flashing_timer = 0.1
	flash_count = 5
	knockback_timer = KNOCKBACK_DURATION
	velocity = KNOCKBACK_FORCE * (1 if animated_sprite_2d != null and not animated_sprite_2d.flip_h else -1)
	if animated_sprite_2d != null:
		animated_sprite_2d.modulate = Color(1, 1, 1)
		animated_sprite_2d.play("hit")
		hit_animation.play("hit")

func _trigger_death() -> void:
	print("Player is dead!")
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	player_death_effect_instance.set("facing_left", animated_sprite_2d.flip_h)
	get_parent().add_child(player_death_effect_instance)
	queue_free()
