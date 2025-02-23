extends StaticBody2D


@onready var health = $Health;

@export var strength = 1;
@export var defense = 0; # 0.00-1.00 
@export var speed = 1.00; # every {speed} tile(s) enemy gets a move, 0.1-3.0, if > 1 get multiple turns each player turn


func damage(attackerStrength, attackerWeaponDefenseIgnoreRate):
	var defense_ignored = (defense * attackerWeaponDefenseIgnoreRate);
	if (defense_ignored < 0): defense_ignored = 0;
	
	health.set_health( health.health - (attackerStrength * (1 - (defense - defense_ignored))) );
	
	if (health.health <= 0):
		die();


@onready var passed_turns = 0.00
# called every world turn, calls MakeTurn every (passedTurns / speed) turns
func turn():
	passed_turns += 1;
	if ((passed_turns * speed) >= 1):
		while ((passed_turns * speed) >= 1):
			make_turn();
			passed_turns -= 1;
		passed_turns = 0
	pass;
			

func make_turn():
	assert(false, "Must be implemented in inherited enemy class");
	#enemy moves / attacks / etc
	
func die():
	assert(false, "Must be implemented in inherited enemy class");
	#despawn / death explosion / etc
