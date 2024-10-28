/datum/job/
	var/list/possible_backstories = list()

/datum/controller/subsystem/jobs/proc/pick_backstory(var/list/backstories_list, var/mob/user)
	if(!ishuman(user))
		return
	var/list/possible_backstories = list()
	for(var/thing in backstories_list)//Populate possible backstories list.
		var/datum/backstory/A = new thing
		possible_backstories += A
	if(!possible_backstories.len)//If there's nothing there afterwards return.
		return
	var/datum/backstory/backstory
	for(var/datum/backstory/story in shuffle(possible_backstories)) // end me
		if(prob(15))
			break // A chance you won't get one at all.
		if(prob(story.chance))
			backstory = story
			break
		else
			continue
	if(!backstory)
		return
	backstory.apply(user)

/datum/backstory/
	var/name = "BASE NAME"
	var/description = "BASE BACKSTORY"
	var/chance = 100

/datum/backstory/proc/apply(var/mob/living/carbon/human/user)
	if(!user)
		return
	if(!description)
		return
	if(!name)
		return
	user.mind.store_memory(FONT_GIANT("\n<b>|--[name]--|</b>"))
	user.mind.store_memory(description)
	user.show_message(SPAN_YELLOW_LARGE(FONT_LARGE("\n|--[name]--|")))
	user.show_message(SPAN_YELLOW(FONT_SMALL("[description]\n")))