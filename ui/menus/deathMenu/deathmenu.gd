extends Control

@onready var dancingRat = $DancingRatAnimation
# Called when the node enters the scene tree for the first time.
func _ready():
	dancingRat.animation_looped
	dancingRat.play()

func _on_dancing_rat_animation_animation_finished():
	changeToEndAnimatoin()

func _on_dancing_rat_animation_animation_looped():
	changeToEndAnimatoin()

func changeToEndAnimatoin():
	dancingRat.animation = "endAnimation"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_try_again_pressed():
	get_tree().change_scene_to_file("res://ui/menus/mainMenu/mainmenu.tscn")






