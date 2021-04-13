tool
extends EditorPlugin

var main_panel: PackedScene = load("res://addons/rpg_database/scenes/Base.tscn")
var instanced_scene: Control
var button: Button = Button.new()



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _enter_tree():
	instanced_scene = main_panel.instance()
	button.text = "Database"
	button.connect("pressed", self, "_on_button_pressed")
	add_control_to_container(0, button)
	add_child(instanced_scene)

func _exit_tree():
	remove_child(instanced_scene)
	remove_control_from_container(0, button)
	if (instanced_scene != null):
		instanced_scene.queue_free()

func _on_button_pressed():
	if (!instanced_scene.visible):
		var position = Vector2(150, 150)
		instanced_scene.set_position(position)
		instanced_scene.show()
	else:
		instanced_scene.hide()
