@tool
extends Control

var icon_path = ""
var class_selected = 0
var stat_edit = -1
var skill_list_array = []

func start():
	var json_data = get_parent().get_parent().call("read_data", "Class")
	for i in json_data.size():
		var class_data = json_data["class" + String(i)]
		if i > ($ClassButton.get_item_count() - 1):
			$ClassButton.add_item(String(class_data["name"]))
		else:
			$ClassButton.set_item_text(i, String(class_data["name"]))
	refresh_data()

func refresh_data(id = class_selected):
	var json_data = get_parent().get_parent().call("read_data", "Class")
	if json_data.has("class" + String(id)):
		$ClassButton.select(id)
		var class_data = json_data["class" + String(id)]
		var class_skill_list = class_data["skill_list"]

		json_data = get_parent().get_parent().call("read_data", "System")
		var systemStatsData = json_data["stats"]

		json_data = get_parent().get_parent().call("read_data", "Skill")

		$NameLabel/NameText.text = String(class_data["name"])
		var icon = class_data["icon"]
		if (icon != ""):
			$IconLabel/IconSprite.texture = load(String(class_data["icon"]))
		$ExpLabel/ExpText.text = String(class_data["experience"])

		$StatsLabel/StatsContainer/DataContainer/StatsListContainer/StatsList.clear()
		$StatsLabel/StatsContainer/DataContainer/FormulaListContainer/FormulaList.clear()
		for i in systemStatsData.size():
			var stat_name = String(systemStatsData[String(i)])
			var class_stat_formula = class_data["stat_list"]
			var stat_formula = ""
			if (class_stat_formula.has(stat_name)):
				stat_formula = String(class_stat_formula[stat_name])
			else:
				stat_formula = "level * 5"
			$StatsLabel/StatsContainer/DataContainer/StatsListContainer/StatsList.add_item(stat_name)
			$StatsLabel/StatsContainer/DataContainer/FormulaListContainer/FormulaList.add_item(stat_formula)

		$SkillLabel/SkillContainer/HBoxContainer/SkillListContainer/SkillList.clear()
		$SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.clear()
		skill_list_array.clear()
		for element in class_skill_list:
			skill_list_array.append(element)
			var skill_data = json_data["skill" + String(element)]
			var skillName = String(skill_data["name"])
			$SkillLabel/SkillContainer/HBoxContainer/SkillListContainer/SkillList.add_item(skillName)
			var level = String(class_skill_list[String(element)])
			$SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.add_item(level)

		$SkillLabel/AddSkill/SkillLabel/OptionButton.clear()
		for element in json_data:
			var skill_data = json_data[element]
			var name = String(skill_data["name"])
			$SkillLabel/AddSkill/SkillLabel/OptionButton.add_item(name)
			$SkillLabel/AddSkill/SkillLabel/OptionButton.select(0)
		clear_effect_list()
		if (class_data.has("effects")):
			var effect_list = class_data["effects"]
			for effect in effect_list:
				add_effect_list(String(effect["name"]), int(effect["data_id"]), String(effect["value1"]), String(effect["value2"]))
	else:
		print("Unable to find class data for ID: " + String(id) )

