extends CharacterBody2D
class_name TEST_ENEMY

@export var speed: float = 400
@export var bulletSpeed: float = 50
@export var health: int = 1

func _input(event):
	if event.is_action_pressed("change_color"):
		change_color()
		#_shoot()
	
func change_color() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())
