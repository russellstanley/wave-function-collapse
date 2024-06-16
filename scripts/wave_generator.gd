class_name WaveGenerator extends Node2D

@export var n : int # Pattern size
@onready var pipes = $Pipes
@onready var timer = $Timer
var output_size = Vector2i(21, 21)
var output_image = []
var wave_renderer : WaveRenderer

var patterns : Array[Pattern] # List of patterns
var input_size = Vector2i(0,0) # Size of the input bitmap

var curent_x = 0
var current_y = 0
var timer_stopped = true

func _ready():
	load_pipes()
	wave_renderer = WaveRenderer.new(n)
	add_child(wave_renderer)
	
	for y in output_size.y:
		output_image.append([])
		for x in output_size.x:
			output_image[y].append(Cell.new(patterns, Vector2i(x, y)))

func _process(_delta):
	var texture
		
	if timer_stopped:
		timer.start()
		timer_stopped = false
		
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
# TODO: Remove once using automated process
func load_pipes():
	for i in pipes.get_children():
		print(i.get_path())
		patterns.append(i)
		
	n = patterns[0].image.get_size().x
	# remove_duplicates(patterns)
	
# Calculate the entropy and return the minimum
func calculate_entropy():
	var minimum_entropy = INF
	var lowest_entropy_cells : Array[Vector2i] = []
	
	for y in range(output_image.size() - 1):
		for x in range(output_image[y].size() - 1):
			var surrounding = find_surrounding(x, y)
			output_image[y][x].entropy(surrounding)
			var entropy = output_image[y][x].current_entropy
			if  output_image[y][x].collapsed == false and entropy < minimum_entropy:
				minimum_entropy = entropy
				
	for y in range(output_image.size() - 1):
		for x in range(output_image[y].size() - 1):
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
			
	if surrounding.size() != 4:
		print("Bad")

	return surrounding
	
func _on_timer_timeout():
	timer_stopped = true
