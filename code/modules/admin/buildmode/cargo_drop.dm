/datum/build_mode/cargo_drop
	name = "Cargo Drop"
	icon_state = "buildmode1"

	var/decl/cargo_product/selected_product

/datum/build_mode/cargo_drop/Help()
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Click   = Drop cargo crate at location</span>")
	to_chat(user, "<span class='notice'>Right Click  = Select cargo product type</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Current: [selected_product?.name || "None selected"]</span>")

/datum/build_mode/cargo_drop/Configurate()
	var/list/products = list()
	var/list/all_decls = decls_repository.get_decls_of_subtype(/decl/cargo_product)

	for(var/type in all_decls)
		var/decl/cargo_product/P = all_decls[type]
		if(!istype(P))
			continue
		if(istype(P, /decl/cargo_product/job))
			continue
		if(P.type == /decl/cargo_product || P.type == /decl/cargo_product/crate || P.type == /decl/cargo_product/train)
			continue
		products[P.name] = P

	var/choice = input("Select cargo product", "Cargo Drop") as null|anything in products
	if(choice)
		selected_product = products[choice]
		to_chat(user, "<span class='notice'>Selected: [selected_product.name]</span>")

/datum/build_mode/cargo_drop/OnClick(var/atom/A, var/list/parameters)
	if(parameters["left"])
		if(!selected_product)
			to_chat(user, "<span class='warning'>No product selected! Right-click to configure.</span>")
			return

		var/turf/T = get_turf(A)
		if(!T)
			return

		new /obj/effect/falling_crate(T, selected_product.crate_type, selected_product.contents)

		to_chat(user, "<span class='notice'>Dropping [selected_product.name] at [T.x],[T.y]!</span>")
		Log("Cargo drop [selected_product.name] at [T.x],[T.y],[T.z]")

	else if(parameters["right"])
		Configurate()
