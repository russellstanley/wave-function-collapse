class_name WaveRenderer extends Node2D

var cell_size : int

func _init(cell_size : int):
	self.cell_size = cell_size

func draw_sprite(location : Vector2i, texture):
	var sprite = Sprite2D.new()
	
	# If null set blank canvas
	if texture == null:
		texture = CanvasTexture.new()
		
	sprite.texture = texture
	sprite.position.x = location.x * cell_size
	sprite.position.y = location.y * cell_size
	add_child(sprite)
