extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var health = $Health

@export var weapon: Node2D

func _ready() -> void:
	# Update sprite position, add self to the list of enemies that can take turns
	sprite.global_position = global_position
	TurnManager.enemies.append(self)
	TurnManager.update_sprite.connect(update_sprite)

func turn() -> void:
	# Wait for the previous enemy/player to move
	await get_tree().physics_frame

	if health.health == 0:
		TurnManager.enemies.erase(self)
		queue_free()

	# AI sttuff that makes it move to player 
	var player_position: Vector2 = get_parent().get_node("Player").global_position
	var angle = snappedf((player_position - global_position).angle(), deg_to_rad(90))

	var movement: Vector2 = Vector2(cos(angle), sin(angle))
	if !test_move(transform, movement * 32):
		position += movement * 32
	elif (global_position.x == player_position.x && abs(global_position.y - player_position.y) <= 40) || (global_position.y == player_position.y && abs(global_position.x - player_position.x) <= 40):
		#attack animation and actuasl attack here
		print("attack")

func update_sprite() -> void:
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
