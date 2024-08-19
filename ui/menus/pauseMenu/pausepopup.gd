extends Window

@onready var pauseScene = $"."

func _input(event):
	if event.is_action_pressed("Pause"):
		pauseScene.hide()

func _on_resume_pressed():
	pauseScene.hide()


func _on_ratabase_pressed():
	print("ratabase")


func _on_quit_pressed():
	get_tree().quit()

