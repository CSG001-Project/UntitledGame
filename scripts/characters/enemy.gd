extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var health = $Health

func _ready() -> void:
	# Update sprite position, add self to the list of enemies that can take turns
	sprite.global_position = global_position
	TurnManager.enemies.append(self)
	TurnManager.update_sprite.connect(update_sprite)

func turn() -> void:
	# Wait for the previous enemy/player to move
	await get_tree().physics_frame

	if health.get_health() == 0:
		TurnManager.enemies.erase(self)
		queue_free()
	# Simple move down for test
	if !test_move(transform, Vector2.DOWN * 32):
		position += Vector2.DOWN * 32

func update_sprite() -> void:
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
