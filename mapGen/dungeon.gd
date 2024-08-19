extends Node2D

const LEVEL = preload("res://mapGen/level.tscn")

var levelPointer : Level = null

func _ready():
	var level = LEVEL.instantiate()
	level.tilemapAtlasId = 2
	get_child(0).add_sibling(level) # add_child and move_child to 0, but without adding to end first
	print(level.spawnPoint)
	$PackOfRats.position = level.spawnPoint
	music()


func music():
	var music = AudioStreamPlayer.new()
	add_child(music)
	const default_music = preload("res://assets/Music/tune0.wav")

	music.stream = default_music
	music.play()

func _input(event):
	if event.is_action_pressed("Load Level 1"):
		load_new_level(0)
	if event.is_action_pressed("Load Level 2"):
		load_new_level(1)
	if event.is_action_pressed("Load Level 3"):
		load_new_level(2)

func load_new_level(levelNum : int):
	if levelPointer != null:
		print("Level child found")
		remove_child(levelPointer) # remove reference
		levelPointer.queue_free() # delete memory
	else:
		print("No Level child found")
		
	var level = LEVEL.instantiate()
	print("level:" + level.name)
	level.tilemapAtlasId = levelNum
	##get_child(0).add_sibling(level) # add_child and move_child to 0, but without adding to end first
	levelPointer = level
	add_child(level)
	move_child(level, 0)
	print(level.spawnPoint)
	
	$PackOfRats.position = level.spawnPoint
