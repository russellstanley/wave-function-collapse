extends HSlider

@onready var label = $SliderValue

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label.text = str(value)
