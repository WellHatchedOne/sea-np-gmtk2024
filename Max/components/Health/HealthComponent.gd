extends Area2D
class_name HealthComponent

const FOOD = preload("res://Grace/food.tscn")
@export var initial_health: float = 100

var collision_shape: CollisionShape2D = null
@onready var area_2d = $Area2D

func _ready():
	for child in get_parent().get_children():
		if child is CollisionShape2D:
			collision_shape = child
			break
	
	# Get the collision shape of the parent
	self.add_child(collision_shape)
	assert(collision_shape != null, "%s HealthComponent does not have collision shape" % get_parent())

# Should tell the parent to play death animation if possible
func take_damage(damage: float):
	initial_health -= damage
	if initial_health <= 0:
		var new_food_drop = FOOD.instantiate()
		new_food_drop.position = get_parent()
		get_parent().get_parent().add_child(new_food_drop)
		
		get_parent().queue_free()
		
func increase_health(number: float):
	initial_health += number
