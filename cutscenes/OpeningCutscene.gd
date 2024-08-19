extends Node2D


func _ready():
	$AnimationPlayer.play()




func _on_button_pressed():
	print("Hello world!")
	get_tree().change_scene_to_file("res://mapGen/dungeon.tscn")
