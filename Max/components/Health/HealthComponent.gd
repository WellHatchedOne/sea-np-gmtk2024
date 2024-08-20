extends Area2D
class_name HealthComponent

const FOOD = preload("res://Grace/food.tscn")
@export var initial_health: float = 100

var parent_collision: CollisionShape2D = null
@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	for child in get_parent().get_children():
		if child is CollisionShape2D:
			parent_collision = child
			break
	
	collision_shape_2d.shape = parent_collision.shape

# Should tell the parent to play death animation if possible
func take_damage(damage: float):
	print("Lost Health! %s" % initial_health)
	initial_health -= damage
	if initial_health <= 0:
		var new_food_drop = FOOD.instantiate()
		new_food_drop.position = get_parent().position
		get_parent().get_parent().add_child(new_food_drop)
		
		get_parent().queue_free()
		
func increase_health(number: float):
	initial_health += number

func _on_area_entered(area):
	if area.get_parent() is Bullet:
		if !area.get_parent().isEnemyBullet:
			print("Taking damage")
			take_damage(area.get_parent().damage)
