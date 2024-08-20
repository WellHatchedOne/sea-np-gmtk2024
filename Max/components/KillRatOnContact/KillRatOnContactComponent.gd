extends Area2D

@onready var collision_shape_2d = $CollisionShape2D
var parent_collision = null
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_parent().get_children():
		if child is CollisionShape2D:
			parent_collision = child
			break
	collision_shape_2d.shape = parent_collision.shape


func _on_body_entered(body):
	print("rat killed by hitting them")
	if body is Rat:
		body._on_hit_by_bullet()
