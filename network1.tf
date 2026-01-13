locals {
	network_info = {
		aks_subnet_ids = [ for k, v in local.network_vnets["aks"].subnets : azurerm_subnet.env["aks_${k}"].id if lookup(v, "is_aks_nodepool", false) ]
		aks_address_spaces = [ for k, v in local.network_vnets["aks"].subnets : azurerm_subnet.env["aks_${k}"].address_prefixes[0] if lookup(v, "is_aks_nodepool", false) ]
		backhaul_firewall_public_ip = azurerm_public_ip.env[local.network_firewalls["backhaul"].pip].ip_address
		local_address_spaces = flatten([ for k, v in azurerm_virtual_network.env : v.address_space ])
		service_address_spaces = concat(
			[ for k, v in local.network_vnets["aks"].subnets : azurerm_subnet.env["aks_${k}"].address_prefixes[0] if lookup(v, "is_aks_nodepool", false) ],
		)
	}
}

#----- Create the shared DDoS protection plan resource
resource "azurerm_network_ddos_protection_plan" "env" {
	for_each = ( local.my_mg.firewall_whitelist.all_internet_to_web || contains(local.my_env.exceptions, "${local.my_env_short}_public_internet") ) ? { "default":"default"} : {}

	name = "default-ddos-protection-plan"
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

#----- Create the vnets
resource "azurerm_virtual_network" "env" {
	for_each = { for k, v in local.network_vnets : k => v }
	
	name = lower("vnet-${each.key}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-01")
	resource_group_name = azurerm_resource_group.env[each.value.rg_ref].name
	location = azurerm_resource_group.env[each.value.rg_ref].location
	
	address_space = local.my_env.vnet_address_spaces[local.basic["local"].region_short][each.key]
	
	dynamic ddos_protection_plan {
		for_each = ( local.my_mg.firewall_whitelist.all_internet_to_web || contains(local.my_env.exceptions, "${local.my_env_short}_public_internet") ) ? { "default":"default"} : {}
	
		content {
			id = azurerm_network_ddos_protection_plan.env["default"].id
			enable = true
		}
	}
	
	tags = local.tags
	
	lifecycle {
		ignore_changes = [ dns_servers, tags ]
	}
}

#----- Create the subnets
resource "azurerm_subnet" "env" {
	for_each = { for k, v in (flatten(
		[ for vnet_key, vnet_value in local.network_vnets :
			[ for subnet_key, subnet_value in vnet_value.subnets :
				{
					vnet_key = vnet_key
					subnet_key = subnet_key
					subnet_value = subnet_value
				}
			]
		]
		)) : "${v.vnet_key}_${v.subnet_key}" => v
	}
	
	name = (lookup(each.value["subnet_value"], "full_name", "") != "" ?
		each.value["subnet_value"].full_name
		:
		lower("snet-${each.value["subnet_value"].name}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-${each.value["subnet_value"].numeric}")
	)
	
	resource_group_name = azurerm_virtual_network.env[each.value["vnet_key"]].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.env[each.value["vnet_key"]].name
	address_prefixes = [ local.network_subnet_address_prefixes[each.key] ]
	
	service_endpoints = (lookup(each.value["subnet_value"], "dont_add_service_endpoints", false) ?
		[]
		:
		[ 
			"Microsoft.AzureCosmosDB",
			"Microsoft.CognitiveServices",
			"Microsoft.ContainerRegistry",
			"Microsoft.EventHub",
			"Microsoft.KeyVault",
			"Microsoft.ServiceBus",
			"Microsoft.Sql",
			"Microsoft.Storage"
		]
	)

	dynamic "delegation" {
		for_each = (lookup(each.value["subnet_value"], "delegation", null) != null ? { "default" = "default" } : {})
		
		content {
			name = each.value["subnet_value"].delegation.name
			service_delegation {
				name = each.value["subnet_value"].delegation.name
				actions = each.value["subnet_value"].delegation.actions
			}
		}
	}
	
	private_endpoint_network_policies_enabled = lookup(each.value["subnet_value"], "enforce_private_link_endpoint_network_policies", true)
}

#----- Create the network security groups
resource "azurerm_network_security_group" "env" {
	for_each = local.network_nsgs
	
	name = (contains(keys(each.value), "full_name") ?
		each.value.full_name
		:
		"nsg-${each.value.name}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-${each.value.numeric}"
	)
	resource_group_name = azurerm_resource_group.env[each.value.rg_ref].name	
	location = azurerm_resource_group.env[each.value.rg_ref].location
	
	dynamic security_rule {
		for_each = { for k, v in each.value.rules : k => v }
		
		content {
			name = security_rule.key
			description = ""
			priority = security_rule.value.priority
	
			direction = security_rule.value.direction
			access = security_rule.value.access
			
			protocol = security_rule.value.protocol
			# Check if there are subnet references first (used to keep the NSG spec global as opposed to local to the 00 step)
			source_address_prefix = (lookup(security_rule.value, "source_address_prefix_subnet_ref", null) != null ?
				local.network_subnet_address_prefixes[lookup(security_rule.value, "source_address_prefix_subnet_ref", null)]
				:
				lookup(security_rule.value, "source_address_prefix", null)
			)
			source_address_prefixes = (contains(keys(security_rule.value), "source_address_prefixes") || contains(keys(security_rule.value), "source_address_prefix_subnet_refs") ?
				distinct(concat(
					lookup(security_rule.value, "source_address_prefixes", []),
					[ for v in lookup(security_rule.value, "source_address_prefix_subnet_refs", []) : local.network_subnet_address_prefixes[v] ]
				))
				:
				null
			)
			source_port_range = (contains(keys(security_rule.value), "source_port_ranges")) ? null : security_rule.value.source_port_range
			source_port_ranges = lookup(security_rule.value, "source_port_ranges", null)
			
			# Check if there are subnet references first (used to keep the NSG spec global as opposed to local to the 00 step)
			destination_address_prefix = (lookup(security_rule.value, "destination_address_prefix_subnet_ref", null) != null ?
				local.network_subnet_address_prefixes[lookup(security_rule.value, "destination_address_prefix_subnet_ref", null)]
				:
				lookup(security_rule.value, "destination_address_prefix", null)
			)
			destination_address_prefixes = (contains(keys(security_rule.value), "destination_address_prefixes") || contains(keys(security_rule.value), "destination_address_prefix_subnet_refs") ?
				distinct(concat(
					lookup(security_rule.value, "destination_address_prefixes", []),
					[ for v in lookup(security_rule.value, "destination_address_prefix_subnet_refs", []) : local.network_subnet_address_prefixes[v] ]
				))
				:
				null
			)
			destination_port_range = (contains(keys(security_rule.value), "destination_port_ranges")) ? null : security_rule.value.destination_port_range
			destination_port_ranges = lookup(security_rule.value, "destination_port_ranges", null)
		}
	}
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

#----- Associate the NSGs to their respective subnets
resource "azurerm_subnet_network_security_group_association" "env" {
	for_each = { for k, v in (flatten(
		[ for vnet_key, vnet_value in local.network_vnets :
			[ for subnet_key, subnet_value in vnet_value.subnets :
				{
					vnet_key = vnet_key
					subnet_key = subnet_key
					subnet_value = subnet_value
				}
			]
		]
		)) : "${v.vnet_key}_${v.subnet_key}" => v if v.subnet_value.nsg_ref != "none"
	}

	subnet_id = azurerm_subnet.env[each.key].id
	network_security_group_id = azurerm_network_security_group.env[each.value["subnet_value"].nsg_ref].id
}

#----- Create the resources needed for NSG flow logs
resource "azurerm_network_watcher" "env" {
	name = lower("nww-${local.basic["local"].env_short}-${local.basic["local"].region_short}")
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

resource "azurerm_network_watcher_flow_log" "env" {
	for_each = local.network_nsgs

	name = "Microsoft.Network${azurerm_network_security_group.env[each.key].resource_group_name}${azurerm_network_security_group.env[each.key].name}"
	network_watcher_name = azurerm_network_watcher.env.name
	resource_group_name = azurerm_network_watcher.env.resource_group_name
	location = azurerm_network_watcher.env.location

	network_security_group_id = azurerm_network_security_group.env[each.key].id
	storage_account_id = azurerm_storage_account.env["network"].id
	enabled = true

	retention_policy {
		enabled = true
		days = var.nsg_flow_logs.retention_days
	}

	traffic_analytics {
		enabled = true
		workspace_id = data.terraform_remote_state.common.outputs.log_analytics["default"].workspace_id
		workspace_region = data.terraform_remote_state.common.outputs.log_analytics["default"].location
		workspace_resource_id = data.terraform_remote_state.common.outputs.log_analytics["default"].id
		interval_in_minutes = var.nsg_flow_logs.traffic_analytics_interval
	}
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

#----- Peer all vnets to each other
resource "azurerm_virtual_network_peering" "env" {
	for_each = { for k, v in (flatten(
			[ for source_vnet_key, source_vnet_value in local.network_vnets :
				[ for dest_vnet_key, dest_vnet_value in local.network_vnets :
					{
						source_vnet_key = source_vnet_key
						dest_vnet_key = dest_vnet_key
					}
				]
			]
		)) : "${v.source_vnet_key}_to_${v.dest_vnet_key}" => v if v.source_vnet_key != v.dest_vnet_key
	}
	
	name = azurerm_virtual_network.env[each.value["dest_vnet_key"]].name
	resource_group_name = azurerm_virtual_network.env[each.value["source_vnet_key"]].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.env[each.value["source_vnet_key"]].name
	remote_virtual_network_id = azurerm_virtual_network.env[each.value["dest_vnet_key"]].id
}

#----- Add peerings for vnets in SL-EXOS-ReleaseMGMT-01 (only build servers currently)
resource "azurerm_virtual_network_peering" "local_to_common" {
	for_each = { for k, v in local.network_vnets : "${k}_to_build" => k if (k != "wvd" || (k == "wvd" && var.create_wvd_infra == true)) }
	
	name = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].vnet_name
	resource_group_name = azurerm_virtual_network.env[each.value].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.env[each.value].name
	remote_virtual_network_id = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].vnet_id
}

resource "azurerm_virtual_network_peering" "common_to_local" {
	for_each = { for k, v in local.network_vnets : "build_to_${k}" => k if (k != "wvd" || (k == "wvd" && var.create_wvd_infra == true)) }
	
	provider = azurerm.common
	
	name = azurerm_virtual_network.env[each.value].name
	resource_group_name = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].vnet_rg_name
	
	virtual_network_name = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].vnet_name
	remote_virtual_network_id = azurerm_virtual_network.env[each.value].id
}

