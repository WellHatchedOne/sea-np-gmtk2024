extends Control

func _on_play_pressed():
	get_tree().change_scene_to_file("res://tempMains/shawnMain.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://ui/menus/optionsMenu/optionsMenu.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
