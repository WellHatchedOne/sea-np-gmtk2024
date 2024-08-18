extends CharacterBody2D
class_name PackOfRats

@export var speed: float = 400
const RAT = preload("res://rat.tscn")
@onready var pack_collision_circle = $CollisionShape2D
signal ratsignal
var current_radius = 0
var rat_children: Array = []
var ratnumber = 0

func _input(event):
	if event.is_action_pressed("change_color"):
		spawn_rat(randf_range(-100, 100), randf_range(-100, 100))

func get_input() -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	self.velocity = input_direction * speed;
	#if Input.is_action_pressed("move_left"):
		#$Ratstepssfx.play()
	
			
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
			rat.animated_sprite_2d.flip_v = false
			rat.animated_sprite_2d.flip_h = velocity.x < 0
		elif velocity.y != 0:
			if velocity.y > 0:
				rat.animated_sprite_2d.animation = "down"
			else:
				rat.animated_sprite_2d.animation = "up"

func _ready():
	spawn_rat(0,0)

func spawn_rat(x: float, y: float):
	var new_rat = RAT.instantiate()
	var new_position = Vector2(x, y)
	var radius_from_parent_origin = Vector2(0,0).distance_to(new_position)
	new_rat.position = new_position
	
	ratnumber += 1
	self.add_child(new_rat)
	rat_children.append(new_rat)
	emit_signal("ratsignal")
	get_parent().classify_entity(new_rat)
	
	if (x==0 && y==0):
		var rat_collision_shape = new_rat.find_child("CollisionShape2D") as CollisionShape2D
		update_collision_radius(rat_collision_shape.shape.radius)
	elif radius_from_parent_origin > current_radius:
		current_radius = radius_from_parent_origin
		update_collision_radius(radius_from_parent_origin)

func update_collision_radius(new_radius):
	pack_collision_circle.shape.radius = new_radius
