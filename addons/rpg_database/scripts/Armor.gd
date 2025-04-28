@tool
extends Control

var iconPath = ""
var armor_selected = 0
var stat_edit = -1

func start():
	var json_data = get_parent().get_parent().call("read_data", "Armor")
	for i in json_data.size():	
		var armor_data = json_data["armor" + String(i)]
		if (i > $ArmorButton.get_item_count() - 1):
			$ArmorButton.add_item(String(armor_data["name"]))
		else:
			$ArmorButton.set_item_text(i, String(armor_data["name"]))
	json_data = get_parent().get_parent().call("read_data", "System")
	
	var system_data = json_data["armors"]
	for i in system_data.size():
		if (i > $ATypeLabel/ATypeButton.get_item_count() - 1):
			$ATypeLabel/ATypeButton.add_item(String(system_data[String(i)]))
		else:
			$ATypeLabel/ATypeButton.set_item_text(i, String(system_data[String(i)]))
	
	
	
	system_data = json_data["slots"]
	var final_id = 0
	for slot in system_data:
		if (slot[0] == 'a'):
			var id = int(slot.right(1)) - final_id
			if (id > $SlotLabel/SlotButton.get_item_count() - 1):
				$SlotLabel/SlotButton.add_item(String(system_data[slot]))
			else:
				$SlotLabel/SlotButton.set_item_text(id, String(system_data[slot]))
		else:
			final_id += 1
	refresh_data()


func refresh_data(id = armor_selected):
	var json_data = get_parent().get_parent().call("read_data", "Armor")
	if (json_data.has("armor" + String(id))):
		$ArmorButton.select(id)
		var armor_data = json_data["armor" + String(id)]

		json_data = get_parent().get_parent().call("read_data", "System")
		var system_data = json_data["stats"]

		$NameLabel/NameText.text = String(armor_data["name"])
		if armor_data.has("icon"):
			var icon = String(armor_data["icon"])
			if (icon != ""):
				$IconLabel/IconSprite.texture = load(icon)
		
		$DescLabel/DescText.text = String(armor_data["description"])
		$ATypeLabel/ATypeButton.selected = int(armor_data["armor_type"])
		$SlotLabel/SlotButton.selected = int(armor_data["slot_type"])
		$PriceLabel/PriceSpin.value = int(armor_data["price"])

		$StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.clear()
		$StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.clear()
		for i in system_data.size():	
			var stat_name = String(system_data[String(i)])
			var armor_stat_formula = armor_data["stat_list"]
			var stat_formula = ""
			if (armor_stat_formula.has(stat_name)):
				stat_formula = String(armor_stat_formula[String(stat_name)])
			else:
				stat_formula = "0"
		
			$StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.add_item(stat_name)
			$StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.add_item(stat_formula)
		clear_effect_list()
		if (armor_data.has("effects")):
			var effect_list = armor_data["effects"]
			for effect in effect_list:
				add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Undefined armor with id: " + String(id))


func save_armor_data():
	var json_data = get_parent().get_parent().call("read_data", "Armor")
	var armor_data = json_data["armor"+String(armor_selected)]
	var armor_stat_formula = armor_data["stat_list"]
	var effect_list = []
	armor_data["name"] = $NameLabel/NameText.text
	$ArmorButton.set_item_text(armor_selected, $NameLabel/NameText.text)
	armor_data["icon"] = iconPath
	armor_data["description"] = $DescLabel/DescText.text
	armor_data["armor_type"] = $ATypeLabel/ATypeButton.selected
	armor_data["slot_type"] = $SlotLabel/SlotButton.selected
	armor_data["price"] = $PriceLabel/PriceSpin.value
	var items = $StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.get_item_count()
	for i in items:
		var stat = $StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.get_item_text(i)
		var formula = $StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.get_item_text(i)
		armor_stat_formula[stat] = formula
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	armor_data["effects"] = effect_list
	get_parent().get_parent().call("store_data", "Armor", json_data)


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


func _on_AddArmorButton_pressed():
	$ArmorButton.add_item("NewArmor")
	var id = $ArmorButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "Armor")
	var armor_data = {}
	var armor_stats = {}
	armor_data["name"] = "NewArmor"
	armor_data["icon"] = ""
	armor_data["description"] = "New created armor"
	armor_data["armor_type"] = 0
	armor_data["slot_type"] = 0
	armor_data["price"] = 50
	armor_stats["hp"] = "0"
	armor_stats["mp"] = "0"
	armor_stats["atk"] = "10"
	armor_stats["def"] = "2"
	armor_stats["int"] = "2"
	armor_stats["res"] = "1"
	armor_stats["spd"] = "0"
	armor_stats["luk"] = "0"
	armor_data["stat_list"] = armor_stats
	json_data["armor" + String(id)] = armor_data
	get_parent().get_parent().call("store_data", "Armor", json_data)
	armor_selected = id
	refresh_data()


func _on_RemoveArmor_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Armor")
	if (json_data.size() > 1):
		var armorId = armor_selected
		while (armorId < json_data.size() - 1):
			if json_data.has("armor" + String(armorId + 1)):
				json_data["armor" + String(armorId)] = json_data["armor" + String(armorId + 1)]
			armorId += 1
	
		json_data.erase("armor" + String(armorId))
		get_parent().get_parent().call("store_data", "Armor", json_data)
		$ArmorButton.remove_item(armor_selected)
		if (armor_selected == 0):
			$ArmorButton.select(armor_selected + 1)
			armor_selected += 1
		else:
			$ArmorButton.select(armor_selected - 1)
			armor_selected -= 1
		$ArmorButton.select(armor_selected)
		refresh_data()
	


func _on_ArmorSaveButton_pressed():
	save_armor_data()
	refresh_data()


func _on_Search_pressed():
	$IconLabel/IconSearch.popup_centered()


func _on_IconSearch_file_selected(path):
	iconPath = path
	$IconLabel/IconSprite.texture = load(path)


func _on_ArmorButton_item_selected(id):
	armor_selected = id
	refresh_data()


func _on_StatValueList_item_activated(index):
	var stat_name = $StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.get_item_text(index)
	var stat_formula = $StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.get_item_text(index)
	$StatEditor/StatLabel.text = stat_name
	$StatEditor/StatEdit.text = stat_formula
	stat_edit = index
	$StatEditor.show()


func _on_OkButton_pressed():
	var stat_formula = $StatEditor/StatEdit.text
	$StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.set_item_text(stat_edit, stat_formula)
	save_armor_data()
	stat_edit = -1
	$StatEditor.hide()


func _on_CancelButton_pressed():
	stat_edit = -1
	$StatEditor.hide()


func _on_AddArmorEffect_pressed():
	get_parent().get_parent().call("open_effect_manager", "Armor")


func _on_RemoveArmorEffect_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
