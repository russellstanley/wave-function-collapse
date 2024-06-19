extends Node2D

@onready var input : Sprite2D = $InputImage # Input bitmap
@export var n : int = 3 					# Pattern size
@onready var pipes = $Pipes
@onready var output_size = Vector2i(21, 21)
var output_image = []
@onready var timer = $Timer

var patterns : Array[Pattern] # List of patterns
var input_size = Vector2i(0,0) # Size of the input bitmap

var curent_x = 0
var current_y = 0
var timer_stopped = true

# Genreate a list of unique patterns and their respective ruleset from an input image.
# TODO: Setup the rules
# TODO: Adjust for rotation and symmetry
func load_patterns():
	patterns.clear()
	var input_image = input.texture.get_image()
	input_size = input_image.get_size()
	
	for y in range(0, input_size.y, n):
		for x in range(0, input_size.x, n):
			patterns.append(Pattern.new())
			patterns.back().initialize(input_image.get_region(Rect2i(x, y, n, n)))
	
	# patterns = remove_duplicates(patterns)
	draw_patterns(patterns)
	
# Helper function which can be used to visualize the current list of patterns.
func draw_patterns(list):
	var custom_scale = 5
	var border = 5
	var n_cols = 5
	var spacing = (n * custom_scale) + border
	var offset = (n_cols * spacing) / 2
	
	for i in range(0, list.size()):
		var sprite = Sprite2D.new()
		sprite.texture = ImageTexture.create_from_image(list[i].image)
		sprite.set_scale(Vector2i(custom_scale, custom_scale))
		
		sprite.position.x = (((i % n_cols) * spacing)) - offset
		sprite.position.y = (i / n_cols) * spacing

		add_child(sprite)
