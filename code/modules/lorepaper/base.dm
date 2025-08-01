GLOBAL_DATUM_INIT(war_lore, /datum/war_lore, new /datum/war_lore)

/obj/structure/war_terminal
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_machine"

/obj/structure/war_terminal/attack_hand(mob/user)
	. = ..()
	to_chat(user, "Name: [GLOB.war_lore.generate_name()]")
	user.play_screen_text("[time2text(world.realtime, "MM-DD")]\n[time2text(world.timeofday, "hh:mm")]\n[GLOB.war_lore.name]", alert = /atom/movable/screen/text/screen_text/battlefield)

/datum/war_lore
	var/name = "REDACTED"
	var/list/prefixes = list("Ray", "Sea", "Ocean", "Capri", "Crimson", "Garnet", "Maroon", "Fungal", "Blut", "Shadow", "Blue", "Blu", "Bluer", "Azur", "Cobalt", "Saphir", "Bleak", "Glas", "Morne", "Indigo", "Cerule", "Wint", "Mist", "Nive", "Lazul", "Aura")
	var/list/suffixes = list("front", "bastion", "bergfrid", "banquet", "gabion", "line", "forest", "ashdunes", "vale", "ridge", "field", "pass", "fort", "march", "hollow", "watch", "peak", "cliff", "moor","reach", "crag", "fen", "shard", "glen", "grasp", "waste", "rift")

	var/list/structures = list(
		"Battle of %PLACE",
		"Skirmish at %PLACE",
		"The Siege of %PLACE",
		"Massacre of %PLACE",
		"Conflict at %PLACE",
		"Uprising in %CITY",
		"Campaign of %PLACE"
	)

/datum/war_lore/New()
	. = ..()
	name = generate_name()

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