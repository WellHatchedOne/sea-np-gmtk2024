extends Node2D

# big green squares = space
# gray = out of bounds
# red = floor
# orange = walls

# CONSTANTS

var DEBUG = false

var tile_size: int =  16

var tileMapFloorVector: Vector2i = Vector2i(0, 8)
var tileMapWallVector: Vector2i = Vector2i(0, 0)
var tileMapCornerVector: Vector2i = Vector2i(5, 0)

# END CONSTANTS

var root_node: Branch
var tilemap: TileMap
var paths: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_node("TileMap")
	root_node  = Branch.new(Vector2i(0, 0), Vector2i(60, 30)) # 60 tiles wide and 30 tall
	root_node.split(2, paths)
	queue_redraw()

func _draw():
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	for leaf in root_node.get_leaves():
		if (DEBUG):
			draw_rect(
			Rect2(
				leaf.position.x * tile_size, # x
				leaf.position.y * tile_size, # y
				leaf.size.x * tile_size, # width
				leaf.size.y * tile_size # height
			), 
			Color.GREEN, # colour
			false # is filled
		)
		
		var padding = Vector4i(
			rng.randi_range(2,2),
			rng.randi_range(2,2),
			rng.randi_range(2,2),
			rng.randi_range(2,2)
		)
		
		# Render floor
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				# Only render tiles in actual rooms
				if not leaf.isNotFloorTile(x, y, padding):
					# 1 is the atlas ID
					# 0,8 is the tile location in the atlas
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapFloorVector)
				elif not leaf.isNotFloorTile(x, y + 1, padding):
					# Render top wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapWallVector)
				elif not leaf.isNotFloorTile(x, y - 1, padding):
					# Render bottom wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapWallVector, 5)
				elif not leaf.isNotFloorTile(x + 1, y, padding):
					# Render left wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapWallVector, 6)
				elif leaf.isNotFloorTile(x, y, padding) and not leaf.isNotFloorTile(x - 1, y, padding):
					# Render right wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapWallVector, 7)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x + 1, y + 1, padding):
					# Render top left wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapCornerVector, 1)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x - 1, y + 1, padding):
					# Render top right wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapCornerVector)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x + 1, y - 1, padding):
					# Render bottom left wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapCornerVector, 3)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x - 1, y - 1, padding):
					# Render bottom right wall
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, tileMapCornerVector, 2)
					
					
	# Render room connections
	for path in paths:
		if path['left'].y == path['right'].y:
			# horizontal
			for i in range(path['right'].x - path['left'].x):
				tilemap.set_cell(0, Vector2i(path['left'].x+i,path['left'].y), 1, Vector2i(0, 9))
				tilemap.set_cell(1, Vector2i(path['left'].x+i,path['left'].y), 1, Vector2i(0, 15))
		else:
			# vertical
			for i in range(path['right'].y - path['left'].y):
				tilemap.set_cell(0, Vector2i(path['left'].x,path['left'].y+i), 1, Vector2i(0, 11))
				tilemap.set_cell(1, Vector2i(path['left'].x,path['left'].y+i), 1, Vector2i(0, 12))

