extends CharacterBody2D
class_name PackOfRats

const MAX_RATS = 50
@export var speed: float = 400
const RAT_EXPANDED_DISTANCE:float = 15
const RAT_CLUSTERED_DISTANCE:float = RAT_EXPANDED_DISTANCE / 3
@export var ratHeightDist = 15
const RAT_DELAY_MULTIPLICATIVE_MODIFIER:float = .002
const RAT_DELAY_RANDOM_MODIFIER:float = .3
const RAT = preload("res://rat.tscn")
const MAX_TIME_FOR_RAT_SWARM_MS:int = 1.5 * 1000
const TIME_OUT_FOR_RAT_SWARM_MS:float = 3 * 1000
@onready var pack_collision_circle = $CollisionShape2D

var isRatClustred = false
var lastClusterEndTime = -1
var currentClusterStartTime = -1
#signal ratsignal
var current_radius = 0
var alpha_rat = Rat
var all_rats: Array[Rat] = []
var ratnumber = 0

func _input(event):
	if event.is_action_pressed("change_color"):
		spawn_spiral_rat()

func get_input() -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	self.velocity = input_direction * speed;

func _physics_process(delta) -> void:
	get_input()
	move_and_slide()
	move_rats(delta, areRatsClustered())
	killARandomRat()
	
func move_rats(delta, areRatsClustered:bool):
	for rat in all_rats:
		rat.enable_collision()
		rat.ratMove(velocity, speed, delta, areRatsClustered)

func areRatsClustered() -> bool:
	if Input.is_action_just_pressed("cluster_rats"):
		if lastClusterEndTime < 0 || Time.get_ticks_msec() - lastClusterEndTime > TIME_OUT_FOR_RAT_SWARM_MS:
			currentClusterStartTime = Time.get_ticks_msec()
			isRatClustred = true
		else:
			isRatClustred = false
	if Input.is_action_just_released("cluster_rats"):
		if isRatClustred:
			isRatClustred = false
			lastClusterEndTime = Time.get_ticks_msec()

	if isRatClustred:
		if Time.get_ticks_msec() - currentClusterStartTime > MAX_TIME_FOR_RAT_SWARM_MS:
			print("end cluster3")
			isRatClustred = false
			lastClusterEndTime = Time.get_ticks_msec()

	return isRatClustred

func getRatClusterCooldownPercentage() -> float:
	# Show cooldown for when we can start again
	if isRatClustred:
		if currentClusterStartTime < 0:
			return 100
		else:
			var timeClustered = Time.get_ticks_msec() - currentClusterStartTime
			if timeClustered > MAX_TIME_FOR_RAT_SWARM_MS:
				return 0
			else:
				var timeLeft:float = MAX_TIME_FOR_RAT_SWARM_MS - timeClustered
				return timeLeft / MAX_TIME_FOR_RAT_SWARM_MS * 100
	else:
		if lastClusterEndTime < 0:
			return 100
		else:
			var timeSinceLastCluster = Time.get_ticks_msec() - lastClusterEndTime
			if timeSinceLastCluster > TIME_OUT_FOR_RAT_SWARM_MS:
				return 100
			else:
				return timeSinceLastCluster / TIME_OUT_FOR_RAT_SWARM_MS * 100

func killARandomRat():
	if(Input.is_action_just_pressed("kill_rat")):
		var ratToKill:Rat = all_rats.pick_random()
		ratToKill._on_hit_by_bullet()

func _ready():
	spawn_spiral_rat(false)

func spawn_spiral_rat(should_be_child=true):
	var spiralCoordinates:Vector2 = get_spiral_coordinates_from_poisition(ratnumber % MAX_RATS)
	var ratPosition = getRatPosistionFromSpiralCoordinates(spiralCoordinates, RAT_EXPANDED_DISTANCE, RAT_EXPANDED_DISTANCE)
	var clusterPosition = getRatPosistionFromSpiralCoordinates(spiralCoordinates, RAT_CLUSTERED_DISTANCE, RAT_CLUSTERED_DISTANCE)
	spawn_rat(ratPosition, clusterPosition, should_be_child)

