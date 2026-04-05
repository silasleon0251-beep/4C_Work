extends Control

@onready var start_sign: TextureRect = $StartSign
@onready var set_sign: TextureRect = $SetSign
@onready var exit_sign: TextureRect = $ExitSign

@onready var start_anim: AnimationPlayer = $StartSign/StartAnim
@onready var set_anim: AnimationPlayer = $SetSign/SetAnim
@onready var exit_anim: AnimationPlayer = $ExitSign/ExitAnim


func _ready() -> void:
	start_sign.visible = false
	set_sign.visible = false
	exit_sign.visible = false
	
func _on_start_but_mouse_entered() -> void:
	start_sign.visible = true
	start_anim.play("default")
	pass # Replace with function body.


func _on_start_but_mouse_exited() -> void:
	start_sign.visible = false
	pass # Replace with function body.


func _on_set_but_mouse_entered() -> void:
	set_sign.visible = true
	set_anim.play("default")
	pass # Replace with function body.


func _on_set_but_mouse_exited() -> void:
	set_sign.visible = false
	pass # Replace with function body.


func _on_exit_mouse_entered() -> void:
	exit_sign.visible = true
	exit_anim.play("default")
	pass # Replace with function body.


func _on_exit_mouse_exited() -> void:
	exit_sign.visible = false
	pass # Replace with function body.
