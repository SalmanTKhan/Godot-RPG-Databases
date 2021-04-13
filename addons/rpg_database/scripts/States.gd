tool
extends Control


var icon_path = ""
var state_selected = 0
var add_string = -1


func start():
	var jsonDictionary = get_parent().get_parent().call("read_data", "State")
	for i in jsonDictionary.size():
		var stateData = jsonDictionary["state" + String(i)]
		if (i > $StateButton.get_item_count() - 1):
			$StateButton.add_item(String(stateData["name"]))
		else:
			$StateButton.set_item_text(i, String(stateData["name"]))
	refresh_data()


func refresh_data(id = state_selected):
	var jsonDictionary = get_parent().get_parent().call("read_data", "State")
	if jsonDictionary.has("state" + String(id)):
		$StateButton.select(id)
		var stateData = jsonDictionary["state" + String(id)]
		var eraseConditions = stateData["erase_conditions"]
		var messages = stateData["messages"]
		var customEraseConditions = stateData["custom_erase_conditions"]
		$NameLabel/NameLine.text = String(stateData["name"])
		var icon = String(stateData["icon"])
		if stateData.has("icon"):
			if icon != "":
				icon_path = icon
				$IconLabel/Sprite.texture = load(icon_path)
		
		$RestrictionLabel/RestrictionOption.selected = int(stateData["restriction"])
		$PriorityLabel/PriorityValue.value = int(stateData["priority"])
		$EraseLabel/TurnsLabel/MinTurns.value = int(eraseConditions["turns_min"])
		$EraseLabel/TurnsLabel/MaxTurns.value = int(eraseConditions["turns_max"])
		$EraseLabel/DamageLabel/Damage.value = int(eraseConditions["erase_damage"])
		$EraseLabel/SetpsLabel/SpinBox.value = int(eraseConditions["erase_setps"])
		$MessagesLabel/PanelContainer/VBoxContainer/MessageList.clear()
		for message in messages.values():
			$MessagesLabel/PanelContainer/VBoxContainer/MessageList.add_item(message)
		$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.clear()
		for condition in customEraseConditions.values():
			$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.add_item(condition)
	else:
		print("Undefined state with id: " + String(id))


func _on_SearchState_pressed():
	$IconLabel/SearchDialog.popup_centered();


func _on_SearchStateIconDialog_file_selected(path):
	icon_path = path;
	$IconLabel/Sprite.texture = load(path)


func _on_AddCustomStateCondition_pressed():
	add_string = 0;
	$AddString.window_title = "Custom State Erase Formula";
	$AddString.popup_centered();


func _on_RemoveCustomStateCondition_pressed():
	var selected = $CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.get_selected_items()[0];
	if (selected > -1):
		$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.remove_item(selected)


func _on_AddStateMessage_pressed():
	add_string = 1;
	$AddString.window_title = "State Message";
	$AddString.popup_centered();


func _on_RemoveStateMessage_pressed():
	var selected = $MessagesLabel/PanelContainer/VBoxContainer/MessageList.get_selected_items()[0];
	if (selected > -1):
		$MessagesLabel/PanelContainer/VBoxContainer/MessageList.remove_item(selected)


func _on_ConfirmAddString_pressed():
	var text = $AddString/LineEdit.text
	if (add_string == 0):
		$CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.add_item(text)
	elif (add_string == 1):
		$MessagesLabel/PanelContainer/VBoxContainer/MessageList.add_item(text)
	add_string = -1;
	$AddString.hide()


func _on_CancelAddString_pressed():
	add_string = -1;
	$AddString.hide()


func _on_StateButton_item_selected(id):
	state_selected = id
	refresh_data()


func _on_AddState_pressed():
	$StateButton.add_item("NewState")
	var id = $StateButton.get_item_count() - 1
	var jsonDictionary = get_parent().get_parent().call("read_data", "State")

	var stateData = {}
	var eraseCondition = {}
	var messages = {}
	var customEraseConditions = {}
	stateData["name"] = "NewState"
	stateData["icon"] = ""
	stateData["restriction"] = 4
	stateData["priority"] = 100
	eraseCondition["turns_min"] = 0
	eraseCondition["turns_max"] = 0
	eraseCondition["erase_damage"] = 0
	eraseCondition["erase_setps"] = 0
	stateData["erase_conditions"] = eraseCondition
	messages["0"] = "Insert a custom message"
	stateData["messages"] = messages
	customEraseConditions["0"] = "Insert a custom condition"
	stateData["custom_erase_conditions"] = customEraseConditions
	jsonDictionary["state" + String(id)] = stateData
	get_parent().get_parent().call("store_data", "State", jsonDictionary);
	state_selected = id
	refresh_data()


func _on_RemoveState_pressed():
	var jsonDictionary = get_parent().get_parent().call("read_data", "State")
	if (jsonDictionary.size() > 1):
		var state_id = state_selected
		while (state_id < jsonDictionary.size() - 1):
			jsonDictionary["state" + String(state_id)] = jsonDictionary["state" + String(state_id + 1)];
			state_id += 1;
		jsonDictionary.erase("state" + String(state_id))
		get_parent().get_parent().call("store_data", "State", jsonDictionary)
		$StateButton.remove_item(state_selected)
		if (state_selected == 0):
			state_selected += 1
		else:
			state_selected -= 1
		$StateButton.select(state_selected)
		refresh_data()


func _on_SaveStates_pressed():
	var jsonDictionary = get_parent().get_parent().call("read_data", "State")
	var stateData = jsonDictionary["state" + String(state_selected)]
	var eraseCondition = stateData["erase_conditions"]
	var messages = stateData["messages"]
	var customEraseConditions = stateData["custom_erase_conditions"]
	stateData["name"] = $NameLabel/NameLine.text
	stateData["icon"] = icon_path
	stateData["restriction"] = $RestrictionLabel/RestrictionOption.selected
	stateData["priority"] = $PriorityLabel/PriorityValue.value
	eraseCondition["turns_min"] = $EraseLabel/TurnsLabel/MinTurns.value
	eraseCondition["turns_max"] = $EraseLabel/TurnsLabel/MaxTurns.value
	eraseCondition["erase_damage"] = $EraseLabel/DamageLabel/Damage.value
	eraseCondition["erase_setps"] = $EraseLabel/SetpsLabel/SpinBox.value
	var items = $MessagesLabel/PanelContainer/VBoxContainer/MessageList.get_item_count()
	for i in items:
		messages[String(i)] = $MessagesLabel/PanelContainer/VBoxContainer/MessageList.get_item_text(i)
	items = $CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.get_item_count()
	for i in items:
		messages[String(i)] = $CustomEraseLabel/PanelContainer/VBoxContainer/EraseConditions.get_item_text(i)
	get_parent().get_parent().call("store_data", "State", jsonDictionary);
