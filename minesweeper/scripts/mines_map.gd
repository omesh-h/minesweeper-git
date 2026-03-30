extends TileMapLayer
@onready var interactive_tile_map: TileMapLayer = $"../InteractiveTileMap"

var map_size: Rect2i
var bombs: int
var bomb_coords: Array[Vector2i]

const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_difficulty_map(difficulty) -> void:
	#reset vars if changing difficulty
	map_size = Rect2i(Vector2i.ZERO, Vector2i.ZERO)
	bombs = 0
	bomb_coords.clear()
	print("Creating difficulty: " + str(difficulty))
	match difficulty:
		0: #Easy - 10 x 10
			map_size = Rect2i(0, 0, 10, 10)#create a rect of the map size
			bombs = 10
			#use for loop to set the cell for each cell in the rect
			create_grid(map_size, bombs)
			pass
		1: #Medium
			map_size = Rect2i(0, 0, 16, 16)
			bombs = 40
			create_grid(map_size, bombs)
			pass
		2: #Hard
			bombs = 99
			map_size = Rect2i(0, 0, 20, 20)
			create_grid(map_size, bombs)
			pass
		3: #Extreme
			bombs = 260
			map_size = Rect2i(0, 0, 32, 32)
			create_grid(map_size, bombs)
			pass

func create_grid(grid: Rect2i, bombs: int) -> void:
	clear()
	#create bombs
	if bomb_coords.size() != bombs:
		for i in range(0, bombs):
			var x = randi_range(1, abs(grid.size.x - 1))
			var y = randi_range(1, abs(grid.size.y - 1))
			set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
			bomb_coords.append(Vector2i(x, y))
			#print(str(bomb_coords))
	#take x and y values of rectangle and then set cell (create minemap)
	for x in range(0, abs(grid.size.x)):
		for y in range(0, abs(grid.size.y)):
			interactive_tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 1))
			#print("configuring cell")
			if get_cell_source_id(Vector2i(x,y)) == -1:
				var bomb_count = check_neighbors(Vector2i(x, y))
				set_cell(Vector2i(x, y), 0, Vector2i(bomb_count, 0))


func check_neighbors(cell: Vector2i) -> int:
	var count = 0
	for neighbor_cell in NEIGHBORS:
		if cell + neighbor_cell in bomb_coords:
			count += 1
	return count
