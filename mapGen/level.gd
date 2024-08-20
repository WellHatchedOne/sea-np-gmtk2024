extends Node2D
class_name Level

# big green squares = space
# gray = out of bounds
# red = floor
# orange = walls

# CONSTANTS

@export var fire_audio: AudioStream = null

var DEBUG = false

var tile_size := 64 # pixels

var dungeonWidth := 90
var dungeonHeight := 30
var log2Rooms := 3 # value of 3 -> 2^3 = 8 rooms
var paddings = Vector4i(
	2, #rng.randi_range(2,2),
	2, #rng.randi_range(2,2),
	2, #rng.randi_range(2,2),
	2, #rng.randi_range(2,2)
)

var tilemapAtlasId := 0

@export var default_spawn_percent: float = 0.25

# END CONSTANTS

var root_node: Branch
var paths: Array = []

var spawnPoint: Vector2i
var bossSpawnPoint: Vector2i

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var biters: Array = []

#list of enemies that can be spawned 
const ENEMY = preload("res://Entities/Enemies/dummyEnemy.tscn")
const CARROT = preload("res://Entities/Enemies/Carrot/Carrot.tscn")
const CHEETO = preload("res://Entities/Enemies/cheetoGerm/cheetoGerm.tscn")
const ELECTRICTRAP = preload("res://Entities/Enemies/ElectricTrap/ElectricTrap.tscn")
const FLOWER = preload("res://Entities/Enemies/Flower/Flower.tscn")
const PINKGERM = preload("res://Entities/Enemies/greenGerm/greenGerm.tscn")
const PICO = preload("res://Entities/Enemies/Pico/Pico.tscn")



const BITE_ATTACK_TIMER = preload("res://Events/Timers/biteAttackTimer.tscn")
const FOOD = preload("res://Grace/food.tscn")
#const LIGHTNING_ATTACK_TIMER = preload("res://Entities/Enemies/meleeAttacker.tscn")
#const BULLET_ATTACK_TIMER = preload("res://Entities/Enemies/meleeAttacker.tscn")

var already_spawned_entities_map: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	#assert(tilemap != null, "Make sure you set the tilemap before add_child")
	#add_child(tilemap)
	$LevelTileMap.setAtlasIdAndVectors(tilemapAtlasId)
	
	root_node = Branch.new(Vector2i(0, 0), Vector2i(dungeonWidth, dungeonHeight)) # 90 tiles wide and 30 tall
	root_node.split(log2Rooms - 1, paths)
	queue_redraw()
	setSpawnPoints()
	
	setup_timers()
	
	# Irrelevant if this is slow, it's building the game and runs once before the player has agency
	for x in range(dungeonWidth):
		for y in range(dungeonHeight):
			already_spawned_entities_map[Vector2i(x,y)] = 0

func setSpawnPoints():
	var roomArray = root_node.get_leaves()
	var numRooms = roomArray.size()
	print("numOfRooms: " + str(numRooms))
	
	# find largest room for boss
	var largestRoom = 0
	var neMostRoom = 0
	var seMostRoom = 0
	var nwMostRoom = 0
	var swMostRoom = 0
	for room in range(numRooms):
		print("room: " + str(room) + ", position: " + str(roomArray[room].position) + ", size: " + str(roomArray[room].size))
		print("area: " + str(roomArray[room].size.x * roomArray[room].size.y))
		if(roomArray[room].size.x * roomArray[room].size.y > roomArray[largestRoom].size.x * roomArray[largestRoom].size.y):
			largestRoom = room
		if(roomArray[room].getNECorner() == Vector2i(0, 0)):
			neMostRoom = room
		if(roomArray[room].getNWCorner() == Vector2i(dungeonWidth, 0)):
			nwMostRoom = room
		if(roomArray[room].getSECorner() == Vector2i(0, dungeonHeight)):
			seMostRoom = room
		if(roomArray[room].getSWCorner() == Vector2i(dungeonWidth, dungeonHeight)):
			swMostRoom = room
	
	print("Boss Room (largestRoom): " + str(largestRoom))
	bossSpawnPoint = roomArray[largestRoom].get_center() * tile_size
	print("bossSpawnPoint: " + str(bossSpawnPoint))
	
	print(neMostRoom)
	print(nwMostRoom)
	print(seMostRoom)
	print(swMostRoom)
	
	# use dictionary as hashset
	# we want rat to spawn in a corner room
	var spawnRoomCandidates : Dictionary = {
		neMostRoom: null,
		nwMostRoom: null,
		seMostRoom: null,
		swMostRoom: null,
	}
	
	# we dont want rat to spawn in boss room
	spawnRoomCandidates.erase(largestRoom)
	print("spawnRoomCandidates: " + str(spawnRoomCandidates))
	
	var keysIndex = rng.randi_range(0, spawnRoomCandidates.size() - 1)
	print("keysIndex: " + str(keysIndex))
	var startRoomNum = spawnRoomCandidates.keys()[keysIndex]
	print("startRoomNum: " + str(startRoomNum))
	var startRoomLeaf = roomArray[startRoomNum]
	var centerOfRoom = startRoomLeaf.get_center()
	print("centerOfRoom: " + str(centerOfRoom))
	
	spawnPoint = centerOfRoom * tile_size
	print("spawnPoint: " + str(spawnPoint))

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
		
		renderFloor(leaf, paddings)
	
	for path in paths:
		renderRoomConnection(path)

