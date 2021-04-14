tool
extends Control

var effect_manager_tab = ""
var effect_data_type = ""

func _ready():
	create_system_database()
	create_character_database()
	create_skill_database()
	create_class_database()
	create_item_database()
	create_weapon_database()
	create_armor_database()
	create_enemy_database()
	create_state_database()
	create_effect_database()
	$Tabs/Character.call("start")
	
func read_data(file):
	return load_data(file)

func load_data(file_name):
	# Will contain the JSON parsing result if valid (typically a dictionary or array)
	var result
	var file_path = "res://databases/"+file_name+".json"
	var file = File.new()
	var file_error = file.open(file_path, File.READ)

	if file_error == OK:
		# The file was read successfully
		var json_result := JSON.parse(file.get_as_text())
		if json_result.error == OK:
			# File contains valid JSON
			result = json_result.result
			file.close()
			return result
		else:
			# File contains invalid JSON
			push_error("Error while parsing JSON at "+ file_path +":{line}: {message}".format({line = json_result.error_line, message = json_result.error_string}))
	else:
		# An error occurred related to the file reading (e.g. the file wasn't found)
		push_error("Could not open file: " + file_path)
	file.close()
	return {}

func store_data(file, data):
	var databaseFile = File.new()
	var err = databaseFile.open("res://databases/" + file + ".json", File.WRITE)
	if err != OK:
		print("Unable to store data" + String(err))
		return
	databaseFile.store_string(JSON.print(data))
	databaseFile.close()


func _on_Tabs_tab_changed(tab):
	match(tab):
		0:
			$Tabs/Character.call("start")
		1:
			$Tabs/Class.call("start")
		2:
			$Tabs/Skill.call("start")
		3:
			$Tabs/Item.call("start")
		4:
			$Tabs/Weapon.call("start")
		5:
			$Tabs/Armor.call("start")
		6:
			$Tabs/Enemy.call("start")
		7:
			$Tabs/States.call("start")
		8:
			$Tabs/Effects.call("start")
		9:
			$Tabs/System.call("start")


func open_effect_manager(tab):
	var effect_list = read_data("Effect")
	var effect_data
	$EffectManager/HBoxContainer/EffectList.clear()
	for i in effect_list.size():
		effect_data = effect_list["effect" + String(i)]
		$EffectManager/HBoxContainer/EffectList.add_item(String(effect_data["name"]))
	$EffectManager/HBoxContainer/EffectList.select(0)
	_on_EffectList_item_selected(0)
	effect_manager_tab = tab;
	$EffectManager.popup_centered()


func _on_EffectList_item_selected(index):
	var effect_list = read_data("Effect")
	var json_data
	var data
	var effect_data = effect_list["effect" + String(index)]
	var data_types = effect_data["data_type"]
	var value2 = effect_data["value2"]

	$EffectManager/HBoxContainer/VBoxContainer/DataList.clear()
	if (data_types["show"]):
		$EffectManager/HBoxContainer/VBoxContainer/DataType.hide()
		$EffectManager/HBoxContainer/VBoxContainer/DataList.hide()
		effect_data_type = "Disabled";
	else:
		$EffectManager/HBoxContainer/VBoxContainer/DataType.show()
		$EffectManager/HBoxContainer/VBoxContainer/DataList.show()
		var type = String(data_types["data"])
		effect_data_type = String(data_types["data"])
		match (type):
			"States":
				json_data = read_data("States");
				for i in json_data.size():
					data = json_data["state" + String(i)]
					$EffectManager/HBoxContainer/VBoxContainer/DataList.add_item(String(data["name"]))
			"Stats":
				json_data = read_data("System");
				data = json_data["stats"]
				for i in json_data.size():
					$EffectManager/HBoxContainer/VBoxContainer/DataList.add_item(String(data[String(i)]))
			"Weapon Types":
				json_data = read_data("System");
				data = json_data["weapons"]
				for i in json_data.size():
					$EffectManager/HBoxContainer/VBoxContainer/DataList.add_item(String(data[String(i)]))
			"Armor Types":
				json_data = read_data("System");
				data = json_data["armors"]
				for i in json_data.size():
					$EffectManager/HBoxContainer/VBoxContainer/DataList.add_item(String(data[String(i)]))
			"Elements":
				json_data = read_data("System");
				data = json_data["elements"]
				for i in json_data.size():
					$EffectManager/HBoxContainer/VBoxContainer/DataList.add_item(String(data[String(i)]))
			"Skill Types":
				json_data = read_data("System");
				data = json_data["skills"]
				for i in json_data.size():
					$EffectManager/HBoxContainer/VBoxContainer/DataList.add_item(String(data[String(i)]))
	match (int(effect_data["value1"])):
		0:
			$EffectManager/HBoxContainer/VBoxContainer/Value1/LineEdit.show();
			$EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.hide();
		1:
			$EffectManager/HBoxContainer/VBoxContainer/Value1/LineEdit.hide();
			$EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.show();
			$EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.rounded = true;
		2:
			$EffectManager/HBoxContainer/VBoxContainer/Value1/LineEdit.hide();
			$EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.show();
			$EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.rounded = false;

	if (value2.has("show") and value2["show"] == false):
		$EffectManager/HBoxContainer/VBoxContainer/Value2.hide();
	else:
		$EffectManager/HBoxContainer/VBoxContainer/Value2.show();
		match (int(value2["data"])):
			0:
				$EffectManager/HBoxContainer/VBoxContainer/Value2/LineEdit.show();
				$EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.hide();
			1:
				$EffectManager/HBoxContainer/VBoxContainer/Value2/LineEdit.hide();
				$EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.show();
				$EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.rounded = true;
			2:
				$EffectManager/HBoxContainer/VBoxContainer/Value2/LineEdit.hide();
				$EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.show();
				$EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.rounded = false;


