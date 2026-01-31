


	



/obj/structure/closet/crate/scuffedcargo/ 
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
	var/credits 
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
	var/list/products = list()
	var/list/categories = list()

/obj/machinery/kaos/cargo_machine/proc/get_available_products()
	var/list/all_decls = decls_repository.get_decls_of_subtype(/decl/cargo_product)
	var/list/available = list()
	for(var/type in all_decls)
		var/decl/cargo_product/P = all_decls[type]
		if(!istype(P) || istype(P, /decl/cargo_product/train))
			continue
		
		if(P.type == /decl/cargo_product || P.type == /decl/cargo_product/job || P.type == /decl/cargo_product/crate)
			continue
		if(P.name == "Unknown Product")
			continue
		if(!P.faction_id || P.faction_id == id)
			available += P
	return available

/obj/machinery/kaos/cargo_machine/proc/update_categories()
	categories = list()
	var/list/avail = get_available_products()
	for(var/decl/cargo_product/P in avail)
		categories |= P.category
	categories |= "Artillery"

/obj/machinery/kaos/cargo_machine/RightClick(mob/user)
	return 

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
	playsound(src.loc, "sound/machines/rpf/barotraumastuff/UI_labelselect.ogg", 75, 0.2) 
	to_chat(user, "\icon[src]RE-ESTABLISHING CONNECTION... PLEASE WAIT..")
	spawn(2 SECONDS)
		playsound(src.loc, 'sound/machines/rpf/beepsound1.ogg', 60, 0)
		pinglight()
		spawn(2 SECONDS)
			useable = TRUE
			set_light(3, 3,"#ebc683")
			if (pads.len < 0 | pads.len == null | pads.len == 0) 
				set_light(3, 3,"#ebc683")
				to_chat(src, "\icon[src]ERROR. NO CARGO PADS LOCATED. CONTACT YOUR SUPERIOR OFFICER.")
				playsound(src.loc, 'sound/machines/rpf/harshdeny.ogg', 250, 0.5)
				to_chat(user, "\icon[src]AMOUNT OF LINKED PADS: [pads.len]")
			else
				playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 250, 0.5)
				to_chat(src, "\icon[src]LINK ESTABLISHED SUCCESSFULLY.")
				to_chat(user, "\icon[src]AMOUNT OF LINKED PADS: [pads.len]")

/obj/machinery/kaos/cargo_machine/proc/get_objects_on_turf(turf/T)
	
	var/list/objects_on_turf = list()

	
	for (var/obj/A in T)
		
		objects_on_turf += A

	
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
	
	var/list/people_on_turf = list()

	
	for (var/mob/living/carbon/A in T)
		
		people_on_turf += A

	
	return people_on_turf

/obj/machinery/kaos/cargo_machine/proc/reconnectpads()
	pads = list()
	for(var/obj/structure/cargo_pad/pad in world)
		if (pad.id == src.id && !pad.broken)
			pads += pad

/obj/machinery/kaos/cargo_machine/New() 
	reconnectpads()
	update_categories()
	setup_sound()

/obj/machinery/kaos/cargo_machine/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = 1)

	var/sound/audio = sound('sound/effects/pc_idle.ogg')
	audio.repeat = TRUE
	audio.volume = 3
	sound_emitter.add(audio, "idle")

	sound_emitter.play("idle") 

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
			qdel(toof) 
			return
		var/to_grant = 0
		for(var/i = 1, i <= toof.amount, i++)
			to_grant += 2
		qdel(toof)
		GLOB.faction_dosh[id] += to_grant
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return
	else if(istype(O, /obj/item/clothing/head/helmet/redhelmet) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/bluehelmet) && id == RED_TEAM ) 
		GLOB.faction_dosh[id] += 35
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/card/id/dog_tag/red) && id == BLUE_TEAM || istype(O, /obj/item/card/id/dog_tag/blue) && id == RED_TEAM ) 
		GLOB.faction_dosh[id] += 40
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/head/helmet/sentryhelm/red) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/sentryhelm/blue) && id == RED_TEAM ) 
		GLOB.faction_dosh[id] += 150
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/head/helmet/redhelmet/fire) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/bluehelmet/fire) && id == RED_TEAM ) 
		GLOB.faction_dosh[id] += 250
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/clothing/head/warfare_officer/redofficer) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/warfare_officer/blueofficer) && id == RED_TEAM ) 
		GLOB.faction_dosh[id] += 500
		qdel(O)
		playsound(user.loc, 'sound/machines/rpf/audiotapein.ogg', 50, 0.4)
		return

	else if(istype(O, /obj/item/melee/classic_baton/factionbanner/red) && id == BLUE_TEAM || istype(O, /obj/item/melee/classic_baton/factionbanner/blue) && id == RED_TEAM ) 
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

