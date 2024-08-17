extends CharacterBody2D
class_name Test_Movable_Guy

@export var speed: float = 400
@export var img1: Texture2D = null

func _input(event):
	if event.is_action_pressed("change_color"):
		change_color()

func _physics_process(delta) -> void:
	get_input()
	move_and_slide()

func get_input() -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	self.velocity = input_direction * speed;
	
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	if velocity.x != 0:
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		if velocity.y > 0:
			$AnimatedSprite2D.animation = "down"
		else:
			$AnimatedSprite2D.animation = "up"


func change_color() -> void:
	$ColorRect.color = Color(randf(), randf(), randf())
