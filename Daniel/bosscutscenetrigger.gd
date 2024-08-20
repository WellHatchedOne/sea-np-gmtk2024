extends Area2D

class_name Bosscutscenetrigger
@onready var triggerradius = $triggerradius

@onready var cat_cutscene = $CatCutscene

@export var trigger_radius: float = 200

func _ready():
	triggerradius.shape.radius = trigger_radius
	
	print("ready")

func _on_body_entered(body):
	cat_cutscene._startcutscene()
	print("entered body")
