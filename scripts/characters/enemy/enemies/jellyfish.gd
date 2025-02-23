extends "res://scripts/characters/enemy/enemy.gd"

	
@onready var sprite = $Sprite2D

#enemy moves / attacks / etc
func make_turn():
	await get_tree().physics_frame

	if health.health <= 0:
		die();
		pass;
	
	# Simple move down for test
	if !test_move(transform, Vector2.DOWN * 32):
		position += Vector2.DOWN * 32
	
	# Tween sprite to new position after turn is finished
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.1)
	
#despawn / death explosion / etc
func die():
	TurnManager.enemies.erase(self)
	queue_free()


func _ready() -> void:
	health.set_health(5)
	sprite.global_position = global_position
	TurnManager.enemies.append(self)
	
	pass
