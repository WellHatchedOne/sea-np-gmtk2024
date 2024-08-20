extends Node2D

var score = 50
@onready var pack_of_rats = $"../PackOfRats"
@onready var dungeon = $".."


func _ready():
	score = pack_of_rats.ratnumber

func _process(delta):
	print(score)
	if score == 50:
		print("50")
		#dungeon.music()
		pass
		#spawnpico"res://Entities/Enemies/Pico/Pico.tscn"
		

