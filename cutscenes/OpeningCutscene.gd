extends Node2D


func _ready():
	var gain_power_animated_sprite = $Scenes/GainPower
	gain_power_animated_sprite.play("GainPower")
	var rat_moving_animated_sprite = $Scenes/RatMoving
	rat_moving_animated_sprite.play("RatMoving")
	$AnimationPlayer.play()

func _on_button_pressed():
	
	get_tree().change_scene_to_file("res://mapGen/dungeon.tscn")
