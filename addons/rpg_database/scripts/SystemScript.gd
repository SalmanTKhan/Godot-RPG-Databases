@tool
extends Control


var edited_field = -1
func start():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var stats_data = json_data["stats"]
	var weapons_data = json_data["weapons"]
	var armors_data = json_data["armors"]
	var elements_data = json_data["elements"]
	var slots_data = json_data["slots"]
	var skills_data

	if (json_data.has("skills")):
		skills_data = json_data["skills"]
	else:
		skills_data = {}
		skills_data["0"] = "Skills"
		skills_data["1"] = "Magic"
		json_data["skills"] = skills_data
		get_parent().get_parent().call("store_data", "System", json_data)


	$StatsLabel/StatsContainer/StatsBoxContainer/StatsList.clear()
	$WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.clear()
	$ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.clear()
	$ElementLabel/ElementContainer/EleBoxContainer/ElementList.clear()
	$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList.clear()
	$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/TypeList.clear()
	$SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.clear()

	for i in stats_data.size():
		$StatsLabel/StatsContainer/StatsBoxContainer/StatsList.add_item(String(stats_data[String(i)]))

	for i in weapons_data.size():
		$WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.add_item(String(weapons_data[String(i)]))

	for i in armors_data.size():	
		$ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.add_item(String(armors_data[String(i)]))

	for i in elements_data.size():
		$ElementLabel/ElementContainer/EleBoxContainer/ElementList.add_item(String(elements_data[String(i)]))
	
	for i in skills_data.size():	
		$SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.add_item(String(skills_data[String(i)]))

	for id in slots_data:
		var kind = $EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList
		var kindId = String(id[0])
		var type = $EquipmentLabel/EquipContainer/SetContainer/SetDivisor/TypeList
		match (kindId):
			"w":
				kind.add_item("Weapon")
				type.add_item(String(slots_data[id]))
			"a":
				kind.add_item("Armor")
				type.add_item(String(slots_data[id]))


func save_data():
	save_stats()
	save_weapons()
	save_armors()
	save_elements()
	save_slots()
	save_skills()

func save_stats():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var stats_data = {}

	var statSize = $StatsLabel/StatsContainer/StatsBoxContainer/StatsList.get_item_count()
	for i in statSize:
		var text = $StatsLabel/StatsContainer/StatsBoxContainer/StatsList.get_item_text(i)
		stats_data[String(i)] = text

	json_data["stats"] = stats_data
	get_parent().get_parent().call("store_data", "System", json_data)


func save_weapons():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var weapons_data = {}

	var weapon_size = $WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.get_item_count()
	for i in weapon_size:
		var text = $WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.get_item_text(i)
		weapons_data[String(i)] = text

	json_data["weapons"] = weapons_data
	get_parent().get_parent().call("store_data", "System", json_data)


func save_armors():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var armors_data = {}

	var armor_size = $ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.get_item_count()
	for i in armor_size:
		var text = $ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.get_item_text(i)
		armors_data[String(i)] = text

	json_data["armors"] = armors_data
	get_parent().get_parent().call("store_data", "System", json_data)


func save_elements():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var elements_data = {}

	var element_size = $ElementLabel/ElementContainer/EleBoxContainer/ElementList.get_item_count()
	for i in element_size:
		var text = $ElementLabel/ElementContainer/EleBoxContainer/ElementList.get_item_text(i)
		elements_data[String(i)] = text

	json_data["elements"] = elements_data
	get_parent().get_parent().call("store_data", "System", json_data)


func save_skills():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var skills_data = {}

	var skill_size = $SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.get_item_count()
	for i in skill_size:
		var text = $SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.get_item_text(i)
		skills_data[String(i)] = text

	json_data["skills"] = skills_data
	get_parent().get_parent().call("store_data", "System", json_data)


func save_slots():
	var json_data = get_parent().get_parent().call("read_data", "System")
	var slots_data = {}

	var slot_size = $EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList.get_item_count()
	for i in slot_size:
		var kind = $EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList.get_item_text(i)
		var id = ""
		match (kind):
			"Weapon":
				id = "w"
			"Armor":
				id = "a"
	
		var text = $EquipmentLabel/EquipContainer/SetContainer/SetDivisor/TypeList.get_item_text(i)
		id += String(i)
		slots_data[String(id)] = text

	json_data["slots"] = slots_data
	get_parent().get_parent().call("store_data", "System", json_data)

