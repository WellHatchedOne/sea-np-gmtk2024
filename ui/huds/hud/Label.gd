extends Label

var score = 5
var red
var blue 
var green
func _ready():
	#$pack_of_rats.connect("ratsignal",self, "on_ratsignal")
	#print(owner.Player.ratnumber)
	score = owner.Player.ratnumber
	text = str(score)
	
	
	
func _process(delta):
	score = owner.Player.ratnumber
	text = str(score) + "/50 RATS"
	if score < 5 :
		red = Color(1.0,0.0,0.0,1.0)
		set("theme_override_colors/font_color",red)
	if score > 5 and score < 40:
		blue = Color(0, 0, 0, 1)
		set("theme_override_colors/font_color",blue)
	if score > 40:
		green = Color(0, 1, 0, 1)
		set("theme_override_colors/font_color",green)
	