#----- Add peerings to a FNF subscription for vnets that need to be routed
resource "azurerm_virtual_network_peering" "local_to_routed" {
	for_each = contains(local.fcx_peering.apply_in,local.my_env_short) ? {} : { for v in local.my_mg.routed_vnets : "${v}_to_routed" => v if (
		v != "wvd" || (v == "wvd" && var.create_wvd_infra == true)) && local.my_mg.routed_vnet_target[var.region_ref].peering_enabled}
	
	name = local.my_mg.routed_vnet_target[var.region_ref].vnet_name
	resource_group_name = azurerm_virtual_network.env[each.value].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.env[each.value].name
	remote_virtual_network_id = local.my_mg.routed_vnet_target[var.region_ref].vnet_id
	
	allow_forwarded_traffic = true
	use_remote_gateways = true
}

resource "azurerm_virtual_network_peering" "routed_to_local" {
	for_each = contains(local.fcx_peering.apply_in,local.my_env_short) ? {} : { for v in local.my_mg.routed_vnets : "routed_to_${v}" => v if (
		v != "wvd" || (v == "wvd" && var.create_wvd_infra == true))  && local.my_mg.routed_vnet_target[var.region_ref].peering_enabled}
	
	provider = azurerm.routed_vnet
	
	name = azurerm_virtual_network.env[each.value].name
	resource_group_name = local.my_mg.routed_vnet_target[var.region_ref].rg_name
	
	virtual_network_name = local.my_mg.routed_vnet_target[var.region_ref].vnet_name
	remote_virtual_network_id = azurerm_virtual_network.env[each.value].id
	
	allow_gateway_transit = true
}

