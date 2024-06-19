extends Node2D
class_name Pattern 

var image : Image
@export var texture : Texture2D
@export var edges_id : Array[int]

enum {
	RIGHT = 1,
	LEFT = 3
	}
	
func _ready():
	image = texture.get_image()
	
func initialize(src : Image):
	image = src
	texture = ImageTexture.create_from_image(image)
	
func is_equal(pattern : Pattern):
	if self.image.get_data() == pattern.image.get_data():
		return true

# Create a new pattern which is reflected horizontally
func reflect_pattern():
	var result = Pattern.new()
	var copy = Image.new()
	copy.copy_from(texture.get_image())
	copy.flip_x()
	result.initialize(copy)
	
	var new_edges : Array[int] 
	new_edges = edges_id.duplicate()

	# Flip left and right edges
	new_edges[LEFT] = edges_id[RIGHT]
	new_edges[RIGHT] = edges_id[LEFT]

	result.edges_id = new_edges
	return result

# Create a new pattern which has been rotated by 90 degress	
func rotate_pattern():
	var result = Pattern.new()
	var copy = Image.new()
	copy.copy_from(texture.get_image())
	copy.rotate_90(0)
	result.initialize(copy)
	
	var new_edges : Array[int] 
	new_edges = [0,0,0,0]
	
	# Rotate the edges
	new_edges[0] = edges_id[3]
	for i in edges_id.size() - 1:
		new_edges[i + 1] = edges_id[i]
		
	result.edges_id = new_edges
	return result
	
	
	
