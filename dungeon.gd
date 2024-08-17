extends Node2D

var root_node: Branch
var tile_size: int =  16

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
				if not leaf.self_inside_padding(x, y, padding):
					# 1 is the atlas ID
					# 0,8 is the tile location in the atlas
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(0, 8))
		
		# Render top wall
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if leaf.self_inside_padding(x, y, padding) and not leaf.self_inside_padding(x, y + 1, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(0, 0))
		
		## Render bottom wall
		#for x in range(leaf.size.x):
			#for y in range(leaf.size.y):
				#if leaf.self_inside_padding(x, y, padding) and not leaf.self_inside_padding(x, y - 1, padding):
					#tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(4, 2), 1)
		
		# Render left wall
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if leaf.self_inside_padding(x, y, padding) and not leaf.self_inside_padding(x + 1, y, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(1, 0))
					tilemap.set_cell(1, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(5, 8))
		
		# Render right wall
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if leaf.self_inside_padding(x, y, padding) and not leaf.self_inside_padding(x - 1, y, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(1, 0))
					tilemap.set_cell(1, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(3, 8))
		
		# Render top left wall
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if leaf.self_inside_padding(x, y, padding) and leaf.self_inside_padding(x + 1, y, padding) and leaf.self_inside_padding(x - 1, y, padding) and leaf.self_inside_padding(x, y + 1, padding) and leaf.self_inside_padding(x, y - 1, padding) and not leaf.self_inside_padding(x + 1, y + 1, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(3, 0))
		
		# Render top right wall
		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if leaf.self_inside_padding(x, y, padding) and leaf.self_inside_padding(x + 1, y, padding) and leaf.self_inside_padding(x - 1, y, padding) and leaf.self_inside_padding(x, y + 1, padding) and leaf.self_inside_padding(x, y - 1, padding) and not leaf.self_inside_padding(x - 1, y + 1, padding):
					tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 1, Vector2i(5, 0))
					
					
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
