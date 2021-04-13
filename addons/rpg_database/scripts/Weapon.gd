tool
extends Control

var iconPath = ""
var weapon_selected = 0
var stat_edit = -1

func start():
	var json_data = get_parent().get_parent().call("read_data", "Weapon")
	for i in json_data.size():
		var weapon_data = json_data["weapon" + String(i)]
		if (i > $WeaponButton.get_item_count() - 1):
			$WeaponButton.add_item(String(weapon_data["name"]))
		else:
			$WeaponButton.set_item_text(i, String(weapon_data["name"]))
	json_data = get_parent().get_parent().call("read_data", "System")
	var system_data = json_data["elements"]
	for i in system_data.size():
		if (i > $ElementLabel/ElementButton.get_item_count() - 1):
			$ElementLabel/ElementButton.add_item(String(system_data[String(i)]))
		else:
			$ElementLabel/ElementButton.set_item_text(i, String(system_data[String(i)]))
	
	system_data = json_data["weapons"]
	for i in system_data.size():
		if (i > $WTypeLabel/WTypeButton.get_item_count() - 1):
			$WTypeLabel/WTypeButton.add_item(String(system_data[String(i)]))
		else:
			$WTypeLabel/WTypeButton.set_item_text(i, String(system_data[String(i)]))
	
	system_data = json_data["slots"]
	var final_id = 0
	for slot in system_data:
		var kind = String(slot[0])
		if (slot[0] == 'w'):
			var id = int(slot.right(1)) - final_id;
			if (id > $SlotLabel/SlotButton.get_item_count() - 1):
				$SlotLabel/SlotButton.add_item(String(system_data[slot]))
			else:
				$SlotLabel/SlotButton.set_item_text(id, String(system_data[slot]));	
		else:
			final_id += 1;
	refresh_data()


func refresh_data(id = weapon_selected):
	var json_data = get_parent().get_parent().call("read_data", "Weapon")
	if json_data.has("weapon" + String(id)):
		var weapon_data = json_data["weapon" + String(id)]
		json_data = get_parent().get_parent().call("read_data", "System")
		var system_data = json_data["stats"]
		$WeaponButton.select(id)
		$NameLabel/NameText.text = String(weapon_data["name"])
		if weapon_data.has("icon"):
			var icon = String(weapon_data["icon"])
			if (icon != ""):
				$IconLabel/IconSprite.texture = load(icon)
		
		$DescLabel/DescText.text = String(weapon_data["description"])
		$WTypeLabel/WTypeButton.selected = int(weapon_data["weapon_type"]);
		$SlotLabel/SlotButton.selected = int(weapon_data["slot_type"]);
		$PriceLabel/PriceSpin.value = int(weapon_data["price"]);
		$ElementLabel/ElementButton.selected = int(weapon_data["element"]);

		$StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.clear()
		$StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.clear()
		for i in system_data.size():
			var stat_name = String(system_data[String(i)]);
			var weapon_stat_formula = weapon_data["stat_list"]
			var stat_formula = "";
			if (weapon_stat_formula.has(stat_name)):
				stat_formula = String(weapon_stat_formula[String(stat_name)])
			else:
				stat_formula = "0";
			$StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.add_item(stat_name);
			$StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.add_item(stat_formula);
	else:
		print("Undefined weapon with id:" + String(id))


func save_weapon_data():
	var json_data = get_parent().get_parent().call("read_data", "Weapon")
	var weapon_data = json_data["weapon" + String(weapon_selected)]
	var weapon_stat_formula = weapon_data["stat_list"]
	weapon_data["name"] = $NameLabel/NameText.text
	$WeaponButton.set_item_text(weapon_selected, $NameLabel/NameText.text)
	weapon_data["icon"] = iconPath
	weapon_data["description"] = $DescLabel/DescText.text
	weapon_data["weapon_type"] = $WTypeLabel/WTypeButton.selected
	weapon_data["slot_type"] = $SlotLabel/SlotButton.selected
	weapon_data["price"] = $PriceLabel/PriceSpin.value
	weapon_data["element"] = $ElementLabel/ElementButton.selected
	var items = $StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.get_item_count()
	for i in items:
		var stat = $StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.get_item_text(i)
		var formula = $StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.get_item_text(i)
		weapon_stat_formula[stat] = formula
	get_parent().get_parent().call("store_data", "Weapon", json_data)


func _on_AddWeaponButton_pressed():
	$WeaponButton.add_item("NewWeapon");
	var id = $WeaponButton.get_item_count() - 1;
	var json_data = get_parent().get_parent().call("read_data", "Weapon")
	var weapon_data = {}
	var weapon_stats = {}
	weapon_data["name"] = "NewWeapon"
	weapon_data["icon"] = ""
	weapon_data["description"] = "New created weapon"
	weapon_data["weapon_type"] = 0
	weapon_data["slot_type"] = 0
	weapon_data["price"] = 50
	weapon_data["element"] = 0
	weapon_stats["hp"] = "0"
	weapon_stats["mp"] = "0"
	weapon_stats["atk"] = "10"
	weapon_stats["def"] = "2"
	weapon_stats["int"] = "2"
	weapon_stats["res"] = "1"
	weapon_stats["spd"] = "0"
	weapon_stats["luk"] = "0"
	weapon_data["stat_list"] = weapon_stats
	json_data["weapon" + String(id)] = weapon_data
	get_parent().get_parent().call("store_data", "Weapon", json_data);
	weapon_selected = id
	refresh_data()


func _on_RemoveWeapon_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Weapon")
	if (json_data.size() > 1):
		var weaponId = weapon_selected
		while (weaponId < json_data.size() - 1):		
			if (json_data.has("weapon" + String(weaponId + 1))):
				json_data["weapon" + String(weaponId)] = json_data["weapon" + String(weaponId + 1)];
			weaponId += 1
	
		json_data.erase("weapon" + String(weaponId))
		get_parent().get_parent().call("store_data", "Weapon", json_data);
		$WeaponButton.remove_item(weapon_selected);
		if (weapon_selected == 0):
			$WeaponButton.select(weapon_selected + 1)
			weapon_selected += 1
		else:
			$WeaponButton.select(weapon_selected - 1);
			weapon_selected -= 1;
	
		refresh_data()


func _on_WeaponSaveButton_pressed():
	save_weapon_data()
	refresh_data(weapon_selected)


func _on_Search_pressed():
	$IconLabel/IconSearch.popup_centered()


func _on_IconSearch_file_selected(path):
	iconPath = path
	$IconLabel/IconSprite.texture = load(path)


func _on_WeaponButton_item_selected(id):
	weapon_selected = id;
	refresh_data()


func _on_StatValueList_item_activated(index):
	var stat_name = $StatsLabel/StatsContainer/DataContainer/StatNameCont/StatNameList.get_item_text(index)
	var stat_formula = $StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.get_item_text(index)
	$StatEditor/StatLabel.text = stat_name
	$StatEditor/StatEdit.text = stat_formula
	stat_edit = index
	$StatEditor.show()


func _on_OkButton_pressed():
	var stat_formula = $StatEditor/StatEdit.text;
	$StatsLabel/StatsContainer/DataContainer/StatValueCont/StatValueList.set_item_text(stat_edit, stat_formula);
	save_weapon_data()
	stat_edit = -1
	$StatEditor.hide()


func _on_CancelButton_pressed():
	stat_edit = -1
	$StatEditor.hide()
