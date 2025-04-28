@tool
extends Control

var face_path: String = ""
var character_path: String = ""
var character_selected: int = 0
var initial_equip_edit = -1
var equip_id_array = []
var equip_edit_array = []
var initial_equip_id_array = []

func start():
	var json_data = get_parent().get_parent().call("read_data", "Character")
	$CharacterButton.clear()
	for i in json_data.size():
		if (json_data.has("chara" + String(i))):
			var character_data = json_data["chara" + String(i)]
			if (i > $CharacterButton.get_item_count() - 1):
				$CharacterButton.add_item(String(character_data["name"]))
			else:
				$CharacterButton.set_item_text(i, String(character_data["name"]))
		refresh_data()

func refresh_data(id = character_selected):
	var json_data = get_parent().get_parent().call("read_data", "Character")
	if json_data.has("chara" + String(id)):
			var character_data = json_data["chara" + String(id)]
			var name = String(character_data["name"])
			var face = String(character_data["faceImage"])
			$CharacterButton.set_item_text(id, name)
			$CharacterButton.select(id)
			$NameLabel/NameText.text = name
			if (face != ""):
				face_path = face
			if (character_data.has("description")):
				$DescLabel/DescText.text = String(character_data["description"])
			else:
				$DescLabel/DescText.text = ""
			$InitLevelLabel/InitLevelText.value = int(character_data["initialLevel"])
			$MaxLevelLabel/MaxLevelText.value = int(character_data["maxLevel"])
			
			json_data = get_parent().get_parent().call("read_data", "System")
			var weapons = json_data["weapons"]
			var armor = json_data["armors"]
			var equip_slots = json_data["slots"]
			var equip_types = character_data["equip_types"]
			$EquipLabel/EquipContainer/EquipContainer/EquipList.clear()
			equip_id_array.clear()
			var equip_name = ""
			for equip in equip_types:
				var kind = String(equip[0])
				var type_id = String(equip_types[equip])
				equip_id_array.append(int(equip_types[equip]))
				match(kind):
					"w":
						var weapon_id = equip.right(1)
						equip_name = "W: " + String(weapons[type_id])
						$EquipLabel/EquipContainer/EquipContainer/EquipList.add_item(equip_name)
					"a":
						var armor_id = equip.right(1)
						equip_name = "A: " + String(armor[type_id])
						$EquipLabel/EquipContainer/EquipContainer/EquipList.add_item(equip_name)

			var weapon_list = get_parent().get_parent().call("read_data", "Weapon")
			var armor_list = get_parent().get_parent().call("read_data", "Armor")
			
			$InitialEquipLabel/PanelContainer/TypeContainer/EquipList.clear()
			$InitialEquipLabel/PanelContainer/TypeContainer/TypeList.clear()
			var initial_equip_data = character_data["initial_equip"]
			initial_equip_id_array.clear()
			for equip in equip_slots:
				$InitialEquipLabel/PanelContainer/TypeContainer/TypeList.add_item(String(equip_slots[equip]))
				var kind = String(equip[0])
				var kind_id = int(equip.right(1))
				
				match(kind):
					"w":
						var weapon_id = -1
						if (kind_id < initial_equip_data.size()):
							weapon_id = initial_equip_data[String(kind_id)]
						initial_equip_id_array.append(weapon_id)
						if weapon_id >= 0:
							var weaponData = weapon_list["weapon" + String(weapon_id)]
							$InitialEquipLabel/PanelContainer/TypeContainer/EquipList.add_item(String(weaponData["name"]))
						else:
							$InitialEquipLabel/PanelContainer/TypeContainer/EquipList.add_item("None")
					"a":
						var armor_id = -1
						if (kind_id < initial_equip_data.size()):
							armor_id = initial_equip_data[String(kind_id)]
						initial_equip_id_array.append(armor_id)
						if armor_id >= 0:
							var armorData = armor_list["armor" + String(armor_id)]
							$InitialEquipLabel/PanelContainer/TypeContainer/EquipList.add_item(String(armorData["name"]))
						else:
							$InitialEquipLabel/PanelContainer/TypeContainer/EquipList.add_item("None")
			json_data = get_parent().get_parent().call("read_data", "Class")
			for i in json_data.size():
				var class_data = json_data["class" + String(i)]
				if (i > $ClassLabel/ClassText.get_item_count()):
					$ClassLabel/ClassText.add_item(String(class_data["name"]))
				else:
					$ClassLabel/ClassText.set_item_text(i, String(class_data["name"]))
			$ClassLabel/ClassText.select(int(character_data["class"]))
			clear_effect_list()
			if (character_data.has("effects")):
				var effect_list = character_data["effects"]
				for effect in effect_list:
					add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Undefined character with id: " + String(id))


