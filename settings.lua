data:extend(
{
  {
    setting_type = "runtime-per-user",
    type = "bool-setting",
    name = "ick-alert",
	order = "a[alert]",
    default_value = true
  },
  {
    setting_type = "runtime-global",
    type = "bool-setting",
    name = "ick-automatic-mode",
	order = "b[automatic-mode]",
    default_value = false
  },
  {
    setting_type = "runtime-global",
    type = "bool-setting",
    name = "ick-include-equipment",
	order = "c[include-equipment]",
    default_value = true
  },
  {
    setting_type = "runtime-global",
    type = "bool-setting",
    name = "ick-include-fuel",
	order = "d[ick-include-fuel]",
    default_value = true
  },
  {
    setting_type = "runtime-global",
    type = "string-setting",
    name = "ick-fuel-type",
	order = "e[fuel]",
	allow_blank = true,
	auto_trim = true,
    default_value = ""
  },
  {
    setting_type = "runtime-global",
    type = "int-setting",
    name = "ick-fuel-amount",
	order = "f[fuel-amount]",
	minimum_value = 1,
    default_value = 1
  },
})
