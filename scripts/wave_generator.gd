class_name WaveGenerator extends Node2D

var n : int # Pattern size
@export var debug_mode : bool = false # Debug mode

@onready var pipes = $Pipes
@onready var summer = $Summer
@onready var timer = $Timer

var output_size = Vector2i(10, 10)
var output_image = []
var wave_renderer : WaveRenderer

var patterns : Array[Pattern] # List of patterns
var input_size = Vector2i(0,0) # Size of the input bitmap

var curent_x = 0
var current_y = 0
var timer_stopped = true

var lock_processing

func _ready():
	load_pipes()
	wave_renderer = WaveRenderer.new(n)
	add_child(wave_renderer)
	setup_wave()

func _process(_delta):
	if debug_mode:
		if timer_stopped:
			timer.start()
			timer_stopped = false
		else:
			return
			
	var texture
	var next_cell = calculate_entropy()
	
	if (next_cell == null):
		return
		
	curent_x = next_cell.x
	current_y = next_cell.y
	
	output_image[current_y][curent_x].collapse()
	if output_image[current_y][curent_x].tile == -1:
		texture = null
	else:
		texture = patterns[output_image[current_y][curent_x].tile].texture
		
	wave_renderer.draw_sprite(Vector2i(curent_x, current_y), texture)
	
# Load a set of preset pipe patterns
func load_pipes():
	patterns.clear()
	
	for i in pipes.get_children():
		print(i.get_path())
		patterns.append(i)
	
	var corner_up = patterns[0]
	var corner_right = corner_up.rotate_pattern()
	var corner_down = corner_right.rotate_pattern()
	var corner_left = corner_up.reflect_pattern()
	
	var line_horizontal = patterns[3]
	var line_vertical = line_horizontal.rotate_pattern()
	
	patterns.append(corner_right)
	patterns.append(corner_down)
	patterns.append(corner_left)
	patterns.append(line_vertical)
	n = patterns[0].image.get_size().x
	remove_duplicates(patterns)
	
# Load a set of preset pipe patterns
func load_summer():
	patterns.clear()
	
	for i in summer.get_children():
		print(i.get_path())
		patterns.append(i)

	n = patterns[0].image.get_size().x
	remove_duplicates(patterns)
	
# Calculate the entropy and return the minimum
func calculate_entropy():
	var minimum_entropy = INF
	var lowest_entropy_cells : Array[Vector2i] = []
	
	for y in range(output_image.size() - 1):
		for x in range(output_image[y].size() - 1):
			var surrounding = find_surrounding(x, y)
			var entropy = output_image[y][x].entropy(surrounding)
			
			# Update the minimum
			if output_image[y][x].collapsed == false and entropy < minimum_entropy:
				minimum_entropy = entropy
				lowest_entropy_cells.clear()
			
			# Create array of lowest entropy cells
			if output_image[y][x].current_entropy == minimum_entropy and output_image[y][x].collapsed == false:
				lowest_entropy_cells.append(Vector2i(x,y))
					
	return lowest_entropy_cells.min()
	
	
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
				
	return surrounding
	
# Remove duplciates from the list of patterns.
# TODO: Decrease the complexity
func remove_duplicates(all_patterns):
	var duplicate_mask : Array[bool] = []
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

# Clear the wave.
func clear_wave():
	wave_renderer.clear_sprites()
	output_image.clear()
	
# Setup the wave.
func setup_wave():
	# Clear any existing data
	clear_wave()
	
	for y in output_size.y + 1:
		output_image.append([])
		for x in output_size.x + 1:
			output_image[y].append(Cell.new(patterns, Vector2i(x, y)))
	
func _on_timer_timeout():
	timer_stopped = true

func _on_button_pressed():
	setup_wave()

func _on_slider_value_changed(value):
	output_size = Vector2i(int(value), int(value))

func _on_option_button_item_selected(index):	
	if index == 0:
		load_pipes()
	elif index == 1:
		load_summer()
	
	wave_renderer.queue_free()
	wave_renderer = WaveRenderer.new(n)
	setup_wave()
	add_child(wave_renderer)
