






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
	var/list/pads
	var/id
	var/withdraw_amount
	var/line_input
	var/cooldown
	var/useable = TRUE
	var/status_message = "READY"
	var/status_error = FALSE
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

/obj/machinery/kaos/cargo_machine/proc/set_machine_status(message, is_error = FALSE)
	status_message = message
	status_error = is_error
	SSnanoui.update_uis(src)

/obj/machinery/kaos/cargo_machine/proc/pingpads()
	for(var/obj/structure/cargo_pad/pad in pads)
		pad.pingpad()
		if(pads.len > 4)
			playsound(pad.loc,'sound/machines/rpf/UImsg.ogg', 10, 0)
		else
			playsound(pad.loc,'sound/machines/rpf/UImsg.ogg', 20, 0)

/obj/machinery/kaos/cargo_machine/proc/playpadsequence(mob/user)
	useable = FALSE
	set_machine_status("RE-ESTABLISHING CARGO PAD CONNECTION...")
	reconnectpads()
	playsound(src.loc, "sound/machines/rpf/barotraumastuff/UI_labelselect.ogg", 75, 0.2)
	spawn(2 SECONDS)
		playsound(src.loc, 'sound/machines/rpf/beepsound1.ogg', 60, 0)
		pinglight()
		spawn(2 SECONDS)
			useable = TRUE
			set_light(3, 3,"#ebc683")
			if (pads.len < 0 | pads.len == null | pads.len == 0)
				set_light(3, 3,"#ebc683")
				set_machine_status("ERROR: NO CARGO PADS LOCATED", TRUE)
				playsound(src.loc, 'sound/machines/rpf/harshdeny.ogg', 250, 0.5)
			else
				playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 250, 0.5)
				set_machine_status("LINK ESTABLISHED: [pads.len] CARGO PADS")

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
	if(!pads.len)
		status_message = "NO CARGO PADS LINKED"
		status_error = TRUE
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
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.3)
		return

	set_light(3, 3, "#ebc683")
	ui_interact(user)

/obj/machinery/kaos/cargo_machine/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!CanPhysicallyInteract(user))
		return

	user.set_machine(src)
	reconnectpads()
	update_categories()

	var/list/data = list()
	var/balance = GLOB.faction_dosh[id]
	if(isnull(balance))
		balance = 0
	data["balance"] = balance
	data["machine_name"] = name
	data["accent"] = id == RED_TEAM ? "#d35b52" : "#6b9ed6"
	data["pad_count"] = pads ? pads.len : 0
	data["useable"] = useable
	data["status_message"] = status_message
	data["status_error"] = status_error
	data["artillery_cost"] = 550

	var/list/available = get_available_products()
	var/list/listed_categories = list()
	for(var/category in categories)
		var/list/listed_products = list()
		if(category != "Artillery")
			for(var/product_index = 1 to available.len)
				var/decl/cargo_product/P = available[product_index]
				if(P.category != category)
					continue
				listed_products += list(list(
					"index" = product_index,
					"name" = P.name,
					"price" = P.price
				))
		listed_categories += list(list(
			"name" = category,
			"products" = listed_products
		))
	data["categories"] = listed_categories

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo_machine.tmpl", name, 500, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/kaos/cargo_machine/OnTopic(user, href_list)
	if(!CanPhysicallyInteract(user))
		return TOPIC_NOACTION

	if(!useable)
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.3)
		return TOPIC_REFRESH

	switch(href_list["action"])
		if("balance")
			display_balance(user)
		if("reconnect")
			playpadsequence(user)
		if("purchase")
			if(!pads || !pads.len)
				set_machine_status("ERROR: NO LINKED CARGO PADS", TRUE)
				playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
				return TOPIC_REFRESH

			var/product_index = text2num(href_list["product"])
			var/list/available = get_available_products()
			if(product_index < 1 || product_index > available.len || round(product_index) != product_index)
				return TOPIC_REFRESH

			var/decl/cargo_product/P = available[product_index]
			if(!P || P.category == "Artillery")
				return TOPIC_REFRESH
			purchase_product(user, P)
		if("artillery")
			if(!pads || !pads.len)
				set_machine_status("ERROR: NO LINKED CARGO PADS", TRUE)
				playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
				return TOPIC_REFRESH
			set_machine_status("ARTILLERY AUTHORIZATION REQUIRED")
			handle_artillery_menu(user)
		else
			return TOPIC_NOACTION

	return TOPIC_REFRESH

/obj/machinery/kaos/cargo_machine/proc/display_balance(mob/user)
	playsound(src, "keyboard_sound", 100, 1)
	if(GLOB.faction_dosh[id] > 0)
		set_machine_status("ACCOUNT BALANCE: [GLOB.faction_dosh[id]] CREDITS")
	else
		set_machine_status("ACCOUNT BALANCE: NO CREDITS")
	playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)

