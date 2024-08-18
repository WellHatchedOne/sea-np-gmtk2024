extends CharacterBody2D
class_name Rat

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
var delay = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enable_collision():
	collision_shape_2d.disabled = false

func set_delay(newDelay:float):
	delay = newDelay

func ratMove(swarmVelocity, speed, delta):
	velocity = getRatVelocity()
	var globalRatVelocity:Vector2 = swarmVelocity + velocity
	animateRat(globalRatVelocity)

func getRatVelocity() -> Vector2:
	return Vector2.ZERO

# GlobalRatVelocity is the rat's velocity relative to the background (since this.velocity is relative to the pack
func animateRat(globalRatVelocity):
	if globalRatVelocity.length() > 0:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.stop()

	if globalRatVelocity.x != 0:
		animated_sprite_2d.animation = "side"
		animated_sprite_2d.flip_v = false
		animated_sprite_2d.flip_h = globalRatVelocity.x < 0
	elif globalRatVelocity.y != 0:
		if globalRatVelocity.y > 0:
			animated_sprite_2d.animation = "down"
		else:
			animated_sprite_2d.animation = "up"

func execute_move():
	pass
