extends Node2D

class_name Dungeon
const LEVEL = preload("res://mapGen/level.tscn")
var levelPointer : Level = null
var debug = true
var currentLevel = 1

func _ready():
	load_new_level(currentLevel)
	music()


func music():
	var music = AudioStreamPlayer.new()
	add_child(music)
	const default_music = preload("res://assets/Music/wtf_is_this.wav")

	music.stream = default_music
	music.play()


func _input(event):
	if event.is_action_pressed("Load Level 1"):
		load_new_level(0)
	if event.is_action_pressed("Load Level 2"):
		load_new_level(1)
	if event.is_action_pressed("Load Level 3"):
		load_new_level(2)

func load_next_level():
	load_new_level(currentLevel + 1)

func load_new_level(levelNum : int):
	currentLevel = levelNum
	if levelPointer != null:
		print("Level child found")
		remove_child(levelPointer) # remove reference
		levelPointer.queue_free() # delete memory
	else:
		print("No Level child found")
		
	var level = LEVEL.instantiate()
	level.tilemapAtlasId = levelNum
	get_child(0).add_sibling(level) # add_child and move_child to 0, but without adding to end first
	levelPointer = level
	print("SpawnPoint: " + str(level.spawnPoint))
	
	
	if debug:
		$PackOfRats.position = Vector2(400,400)
	else:
		$PackOfRats.position = level.spawnPoint
