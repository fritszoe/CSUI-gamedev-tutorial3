extends CharacterBody2D

@export var speed: float = 50.0
@export var move_direction: int = -1  # -1 untuk kiri, 1 untuk kanan
@export var player: NodePath

signal zombie_died

@onready var animated_sprite = $AnimatedSprite2D
@onready var dead_sound = $deadSound

var is_dead = false


func _ready():
	animated_sprite.flip_h = (move_direction == -1)


func _physics_process(delta):
	if is_dead:
		velocity.x = 0
		return

	# Gerakan bolak-balik
	velocity.x = move_direction * speed
	move_and_slide()

	# Cek jika bertabrakan dengan dinding untuk balik arah
	if is_on_wall():
		move_direction *= -1
		animated_sprite.flip_h = (move_direction == -1)
		#await get_tree().create_timer(1).timeout  # Idle sebelum bergerak kembali
		animated_sprite.play("walk")

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Jika objek yang masuk ke HurtBox adalah player
		#get_tree().change_scene_to_file(str("res://scenes/" + "Main" + ".tscn"))
		var player_velocity = body.velocity
		if player_velocity.y > 0:  # Jika player jatuh dari atas ke zombie4
			is_dead = true
			animated_sprite.play("Dead")
			dead_sound.play()

			await get_tree().create_timer(2).timeout
			zombie_died.emit()
			queue_free()  # Hapus zombie setelah mati
		elif not is_dead:  # Jika zombie belum mati dan player kena dari samping
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
