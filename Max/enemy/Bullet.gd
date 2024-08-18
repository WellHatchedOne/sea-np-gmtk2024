extends Area2D
class_name Bullet

@export var speed = 15
@export var direction = Vector2(0.5,0.5)

func start(pos):
	position = pos

func _physics_process(delta):
	position += direction*speed

func _on_area_entered(area):
	# Collision Layer and Mask is fucked right now
	print(area.name)
