data:extend(
{
  {
    setting_type = "runtime-global",
    type = "bool-setting",
    name = "ick-automatic-mode",
	order = "a[automatic-mode]",
    default_value = true
  },
  {
    setting_type = "runtime-global",
    type = "bool-setting",
    name = "ick-include-equipment",
	order = "b[include-equipment]",
    default_value = true
  },
  {
    setting_type = "runtime-global",
    type = "bool-setting",
    name = "ick-include-fuel",
	order = "c[ick-include-fuel]",
    default_value = true
  },
  {
    setting_type = "runtime-global",
    type = "string-setting",
    name = "ick-fuel-type",
	order = "d[fuel]",
	allow_blank = true,
	auto_trim = true,
    default_value = ""
  },
  {
    setting_type = "runtime-global",
    type = "int-setting",
    name = "ick-fuel-amount",
	order = "e[fuel-amount]",
	minimum_value = 1,
    default_value = 1
  },
})
