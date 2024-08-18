extends Control



func _on_play_pressed():
	get_tree().change_scene_to_file("res://mapGen/dungeon.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://ui/menus/optionsMenu/optionsMenu.tscn")
	
func _on_exit_pressed():
	get_tree().quit()


func _on_exit_mouse_entered():
	$HoverIconExit.visible = true

func _on_exit_mouse_exited():
	$HoverIconExit.visible = false


func _on_play_mouse_entered():
	$HoverIconPlay.visible = true	


func _on_play_mouse_exited():
	$HoverIconPlay.visible = false


func _on_options_mouse_entered():
	$HoverIconOptions.visible = true

func _on_options_mouse_exited():
	$HoverIconOptions.visible = false
