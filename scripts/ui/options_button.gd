extends Button

@onready var options = $"../../../../Options";

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _pressed() -> void:
	if (options.visible == false):
		options.show();
	else:
		options.hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
