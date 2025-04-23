extends Node2D
class_name BaseCharacter

var direction = "left"

func _ready() -> void:
	TurnManager.update_sprite.connect(update_sprite)

func update_sprite() -> void:
	assert(false, "Sprite must be updated")

func update_direction(new_direction: float) -> void:
	if new_direction > 0:
		direction = "right"
	elif new_direction < 0:
		direction = "left"
