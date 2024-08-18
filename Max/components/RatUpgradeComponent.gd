extends Area2D

@export var new_sprite: PackedScene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(new_sprite != null, "RatUpgradeComponent does not have an upgrade sprite")
	
func update_animated_sprite(Rat: rat):
	print(rat.position)

func _on_body_entered(body):
	print(body)
	if body is Rat:
		update_animated_sprite(body)
		
