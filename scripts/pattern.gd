extends Node2D
class_name Pattern 

var image : Image
@export var texture : Texture2D
@export var up : Array[Pattern]
@export var down : Array[Pattern]
@export var left : Array[Pattern]
@export var right : Array[Pattern]
	
func _ready():
	image = texture.get_image()
	
func initialize(src : Image):
	image = src
	texture = ImageTexture.create_from_image(image)
	
func is_equal(pattern : Pattern):
	if self.image.get_data() == pattern.image.get_data():
		return true
	
