extends CharacterBody2D

@export var speed: float = 400
@export var bulletSpeed: float = 50
@export var health: int = 1

var bullet_scene = preload("res://Davis/Entities/Bullets/bullet.tscn")

class Bullet:
	var position: = Vector2()
	var speed := 1.0
	var body := RID()

func _shoot():
	# create projectile in front
	# give projectile velocity forwards
	var new_bullet = bullet_scene.instance()
	new_bullet.
	add_child(new_bullet)


func _input(event):
	if event.is_action_pressed("change_color"):
		change_color()
		_shoot()

func _physics_process(delta) -> void:
	get_input()
	move_and_slide()

func get_input() -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	self.velocity = input_direction * speed;
	
func change_color() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())

func _damage(damageValue):
	health = health - damageValue
	if(health <= 0):
		_kill()

func _kill():
	# place death particles
	queue_free()
	# play death sound
