tool
extends Control

var iconPath = ""
var skillSelected = 0

func start():
	var jsonDictionary = get_parent().get_parent().call("read_data", "Skill")
	var systemDictionary = get_parent().get_parent().call("read_data", "System")

	for i in jsonDictionary.size():
		var skillData = jsonDictionary["skill" + String(i)]
		if (i > $SkillButton.get_item_count() - 1):
			$SkillButton.add_item(String(skillData["name"]))
		else:
			$SkillButton.set_item_text(i, String(skillData["name"]))
	var systemData = systemDictionary["elements"]
	for i in systemData.size():
		if (i > $DamageLabel/ElementLabel/ElementButton.get_item_count() - 1):
			$DamageLabel/ElementLabel/ElementButton.add_item(String(systemData[String(i)]))
		else:
			$DamageLabel/ElementLabel/ElementButton.set_item_text(i, String(systemData[String(i)]));



	systemData = systemDictionary["skills"]
	for i in systemData.size():
		if (i > $SkillTypeLabel/SkillTypeButton.get_item_count() - 1):
			$SkillTypeLabel/SkillTypeButton.add_item(String(systemData[String(i)]))
		else:
			$SkillTypeLabel/SkillTypeButton.set_item_text(i, String(systemData[String(i)]));
	refresh_data(skillSelected);


func refresh_data(id = skillSelected):
	var jsonDictionary = get_parent().get_parent().call("read_data", "Skill")
	if jsonDictionary.has("skill" + String(id)):
		$SkillButton.select(skillSelected)
		var skillData = jsonDictionary["skill" + String(id)]
		$NameLabel/NameText.text = String(skillData["name"])
		var icon = String(skillData["icon"])
		if (icon != ""):
			$IconLabel/IconSprite.texture = load(String(skillData["icon"]))
		$DescLabel/DescText.text = String(skillData["description"])
		$SkillTypeLabel/SkillTypeButton.selected = int(skillData["skill_type"])
		$MPCostLabel/MPCostBox.value = int(skillData["mp_cost"])
		$TPCostLabel/TPCostBox.value = int(skillData["tp_cost"])
		$TargetLabel/TargetButton.selected = int(skillData["target"])
		$UsableLabel/UsableButton.selected = int(skillData["usable"])
		$HitLabel/HitBox.value = int(skillData["success"])
		$TypeLabel/TypeButton.selected = int(skillData["hit_type"])
		$DamageLabel/DTypeLabel/DTypeButton.selected = int(skillData["damage_type"])
		$DamageLabel/ElementLabel/ElementButton.selected = int(skillData["element"])
		$DamageLabel/DFormulaLabel/FormulaText.text = String(skillData["formula"])
	else:
		print("Undefined skill with id: " + String(id))


func _on_Search_pressed():
	$IconLabel/IconSearch.popup_centered()


func _on_IconSearch_file_selected(path):
	iconPath = path;
	$IconLabel/IconSprite.texture = load(path)


func _on_AddSkill_pressed():
	$SkillButton.add_item("NewSkill")
	var id = $SkillButton.get_item_count() - 1;
	var jsonDictionary = get_parent().get_parent().call("read_data", "Skill")
	var skillData = {}
	skillData["name"] = "NewSkill"
	skillData["icon"] = ""
	skillData["description"] = "New created skill"
	skillData["skill_type"] = 0
	skillData["mp_cost"] = 1
	skillData["tp_cost"] = 1
	skillData["target"] = 1
	skillData["usable"] = 1
	skillData["success"] = 95
	skillData["hit_type"] = 1
	skillData["damage_type"] = 1
	skillData["element"] = 0
	skillData["formula"] = "atk * 4 - def * 2"
	jsonDictionary["skill" + String(id)] = skillData
	get_parent().get_parent().call("store_data", "Skill", jsonDictionary);
	skillSelected = id
	refresh_data()


func _on_RemoveSkill_pressed():
	var jsonDictionary = get_parent().get_parent().call("read_data", "Skill")
	if (jsonDictionary.size() > 1):
		var skillId = skillSelected
		while (skillId < jsonDictionary.size() - 1):
			if jsonDictionary.has("skill" + String(skillId + 1)):
				jsonDictionary["skill" + String(skillId)] = jsonDictionary["skill" + String(skillId + 1)]
			skillId += 1;
		jsonDictionary.erase("skill" + String(skillId))
		get_parent().get_parent().call("store_data", "Skill", jsonDictionary)
		$SkillButton.remove_item(skillSelected);
		if (skillSelected == 0):
			$SkillButton.select(skillSelected + 1);
			skillSelected += 1;
		else:
			$SkillButton.select(skillSelected - 1);
			skillSelected -= 1;
		$SkillButton.select(skillSelected)
		refresh_data(skillSelected)


func _on_SkillSaveButton_pressed():
	save_skill_data()
	refresh_data(skillSelected)


func save_skill_data():
	var jsonDictionary = get_parent().get_parent().call("read_data", "Skill")
	var skillData = jsonDictionary["skill" + String(skillSelected)]
	skillData["name"] = $NameLabel/NameText.text
	$SkillButton.set_item_text(skillSelected, $NameLabel/NameText.text);
	skillData["icon"] = iconPath;
	skillData["description"] = $DescLabel/DescText.text
	skillData["skill_type"] = $SkillTypeLabel/SkillTypeButton.selected
	skillData["mp_cost"] = $MPCostLabel/MPCostBox.value
	skillData["tp_cost"] = $TPCostLabel/TPCostBox.value
	skillData["target"] = $TargetLabel/TargetButton.selected
	skillData["usable"] = $UsableLabel/UsableButton.selected
	skillData["success"] = $HitLabel/HitBox.value
	skillData["hit_type"] = $TypeLabel/TypeButton.selected
	skillData["damage_type"] = $DamageLabel/DTypeLabel/DTypeButton.selected
	skillData["element"] = $DamageLabel/ElementLabel/ElementButton.selected
	skillData["formula"] = $DamageLabel/DFormulaLabel/FormulaText.text
	get_parent().get_parent().call("store_data", "Skill", jsonDictionary);


func _on_SkillButton_item_selected(id):
	skillSelected = id;
	refresh_data(id);
