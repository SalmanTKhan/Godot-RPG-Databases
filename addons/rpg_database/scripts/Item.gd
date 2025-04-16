@tool
extends Control

var icon_path = ""
var item_selected = 0

func start():
	var json_data = get_parent().get_parent().call("read_data", "Item")
	
	for i in json_data.size():
		var item_data = json_data["item" + String(i)]
		if (i > $ItemButton.get_item_count() - 1):
			$ItemButton.add_item(String(item_data["name"]))
		else:
			$ItemButton.set_item_text(i, String(item_data["name"]))
	
	json_data = get_parent().get_parent().call("read_data", "System")
	
	var systemData = json_data["elements"]
	for i in systemData.size():
		if (i > $DamageLabel/ElementLabel/ElementButton.get_item_count() - 1):
			$DamageLabel/ElementLabel/ElementButton.add_item(String(systemData[String(i)]))
		else:
			$DamageLabel/ElementLabel/ElementButton.set_item_text(i, String(systemData[String(i)]))
	
	refresh_data()
	

func refresh_data(id = item_selected):
	var json_data = get_parent().get_parent().call("read_data", "Item")
	if json_data.has("item" + String(id)):
		$ItemButton.select(id)
		var item_data = json_data["item" + String(id)]
		$NameLabel/NameText.text = String(item_data["name"])
		var icon = String(item_data["icon"])
		if (icon != ""):
			$IconLabel/IconSprite.texture = load(icon)
		$DescLabel/DescText.text = String(item_data["description"])
		$ItemTypeLabel/ItemTypeButton.selected = int(item_data["item_type"])
		$PriceLabel/PriceBox.value = int(item_data["price"])
		$ConsumableLabel/ConsumableButton.selected = int(item_data["consumable"])
		$TargetLabel/TargetButton.selected = int(item_data["target"])
		$UsableLabel/UsableButton.selected = int(item_data["usable"])
		$HitLabel/HitBox.value = int(item_data["success"])
		$TypeLabel/TypeButton.selected = int(item_data["hit_type"])
		$DamageLabel/DTypeLabel/DTypeButton.selected = int(item_data["damage_type"])
		$DamageLabel/ElementLabel/ElementButton.selected = int(item_data["element"])
		$DamageLabel/DFormulaLabel/FormulaText.text = String(item_data["formula"])
		
		clear_effect_list()
		if (item_data.has("effects")):
			var effect_list = item_data["effects"]
			for effect in effect_list:
				add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Undefined item with id: " + String(id))


func save_item_data():
	var json_data = get_parent().get_parent().call("read_data", "Item")
	var item_data = json_data["item" + String(item_selected)]
	var effect_list = []
	
	item_data["name"] = $NameLabel/NameText.text
	$ItemButton.set_item_text(item_selected, $NameLabel/NameText.text)
	item_data["icon"] = icon_path
	item_data["description"] = $DescLabel/DescText.text
	item_data["item_type"] = $ItemTypeLabel/ItemTypeButton.selected
	item_data["price"] = $PriceLabel/PriceBox.value
	item_data["consumable"] = $ConsumableLabel/ConsumableButton.selected
	item_data["target"] = $TargetLabel/TargetButton.selected
	item_data["usable"] = $UsableLabel/UsableButton.selected
	item_data["success"] = $HitLabel/HitBox.value
	item_data["hit_type"] = $TypeLabel/TypeButton.selected
	item_data["damage_type"] = $DamageLabel/DTypeLabel/DTypeButton.selected
	item_data["element"] = $DamageLabel/ElementLabel/ElementButton.selected
	item_data["formula"] = $DamageLabel/DFormulaLabel/FormulaText.text
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	item_data["effects"] = effect_list
	
	get_parent().get_parent().call("store_data", "Item", json_data)


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


func _on_Search_pressed():
	$IconLabel/IconSearch.popup_centered()
	

func _on_IconSearch_file_selected(path):
	icon_path = path
	$IconLabel/IconSprite.texture = load(path)
	
func _on_AddItem_pressed():
	$ItemButton.add_item("NewItem")
	var id = $ItemButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "Item")
	var item_data = {}
	item_data["name"] = "NewItem"
	item_data["icon"] =""
	item_data["description"] = "New created item"
	item_data["item_type"] = 0
	item_data["price"] = 10
	item_data["consumable"] = 0
	item_data["target"] = 3
	item_data["usable"] = 0
	item_data["success"] = 95
	item_data["hit_type"] = 1
	item_data["damage_type"] = 1
	item_data["element"] = 0
	item_data["formula"] = "10"
	json_data["item" + String(id)] = item_data
	get_parent().get_parent().call("store_data", "Item", json_data)
	item_selected = id
	refresh_data()


func _on_RemoveItem_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Item")
	if (json_data.size() > 1):
		var itemId = item_selected
		while (itemId < json_data.size() - 1):
			if json_data.has("item" + String(itemId + 1)):
				json_data["item" + String(itemId)] = json_data["item" + String(itemId + 1)]
			itemId += 1
		
		json_data.erase("item" + String(itemId))
		get_parent().get_parent().call("store_data", "Item", json_data)
		$ItemButton.remove_item(item_selected)
		if (item_selected == 0):
			$ItemButton.select(item_selected + 1)
			item_selected += 1
		else:
			$ItemButton.select(item_selected - 1)
			item_selected -= 1
		
		$ItemButton.select(item_selected)
		refresh_data(item_selected)


func _on_ItemSaveButton_pressed():
	save_item_data()
	refresh_data(item_selected)


func _on_ItemButton_item_selected(id):
	item_selected = id
	refresh_data()


func _on_AddItemEffect_pressed():
	get_parent().get_parent().call("open_effect_manager", "Item")


func _on_RemoveItemEffect_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
