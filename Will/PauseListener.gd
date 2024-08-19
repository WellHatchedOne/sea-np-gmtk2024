extends Node2D

var paused = false
@onready var pauseScene = $PausePopup

func _ready():
	pauseScene.hide()
	pass 

func _process(delta):
	if (paused && !pauseScene.is_visible()):
		pause_button_pressed()

func _input(event):
	if event.is_action_pressed("Pause"):
		pause_button_pressed()

func pause_button_pressed():
	
	if paused:
		pauseScene.hide()
		get_tree().paused = false
	else:
		pauseScene.show()
		get_tree().paused = true
		
	paused = !paused
