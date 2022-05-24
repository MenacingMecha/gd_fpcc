extends RayCast

signal interacted
signal interactable_hovered_changed(new_hovered)

const InteractBox := preload("res://interact_box.gd")

export var _interact_input_action := "interact"

var _previously_hovered_interactable: InteractBox


func _ready():
	assert(InputMap.has_action(self._interact_input_action))


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(self._interact_input_action):
		emit_signal("interacted")
		get_tree().set_input_as_handled()


func _physics_process(_delta: float):
	var hovered_interactable := get_collider() as InteractBox

	if hovered_interactable != self._previously_hovered_interactable:
		var was_previously_hovering_interactable := self._previously_hovered_interactable != null
		if was_previously_hovering_interactable:
			disconnect("interacted", self._previously_hovered_interactable, "on_interacted_with")

		var is_hovering_interactable := hovered_interactable != null
		if is_hovering_interactable:
			connect("interacted", hovered_interactable, "on_interacted_with")

		emit_signal("interactable_hovered_changed", is_hovering_interactable)
		# print("[DEBUG] is_hovering_interactable=%s" % is_hovering_interactable)

	# Update at end of tick
	self._previously_hovered_interactable = hovered_interactable
