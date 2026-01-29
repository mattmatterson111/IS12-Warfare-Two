// NOTES FOR STUFF:


	// PENDING COMPLETE REWORK SOMETIME AFTER 9/26/2024 TO USE CARGO CODE DATUMS FOR STUFF :SOB:

// this code is fucking retarded I will rewrite it someday but not today 11/2/2024

/obj/structure/closet/crate/scuffedcargo/ // unused
	name = "TEST CRATE #1"
	icon = 'icons/obj/storage.dmi'
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"

GLOBAL_LIST_EMPTY(faction_dosh)

/obj/machinery/kaos/cargo_machine
	name = "Cargo Machine"
	desc = "You use this to buy shit."
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_machine"
	anchored = TRUE
	density = TRUE
	var/credits // no longer used
	var/loggedin = FALSE
	var/list/INPUTS = list("BROWSE CATALOG", "CHECK BALANCE", "CANCEL")
	var/list/pads
	var/id
	var/withdraw_amount
	var/line_input
	var/cooldown
	var/useable = TRUE
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	clicksound = "keyboard"
	// When adding products, use this format
	// list("name" = "name in input list", "price" = price, "category" = "What category", "path" = object path),
	var/list/products = list(
	)

	var/list/categories = list("Brass.Co Top-Brass", "Brass.Co Ammunitions", "Daisy's Panacea", "Sil's Utility Corps", "ChowField Provisions", "Units", "Artillery")

/obj/machinery/kaos/cargo_machine/RightClick(mob/user)
	return // NO

/obj/machinery/kaos/cargo_machine/proc/pingpads()
	for(var/obj/structure/cargo_pad/pad in pads)
		pad.pingpad()
		if(pads.len > 4)
			playsound(pad.loc,'sound/machines/rpf/UImsg.ogg', 10, 0)
		else
			playsound(pad.loc,'sound/machines/rpf/UImsg.ogg', 20, 0)

/obj/machinery/kaos/cargo_machine/proc/playpadsequence(mob/user)
	useable = FALSE
	reconnectpads()
	playsound(src.loc, "sound/machines/rpf/barotraumastuff/UI_labelselect.ogg", 75, 0.2) // IDEA: MAKE IT A PROC!! PLEASE?? MAYBE???!! // I did it, past me.
	to_chat(user, "\icon[src]RE-ESTABLISHING CONNECTION... PLEASE WAIT..")
	spawn(2 SECONDS)
		playsound(src.loc, 'sound/machines/rpf/beepsound1.ogg', 60, 0)
		pinglight()
		spawn(2 SECONDS)
			useable = TRUE
			set_light(3, 3,"#ebc683")
			if (pads.len < 0 | pads.len == null | pads.len == 0) // I WANT TO MAKE SURE IM SANE. SO I DID IT THREE TIMES.
				set_light(3, 3,"#ebc683")
				to_chat(src, "\icon[src]ERROR. NO CARGO PADS LOCATED. CONTACT YOUR SUPERIOR OFFICER.")
				playsound(src.loc, 'sound/machines/rpf/harshdeny.ogg', 250, 0.5)
				to_chat(user, "\icon[src]AMOUNT OF LINKED PADS: [pads.len]")
			else
				playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 250, 0.5)
				to_chat(src, "\icon[src]LINK ESTABLISHED SUCCESSFULLY.")
				to_chat(user, "\icon[src]AMOUNT OF LINKED PADS: [pads.len]")

/obj/machinery/kaos/cargo_machine/proc/get_objects_on_turf(turf/T)
	// Initialize an empty list to hold the objects
	var/list/objects_on_turf = list()

	// Loop through the contents of the turf
	for (var/obj/A in T)
		// Add each object to the list
		objects_on_turf += A

	// Return the list of objects
	return objects_on_turf

/obj/machinery/kaos/cargo_machine/proc/pinglight()
	spawn(0.1 SECONDS)
		set_light(3, 3,"#f0e2c9")
		pingpads()
		spawn(0.1 SECONDS)
			set_light(1, 1,"#110f0c")

/obj/machinery/kaos/cargo_machine/proc/resetlightping()
	spawn(0.12 SECONDS)
		set_light(4, 4,"#fffdfc")
		spawn(0.1 SECONDS)
			set_light(3, 3,"#ebc683")