# We should keep track of where things spawn so that we don't accidentally spawn things right next to each other
#self.bossSpawnPoint is a vector2
func handleRandomEnemySpawning(tile_index: Vector2i):
	var level_position = Vector2(tile_index.x*tile_size, tile_index.y*tile_size)
	
	if already_spawned_entities_map[tile_index] is Object:
		return
	elif already_spawned_entities_map[tile_index] != 0:
		return
	else:
		#tilemapAtlasId is the INT
		#0 is the lab
		#1 is the farm
		#2 is the sewer
		var RandEnemy = rng.randf_range(0, 10)
		if tilemapAtlasId == 0:
			if RandEnemy < 4:
				try_to_spawn_entity(CHEETO, tile_index, level_position, 0.01)
			if RandEnemy > 4 and RandEnemy < 7:
				try_to_spawn_entity(PINKGERM, tile_index, level_position, 0.01)
			if RandEnemy > 4 and RandEnemy < 7:
				try_to_spawn_entity(ELECTRICTRAP, tile_index, level_position, 0.01)
		if tilemapAtlasId == 1:
			if RandEnemy < 5:
				try_to_spawn_entity(FLOWER, tile_index, level_position, 0.05)
			if RandEnemy > 5 :
				try_to_spawn_entity(CARROT, tile_index, level_position, 0.05)
		if tilemapAtlasId == 2:
			if RandEnemy < 2:
				try_to_spawn_entity(CHEETO, tile_index, level_position, 0.01)
			if RandEnemy > 2 and RandEnemy < 4:
				try_to_spawn_entity(PINKGERM, tile_index, level_position, 0.01)
			if RandEnemy > 4 and RandEnemy < 6:
				try_to_spawn_entity(ELECTRICTRAP, tile_index, level_position, 0.01)
			if RandEnemy > 6 and RandEnemy < 8:
				try_to_spawn_entity(FLOWER, tile_index, level_position, 0.01)
			if RandEnemy > 8 :
				try_to_spawn_entity(CARROT, tile_index, level_position, 0.01)

func handleRandomPickupsSpawning(tile_index: Vector2i):
	var level_position = Vector2(tile_index.x*tile_size, tile_index.y*tile_size)
	
	if already_spawned_entities_map[tile_index] is Object:
		return
	elif already_spawned_entities_map[tile_index] != 0:
		return
	else:
		try_to_spawn_entity(FOOD, tile_index, level_position, 0.1)