func _on_OKButton_pressed():
	var name = $EditField/FieldName.text
	if (name != ""):
		if (edited_field == 0):
			$StatsLabel/StatsContainer/StatsBoxContainer/StatsList.add_item(name)
		elif(edited_field == 1):
			$WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.add_item(name)
		elif(edited_field == 2):
			$ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.add_item(name)
		elif(edited_field == 3):
			$ElementLabel/ElementContainer/EleBoxContainer/ElementList.add_item(name)
		elif(edited_field == 4):
			$SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.add_item(name)
		save_data()
	$EditField.hide()
	edited_field = -1


func _on_CancelButton_pressed():
	edited_field = -1
	$EditField.hide()


func _on_EditField_popup_hide():
	edited_field = -1
	$EditField.hide()


func _on_AddStat_pressed():
	edited_field = 0
	$EditField.window_title = "Add Stat"
	$EditField/FieldName.text = ""
	$EditField.popup_centered(Vector2(392, 95))


func _on_RemoveStat_pressed():
	var index = $StatsLabel/StatsContainer/StatsBoxContainer/StatsList.get_selected_items()[0]
	if (index > -1):
		$StatsLabel/StatsContainer/StatsBoxContainer/StatsList.remove_item(index)
		save_data()



func _on_AddWeapon_pressed():
	edited_field = 1
	$EditField.window_title = "Add Weapon"
	$EditField/FieldName.text = ""
	$EditField.popup_centered(Vector2(392, 95))


func _on_RemoveWeapon_pressed():
	var index = $WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.get_selected_items()[0]
	if (index > -1):
		$WeaponTypesLabel/WeaponTypesContainer/WpBoxContainer/WeaponList.remove_item(index)
		save_data()


func _on_AddArmor_pressed():
	edited_field = 2
	$EditField.window_title = "Add Armor"
	$EditField/FieldName.text = ""
	$EditField.popup_centered(Vector2(392, 95))


func _on_RemoveArmor_pressed():
	var index = $ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.get_selected_items()[0]
	if (index > -1):
		$ArmorTypesLabel/ArmorTypesContainer/ArBoxContainer/ArmorList.remove_item(index)
		save_data()


func _on_AddElement_pressed():
	edited_field = 3
	$EditField.window_title = "Add Element"
	$EditField/FieldName.text = ""
	$EditField.popup_centered(Vector2(392, 95))


func _on_RemoveElement_pressed():
	var index = $ElementLabel/ElementContainer/EleBoxContainer/ElementList.get_selected_items()[0]
	if (index > -1):
		$ElementLabel/ElementContainer/EleBoxContainer/ElementList.remove_item(index)
		save_data()


func _on_AddSkillType_pressed():
	edited_field = 4
	$EditField.window_title = "Add Skill Type"
	$EditField/FieldName.text = ""
	$EditField.popup_centered(Vector2(392, 95))


func _on_RemoveSKillType_pressed():
	var index = $SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.get_selected_items()[0]
	if (index > -1):
		$SkillTypesLabel/SkillTypeContainer/VBoxContainer/SkillTypeList.remove_item(index)
		save_data()


func _on_AddSet_pressed():
	$AddSlot.popup_centered()


func _on_RemoveSet_pressed():
	var index = $EquipmentLabel/EquipContainer/SetContainer/SetDivisor/TypeList.get_selected_items()[0]
	if (index > -1):
		$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList.remove_item(index)
		$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/TypeList.remove_item(index)
		save_data()


func _on_AddSlotCancelButton_pressed():
	$AddSlot.hide()


func _on_AddSlotOkButton_pressed():
	var kind = $AddSlot/TypeLabel/TypeButton.selected
	match (kind):
		0:
			$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList.add_item("Weapon")
		1:
			$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/KindList.add_item("Armor")
	var name = $AddSlot/NameLabel/NameEdit.text
	$EquipmentLabel/EquipContainer/SetContainer/SetDivisor/TypeList.add_item(name)
	save_data()
	$AddSlot.hide()
