/datum/job/
	var/list/backstories = list()

// I know this is bad, I know this shouldn't have to create all of the datums each time, but I can't be bothered to make it better right now.
// edit: It doesn't create them each time, it's stored as a list, but it's still shit

/datum/controller/subsystem/jobs/proc/pick_backstory(var/datum/job/job, var/mob/user)
	if(!ishuman(user))
		return
	var/datum/backstory/backstory = null
	for(var/datum/backstory/story in shuffle(job.backstories)) // end me
		if(prob(story.chance))
			backstory = story
			break
		else
			continue
	if(!backstory) // you get nothing
		return
	backstory.apply(user)
	user.backstory = backstory

/datum/backstory/
	var/name = "BASE NAME"
	var/description = "BASE BACKSTORY"
	var/chance = 100
	var/apply_sound = 'sound/effects/backstory.ogg'

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
	if(apply_sound)
		sound_to(user, apply_sound)