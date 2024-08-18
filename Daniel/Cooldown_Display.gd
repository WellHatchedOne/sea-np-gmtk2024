extends Label
@onready var make_opaque_component = $".."
@onready var cooldown_timer = $"../CooldownTimer"
@onready var cooldown_display = $"."
var intcon
var roundup

func _ready():
	pass
	
	
func _process(delta):
	var roundup = ceil(cooldown_timer.get_time_left())
	var intcon = int(roundup)
	if make_opaque_component.dodgestart == true:
		cooldown_display.set_text(str(intcon))
