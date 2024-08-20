extends Label

@onready var animation_player = $AnimationPlayer
var levelnum = 1
var score = 5
var red
var blue 
var green
var firstplay = true
func _ready():
	#$pack_of_rats.connect("ratsignal",self, "on_ratsignal")
	#print(owner.Player.ratnumber)
	score = owner.Player.ratnumber
	text =""
	#levelnum = get_tree().root.get_child(0).get_node("Level").level.tilemapAtlasId
	#print(get_tree().root.get_child(0).get_children())
	
func _process(delta):
	score = owner.Player.ratnumber
	#print(score)
	
	if getPlayerLevel() >= 4 and firstplay == true:
		_activate()
		firstplay = false
		$Timer.start()


func _activate():
	text ="YOU WIN"
	animation_player.play()

func _on_timer_timeout():
	_deactivate()
	
func _deactivate():
	text = ""
	animation_player.stop()

func  getPlayerTarget() -> float:
	return getLevelNode().getPlayerTarget()

func getPlayerLevel() -> float:
	return getLevelNode().playerLevel

func getLevelNode() -> Level:
	return get_parent().get_parent().get_parent().get_node("Level")



