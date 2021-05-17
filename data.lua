local alert_group = {
	type = "item-subgroup",
	name = "ick-virtual-signal-alert",
	group = "signals",
	order = "f[alert]"
}

local alert_signal = {
	type = "virtual-signal",
	name = "ick-signal-destroyed-train",
	icon = "__ick-automatic-train-repair__/graphics/destroyed-train.png",
	icon_size = 64,
	subgroup = "ick-virtual-signal-alert",
	order = "h[destroyed-train]"
}


data:extend({alert_group, alert_signal})