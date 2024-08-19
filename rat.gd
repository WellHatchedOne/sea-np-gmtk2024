extends CharacterBody2D
class_name Rat

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
var delay:float = 0
var currentTimeOffset:float = 0
var timeOffsetQueue:Array[float] = []
var positionOffSetQueue:Array[Vector2] = []
var playsound = true
var ratwalksfx

const defaultratsfx = preload("res://assets/Music/635012__jigglesticks__small-animal-running-on-grass.wav")
@export var ratwalksfxselector: AudioStream = defaultratsfx
# Called when the node enters the scene tree for the first time.
func _ready():
	var stimer = get_node("Timerstepsfx")
	stimer.timeout.connect(_on_stimer_timeout)
	

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
	velocity = getRatVelocity(swarmVelocity, speed, delta)
	move_and_slide()
	animateRat(swarmVelocity)

func getRatVelocity(swarmVelocity:Vector2, speed:float, delta:float) -> Vector2:
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

	# Determine our global velocity based on speed
	var desiredGlobalVelocity:Vector2 = (desiredPosition).normalized() * speed

	# Need to subtract the swarm velocity since rats move relative to the swarm
	return desiredGlobalVelocity - swarmVelocity

# GlobalRatVelocity is the rat's velocity relative to the background (since this.velocity is relative to the pack)
func animateRat(swarmVelocity:Vector2):
	var globalRatVelocity:Vector2 = swarmVelocity + velocity
	if globalRatVelocity.length() > 0:
		animated_sprite_2d.play()
		
		if playsound == true:
			ratwalksfx = AudioStreamPlayer.new()
			add_child(ratwalksfx)
	
			$Timerstepsfx.start()
			ratwalksfx.stream = ratwalksfxselector
			ratwalksfx.play()
			ratwalksfx.set_autoplay(true)
			ratwalksfx.set_volume_db(5.0)
			playsound = false
			print("playsound")
		
		
	else:
		animated_sprite_2d.stop()
		if playsound == false:
			#ratwalksfx.stop()
			pass
		

	if globalRatVelocity.x != 0:
		animated_sprite_2d.animation = "side"
		animated_sprite_2d.flip_v = false
		animated_sprite_2d.flip_h = globalRatVelocity.x < 0
	elif globalRatVelocity.y != 0:
		if globalRatVelocity.y > 0:
			animated_sprite_2d.animation = "down"
		else:
			animated_sprite_2d.animation = "up"
			
			
	
func _on_stimer_timeout():
	playsound = true
	print("end timer")
	
	
func execute_move():
	pass
