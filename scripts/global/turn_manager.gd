extends Node
class_name Ranged

var enemies = []
var player_turn = true
var action_in_progress: bool = false

signal update_sprite

func enemy_turn() -> void:
	player_turn = false
	
	# Make all the enemies calculate their turn sequentially
	for i in enemies:
		await i.turn()
	
	# Update everyone's sprites to move to their new position
	update_sprite.emit()
	player_turn = true
