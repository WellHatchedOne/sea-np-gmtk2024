extends CanvasLayer

@export var player: PackOfRats = null
@onready var mm_camera = $Control/ColorRect/MarginContainer/SubViewportContainer/SubViewport/MMCamera
@onready var sub_viewport = $Control/ColorRect/MarginContainer/SubViewportContainer/SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(player != null, "Player instance not assigned for Minimap")
	sub_viewport.world_2d = get_viewport().world_2d

func _physics_process(delta):
	mm_camera.position = player.position
	mm_camera.make_current()
