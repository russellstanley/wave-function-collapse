class_name Cell extends Node2D

var available : Array[Pattern] 	# The available patterns.
var state : Array[bool]			# Super position of patterns.
var collapsed : bool = false 	# True is the cell has collapsed.
var location : Vector2i			# Location of the cell in the grid.
var tile : int = -1 			# The pattern being used, -1 if not yet known.
var current_entropy : int

# Up and down are flipped
var dir_to_int = {
	"up" = 2,
	"right" = 1,
	"down" = 0,
	"left" = 3
	}

# Initialize the cell with available patterns and location.
func _init(patterns : Array[Pattern], location : Vector2i):
	self.available = patterns
	self.location = location
	
	for i in range(available.size()):
		state.append(true)
		
	self.current_entropy = available.size()

# Check if the state of a pattern could be valid given a surroudning tile.
func is_state_valid(pattern_edges : Array[int], surroudning_edges : Array[int], dir : String):		
	if (pattern_edges[dir_to_int[dir]] == surroudning_edges[(dir_to_int[dir] + 2) % 4]):
		return true
			
	return false

# Update and calculate the entropy of the cell
func entropy(surrounding_cells):
	for a in range(available.size()):
		var is_valid = []
	
		for dir in surrounding_cells:
			if surrounding_cells[dir] != null and surrounding_cells[dir].collapsed == true:
				var surrounding_pattern = available[surrounding_cells[dir].tile]
				is_valid.append(is_state_valid(available[a].edges_id, surrounding_pattern.edges_id, dir))
		
		# If the state is invalid for any direction then set it to false
		if is_valid.find(false) != -1:
			state[a] = false
			continue
		state[a] = true
	
	current_entropy = state.count(true)
	return current_entropy

# Collapse the state of the cell
func collapse():	
	var valid_indices = []
	var selction
	
	# Determine the valid indices
	for i in range(state.size()):
		if state[i] == true:
			valid_indices.append(i)
			
	selction = valid_indices.pick_random()
	if selction == null:
		# In this case we have a contradiction
		collapsed = true
		current_entropy = -INF
	else:
		collapsed = true
		current_entropy = -INF
		tile = selction
