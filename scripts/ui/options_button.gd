extends Button

@onready var options = $"../../../../Options";

func _pressed() -> void:
	if (options.visible == false):
		options.show();
	else:
		options.hide();
