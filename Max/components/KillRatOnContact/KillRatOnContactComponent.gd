extends Area2D

var collision_shape: CollisionShape2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_parent().get_children():
		if child is CollisionShape2D:
			collision_shape = child
			break
	
	# Get the collision shape of the parent
	self.add_child(collision_shape)
	assert(collision_shape != null, "%s HealthComponent does not have collision shape" % get_parent())


func _on_body_entered(body):
	if body is Rat:
		body._on_hit_by_bullet()
