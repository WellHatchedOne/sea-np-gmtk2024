extends Label

@onready var animation_player = $AnimationPlayer
var levelnum = 1
var score = 5
var red
var blue 
var green
func _ready():
	#$pack_of_rats.connect("ratsignal",self, "on_ratsignal")
	#print(owner.Player.ratnumber)
	score = owner.Player.getRatPackCount()
	text =""
	#levelnum = get_tree().root.get_child(0).get_node("Level").level.tilemapAtlasId
	#print(get_tree().root.get_child(0).get_children())
	
func _process(delta):
	score = owner.Player.getRatPackCount()
	#print(score)
	
	if score >= getPlayerTarget():
		_activate()
	else:
		_deactivate()

		
func _activate():
	text ="!FIND THE CAT!"
	animation_player.play()
	
func _deactivate():
	text = ""
	animation_player.stop()

func  getPlayerTarget() -> float:
	return getLevelNode().getPlayerTarget()

func getPlayerLevel() -> float:
	return getLevelNode().playerLevel

func getLevelNode() -> Level:
	return get_parent().get_parent().get_parent().get_node("Level")