/obj/machinery/kaos/cargo_machine/proc/get_people_on_turf(turf/T)
	// Initialize an empty list to hold the objects
	var/list/people_on_turf = list()

	// Loop through the contents of the turf
	for (var/mob/living/carbon/A in T)
		// Add each object to the list
		people_on_turf += A

	// Return the list of objects
	return people_on_turf

/obj/machinery/kaos/cargo_machine/proc/reconnectpads()
	pads = list()
	for(var/obj/structure/cargo_pad/pad in world)
		if (pad.id == src.id && !pad.broken)
			pads += pad

/obj/machinery/kaos/cargo_machine/New() // temporary(?)
	if(id)
		GLOB.faction_dosh[id] = 500
	reconnectpads()
	setup_sound()

/obj/machinery/kaos/cargo_machine/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = 1)

	var/sound/audio = sound('sound/effects/pc_idle.ogg')
	audio.repeat = TRUE
	audio.volume = 3
	sound_emitter.add(audio, "idle")

	sound_emitter.play("idle") // <3

/*
/obj/machinery/kaos/cargo_machine/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/spacecash))
		var/obj/item/spacecash/dolla = O
		if(dolla.worth <= 0)
			to_chat(user, "\icon[src]You cannot insert that into the machine.")
			playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		else
			to_chat(user, "\icon[src]You insert [O.name] into the machine.")
			playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
			GLOB.faction_dosh[id] += dolla.worth
			qdel(O)
	else if(istype(O, /obj/item/stack/teeth))
		var/obj/item/stack/teeth/toof = O
		if(toof.amount <= 0)
			qdel(toof) // no you dont get to insert 0 teeth for cash.
			return
		var/to_grant = 0
		for(var/i = 1, i <= toof.amount, i++)
			to_grant += 2
		qdel(toof)
		GLOB.faction_dosh[id] += to_grant
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return
	else if(istype(O, /obj/item/clothing/head/helmet/redhelmet) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/bluehelmet) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 35
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/card/id/dog_tag/red) && id == BLUE_TEAM || istype(O, /obj/item/card/id/dog_tag/blue) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 40
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/head/helmet/sentryhelm/red) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/sentryhelm/blue) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 150
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/head/helmet/redhelmet/fire) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/bluehelmet/fire) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 250
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/head/warfare_officer/redofficer) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/warfare_officer/blueofficer) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 500
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/melee/classic_baton/factionbanner/red) && id == BLUE_TEAM || istype(O, /obj/item/melee/classic_baton/factionbanner/blue) && id == RED_TEAM ) // JACKPOT!!!
		GLOB.faction_dosh[id] += 750
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/accessory/medal/red) && id == BLUE_TEAM || istype(O, /obj/item/clothing/accessory/medal/blue) && id == RED_TEAM )
		GLOB.faction_dosh[id] += 200
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return
*/