/obj/machinery/kaos/cargo_machine/proc/handle_artillery_menu(mob/user)
	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	var/line_input = sanitize(input(user, "ENTER LOGIN.", "[name]", ""))
	if(!line_input || !useable || !CanPhysicallyInteract(user))
		if(useable)
			set_machine_status("ARTILLERY REQUEST CANCELLED")
		set_light(0)
		return

	if(line_input != GLOB.cargo_password)
		set_machine_status("ERROR: INCORRECT ARTILLERY PASSWORD", TRUE)
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		set_light(0)
		return

	playsound(src, "switch_sound", 100, 1)
	set_machine_status("AUTHORIZATION ACCEPTED: WELCOME CAPTAIN")
	playsound(src.loc, 'sound/machines/rpf/consolebeep.ogg', 100, 0.5)

	if(!useable || !CanPhysicallyInteract(user))
		if(useable)
			set_machine_status("ARTILLERY REQUEST CANCELLED")
		return

	var/x_input = input(user, "Please input the X coordinate.") as num
	if(!x_input || !useable || !CanPhysicallyInteract(user))
		if(useable)
			set_machine_status("ARTILLERY REQUEST CANCELLED")
		return

	set_machine_status("ENTER TARGET Y COORDINATE")
	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	var/y_input = input(user, "Please input the Y coordinate.") as num
	if(!y_input || !useable || !CanPhysicallyInteract(user))
		if(useable)
			set_machine_status("ARTILLERY REQUEST CANCELLED")
		return

	var/target_x = x_input
	var/target_y = y_input

	target_x -= SSwarfare.coord_offset_x
	target_y -= SSwarfare.coord_offset_y

	var/costofartillery = 550
	if(GLOB.faction_dosh[id] < costofartillery)
		set_machine_status("ERROR: INSUFFICIENT FUNDS FOR ARTILLERY", TRUE)
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		set_light(0)
		return

	var/turf/turf_to_drop = locate(target_x, target_y, 2)
	if(!turf_to_drop || !(istype(turf_to_drop.loc, /area/warfare/battlefield/no_mans_land) || istype(turf_to_drop.loc, /area/warfare/battlefield/capture_point/mid)))
		set_machine_status("ERROR: INVALID ARTILLERY COORDINATES", TRUE)
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		set_light(0)
		return

	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)
	set_machine_status("ARTILLERY DEPLOYED: X [target_x], Y [target_y]")
	to_chat(world, uppertext("<font size=5><b>INCOMING!! NO MAN'S LAND!!</b></font>"))

	for(var/obj/machinery/light/l in GLOB.lights)
		if(prob(7))
			l.flicker()

	spawn(1 SECOND)
		for(var/i = 1 to 2)
			sound_to(world, 'sound/effects/arty_distant.ogg')
			sleep(5 SECONDS)

	GLOB.faction_dosh[id] -= costofartillery
	SSnanoui.update_uis(src)
	playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)

	spawn(8 SECONDS)
		artillery_barage(target_x, target_y, 2)

/obj/machinery/kaos/cargo_machine/proc/purchase_product(mob/living/user, decl/cargo_product/P)
	if(!P || !CanPhysicallyInteract(user))
		return

	playsound(src.loc, "sound/machines/rpf/press1.ogg", 100, 0.7)

	if(P.price > GLOB.faction_dosh[id])
		set_machine_status("ERROR: INSUFFICIENT FUNDS FOR [uppertext(P.name)]", TRUE)
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		return

	if(istype(P, /decl/cargo_product/job))
		if(P.name == "Reinforcements")
			set_machine_status("ERROR: REINFORCEMENTS PURCHASES ARE DISABLED", TRUE)
			playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
			return

		var/datum/job/team_job = SSjobs.GetJobByType(P.job_path)
		if(team_job.total_positions < 1)
			SSjobs.allow_one_more(team_job.title)
			GLOB.faction_dosh[id] -= P.price
			set_machine_status("[uppertext(P.name)] REQUESTED")
			playsound(src.loc, 'sound/machines/rpf/sendmsgcargo.ogg', 100, 0)
		else
			set_machine_status("ERROR: NO UNITS AVAILABLE TO SEND", TRUE)
			playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		return

	handle_purchase_spawn(user, P)

/obj/machinery/kaos/cargo_machine/proc/handle_purchase_spawn(mob/living/user, decl/cargo_product/P)
	reconnectpads()
	var/list/clear_turfs = list()
	for(var/obj/structure/cargo_pad/pad in pads)
		if(get_dense_objects_on_turf(get_turf(pad)).len <= 0)
			clear_turfs += pad

	if(!clear_turfs.len)
		set_machine_status("ERROR: ALL CARGO PADS ARE OCCUPIED", TRUE)
		playsound(src.loc, 'sound/machines/rpf/denybeep.ogg', 100, 0.5)
		return

	var/obj/structure/cargo_pad/pickedpad = pick(clear_turfs)
	var/turf/pickedloc = get_turf(pickedpad)

	useable = FALSE
	set_machine_status("TRANSPORTING [uppertext(P.name)]...")
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
			set_machine_status("[uppertext(P.name)] DELIVERED")
			spawn(0.1 SECONDS)
				qdel(glowobj)
				pickedpad.isdeselected()
			playsound(src.loc, 'sound/machines/rpf/transcriptprint.ogg', 90, 0)
			spawn(2 SECONDS)
				resetlightping()
				playsound(src.loc, 'sound/machines/rpf/ChatMsg.ogg', 100, 0)
				useable = TRUE
				SSnanoui.update_uis(src)

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

/obj/structure/cargo_pad/blue/captain
	id = "Bluecoats_C"