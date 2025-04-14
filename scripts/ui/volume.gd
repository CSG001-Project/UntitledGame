extends HSlider

var master_bus = "Master"

func _ready():
	var current_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(master_bus))
	value = current_volume
	print(current_volume)

# Called when the slider value changes
func _value_changed(value):
	var volume_db = (value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(master_bus), volume_db)