func save_class_data():
	var json_data = get_parent().get_parent().call("read_data", "Class")
	var class_data = json_data["class" + String(class_selected)]
	var class_stat_formula = class_data["stat_list"]
	var class_skill_list = class_data["skill_list"]
	var effect_list = []

	class_data["name"] = $NameLabel/NameText.text
	$ClassButton.set_item_text(class_selected, $NameLabel/NameText.text)
	class_data["icon"] = icon_path
	class_data["experience"] = $ExpLabel/ExpText.text
	var items = $StatsLabel/StatsContainer/DataContainer/StatsListContainer/StatsList.get_item_count()
	for i in items:
		var stat = $StatsLabel/StatsContainer/DataContainer/StatsListContainer/StatsList.get_item_text(i)
		var formula = $StatsLabel/StatsContainer/DataContainer/FormulaListContainer/FormulaList.get_item_text(i)
		class_stat_formula[stat] = formula
	
	var skills_count = $SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.get_item_count()
	for i in skills_count:
		var skill = String(skill_list_array[i])
		var level = int($SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.get_item_text(i))
		class_skill_list[skill] = level
	
	var effect_size = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_count()
	for i in effect_size:
		var effect_data = {}
		effect_data["name"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_item_text(i)
		effect_data["data_id"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.get_item_text(i)
		effect_data["value1"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.get_item_text(i)
		effect_data["value2"] = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.get_item_text(i)
		effect_list.append(effect_data)
	
	class_data["stat_list"] = class_stat_formula
	class_data["skill_list"] = class_skill_list
	class_data["effects"] = effect_list
	get_parent().get_parent().call("store_data", "Class", json_data)


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


func _on_ClassSaveButton_pressed():
	save_class_data()
	refresh_data()


func _on_AddClass_pressed():
	$ClassButton.add_item("NewClass")
	var id = $ClassButton.get_item_count() - 1
	var json_data = get_parent().get_parent().call("read_data", "Class")
	var class_data = {}
	var stat_data = {}
	var skill_data = {}
	class_data["name"] = "NewClass"
	class_data["icon"] = ""
	class_data["experience"] = "level * 30"
	stat_data["hp"] = "level * 25 + 10"
	stat_data["mp"] = "level * 15 + 5"
	stat_data["atk"] = "level * 5 + 3"
	stat_data["def"] = "level * 5 + 3"
	stat_data["int"] = "level * 5 + 3"
	stat_data["res"] = "level * 5 + 3"
	stat_data["spd"] = "level * 5 + 3"
	stat_data["luk"] = "level * 5 + 3"
	class_data["stat_list"] = stat_data
	skill_data[0] = 5
	class_data["skill_list"] = skill_data
	json_data["class" + String(id)] = class_data
	get_parent().get_parent().call("store_data", "Class", json_data)
	class_selected = id
	refresh_data()


func _on_RemoveClass_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Class")
	if json_data.size() > 1:
		var classId = class_selected
		while classId < json_data.size() - 1:
			if (json_data.has("class" + String(classId+1))):
				json_data["class" + String(classId)] = json_data["class" + String(classId+1)]
			classId += 1
		
		json_data.erase("class" + String(classId))
		get_parent().get_parent().call("store_data", "Class", json_data)
		$ClassButton.remove_item(class_selected)
		if (class_selected == 0):
			class_selected += 1
		else:
			class_selected -= 1
		
		$ClassButton.select(class_selected)
		refresh_data()
	

func _on_ClassButton_item_selected(id):
	class_selected = id
	refresh_data()


func _on_AddSkillButton_pressed():
	$SkillLabel/AddSkill.popup_centered()


func _on_RemoveButton_pressed():
	var selected = $SkillLabel/SkillContainer/HBoxContainer/SkillListContainer/SkillList.get_selected_items()[0]
	$SkillLabel/SkillContainer/HBoxContainer/SkillListContainer/SkillList.remove_item(selected)
	$SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.remove_item(selected)
	skill_list_array.remove(selected)


func _on_OkButton_pressed():
	var json_data = get_parent().get_parent().call("read_data", "Skill")	
	var skill = $SkillLabel/AddSkill/SkillLabel/OptionButton.get_selected_id()
	var level = int($SkillLabel/AddSkill/LevelLabel/LevelSpin.value)
	skill_list_array.append(String(skill))
	var skill_data = json_data["skill" + String(skill)]
	var skillName = String(skill_data["name"])
	$SkillLabel/SkillContainer/HBoxContainer/SkillListContainer/SkillList.add_item(skillName)
	$SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.add_item(String(level))
	$SkillLabel/AddSkill.hide()


func _on_CancelButton_pressed():
	$SkillLabel/AddSkill.hide()


func _on_StatsList_item_selected(index):
	$StatsLabel/StatsContainer/DataContainer/FormulaListContainer/FormulaList.select(index)


func _on_FormulaList_item_selected(index):
	$StatsLabel/StatsContainer/DataContainer/StatsListContainer/StatsList.select(index)


func _on_SkillList_item_selected(index):
	$SkillLabel/SkillContainer/HBoxContainer/SkillLevelContainer/SkillLevelList.select(index)


func _on_SkillLevelList_item_selected(index):
	$SkillLabel/SkillContainer/HBoxContainer/SkillListContainer/SkillList.select(index)


func _on_FormulaList_item_activated(index):
	var stat_name = $StatsLabel/StatsContainer/DataContainer/StatsListContainer/StatsList.get_item_text(index)
	var stat_formula = $StatsLabel/StatsContainer/DataContainer/FormulaListContainer/FormulaList.get_item_text(index)
	$StatEditor/StatLabel.text = stat_name
	$StatEditor/StatEdit.text = stat_formula
	stat_edit = index
	$StatEditor.show()


func _on_OkStatButton_pressed():
	var stat_formula = $StatEditor/StatEdit.text
	$StatsLabel/StatsContainer/DataContainer/FormulaListContainer/FormulaList.set_item_text(stat_edit, stat_formula)
	save_class_data()
	stat_edit = -1
	$StatEditor.hide()


func _on_CancelStatButton_pressed():
	stat_edit = -1
	$StatEditor.hide()


func _on_AddClassEffect_pressed():
	get_parent().get_parent().call("open_effect_manager", "Class")


func _on_RemoveClassEffect_pressed():
	var id = $EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.get_selected_items()[0]
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectNames.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/DataType.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue1.remove_item(id)
	$EffectLabel/PanelContainer/VBoxContainer/HBoxContainer/EffectValue2.remove_item(id)