func get_spiral_coordinates_from_poisition(position) -> Vector2:
	# di and dj are vectors for the current segment
	var di:int = 1
	var dj:int = 0
	# length of curent segment
	var segmentLength:int = 1;

	# current position
	var i:int = 0
	var j:int = 0
	var segmentPosition:int = 0

	for k in position:
		i += di
		j += dj
		segmentPosition+=1

		if(segmentPosition == segmentLength):
			segmentPosition = 0
			var buffer = di
			di = -dj
			dj = buffer

			if(dj == 0):
				segmentLength+=1

	return Vector2(i, j)

func getRatPosistionFromSpiralCoordinates(spiralPosition:Vector2, ratWidthDist:float, ratHeightDist) -> Vector2:
	var x = spiralPosition.x * ratWidthDist + randf_range(-1 * ratWidthDist / 2, ratWidthDist / 2)
	var y = spiralPosition.y * ratHeightDist + randf_range(-1 * ratHeightDist / 2, ratHeightDist / 2)
	return Vector2(x, y)

func spawn_rat(new_position:Vector2, clusterPositon:Vector2, should_be_child=true):
	print("spawn rat")
	var new_rat:Rat = RAT.instantiate()
	var radius_from_parent_origin = Vector2(0,0).distance_to(new_position)
	new_rat.position = new_position
	new_rat.setClusterPosition(clusterPositon)
	
	ratnumber += 1
	
	if should_be_child:
		new_rat.set_delay(get_rat_delay(new_position))
	else:
		alpha_rat = new_rat
		new_rat.set_delay(0)
		var rat_collision_shape = new_rat.find_child("CollisionShape2D") as CollisionShape2D
		update_collision_radius(rat_collision_shape.shape.radius)
	
	all_rats.append(new_rat)
	self.add_child(new_rat)

# This function determines the rat delay as function of far it is from the center of the pack
func get_rat_delay(position:Vector2) -> float:
	return abs(position.distance_to(Vector2.ZERO) * RAT_DELAY_MULTIPLICATIVE_MODIFIER
	+ randf_range(-1 * RAT_DELAY_RANDOM_MODIFIER, RAT_DELAY_RANDOM_MODIFIER))

func update_collision_radius(new_radius):
	pack_collision_circle.shape.radius = new_radius

'''Returns the first basic rat we can find, if not, then returns null'''
func return_basic_rat():
	for rat in all_rats:
		if rat.ratType == "basic":
			return rat
	return null

func killRat(rat: Rat):
	var index = all_rats.find(rat)
	if index < 0:
		print("Unable to find rat to kill")
	ratnumber -= 1
	all_rats.remove_at(index)
	rat.queue_free()

	if (all_rats.size() == 0):
		showEndGameScreen()
		return

	if rat == alpha_rat:
		setNewAlphaRat()

	if (alpha_rat.getRatState() == Rat.RatState.SITTING):
		showEndGameScreen()

func showEndGameScreen():
	get_tree().change_scene_to_file("res://ui/menus/deathMenu/deathmenu.tscn")

func setNewAlphaRat():
	alpha_rat = getClosestRatToCenter()
	alpha_rat.set_delay(0)
	alpha_rat.set_new_pack_position(Vector2.ZERO, Vector2.ZERO)

func getClosestRatToCenter():
	var bestDistanceToCetner = getRatsDistanceFromCenter(all_rats[0])
	var closestRat = all_rats[0]
	for rat in all_rats:
		if getRatsDistanceFromCenter(rat) < bestDistanceToCetner:
			closestRat = rat
	return closestRat

func getRatsDistanceFromCenter(rat:Rat) -> float:
	return rat.getStartingPosition().length()
