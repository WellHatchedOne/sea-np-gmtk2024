extends CharacterBody2D
class_name Exterminator

@onready var move_at_target_component = $MoveAtTargetComponent
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var should_move: bool = true
@export var vel: float = 100

var dir = Vector2(1,1)

func _ready():
	animated_sprite_2d.animation = "idle"
	animated_sprite_2d.play()
	for child in get_children():
		if child is MoveAtTargetComponent:
			move_at_target_component = child
			break

func _physics_process(delta):
	
	if should_move == true:
		dir = move_at_target_component.direction
		velocity = dir*vel
		move_and_slide()
