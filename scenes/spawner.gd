extends Node2D

@export var zombie_scene: PackedScene  # Simpan referensi ke scene zombie


func _ready():
	spawn_zombie()


func spawn_zombie():
	var new_zombie = zombie_scene.instantiate()  # Buat zombie baru
	new_zombie.global_position = Vector2(-18, 40)  # Atur posisi awal
	new_zombie.zombie_died.connect(_on_zombie_died)
	add_child(new_zombie)


func _on_zombie_died():
	await get_tree().create_timer(2).timeout  # Tunggu 3 detik sebelum respawn
	spawn_zombie()