func renderFloor(leaf: Branch, padding: Vector4i):
	for x in range(leaf.size.x):
		for y in range(leaf.size.y):
			# Only render tiles in actual rooms
			var xposition = x + leaf.position.x
			var yposition = y + leaf.position.y
			var currPosition = Vector2i(xposition, yposition)
			var levelPosition = Vector2i(tile_size*xposition, tile_size*yposition)
			if leaf.isFloorTile(x, y, padding):
				# 1 is the atlas ID
				# 0,8 is the tile location in the atlas
				setRandomFloorTile(xposition, yposition)
				handleRandomEnemySpawning(currPosition)
				handleRandomPickupsSpawning(currPosition)
				
			elif leaf.isFloorTile(x, y + 1, padding):
				# Render top wall
				$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapTopAlt)
			elif leaf.isFloorTile(x, y - 1, padding):
				# Render bottom wall
				$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapBottomAlt)
			elif leaf.isFloorTile(x + 1, y, padding):
				# Render left wall
				$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapLeftAlt)
			elif leaf.isFloorTile(x - 1, y, padding):
				# Render right wall
				$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapRightAlt)
			elif leaf.isNotFloorTile(x, y, padding) and leaf.hasNoCardinalAdjacentFloorTile(x, y, padding):
				if leaf.isFloorTile(x + 1, y + 1, padding):
					# Render top left wall
					$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapCornerVector, $LevelTileMap.tileMapTLAlt)
				elif leaf.isFloorTile(x - 1, y + 1, padding):
					# Render top right wall
					$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapCornerVector, $LevelTileMap.tileMapTRAlt)
				elif leaf.isFloorTile(x + 1, y - 1, padding):
					# Render bottom left wall
					$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapCornerVector, $LevelTileMap.tileMapBLAlt)
				elif leaf.isFloorTile(x - 1, y - 1, padding):
					# Render bottom right wall
					$LevelTileMap.set_cell(0, currPosition, tilemapAtlasId, $LevelTileMap.tileMapCornerVector, $LevelTileMap.tileMapBRAlt)