/obj/machinery/kaos/cargo_machine/attack_hand(mob/living/user as mob) // notice: find a way to sync both versions without having them be duplicates // Done, ignore this notice
	var/machine_input
	if(!CanPhysicallyInteract(user))
		return
	if (useable)
		set_light(3, 3,"#ebc683")
		machine_input = input(user, "CARGO MACHINE.") as null|anything in INPUTS
	else if (!useable)
		to_chat(user, "\icon[src]The machine is currently busy processing something..")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.3)
	if(machine_input == "CHECK BALANCE" && useable)
		if(GLOB.faction_dosh[id] > 0)
			playsound(src, "keyboard_sound", 100, 1)
			to_chat(user, "\icon[src]The machine has [GLOB.faction_dosh[id]] credits.")
			playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)
		else
			to_chat(user, "\icon[src]The machine has no credits.")
			playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)
	else if(machine_input == "BROWSE CATALOG" && useable)
		if(!pads)
			to_chat(user, "\icon[src]ERROR. NO LINKED CARGO PADS. REESTABLISH CONNECTION AND TRY AGAIN.")
			playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		else if(pads.len > 0)
			playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
			var/list/CATEGORY_INPUTS = list()
			for(var/category in categories)
				CATEGORY_INPUTS += "- [category]"
			var/selected_category = input(user, "CHOOSE A CATEGORY TO BROWSE.") as null|anything in CATEGORY_INPUTS
			if(selected_category=="- Artillery")
				playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
				var/line_input = sanitize(input(user, "ENTER LOGIN.", "[name]", "")) // remove hint when we're done
				line_input = sanitize(line_input)
				if(!line_input)
					to_chat(user, "\icon[src]You must enter the password to proceed.")
					playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
					set_light(0)
				else
					if(line_input == GLOB.cargo_password)
						playsound(src, "switch_sound", 100, 1)
						to_chat(user, "\icon[src]Welcome, <span class='warning'>Captain</span>.")
						playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)
						var/x_input = input(user, "Please input the X coordinate.") as num
						if(x_input)
							playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
							var/y_input = input(user, "Please input the Y coordinate.") as num
							var/costofartillery = 550 // shitty way to go about it. redo this someday.
							if(y_input && GLOB.faction_dosh[id] >= costofartillery && CanPhysicallyInteract(user))
								var/turf/turf_to_drop = locate(x_input,y_input,2)
								if(istype(turf_to_drop.loc, /area/warfare/battlefield/no_mans_land) || istype(turf_to_drop.loc, /area/warfare/battlefield/capture_point/mid))
									playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
									to_chat(user, "\icon[src]<span class='danger'>ENGAGING ARTILLERY FIRE AT LOCATION: \n\icon[src]X coordinate[x_input], Y coordinate [y_input].\n")
									to_chat(world, uppertext("<font size=5><b>INCOMING!! NO MAN'S LAND!!</b></font>"))
									for(var/obj/machinery/light/l in GLOB.lights)
										if(!prob(7)) continue
										l.flicker()
									spawn(1 SECOND)
										for(var/i = 1, i<3, i++) // it sounds nicer when its delayed.
											sound_to(world, 'sound/effects/arty_distant.ogg')
											sleep(50)
									GLOB.faction_dosh[id] -= costofartillery
									playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
									spawn(8 SECONDS)
										artillery_barage(x_input,y_input,2) // artillery used console cords so unfortunate cap was blown to smithereens with his own artillery barrage
								else
									playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
									to_chat(user, "\icon[src]The coordinates were invalid, <span class='warning'>Captain</span>.")
									set_light(0)
							else if(y && GLOB.faction_dosh[id] < costofartillery)
								playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
								to_chat(user, "\icon[src]You are unable to afford an artillery strike, <span class='warning'>Captain</span>.")
								set_light(0)
							else if(!y)
								playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
								to_chat(user, "\icon[src]Please input the Y coordinate</span>.")
								set_light(0)
						else
							playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
							to_chat(user, "\icon[src]Please input the X coordinate.")
							set_light(0)
						//var/machine_input = input(user, "CARGO MACHINE.") as null|anything in INPUTS // Figure out how to make this work without breaking the machine
					else
						to_chat(user, "\icon[src]Incorrect password provided.")
						playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
						set_light(0)
			else if(selected_category && useable)
				playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
				var/list/PRODUCT_INPUTS = list()
				for(var/product in products)
					if("- " + product["category"] == selected_category)
						PRODUCT_INPUTS += "- [product["name"]] -- [product["price"]] credits"
				PRODUCT_INPUTS += "-- Return --"
				var/selected_product = input(user, "CHOOSE A PRODUCT TO PURCHASE.") as null|anything in PRODUCT_INPUTS
				//to_chat(user, "\icon[src]PRODUCTS: [products]") // broken devmsg
				if((selected_product=="-- Return --") && useable)
					playsound(src.loc, "sound/machines/rpf/UI_labelselect.ogg", 100, 0.15)
				else if(selected_product && useable && CanPhysicallyInteract(user))
					playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
					var/pos1 = findtext(selected_product, "- ") + 2
					var/pos2 = findtext(selected_product, " --")
					var/productname = copytext(selected_product, pos1, pos2)
					var/product
					for(var/p in products)
						if(p["name"] == productname)
							product = p
							break
					productname = product["name"]
					var/productprice = product["price"]
					var/productpath = product["path"]
					var/productwill_contain
					if(product["willcontain"])
						productwill_contain = product["willcontain"]
					var/turf/pickedloc
					var/list/clear_turfs = list()
					var/obj/structure/cargo_pad/pickedpad
					if(useable && selected_category == "- Units")
						if(productprice <= GLOB.faction_dosh[id])
							if(productname == "Reinforcements")
								/*
								if(id == BLUE_TEAM)
									var/newcount = SSwarfare.blue.left + 5
									SSwarfare.blue.left = newcount
									playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
									GLOB.faction_dosh[id] -= productprice
									return
								if(id == RED_TEAM)
									var/newcount = SSwarfare.red.left + 5
									SSwarfare.red.left = newcount
									playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
									GLOB.faction_dosh[id] -= productprice
									return
								else
									playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
									GLOB.faction_dosh[id] -= productprice
									return
								*/
								to_chat(user, SPAN_YELLOW("\icon[src]You have been barred from further purchases of reinforcements\n\n\icon[src]Please consult a technician if you believe this decision was made in error."))
								playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
								return
							else
								playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
								var/datum/job/team_job = SSjobs.GetJobByType(productpath) //Open up the corresponding job on that team.
								if(team_job.total_positions < 1)//You can only buy a guy if he's not dead.
									SSjobs.allow_one_more(team_job.title)
									GLOB.faction_dosh[id] -= productprice
								else
									playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
									to_chat(user, "\icon[src]There are no more units available to send at the moment.")
								return
						else
							to_chat(user, "\icon[src]You lack the required funding to purchase this product.")
							playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
							return
					//var/list/cargoturfs = list()
				//	var/hasdenseobject
					if(productprice <= GLOB.faction_dosh[id]) // This shitcode works! Checks for dense objects on the turf!
						reconnectpads() // let's be cheeky and silently reocnnect it just incase one got deleted
						for(var/obj/structure/cargo_pad/pad in pads)
							if(get_dense_objects_on_turf(get_turf(pad)).len <= 0)
								clear_turfs += pad
							else
								continue
						pickedpad = pick(clear_turfs)
						pickedloc = get_turf(pickedpad)
					if(!clear_turfs)
						to_chat(user, "\icon[src]ERROR. ALL PADS OCCUPIED. MAKE SPACE AND TRY AGAIN.")
						playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
						return
					if(!pads) // if this somehow were to happen id be in awe.
						to_chat(user, "\icon[src]ERROR. NO LINKED CARGO PADS. REESTABLISH CONNECTION AND TRY AGAIN.")
						playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
						return
					else if(productprice <= GLOB.faction_dosh[id])
						useable = FALSE
						playsound(src.loc, 'sound/machines/rpf/cargo_starttp.ogg', 100, 0)
						spawn(2.2 SECONDS)
						//	pad.lightup()
							pickedpad.isselected()
							var/obj/glowobj = new /obj/effect/overlay/cargopadglow(pickedloc)
							playsound(pickedpad.loc, 'sound/machines/rpf/cargo_endtp.ogg', 200, 0)
							spawn(2.65 SECONDS)
								var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
								sparks.set_up(3, 0, pickedloc)
								sparks.start()
								pickedpad.isselectedbrighter()
								var/list/togib = get_people_on_turf(get_turf(pickedpad))
								var/spawn_gibs = FALSE
								for(var/mob/gibthisguy in togib)
									if(gibthisguy.resting)
										log_and_message_admins("[gibthisguy] has <span class='danger'>gibbed themselves</span> on the following cargo pad: [pickedpad]!")
										gibthisguy.gib()
									else
										if(ishuman(gibthisguy))
											var/mob/living/carbon/human/leg_removal = gibthisguy
											var/obj/item/organ/external/L = leg_removal.get_organ(BP_L_LEG)
											var/obj/item/organ/external/R = leg_removal.get_organ(BP_R_LEG)
											if(L)
												L.droplimb()
											if(R)
												R.droplimb()
											new/obj/effect/gibspawner/human(get_turf(pickedpad))
											spawn_gibs = TRUE
								if(spawn_gibs)
									new/obj/effect/gibspawner/human(get_turf(pickedpad))
								var/to_spawn = product["path"]
								var/obj/A = new to_spawn(pickedloc)
								A.desc = "A [productname] crate."
								A.name = "[productname] crate"
								if(productwill_contain) // hopefully this will prevent runtimes
									create_objects_in_loc(A, productwill_contain)
							spawn(2.7 SECONDS)
								pickedpad.isselected()
					//				pad.lightdown()
						//A.SetName("[productname]")
								GLOB.faction_dosh[id] -= productprice
								spawn(0.1 SECONDS)
									qdel(glowobj)
									pickedpad.isdeselected()
								playsound(src.loc, 'sound/machines/rpf/transcriptprint.ogg', 90, 0)
								spawn(2 SECONDS)
									resetlightping()
									playsound(src.loc, 'sound/machines/rpf/ChatMsg.ogg', 100, 0)
									useable = TRUE

					else if(productprice > GLOB.faction_dosh[id])
						to_chat(user, "\icon[src]Insufficient funds to purchase [product["name"]].")
						playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
						return 0
					else if(clear_turfs.len <= 0)
						to_chat(user, "\icon[src]No space to drop off [product["name"]].")
						playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
						return
					else if(pickedloc == null)
						to_chat(user, "\icon[src]FATAL ERROR.")
						return
					else//I know these returns aren't needed they just make me feel better ok? Fuck you.
						to_chat(user, "\icon[src]An UNKNOWN error has occured.")
						return


