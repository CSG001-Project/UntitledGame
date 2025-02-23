extends BaseEnemy

@onready var sprite = $Sprite2D

func _ready() -> void:
	super()
	
	sprite.global_position = global_position

#enemy moves / attacks / etc
func make_turn() -> void:
	await get_tree().physics_frame
	
	# Simple move down for test
	if !test_move(transform, Vector2.DOWN * 32):
		position += Vector2.DOWN * 32

# despawn / death explosion / etc
func die() -> void:
	super()
	
	queue_free()

func update_sprite() -> void:
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
