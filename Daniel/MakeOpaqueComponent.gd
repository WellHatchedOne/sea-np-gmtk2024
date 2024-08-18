extends Node2D
class_name MakeOpaqueComponent
var turnback = 0 
var dodgestart = false
var canattack = true
var dodgebutton = false
@onready var hud = $Hud

@onready var label = $Cooldown_Display



func _ready():
	var dtimer = get_node("DodgeTimer")
	dtimer.timeout.connect(_on_dtimer_timeout)
	var ctimer = get_node("CooldownTimer")
	ctimer.timeout.connect(_on_ctimer_timeout)

func _process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("Dodgeroll") and canattack == true:
		assert(get_parent() is PackOfRats, "Only rat packs can be opaque")
		
		for rat: Rat in get_parent().rat_children:
			rat.modulate.a = 0.5
		dodgestart = true
		canattack = false 
		$DodgeTimer.start()
		$CooldownTimer.start()
		
		dodgestart = true
		canattack = false 
		
		
		

func _on_dtimer_timeout():
	print("go back")
	for rat: Rat in get_parent().rat_children:
			rat.modulate.a = 1
	$DodgeTimer.stop()
	

func _on_ctimer_timeout():
	print("cooldownover")
	
	
	$CooldownTimer.stop()
	canattack = true
	
