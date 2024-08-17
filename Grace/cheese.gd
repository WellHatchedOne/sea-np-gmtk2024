extends RigidBody2D


# generic food-type object. This could be modified to be any random food by 
# changing the animation--use commented out code in _ready to do this
func _ready():
	# var food_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	# $AnimatedSprite2D.play(food_types[randi() % food_types.size()])
	$AnimatedSprite2D.play("rest") 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	# This should be where your cheese disappears and your new rat comes in
	# I think this line makes it disappear? idk
	queue_free()
