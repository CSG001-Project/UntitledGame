extends BaseCharacter
class_name BaseEnemy

@onready var health = $Health

@export var strength: float = 1
@export var weapon: Node2D
@export_range (0.00, 1.00) var defence: float = 0 # 0.00-1.00 
@export_range (0.1, 3.0) var speed: float = 1.00 # every {speed} tile(s) enemy gets a move, 0.1-3.0, if > 1 get multiple turns each player turn

var passed_turns: int = 0

func _ready() -> void:
	super()
	
	TurnManager.enemies.append(self)

func damage(attacker_strength: float, attacker_piercing: float):
	var defence_ignored = (defence * attacker_piercing)
	
	if (defence_ignored < 0):
		defence_ignored = 0
	
	health.health -= attacker_strength * (1 - (defence - defence_ignored))

# called every world turn, calls MakeTurn every (passedTurns / speed) turns
func turn() -> void:
	passed_turns += 1
	
	if passed_turns * speed >= 1:
		while passed_turns * speed >= 1:
			@warning_ignore("redundant_await")
			await make_turn()
			passed_turns -= 1
		
		passed_turns = 0

func make_turn() -> void:
	assert(false, "Must be implemented in inherited enemy class")
	# enemy moves / attacks / etc
	
func die() -> void:
	TurnManager.enemies.erase(self)

func attack():
	pass
