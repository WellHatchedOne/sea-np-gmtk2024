extends CharacterBody2D
class_name PackOfRats

@export var speed: float = 400
@export var ratWidthDist = 50
@export var ratHeightDist = 50
const RAT = preload("res://rat.tscn")
@onready var pack_collision_circle = $CollisionShape2D
signal ratsignal
var current_radius = 0
var rat_children: Array = []
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
	play_movement_animations()
	
func play_movement_animations():
	for rat in rat_children:
		if velocity.length() > 0:
			rat.animated_sprite_2d.play()
		else:
			rat.animated_sprite_2d.stop()

		if velocity.x != 0:
			rat.animated_sprite_2d.animation = "side"
			rat.animated_sprite_2d.flip_v = false
			rat.animated_sprite_2d.flip_h = velocity.x < 0
		elif velocity.y != 0:
			if velocity.y > 0:
				rat.animated_sprite_2d.animation = "down"
			else:
				rat.animated_sprite_2d.animation = "up"

func _ready():
	spawn_spiral_rat()

func spawn_spiral_rat():
	var spiralCoordinates:Vector2 = get_spiral_coordinates_from_poisition(ratnumber)
	spawn_rat(getRatPosistionFromSpiralCoordinates(spiralCoordinates))

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

func spawn_rat(new_position:Vector2):
	var new_rat = RAT.instantiate()
	var radius_from_parent_origin = Vector2(0,0).distance_to(new_position)
	new_rat.position = new_position
	
	ratnumber += 1
	self.add_child(new_rat)
	rat_children.append(new_rat)
	emit_signal("ratsignal")
	get_parent().classify_entity(new_rat)
	emit_signal("ratsignal")
	
	if (new_position == Vector2.ZERO):
		var rat_collision_shape = new_rat.find_child("CollisionShape2D") as CollisionShape2D
		update_collision_radius(rat_collision_shape.shape.radius)
	elif radius_from_parent_origin > current_radius:
		current_radius = radius_from_parent_origin
		update_collision_radius(radius_from_parent_origin)

func update_collision_radius(new_radius):
	pack_collision_circle.shape.radius = new_radius