/obj/machinery/kaos/cargo_machine/red
	name = "R.E.D. Cargo Machine"
	id = RED_TEAM
	products = list(
		// general ammo stuff
		list("name" = "Rifle Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/rifle = 10)),
		list("name" = "Modern Rifle Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/rifle/modern = 10)),
		//list("name" = "M41 Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/a762/m14 = 5)),
		list("name" = "Shotgun Ammo Pack", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/shotgun = 10)),
		list("name" = "Pistol Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/c45m/warfare = 10, /obj/item/ammo_magazine/a50 = 5)),
		list("name" = "Revolver Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/handful/revolver = 10)),
		//list("name" = "Soulburn Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/mc9mmt/machinepistol = 10)),
		list("name" = "HMG Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/box/a556/mg08 = 5)),
		list("name" = "Old LMG Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/c45rifle/flat = 5)),
		list("name" = "Armageddon Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/a762/m14/battlerifle_mag = 3, /obj/item/ammo_magazine/a762/rsc = 3)),
		list("name" = "Warcrime Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/autoshotty = 5)),
		list("name" = "Warmonger Ammo", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/c45rifle/akarabiner = 10)),
		list("name" = "Flamethrower Ammo Pack", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/flamer = 5)),
		list("name" = "PTSD Ammo Pack", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/ptsd = 5)),
		list("name" = "Mortar Ammo", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_shell = 8)),

		// general weapon stuff
		list("name" = "Shotgun Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/shotgun/pump/shitty = 5)),
		list("name" = "Golt Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/golt = 2)),
		list("name" = "Pistol Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/warfare = 3)),
		list("name" = "Harbinger Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/automatic/mg08 = 2)),
		list("name" = "Warmonger Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/automatic/m22/warmonger = 10)),
		list("name" = "Shovel Pack", "price" = 50, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/shovel = 5)),
		list("name" = "Doublebarrel Shotgun Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/shotgun/doublebarrel = 5)),
		list("name" = "Bolt Action Rifle Pack", "price" = 50, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty/leverchester = 10)),
		//list("name" = "Soulburn Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/automatic/machinepistol/wooden = 5)),
		list("name" = "Flamethrower Pack", "price" = 200, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/automatic/flamer = 1, /obj/item/ammo_magazine/flamer = 2)),
		list("name" = "Frag Grenade Pack", "price" = 350, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/grenade/frag/warfare = 5)),
		list("name" = "Trench Club Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/melee/classic_baton/trench_club = 5)),
		list("name" = "Trenchman Revolver Pack", "price" = 200, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/revolver/manual/ = 5)),
		list("name" = "Mortar Pack", "price" = 800, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/mortar_launcher = 2, /obj/item/mortar_shell = 6)),

		// medical and supply stuff
		list("name" = "Gas Mask Pack", "price" = 50, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/clothing/mask/gas/sniper/penal1 = 10)),
		list("name" = "Barbwire Pack", "price" = 50, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/stack/barbwire = 5)),
		list("name" = "Canned Food Pack", "price" = 20, "category" = "ChowField Provisions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/random/canned_food/red = 10)),
		list("name" = "Bodybag Pack", "price" = 5, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/medical, "willcontain" = list(/obj/item/storage/box/bodybags = 3)),
		list("name" = "Cigarette Pack", "price" = 50, "category" = "ChowField Provisions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/storage/fancy/cigarettes = 10)),
		list("name" = "First Aid Pack", "price" = 100, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/medical, "willcontain" = list(/obj/item/storage/firstaid/regular = 5)),
		list("name" = "Advanced First Aid Pack", "price" = 200, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/medical, "willcontain" = list(/obj/item/storage/firstaid/adv = 5)),
		list("name" = "Medical Belt Pack", "price" = 50, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/medical, "willcontain" = list(/obj/item/storage/belt/medical/full = 10)),
		list("name" = "Booze Pack", "price" = 100, "category" = "ChowField Provisions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/random/drinkbottle = 8)),
		list("name" = "Atepoine Pack", "price" = 50, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/medical, "willcontain" = list(/obj/item/reagent_containers/hypospray/autoinjector/revive = 10)),
		list("name" = "Smoke Grenade Pack", "price" = 150, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/grenade/smokebomb = 5)),
		list("name" = "Plastic Explosives Pack", "price" = 150, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/plastique/red = 5)),
		list("name" = "Prosthetic Limbs Pack", "price" = 200, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/medical, "willcontain" = list(/obj/item/organ/external/arm/robo_arm = 2, /obj/item/organ/external/arm/right/robo_arm = 2,
			/obj/item/organ/external/hand/robo_hand = 2, /obj/item/organ/external/hand/right/robo_hand = 2, /obj/item/organ/external/leg/robo_leg = 2, /obj/item/organ/external/leg/right/robo_leg = 2,
			/obj/item/organ/external/foot/robo_foot = 2, /obj/item/organ/external/foot/right/robo_foot = 2)),
		list("name" = "Blood Injector Pack", "price" = 50, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/reagent_containers/hypospray/autoinjector/blood = 10)),
		//list("name" = "Trench Bridge Pack", "price" = 150, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/grenade_box/trench_bridge = 2)),


		// team stuff
		list("name" = "Illumination Mortar Ammo (Red)", "price" = 300, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_shell/flare = 8)),
//		list("name" = "Illumination Mortar Ammo (Blue)", "price" = 300, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_shell/flare/blue = 8)),

	// warfunits

		list("name" = "Red sniper", "price" = 500, "category" = "Units", "path" = /datum/job/soldier/red_soldier/sniper),
		list("name" = "Red flamer", "price" = 1000, "category" = "Units", "path" = /datum/job/soldier/red_soldier/flame_trooper),
		list("name" = "Red sentry", "price" = 750, "category" = "Units", "path" = /datum/job/soldier/red_soldier/sentry),
		list("name" = "Reinforcements", "price" = 750, "category" = "Units", "path" = "none")
	)

/obj/machinery/kaos/cargo_machine/blue
	name = "B.L.U.E. Cargo Machine"
	id = BLUE_TEAM
	products = list(
		// general ammo stuff
		list("name" = "Rifle Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/rifle = 10)),
		list("name" = "Modern Rifle Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/rifle/modern = 10)),
		//list("name" = "M41 Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/a762/m14 = 5)),
		list("name" = "Shotgun Ammo Pack", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/shotgun = 10)),
		list("name" = "Pistol Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/c45m/warfare = 10, /obj/item/ammo_magazine/a50 = 5)),
		list("name" = "Revolver Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/handful/revolver = 10)),
		//list("name" = "Soulburn Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/mc9mmt/machinepistol = 10)),
		list("name" = "HMG Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/box/a556/mg08 = 5)),
		list("name" = "Old LMG Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/c45rifle/flat = 5)),
		list("name" = "Armageddon Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/a762/m14/battlerifle_mag = 3, /obj/item/ammo_magazine/a762/rsc = 3)),
		list("name" = "Warcrime Ammo Pack", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/autoshotty = 5)),
		list("name" = "Warmonger Ammo", "price" = 50, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/c45rifle/akarabiner = 10)),
		list("name" = "Flamethrower Ammo Pack", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_magazine/flamer = 5)),
		list("name" = "PTSD Ammo Pack", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/ammo_box/ptsd = 5)),
		list("name" = "Mortar Ammo", "price" = 100, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_shell = 8)),

		// general weapon stuff
		list("name" = "Shotgun Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/shotgun/pump/shitty = 5)),
		list("name" = "Golt Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/golt = 2)),
		list("name" = "Pistol Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/secure/weapon, "willcontain" = list(/obj/item/gun/projectile/warfare = 3)),
		list("name" = "Harbinger Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/automatic/mg08 = 2)),
		list("name" = "Warmonger Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/automatic/m22/warmonger = 10)),
		list("name" = "Shovel Pack", "price" = 50, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/shovel = 5)),
		list("name" = "Doublebarrel Shotgun Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/shotgun/doublebarrel = 5)),
		list("name" = "Bolt Action Rifle Pack", "price" = 50, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/shotgun/pump/boltaction/shitty = 10)),
		//list("name" = "Soulburn Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/automatic/machinepistol = 5)),
		list("name" = "Flamethrower Pack", "price" = 200, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/automatic/flamer = 1, /obj/item/ammo_magazine/flamer = 2)),
		list("name" = "Frag Grenade Pack", "price" = 350, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/grenade/frag/warfare = 5)),
		list("name" = "Trenchman Revolver Pack", "price" = 200, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/gun/projectile/revolver/manual/ = 5)),
		list("name" = "Trench Club Pack", "price" = 100, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/melee/classic_baton/trench_club = 5)),
		list("name" = "Mortar Pack", "price" = 800, "category" = "Brass.Co Top-Brass", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_launcher = 2, /obj/item/mortar_shell = 6)),

		// medical and supply stuff
		list("name" = "Gas Mask Pack", "price" = 50, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/clothing/mask/gas/sniper/penal3 = 10)),
		list("name" = "Barbwire Pack", "price" = 50, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/stack/barbwire = 5)),
		list("name" = "Canned Food Pack", "price" = 20, "category" = "ChowField Provisions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/random/canned_food/blue = 10)),
		list("name" = "Bodybag Pack", "price" = 5, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/storage/box/bodybags = 3)),
		list("name" = "Cigarette Pack", "price" = 50, "category" = "ChowField Provisions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/storage/fancy/cigarettes = 10)),
		list("name" = "First Aid Pack", "price" = 100, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/storage/firstaid/regular = 5)),
		list("name" = "Advanced First Aid Pack", "price" = 200, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/storage/firstaid/adv = 5)),
		list("name" = "Medical Belt Pack", "price" = 50, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/storage/belt/medical/full = 10)),
		list("name" = "Booze Pack", "price" = 100, "category" = "ChowField Provisions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/random/drinkbottle = 8)),
		list("name" = "Atepoine Pack", "price" = 50, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/reagent_containers/hypospray/autoinjector/revive = 10)),
		list("name" = "Blood Injector Pack", "price" = 50, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/reagent_containers/hypospray/autoinjector/blood = 10)),
		list("name" = "Prosthetic Limbs Pack", "price" = 200, "category" = "Daisy's Panacea", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/organ/external/arm/robo_arm = 2, /obj/item/organ/external/arm/right/robo_arm = 2,
			/obj/item/organ/external/hand/robo_hand = 2, /obj/item/organ/external/hand/right/robo_hand = 2, /obj/item/organ/external/leg/robo_leg = 2, /obj/item/organ/external/leg/right/robo_leg = 2,
			/obj/item/organ/external/foot/robo_foot = 2, /obj/item/organ/external/foot/right/robo_foot = 2)),
		list("name" = "Smoke Grenade Pack", "price" = 150, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/grenade/smokebomb = 5)),
		list("name" = "Plastic Explosives Pack", "price" = 150, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/plastique/blue = 5)),
		//list("name" = "Trench Bridge Pack", "price" = 150, "category" = "Sil's Utility Corps", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/grenade_box/trench_bridge = 2)),

		// team stuff