/obj/machinery/kaos/cargo_machine/attack_hand(mob/living/user as mob)
	if(!CanPhysicallyInteract(user))
		return

	if(!useable)
		to_chat(user, "\icon[src]The machine is currently busy processing something..")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.3)
		return

	set_light(3, 3, "#ebc683")
	var/machine_input = input(user, "CARGO MACHINE.") as null|anything in INPUTS
	if(!machine_input || !useable || !CanPhysicallyInteract(user))
		return

	switch(machine_input)
		if("CHECK BALANCE")
			display_balance(user)
		if("BROWSE CATALOG")
			browse_catalog(user)

/obj/machinery/kaos/cargo_machine/proc/display_balance(mob/user)
	playsound(src, "keyboard_sound", 100, 1)
	if(GLOB.faction_dosh[id] > 0)
		to_chat(user, "\icon[src]The machine has [GLOB.faction_dosh[id]] credits.")
	else
		to_chat(user, "\icon[src]The machine has no credits.")
	playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)

/obj/machinery/kaos/cargo_machine/proc/browse_catalog(mob/user)
	if(!pads || !pads.len)
		to_chat(user, "\icon[src]ERROR. NO LINKED CARGO PADS. REESTABLISH CONNECTION AND TRY AGAIN.")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		return

	update_categories()
	var/list/CATEGORY_INPUTS = list()
	for(var/category in categories)
		CATEGORY_INPUTS["- [category]"] = category
	
	var/selected_category_text = input(user, "CHOOSE A CATEGORY TO BROWSE.") as null|anything in CATEGORY_INPUTS
	if(!selected_category_text || !useable || !CanPhysicallyInteract(user))
		return
	
	var/selected_category = CATEGORY_INPUTS[selected_category_text]

	if(selected_category == "Artillery")
		handle_artillery_menu(user)
	else
		purchase_product(user, selected_category)

/obj/machinery/kaos/cargo_machine/proc/handle_artillery_menu(mob/user)
	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	var/line_input = sanitize(input(user, "ENTER LOGIN.", "[name]", ""))
	if(!line_input || !useable || !CanPhysicallyInteract(user))
		set_light(0)
		return

	if(line_input != GLOB.cargo_password)
		to_chat(user, "\icon[src]Incorrect password provided.")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		set_light(0)
		return

	playsound(src, "switch_sound", 100, 1)
	to_chat(user, "\icon[src]Welcome, <span class='warning'>Captain</span>.")
	playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)

	if(!useable || !CanPhysicallyInteract(user))
		return

	var/x_input = input(user, "Please input the X coordinate.") as num
	if(!x_input || !useable || !CanPhysicallyInteract(user))
		return

	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	var/y_input = input(user, "Please input the Y coordinate.") as num
	if(!y_input || !useable || !CanPhysicallyInteract(user))
		return

	var/target_x = x_input
	var/target_y = y_input

	target_x -= SSwarfare.coord_offset_x
	target_y -= SSwarfare.coord_offset_y

	var/costofartillery = 550
	if(GLOB.faction_dosh[id] < costofartillery)
		to_chat(user, "\icon[src]You are unable to afford an artillery strike, <span class='warning'>Captain</span>.")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		set_light(0)
		return

	var/turf/turf_to_drop = locate(target_x, target_y, 2)
	if(!turf_to_drop || !(istype(turf_to_drop.loc, /area/warfare/battlefield/no_mans_land) || istype(turf_to_drop.loc, /area/warfare/battlefield/capture_point/mid)))
		to_chat(user, "\icon[src]The coordinates were invalid, <span class='warning'>Captain</span>.")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		set_light(0)
		return

	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	to_chat(user, "\icon[src]<span class='danger'>ENGAGING ARTILLERY FIRE AT LOCATION: \n\icon[src]X coordinate [target_x], Y coordinate [target_y].\n")
	to_chat(world, uppertext("<font size=5><b>INCOMING!! NO MAN'S LAND!!</b></font>"))
	
	for(var/obj/machinery/light/l in GLOB.lights)
		if(prob(7))
			l.flicker()

	spawn(1 SECOND)
		for(var/i = 1 to 2)
			sound_to(world, 'sound/effects/arty_distant.ogg')
			sleep(5 SECONDS)

	GLOB.faction_dosh[id] -= costofartillery
	playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
	
	spawn(8 SECONDS)
		artillery_barage(target_x, target_y, 2)

