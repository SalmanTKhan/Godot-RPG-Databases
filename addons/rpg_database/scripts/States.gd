tool
extends Control


var icon_path = ""
var state_selected = 0
var add_string = -1


func start():
	var json_data = get_parent().get_parent().call("read_data", "State")
	for i in json_data.size():
		var state_data = json_data["state" + String(i)]
		if (i > $StateButton.get_item_count() - 1):
			$StateButton.add_item(String(state_data["name"]))
		else:
			$StateButton.set_item_text(i, String(state_data["name"]))
	refresh_data()


func refresh_data(id = state_selected):
	var json_data = get_parent().get_parent().call("read_data", "State")
	if json_data.has("state" + String(id)):
		$StateButton.select(id)
		var state_data = json_data["state" + String(id)]
		var eraseConditions = state_data["erase_conditions"]
		var messages = state_data["messages"]
		var custom_erase_condition = state_data["custom_erase_conditions"]
		$NameLabel/NameLine.text = String(state_data["name"])
		var icon = String(state_data["icon"])
		if state_data.has("icon"):
			if icon != "":
				icon_path = icon
				$IconLabel/Sprite.texture = load(icon_path)
		
		$RestrictionLabel/RestrictionOption.selected = int(state_data["restriction"])
		$PriorityLabel/PriorityValue.value = int(state_data["priority"])
		$EraseLabel/TurnsLabel/MinTurns.value = int(eraseConditions["turns_min"])
		$EraseLabel/TurnsLabel/MaxTurns.value = int(eraseConditions["turns_max"])
		$EraseLabel/DamageLabel/Damage.value = int(eraseConditions["erase_damage"])
		$EraseLabel/SetpsLabel/SpinBox.value = int(eraseConditions["erase_setps"])
		$MessagesLabel/PanelContainer/VBoxContainer/MessageList.clear()
		for message in messages.values():
			$MessagesLabel/PanelContainer/VBoxContainer/MessageList.add_item(message)
		$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.clear()
		for condition in custom_erase_condition.values():
			$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.add_item(condition)
		clear_effect_list()
		if (state_data.has("effects")):
			var effect_list = state_data["effects"]
			for effect in effect_list:
				add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Undefined state with id: " + String(id))


func save_states_data():
	var json_data = get_parent().get_parent().call("read_data", "State")
	var state_data = json_data["state" + String(state_selected)]
	var erase_condition = state_data["erase_conditions"]
	var messages = state_data["messages"]
	var custom_erase_condition = state_data["custom_erase_conditions"]
	var effect_list = []
	state_data["name"] = $NameLabel/NameLine.text
	state_data["icon"] = icon_path
	state_data["restriction"] = $RestrictionLabel/RestrictionOption.selected
	state_data["priority"] = $PriorityLabel/PriorityValue.value
	erase_condition["turns_min"] = $EraseLabel/TurnsLabel/MinTurns.value
	erase_condition["turns_max"] = $EraseLabel/TurnsLabel/MaxTurns.value
	erase_condition["erase_damage"] = $EraseLabel/DamageLabel/Damage.value
	erase_condition["erase_setps"] = $EraseLabel/SetpsLabel/SpinBox.value
	var items = $MessagesLabel/PanelContainer/VBoxContainer/MessageList.get_item_count()
	for i in items:
		messages[String(i)] = $MessagesLabel/PanelContainer/VBoxContainer/MessageList.get_item_text(i)
	items = $CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.get_item_count()
	for i in items:
		messages[String(i)] = $CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.get_item_text(i)
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	state_data["effects"] = effect_list
	get_parent().get_parent().call("store_data", "State", json_data)


func add_effect_list(name, dataId, value1, value2):
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.add_item(name)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.add_item(String(dataId))
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.add_item(value1)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.add_item(value2)


func clear_effect_list():
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.clear()
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.clear()
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.clear()
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.clear()


func _on_SearchState_pressed():
	$IconLabel/SearchDialog.popup_centered()


func _on_SearchStateIconDialog_file_selected(path):
	icon_path = path
	$IconLabel/Sprite.texture = load(path)


func _on_AddCustomStateCondition_pressed():
	add_string = 0
	$AddString.window_title = "Custom State Erase Formula"
	$AddString.popup_centered()


func _on_RemoveCustomStateCondition_pressed():
	var selected = $CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.get_selected_items()[0]
	if (selected > -1):
		$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.remove_item(selected)


func _on_AddStateMessage_pressed():
	add_string = 1
	$AddString.window_title = "State Message"
	$AddString.popup_centered()


func _on_RemoveStateMessage_pressed():
	var selected = $MessagesLabel/PanelContainer/VBoxContainer/MessageList.get_selected_items()[0]
	if (selected > -1):
		$MessagesLabel/PanelContainer/VBoxContainer/MessageList.remove_item(selected)


func _on_ConfirmAddString_pressed():
	var text = $AddString/LineEdit.text
	if (add_string == 0):
		$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.add_item(text)
	elif (add_string == 1):
		$MessagesLabel/PanelContainer/VBoxContainer/MessageList.add_item(text)
	add_string = -1
	$AddString.hide()


func _on_CancelAddString_pressed():
	add_string = -1
	$AddString.hide()


func _on_StateButton_item_selected(id):
	state_selected = id
	refresh_data()


func _on_AddState_pressed():
	$StateButton.add_item("NewState")
	var id = $StateButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "State")

	var state_data = {}
	var erase_condition = {}
	var messages = {}
	var custom_erase_condition = {}
	state_data["name"] = "NewState"
	state_data["icon"] = ""
	state_data["restriction"] = 4
	state_data["priority"] = 100
	erase_condition["turns_min"] = 0
	erase_condition["turns_max"] = 0
	erase_condition["erase_damage"] = 0
	erase_condition["erase_setps"] = 0
	state_data["erase_conditions"] = erase_condition
	messages["0"] = "Insert a custom message"
	state_data["messages"] = messages
	custom_erase_condition["0"] = "Insert a custom condition"
	state_data["custom_erase_conditions"] = custom_erase_condition
	json_data["state" + String(id)] = state_data
	get_parent().get_parent().call("store_data", "State", json_data)
	state_selected = id
	refresh_data()


func _on_RemoveState_pressed():
	var json_data = get_parent().get_parent().call("read_data", "State")
	if (json_data.size() > 1):
		var state_id = state_selected
		while (state_id < json_data.size() - 1):
			json_data["state" + String(state_id)] = json_data["state" + String(state_id + 1)]
			state_id += 1
		json_data.erase("state" + String(state_id))
		get_parent().get_parent().call("store_data", "State", json_data)
		$StateButton.remove_item(state_selected)
		if (state_selected == 0):
			state_selected += 1
		else:
			state_selected -= 1
		$StateButton.select(state_selected)
		refresh_data()


func _on_SaveStates_pressed():
	save_states_data()


func _on_AddStatesEffect_pressed():
	get_parent().get_parent().call("open_effect_manager", "Armor")


func _on_RemoveStatesEffect_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
