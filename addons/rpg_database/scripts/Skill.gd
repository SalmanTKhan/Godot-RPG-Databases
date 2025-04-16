@tool
extends Control

var iconPath = ""
var skillSelected = 0

func start():
	var json_data = get_parent().get_parent().call("read_data", "Skill")
	var systemDictionary = get_parent().get_parent().call("read_data", "System")

	for i in json_data.size():
		var skill_data = json_data["skill" + String(i)]
		if (i > $SkillButton.get_item_count() - 1):
			$SkillButton.add_item(String(skill_data["name"]))
		else:
			$SkillButton.set_item_text(i, String(skill_data["name"]))
	var systemData = systemDictionary["elements"]
	for i in systemData.size():
		if (i > $DamageLabel/ElementLabel/ElementButton.get_item_count() - 1):
			$DamageLabel/ElementLabel/ElementButton.add_item(String(systemData[String(i)]))
		else:
			$DamageLabel/ElementLabel/ElementButton.set_item_text(i, String(systemData[String(i)]))



	systemData = systemDictionary["skills"]
	for i in systemData.size():
		if (i > $SkillTypeLabel/SkillTypeButton.get_item_count() - 1):
			$SkillTypeLabel/SkillTypeButton.add_item(String(systemData[String(i)]))
		else:
			$SkillTypeLabel/SkillTypeButton.set_item_text(i, String(systemData[String(i)]))
	refresh_data(skillSelected)


func refresh_data(id = skillSelected):
	var json_data = get_parent().get_parent().call("read_data", "Skill")
	if json_data.has("skill" + String(id)):
		$SkillButton.select(skillSelected)
		var skill_data = json_data["skill" + String(id)]
		$NameLabel/NameText.text = String(skill_data["name"])
		var icon = String(skill_data["icon"])
		if (icon != ""):
			$IconLabel/IconSprite.texture = load(String(skill_data["icon"]))
		$DescLabel/DescText.text = String(skill_data["description"])
		$SkillTypeLabel/SkillTypeButton.selected = int(skill_data["skill_type"])
		$MPCostLabel/MPCostBox.value = int(skill_data["mp_cost"])
		$TPCostLabel/TPCostBox.value = int(skill_data["tp_cost"])
		$TargetLabel/TargetButton.selected = int(skill_data["target"])
		$UsableLabel/UsableButton.selected = int(skill_data["usable"])
		$HitLabel/HitBox.value = int(skill_data["success"])
		$TypeLabel/TypeButton.selected = int(skill_data["hit_type"])
		$DamageLabel/DTypeLabel/DTypeButton.selected = int(skill_data["damage_type"])
		$DamageLabel/ElementLabel/ElementButton.selected = int(skill_data["element"])
		$DamageLabel/DFormulaLabel/FormulaText.text = String(skill_data["formula"])
		
		clear_effect_list()
		if (skill_data.has("effects")):
			var effect_list = skill_data["effects"]
			for effect in effect_list:
				add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Undefined skill with id: " + String(id))


func save_skill_data():
	var json_data = get_parent().get_parent().call("read_data", "Skill")
	var skill_data = json_data["skill" + String(skillSelected)]
	var effect_list = []
	
	skill_data["name"] = $NameLabel/NameText.text
	$SkillButton.set_item_text(skillSelected, $NameLabel/NameText.text)
	skill_data["icon"] = iconPath
	skill_data["description"] = $DescLabel/DescText.text
	skill_data["skill_type"] = $SkillTypeLabel/SkillTypeButton.selected
	skill_data["mp_cost"] = $MPCostLabel/MPCostBox.value
	skill_data["tp_cost"] = $TPCostLabel/TPCostBox.value
	skill_data["target"] = $TargetLabel/TargetButton.selected
	skill_data["usable"] = $UsableLabel/UsableButton.selected
	skill_data["success"] = $HitLabel/HitBox.value
	skill_data["hit_type"] = $TypeLabel/TypeButton.selected
	skill_data["damage_type"] = $DamageLabel/DTypeLabel/DTypeButton.selected
	skill_data["element"] = $DamageLabel/ElementLabel/ElementButton.selected
	skill_data["formula"] = $DamageLabel/DFormulaLabel/FormulaText.text
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	skill_data["effects"] = effect_list
	
	get_parent().get_parent().call("store_data", "Skill", json_data)

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
	iconPath = path
	$IconLabel/IconSprite.texture = load(path)


func _on_AddSkill_pressed():
	$SkillButton.add_item("NewSkill")
	var id = $SkillButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "Skill")
	var skill_data = {}
	skill_data["name"] = "NewSkill"
	skill_data["icon"] = ""
	skill_data["description"] = "New created skill"
	skill_data["skill_type"] = 0
	skill_data["mp_cost"] = 1
	skill_data["tp_cost"] = 1
	skill_data["target"] = 1
	skill_data["usable"] = 1
	skill_data["success"] = 95
	skill_data["hit_type"] = 1
	skill_data["damage_type"] = 1
	skill_data["element"] = 0
	skill_data["formula"] = "atk * 4 - def * 2"
	json_data["skill" + String(id)] = skill_data
	get_parent().get_parent().call("store_data", "Skill", json_data)
	skillSelected = id
	refresh_data()


func _on_RemoveSkill_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Skill")
	if (json_data.size() > 1):
		var skillId = skillSelected
		while (skillId < json_data.size() - 1):
			if json_data.has("skill" + String(skillId + 1)):
				json_data["skill" + String(skillId)] = json_data["skill" + String(skillId + 1)]
			skillId += 1
		json_data.erase("skill" + String(skillId))
		get_parent().get_parent().call("store_data", "Skill", json_data)
		$SkillButton.remove_item(skillSelected)
		if (skillSelected == 0):
			$SkillButton.select(skillSelected + 1)
			skillSelected += 1
		else:
			$SkillButton.select(skillSelected - 1)
			skillSelected -= 1
		$SkillButton.select(skillSelected)
		refresh_data(skillSelected)


func _on_SkillSaveButton_pressed():
	save_skill_data()
	refresh_data(skillSelected)


func _on_SkillButton_item_selected(id):
	skillSelected = id
	refresh_data(id)


func _on_AddSkillEffect_pressed():
	get_parent().get_parent().call("open_effect_manager", "Skill")


func _on_RemoveSkillEffect_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
