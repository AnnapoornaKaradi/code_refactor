locals {

servicelink_environments = {
	# This environment is used during build pool upgrades so Terraform isn't running on a build pool which will be destroyed.
	core = {
		management_group = "prod"
		geo_env_member = false
		geo_env_active = false
		name = "Core"
		name_short = "core"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		vnet_address_spaces = null
		exceptions = [
		]
	}
	common = {
		management_group = "prod"
		geo_env_member = false
		geo_env_active = false
		name = "Common"
		name_short = "common"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		vnet_address_spaces = {
			eus2 = {
				win = [ "10.143.80.0/24" ]
				dev-fcx = [ "10.79.178.0/24" ]
				nonprod-fcx = [ "10.79.162.0/24" ]
				prod-fcx = [ "10.79.130.0/24" ]
			}
			wus2 = {
				win = [ "10.163.32.0/24" ]
				dr-fcx = [ "10.79.146.0/24" ]
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-2"
			encryption_key_suffixes = [
				"28NOV2023-1",
			]
			encryption_key_use = "28NOV2023-1"
		}
		old_keepers = {
			disk_encryption_key_suffixes = [
				"29MAR2022-1",
			]
			disk_encryption_use_key = "29MAR2022-1"
			network_enc_key_suffixes = [
				"7APR2021-1"
			]
			network_enc_key_use = "7APR2021-1"
			terra_enc_key_suffixes = [
				"8APR2021-1"
			]
			terra_enc_key_use = "8APR2021-1"
		}
		exceptions = [
			"tools_storage_firewall",
		]
	}
	sandbox = {
		management_group = "sandbox"
		geo_env_member = true
		geo_env_active = false
		name = "Sandbox"
		name_short = "sandbox"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v44"
		salesforce_adf_username = "sla.datawarehouse@servicelinkauction.com.sandbox"
		salesforce_client_id = "3MVG9eExlsU2GHz4.vbaoGj35oqcoDSGogdbd5hgb_Xrd0zXO_qsj3QXdyhb_5wqyXfx1HLzydU70WI82rm3U"
		salesforce_environment_url = "https://servicelinkauction--dev2a.sandbox.my.salesforce.com"
		nginx_edge_hsm = {
			eus2 = {
				ha-enabled = true
				partition_name = "par-dev-ha"
				ca_cert_names = [
					"HSM--SandboxCACert1",
					"HSM--SandboxCACert2",
				]
				partition_name = "par-use2-dev01"
				devices = [
					{
						numeric = "00"
						ip = "10.151.0.4"
						port = "1792"
						htl = "0"
					}
				]
			}
		}
		vnet_address_spaces = {
			eus2 = {
				app = [ "10.143.100.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.143.101.0/24" ]
				win = [ "10.143.111.0/24" ]
				wvd = [ "10.143.144.0/26" ]
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-2"
			encryption_key_suffixes = [
				"15APR2021-1",
				"28NOV2023-1",
			]
			encryption_key_use = "28NOV2023-1"
		}
		old_keepers = {
			app_key_rotate_id = "10/1/2020 - 1"
			disk_encryption_key_suffixes = [
				"11JAN2021-1",
				"12JAN2021-1"
			]
			reportingdb_cmk_key_suffixes = [
				"30MAR2021-1"
			]
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		diag_logging_excluded_resource_groups = [
			"databricks-rg-testing-k22yzghyvrn44",
			"azureml-rg-DataScience-AMLRegistryPOC_7b24177f-8e88-4caf-add9-9c99d006f620",
		]
		exceptions = [
			"network_refactor_local_testing",
			"kv_non_declarative_perms",
			"sandbox_name_shrink",
		]
	}
	sand9 = {
		management_group = "sandbox"
		geo_env_member = false
		geo_env_active = false
		name = "Sandbox9"
		name_short = "sand9"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v43"
		vnet_address_spaces = {
			eus2 = {
				app = [ "10.163.53.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.163.55.0/24" ]
				win = [ "10.143.147.0/24" ]
				wvd = [ "10.143.146.0/26" ]
			}
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		exceptions = [
			"network_refactor_local_testing",
			"kv_non_declarative_perms",
		]
	}
	dev2 = {
		management_group = "dev"
		geo_env_member = false
		geo_env_active = false
		name = "Development2"
		name_short = "dev2"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		salesforce_adf_username = "sla.datawarehouse@servicelinkauction.com.dev2a"
		salesforce_client_id = "3MVG9eExlsU2GHz4.vbaoGj35oqcoDSGogdbd5hgb_Xrd0zXO_qsj3QXdyhb_5wqyXfx1HLzydU70WI82rm3U"
		salesforce_environment_url = "https://servicelinkauction--dev2a.sandbox.my.salesforce.com"
		fnf_wvd_prod_01_developer_machines_ips = [ "52.254.39.161", ]
		fnf_wvd_prod_01_developer_machines_ip_ranges = [ "52.254.39.161-52.254.39.161", ]
		fnf_wvd_prod_01_developer_machines_subnet_id = "/subscriptions/23f8ad78-24e0-4424-a601-3b973060240e/resourceGroups/FNF-RG-WVD-Networking-PROD/providers/Microsoft.Network/virtualNetworks/vn-prod_wvd-use2-01/subnets/sn-10.44.128.0_20"
		adf_warehouse_endpoint = "tn5ybcw2alzupkidpenefirilq-h3yidvnzn27u7m6scbq6smtg44.datawarehouse.fabric.microsoft.com"
		adf_warehouse_artifact_id = "7f53b7b4-9e50-412c-ae02-5664ca3d206a"
		adf_warehouse_workspace_id = "d581f03e-6eb9-4fbf-b3d2-1061e93266e7"
		adf_service_principal_id = "6ddf303d-110d-47ab-bbb1-701e1ab6e1c4"
		adf_service_object_id = "0f680e12-8212-4f41-a61c-5eceddd4892f"
		adf_lakehouse_workspace_id = "d581f03e-6eb9-4fbf-b3d2-1061e93266e7"
		adf_lakehouse_artifact_id = "ef8c844b-eff1-43eb-b3b2-44422d46ad53"
		additional_cnames = {
			blog_svclnk = {
				name = "blog.svclnk"
				record = "blog.svclnk.dev2.exostechnology.com.00d3k000000tr3feae.live.siteforce.com"
			}
		}
		nginx_edge_hsm = {
			eus2 = {
				ha-enabled = true
				partition_name = "par-dev-ha"
				ca_cert_names = [
					"HSM--NonProdEastCACert1"
				]
				virtualtoken = {
					serialnumber = "11520917000091"
					members = "1520917000091,1336510508282"
					standbymembers = "1336510508282"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.0.5"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.6.4"
						port = "1792"
						htl = "0"
					}
				]
			}
		}
		vnet_address_spaces = {
			eus2 = {
				app = [ "10.143.136.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.143.137.0/24" ]
				win = [ "10.143.132.0/24" ]
				wvd = [ "10.143.110.128/27" ]
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-1"
			encryption_key_suffixes = [
				"15APR2021-1",
				"27NOV2023-1",
			]
			encryption_key_use = "27NOV2023-1"
		}
		old_keepers = {
			disk_encryption_key_suffixes = [
				"11JAN2021-1",
				"12JAN2021-1"
			]
			reportingdb_cmk_key_suffixes = [
				"30MAR2021-1",
				"1APR2021-1"
			]
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		exceptions = [
			"network_refactor_local_testing",
			"sl_exos_all_will_never_die",
			"kv_non_declarative_perms",
			"db_perms_exosapparchivedb_ordertrackingdb",
			"old_spark_to_service_bus",
		]
	}
	perf = {
		management_group = "nonprod"
		geo_env_member = true
		geo_env_active = true
		name = "Performance"
		name_short = "perf"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		salesforce_adf_username = "sla.datawarehouse@servicelinkauction.com.perf"
		salesforce_client_id = "3MVG9CXa9eR3sUEDllG7cM0cn0xJ5GUYB0n4GSkp5PQK.RX7DXIbLv5zTYzKuZrVOrjKAI1PpZgY0Gn.iyVHh"
		salesforce_environment_url = "https://servicelinkauction--perf.sandbox.my.salesforce.com"
		adf_service_principal_id = "6ddf303d-110d-47ab-bbb1-701e1ab6e1c4"
		adf_service_object_id = "0f680e12-8212-4f41-a61c-5eceddd4892f"		
		additional_cnames = {
			blog_svclnk = {
				name = "blog.svclnk"
				record = "blog.svclnk.perf.exostechnology.com.00d3k000000tr3feae.live.siteforce.com"
			}
		}
		nginx_edge_hsm = {
			eus2 = {
				ha-enabled = true
				partition_name = "par-dev-ha"
				ca_cert_names = [
					"HSM--NonProdEastCACert1"
				]
				virtualtoken = {
					serialnumber = "11520917000091"
					members = "1520917000091,1336510508282"
					standbymembers = "1336510508282"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.0.5"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.6.4"
						port = "1792"
						htl = "0"
					}
				]
			}
			wus2 = {
				ha-enabled = true
				partition_name = "par-dev-ha"
				ca_cert_names = [
					"HSM--NonProdWestCACert1"
				]
				virtualtoken = {
					serialnumber = "11336510508282"
					members = "1336510508282,1520917000091"
					standbymembers = "1520917000091"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.6.4"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.0.5"
						port = "1792"
						htl = "0"
					}
				]
			}
		}
		vnet_address_spaces = {
			eus2 = {
				app = [ "172.16.0.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.143.107.0/24" ]
				win = [ "10.143.99.0/24" ]
				wvd = [ "10.143.110.0/26" ]
			}
			wus2 = {
				app = [ "172.16.1.0/24" ]
				aks = [ "172.20.0.0/15" ]
				backhaul = [ "10.163.50.0/24" ]
				win = [ "10.163.52.0/24" ]
				wvd = [ "10.163.58.0/26" ]
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-2"
			encryption_key_suffixes = [
				"15APR2021-1",
				"28NOV2023-1",
			]
			encryption_key_use = "28NOV2023-1"
		}
		old_keepers = {
			app_key_rotate_id = "10/8/2020 - 1"
			disk_encryption_key_suffixes = [
				"11JAN2021-1",
				"12JAN2021-1"
			]
			reportingdb_cmk_key_suffixes = [
				"30MAR2021-1"
			]
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		exceptions = [
			"sl_exos_all_will_never_die",
			"kv_non_declarative_perms",
			"dev_paas_firewall_spec",
			"exos_cant_autoscale",
			"db_perms_exosapparchivedb_ordertrackingdb",
			"old_spark_to_service_bus",
		]
	}
	uat2 = {
		management_group = "nonprod"
		geo_env_member = false
		geo_env_active = false
		name = "UAT2"
		name_short = "uat2"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		salesforce_adf_username = "sla.datawarehouse@servicelinkauction.com.qa"
		salesforce_client_id = "3MVG9CXa9eR3sUEC2FcrIy2DQ1lRQDaC_XDYA9F5pnnrZLqxHBJppoy9xVEr_B8.cMiKRg9wE9.zDJQrjRWMO"
		salesforce_environment_url = "https://servicelinkauction--qa.sandbox.my.salesforce.com"
		adf_warehouse_endpoint = "tn5ybcw2alzupkidpenefirilq-mr24zrga5eue7jzu4qomtfyvze.datawarehouse.fabric.microsoft.com"
		adf_warehouse_artifact_id = "f589761a-8ee2-48ec-95d5-af23e97980ab"
        adf_warehouse_workspace_id = "c4cc7564-e9c0-4f28-a734-e41cc99715c9"
		adf_service_principal_id = "6ddf303d-110d-47ab-bbb1-701e1ab6e1c4"
		adf_service_object_id = "0f680e12-8212-4f41-a61c-5eceddd4892f"
		adf_lakehouse_workspace_id = "c4cc7564-e9c0-4f28-a734-e41cc99715c9"
		adf_lakehouse_artifact_id = "7b3938be-1464-4e5d-8908-038d4e4585af"
		additional_cnames = {
			blog_svclnk = {
				name = "blog.svclnk"
				record = "blog.svclnk.uat2.exostechnology.com.00d3k000000tr3feae.live.siteforce.com"
			}
		}
		nginx_edge_hsm = {
			eus2 = {
				ha-enabled = true
				partition_name = "par-dev-ha"
				ca_cert_names = [
					"HSM--NonProdEastCACert1"
				]
				virtualtoken = {
					serialnumber = "11520917000091"
					members = "1520917000091,1336510508282"
					standbymembers = "1336510508282"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.0.5"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.6.4"
						port = "1792"
						htl = "0"
					}
				]
			}
		}
		vnet_address_spaces = {
			eus2 = {
				app = [ "172.16.0.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.143.122.0/24", "10.143.123.0/24" ]
				win = [ "10.143.97.0/24" ]
				wvd = [ "10.143.116.64/26" ]
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-2"
			encryption_key_suffixes = [
				"15APR2021-1",
				"28NOV2023-1",
			]
			encryption_key_use = "28NOV2023-1"
		}
		old_keepers = {
			app_key_rotate_id = "10/26/2020 - 1"
			disk_encryption_key_suffixes = [
				"11JAN2021-1",
				"12JAN2021-1"
			]
			reportingdb_cmk_key_suffixes = [
				"1APR2021-1"
			]
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "",]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		exceptions = [
			"sl_exos_all_will_never_die",
			"kv_non_declarative_perms",
			"db_perms_exosapparchivedb_ordertrackingdb",
			"old_spark_to_service_bus",
			"uat2_to_qa2_migration"
		]
	}
	stage = {
		management_group = "prod"
		geo_env_member = true
		geo_env_active = false
		name = "Stage"
		name_short = "stage"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		salesforce_adf_username = "sla.datawarehouse@servicelinkauction.com.staging"
		salesforce_client_id = "3MVG9aePn9FJJ2neFMUiOCnfKmuqhRn380fBKw8rle_G4g1uWCOZrTbhvnMz_k2Uoi.T4eT3Ui96apoQANfkY"
		salesforce_environment_url = "https://servicelinkauction--staging.sandbox.my.salesforce.com"
		adf_warehouse_endpoint = "tn5ybcw2alzupkidpenefirilq-dxugozufz4ou3eycmqjwpukoji.datawarehouse.fabric.microsoft.com"
		adf_warehouse_artifact_id = "8f619a80-923e-4d28-aafb-7faa408a9a40"
        adf_warehouse_workspace_id = "67e81d-cf85-4d1d-9302-641367d14e4a"
		adf_service_principal_id = "b4c031b6-26ad-4b7e-86e9-af72d5e6a44a"
		adf_service_object_id = "bca51a2c-75ad-4fd9-b3b4-5784c7037a3b"
		adf_lakehouse_workspace_id = "6667e81d-cf85-4d1d-9302-641367d14e4a"
		adf_lakehouse_artifact_id = "3eaf0973-004d-40a1-9dd3-5ca9c8b21030"
		additional_cnames = {
			blog_svclnk = {
				name = "blog.svclnk"
				record = "blog.svclnk.stage.exostechnology.com.00d3k000000tr3feae.live.siteforce.com"
			}
			blog_svclnk_root = {
				name = "blog.svclnk"
				record = "blog.svclnk.stage.exostechnology.com.00d3k000000tr3feae.live.siteforce.com"
				zone_override = "stage.exostechnology.com"
			}
		}
		nginx_edge_hsm = {
			eus2 = {
				ha-enabled = true
				partition_name = "par-prod-ha"
				ca_cert_names = [
					"HSM--StageEastCACert1"
				]
				virtualtoken = {
					serialnumber = "11336487225220"
					members = "1336487225220,1332715369509,1387011465419"
					standbymembers = "1387011465419"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.2.4"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.2.5"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "02"
						ip = "10.151.4.5"
						port = "1792"
						htl = "0"
					}
				]
			}
		}
		vnet_address_spaces = {
			eus2 = {
				app = [ "172.16.0.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.143.106.0/24" ]
				win = [ "10.143.94.0/24" ]
				wvd = [ "10.143.110.160/27" ]
			}
			wus2 = {
				app = null
				aks = null
				backhaul = null
				win = null
				wvd = null
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-2"
			encryption_key_suffixes = [
				"15APR2021-1",
				"28NOV2023-1",
			]
			encryption_key_use = "28NOV2023-1"
		}
		old_keepers = {
			app_key_rotate_id = "12/3/2020 - 1"
			disk_encryption_key_suffixes = [
				"11JAN2021-1",
				"12JAN2021-1"
			]
			reportingdb_cmk_key_suffixes = [
				"1APR2021-1"
			]
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		exceptions = [
			"sl_exos_all_will_never_die",
			"kv_non_declarative_perms",
			"exos_cant_autoscale",
			"db_perms_exosapparchivedb_ordertrackingdb",
			"exosall_adf_to_sql",
			"old_spark_to_service_bus",
		]
	}
	prod = {
		management_group = "prod"
		geo_env_member = true
		geo_env_active = true
		name = "Production"
		name_short = "prod"
		build_pool_image_version = "v42"
		build_pool2_image_version = "v42"
		salesforce_adf_username = "sla.datawarehouse@servicelinkauction.com"
		salesforce_client_id = "3MVG9_XwsqeYoueK65rTiKm0aE08kwVC0m57BmrUzvST0x6AKEseSgmpjiNrO3MYMZwal8U3juF0s2_UzgaSL"
		salesforce_environment_url = "https://servicelinkauction.my.salesforce.com"
		adf_warehouse_endpoint = "tn5ybcw2alzupkidpenefirilq-wscdo7uujcferoogarxkfim3x4.datawarehouse.fabric.microsoft.com"
		adf_warehouse_artifact_id = "7a0d613c-0660-4d1d-9c8b-2c4a801c0101"
    	adf_warehouse_workspace_id = "7e3784b4-4894-488a-b9c6-046ea2a19bbf"
		adf_service_principal_id = "b4c031b6-26ad-4b7e-86e9-af72d5e6a44a"
		adf_service_object_id = "bca51a2c-75ad-4fd9-b3b4-5784c7037a3b"
		adf_lakehouse_workspace_id = "7e3784b4-4894-488a-b9c6-046ea2a19bbf"
		adf_lakehouse_artifact_id = "d9c291fd-5e92-43f5-b15d-e99eab3bf5f8"
		nginx_edge_hsm = {
			eus2 = {
				ha-enabled = true
				partition_name = "par-prod-ha"
				ca_cert_names = [
					"HSM--ProdEastCACert1"
				]
				virtualtoken = {
					serialnumber = "11336487225221"
					members = "1336487225221,1332715369510,1387011465420"
					standbymembers = "1387011465420"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.2.4"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.2.5"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "02"
						ip = "10.151.4.5"
						port = "1792"
						htl = "0"
					}
				]
			}
			wus2 = {
				ha-enabled = true
				partition_name = "par-prod-ha"
				ca_cert_names = [
					"HSM--ProdWestCACert1"
				]
				virtualtoken = {
					serialnumber = "11387011465420"
					members = "1387011465420,1336487225221,1332715369510"
					standbymembers = "1336487225221,1332715369510"
				}
				devices = [
					{
						numeric = "00"
						ip = "10.151.4.5"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "01"
						ip = "10.151.2.4"
						port = "1792"
						htl = "0"
					},
					{
						numeric = "02"
						ip = "10.151.2.5"
						port = "1792"
						htl = "0"
					}
				]
			}
		}
		vnet_address_spaces = {
			eus2 = {
				app = [ "172.16.0.0/24" ]
				aks = [ "172.18.0.0/15" ]
				backhaul = [ "10.143.108.0/24" ]
				win = [ "10.143.95.0/24" ]
				wvd = [ "10.143.110.192/26" ]
			}
			wus2 = {
				app = [ "172.16.1.0/24" ]
				aks = [ "172.20.0.0/15" ]
				backhaul = [ "10.163.51.0/24" ]
				win = [ "10.163.57.0/24" ]
				wvd = [ "10.163.59.0/26" ]
			}
		}
		keepers = {
			dr_mode = false
			credentials = "28NOV2023-1"
			encryption_key_suffixes = [
				"15APR2021-1",
				"27NOV2023-1",
			]
			encryption_key_use = "27NOV2023-1"
		}
		old_keepers = {
			app_key_rotate_id = "10/1/2020 - 1"
			disk_encryption_key_suffixes = [
				"11JAN2021-1",
				"12JAN2021-1"
			]
			reportingdb_cmk_key_suffixes = [
				"1APR2021-1"
			]
		}
		app_enc_keys = {
			key--exos-svclnk = {
				kv_secret_prefix = "key--exos-svclnk"
				app_config_key_name = "ExosMacro:Encryption:SvclnkKey"
				versions = [
					"",
					#"-21JAN2021-1"  This is an example of the next key name, since the first one won't have a suffix
				]
				use_version = ""
			}
			key--exos-automation = {
				kv_secret_prefix = "key--exos-automation"
				app_config_key_name = "ExosMacro:Encryption:AutomationKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-boa = {
				kv_secret_prefix = "key--exos-boa"
				app_config_key_name = "ExosMacro:Encryption:BoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dbhashing-salt = {
				kv_secret_prefix = "key--exos-dbhashing-salt"
				app_config_key_name = "ExosMacro:Encryption:SvclnkDbHashSaltKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms = {
				kv_secret_prefix = "key--exos-dms"
				app_config_key_name = "ExosMacro:Encryption:DmsKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-dms-boa = {
				kv_secret_prefix = "key--exos-dms-boa"
				app_config_key_name = "ExosMacro:Encryption:DmsBoaKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-morganstanley = {
				kv_secret_prefix = "key--exos-morganstanley"
				app_config_key_name = "ExosMacro:Encryption:MorganStanleyKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink = {
				kv_secret_prefix = "key--exos-nationallink"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkKey"
				versions = [ "", ]
				use_version = ""
			}
			key--exos-nationallink-boa = {
				kv_secret_prefix = "key--exos-nationallink-boa"
				app_config_key_name = "ExosMacro:Encryption:NationalLinkBoaKey"
				versions = [ "", ]
				use_version = ""
			}
		}
		exceptions = [
			"els_prod_data_migration",
			"sl_exos_all_will_never_die",
			"kv_non_declarative_perms",
			"exos_cant_autoscale",
			"db_perms_exosapparchivedb_ordertrackingdb",
			"old_spark_to_service_bus",
			"prod_to_uat4_migration",
		]
	}
}

}
