extends Node2D

const LEVEL = preload("res://mapGen/level.tscn")

func _ready():
	var level = LEVEL.instantiate()
	add_child(level)
	move_child(level, 0)
	print(level.spawnPoint)
	
	$PackOfRats.position = level.spawnPoint
