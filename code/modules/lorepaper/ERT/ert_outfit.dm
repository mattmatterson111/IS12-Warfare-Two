/obj/item/clothing/suit/storage/toggle/soldier
	icon_state = "soldier"
	icon_open = "soldier_open"
	icon_closed = "soldier"

/obj/item/clothing/gloves/thick/swat
	item_state = "soldier"

/obj/item/clothing/shoes/jackboots/warfare/red/soldier
	warfare_team = ""
	item_state = "soldier"

/obj/item/clothing/under/soldier
	icon_state = "soldier"

/obj/item/clothing/mask/soldier
	icon_state = "soldier"

/obj/item/storage/backpack/satchel/warfare/chestrig/soldier
	icon_state = "soldier"

/obj/item/clothing/head/warfare_officer/redofficer/squadleader
	name = "Squad Leader's cap"
	warfare_team = ""

/decl/hierarchy/outfit/soldier
	suit = /obj/item/clothing/suit/storage/toggle/soldier
	mask = /obj/item/clothing/mask/soldier
	chest_holster = /obj/item/storage/backpack/satchel/warfare/chestrig/soldier
	uniform = /obj/item/clothing/under/soldier
	gloves = /obj/item/clothing/gloves/thick/swat
	shoes = /obj/item/clothing/shoes/jackboots/warfare/red/soldier
	flags = OUTFIT_NO_BACKPACK|OUTFIT_NO_SURVIVAL_GEAR

/decl/hierarchy/outfit/soldier/leader
	head = /obj/item/clothing/head/warfare_officer/redofficer/squadleader