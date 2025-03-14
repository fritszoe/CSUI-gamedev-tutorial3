extends AudioStreamPlayer2D

@export var player: NodePath  # Pilih node Player dari editor
@export var max_volume: float = 0.0  # Volume maksimal (default: 0 dB)
@export var min_volume: float = -30.0  # Volume minimal (saat jauh)
@export var proximity_distance: float = 600.0  # Jarak maksimum untuk mendengar suara


func _process(delta: float) -> void:
	if player:
		var player_node = get_node(player)
		var distance = global_position.distance_to(player_node.global_position)

		# Hitung volume berdasarkan jarak
		var volume = max_volume - (distance / proximity_distance) * abs(max_volume - min_volume)
		volume_db = clamp(volume, min_volume, max_volume)
