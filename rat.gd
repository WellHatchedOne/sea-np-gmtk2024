extends CharacterBody2D
class_name Rat

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
const DISTANCE_FROM_PACK_TO_STOP_MOVING = 500
const DISTANCE_FROM_PACK_TO_START_MOVING = 50
enum RatState {FOLLOWING, SITTING}
var currentRatState = RatState.FOLLOWING
var startingPosition:Vector2
var delay:float = 0
var currentTimeOffset:float = 0
var timeOffsetQueue:Array[float] = []
var positionOffSetQueue:Array[Vector2] = []

var ratType = "basic"

# Called when the node enters the scene tree for the first time.
func _ready():
	startingPosition = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Code should eventually cause a rat to be deleted
func _on_hit_by_bullet():
	pass

func enable_collision():
	collision_shape_2d.disabled = false

# Sets how much of a time delay the rat has from the pack
func set_delay(newDelay:float):
	delay = newDelay

# Moves the rat for this frame relative to the swarm
func ratMove(swarmVelocity:Vector2, speed:float, delta:float):
	var desiredGlobalPosition:Vector2 = getRatDesiredGlobalPosition(swarmVelocity, speed, delta)
	var shouldAnimate = moveAndSlideRat(desiredGlobalPosition, swarmVelocity, speed, delta)
	if shouldAnimate:
		animateRat(swarmVelocity)

func getRatDesiredGlobalPosition(swarmVelocity:Vector2, speed:float, delta:float) -> Vector2:
	# Push this frame's velocity onto our queue of time and position offsets
	timeOffsetQueue.push_back(delta)
	positionOffSetQueue.push_back(swarmVelocity)

	# Modify our current time offset based on this frame
	currentTimeOffset += delta

	# Get desired position
	var desiredPosition:Vector2 = Vector2.ZERO
	while (timeOffsetQueue.size() > 0 && positionOffSetQueue.size() > 0 && currentTimeOffset > delay):
		currentTimeOffset -= timeOffsetQueue.pop_front()
		desiredPosition += positionOffSetQueue.pop_front()

	return desiredPosition

# Returns true if motion should be animated, false if not
func moveAndSlideRat(desiredGlobalPosition: Vector2, swarmVelocity:Vector2, speed:float, delta:float) -> bool:
	if (position.distance_to(Vector2.ZERO) < DISTANCE_FROM_PACK_TO_START_MOVING):
		currentRatState = RatState.FOLLOWING

	if(currentRatState == RatState.SITTING || 
		position.distance_to(Vector2.ZERO) > DISTANCE_FROM_PACK_TO_STOP_MOVING):
		currentRatState = RatState.SITTING
		# Make the rats stay stil if they are too far away (technically, they have to move to oppose the pack)
		velocity = -1 * swarmVelocity
		move_and_slide()
		return false

	var desiredGlobalVelocity:Vector2 = (desiredGlobalPosition).normalized() * speed
	if(swarmVelocity == Vector2.ZERO && desiredGlobalVelocity == Vector2.ZERO):
		var vectorToStartingPosition = startingPosition - position
		velocity = vectorToStartingPosition.normalized() * speed
		if vectorToStartingPosition.length() > 5:
			move_and_slide()
			return true
		else:
			# Move back to starting position when rat and frame isn't moving
			position = position.move_toward(startingPosition, speed * delta)
			return false
	else:
		velocity = desiredGlobalVelocity - swarmVelocity
		move_and_slide()
		return true

# GlobalRatVelocity is the rat's velocity relative to the background (since this.velocity is relative to the pack)
var last_state = null
func animateRat(swarmVelocity:Vector2):
	var globalRatVelocity:Vector2 = swarmVelocity + velocity
	if globalRatVelocity.length() > 0:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.stop()

	if globalRatVelocity.x != 0:
		animated_sprite_2d.animation = "side"
		animated_sprite_2d.flip_v = false
		animated_sprite_2d.flip_h = globalRatVelocity.x < 0
		if globalRatVelocity.x < 0:
			last_state = "sideA"
			animated_sprite_2d.rotation = (deg_to_rad(90))
			self.rotation = (deg_to_rad(-90))
		else:
			last_state = "sideB"
			animated_sprite_2d.rotation = deg_to_rad(-90)
			self.rotation = (deg_to_rad(90))
	elif globalRatVelocity.y != 0:
		if globalRatVelocity.y > 0:
			animated_sprite_2d.animation = "down"
			last_state = "down"
			animated_sprite_2d.rotation = (deg_to_rad(180))
			self.rotation = (deg_to_rad(180))
		else:
			animated_sprite_2d.animation = "up"
			last_state = "up"
			animated_sprite_2d.rotation = (deg_to_rad(0))
			self.rotation = (deg_to_rad(0))
	print(last_state)
	

func execute_move():
	pass