#----- Add peerings to the HSM vNets
resource "azurerm_virtual_network_peering" "local_to_hsm" {
	for_each = { for v in local.my_mg.hsm_vnets : "${v}_to_hsm" => v if local.my_mg.hsm_vnet_target[var.region_ref].peering_enabled}
	
	name = local.my_mg.hsm_vnet_target[var.region_ref].vnet_name
	resource_group_name = azurerm_virtual_network.env[each.value].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.env[each.value].name
	remote_virtual_network_id = local.my_mg.hsm_vnet_target[var.region_ref].vnet_id
}

resource "azurerm_virtual_network_peering" "hsm_to_local" {
	for_each = { for v in local.my_mg.hsm_vnets : "hsm_to_${v}" => v if local.my_mg.hsm_vnet_target[var.region_ref].peering_enabled}
	
	provider = azurerm.hsm_vnet
	
	name = azurerm_virtual_network.env[each.value].name
	resource_group_name = local.my_mg.hsm_vnet_target[var.region_ref].rg_name
	
	virtual_network_name = local.my_mg.hsm_vnet_target[var.region_ref].vnet_name
	remote_virtual_network_id = azurerm_virtual_network.env[each.value].id
}

#----- Create route tables and associate them to each subnet
resource "azurerm_route_table" "env" {
	for_each = local.network_route_tables
	
	name = lower("route-${each.value["name"]}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-${each.value.numeric}")
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	bgp_route_propagation_enabled = true
	
	dynamic "route" {
		for_each = lookup(each.value, "internet_routes", {})
		
		content {
			name = route.key
			address_prefix = route.value
			next_hop_type = "Internet"
		}
	}
	
	dynamic "route" {
		for_each = lookup(each.value, "add_default_to_backhaul_firewall", false) ? { "default" = azurerm_firewall.env["backhaul"].ip_configuration[0].private_ip_address } : {}
		
		content {
			name = route.key
			address_prefix = "0.0.0.0/0"
			next_hop_type = "VirtualAppliance"
			next_hop_in_ip_address = route.value
		}
	}

	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

resource "azurerm_subnet_route_table_association" "env" {
	for_each = { for k, v in (flatten(
		[ for vnet_key, vnet_value in local.network_vnets :
			[ for subnet_key, subnet_value in vnet_value.subnets :
				{
					vnet_key = vnet_key
					subnet_key = subnet_key
					subnet_value = subnet_value
				}
			]
		]
		)) : "${v.vnet_key}_${v.subnet_key}" => v if v.subnet_value.route_table_ref != "none"
	}

	subnet_id = azurerm_subnet.env[each.key].id
	route_table_id = azurerm_route_table.env[each.value["subnet_value"].route_table_ref].id
}


#----- Create public IPs
resource "azurerm_public_ip" "env" {
	for_each = local.network_public_ips
	
	name = lower("pip-${each.value.name}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-${each.value.numeric}")
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	allocation_method = "Static"
	sku = "Standard"
	
	zones = [ "1", "2", "3" ]
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

#----- Create the firewall
resource "azurerm_firewall" "env" {
	for_each = local.network_firewalls

	name = lower("frw-${each.value.name}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-${each.value.numeric}")
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	sku_name = "AZFW_VNet"
	sku_tier = "Standard"
	
	ip_configuration {
		name = "pip1"
		subnet_id = azurerm_subnet.env[each.value["subnet"]].id
		public_ip_address_id = azurerm_public_ip.env[each.value["pip"]].id
	}
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

#----- Create the bastions
resource "azurerm_bastion_host" "env" {
	for_each = local.network_bastions
	
	name = (each.value.name == "" ?
		lower("bastion-${local.basic["local"].env_short}-${local.basic["local"].region_short}-01")
		:
		lower("bastion-${each.value["name"]}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-01")
	)
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	ip_configuration {
		name = "config"
		subnet_id = azurerm_subnet.env[each.value["subnet"]].id
		public_ip_address_id = azurerm_public_ip.env[each.value["pip"]].id
	}
	
	tags = local.tags
	lifecycle {
		ignore_changes = [
			tags,
		]
	}
}

# -----  Create VNet Peering between Backhaul Vnet and FCX Vnet
resource "azurerm_virtual_network_peering" "local_to_fcx" {
	for_each = contains(local.fcx_peering.apply_in,local.my_env_short) ? { for v in local.my_mg.routed_vnets : "${v}_to_fcx" => v if (v != "wvd" || (v == "wvd" && var.create_wvd_infra == true)) } : {}
	
	name = data.terraform_remote_state.common.outputs.fcx_vnet[local.my_mg.fcx_vnet_target[var.region_ref]].vnet_name
	resource_group_name = azurerm_virtual_network.env[each.value].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.env[each.value].name
	remote_virtual_network_id = data.terraform_remote_state.common.outputs.fcx_vnet[local.my_mg.fcx_vnet_target[var.region_ref]].vnet_id
	
	allow_forwarded_traffic = true
	use_remote_gateways = true
}

resource "azurerm_virtual_network_peering" "fcx_to_local" {
	for_each = contains(local.fcx_peering.apply_in,local.my_env_short) ? { for v in local.my_mg.routed_vnets : "fcx_to_${v}" => v if (v != "wvd" || (v == "wvd" && var.create_wvd_infra == true)) } : {}
	
	provider = azurerm.common
	
	name = azurerm_virtual_network.env[each.value].name
	resource_group_name = data.terraform_remote_state.common.outputs.fcx_vnet[local.my_mg.fcx_vnet_target[var.region_ref]].vnet_rg_name
	
	virtual_network_name = data.terraform_remote_state.common.outputs.fcx_vnet[local.my_mg.fcx_vnet_target[var.region_ref]].vnet_name
	remote_virtual_network_id = azurerm_virtual_network.env[each.value].id
	
	allow_gateway_transit = true
}

######################################################################
#--------------------Temp VM for FCX testing in Sandbox --------------
#----- Create the Vnet
resource "azurerm_virtual_network" "temp_vnet" {
	for_each = local.my_env_short =="sandbox" ? { "temp-backhaul":"temp-backhaul" } : {}
	name = "vnet-temp-backhaul"
	resource_group_name = azurerm_resource_group.env["net"].name
	location = azurerm_resource_group.env["net"].location
	
	address_space = ["10.79.180.0/24"]
	
	dynamic ddos_protection_plan {
		for_each = ( local.my_mg.firewall_whitelist.all_internet_to_web || contains(local.my_env.exceptions, "${local.my_env_short}_public_internet") ) ? { "default":"default"} : {}
	
		content {
			id = azurerm_network_ddos_protection_plan.env["default"].id
			enable = true
		}
	}
	
	tags = local.tags
	
	lifecycle {
		ignore_changes = [ dns_servers, tags ]
	}
}
#----- Create the subnets
resource "azurerm_subnet" "temp_vnet_subnet" {
	for_each = local.my_env_short == "sandbox" ? { "snet-temp-backhaul":"snet-temp-backhaul" } : {}
	
	name = "snet-temp-backhaul"
	
	resource_group_name = azurerm_virtual_network.temp_vnet["temp-backhaul"].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.temp_vnet["temp-backhaul"].name
	address_prefixes = [ cidrsubnet("10.79.180.0/24", 3, 0) ]

}

#----- Associate the NSGs to their respective Temp Vnet subnets
resource "azurerm_subnet_network_security_group_association" "temp_vnet_nsg" {
	for_each = local.my_env_short == "sandbox" ? { "snet-temp-backhaul":"snet-temp-backhaul" } : {}

	subnet_id = azurerm_subnet.temp_vnet_subnet[each.key].id
	network_security_group_id = azurerm_network_security_group.env["default"].id
}

resource "azurerm_virtual_network_peering" "local_to_routed_fcx" {
	for_each = local.my_env_short =="sandbox" ? { for v in ["temp-backhaul"] : "${v}_to_routed_fcx" => v if (v != "wvd" || (v == "wvd" && var.create_wvd_infra == true)) } : {}
	
	name = data.terraform_remote_state.common.outputs.fcx_vnet["dev-fcx_${local.basic["local"].region_short}"].vnet_name
	resource_group_name = azurerm_virtual_network.temp_vnet[each.value].resource_group_name
	
	virtual_network_name = azurerm_virtual_network.temp_vnet[each.value].name
	remote_virtual_network_id = data.terraform_remote_state.common.outputs.fcx_vnet["dev-fcx_${local.basic["local"].region_short}"].vnet_id
	# remote_virtual_network_id = local.basic["local"].region_short == "wus2" ? data.terraform_remote_state.common.outputs.fcx_vnet["dr-fcx_wus2"].vnet_id : data.terraform_remote_state.common.outputs.fcx_vnet["${local.my_mg_ref}-fcx_${local.basic["local"].region_short}"].vnet_id
	
	allow_forwarded_traffic = true
	use_remote_gateways = true
}

resource "azurerm_virtual_network_peering" "routed_fcx_to_local" {
	for_each = local.my_env_short =="sandbox" ? { for v in ["temp-backhaul"] : "routed_to_${v}" => v if (v != "wvd" || (v == "wvd" && var.create_wvd_infra == true)) } : {}
	
	provider = azurerm.common
	
	name = azurerm_virtual_network.temp_vnet[each.value].name
	resource_group_name = data.terraform_remote_state.common.outputs.fcx_vnet["dev-fcx_${local.basic["local"].region_short}"].vnet_rg_name
	
	virtual_network_name = data.terraform_remote_state.common.outputs.fcx_vnet["dev-fcx_${local.basic["local"].region_short}"].vnet_name
	remote_virtual_network_id = azurerm_virtual_network.temp_vnet[each.value].id
	
	allow_gateway_transit = true
}
