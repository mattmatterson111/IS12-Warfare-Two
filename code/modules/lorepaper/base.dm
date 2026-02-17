GLOBAL_DATUM_INIT(war_lore, /datum/war_lore, new /datum/war_lore)

/obj/structure/war_terminal
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_machine"

/obj/structure/war_terminal/attack_hand(mob/user)
	. = ..()
	to_chat(user, "Name: [GLOB.war_lore.generate_name()]")
	user.play_screen_text("[time2text(world.realtime, "MM-DD")]\n[time2text(world.timeofday, "hh:mm")]\n[GLOB.war_lore.name]", alert = /atom/movable/screen/text/screen_text/battlefield)

/proc/is_map_flora(var/map_flora_name)
	if(!istext(map_flora_name))
		return FALSE
	if(!GLOB.war_lore || !istext(GLOB.war_lore.map_flora))
		return FALSE
	return lowertext(GLOB.war_lore.map_flora) == lowertext(map_flora_name)

/proc/is_war_lore_flora(var/flora_name)
	if(!istext(flora_name))
		return FALSE
	return is_map_flora(flora_name)

/datum/war_lore
	var/name = "REDACTED"
	var/list/prefixes = list("Ray", "Sea", "Ocean", "Capri", "Crimson", "Garnet", "Maroon", "Fungal", "Blut", "Shadow", "Blue", "Blu", "Bluer", "Azur", "Cobalt", "Saphir", "Bleak", "Glas", "Morne", "Indigo", "Cerule", "Wint", "Mist", "Nive", "Lazul", "Aura")
	var/list/suffixes = list("front", "bastion", "bergfrid", "banquet", "gabion", "line", "forest", "ashdunes", "vale", "ridge", "field", "pass", "fort", "march", "hollow", "watch", "peak", "cliff", "moor","reach", "crag", "fen", "shard", "glen", "grasp", "waste", "rift")
	var/map_flora = "classic"
	var/list/flora_profiles = list()

	var/list/structures = list(
		"Battle of %PLACE",
		"Skirmish at %PLACE",
		"The Siege of %PLACE",
		"Massacre of %PLACE",
		"Conflict at %PLACE",
		"Uprising in %CITY",
		"Campaign of %PLACE"
	)

/datum/war_lore/proc/build_default_flora_profiles()
	return list(
		"classic" = list(
			"flora_spawns" = list(
				/obj/structure/flora/wasteland/misc = 13,
				/obj/structure/flora/wasteland/tree = 10,
				/obj/structure/flora/wasteland/rock = 35
			)
		),
		"forest" = list(
			"flora_spawns" = list(
				/obj/structure/flora/wasteland/tree = 13,
				/obj/structure/flora/wasteland/tree_full = 11,
				/obj/structure/flora/wasteland/rock = 55
			)
		)
	)

/datum/war_lore/New()
	. = ..()
	if(!islist(flora_profiles) || !flora_profiles.len)
		flora_profiles = build_default_flora_profiles()
	name = generate_name()
	map_flora = generate_map_flora()

/datum/war_lore/proc/generate_place_name()
	var/prefix = pick(prefixes)
	var/suffix = pick(suffixes)

	if(prob(20))
		var/prefix2 = pick(prefixes)
		var/suffix2 = pick(suffixes)
		return "[prefix][suffix] [prefix2][suffix2]"
	else
		return "[prefix][suffix]"

/datum/war_lore/proc/generate_city_name()
	var/list/city_suffixes = list("grad", "berg", "chester", "stead", "port", "mouth", "ton", "ford", "heim", "wich", "polis", "thal", "york")
	var/prefix = pick(prefixes)
	var/suffix = pick(city_suffixes)

	return "[prefix][suffix]"

/datum/war_lore/proc/generate_name()
	var/structure = pick(structures)

	if(findtext(structure, "%PLACE"))
		structure = replacetext(structure, "%PLACE", generate_place_name())

	if(findtext(structure, "%CITY"))
		structure = replacetext(structure, "%CITY", generate_city_name())

	return structure

/datum/war_lore/proc/generate_map_flora()
	if(!islist(flora_profiles) || !flora_profiles.len)
		flora_profiles = build_default_flora_profiles()

	var/list/flora_names = list()
	for(var/flora_name in flora_profiles)
		if(!istext(flora_name))
			continue
		if(!islist(flora_profiles[flora_name]))
			continue
		flora_names += flora_name

	if(!flora_names.len)
		return "classic"

	return pick(flora_names)

/datum/war_lore/proc/get_flora_profile()
	if(!islist(flora_profiles) || !flora_profiles.len)
		flora_profiles = build_default_flora_profiles()
	var/list/profile = flora_profiles[map_flora]
	if(!islist(profile))
		return flora_profiles["classic"]
	return profile

/datum/war_lore/proc/generate_flora_variant()
	return generate_map_flora()
