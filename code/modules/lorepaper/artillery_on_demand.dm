/client/proc/artillery()
	set category = "roleplay"
	set name = "Artillery Barrage"
	set desc = "Kaboom, Ricko."

	if(!holder)
		return

	var/key = input("Select an artillery type", "KABOOM") as anything in list("rflare","bflare","shrapnel","gas","fire")+"CANCEL"
	if(key == "CANCEL")
		return
	var/amount = input("Change the MAX amount?", "Input 0 for default") as num
	var/playsound = input("Play sound?", "Yes or No") as anything in list("Yes","No")
	if(playsound == "Yes")
		sound_to(world, 'sound/effects/arty_distant.ogg')
		sleep(4 SECONDS)
	artillery_barage(mob.x, mob.y, mob.z, mortartype=key, bypass_restrictions = TRUE, maxamount = amount)

	message_admins("[ckey] began a '[key]' artillery barrage.")