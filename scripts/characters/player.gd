extends StaticBody2D

@onready var timer = $Timer
@onready var sprite = $Sprite2D

const TILE_SIZE: int = 32

func _ready() -> void:
	# Update initial sprite position, update sprite when turn is finished
	sprite.global_position = global_position
	TurnManager.update_sprite.connect(update_sprite)

func _physics_process(_delta: float) -> void:
	var axis = get_input_axis()
	
	if axis != Vector2.ZERO and TurnManager.player_turn and timer.is_stopped():
		var motion = axis * TILE_SIZE
		
		# Check if the player can move to the tile, move the player to the tile (without the sprite)
		if !test_move(transform, motion):
			timer.start()
			position += motion
			# Now let the enemies calculate their turn
			TurnManager.enemy_turn()

func get_input_axis() -> Vector2:
	var input = Vector2.ZERO
	
	# Input axis, ensure it is NOT normalised
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	
	return input

func update_sprite() -> void:
	# Tween the sprite to the new position when the turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