func set_face_image(path):
	$FaceLabel/FaceSprite.texture = load(path)


func save_character_data():
	var json_data = get_parent().get_parent().call("read_data", "Character")
	var character_data = json_data["chara" + str(character_selected)]
	var equip_type_data = character_data["equip_types"]
	var initial_equip_data = character_data["initial_equip"]
	var effect_list = []

	character_data["faceImage"] = face_path
	character_data["charaImage"] = character_path
	character_data["name"] = $NameLabel/NameText.text
	$CharacterButton.set_item_text(character_selected, $NameLabel/NameText.text)
	character_data["class"] = $ClassLabel/ClassText.selected
	character_data["description"] = $DescLabel/DescText.text
	character_data["initialLevel"] = $InitLevelLabel/InitLevelText.value
	character_data["maxLevel"] = $MaxLevelLabel/MaxLevelText.value

	equip_type_data.clear()
	var equip_items = $EquipLabel/EquipContainer/EquipContainer/EquipList.get_item_count()
	for i in equip_items:
		var kind = $EquipLabel/EquipContainer/EquipContainer/EquipList.get_item_text(i).substr(0, 1)
		match (kind):
			"W":
				equip_type_data["w" + String(i)] = equip_id_array[i]
			"A":
				equip_type_data["a" + String(i)] = equip_id_array[i]
	character_data["equip_types"] = equip_type_data

	var slot_items = $InitialEquipLabel/PanelContainer/TypeContainer/EquipList.get_item_count()
	for i in slot_items:
		initial_equip_data[String(i)] = int(initial_equip_id_array[i])
	character_data["initial_equip"] = initial_equip_data
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	character_data["effects"] = effect_list
	
	get_parent().get_parent().call("store_data", "Character", json_data)

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


func _on_CharaSaveButton_pressed():
	save_character_data()
	refresh_data()


func _on_CharacterButton_item_selected(id):
	character_selected = id
	refresh_data()

func _on_AddButton_pressed():
	$CharacterButton.add_item("NewCharacter")
	var id = $CharacterButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "Character")
	var characterData = {}
	var etypeData = {}
	var einitData = {}
	characterData["faceImage"] = "res://"
	characterData["charaImage"] = "res://"
	characterData["name"] = "NewCharacter"
	characterData["class"] = 0
	characterData["description"] = ""
	characterData["initialLevel"] = 1
	characterData["maxLevel"] = 99
	etypeData["w0"] = 0
	etypeData["w1"] = 1
	etypeData["a2"] = 0
	etypeData["a3"] = 3
	einitData["0"] = -1
	einitData["1"] = -1
	einitData["2"] = -1
	einitData["3"] = -1
	characterData["initial_equip"] = einitData
	characterData["equip_types"] = etypeData
	json_data["chara" + String(id)] = characterData
	get_parent().get_parent().call("store_data", "Character", json_data)
	character_selected = id
	refresh_data()

func _on_RemoveCharacterButton_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Character")
	if (json_data.size() > 1):
		var chara = character_selected
		while (chara < json_data.size() - 1):
			if (json_data.has("chara" + String(chara+1))):
				json_data["chara" + String(chara)] = json_data["chara" + String(chara+1)]
			chara += 1
		json_data.erase("chara"+String(chara))
		get_parent().get_parent().call("store_data", "Character", json_data)
		$CharacterButton.remove_item(character_selected)
		if (character_selected == 0):
			$CharacterButton.select(character_selected+1)
			character_selected += 1
		else:
			$CharacterButton.select(character_selected-1)
			character_selected -= 1
		$CharacterButton.select(character_selected)
		refresh_data(character_selected)

func _on_Search_pressed():
	$FaceLabel/FaceSearch.popup_centered()

func _on_FaceSearch_file_selected(file):
	face_path = file
	set_face_image(file)


func _on_EquipList_item_activated(index):
	initial_equip_edit = index
	equip_edit_array.append("-1")
	$InitialEquipLabel/InitialEquipChange/Label.text = $InitialEquipLabel/PanelContainer/TypeContainer/TypeList.get_item_text(index)

	$InitialEquipLabel/InitialEquipChange/Label/OptionButton.clear()
	$InitialEquipLabel/InitialEquipChange/Label/OptionButton.add_item("None")
	var json_data = get_parent().get_parent().call("read_data", "Character")
	var character_data = json_data["chara" + str(character_selected)]

	json_data = get_parent().get_parent().call("read_data", "System")
	var slotsData = json_data["slots"]

	var equipTypesData = character_data["equip_types"]
	if (slotsData.has("w" + String(index))):
		var weaponList = get_parent().get_parent().call("read_data", "Weapon")

		var weaponArray = []
		for key in equipTypesData:
			var kind = String(key[0])
			if (kind == "w"):
				weaponArray.append(int(equipTypesData[key]))

		for weapon in weaponList:
			var weaponData = weaponList[weapon]
			if (weaponArray.has(int(weaponData["weapon_type"]))):
				equip_edit_array.append(weapon.right(6))
				$InitialEquipLabel/InitialEquipChange/Label/OptionButton.add_item(String(weaponData["name"]))
	elif (slotsData.has("a" + String(index))):
		var armorList = get_parent().get_parent().call("read_data", "Armor")

		var armorArray = []
		for key in equipTypesData:
			var kind = String(key[0])
			if (kind == "a"):
				armorArray.append(int(equipTypesData[key]))

		for armor in armorList:
			var armorData = armorList[armor]
			if (armorArray.has(int(armorData["armor_type"]))):
				equip_edit_array.append(armor.right(5))
				$InitialEquipLabel/InitialEquipChange/Label/OptionButton.add_item(String(armorData["name"]))
	$InitialEquipLabel/InitialEquipChange.popup_centered()


