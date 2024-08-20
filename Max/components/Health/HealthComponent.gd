extends Area2D
class_name HealthComponent

const FOOD = preload("res://Grace/food.tscn")
@export var initial_health: float = 100

var parent_collision: CollisionShape2D = null
@onready var collision_shape_2d = $CollisionShape2D

const EXTERMINATOR_DEATH_2 = preload("res://Entities/Enemies/Exterminator/Exterminator_Death-2.png")

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
		if get_parent() is Pico:
			go_to_next_level()
		elif get_parent() is Exterminator:
			var death_sprite = Sprite2D.new()
			death_sprite.texture = EXTERMINATOR_DEATH_2
			death_sprite.global_position = self.global_position
			death_sprite.scale.x = 0.05
			death_sprite.scale.y = 0.05
			get_parent().get_parent().add_child(death_sprite)
		get_parent().queue_free()

func go_to_next_level():
	var dungeon := findDungeonNode()
	if(dungeon == null):
		return
	dungeon.load_next_level()

func findDungeonNode() -> Dungeon:
	return get_parent().get_parent().get_parent()
		
func increase_health(number: float):
	initial_health += number

func _on_area_entered(area):
	if area.get_parent() is Bullet:
		if !area.get_parent().isEnemyBullet:
			print("Taking damage")
			take_damage(area.get_parent().damage)