//		list("name" = "Illumination Mortar Ammo (Red)", "price" = 300, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_shell/flare = 8)),
		list("name" = "Illumination Mortar Ammo (Blue)", "price" = 300, "category" = "Brass.Co Ammunitions", "path" = /obj/structure/closet/crate/wooden, "willcontain" = list(/obj/item/mortar_shell/flare/blue = 8)),

		list("name" = "Blue sniper", "price" = 500, "category" = "Units", "path" = /datum/job/soldier/blue_soldier/sniper),
		list("name" = "Blue flamer", "price" = 1000, "category" = "Units", "path" = /datum/job/soldier/blue_soldier/flame_trooper),
		list("name" = "Blue sentry", "price" = 750, "category" = "Units", "path" = /datum/job/soldier/blue_soldier/sentry),
		list("name" = "Reinforcements", "price" = 750, "category" = "Units", "path" = "none"),
	)

/obj/effect/overlay/cargopadglow
	name = "Cargo Pad"
	desc = "Huh... I wonder what this does.."
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "portal"
	density = 0
//	plane = ABOVE_OBJ_PLANE
	plane = WALL_PLANE
//	layer = ABOVE_OBJ_LAYER
	anchored = 1

//Just for looks, it shows off nicely where the cargo will be dropped off.
/obj/structure/cargo_pad
	name = "Cargo Pad"
	desc = "Papa said that I shouldn't stand on this when it lights up.."
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "cargo_pad"
	density = FALSE
	unacidable = TRUE
	anchored = TRUE
	plane = WALL_PLANE
	var/id
	var/broken = FALSE
	var/lvl1_color = "#e26868"
	var/lvl2_color = "#e26868"

