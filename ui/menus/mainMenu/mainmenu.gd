extends Control

func _on_play_pressed():
	get_tree().change_scene_to_file("res://mapGen/dungeon.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://ui/menus/optionsMenu/optionsMenu.tscn")
	
func _on_exit_pressed():
	get_tree().quit()


func _on_exit_mouse_entered():
	pass

func _on_exit_mouse_exited():
	pass


func _on_play_mouse_entered():
	
	pass # Replace with function body.


func _on_play_mouse_exited():
	pass # Replace with function body.


func _on_options_mouse_entered():
	pass # Replace with function body.


func _on_options_mouse_exited():
	pass # Replace with function body.