func _on_AddEffectConfirm_pressed():
	var id = $EffectManager/HBoxContainer/EffectList.get_selected_items()[0]
	var name = $EffectManager/HBoxContainer/EffectList.get_item_text(id)
	var dataType = -1
	if (effect_data_type != "Disabled"):
		dataType = $EffectManager/HBoxContainer/VBoxContainer/DataList.selected

	var value1 = ""
	if $EffectManager/HBoxContainer/VBoxContainer/Value1/LineEdit.visible:
		value1 = $EffectManager/HBoxContainer/VBoxContainer/Value1/LineEdit.text
	elif $EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.rounded:
		value1 = String($EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.value)
	else:
		value1 = String($EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.value)


	var value2 = ""
	if $EffectManager/HBoxContainer/VBoxContainer/Value2.visible:
		if $EffectManager/HBoxContainer/VBoxContainer/Value2/LineEdit.visible:
			value2 = $EffectManager/HBoxContainer/VBoxContainer/Value2/LineEdit.text
		elif $EffectManager/HBoxContainer/VBoxContainer/Value1/SpinBox.rounded:
			value2 = String($EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.value)
		else:
			value2 = String($EffectManager/HBoxContainer/VBoxContainer/Value2/SpinBox.value)
	


	match (effect_manager_tab):
		"Character":
			$Tabs/Character.call("add_effect_list", name, dataType, value1, value2)
		"Class":
			$Tabs/Class.call("add_effect_list", name, dataType, value1, value2)
		"Skill":
			$Tabs/Skill.call("add_effect_list", name, dataType, value1, value2)
	effect_manager_tab = ""
	effect_data_type = ""
	$EffectManager.hide()


func create_system_database():
	var databaseFile = File.new()
	if not databaseFile.file_exists("res://databases/System.json"):
		var result = databaseFile.open("res://databases/System.json", File.WRITE)
		var systemList = {}
		var statsData = {}
		var weaponTypeData = {}
		var armorTypeData = {}
		var elementData = {}
		var slotsData = {}
		var skillTypeData = {}
		statsData["0"] = "hp"
		statsData["1"] = "mp"
		statsData["2"] = "atk"
		statsData["3"] = "def"
		statsData["4"] = "int"
		statsData["5"] = "res"
		statsData["6"] = "spd"
		statsData["7"] = "luk"
		weaponTypeData["0"] = "Sword"
		weaponTypeData["1"] = "Spear"
		weaponTypeData["2"] = "Axe"
		weaponTypeData["3"] = "Staff"
		armorTypeData["0"] = "Armor"
		armorTypeData["1"] = "Robe"
		armorTypeData["2"] = "Shield"
		armorTypeData["3"] = "Hat"
		armorTypeData["4"] = "Accessory"
		elementData["0"] = "Physical"
		elementData["1"] = "Fire"
		elementData["2"] = "Ice"
		elementData["3"] = "Wind"
		slotsData["w0"] = "Weapon"
		slotsData["a1"] = "Head"
		slotsData["a2"] = "Body"
		slotsData["a3"] = "Accessory"
		skillTypeData["0"] = "Skills"
		skillTypeData["1"] = "Magic"
		systemList["stats"] = statsData
		systemList["weapons"] = weaponTypeData
		systemList["armors"] = armorTypeData
		systemList["elements"] = elementData
		systemList["slots"] = slotsData
		systemList["skills"] = skillTypeData
		databaseFile.store_line(JSON.print(systemList))
		databaseFile.close()

