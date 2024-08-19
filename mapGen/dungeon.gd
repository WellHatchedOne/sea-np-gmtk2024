extends Node2D

const LEVEL = preload("res://mapGen/level.tscn")

func _ready():
	var level = LEVEL.instantiate()
	level.selected_level = 420
	add_child(level)
	move_child(level, 0)
	print(level.spawnPoint)
	
	$PackOfRats.position = level.spawnPoint
	# level.bossSpawnPoint exists!
