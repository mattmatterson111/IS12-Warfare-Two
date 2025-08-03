/obj/structure/train_deco
	icon = 'icons/obj/respawn_trains/decals.dmi'
	anchored = TRUE
	density = FALSE

/obj/structure/train_deco/platform
	icon_state = "platform"

/obj/structure/train_deco/tracks01
	icon = 'icons/obj/respawn_trains/train.dmi'
	icon_state = "tracks01"
	layer = 27

/obj/structure/train_deco/tracks02
	icon = 'icons/obj/respawn_trains/train.dmi'
	icon_state = "tracks02"
	layer = 27

/obj/structure/train_deco/sides
	icon_state = "sides"

/obj/effect/floor_decal/train_deco
	icon = 'icons/obj/respawn_trains/decals.dmi'

/obj/effect/floor_decal/train_deco/stripes
	icon_state = "stripes"

/obj/effect/landmark/train_marker
	icon = 'icons/obj/respawn_trains/decals.dmi'
	icon_state = "train_marker"
	anchored = TRUE
	density = FALSE
	invisibility = 101
	var/id

/obj/effect/landmark/train_marker/entry
/obj/effect/landmark/train_marker/idle
/obj/effect/landmark/train_marker/exit

/obj/effect/landmark/train_marker/entry/red
	id = RED_TEAM
/obj/effect/landmark/train_marker/idle/red
	id = RED_TEAM
/obj/effect/landmark/train_marker/exit/red
	id = RED_TEAM

/obj/effect/landmark/train_marker/entry/blue
	id = BLUE_TEAM
/obj/effect/landmark/train_marker/idle/blue
	id = BLUE_TEAM
/obj/effect/landmark/train_marker/exit/blue
	id = BLUE_TEAM

/obj/effect/landmark/train_marker/teleport

/obj/effect/landmark/train_marker/teleport/blue
	id = BLUE_TEAM
/obj/effect/landmark/train_marker/teleport/red
	id = RED_TEAM