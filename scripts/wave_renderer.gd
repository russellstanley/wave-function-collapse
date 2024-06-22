class_name WaveRenderer extends Node2D

var cell_size : int

func _init(cell_size : int):
	self.cell_size = cell_size

func draw_sprite(location : Vector2i, texture):
	var sprite = Sprite2D.new()
	var ratio = 50 / cell_size
	
	# If null set blank canvas
	if texture == null:
		texture = CanvasTexture.new()
		
	sprite.texture = texture
	sprite.scale = Vector2i(ratio, ratio)
	sprite.position.x = location.x * (cell_size * ratio)
	sprite.position.y = location.y * (cell_size * ratio)
	add_child(sprite)

# Clear the child sprites
func clear_sprites():
	for i in get_children():
		i.queue_free()
