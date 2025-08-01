// WE DO NOT NEED NOSMOOTH ANYMORE
// IT'D JUST BE A PAIN TO RE-MAP
// TO-DO: REPLACE WITH TABLE AND RACK SUBTYPES!!

/obj/structure/table/rack/nosmooth
	name = "rack/nosmooth"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	can_plate = 0
	can_reinforce = 0
	flipped = 0

	material = DEFAULT_TABLE_MATERIAL

/obj/structure/table/rack/nosmooth/wood
	name = "wood table"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/tables.dmi'
	icon_state = "wood1"

	material = DEFAULT_TABLE_MATERIAL

/obj/structure/table/rack/nosmooth/wood/alt
	icon_state = "wood2"

/obj/structure/table/rack/nosmooth/dismantle(obj/item/wrench/W, mob/user)
	to_chat(user, "<span class='warning'>You cannot dismantle \the [src].</span>")
	return

/obj/structure/table/rack/nosmooth/metal
	name = "metal table"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/tables.dmi'
	icon_state = "metallic"

	material = DEFAULT_TABLE_MATERIAL

// I feel bad about copy and pasting this.

// NOTE: Figure out a cleaner way to do this, since currently you can't walk from table to table.
/obj/structure/table/rack/nosmooth/auto_align(obj/item/W, click_params) //You broke something here Kas. It runtimes like crazy. I'll fix it later.
	if(W)
		if(!W.center_of_mass) // Clothing, material stacks, generally items with large sprites where exact placement would be unhandy.
			W.pixel_x = rand(-W.randpixel, W.randpixel)
			W.pixel_y = rand(-W.randpixel, W.randpixel)
			W.pixel_z = 0
			return

	if (!click_params)
		return

	var/list/click_data = params2list(click_params)
	if (!click_data["icon-x"] || !click_data["icon-y"])
		return

	// Calculation to apply new pixelshift.
	var/mouse_x = text2num(click_data["icon-x"])-1 // Ranging from 0 to 31
	var/mouse_y = text2num(click_data["icon-y"])-1

	var/cell_x = Clamp(round(mouse_x/CELLSIZE), 0, CELLS-1) // Ranging from 0 to CELLS-1
	var/cell_y = Clamp(round(mouse_y/CELLSIZE), 0, CELLS-1)

	var/list/center = cached_key_number_decode(W.center_of_mass)

	W?.pixel_x = (CELLSIZE * (cell_x + 0.5)) - center["x"]
	W?.pixel_y = (CELLSIZE * (cell_y + 0.5)) - center["y"]
	W?.pixel_z = 0

/obj/structure/table/rack/nosmooth/capleft
	name = "wooden table"
	desc = "Sturdy.. the peak of circular innovation."
	icon = 'icons/obj/tables.dmi'
	icon_state = "captablel"

/obj/structure/table/rack/nosmooth/capright
	name = "wooden table"
	desc = "Sturdy.. the peak of circular innovation."
	icon = 'icons/obj/tables.dmi'
	icon_state = "captabler"
