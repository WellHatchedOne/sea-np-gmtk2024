extends Label

@onready var animation_player = $AnimationPlayer
var levelnum = 1
var score = 5
var red
var blue 
var green
var track = false
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
	
	if score > 49:
		_activate()
		track = true

		
func _activate():
	text ="!FIND THE CAT!"
	print("activate")
	animation_player.play()