func create_character_database():
	var databaseFile = File.new()
	if not databaseFile.file_exists("res://databases/Character.json"):
		databaseFile.open("res://databases/Character.json", File.WRITE)
		var characterList = {}
		var characterData = {}
		var equipTypeData = {}
		var initialEquipData = {}
		characterData["faceImage"] = ""
		characterData["charaImage"] = ""
		characterData["name"] = "Kate"
		characterData["class"] = 0
		characterData["description"] = ""
		characterData["initialLevel"] = 1
		characterData["maxLevel"] = 99
		equipTypeData["w0"] = 0
		equipTypeData["w1"] = 1
		equipTypeData["a2"] = 0
		equipTypeData["a3"] = 3
		initialEquipData["0"] = -1
		initialEquipData["1"] = -1
		initialEquipData["2"] = -1
		initialEquipData["3"] = -1
		characterData["initial_equip"] = initialEquipData
		characterData["equip_types"] = equipTypeData
		characterList["chara0"] = characterData
		databaseFile.store_line(JSON.print(characterList))
		databaseFile.close()

func create_skill_database():
	var databaseFile = File.new()
	if not databaseFile.file_exists("res://databases/Skill.json"):
		databaseFile.open("res://databases/Skill.json", File.WRITE);
		var skillList = {}
		var skillData = {}
		skillData["name"] = "Double Attack"
		skillData["icon"] = ""
		skillData["description"] = "Attacks an enemy twice"
		skillData["skill_type"] = 0
		skillData["mp_cost"] = 4
		skillData["tp_cost"] = 2
		skillData["target"] = 1
		skillData["usable"] = 1
		skillData["success"] = 95
		skillData["hit_type"] = 1
		skillData["damage_type"] = 1
		skillData["element"] = 0
		skillData["formula"] = "atk * 4 - def * 2"
		skillList["skill0"] = skillData
		databaseFile.store_line(JSON.print(skillList))
		databaseFile.close()

func create_class_database():
	var databaseFile = File.new()
	if not databaseFile.file_exists("res://databases/Class.json"):
		databaseFile.open("res://databases/Class.json", File.WRITE)
		var classList = {}
		var classData = {}
		var classStats = {}
		var skillList = {}
		classData["name"] = "Warrior"
		classData["icon"] = ""
		classData["experience"] = "level * 30"
		classStats["hp"] = "level * 25 + 10"
		classStats["mp"] = "level * 15 + 5"
		classStats["atk"] = "level * 5 + 3"
		classStats["def"] = "level * 5 + 3"
		classStats["int"] = "level * 5 + 3"
		classStats["res"] = "level * 5 + 3"
		classStats["spd"] = "level * 5 + 3"
		classStats["luk"] = "level * 5 + 3"
		skillList[0] = 5
		classData["skill_list"] = skillList
		classData["stat_list"] = classStats
		classList["class0"] = classData
		databaseFile.store_line(JSON.print(classList))
		databaseFile.close()

func create_item_database():
	var databaseFile = File.new()
	if (!databaseFile.file_exists("res://databases/Item.json")):
		databaseFile.open("res://databases/Item.json", File.WRITE)
		var itemList = {}
		var itemData = {}
		itemData["name"] = "Potion"
		itemData["icon"] = ""
		itemData["description"] = "Heals 50HP to one ally"
		itemData["item_type"] = 0
		itemData["price"] = 50
		itemData["consumable"] = 0
		itemData["target"] = 7
		itemData["usable"] = 0
		itemData["success"] = 100
		itemData["hit_type"] = 0
		itemData["damage_type"] = 3
		itemData["element"] = 0
		itemData["formula"] = "50"
		itemList["item0"] = itemData
		databaseFile.store_line(JSON.print(itemList))
		databaseFile.close()

