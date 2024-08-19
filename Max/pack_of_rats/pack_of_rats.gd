extends CharacterBody2D
class_name PackOfRats

@export var speed: float = 400
@export var ratWidthDist = 15
@export var ratHeightDist = 15
const RAT_DELAY_MULTIPLICATIVE_MODIFIER:float = .002
const RAT_DELAY_RANDOM_MODIFIER:float = .3
const RAT = preload("res://rat.tscn")
@onready var pack_collision_circle = $CollisionShape2D
#signal ratsignal
var current_radius = 0
var alpha_rat = Rat
var rat_children: Array[Rat] = []
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
	move_rats(delta)
	
func move_rats(delta):
	for rat in all_rats:
		rat.enable_collision()
		rat.ratMove(velocity, speed, delta)

func _ready():
	spawn_spiral_rat(false)

func spawn_spiral_rat(should_be_child=true):
	var spiralCoordinates:Vector2 = get_spiral_coordinates_from_poisition(ratnumber)
	spawn_rat(getRatPosistionFromSpiralCoordinates(spiralCoordinates), should_be_child)

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

func getRatPosistionFromSpiralCoordinates(spiralPosition:Vector2) -> Vector2:
	var x = spiralPosition.x * ratWidthDist + randf_range(-1 * ratWidthDist / 2, ratWidthDist / 2)
	var y = spiralPosition.y * ratHeightDist + randf_range(-1 * ratHeightDist / 2, ratHeightDist / 2)
	return Vector2(x, y)

func spawn_rat(new_position:Vector2, should_be_child=true):
	print("spawn rat")
	var new_rat:Rat = RAT.instantiate()
	var radius_from_parent_origin = Vector2(0,0).distance_to(new_position)
	new_rat.position = new_position
	
	ratnumber += 1
	
	if should_be_child:
		rat_children.append(new_rat)
		new_rat.set_delay(get_rat_delay(new_position))
	else:
		alpha_rat = new_rat
		new_rat.set_delay(0)
		var rat_collision_shape = new_rat.find_child("CollisionShape2D") as CollisionShape2D
		update_collision_radius(rat_collision_shape.shape.radius)
	
	all_rats.append(new_rat)
	self.add_child(new_rat)
	
	#emit_signal("ratsignal")
	#get_parent().classify_entity(new_rat)
	#emit_signal("ratsignal")

# This function determines the rat delay as function of far it is from the center of the pack
func get_rat_delay(position:Vector2) -> float:
	return abs(position.distance_to(Vector2.ZERO) * RAT_DELAY_MULTIPLICATIVE_MODIFIER
	+ randf_range(-1 * RAT_DELAY_RANDOM_MODIFIER, RAT_DELAY_RANDOM_MODIFIER))

func update_collision_radius(new_radius):
	pack_collision_circle.shape.radius = new_radius
