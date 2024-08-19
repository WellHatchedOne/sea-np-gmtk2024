extends Area2D
class_name BulletHitboxComponent

@export var kill_on_hit: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	if area is Bullet:
		if get_parent().has_method("_on_hit_by_bullet"):
			get_parent()._on_hit_by_bullet()
			
