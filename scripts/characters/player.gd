extends BaseCharacter

@onready var timer = $Timer
@onready var sprite = $Sprite
@onready var arrow = $Sprite/Arrow
@export var weapon: Node2D

const TILE_SIZE: int = 32

func _ready() -> void:
	super()
	# Update initial sprite position
	sprite.top_level = true
	sprite.global_position = global_position

func _physics_process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	# Visual indicator of where the player is aiming
	arrow.rotation = lerp_angle(arrow.rotation, angle, 0.1)
	
	sprite.play("idle_"+direction)
	
	if Input.is_action_just_released("attack"):
		# Wait for the attack to finish and then call the enemy turn
		update_direction(sin(angle))
		await weapon.attack()
		TurnManager.enemy_turn()
	else:
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
	update_direction(sprite.to_local(global_position).x)
	
	# Tween the sprite to the new position when the turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
