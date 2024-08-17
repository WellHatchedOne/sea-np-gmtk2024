extends CharacterBody2D
class_name ratSwarm

@export var speed: float = 400

func _input(event):
	if event.is_action_pressed("change_color"):
		change_color()
		add_rat()

func _physics_process(delta) -> void:
	get_input()
	move_and_slide()

func get_input() -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	self.velocity = input_direction * speed;
	
func change_color() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())

func add_rat() -> void:
	var childRat = $basicRat.duplicate()
	childRat.position
	add_child(childRat)

