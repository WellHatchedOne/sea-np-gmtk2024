extends Control

@onready var pauseMenu = $Pausemenu
@onready var window = $Window	
	
func _on_resume_pressed():
	print("resume")


func _on_ratabase_pressed():
	print("ratabase")


func _on_quit_pressed():
	print("quit")
	get_tree().quit()
	
	
func _on_quit_mouse_entered():
	$HoverIconQuit.visible = true

func _on_quit_mouse_exited():
	$HoverIconQuit.visible = false


func _on_resume_mouse_entered():
	$HoverIconResume.visible = true	


func _on_resume_mouse_exited():
	$HoverIconResume.visible = false


func _on_ratabase_mouse_entered():
	$HoverIconOptions.visible = true

func _on_ratabase_mouse_exited():
	$HoverIconOptions.visible = false

