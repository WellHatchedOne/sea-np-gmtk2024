extends CharacterBody2D

func _input(event):
	if event.is_action_pressed("change_color"):
		change_color()
		#_shoot()
	
func change_color() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())
