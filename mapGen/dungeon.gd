extends Node2D

const LEVEL = preload("res://mapGen/level.tscn")

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
