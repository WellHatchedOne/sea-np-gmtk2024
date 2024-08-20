extends Area2D
class_name MoveAtTargetComponent

const Enemy = preload("res://Max/enemy/test_enemy.tscn")
@export var target: Node = null
@export var enemy_radius: float = 200


var direction = Vector2(0,0)
var inbody = false
var true_parent

@onready var vision_circle_shape = $VisionCircleShape1


# Called when the node enters the scene tree for the first time.
func _ready():
	
	true_parent = get_parent()
	target = true_parent.get_parent().find_child("PackOfRats")
	vision_circle_shape.shape.radius = enemy_radius


func _process(delta):
	if inbody == true:
		direction = true_parent.position.direction_to(target.position)
		
func _on_body_entered(body):
	if !(body is PackOfRats):
		return
	target = body
	inbody = true

func _on_body_exited(body):
	if !(body is PackOfRats):
		return
	inbody = false
	direction = Vector2(0,0)


