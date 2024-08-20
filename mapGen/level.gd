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
var score = 1
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
@onready var pack_of_rats = $PackOfRats

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

const CAT = preload("res://Entities/Enemies/Pico/Pico.tscn")

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

var pass50 = false
func _process(delta):
	score = get_parent().get_node("PackOfRats").ratnumber
	
	if pass50 == false and score == 50: 
		pass50 =true
		_spawncat()
		

func _spawncat():
	var new_cat  = CAT.instantiate()
	new_cat.position = bossSpawnPoint
	self.add_child(new_cat)

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
		renderRoomConnectionInternal(path, true)
	else:
		renderRoomConnectionInternal(path, false)

func renderRoomConnectionInternal(path, horizontal):
	var axisIndex = 0 if horizontal else 1
	var sideModifier1 = Vector2i(0 , -1) if horizontal else Vector2i(-1, 0)
	var sideModifier2 = Vector2i(0 , 1) if horizontal else Vector2i(1, 0)
	var pathWallLayer = 1 if horizontal else 2
	
	for i in range(path['right'][axisIndex] - path['left'][axisIndex]):
		var pathDiff = Vector2i(i , 0) if horizontal else Vector2i(0, i)
		
		var pathPos = path['left'] + pathDiff
		var sidePos1 = pathPos + sideModifier1
		var sidePos2 = pathPos + sideModifier2
		
		var cellDataBeforePath = $LevelTileMap.get_cell_tile_data(0, pathPos)
		var cellDataSide1 = $LevelTileMap.get_cell_tile_data(0, sidePos1)
		var cellDataSide2 = $LevelTileMap.get_cell_tile_data(0, sidePos2)
		
		# Now check if the tile to above or below is also dead space
		if connectionWallShouldOverwriteTile(cellDataSide1, sidePos1):
			# Render side1 wall
			var alt = $LevelTileMap.tileMapTopAlt if horizontal else $LevelTileMap.tileMapLeftAlt
			$LevelTileMap.set_cell(pathWallLayer, sidePos1, tilemapAtlasId, $LevelTileMap.tileMapWallVector, alt)
		if connectionWallShouldOverwriteTile(cellDataSide2, sidePos2):
			# Render side2 wall
			var alt = $LevelTileMap.tileMapBottomAlt if horizontal else $LevelTileMap.tileMapRightAlt
			$LevelTileMap.set_cell(pathWallLayer, sidePos2, tilemapAtlasId, $LevelTileMap.tileMapWallVector, alt)
		
		# Now draw the path connection tiles
		if DEBUG:
			$LevelTileMap.set_cell(0, pathPos, tilemapAtlasId, Vector2i(0, 9))
			$LevelTileMap.set_cell(1, pathPos, tilemapAtlasId, Vector2i(0, 15))
		else:
			# Path floor should overwrite all (non-cosmetic) layers
			$LevelTileMap.set_cell(0, pathPos, tilemapAtlasId, $LevelTileMap.tileMapFloorVector)
			$LevelTileMap.set_cell(1, pathPos, tilemapAtlasId, $LevelTileMap.tileMapFloorVector)
			$LevelTileMap.set_cell(2, pathPos, tilemapAtlasId, $LevelTileMap.tileMapFloorVector)

func connectionWallShouldOverwriteTile(cellData, pos):
	return cellData == null || $LevelTileMap.get_cell_atlas_coords(0, pos) == $LevelTileMap.tileMapWallVector || $LevelTileMap.get_cell_atlas_coords(0, pos) == $LevelTileMap.tileMapCornerVector

func isPositionCorrectTileAndAlt(pos, tile, alt):
	return $LevelTileMap.get_cell_atlas_coords(0, pos) == tile && $LevelTileMap.get_cell_alternative_tile(0, pos) == alt

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
	$LevelTileMap.set_cell(3, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVector)
	# random floor tiles
	if isBottomRightOfFourFloorTiles(xposition, yposition) && rand > 94:
		if rand <= 96:
			$LevelTileMap.set_cell(3, Vector2i(xposition - 1, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapNE)
			$LevelTileMap.set_cell(3, Vector2i(xposition, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapNW)
			$LevelTileMap.set_cell(3, Vector2i(xposition - 1, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapSE)
			$LevelTileMap.set_cell(3, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTrapSW)
		elif rand <= 98:
			$LevelTileMap.set_cell(3, Vector2i(xposition - 1, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawNE)
			$LevelTileMap.set_cell(3, Vector2i(xposition, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawNW)
			$LevelTileMap.set_cell(3, Vector2i(xposition - 1, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawSE)
			$LevelTileMap.set_cell(3, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorClawSW)
		else:
			$LevelTileMap.set_cell(3, Vector2i(xposition - 1, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeNE)
			$LevelTileMap.set_cell(3, Vector2i(xposition, yposition - 1), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeNW)
			$LevelTileMap.set_cell(3, Vector2i(xposition - 1, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeSE)
			$LevelTileMap.set_cell(3, Vector2i(xposition, yposition), tilemapAtlasId, $LevelTileMap.tileMapFloorVectorTubeSW)
	
func isBottomRightOfFourFloorTiles(xposition, yposition):
	return tileIsSetToCleanFloorVector(xposition, yposition) && tileIsSetToCleanFloorVector(xposition - 1, yposition) && tileIsSetToCleanFloorVector(xposition, yposition - 1) && tileIsSetToCleanFloorVector(xposition - 1, yposition - 1)
	
func tileIsSetToCleanFloorVector(xpos, ypos):
	return $LevelTileMap.get_cell_atlas_coords(0, Vector2i(xpos, ypos)) == $LevelTileMap.tileMapFloorVector &&  $LevelTileMap.get_cell_atlas_coords(3, Vector2i(xpos, ypos)) == $LevelTileMap.tileMapFloorVector
