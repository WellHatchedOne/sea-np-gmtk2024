extends Node2D



func _ready():
	pass
	
	
	
	
func _startcutscene():
	$AnimationPlayercat.play()
	print("Play")
	$Timer.start()
	$catmeow.play()


func _on_timer_timeout():
	print("playsound")
	$Catroar.play()
	$Timer.stop()
