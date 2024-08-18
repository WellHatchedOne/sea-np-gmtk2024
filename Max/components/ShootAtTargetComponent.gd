extends Area2D
class_name ShootAtTargetComponent

const BULLET = preload("res://Max/enemy/Bullet.tscn")
@export var target: Node = null
@export var vision_radius: float = 200
@export var bullet_speed: float = 6
@onready var vision_circle_shape = $VisionCircleShape

# Called when the node enters the scene tree for the first time.
func _ready():
	if (target == null):
		target = owner.find_child("PackOfRats")

	vision_circle_shape.shape.radius = vision_radius

func shoot_at_target():
	var new_bullet: Bullet = BULLET.instantiate()
	# Added call_deferred to queue the action since there are also collision checks
	self.call_deferred("add_child", new_bullet)
	new_bullet.start(self.position)
	new_bullet.speed = bullet_speed
	new_bullet.direction = self.position.direction_to(target.position)

func _on_body_entered(body):
	target = body
	shoot_at_target()
func _on_body_exited(body):
	target = null
