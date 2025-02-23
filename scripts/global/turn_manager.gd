extends Node

var enemies = []
var player_turn = true

func enemy_turn() -> void:
	player_turn = false
	
	# Make all the enemies calculate their turn sequentially
	for i in enemies:
		await i.turn()
	
	# Update everyone's sprites to move to their new position
	player_turn = true
