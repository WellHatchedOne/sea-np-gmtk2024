extends Node2D

# big green squares = space
# gray = out of bounds
# red = floor
# orange = walls

# CONSTANTS

var DEBUG = true

var tile_size: int =  16

var tileMapFloorVector: Vector2i = Vector2i(0, 8)
var tileMapWallVector: Vector2i = Vector2i(0, 0)
var tileMapCornerVector: Vector2i = Vector2i(5, 0)

@export var default_spawn_percent: float = 0.025

# END CONSTANTS

var root_node: Branch
var tilemap: TileMap
var paths: Array = []

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var biters: Array = []

const ENEMY = preload("res://Entities/Enemies/dummyEnemy.tscn")
const BITE_ATTACK_TIMER = preload("res://Events/Timers/biteAttackTimer.tscn")
#const LIGHTNING_ATTACK_TIMER = preload("res://Entities/Enemies/meleeAttacker.tscn")
#const BULLET_ATTACK_TIMER = preload("res://Entities/Enemies/meleeAttacker.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_node("TileMap")
	root_node  = Branch.new(Vector2i(0, 0), Vector2i(60, 30)) # 60 tiles wide and 30 tall
	root_node.split(2, paths)
	setup_timers()
	queue_redraw()

func setup_timers():
	var biteTimer = BITE_ATTACK_TIMER.instantiate()
	#var lightningTimer = LIGHTNING_ATTACK_TIMER.instantiate()
	#var bulletTimer = BULLET_ATTACK_TIMER.instantiate()
	add_child(biteTimer)
	biteTimer.get_child(0).connect("timeout", self._on_biteTimer_timeout)
	#add_child(biteTimer)
	#add_child(biteTimer)

func _draw():	
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
				var position = Vector2i(x + leaf.position.x,y + leaf.position.y)
				if not leaf.isNotFloorTile(x, y, padding):
					# 1 is the atlas ID
					# 0,8 is the tile location in the atlas
					tilemap.set_cell(0, position, 1, tileMapFloorVector)
					spawn_enemy(Vector2i(tile_size*position.x, tile_size*position.y), default_spawn_percent)
				elif not leaf.isNotFloorTile(x, y + 1, padding):
					# Render top wall
					tilemap.set_cell(0, position, 1, tileMapWallVector)
				elif not leaf.isNotFloorTile(x, y - 1, padding):
					# Render bottom wall
					tilemap.set_cell(0, position, 1, tileMapWallVector, 5)
				elif not leaf.isNotFloorTile(x + 1, y, padding):
					# Render left wall
					tilemap.set_cell(0, position, 1, tileMapWallVector, 6)
				elif leaf.isNotFloorTile(x, y, padding) and not leaf.isNotFloorTile(x - 1, y, padding):
					# Render right wall
					tilemap.set_cell(0, position, 1, tileMapWallVector, 7)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x + 1, y + 1, padding):
					# Render top left wall
					tilemap.set_cell(0, position, 1, tileMapCornerVector, 1)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x - 1, y + 1, padding):
					# Render top right wall
					tilemap.set_cell(0, position, 1, tileMapCornerVector)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x + 1, y - 1, padding):
					# Render bottom left wall
					tilemap.set_cell(0, position, 1, tileMapCornerVector, 3)
				elif leaf.isNotFloorTile(x, y, padding) and leaf.isNotFloorTile(x + 1, y, padding) and leaf.isNotFloorTile(x - 1, y, padding) and leaf.isNotFloorTile(x, y + 1, padding) and leaf.isNotFloorTile(x, y - 1, padding) and not leaf.isNotFloorTile(x - 1, y - 1, padding):
					# Render bottom right wall
					tilemap.set_cell(0, position, 1, tileMapCornerVector, 2)
					
					
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

func spawn_enemy(spawn_position: Vector2i, spawn_percent: float = 1):
	if !(rng.randf_range(0,1) <= spawn_percent):
		return
	var new_enemy = ENEMY.instantiate()
	new_enemy.position = spawn_position
	self.add_child(new_enemy)
	classify_entity(new_enemy)

func _on_biteTimer_timeout():
	for biter in biters:
		biter.get_node("BiteAttacker").attack()
	
func classify_entity(entity):
	if entity.is_in_group("BITER"):
		biters.append(entity)
