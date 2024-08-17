extends CharacterBody2D

@export var speed: float = 400
@export var health: int = 1

func _input(event):
	if event.is_action_pressed("change_color"):
		change_color()
		_damage(1)

func _physics_pocess(delta) -> void:
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
