extends CharacterBody2D

@export var gravity = 360.0
@export var walk_speed = 200
@export var jump_speed = -250.0
@export var max_jump = 2
@export var dash_speed = 400.0
@export var time_interval_doubleTap = 0.3
@export var dash_duration = 1.0
@export var crouch_speed = 100.0

var jump_count = 0
var last_tap_l = 0.0
var last_tap_r = 0.0
var is_dashing = false
var is_crouching = false
var original_walk_speed = 0.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var idle_collision = $IdleCollisionShape
@onready var run_collision = $RunCollisionShape
@onready var crouch_collision = $CrouchCollisionShape

func _ready():
	original_walk_speed = walk_speed
	_update_collision("idle")  # Set default collision

func _physics_process(delta):
	velocity.y += delta * gravity

	# Reset jump count when touching the ground
	if is_on_floor():
		jump_count = 0  # 🔥 FIX: Reset jump count only when landing

	# Handle Jump Movement (Allow movement mid-air)
	if not is_on_floor():
		if Input.is_action_pressed("ui_left"):
			velocity.x = -walk_speed
			anim_sprite.flip_h = true
		elif Input.is_action_pressed("ui_right"):
			velocity.x = walk_speed
			anim_sprite.flip_h = false

	# Handle crouch movement
	if Input.is_action_pressed("ui_down"):
		if not is_crouching:
			start_crouch()
		if Input.is_action_pressed("ui_left"):
			velocity.x = -crouch_speed
			anim_sprite.flip_h = true
		elif Input.is_action_pressed("ui_right"):
			velocity.x = crouch_speed
			anim_sprite.flip_h = false
	else:
		if is_crouching:
			stop_crouch()

	# Dash (lari cepat)
	if Input.is_action_just_pressed("ui_left"):
		if (Time.get_ticks_msec() / 1000.0) - last_tap_l < time_interval_doubleTap:
			dash(-1)
		last_tap_l = Time.get_ticks_msec() / 1000.0

	elif Input.is_action_just_pressed("ui_right"):
		if (Time.get_ticks_msec() / 1000.0) - last_tap_r < time_interval_doubleTap:
			dash(1)
		last_tap_r = Time.get_ticks_msec() / 1000.0

	# Handle normal movement when on the ground (not dashing or crouching)
	if not is_dashing and not is_crouching and is_on_floor():
		if Input.is_action_pressed("ui_left"):
			velocity.x = -walk_speed
			anim_sprite.flip_h = true
			anim_sprite.play("walk")
			_update_collision("run")

		elif Input.is_action_pressed("ui_right"):
			velocity.x = walk_speed
			anim_sprite.flip_h = false
			anim_sprite.play("walk")
			_update_collision("run")

		else:
			velocity.x = 0
			anim_sprite.play("idle")
			_update_collision("idle")

	# Jump (Lompat)
	if Input.is_action_just_pressed("ui_up") and jump_count < max_jump:
		velocity.y = jump_speed
		jump_count += 1  # 🔥 FIX: Increase jump count when jumping
		anim_sprite.play("jump")

		# Flip sprite while jumping left or right
		if Input.is_action_pressed("ui_left"):
			anim_sprite.flip_h = true
		elif Input.is_action_pressed("ui_right"):
			anim_sprite.flip_h = false

	move_and_slide()

func dash(direction):
	velocity.x = dash_speed * direction
	is_dashing = true
	anim_sprite.play("run")  # Can be replaced with dash animation

	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false

func start_crouch():
	is_crouching = true
	walk_speed = crouch_speed
	anim_sprite.play("crouch")
	_update_collision("crouch")

func stop_crouch():
	is_crouching = false
	walk_speed = original_walk_speed
	anim_sprite.play("idle")
	_update_collision("idle")

func _update_collision(animation_name):
	idle_collision.disabled = (animation_name != "idle")
	run_collision.disabled = (animation_name != "run")
	crouch_collision.disabled = (animation_name != "crouch")