func renderRoomConnection(path):
	if path['left'].y == path['right'].y:
		# horizontal
		for i in range(path['right'].x - path['left'].x):
			var pathPos = Vector2i(path['left'].x+i,path['left'].y)
			var upPos = Vector2i(path['left'].x+i,path['left'].y-1)
			var downPos = Vector2i(path['left'].x+i,path['left'].y+1)
			
			var cellDataBeforePath = $LevelTileMap.get_cell_tile_data(0, pathPos)
			var cellDataUp = $LevelTileMap.get_cell_tile_data(0, upPos)
			var cellDataDown = $LevelTileMap.get_cell_tile_data(0, downPos)
			
			# Now check if the tile to above or below is also dead space
			if connectionWallShouldOverwriteTile(cellDataUp, upPos):
				# Render top wall
				$LevelTileMap.set_cell(0, upPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector)
			if connectionWallShouldOverwriteTile(cellDataDown, downPos):
				# Render bottom wall
				$LevelTileMap.set_cell(0, downPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapBottomAlt)
			
			# This means the connecting path we are about to render is in dead space
			if cellDataBeforePath == null:
				pass
			else:
				 # This means we could be breaking down a wall, or just overwriting an existing floor tile
				 # If we're breaking down a wall, also render another wall piece on another layer above or below
				if ($LevelTileMap.get_cell_atlas_coords(0, pathPos) == Vector2i(0,0) && $LevelTileMap.get_cell_alternative_tile(0, pathPos) == $LevelTileMap.tileMapRightAlt):
					if ($LevelTileMap.get_cell_atlas_coords(0, upPos) == Vector2i(0,0) && $LevelTileMap.get_cell_alternative_tile(0, upPos) == $LevelTileMap.tileMapRightAlt) || ($LevelTileMap.get_cell_atlas_coords(0, upPos) == $LevelTileMap.tileMapCornerVector):
						# Render top wall
						$LevelTileMap.set_cell(1, upPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector)
					if ($LevelTileMap.get_cell_atlas_coords(0, downPos) == Vector2i(0,0) && $LevelTileMap.get_cell_alternative_tile(0, downPos) == $LevelTileMap.tileMapRightAlt) || ($LevelTileMap.get_cell_atlas_coords(0, downPos) == $LevelTileMap.tileMapCornerVector):
						# Render bottom wall
						$LevelTileMap.set_cell(1, downPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapBottomAlt)
				elif ($LevelTileMap.get_cell_atlas_coords(0, pathPos) == Vector2i(0,0) && $LevelTileMap.get_cell_alternative_tile(0, pathPos) == $LevelTileMap.tileMapLeftAlt):
					if ($LevelTileMap.get_cell_atlas_coords(0, upPos) == Vector2i(0,0) && $LevelTileMap.get_cell_alternative_tile(0, upPos) == $LevelTileMap.tileMapLeftAlt) || ($LevelTileMap.get_cell_atlas_coords(0, upPos) == $LevelTileMap.tileMapCornerVector):
						# Render top wall
						$LevelTileMap.set_cell(1, upPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector)
					if ($LevelTileMap.get_cell_atlas_coords(0, downPos) == Vector2i(0,0) && $LevelTileMap.get_cell_alternative_tile(0, downPos) == $LevelTileMap.tileMapLeftAlt) || $LevelTileMap.get_cell_atlas_coords(0, downPos) == $LevelTileMap.tileMapCornerVector:
						# Render bottom wall
						$LevelTileMap.set_cell(1, downPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapBottomAlt)
			
			# Now draw the path connection tiles
			if DEBUG:
				$LevelTileMap.set_cell(0, Vector2i(path['left'].x+i,path['left'].y), tilemapAtlasId, Vector2i(0, 9))
				$LevelTileMap.set_cell(1, Vector2i(path['left'].x+i,path['left'].y), tilemapAtlasId, Vector2i(0, 15))
			else:
				$LevelTileMap.set_cell(0, Vector2i(path['left'].x+i,path['left'].y), tilemapAtlasId, $LevelTileMap.tileMapFloorVector)
	else:
		# vertical
		for i in range(path['right'].y - path['left'].y):
			var pathPos = Vector2i(path['left'].x,path['left'].y+i)
			var leftPos = Vector2i(path['left'].x - 1,path['left'].y+i)
			var rightPos = Vector2i(path['left'].x + 1,path['left'].y+i)
			
			var cellDataBeforePath = $LevelTileMap.get_cell_tile_data(0, pathPos)
			var cellDataLeft = $LevelTileMap.get_cell_tile_data(0, leftPos)
			var cellDataRight = $LevelTileMap.get_cell_tile_data(0, rightPos)
			
			# Now check if the tile to our left or right is also dead space
			if connectionWallShouldOverwriteTile(cellDataLeft, leftPos):
				# Render left wall
				$LevelTileMap.set_cell(1, leftPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapLeftAlt)
			if connectionWallShouldOverwriteTile(cellDataRight, rightPos):
				# Render right wall
				$LevelTileMap.set_cell(1, rightPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapRightAlt)
			
			# This means the connecting path we are about to render is in dead space
			if cellDataBeforePath == null:
				pass
			else:
				# This means we could be breaking down a wall, or just overwriting an existing floor tile
				# If we're breaking down a wall, also render another wall piece on another layer one to the left or right
				if ($LevelTileMap.get_cell_atlas_coords(0, pathPos) == $LevelTileMap.tileMapWallVector && $LevelTileMap.get_cell_alternative_tile(0, pathPos) == $LevelTileMap.tileMapTopAlt):
					if ($LevelTileMap.get_cell_atlas_coords(0, leftPos) == $LevelTileMap.tileMapWallVector && $LevelTileMap.get_cell_alternative_tile(0, leftPos) == $LevelTileMap.tileMapTopAlt) || ($LevelTileMap.get_cell_atlas_coords(0, leftPos) == $LevelTileMap.tileMapCornerVector):
						# Render left wall
						$LevelTileMap.set_cell(1, leftPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapLeftAlt)
					if ($LevelTileMap.get_cell_atlas_coords(0, rightPos) == $LevelTileMap.tileMapWallVector && $LevelTileMap.get_cell_alternative_tile(0, rightPos) == $LevelTileMap.tileMapTopAlt) || ($LevelTileMap.get_cell_atlas_coords(0, rightPos) == $LevelTileMap.tileMapCornerVector):
						# Render right wall
						$LevelTileMap.set_cell(1, rightPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapRightAlt)
				elif ($LevelTileMap.get_cell_atlas_coords(0, pathPos) == $LevelTileMap.tileMapWallVector && $LevelTileMap.get_cell_alternative_tile(0, pathPos) == $LevelTileMap.tileMapBottomAlt):
					if ($LevelTileMap.get_cell_atlas_coords(0, leftPos) == $LevelTileMap.tileMapWallVector && $LevelTileMap.get_cell_alternative_tile(0, leftPos) == $LevelTileMap.tileMapBottomAlt) || ($LevelTileMap.get_cell_atlas_coords(0, leftPos) == $LevelTileMap.tileMapCornerVector):
						# Render left wall
						$LevelTileMap.set_cell(1, leftPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapLeftAlt)
					if ($LevelTileMap.get_cell_atlas_coords(0, rightPos) == $LevelTileMap.tileMapWallVector && $LevelTileMap.get_cell_alternative_tile(0, rightPos) == $LevelTileMap.tileMapBottomAlt) || ($LevelTileMap.get_cell_atlas_coords(0, rightPos) == $LevelTileMap.tileMapCornerVector):
						# Render right wall
						$LevelTileMap.set_cell(1, rightPos, tilemapAtlasId, $LevelTileMap.tileMapWallVector, $LevelTileMap.tileMapRightAlt)
			
			# Now draw the path connection tiles
			if DEBUG:
				$LevelTileMap.set_cell(0, Vector2i(path['left'].x,path['left'].y+i), tilemapAtlasId, Vector2i(0, 11))
				$LevelTileMap.set_cell(1, Vector2i(path['left'].x,path['left'].y+i), tilemapAtlasId, Vector2i(0, 12))
			else:
				$LevelTileMap.set_cell(0, Vector2i(path['left'].x,path['left'].y+i), tilemapAtlasId, $LevelTileMap.tileMapFloorVector)

