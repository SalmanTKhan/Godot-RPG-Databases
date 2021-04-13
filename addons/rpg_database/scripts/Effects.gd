tool
extends Control


var addNewEffect = true
var databaseLoaded = false
func start():
	if (databaseLoaded == false):
		var jsonDictionary = get_parent().get_parent().call("read_data", "Effect")
		for i in jsonDictionary.size():
			var effectData = jsonDictionary["effect" + String(i)]
			var showList = effectData["data_type"]
			var value2 = effectData["value2"]

			$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.add_item(String(effectData["name"]))
			if showList.has("show") and showList["show"]:
				$EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.add_item(String(showList["data"]))
			else:
				$EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.add_item("Disabled");

			$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.add_item(String(effectData["value1"]))
			if (value2.has("show") and value2["show"]):
				$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.add_item(String(value2["data"]))
			else:
				$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.add_item("-1");
		databaseLoaded = true;

func _on_AddEffect_pressed():
	addNewEffect = true;
	$AddEffect.popup_centered()


func _on_EditEffect_pressed():
	if ($EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_selected_items()[0] > -1):
		addNewEffect = false;
		var id = $EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_selected_items()[0]

		var name = $EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_item_text(id)
		var dataTypes = $EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.get_item_text(id)
		var value1 = int($EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.get_item_text(id))
		var value2 = int($EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.get_item_text(id))

		$AddEffect/VBoxContainer/Name/LineEdit.text = name;
		if (dataTypes == "Disabled"):
			$AddEffect/VBoxContainer/ShowList/CheckButton.pressed = false
			$AddEffect/VBoxContainer/ShowList/OptionButton.disabled = true
		else:
			$AddEffect/VBoxContainer/ShowList/CheckButton.pressed = true
			$AddEffect/VBoxContainer/ShowList/OptionButton.disabled = false
		match (dataTypes):
			"States":
				$AddEffect/VBoxContainer/ShowList/OptionButton.select(0)
			"Stats":
				$AddEffect/VBoxContainer/ShowList/OptionButton.select(1)
			"Weapon Types":
				$AddEffect/VBoxContainer/ShowList/OptionButton.select(2)
			"Armor Types":
				$AddEffect/VBoxContainer/ShowList/OptionButton.select(3)
			"Elements":
				$AddEffect/VBoxContainer/ShowList/OptionButton.select(4)
			"Skill Types":
				$AddEffect/VBoxContainer/ShowList/OptionButton.select(5)
		
		$AddEffect/VBoxContainer/Value1/OptionButton.select(value1)
		if (value2 == -1):
			$AddEffect/VBoxContainer/Value2/CheckButton.pressed = false
			$AddEffect/VBoxContainer/Value2/OptionButton.disabled = true
		else:
			$AddEffect/VBoxContainer/Value2/CheckButton.pressed = true
			$AddEffect/VBoxContainer/Value2/OptionButton.disabled = false
			$AddEffect/VBoxContainer/Value2/OptionButton.select(value2)
	
		$AddEffect.popup_centered()


func _on_RemoveEffect_pressed():
	var selectedEffect = $EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_selected_items()[0];
	if (selectedEffect > -1):
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.remove_item(selectedEffect)
		$EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.remove_item(selectedEffect)
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.remove_item(selectedEffect)
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.remove_item(selectedEffect)


func _on_ClearEffects_pressed():
	$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.clear()
	$EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.clear()
	$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.clear()
	$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.clear()


func _on_ShowListCheckButton_pressed():
	if ($AddEffect/VBoxContainer/ShowList/CheckButton.pressed == true):
		$AddEffect/VBoxContainer/ShowList/OptionButton.disabled = false
	else:
		$AddEffect/VBoxContainer/ShowList/OptionButton.disabled = true


func _on_Value2CheckButton_pressed():
	if ($AddEffect/VBoxContainer/Value2/CheckButton.pressed == true):
		$AddEffect/VBoxContainer/Value2/OptionButton.disabled = false
	else:
		$AddEffect/VBoxContainer/Value2/OptionButton.disabled = true
	

func _on_AddEffectConfirm_pressed():
	var name = $AddEffect/VBoxContainer/Name/LineEdit.text
	var selected = 0
	var dataType = "Disabled"
	if ($AddEffect/VBoxContainer/ShowList/CheckButton.pressed == true):
		selected = $AddEffect/VBoxContainer/ShowList/OptionButton.selected
		dataType = $AddEffect/VBoxContainer/ShowList/OptionButton.get_item_text(selected)
	
	var value1 = $AddEffect/VBoxContainer/Value1/OptionButton.selected
	var value2 = -1
	if ($AddEffect/VBoxContainer/Value2/CheckButton.pressed == true):
		value2 = $AddEffect/VBoxContainer/Value2/OptionButton.selected
	if (addNewEffect == false):
		var id = $EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_selected_items()[0];
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.set_item_text(id, name);
		$EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.set_item_text(id, dataType);
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.set_item_text(id, String(value1))
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.set_item_text(id, String(value2))
	else:
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.add_item(name)
		$EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.add_item(dataType)
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.add_item(String(value1))
		$EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.add_item(String(value2))
	
	$AddEffect.hide()


func _on_AddEffectCancel_pressed():
	$AddEffect.hide()


func _on_SaveEffects_pressed():
	var size = $EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_item_count()
	var effectList = {}
	for i in size:
	
		var effectData = {}
		var showList = {}
		var value2 = {}
		effectData["name"] = $EffectLabel/PanelContainer/VBoxContainer/Effects/EffectNames.get_item_text(i)
		var dataType = $EffectLabel/PanelContainer/VBoxContainer/Effects/DataTypes.get_item_text(i)
		if (dataType == "Disabled"):
			showList["show"] = false
			showList["data"] = ""
		else:
			showList["show"] = true
			showList["data"] = dataType
	
		effectData["data_type"] = showList;
		effectData["value1"] = int($EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue1.get_item_text(i))
		var value2Val = int($EffectLabel/PanelContainer/VBoxContainer/Effects/EffectValue2.get_item_text(i))
		if (value2Val == -1):
			value2["show"] = false
			value2["data"] = ""
		else:
			value2["show"] = true
			value2["data"] = value2Val
	
		effectData["value2"] = value2
		effectList["effect" + String(i)] = effectData
	
	get_parent().get_parent().call("store_data", "Effect", effectList)
