extends TileMap

@export var SIZE_X : int = 5
@export var SIZE_Y : int = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_terrain()

func generate_terrain():
	var start_x = -((SIZE_X) / 2)
	var end_x = ceili(float(SIZE_X) / 2)
	
	var start_y = -(SIZE_Y / 2)
	var end_y = ceili(float(SIZE_Y) / 2)
	
	for i in range(start_x, end_x):
		for j in range(start_y, end_y):
				set_cell(0, Vector2i(i,j), 0, Vector2i(randi_range(0,1), randi_range(0,1)))
