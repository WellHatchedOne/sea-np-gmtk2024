extends CharacterBody2D
class_name Rat

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
var delay:float = 0
var currentDeltaOffset:float = 0
var currentPositionOffset:Vector2 = Vector2.ZERO
var deltaQueue:Array[float] = []
var positionQueue:Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Code should eventually cause a rat to be deleted
func _on_hit_by_bullet():
  pass

func enable_collision():
	collision_shape_2d.disabled = false

func set_delay(newDelay:float):
	delay = newDelay

func ratMove(swarmVelocity:Vector2, speed:float, delta:float):
	velocity = getRatVelocity(swarmVelocity, speed, delta)
	move_and_slide()
	currentPositionOffset += velocity
	var globalRatVelocity:Vector2 = swarmVelocity + velocity
	animateRat(globalRatVelocity)

func getRatVelocity(swarmVelocity:Vector2, speed:float, delta:float) -> Vector2:
	# Start with a rat velocity opposite of the swarm. This will keep the rat still
	var ratVelocity:Vector2 = swarmVelocity * -1
	
	# Push this frame's velocity onto our stack
	deltaQueue.push_back(delta)
	if positionQueue.size() == 0:
		positionQueue.push_back(swarmVelocity)
	else:
		positionQueue.push_back(positionQueue[-1] + swarmVelocity)
	
	currentDeltaOffset += delta
	# Get desired position
	var desiredPosition:Vector2 = Vector2.ZERO
	while (currentDeltaOffset > delay):
		currentDeltaOffset -= deltaQueue.pop_front()
		desiredPosition = positionQueue.pop_front()
	
	var desiredGlobalVelocity:Vector2 = (desiredPosition - currentPositionOffset).normalized() * speed
	ratVelocity += desiredGlobalVelocity
	
	#print("swarmVelocity = " + str(swarmVelocity) + ", currentDeltaOffSet = " + str(currentDeltaOffset) + ", desiredGlobalVelocity = " + str(desiredGlobalVelocity) + ", ratVelocity = " + str(ratVelocity) + ", desiredPosition = " + str(desiredPosition) + ", currentPositionOffset = " + str(currentPositionOffset) +", positionQueue = " + str(positionQueue) + ", deltaQueue = " + str(deltaQueue))
	
	return ratVelocity

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
