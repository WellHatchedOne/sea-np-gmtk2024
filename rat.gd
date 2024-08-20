extends CharacterBody2D
class_name Rat

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
const DISTANCE_FROM_PACK_TO_STOP_MOVING = 500
const DISTANCE_FROM_PACK_TO_START_RETURING = 150
const DISTANCE_FROM_PACK_TO_BE_MARKED_AS_RETURNED = 5
enum RatState {FOLLOWING, SITTING, RETURNING}
var currentRatState = RatState.FOLLOWING
var defaultPosition:Vector2
var startingPosition:Vector2
var clusterPosition:Vector2
var delay:float = 0
var currentTimeOffset:float = 0
var timeOffsetQueue:Array[float] = []
var positionOffSetQueue:Array[Vector2] = []
var defaultRatOffset = Vector2.ZERO
var sideRatOffset = Vector2.ZERO

var ratType = "basic"

# Called when the node enters the scene tree for the first time.
func _ready():
	startingPosition = position
	defaultPosition = startingPosition
	defaultRatOffset = animated_sprite_2d.offset

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

func setClusterPosition(newClusterPosition:Vector2):
	clusterPosition = newClusterPosition

# Moves the rat for this frame relative to the swarm
func ratMove(swarmVelocity:Vector2, speed:float, delta:float, isRatClustered: bool):
	clusterOrUnclusterRat(isRatClustered)

	var desiredGlobalPosition:Vector2 = getRatDesiredGlobalPosition(swarmVelocity, speed, delta)
	var shouldAnimateTurn = moveAndSlideRat(desiredGlobalPosition, swarmVelocity, speed, delta)
	animateRat(swarmVelocity, shouldAnimateTurn)

# This function clusters or un clusters the rat
# If it's our first time clustering this this rat,
# we set the state to "returning" so that the rat
# will move to its new position before resuming normal operation
func clusterOrUnclusterRat(isRatClustered:bool):
	if(isRatClustered):
		if defaultPosition != clusterPosition:
			# First time we are clustering, so the rat needs to move to the new clustered position
			# So we just set the state to "returning"
			defaultPosition = clusterPosition
			currentRatState = RatState.RETURNING
	else:
		if defaultPosition != startingPosition:
			# First time we are returning to starting position, so the rat need to move to the new clusted position
			defaultPosition = startingPosition
			currentRatState = RatState.RETURNING

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

# Returns true if trurn should be animated, false if not
func moveAndSlideRat(desiredGlobalPosition: Vector2, swarmVelocity:Vector2, speed:float, delta:float) -> bool:
	setRateState()
	match currentRatState:
		RatState.SITTING:
			sitStill(swarmVelocity)
			return false
		RatState.RETURNING:
			return moveToPosition(defaultPosition, speed, delta)
		RatState.FOLLOWING:
			var desiredGlobalVelocity:Vector2 = desiredGlobalPosition
			# If still, move rats to starting position
			if(swarmVelocity == Vector2.ZERO && desiredGlobalVelocity == Vector2.ZERO):
				return moveToPosition(defaultPosition, speed, delta)
			else:
				velocity = desiredGlobalVelocity - swarmVelocity
				move_and_slide()
				return true
		_:
			return false

func setRateState():
	if (currentRatState == RatState.SITTING && position.distance_to(Vector2.ZERO) < DISTANCE_FROM_PACK_TO_START_RETURING):
		currentRatState = RatState.RETURNING

	if (currentRatState == RatState.RETURNING && position.distance_to(defaultPosition) < DISTANCE_FROM_PACK_TO_BE_MARKED_AS_RETURNED):
		currentRatState = RatState.FOLLOWING

	if (currentRatState == RatState.FOLLOWING && position.distance_to(Vector2.ZERO) > DISTANCE_FROM_PACK_TO_STOP_MOVING):
		currentRatState = RatState.SITTING

func sitStill(swarmVelocity:Vector2):
	# To remain still, you have to oppose the direcation of the pack
	velocity = -1 * swarmVelocity
	move_and_slide()
	return false

# Returns true if trurn should be animated, false if not
func moveToPosition(desiredPosition:Vector2, speed:float, delta:float) -> bool:
	var vectorToDesiredPosition = desiredPosition - position
	velocity = vectorToDesiredPosition.normalized() * speed
	if vectorToDesiredPosition.length() > 5:
		move_and_slide()
		return true
	else:
		# Move back to starting position when rat and frame isn't moving
		position = position.move_toward(desiredPosition, speed * delta)
		return false

# GlobalRatVelocity is the rat's velocity relative to the background (since this.velocity is relative to the pack)
var last_state = null
func animateRat(swarmVelocity:Vector2, shouldAnimateTurn:bool):
	var globalRatVelocity:Vector2 = swarmVelocity + velocity
	if globalRatVelocity.length() > 0:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.pause()

	if currentRatState == RatState.SITTING:
		animated_sprite_2d.animation = "sitting"
		animated_sprite_2d.rotation = (deg_to_rad(0))
		self.rotation = (deg_to_rad(0))

	if !shouldAnimateTurn:
		return

	if globalRatVelocity.x != 0:
		animated_sprite_2d.animation = "side"
		animated_sprite_2d.offset = sideRatOffset
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
		animated_sprite_2d.flip_v = false
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.offset = defaultRatOffset
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


func execute_move():
	pass
