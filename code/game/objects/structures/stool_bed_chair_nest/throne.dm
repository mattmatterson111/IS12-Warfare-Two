//The throne has many functions so it gets its own file.

/obj/structure/bed/chair/throne
	name = "\the Blue Captain's throne"
	desc = "A throne for the finest of nepotized asses."
	base_icon = "brownchair"
	icon_state = "brownchair"
	color = "#FFFFFF"

/obj/structure/bed/chair/throne/red
	name = "\the Red Captain's throne"

/obj/structure/bed/chair/throne/rotate()//Can't rotate it.
	return

/obj/structure/bed/chair/throne/attackby(obj/item/W as obj, mob/user as mob)//Can't deconstruct it.
	return