func connectionWallShouldOverwriteTile(cellData, pos):
	return cellData == null || $LevelTileMap.get_cell_atlas_coords(0, pos) == $LevelTileMap.tileMapWallVector || $LevelTileMap.get_cell_atlas_coords(0, pos) == $LevelTileMap.tileMapCornerVector

const spawn_overlap_protection_padding = 1
func try_to_spawn_entity(entity_file_path, tile_index: Vector2i, level_position: Vector2, spawn_percent: float = 1):
	if !(rng.randf_range(0,1) <= spawn_percent):
		return
	
	var new_entity = entity_file_path.instantiate()
	new_entity.position = level_position
	
	# Apply a padding around newly spawned entities so that entities aren't clumped together
	already_spawned_entities_map[tile_index] = new_entity
	for x in range(-spawn_overlap_protection_padding, spawn_overlap_protection_padding+1):
		for y in range(-spawn_overlap_protection_padding, spawn_overlap_protection_padding+1):
			if x == 0 && y == 0:
				continue
			already_spawned_entities_map[Vector2i(x,y) + tile_index] = -1

	self.add_child(new_entity)
	
	# Apply groups to entities
	classify_entity(new_entity)


func _on_biteTimer_timeout():
	for biter in biters:
		biter.get_node("BiteAttacker").attack()
	
func classify_entity(entity):
	if entity.is_in_group("BITER"):
		biters.append(entity)

func setRandomFloorTile(xposition, yposition):
	var rand := rng.randi_range(0, 99) # [0, 100) ints
	$LevelTileMap.set_cell(0, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVector)
	# random floor tiles
	if isBottomRightOfFourFloorTiles(xposition, yposition) && rand > 94:
		if rand <= 96:
			$LevelTileMap.set_cell(0, Vector2i(xposition - 1, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapNE)
			$LevelTileMap.set_cell(0, Vector2i(xposition, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapNW)
			$LevelTileMap.set_cell(0, Vector2i(xposition - 1, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapSE)
			$LevelTileMap.set_cell(0, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapSW)
		elif rand <= 98:
			$LevelTileMap.set_cell(0, Vector2i(xposition - 1, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawNE)
			$LevelTileMap.set_cell(0, Vector2i(xposition, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawNW)
			$LevelTileMap.set_cell(0, Vector2i(xposition - 1, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawSE)
			$LevelTileMap.set_cell(0, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawSW)
		else:
			$LevelTileMap.set_cell(0, Vector2i(xposition - 1, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeNE)
			$LevelTileMap.set_cell(0, Vector2i(xposition, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeNW)
			$LevelTileMap.set_cell(0, Vector2i(xposition - 1, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeSE)
			$LevelTileMap.set_cell(0, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeSW)
	
func isBottomRightOfFourFloorTiles(xposition, yposition):
	return tileIsSetToFloorVector(xposition, yposition) && tileIsSetToFloorVector(xposition - 1, yposition) && tileIsSetToFloorVector(xposition, yposition - 1) && tileIsSetToFloorVector(xposition - 1, yposition - 1)
	
func tileIsSetToFloorVector(xpos, ypos):
	return $LevelTileMap.get_cell_atlas_coords(0, Vector2i(xpos, ypos)) == $LevelTileMap.tileMapFloorVector
