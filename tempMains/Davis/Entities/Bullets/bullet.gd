extends Node
class_name Bullet


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func  _on_ready():
	var area2d = $"Area2d"
	area2d.connect("body_entered",self._collide(area2d))

func _collide(area): #area is the Area2D of the building
	print("bullet hit something")
	queue_free()