func create_weapon_database():
	var databaseFile = File.new()
	if (!databaseFile.file_exists("res://databases/Weapon.json")):
		databaseFile.open("res://databases/Weapon.json", File.WRITE)
		var weaponList = {}
		var weaponData = {}
		var weaponStats = {}
		weaponData["name"] = "Broad Sword"
		weaponData["icon"] = ""
		weaponData["description"] = "A light and easy to use sword"
		weaponData["weapon_type"] = 0
		weaponData["slot_type"] = 0
		weaponData["price"] = 50
		weaponData["element"] = 0
		weaponStats["hp"] = "0"
		weaponStats["mp"] = "0"
		weaponStats["atk"] = "10"
		weaponStats["def"] = "2"
		weaponStats["int"] = "2"
		weaponStats["res"] = "1"
		weaponStats["spd"] = "0"
		weaponStats["luk"] = "0"
		weaponData["stat_list"] = weaponStats
		weaponList["weapon0"] = weaponData
		databaseFile.store_line(JSON.print(weaponList))
		databaseFile.close()

func create_armor_database():
	var databaseFile = File.new()
	if (!databaseFile.file_exists("res://databases/Armor.json")):
		databaseFile.open("res://databases/Armor.json", File.WRITE)
		var armorList = {}
		var armorData = {}
		var armorStats = {}
		armorData["name"] = "Clothes"
		armorData["icon"] = ""
		armorData["description"] = "Light Clothes"
		armorData["armor_type"] = 0
		armorData["slot_type"] = 0
		armorData["price"] = 50
		armorStats["hp"] = "0"
		armorStats["mp"] = "0"
		armorStats["atk"] = "10"
		armorStats["def"] = "2"
		armorStats["int"] = "2"
		armorStats["res"] = "1"
		armorStats["spd"] = "0"
		armorStats["luk"] = "0"
		armorData["stat_list"] = armorStats
		armorList["armor0"] = armorData
		databaseFile.store_line(JSON.print(armorList))
		databaseFile.close()

func create_enemy_database():
	var databaseFile = File.new()
	if (!databaseFile.file_exists("res://databases/Enemy.json")):
		databaseFile.open("res://databases/Enemy.json", File.WRITE)
		var enemyList = {}
		var enemyData = {}
		var statsData = {}
		var dropData = {}
		enemyData["name"] = "Slime"
		enemyData["graphicImage"] = ""
		statsData["hp"] = "150"
		statsData["mp"] = "50"
		statsData["atk"] = "18"
		statsData["def"] = "16"
		statsData["int"] = "8"
		statsData["res"] = "4"
		statsData["spd"] = "12"
		statsData["luk"] = "10"
		dropData["i0"] = 80
		enemyData["experience"] = 6
		enemyData["money"] = 50
		enemyData["stat_list"] = statsData
		enemyData["drop_list"] = dropData
		enemyList["enemy0"] = enemyData
		databaseFile.store_line(JSON.print(enemyList))
		databaseFile.close()

func create_state_database():
	var databaseFile = File.new()
	if (!databaseFile.file_exists("res://databases/State.json")):
		databaseFile.open("res://databases/State.json", File.WRITE)
		var stateList = {}
		var stateData = {}
		var eraseCondition = {}
		var messages = {}
		var customEraseConditions = {}
		stateData["name"] = "Death"
		stateData["icon"] = ""
		stateData["restriction"] = 4
		stateData["priority"] = 100
		eraseCondition["turns_min"] = 0
		eraseCondition["turns_max"] = 0
		eraseCondition["erase_damage"] = 0
		eraseCondition["erase_setps"] = 0
		stateData["erase_conditions"] = eraseCondition
		messages["0"] = ""
		stateData["messages"] = messages
		customEraseConditions["0"] = ""
		stateData["custom_erase_conditions"] = customEraseConditions

		stateList["state0"] = stateData
		databaseFile.store_line(JSON.print(stateList))
		databaseFile.close()

func create_effect_database():
	var databaseFile = File.new()
	if (!databaseFile.file_exists("res://databases/Effect.json")):
		databaseFile.open("res://databases/Effect.json", File.WRITE)
		var effect_list = {}
		var effect_data = {}
		var showList = {}
		var value2 = {}
		effect_data["name"] = "hp_recovery"
		showList["show"] = false
		showList["data"] = ""
		effect_data["data_type"] = showList
		effect_data["value1"] = 1
		value2["show"] = true
		value2["data"] = 2
		effect_data["value2"] = value2
		
		effect_list["effect0"] = effect_data
		databaseFile.store_line(JSON.print(effect_list))
		databaseFile.close()