func _on_OkInitialEquipButton_pressed():
	var text = $InitialEquipLabel/InitialEquipChange/Label/OptionButton.text
	var selected = $InitialEquipLabel/InitialEquipChange/Label/OptionButton.selected
	$InitialEquipLabel/PanelContainer/TypeContainer/EquipList.set_item_text(initial_equip_edit, text)
	if int(equip_edit_array[selected]) >= initial_equip_id_array.size():
		initial_equip_id_array.resize(int(equip_edit_array[selected]) + 1)
	initial_equip_id_array.insert(initial_equip_edit, int(equip_edit_array[selected]))
	initial_equip_edit = -1
	equip_edit_array.clear()
	$InitialEquipLabel/InitialEquipChange.hide()


func _on_CancelInitialEquipButton_pressed():
	initial_equip_edit = -1
	equip_edit_array.clear()
	$InitialEquipLabel/InitialEquipChange.hide()


func _on_AddEquipTypeButton_pressed():
	$EquipLabel/AddEquip.popup_centered()
	var json_data = get_parent().get_parent().call("read_data", "System")
	var wtypeData = json_data["weapons"]
	for i in wtypeData.size():
		if i > ($EquipLabel/AddEquip/EquipLabel/EquipButton.get_item_count() - 1):
			$EquipLabel/AddEquip/EquipLabel/EquipButton.add_item(String(wtypeData[String(i)]))
		else:
			$EquipLabel/AddEquip/EquipLabel/EquipButton.set_item_text(i, String(wtypeData[String(i)]))


func _on_RemoveEquipTypeButton_pressed():
	var selected = $EquipLabel/EquipContainer/EquipContainer/EquipList.get_selected_items()[0]
	equip_id_array.remove(selected)
	$EquipLabel/EquipContainer/EquipContainer/EquipList.remove_item(selected)


func _on_TypeButton_item_selected(index):
	var json_data = get_parent().get_parent().call("read_data", "System")
	$EquipLabel/AddEquip/EquipLabel/EquipButton.clear()
	match (index):
		0:
			var wTypeData = json_data["weapons"]
			for i in wTypeData.size():
				if (i > $EquipLabel/AddEquip/EquipLabel/EquipButton.get_item_count() - 1):
					$EquipLabel/AddEquip/EquipLabel/EquipButton.add_item(String(wTypeData[String(i)]))
				else:
					$EquipLabel/AddEquip/EquipLabel/EquipButton.set_item_text(i, String(wTypeData[String(i)]))
		1:
			var aTypeData = json_data["armors"]
			for i in aTypeData.size():
				if (i > $EquipLabel/AddEquip/EquipLabel/EquipButton.get_item_count() - 1):
					$EquipLabel/AddEquip/EquipLabel/EquipButton.add_item(String(aTypeData[String(i)]))
				else:
					$EquipLabel/AddEquip/EquipLabel/EquipButton.set_item_text(i, String(aTypeData[String(i)]))


func _on_OkButton_pressed():
	var kind = $EquipLabel/AddEquip/TypeLabel/TypeButton.selected
	var item = $EquipLabel/AddEquip/EquipLabel/EquipButton.selected
	equip_id_array.append(int((item)))
	var itemText = $EquipLabel/AddEquip/EquipLabel/EquipButton.text
	match (kind):
		0:
			$EquipLabel/EquipContainer/EquipContainer/EquipList.add_item("W: " + itemText)
		1:
			$EquipLabel/EquipContainer/EquipContainer/EquipList.add_item("A: " + itemText)
	$EquipLabel/AddEquip.hide()


func _on_CancelButton_pressed():
	$EquipLabel/AddEquip.hide()


func _on_CharacterAddEffectButton_pressed():
	get_parent().get_parent().call("open_effect_manager", "Character")


func _on_CharacterRemoveEffectButton_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
