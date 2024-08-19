extends Area2D
class_name MoveAtTargetComponent

const Enemy = preload("res://Max/enemy/test_enemy.tscn")
@export var target: Node = null
@export var enemy_radius: float = 200


var direction = Vector2(0,0)
var inbody = false


@onready var vision_circle_shape = $VisionCircleShape


# Called when the node enters the scene tree for the first time.
func _ready():
	if (true):
		target = owner.find_child("PackOfRats")
		
	vision_circle_shape.shape.radius = enemy_radius


func _process(delta):
	
	if inbody == true:
		direction = get_parent().position.direction_to(target.position)
	
		
	


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


