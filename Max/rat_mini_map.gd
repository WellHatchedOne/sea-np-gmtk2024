extends CanvasLayer

@export var test_movable_guy: CharacterBody2D = null
@onready var mm_camera = $Control/ColorRect/MarginContainer/SubViewportContainer/SubViewport/MMCamera
@onready var sub_viewport = $Control/ColorRect/MarginContainer/SubViewportContainer/SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	sub_viewport.world_2d = get_viewport().world_2d

func _physics_process(delta):
	mm_camera.position = test_movable_guy.position
	mm_camera.make_current()
