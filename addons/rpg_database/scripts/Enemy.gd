tool
extends Control


var graphics_path = ""
var enemy_selected = 0
var stat_edit = -1
var drop_id_array = []

func start():
	var json_data = get_parent().get_parent().call("read_data", "Enemy")
	for i in json_data.size():
		var enemy_data = json_data["enemy" + String(i)]
		if (i > $EnemyButton.get_item_count() - 1):
			$EnemyButton.add_item(String(enemy_data["name"]))
		else:
			$EnemyButton.set_item_text(i, String(enemy_data["name"]))
	refresh_data()


func refresh_data(id = enemy_selected):
	var json_data = get_parent().get_parent().call("read_data", "Enemy")
	if json_data.has("enemy" + String(id)):
		$EnemyButton.select(id)
		var enemy_data = json_data["enemy" + String(id)]

		json_data = get_parent().get_parent().call("read_data", "System")
		var systemStats_data = json_data["stats"]
		var itemList = get_parent().get_parent().call("read_data", "Item")
		var weaponList = get_parent().get_parent().call("read_data", "Weapon")
		var armorList = get_parent().get_parent().call("read_data", "Armor")

		$NameLabel/NameLine.text = String(enemy_data["name"])
		var graphic = String(enemy_data["graphicImage"])
		if (graphic != ""):
			graphics_path = String(enemy_data["graphicImage"])
			$GraphicLabel/Graphic.texture = load(graphics_path)
		$StatsLabel/StatsContainer/DataContainer/StatList.clear()
		$StatsLabel/StatsContainer/DataContainer/FormulaList.clear()
		for i in systemStats_data.size():
			var statName = systemStats_data[String(i)]
			var enemyStatFormula = enemy_data["stat_list"]
			var statFormula = ""
			if (enemyStatFormula.has(statName)):
				statFormula = String(enemyStatFormula[statName])
			else:
				statFormula = "level * 5"
			
			$StatsLabel/StatsContainer/DataContainer/StatList.add_item(statName)
			$StatsLabel/StatsContainer/DataContainer/FormulaList.add_item(statFormula)
		

		var dropList = enemy_data["drop_list"]

		$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.clear()
		$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/ChanceList.clear()
		drop_id_array.clear()
		for drop in dropList:
			var kind = String(drop[0])
			var kind_id = drop.right(1)
			match (kind):
				"i":
					drop_id_array.append(drop)
					var item_data = itemList["item" + String(kind_id)]
					$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.add_item(String(item_data["name"]))
				"w":
					drop_id_array.append(drop)
					var weapon_data = weaponList["weapon" + String(kind_id)]
					$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.add_item(String(weapon_data["name"]))
				"a":
					drop_id_array.append(drop)
					var armor_data = armorList["armor" + String(kind_id)]
					$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.add_item(String(armor_data["name"]))
		
			$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/ChanceList.add_item(String(dropList[drop]))
		
		$ExpLabel/ExpSpin.value = int(enemy_data["experience"])
		$GoldLabel/GoldSpin.value = int(enemy_data["money"])
		
		clear_effect_list()
		if (enemy_data.has("effects")):
			var effect_list = enemy_data["effects"]
			for effect in effect_list:
				add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Undefined enemy with id: " + String(id))


func save_enemy_data():
	var json_data = get_parent().get_parent().call("read_data", "Enemy")
	var enemy_data = json_data["enemy" + String(enemy_selected)]
	var stats_data = enemy_data["stat_list"]
	var drops_data = enemy_data["drop_list"]
	var effect_list = []
	enemy_data["name"] = $NameLabel/NameLine.text
	enemy_data["graphicImage"] = graphics_path
	var items = $StatsLabel/StatsContainer/DataContainer/StatList.get_item_count()
	for i in items:
		var stat = $StatsLabel/StatsContainer/DataContainer/StatList.get_item_text(i)
		var formula = $StatsLabel/StatsContainer/DataContainer/FormulaList.get_item_text(i)
		stats_data[stat] = formula
	
	items = $DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.get_item_count()
	#drop_id_array.resize(items)
	for i in items:
		var id = drop_id_array[i]
		var chance = $DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/ChanceList.get_item_text(i)
		drops_data[id] = chance
	enemy_data["experience"] = $ExpLabel/ExpSpin.value
	enemy_data["money"] = $GoldLabel/GoldSpin.value
	enemy_data["stat_list"] = stats_data
	enemy_data["drop_list"] = drops_data
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	enemy_data["effects"] = effect_list
	
	get_parent().get_parent().call("store_data", "Enemy", json_data)


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


func _on_AddEnemy_pressed():
	$EnemyButton.add_item("NewEnemy")
	var id = $EnemyButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "Enemy")
	var enemy_data = {}
	var stats_data = {}
	var drop_data = {}

	enemy_data["name"] = "NewEnemy"
	enemy_data["graphicImage"] = ""
	stats_data["hp"] = "150"
	stats_data["mp"] = "50"
	stats_data["atk"] = "18"
	stats_data["def"] = "16"
	stats_data["int"] = "8"
	stats_data["res"] = "4"
	stats_data["spd"] = "12"
	stats_data["luk"] = "10"
	drop_data["i0"] = 80
	enemy_data["experience"] = 6
	enemy_data["money"] = 50
	enemy_data["stat_list"] = stats_data
	enemy_data["drop_list"] = drop_data
	json_data["enemy" + String(id)] = enemy_data
	get_parent().get_parent().call("store_data", "Enemy", json_data)
	enemy_selected = id
	refresh_data()