/obj/machinery/kaos/cargo_machine/proc/purchase_product(mob/living/user, selected_category)
	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	var/list/PRODUCT_INPUTS = list()
	var/list/avail = get_available_products()
	for(var/decl/cargo_product/P in avail)
		if(P.category == selected_category)
			PRODUCT_INPUTS["- [P.name] -- [P.price] credits"] = P

	PRODUCT_INPUTS["-- Return --"] = null
	var/selected_product_text = input(user, "CHOOSE A PRODUCT TO PURCHASE.") as null|anything in PRODUCT_INPUTS
	
	if(!selected_product_text || selected_product_text == "-- Return --" || !useable || !CanPhysicallyInteract(user))
		return

	var/decl/cargo_product/P = PRODUCT_INPUTS[selected_product_text]
	if(!P)
		return

	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)

	if(P.price > GLOB.faction_dosh[id])
		to_chat(user, "\icon[src]You lack the required funding to purchase this product.")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		return

	if(istype(P, /decl/cargo_product/job))
		if(P.name == "Reinforcements")
			to_chat(user, SPAN_YELLOW("\icon[src]You have been barred from further purchases of reinforcements\n\n\icon[src]Please consult a technician if you believe this decision was made in error."))
			playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
			return
		
		var/datum/job/team_job = SSjobs.GetJobByType(P.job_path)
		if(team_job.total_positions < 1)
			SSjobs.allow_one_more(team_job.title)
			GLOB.faction_dosh[id] -= P.price
			playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
		else
			playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
			to_chat(user, "\icon[src]There are no more units available to send at the moment.")
		return

	handle_purchase_spawn(user, P)

/obj/machinery/kaos/cargo_machine/proc/handle_purchase_spawn(mob/living/user, decl/cargo_product/P)
	reconnectpads()
	var/list/clear_turfs = list()
	for(var/obj/structure/cargo_pad/pad in pads)
		if(get_dense_objects_on_turf(get_turf(pad)).len <= 0)
			clear_turfs += pad
	
	if(!clear_turfs.len)
		to_chat(user, "\icon[src]ERROR. ALL PADS OCCUPIED. MAKE SPACE AND TRY AGAIN.")
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		return

	var/obj/structure/cargo_pad/pickedpad = pick(clear_turfs)
	var/turf/pickedloc = get_turf(pickedpad)

	useable = FALSE
	playsound(src.loc, 'sound/machines/rpf/cargo_starttp.ogg', 100, 0)
	spawn(2.2 SECONDS)
		pickedpad.isselected()
		var/obj/glowobj = new /obj/effect/overlay/cargopadglow(pickedloc)
		playsound(pickedpad.loc, 'sound/machines/rpf/cargo_endtp.ogg', 200, 0)
		spawn(2.65 SECONDS)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(3, 0, pickedloc)
			sparks.start()
			pickedpad.isselectedbrighter()
			
			var/list/togib = get_people_on_turf(pickedloc)
			var/spawn_gibs = FALSE
			for(var/mob/gibthisguy in togib)
				if(gibthisguy.resting)
					log_and_message_admins("[gibthisguy] has <span class='danger'>gibbed themselves</span> on the following cargo pad: [pickedpad]!")
					gibthisguy.gib()
				else if(ishuman(gibthisguy))
					var/mob/living/carbon/human/leg_removal = gibthisguy
					var/obj/item/organ/external/L = leg_removal.get_organ(BP_L_LEG)
					var/obj/item/organ/external/R = leg_removal.get_organ(BP_R_LEG)
					if(L) L.droplimb()
					if(R) R.droplimb()
					new/obj/effect/gibspawner/human(pickedloc)
					spawn_gibs = TRUE
			if(spawn_gibs)
				new/obj/effect/gibspawner/human(pickedloc)

			var/to_spawn = P.crate_type
			var/obj/A = new to_spawn(pickedloc)
			A.desc = "A [P.name] crate."
			A.name = "[P.name] crate"
			if(P.contents)
				create_objects_in_loc(A, P.contents)
		
		spawn(2.7 SECONDS)
			pickedpad.isdeselected()
			GLOB.faction_dosh[id] -= P.price
			spawn(0.1 SECONDS)
				qdel(glowobj)
				pickedpad.isdeselected()
			playsound(src.loc, 'sound/machines/rpf/transcriptprint.ogg', 90, 0)
			spawn(2 SECONDS)
				resetlightping()
				playsound(src.loc, 'sound/machines/rpf/ChatMsg.ogg', 100, 0)
				useable = TRUE

/obj/machinery/kaos/cargo_machine/red
	name = "R.E.D. Cargo Machine"
	id = RED_TEAM

/obj/machinery/kaos/cargo_machine/blue
	name = "B.L.U.E. Cargo Machine"
	id = BLUE_TEAM

/obj/effect/overlay/cargopadglow
	name = "Cargo Pad"
	desc = "Huh... I wonder what this does.."
	icon = 'icons/obj/old_computers.dmi'
	icon_state = "portal"
	density = 0

	plane = WALL_PLANE

	anchored = 1


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

	sound_emitter.play("idle") 

proc/get_dense_objects_on_turf(turf/T)
	var/list/dense_objects_on_turf = list()

	for (var/obj/A in T)
		if(A.density | istype(A, /obj/structure/closet) | istype(A, /mob/living/carbon))
			if(istype(A, /obj/structure/window))
				var/obj/structure/window/W = A
				if(!W.is_fulltile())
					continue
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