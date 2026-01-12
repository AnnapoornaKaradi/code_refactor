locals {

network_vnets = merge(
{
	aks = {
		rg_ref = "net"
		subnets = merge(
			# Use x.18.0.0/19
			{ default_nodepool = {
				name = "aks-default-nodepool"
				numeric = "01"
				numbits = 4
				offset = 0
				nsg_ref = "aks"
				route_table_ref = "default"
				is_aks_nodepool = true
				aks_ref = "app"
			}},
			# Use x.18.32.0/19
			{ appdefault_nodepool = {
				name = "aks-appdefault-nodepool"
				numeric = "01"
				numbits = 4
				offset = 1
				nsg_ref = "aks"
				route_table_ref = "default"
				is_aks_nodepool = true
				aks_ref = "app"
				add_to_resource_firewalls = true
			}},
			# Use x.18.64.0/19
			{ docgen_nodepool = {
				name = "aks-docgen-nodepool"
				numeric = "01"
				numbits = 4
				offset = 2
				nsg_ref = "aks"
				route_table_ref = "default"
				is_aks_nodepool = true
				aks_ref = "app"
				add_to_resource_firewalls = true
			}},
			# Use x.18.96.0/19
			{ gpu_nodepool = {
				name = "aks-gpu-nodepool"
				numeric = "01"
				numbits = 4
				offset = 3
				nsg_ref = "aks"
				route_table_ref = "default"
				is_aks_nodepool = true
				aks_ref = "app"
				add_to_resource_firewalls = true
			}},
			# Use x.18.128.0/19
			{ els_nodepool = {
				name = "aks-els-nodepool"
				numeric = "01"
				numbits = 4
				offset = 4
				nsg_ref = "aks"
				route_table_ref = "default"
				is_aks_nodepool = true
				aks_ref = "app"
				add_to_resource_firewalls = true
			}},
			# Use x.18.160.0/19
			{ exos3_nodepool = {
				name = "aks-exos3-nodepool"
				numeric = "01"
				numbits = 4
				offset = 5
				nsg_ref = "aks"
				route_table_ref = "default"
				is_aks_nodepool = true
				aks_ref = "app"
				add_to_resource_firewalls = true
			}},
			# --- x.19.0.32/26 is available
			# Use x.19.0.64/26
			{ lan = {
				name = "aks-lan"
				numeric = "01"
				numbits = 11
				offset = 1025
				nsg_ref = "default"
				route_table_ref = "default"
			}},
			# Add the gateway subnet at x.19.0.128/26
			{ gateway = {
				full_name = "GatewaySubnet"
				numbits = 11
				offset = 1026
				nsg_ref = "none"
				route_table_ref = "none"
			}},
			# Use x.19.0.192/26
			(length(keys(local.apim_instances_to_install)) > 0 ? { apim2 = {
				name = "apim2"
				numeric = "02"
				numbits = 11
				offset = 1027
				nsg_ref = "apim"
				route_table_ref = "apim"
			}} : {}),
			# Use x.19.1.0/24 
			{ ase = {
				name = "aks-ase"
				numeric = "01"
				numbits = 9
				offset = 257
				nsg_ref = "ase"
				route_table_ref = "default"
				add_to_resource_firewalls = true
				delegation = {
					name = "Microsoft.Web/hostingEnvironments"
					actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
				}
			}},
		)
	},
	# This expects a /24
	app = {
		rg_ref = "net"
		subnets = {
			# Use x.x.x.0/26
			plink = {
				name = "plink"
				numeric = "01"
				numbits = 2
				offset = 0
				nsg_ref = "plink"
				route_table_ref = "default"
				dont_add_service_endpoints = true
				enforce_private_link_endpoint_network_policies = false
			}
			# Use x.x.x.64/27
			redis = {
				name = "redis"
				numeric = "01"
				numbits = 3
				offset = 2
				nsg_ref = "redis"
				route_table_ref = "default"
				dont_add_service_endpoints = true
			}
		}
	},
	# This expects a /24
	backhaul = {
		rg_ref = "net"
		subnets = {
			# Use x.x.x.32/27
			bastion = {
				full_name = "AzureBastionSubnet"
				numbits = 3
				offset = 1
				nsg_ref = "bastion"
				route_table_ref = "none"
				dont_add_service_endpoints = true
			}
			# Use x.x.x.0/27
			dmz = {
				name = "backhaul-dmz"
				numeric = "01"
				numbits = 3
				offset = 0
				nsg_ref = "default"
				route_table_ref = "default"
			}
			# Use x.x.x.64/26
			firewall = {
				full_name = "AzureFirewallSubnet"
				numbits = 2
				offset = 1
				nsg_ref = "none"
				route_table_ref = "none"
				dont_add_service_endpoints = true
			}
			# Use x.x.x.128/25
			lan = {
				name = "backhaul-lan"
				numeric = "01"
				numbits = 1
				offset = 1
				nsg_ref = "default"
				route_table_ref = "default"
			}
		}
	}
	# This expects a /24
	win = {
		rg_ref = "net"
		use_hosted_dns = true
		subnets = {
			# Use x.x.x.0/28
			print = {
				name = "print"
				numeric = "01"
				numbits = 4
				offset = 0
				nsg_ref = "default"
				route_table_ref = "default"
			}
			ssrs = {
				name = "ssrs"
				numeric = "01"
				numbits = 4
				offset = 1
				nsg_ref = "default"
				route_table_ref = "default"
			}
		}
	}
},
(var.create_wvd_infra ?
	{ wvd = {
		rg_ref = "wvd"
		use_hosted_dns = true
		subnets = {
			wvd = {
				name = "wvd"
				numeric = "01"
				numbits = 0
				offset = 0
				nsg_ref = "wvd"
				route_table_ref = "default"
				add_to_storage_accounts = true
			}
		}
	}}
	:
	{}
)
)

network_subnet_address_prefixes = { for k, v in (flatten(
	[ for vnet_key, vnet_value in local.network_vnets :
		[ for subnet_key, subnet_value in vnet_value.subnets :
			{
				vnet_key = vnet_key
				subnet_key = subnet_key
				subnet_value = subnet_value
			}
		]
	]
	)) : "${v.vnet_key}_${v.subnet_key}" => cidrsubnet(local.my_env.vnet_address_spaces[local.basic["local"].region_short][v.vnet_key][0], v.subnet_value.numbits, v.subnet_value.offset)
}
	

# !!!!! For NSGs to remain global, references need to be used for vNet and subnet address spaces as opposed to hitting the actual resource
# You can reference vNet address space via local.my_env.vnet_address_spaces
# You can reference subnet address spaces by using source_address_prefix_subnet_ref (for one), source_address_prefix_subnet_refs (for multiple), destination_address_prefix_subnet_ref (for one), and destination_address_prefix_subnet_refs (for multiple) 
network_nsgs = merge(
	{
		aks = {
			name = "aks"
			numeric = "01"
			rg_ref = "net"
			rules = {
				allow_local_vnet = {
					priority = 100
					direction = "Inbound"
					access = "Allow"
					protocol = "*"
					source_address_prefix = local.my_env.vnet_address_spaces[local.basic["local"].region_short]["aks"][0]
					source_port_range = "*"
					destination_address_prefix = local.my_env.vnet_address_spaces[local.basic["local"].region_short]["aks"][0]
					destination_port_range = "*"
				}
				allow_443 = {
					priority = 110
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = local.my_env.vnet_address_spaces[local.basic["local"].region_short]["aks"][0]
					destination_port_range = "443"
				}
				allow_alb_probes = {
					priority = 120
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
				allow_mssql = {
					priority = 130
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.my_env.vnet_address_spaces[local.basic["local"].region_short]["aks"][0]
					source_port_range = "*"
					destination_address_prefixes = [ "20.41.4.104/31", "20.41.4.108/30", "20.41.4.208/28", "20.41.4.224/27", "20.41.5.0/25", "20.98.192.168/30", "20.98.192.192/27", "20.98.193.128/26", "20.98.193.192/29", "20.98.199.116/31", "20.119.156.32/27", "20.119.157.64/28", "74.249.120.64/26", "104.208.203.176/28", "135.232.93.144/28", "145.132.126.160/27", ]
					destination_port_range = "1433"
				}
				block_all = {
					priority = 4096
					direction = "Inbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
				venafi-cert-auto-tcp-in = {
					priority = 1713
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefixes = local.venafi-nsg-rules.source_address_prefix
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_ranges = local.venafi-nsg-rules.destination_port_range
				}
				thousand-eye-snmp-udp-in = {
					priority = 1702
					direction = "Inbound"
					access = "Allow"
					protocol = "Udp"
					source_address_prefixes = local.thousand-eye-snmp-udp-in-nsg-rules.source_address_prefix
					source_port_ranges = local.thousand-eye-snmp-udp-in-nsg-rules.source_port_range
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
			}
		}
		ase = {
			name = "ase"
			numeric = "01"
			rg_ref = "net"
			rules = merge(
				{
					allow_subnet_connectivity = {
						priority = 100
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = local.network_subnet_address_prefixes["aks_ase"]
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["aks_ase"]
						destination_port_range = "*"
					}
					allow_443 = {
						priority = 200
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["aks_ase"]
						destination_port_range = "443"
					}
					allow_probes = {
						priority = 201
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_ranges = [ "80", "443", "16001" ]
					}
					allow_deployment = {
						priority = 300
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = local.build_pool_address_space[local.basic["local"].region_short]
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["aks_ase"]
						destination_port_ranges = [ "21", "990", "10001-10020", "8172" ]
					}
					allow_app_service_management = {
						priority = 400
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AppServiceManagement"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["aks_ase"]
						destination_port_ranges = [ "454", "455" ]
					}
					block_all = {
						priority = 4096
						direction = "Inbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					venafi-cert-auto-tcp-in = {
						priority = 1713
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = local.venafi-nsg-rules.source_address_prefix
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_ranges = local.venafi-nsg-rules.destination_port_range
					}
					thousand-eye-snmp-udp-in = {
						priority = 1702
						direction = "Inbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefixes = local.thousand-eye-snmp-udp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.thousand-eye-snmp-udp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
				}
			)
		}
		bastion = {
			name = "bastion"
			numeric = "01"
			rg_ref = "net"
			rules = {
				#----- Inbound rules
				AllowHttpsInbound = {
					priority = 120
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "Internet"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "443"
				}
				AllowGatewayManagerInbound = {
					priority = 130
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "GatewayManager"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "443"
				}
				AllowAzureLoadBalancerInbound = {
					priority = 140
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "443"
				}
				AllowBastionHostCommunication = {
					priority = 150
					direction = "Inbound"
					access = "Allow"
					protocol = "*"
					source_address_prefix = "VirtualNetwork"
					source_port_range = "*"
					destination_address_prefix = "VirtualNetwork"
					destination_port_ranges = [ "8080", "5701" ]
				}
				block_all = {
					priority = 4096
					direction = "Inbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
				#----- Outbound rules
				AllowSshRdpOutbound = {
					priority = 100
					direction = "Outbound"
					access = "Allow"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "VirtualNetwork"
					destination_port_ranges = [ "22", "3389" ]
				}
				AllowAzureCloudOutbound = {
					priority = 110
					direction = "Outbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "AzureCloud"
					destination_port_range = "443"
				}
				AllowBastionCommunication = {
					priority = 120
					direction = "Outbound"
					access = "Allow"
					protocol = "*"
					source_address_prefix = "VirtualNetwork"
					source_port_range = "*"
					destination_address_prefix = "VirtualNetwork"
					destination_port_ranges = [ "8080", "5701" ]
				}
				AllowGetSessionInformation = {
					priority = 130
					direction = "Outbound"
					access = "Allow"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "Internet"
					destination_port_range = "80"
				}
			}
		}
		default = {
			name = "default"
			numeric = "01"
			rg_ref = "net"
			rules = {
			}
		}
		dns = {
			name = "dns"
			numeric = "01"
			rg_ref = "net"
			rules = {
				allow_port_53_udp = {
					priority = 100
					direction = "Inbound"
					access = "Allow"
					protocol = "Udp"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "53"
				}
				allow_port_53_tdp = {
					priority = 101
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "53"
				}
				allow_probe_port_53_udp = {
					priority = 102
					direction = "Inbound"
					access = "Allow"
					protocol = "Udp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "53"
				}
				allow_probe_port_53_tcp = {
					priority = 103
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "53"
				}
				allow_port_22_ent = {
					priority = 110
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix_subnet_refs = distinct(concat(
						[
							"backhaul_bastion",
						],
						(var.create_wvd_infra == true ? [ "wvd_wvd" ] : []),
					))
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "22"
				}
				allow_port_22_deploy = {
					priority = 111
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					#source_address_prefix = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].address_space
					source_address_prefix = local.build_pool_address_space[local.basic["local"].region_short]
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "22"
				}
				block_all = {
					priority = 4096
					direction = "Inbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
			}
		}		
		nginx = {
			full_name = "nsg-ngxe${local.basic["local"].env_short}${local.basic["local"].region_short}"
			#name = "ngxe"
			#numeric = "01"
			rg_ref = "compute"
			rules = {
				allow_port_80 = {
					priority = 100
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "10.0.0.0/8"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "80"
				}
				allow_port_443 = {
					priority = 101
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "10.0.0.0/8"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "443"
				}
				allow_port_22_ent = {
					priority = 103
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix_subnet_refs = distinct(concat(
						[
							"backhaul_bastion",
						],
						(var.create_wvd_infra == true ? [ "wvd_wvd" ] : []),
					))
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "22"
				}
				allow_port_22_deploy = {
					priority = 104
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					#source_address_prefix = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].address_space
					source_address_prefix = local.build_pool_address_space[local.basic["local"].region_short]
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "22"
				}
				allow_probe_port_80 = {
					priority = 105
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "80"
				}
				allow_probe_port_443 = {
					priority = 106
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "443"
				}
				allow_port_80_2 = {
					priority = 107
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "172.16.0.0/12"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "80"
				}
				allow_port_443_2 = {
					priority = 108
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "172.16.0.0/12"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "443"
				}
				allow_port_8001 = {
					priority = 109
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "10.0.0.0/8"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "8001"
				}
				allow_probe_port_8001 = {
					priority = 110
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "8001"
				}
				allow_port_4431 = {
					priority = 111
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "10.0.0.0/8"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "4431"
				}
				allow_probe_port_4431 = {
					priority = 112
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "4431"
				}
				block_all = {
					priority = 4096
					direction = "Inbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
			}
		}
		plink = {
			name = "plink"
			numeric = "01"
			rg_ref = "net"
			rules = merge(
				{
					allow_sql_1433 = {
						priority = 100
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = concat(
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].aks,
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].wvd,
							[ local.network_subnet_address_prefixes["app_redis"] ],
						)
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_plink"]
						destination_port_range = "1433"
					}
					block_all = {
						priority = 4096
						direction = "Inbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
				},
				(local.my_mg.firewall_whitelist.enterprise_trusted_to_resources ?
					{
						allow_sql_1433_ent = {
							priority = 101
							direction = "Inbound"
							access = "Allow"
							protocol = "Tcp"
							source_address_prefix = "10.0.0.0/8"
							source_port_range = "*"
							destination_address_prefix = local.network_subnet_address_prefixes["app_plink"]
							destination_port_range = "1433"
						}
					} : {}
				)
			)
		}
		print = {
			name = "print"
			numeric = "01"
			rg_ref = "net"
			rules = merge(
				# Inbound rules
				{
					alb_probe_443 = {
						priority = 100
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_print"
						destination_port_range = "443"
					}
					inbound_port_443 = {
						priority = 110
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_refs = distinct(concat(
							[ for k, v in local.network_vnets["aks"].subnets : "aks_${k}" if lookup(v, "is_aks_nodepool", false) ],
							# This rule is only added when internal web is false because it will cause an error regarding overlapping IP ranges if both are included
							(var.create_wvd_infra && local.my_mg.firewall_whitelist.enterprise_trusted_to_internal_web == false ? [ "wvd_wvd" ] : [])
						))
						source_address_prefixes = (local.my_mg.firewall_whitelist.enterprise_trusted_to_internal_web ? [ "10.0.0.0/8" ] : [])
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_print"
						destination_port_range = "443"
					}
					inbound_build_winrm = {
						priority = 120
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = local.build_pool_address_space[local.basic["local"].region_short]
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_print"
						destination_port_range = "5986"
					}
					rdp_from_bastion = {
						priority = 130
						direction = "Inbound"
						access = "Allow"
						protocol = "*"
						source_address_prefix_subnet_ref = "backhaul_bastion"
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_print"
						destination_port_range = "3389"
					}
					block_all = {
						priority = 4096
						direction = "Inbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					thousand-eye-snmp-udp-in = {
						priority = 1702
						direction = "Inbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefixes = local.thousand-eye-snmp-udp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.thousand-eye-snmp-udp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					venafi-cert-auto-tcp-in = {
						priority = 1713
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = local.venafi-nsg-rules.source_address_prefix
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_ranges = local.venafi-nsg-rules.destination_port_range
					}
					cyberark-tcp-in = {
						priority = 1164
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = local.cyberark-tcp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.cyberark-tcp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					cyberark-udp-in = {
						priority = 1165
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = local.cyberark-udp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.cyberark-udp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					# Outbound rules
					outbound_aks_ingress_controller = {
						priority = 100
						direction = "Outbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_ref = "win_print"
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "backhaul_dmz"
						destination_port_range = "443"
					}
					outbound_ad_domains_tcp = {
						priority = 110
						direction = "Outbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_ref = "win_print"
						source_port_range = "*"
						destination_address_prefixes = distinct(flatten([ for k, v in local.ad_domains : v.ip_addresses]))
						destination_port_range = "*"
					}
					outbound_ad_domains_udp = {
						priority = 111
						direction = "Outbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefix_subnet_ref = "win_print"
						source_port_range = "*"
						destination_address_prefixes = distinct(flatten([ for k, v in local.ad_domains : v.ip_addresses]))
						destination_port_range = "*"
					}
					outbound_block_internal = {
						priority = 4096
						direction = "Outbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "10.0.0.0/8"
						destination_port_range = "*"
					}
				},
				(length(local.print_mappings[local.my_mg_ref]) > 0 ?
					# Allow TCP and UDP to any print servers
					{ "outbound_printers_tcp" = {
						priority = 200
						direction = "Outbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_ref = "win_print"
						source_port_range = "*"
						destination_address_prefixes = [ for k, v in local.print_mappings[local.my_mg_ref] : "${local.printers[v].ip_address}/32" ]
						destination_port_range = "*"
					}
					"outbound_printers_udp" = {
						priority = 201
						direction = "Outbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefix_subnet_ref = "win_print"
						source_port_range = "*"
						destination_address_prefixes = [ for k, v in local.print_mappings[local.my_mg_ref] : "${local.printers[v].ip_address}/32" ]
						destination_port_range = "*"
					}}
					:
					{}
				),
				(var.create_wvd_infra ?
					 {
						 rdp_from_wvd = {
								priority = 200
								direction = "Inbound"
								access = "Allow"
								protocol = "*"
								source_address_prefix_subnet_ref = "wvd_wvd"
								source_port_range = "*"
								destination_address_prefix_subnet_ref = "win_print"
								destination_port_range = "3389"
						}
						port80_from_wvd = {
								priority = 201
								direction = "Inbound"
								access = "Allow"
								protocol = "*"
								source_address_prefix_subnet_ref = "wvd_wvd"
								source_port_range = "*"
								destination_address_prefix_subnet_ref = "win_print"
								destination_port_range = "80"
						}
						port443_from_wvd = {
								priority = 202
								direction = "Inbound"
								access = "Allow"
								protocol = "*"
								source_address_prefix_subnet_ref = "wvd_wvd"
								source_port_range = "*"
								destination_address_prefix_subnet_ref = "win_print"
								destination_port_range = "443"
						}
					}
					:
					{}
				),
			)
		}
		redis = {
			name = "redis"
			numeric = "01"
			rg_ref = "net"
			rules = merge(
				{
					allow_6380 = {
						priority = 100
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = concat(
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].aks,
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].wvd,
							[ local.network_subnet_address_prefixes["app_redis"] ],
						)
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "6380"
					}
					allow_6380_alb = {
						priority = 101
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "6380"
					}
					allow_8443 = {
						priority = 110
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "8443"
					}
					allow_8500_tcp = {
						priority = 120
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "8500"
					}
					allow_8500_udp = {
						priority = 121
						direction = "Inbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "8500"
					}
					allow_10221_to_10231 = {
						priority = 130
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = concat(
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].aks,
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].wvd,
							[ local.network_subnet_address_prefixes["app_redis"] ],
						)
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "10221-10231"
					}
					allow_10221_to_10231_alb = {
						priority = 131
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "10221-10231"
					}
					allow_13000_to_13999 = {
						priority = 140
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = concat(
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].aks,
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].wvd,
							[ local.network_subnet_address_prefixes["app_redis"] ],
						)
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "13000-13999"
					}
					allow_13000_to_13999_alb = {
						priority = 141
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "13000-13999"
					}
					allow_15000_to_15999 = {
						priority = 150
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = concat(
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].aks,
							local.my_env.vnet_address_spaces[local.basic["local"].region_short].wvd,
							[ local.network_subnet_address_prefixes["app_redis"] ],
						)
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "15000-15999"
					}
					allow_15000_to_15999_alb = {
						priority = 151
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "15000-15999"
					}
					allow_16001_tcp = {
						priority = 160
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "16001"
					}
					allow_16001_udp = {
						priority = 161
						direction = "Inbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "16001"
					}
					allow_20226 = {
						priority = 170
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						source_port_range = "*"
						destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
						destination_port_range = "20226"
					}
					block_all = {
						priority = 4096
						direction = "Inbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
				},
				(local.my_mg.firewall_whitelist.enterprise_trusted_to_resources ?
					{
						allow_6380_ent = {
							priority = 102
							direction = "Inbound"
							access = "Allow"
							protocol = "Tcp"
							source_address_prefix = "10.0.0.0/8"
							source_port_range = "*"
							destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
							destination_port_range = "6380"
						}
						allow_10221_to_10231_ent = {
							priority = 132
							direction = "Inbound"
							access = "Allow"
							protocol = "Tcp"
							source_address_prefix = "10.0.0.0/8"
							source_port_range = "*"
							destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
							destination_port_range = "10221-10231"
						}
						allow_13000_to_13999_ent = {
							priority = 142
							direction = "Inbound"
							access = "Allow"
							protocol = "Tcp"
							source_address_prefix = "10.0.0.0/8"
							source_port_range = "*"
							destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
							destination_port_range = "13000-13999"
						}
						allow_15000_to_15999_ent = {
							priority = 152
							direction = "Inbound"
							access = "Allow"
							protocol = "Tcp"
							source_address_prefix = "10.0.0.0/8"
							source_port_range = "*"
							destination_address_prefix = local.network_subnet_address_prefixes["app_redis"]
							destination_port_range = "15000-15999"
						}
					} : {}
				)
			)
		}
		ssrs = {
			name = "ssrs"
			numeric = "01"
			rg_ref = "net"
			rules = merge(
				# Inbound rules
				{
					alb_probe_443 = {
						priority = 100
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix = "AzureLoadBalancer"
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_ssrs"
						destination_port_range = "443"
					}
					inbound_port_443 = {
						priority = 110
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_refs = distinct(concat(
							[ for k, v in local.network_vnets["aks"].subnets : "aks_${k}" if lookup(v, "is_aks_nodepool", false) ],
							[
								"backhaul_dmz",
							],
							# This rule is only added when internal web is false because it will cause an error regarding overlapping IP ranges if both are included
							(var.create_wvd_infra && local.my_mg.firewall_whitelist.enterprise_trusted_to_internal_web == false ? [ "wvd_wvd" ] : [])
						))
						#source_address_prefixes = (local.my_mg.firewall_whitelist.enterprise_trusted_to_internal_web ? [ "10.0.0.0/8" ] : [])
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_ssrs"
						destination_port_range = "443"
					}
					inbound_build_winrm = {
						priority = 120
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						#source_address_prefix = data.terraform_remote_state.common.outputs.build_servers[local.my_env_region_ref].address_space
						source_address_prefix = local.build_pool_address_space[local.basic["local"].region_short]
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_ssrs"
						destination_port_range = "5986"
					}
					rdp_from_bastion = {
						priority = 130
						direction = "Inbound"
						access = "Allow"
						protocol = "*"
						source_address_prefix_subnet_ref = "backhaul_bastion"
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "win_ssrs"
						destination_port_range = "3389"
					}
					cyberark-tcp-in = {
						priority = 1164
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = local.cyberark-tcp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.cyberark-tcp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					cyberark-udp-in = {
						priority = 1165
						direction = "Inbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefixes = local.cyberark-udp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.cyberark-udp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					block_all = {
						priority = 4096
						direction = "Inbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					thousand-eye-snmp-udp-in = {
						priority = 1702
						direction = "Inbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefixes = local.thousand-eye-snmp-udp-in-nsg-rules.source_address_prefix
						source_port_ranges = local.thousand-eye-snmp-udp-in-nsg-rules.source_port_range
						destination_address_prefix = "*"
						destination_port_range = "*"
					}
					# Outbound rules
					outbound_aks_ingress_controller = {
						priority = 100
						direction = "Outbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_ref = "win_ssrs"
						source_port_range = "*"
						destination_address_prefix_subnet_ref = "backhaul_dmz"
						destination_port_range = "443"
					}
					outbound_ad_domains_tcp = {
						priority = 110
						direction = "Outbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_ref = "win_ssrs"
						source_port_range = "*"
						destination_address_prefixes = distinct(flatten([ for k, v in local.ad_domains : v.ip_addresses]))
						destination_port_range = "*"
					}
					outbound_ad_domains_udp = {
						priority = 111
						direction = "Outbound"
						access = "Allow"
						protocol = "Udp"
						source_address_prefix_subnet_ref = "win_ssrs"
						source_port_range = "*"
						destination_address_prefixes = distinct(flatten([ for k, v in local.ad_domains : v.ip_addresses]))
						destination_port_range = "*"
					}
					outbound_mail_relays = {
						priority = 200
						direction = "Outbound"
						access = "Allow"
						protocol = "Tcp"
						source_address_prefix_subnet_ref = "win_ssrs"
						source_port_range = "*"
						destination_address_prefixes = [ "10.133.26.11", "10.111.26.11" ]
						destination_port_range = "25"
					}
					outbound_block_internal = {
						priority = 4096
						direction = "Outbound"
						access = "Deny"
						protocol = "*"
						source_address_prefix = "*"
						source_port_range = "*"
						destination_address_prefix = "10.0.0.0/8"
						destination_port_range = "*"
					}
				},
				(var.create_wvd_infra ?
					 {
						 rdp_from_wvd = {
								priority = 200
								direction = "Inbound"
								access = "Allow"
								protocol = "*"
								source_address_prefix_subnet_ref = "wvd_wvd"
								source_port_range = "*"
								destination_address_prefix_subnet_ref = "win_ssrs"
								destination_port_range = "3389"
						}
						port443_from_wvd = {
								priority = 202
								direction = "Inbound"
								access = "Allow"
								protocol = "*"
								source_address_prefix_subnet_ref = "wvd_wvd"
								source_port_range = "*"
								destination_address_prefix_subnet_ref = "win_ssrs"
								destination_port_range = "443"
						}
					}
					:
					{}
				),
			)
		}
	},
	(var.create_wvd_infra ?
		{ wvd = {
			name = "wvd"
			numeric = "01"
			rg_ref = "wvd"
			rules = {
				allow_sccm_adaptiva_udp = {
					priority = 102
					direction = "Inbound"
					access = "Allow"
					protocol = "Udp"
					source_address_prefixes = [ "10.164.0.96/27", "170.88.164.0/27", "170.88.8.0/27", ]
					source_port_range = "*"
					destination_address_prefixes = [ "10.0.0.0/8", "172.16.0.0/12", "170.88.0.0/16", ]
					destination_port_ranges = [ "34321-34325", "34329", "34331", "34333", "34335", "34337", "34339", "34341", "34343", "34345", "34545", "34546", "34750", "34760", ]
				}
				allow_sccm_adaptiva_tcp = {
					priority = 101
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefixes = [ "10.164.0.96/27", "170.88.164.0/27", "170.88.8.0/27", ]
					source_port_range = "*"
					destination_address_prefixes = [ "10.0.0.0/8", "172.16.0.0/12", "170.88.0.0/16", ]
					destination_port_ranges = [ "135", "445", "2701", "3389", "34400", "34760", "49152-65535", ]
				}
				allow_rdp_from_bastion = {
					priority = 100
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix_subnet_refs = [ "backhaul_bastion", ]
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "3389"
				}
				cyberark-tcp-in = {
					priority = 1164
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefixes = local.cyberark-tcp-in-nsg-rules.source_address_prefix
					source_port_ranges = local.cyberark-tcp-in-nsg-rules.source_port_range
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
				cyberark-udp-in = {
					priority = 1165
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefixes = local.cyberark-udp-in-nsg-rules.source_address_prefix
					source_port_ranges = local.cyberark-udp-in-nsg-rules.source_port_range
					destination_address_prefix = "*"
					destination_port_range = "*"
					}
				block_all = {
					priority = 4096
					direction = "Inbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
				thousand-eye-snmp-udp-in = {
					priority = 1702
					direction = "Inbound"
					access = "Allow"
					protocol = "Udp"
					source_address_prefixes = local.thousand-eye-snmp-udp-in-nsg-rules.source_address_prefix
					source_port_ranges = local.thousand-eye-snmp-udp-in-nsg-rules.source_port_range
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
			}
		}}
		:
		null
	),
	(length(keys(local.apim_instances_to_install)) > 0 ?
		{ apim = {
			name = "apim"
			numeric = "01"
			rg_ref = "net"
			rules = {
				inbound_allow_local_subnet = {
					priority = 100
					direction = "Inbound"
					access = "Allow"
					protocol = "*"
					source_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					source_port_range = "*"
					destination_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					destination_port_range = "*"
				}
				inbound_allow_from_nginx = {
					priority = 200
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.network_subnet_address_prefixes["backhaul_dmz"]
					source_port_range = "*"
					destination_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					destination_port_range = "443"
				}
				inbound_allow_apim_management = {
					priority = 1000
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "ApiManagement"
					source_port_range = "*"
					destination_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					destination_port_range = "3443"
				}
				inbound_allow_alb = {
					priority = 1001
					direction = "Inbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = "AzureLoadBalancer"
					source_port_range = "*"
					destination_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					destination_port_range = "6390"
				}
				inbound_deny_all = {
					priority = 4096
					direction = "Inbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
				outbound_allow_to_aks = {
					priority = 100
					direction = "Outbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					source_port_range = "*"
					destination_address_prefix = local.network_subnet_address_prefixes["aks_default_nodepool"]
					destination_port_range = "443"
				}
				outbound_allow_storage = {
					priority = 1000
					direction = "Outbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					source_port_range = "*"
					destination_address_prefix = "Storage"
					destination_port_range = "443"
				}
				outbound_allow_sql = {
					priority = 1001
					direction = "Outbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					source_port_range = "*"
					destination_address_prefix = "Sql"
					destination_port_range = "1433"
				}
				outbound_allow_key_vault = {
					priority = 1002
					direction = "Outbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					source_port_range = "*"
					destination_address_prefix = "AzureKeyVault"
					destination_port_range = "443"
				}
				outbound_allow_monitoring = {
					priority = 1003
					direction = "Outbound"
					access = "Allow"
					protocol = "Tcp"
					source_address_prefix = local.network_subnet_address_prefixes["aks_apim2"]
					source_port_range = "*"
					destination_address_prefix = "AzureMonitor"
					destination_port_ranges = [ "1886", "443" ]
				}
				outbound_deny_all = {
					priority = 4096
					direction = "Outbound"
					access = "Deny"
					protocol = "*"
					source_address_prefix = "*"
					source_port_range = "*"
					destination_address_prefix = "*"
					destination_port_range = "*"
				}
			}
		}} : {}
	),
)

network_route_tables = merge(
	{
		default = {
			name = "default"
			numeric = "01"
			add_default_to_backhaul_firewall = true
		}
	},
	(length(keys(local.apim_instances_to_install)) > 0 ? {
		apim = {
			name = "apim"
			numeric = "01"
			internet_routes = {
				apim_management = "ApiManagement"
			}
			add_default_to_backhaul_firewall = true
		}
	} : {})
)

network_public_ips = {
	bastion = {
		name = "bastion"
		numeric = "01"
	}
	firewall = {
		name = "frw-backhaul"
		numeric = "01"
	}
}

network_firewalls = {
	backhaul = {
		name = "backhaul"
		numeric = "01"
		subnet = "backhaul_firewall"
		pip = "firewall"
	}
}

network_bastions = {
	backhaul = {
		name = ""
		numeric = "01"
		subnet = "backhaul_bastion"
		pip = "bastion"
	}
}

build_pool_address_space = {
	eus2 = "172.31.4.0/25"
	wus2 = "172.31.4.128/25"
}

venafi-nsg-rules = {
	source_address_prefix = [ "170.88.175.60", "170.88.175.55", "170.88.174.10", "170.88.174.12" ]
	destination_port_range = [ "1311", "18072", "18080-18085", "18090-18094", "1920", "2083", "2087", "2096","22", "2211", "2484", "28080", "2949", "3268","3269", "3414", "443-449", "465", "4712", "4843", "5223", "5358", "563", "636", "6619", "6679", "6697", "695", "7002", "80" ,"8080", "8222", "8243", "8333", "8443", "8878", "8881", "8882", "9043", "9090", "9091", "9443", "981-995"]
}

cyberark-tcp-in-nsg-rules = {
	source_address_prefix = [ "170.88.174.48/28" ]
	source_port_range = [ "22", "88", "135", "137", "139", "389", "636", "443", "445", "1433", "49152-65535"]
}

cyberark-udp-in-nsg-rules = {
	source_address_prefix = [ "170.88.174.48/28" ]
	source_port_range = [ "137", "138", "1434"]
}

thousand-eye-snmp-udp-in-nsg-rules = {
	source_address_prefix = [ "10.111.25.135", "10.111.25.241","10.118.12.74", "10.118.12.90", "10.119.25.170", "10.133.25.54", "10.133.25.98" ,"10.164.157.181", "10.165.157.180" , "10.230.16.120", ]
	source_port_range = [ "161","162"]
}

}
