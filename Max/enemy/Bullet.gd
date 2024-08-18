extends Area2D
class_name Bullet

@export var speed = 15
var direction = Vector2(0,0)
var start_traveling = false

func start(pos):
	position = pos

func _physics_process(delta):
	if start_traveling:
		position += direction*speed
		
func _on_body_entered(body):
	if body is TileMap:
		queue_free()
