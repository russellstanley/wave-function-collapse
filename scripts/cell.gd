class_name Cell extends Node2D

var available : Array[Pattern] 	# The available patterns.
var state : Array[bool]			# Super position of patterns.
var collapsed : bool = false 	# True is the cell has collapsed.
var location : Vector2i			# Location of the cell in the grid.
var tile : int = -1 			# The pattern being used, -1 if not yet known.

# Initialize the cell with available patterns and location.
func _init(patterns : Array[Pattern], location : Vector2i):
	self.available = patterns
	self.location = location
	
	for i in range(available.size()):
		state.append(true) 

# Check if the state of a pattern could be valid given a surroudning tile.
func is_state_valid(valid_patterns : Array[Pattern], current_pattern : Pattern):
	for p in valid_patterns:
		if p.is_equal(current_pattern):
			return true
			
	return false

# Update and calculate the entropy of the cell
func entropy(surrounding_cells):
	for a in range(available.size()):
		var is_valid = []
	
		for dir in surrounding_cells:
			if surrounding_cells[dir] != null and surrounding_cells[dir].collapsed == true:
				var surrounding_pattern = available[surrounding_cells[dir].tile]
				if dir == "up":
					# Up and down are flipped.
					is_valid.append(is_state_valid(available[a].down, surrounding_pattern))
				if dir == "down":
					is_valid.append(is_state_valid(available[a].up, surrounding_pattern))
				if dir == "left":
					is_valid.append(is_state_valid(available[a].left, surrounding_pattern))
				if dir == "right":
					is_valid.append(is_state_valid(available[a].right, surrounding_pattern))
		
		# If the state is invalid for any direction then set it to false
		if is_valid.find(false) != -1:
			state[a] = false
			continue
		state[a] = true
		
	return state.find(true)

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
	else:
		collapsed = true
		tile = selction
