/*

This file is built for communication with a discord bot.

*/

/client/proc/ping_wardog()
	set name = "Ping Wardog Webhook"
	set category = "Debug"

	var/players = 0
	for(var/client/C in GLOB.clients)
		players++

	var/condition = SSwarfare.complete
	var/victor = findtext(condition, "red") ? "red" : (findtext(condition, "blue") ? "blue" : "draw")
	SSwebhooks.send("wardog", list("victor" = victor, "condition" = condition, "players" = players))

/decl/webhook/wardog
	var/id = "wardog"

/datum/controller/gameticker/declare_completion()
	. = ..()
	var/players = 0
	for(var/client/C in GLOB.clients)
		players++

	var/condition = SSwarfare.complete
	var/victor = findtext(condition, "red") ? "red" : (findtext(condition, "blue") ? "blue" : "draw")
	SSwebhooks.send("wardog", list("victor" = victor, "condition" = condition, "players" = players))

/decl/webhook/wardog/get_message(list/data)
	. = ..()

	var/desc = "## \"[GLOB.war_lore.name]\".\n\n"
	if(data)
		desc += "> The winning team ended up being the *[data["victor"]]*.\n"
		desc += "> In the end, it was a *[data["condition"] ? data["condition"] : "draw"]*.\n"
		desc += "> There were *[data["players"]]* players participating.\n\n"
		desc += "> In total, *[GLOB.mines_tripped]* mines were tripped.\n"
		desc += "> *[GLOB.teeth_lost]* teeth were lost.\n"
		desc += "> and there were *[GLOB.total_deaths]* deaths.\n\n"
		desc += "> It only ended at *[roundduration2text()]*."
	.["embeds"] = list(list(
		"title" = "# A round of Interwar has ended.\n",
		"description" = desc,
		"color" = 0x8bbbd5
	))

/*
/hook/startup/proc/roundstartping()
	send_to_bot(list(
		"call" = "roundstart"
	))
*/