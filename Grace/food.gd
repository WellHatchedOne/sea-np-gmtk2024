extends Area2D
class_name Food

signal eat
# Rat object path
const RAT = preload("res://rat.gd")
# generic food-type object. This could be modified to be any random food by 
# changing the animation--use commented out code in _ready to do this
func _ready():
	$AnimatedSprite2D.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	# This should be where your cheese disappears and your new rat comes in
	if body is RAT:
		body.get_parent().spawn_spiral_rat()
		queue_free()
	
