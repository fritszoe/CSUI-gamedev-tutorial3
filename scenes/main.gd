extends Node2D

@export var player: NodePath  # Path ke Player
@export var zombie: NodePath  # Path ke Zombie (atau ambil dari spawner)
@export var switch_distance: float = 600.0  # Jarak untuk ganti musik

@onready var bgm_main = $bgm_main
@onready var bgm_zombie = $bgm_zombie


func _ready():
	# Pastikan hanya BGM utama yang diputar di awal
	bgm_main.play()
	bgm_zombie.stop()


func _process(delta):
	if not player or not zombie:
		return

	var player_node = get_node(player)
	var zombie_node = get_node(zombie)

	var distance = player_node.global_position.distance_to(zombie_node.global_position)

	# Ganti BGM berdasarkan jarak
	if distance < switch_distance:
		if not bgm_zombie.playing:
			bgm_main.stop()
			bgm_zombie.play()
	else:
		if not bgm_main.playing:
			bgm_zombie.stop()
			bgm_main.play()