func _on_RemoveEnemy_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Enemy")
	if (json_data.size() > 1):
		var enemyId = enemy_selected
		while (enemyId < json_data.size() - 1):
			if json_data.has("enemy" + String(enemyId + 1)):
				json_data["enemy" +  String(enemyId)] = json_data["enemy" + String(enemyId + 1)]
			enemyId += 1
	
		json_data.erase("enemy" + String(enemyId))
		get_parent().get_parent().call("store_data", "Enemy", json_data)
		$EnemyButton.remove_item(enemy_selected)
		if (enemy_selected == 0):
			enemy_selected += 1
		else:
			enemy_selected -= 1
		$EnemyButton.select(enemy_selected)
		refresh_data()


func _on_SearchGraphic_pressed():
	$EnemyGraphic.popup_centered()


func _on_EnemyGraphic_file_selected(path):
	graphics_path = path
	$GraphicLabel/Graphic.texture = load(path)


func _on_FormulaList_item_activated(index):
	var statName = $StatsLabel/StatsContainer/DataContainer/StatList.get_item_text(index)
	var statFormula = $StatsLabel/StatsContainer/DataContainer/FormulaList.get_item_text(index)
	$StatsEdit/Stat.text = statName
	$StatsEdit/Formula.text = statFormula
	stat_edit = index
	$StatsEdit.popup_centered()


func _on_EnemyStatEditorOkButton_pressed():
	var statFormula = $StatsEdit/Formula.text
	$StatsLabel/StatsContainer/DataContainer/FormulaList.set_item_text(stat_edit, statFormula)
	save_enemy_data()
	stat_edit = -1
	$StatsEdit.hide()


func _on_EnemyStatEditorCancelButton_pressed():
	stat_edit = -1
	$StatsEdit.hide()


func _on_AddDrop_pressed():
	$DropEdit/Type/OptionButton.select(0)
	var item_data = get_parent().get_parent().call("read_data", "Item")

	for i in item_data.size():
		var itemName = item_data["item" + String(i)]
		if (i > $DropEdit/Drop/OptionButton.get_item_count() - 1):
			$DropEdit/Drop/OptionButton.add_item(String(itemName["name"]))
		else:
			$DropEdit/Drop/OptionButton.set_item_text(i, String(itemName["name"]))
	$DropEdit.popup_centered()


func _on_RemoveDrop_pressed():
	for i in $DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.get_selected_items():
		$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.remove_item(i)
		$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/ChanceList.remove_item(i)
	save_enemy_data()


func _on_DropType_item_selected(index):
	var item_data = get_parent().get_parent().call("read_data", "Item")
	var weapon_data = get_parent().get_parent().call("read_data", "Weapon")
	var armor_data = get_parent().get_parent().call("read_data", "Armor")
	$DropEdit/Drop/OptionButton.clear()
	match (index):
		0:
			for i in item_data.size():
				var itemName = item_data["item" + String(i)]
				if (i > $DropEdit/Drop/OptionButton.get_item_count() - 1):
					$DropEdit/Drop/OptionButton.add_item(String(itemName["name"]))
				else:
					$DropEdit/Drop/OptionButton.set_item_text(i, String(itemName["name"]))
		1:
			for i in weapon_data.size():
				var weaponName = weapon_data["weapon" + String(i)]
				if (i > $DropEdit/Drop/OptionButton.get_item_count() - 1):
					$DropEdit/Drop/OptionButton.add_item(String(weaponName["name"]))
				else:
					$DropEdit/Drop/OptionButton.set_item_text(i, String(weaponName["name"]))
		2:
			for i in armor_data.size():
				var armorName = armor_data["armor" + String(i)]
				if (i > $DropEdit/Drop/OptionButton.get_item_count() - 1):
					$DropEdit/Drop/OptionButton.add_item(String(armorName["name"]))
				else:
					$DropEdit/Drop/OptionButton.set_item_text(i, String(armorName["name"]))	


func _on_DropEditOkButton_pressed():
	var itemList = get_parent().get_parent().call("read_data", "Item")
	var weaponList = get_parent().get_parent().call("read_data", "Weapon")
	var armorList = get_parent().get_parent().call("read_data", "Armor")
	
	var id = $DropEdit/Type/OptionButton.get_selected_id()
	var selected_id = $DropEdit/Drop/OptionButton.get_selected_id()
	var chance = int($DropEdit/Chance/SpinBox.value)

	match (id):
		0:
			drop_id_array.append("i" + String(selected_id))
			var item_data = itemList["item" + String(selected_id)]
			$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.add_item(String(item_data["name"]))
		1:
			drop_id_array.append("w" + String(selected_id))
			var weapon_data = weaponList["weapon" + String(selected_id)]
			$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.add_item(String(weapon_data["name"]))
		2:
			drop_id_array.append("a" + String(selected_id))
			var armor_data = armorList["armor" + String(selected_id)]
			$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/DropsList.add_item(String(armor_data["name"]))
	
	$DropsLabel/DropsContainer/VBoxContainer/HBoxContainer/ChanceList.add_item(String(chance))
	$DropEdit.hide()


func _on_DropEditCancelButton_pressed():
	$DropEdit.hide()


func _on_EnemySaveButton_pressed():
	save_enemy_data()
	refresh_data()


func _on_AddEnemyEffect_pressed():
	get_parent().get_parent().call("open_effect_manager", "Enemy")


func _on_RemoveEnemyEffect_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
