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

# Called when the node enters the scene tree for the first time.
func _ready():
	load_pipes()
	
	for y in output_size.y:
		output_image.append([])
		for x in output_size.x:
			output_image[y].append(Cell.new(patterns, Vector2i(x, y)))
	
func _process(delta):
	var texture
	calculate_entropy()
	
	if current_y == output_size.y - 1:
		return
		
	if timer_stopped:
		timer.start()
		timer_stopped = false
		
		output_image[current_y][curent_x].collapse()
		
		if output_image[current_y][curent_x].tile == -1:
			texture = null
		else:
			texture = patterns[output_image[current_y][curent_x].tile].texture
			
		draw_sprite(Vector2i(curent_x, current_y), texture)
			
		curent_x += 1
		if curent_x == output_size.x - 1:
			curent_x = 0
			current_y += 1

# Load a set of preset pipe patterns
# TODO: Remove once using automated process
func load_pipes():
	for i in pipes.get_children():
		print(i.get_path())
		patterns.append(i)
		
	n = patterns[0].image.get_size().x
	# remove_duplicates(patterns)

# Genreate a list of unique patterns and their respective ruleset from an input image.
# TODO: Setup the rules
# TODO: Adjust for rotation and symmetry
func load_patterns():
	patterns.clear()
	var input_image = input.texture.get_image()
	var input_size = input_image.get_size()
	
	for y in range(0, input_size.y, n):
		for x in range(0, input_size.x, n):
			patterns.append(Pattern.new())
			patterns.back().initialize(input_image.get_region(Rect2i(x, y, n, n)))
	
	patterns = remove_duplicates(patterns)
	draw_patterns(patterns)

# Remove duplciates from the list of patterns.
# TODO: Decrease the complexity
func remove_duplicates(all_patterns):
	var duplicate_mask : Array[bool]
	var unique : Array[Pattern] = []
	
	for i in all_patterns:
		duplicate_mask.append(false)
		
	for i in range(all_patterns.size()):
		for j  in range(all_patterns.size()):
			if (i != j and all_patterns[i].is_equal(all_patterns[j]) and duplicate_mask[i] != true):
				duplicate_mask[j] = true
				
	for i in range(all_patterns.size()):
		if duplicate_mask[i] == false:
			unique.append(all_patterns[i])
	
	return unique

# Function used to render the image.
func draw_image():
	calculate_entropy()
	
	# Collapse each cell
	for i in range(output_image.size()):
		for j in range(output_image[i].size()):
			output_image[i][j].collapse()
			calculate_entropy()
			
func draw_sprite(location : Vector2i, texture):
	var sprite = Sprite2D.new()
	
	# If null set blank canvas
	if texture == null:
		texture = CanvasTexture.new()
		
	sprite.texture = texture
	sprite.position.x = location.x * (n + 1)
	sprite.position.y = location.y * (n + 1)
	add_child(sprite)
	

func calculate_entropy():
	# Calculate the entropy
	for y in range(output_image.size() - 1):
		for x in range(output_image[y].size() - 1):
			var surrounding = find_surrounding(x, y)
			output_image[y][x].entropy(surrounding)
	
func find_surrounding(x, y):
	var surrounding = {}
	if (y == 0):
		surrounding["down"] = null
	if (x == 0):
		surrounding["left"] = null
	if (y == output_image.size() - 1):
		surrounding["up"] = null
	if (x == output_image[0].size() - 1):
		surrounding["right"] = null

	for dir in ["up", "down", "left", "right"]:
		if not surrounding.has(dir):
			if dir == "up":
				surrounding["up"] = output_image[y + 1][x]
			if dir == "down":
				surrounding["down"] = output_image[y - 1][x]
			if dir == "left":
				surrounding["left"] = output_image[y][x - 1]	
			if dir == "right":
				surrounding["right"] = output_image[y][x + 1]	
			
	if surrounding.size() != 4:
		print("Fuck")

	return surrounding
	
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

func _on_timer_timeout():
	timer_stopped = true