GLOBAL_LIST_EMPTY(cargo_pads)

/obj/structure/cargo_pad/New()
	setup_sound()
	sleep(50)
	if(!id || broken)
		return
	if(!GLOB.cargo_pads[id])
		GLOB.cargo_pads[id] = list()
		var/list/agh = GLOB.cargo_pads[id]
		agh += src

/obj/structure/cargo_pad/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = 1)

	var/sound/audio = sound('sound/effects/cargopad_idle.ogg')
	audio.repeat = TRUE
	audio.volume = 1
	sound_emitter.add(audio, "idle")

	sound_emitter.play("idle") // <3

proc/get_dense_objects_on_turf(turf/T)
	var/list/dense_objects_on_turf = list()

	for (var/obj/A in T)
		if(A.density | istype(A, /obj/structure/closet) | istype(A, /mob/living/carbon))
			dense_objects_on_turf += A

	return dense_objects_on_turf

/obj/structure/cargo_pad/proc/isselected()
	set_light(2, 1, lvl1_color)

/obj/structure/cargo_pad/proc/get_people_on_turf(turf/T)
	var/list/people_on_turf = list()

	for (var/mob/living/carbon/A in T)
		people_on_turf += A

	return people_on_turf

/obj/structure/cargo_pad/proc/handle_spawn(var/datum/snowflake_supply/selected)
	playsound(src.loc, 'sound/machines/rpf/cargo_starttp.ogg', 100, 0)
	sleep(2.2 SECONDS)
	//	pad.lightup()
	isselected()
	var/obj/glowobj = new /obj/effect/overlay/cargopadglow(loc)
	playsound(loc, 'sound/machines/rpf/cargo_endtp.ogg', 200, 0)
	sleep(2.65 SECONDS)
	var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
	sparks.set_up(3, 0, loc)
	sparks.start()
	selected.Spawn(loc)
	qdel(glowobj)
	isselectedbrighter()
	var/list/togib = get_people_on_turf(loc)
	var/spawn_gibs = FALSE
	for(var/mob/gibthisguy in togib)
		if(gibthisguy.resting)
			log_and_message_admins("[gibthisguy] has <span class='danger'>gibbed themselves</span> on the following cargo pad: [src]!")
			gibthisguy.gib()
		else
			if(ishuman(gibthisguy))
				var/mob/living/carbon/human/leg_removal = gibthisguy
				var/obj/item/organ/external/L = leg_removal.get_organ(BP_L_LEG)
				var/obj/item/organ/external/R = leg_removal.get_organ(BP_R_LEG)
				if(L)
					L.droplimb()
				if(R)
					R.droplimb()
				new/obj/effect/gibspawner/human(loc)
				spawn_gibs = TRUE
	if(spawn_gibs)
		new/obj/effect/gibspawner/human(loc)
	return TRUE

/obj/structure/cargo_pad/proc/isselectedbrighter()
	set_light(3, 1,lvl2_color)

/obj/structure/cargo_pad/proc/isdeselected()
	set_light(0)

/obj/structure/cargo_pad/proc/pingpad()
	set_light(1, 1, lvl1_color)
	var/obj/glowobj = new /obj/effect/overlay/cargopadglow(src.loc)
	playsound(loc,'sound/machines/rpf/UImsg.ogg', 45, 0)
	spawn(1)
		qdel(glowobj)
		set_light(0)

/obj/structure/cargo_pad/ex_act()
	return

/obj/structure/cargo_pad/red
	id = RED_TEAM

/obj/structure/cargo_pad/blue
	id = BLUE_TEAM

/obj/structure/cargo_pad/red/captain
	id = "Redcoats_C"

/obj/structure/cargo_pad/bue/captain
	id = "Bluecoats_C"