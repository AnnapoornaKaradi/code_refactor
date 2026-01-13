locals {
event_hub_instances = {
	app = {
		name = "app"
		numeric = "01"
		rg_ref = "data"
		sku = "Standard"
		capacity = {
			default = 1
			env_override = {
				perf = 4
				prod = 4
			}
		}
		minimum_tls_version = {
			default = 1.2
			env_override = {
			}
		}
		auto_inflate = false
		injections = {
			default_primary_connection_string = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--VIPConnectionString"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:VIPConnectionString"
				app_config_ref = "app"
			}
			default_secondary_connection_string = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--VIPConnectionStringSecondary"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:VIPConnectionStringSecondary"
				app_config_ref = "app"
			}
		}
		network_acls = {
			default_action = "Deny"
			bypass = "None"
			ips = local.resource_firewall_with_services.ips
			subnet_ids = local.resource_firewall_with_services.subnet_ids
			subnet_id_refs = local.resource_firewall_with_services.subnet_id_refs
		}
	}
	cdcgroup1 = {
		name = "cdcgroup"
		numeric = "01"
		rg_ref = "data"
		sku = "Standard"
		capacity = {
			default = 1
			env_override = {
				perf = 4
				prod = 4
			}
		}
		minimum_tls_version = {
			default = 1.2
			env_override = {
			}
		}
		auto_inflate = false
		injections = {
			default_primary_connection_string = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP1ConnectionString"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP1ConnectionString"
				app_config_ref = "app"
			}
			default_secondary_connection_string = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP1ConnectionStringSecondary"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP1ConnectionStringSecondary"
				app_config_ref = "app"
			}
			default_primary_connection_string_adl = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP1ConnectionString"
				kv_ref = "adl"
			}
			default_secondary_connection_string_adl = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP1ConnectionStringSecondary"
				kv_ref = "adl"
			}		
		}
		network_acls = {
			default_action = "Deny"
			bypass = "None"
			ips = local.resource_firewall_with_services.ips
			subnet_ids = local.resource_firewall_with_services.subnet_ids
			subnet_id_refs = local.resource_firewall_with_services.subnet_id_refs
		}
		env_managed_private_endpoints_override = {
			dev2 = [ "178cfcc7-9c21-4c92-b49a-55d69549b078" ]
			uat2 = [ "3f6250c9-ea52-4569-8707-f9158d4f85d4" ]
			stage = [ "609bf4dc-2095-420e-aa84-6b8bbd392a17" ]
			prod = [ "f9de06e9-0234-4fc4-b6b1-a10086f056c5" ]
		}
		hubs = [
			{
				name = "exos_cdc_debezium_configs"
				partition_count = 1
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_offsets"
				partition_count = 25
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_statuses"
				partition_count = 5
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_group_1"
				partition_count = 16
				
				retention_description = {
					cleanup_policy = "Delete"
					retention_time_in_hours = 168
				}
				consumer_groups = [
					{
						name = "exos_onelake_etl"
					},
					{
						name = "SL-EXOS-Finance"
					},
					{
						name = "sl-exos-cor-workorder"
					},
					{
						name = "sl-exos-cor-workordertitle"
					},
					{
						name = "sl-exos-cor-asset"
					},
					{
						name = "sl-exos-cor-loan"
					},
					{
						name = "sl-exos-cor-order"
					},
					{
						name = "sl-exos-cor-workorderappraisal"
					},
					{
						name = "sl-exos-cor-workorderclosing"
					},
					{
						name = "sl-exos-cls-workorderclosing"
					},
					{
						name = "sl-exos-cnt-orderstakeholder"
					},
					{
						name = "sl-exos-cnt-stakeholder"
					},
					{
						name = "sl-exos-cnt-stakeholdercontactmethod"
					},	
				]
			}
		]
	}
	cdcgroup2 = {
		name = "cdcgroup"
		numeric = "02"
		rg_ref = "data"
		sku = "Standard"
		capacity = {
			default = 1
			env_override = {
				perf = 4
				prod = 4
			}
		}
		minimum_tls_version = {
			default = 1.2
			env_override = {
			}
		}
		auto_inflate = false
		injections = {
			default_primary_connection_string = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP2ConnectionString"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP2ConnectionString"
				app_config_ref = "app"
			}
			default_secondary_connection_string = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP2ConnectionStringSecondary"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP2ConnectionStringSecondary"
				app_config_ref = "app"
			}
			default_primary_connection_string_adl = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP2ConnectionString"
				kv_ref = "adl"
			}
			default_secondary_connection_string_adl = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP2ConnectionStringSecondary"
				kv_ref = "adl"
			}	
		}
		network_acls = {
			default_action = "Deny"
			bypass = "None"
			ips = local.resource_firewall_with_services.ips
			subnet_ids = local.resource_firewall_with_services.subnet_ids
			subnet_id_refs = local.resource_firewall_with_services.subnet_id_refs
		}
		env_managed_private_endpoints_override = {
			dev2 = [ "23ad0900-e4f9-4b6c-94a6-2d90b0e04fb8" ]
			uat2 = [ "5343c7b3-effe-41c6-ae95-0b4e31ad8f97" ]
			perf = [ "44232c86-f04f-4429-a1b4-5b190dd2db3b" ]
			stage = [ "f4837a21-6524-4f72-ac4c-8b5f78eae311" ]
			prod = [ "6f3ebfd2-75bc-4483-95ce-a399d47b7e23" ]
		}
		hubs = [
			{
				name = "exos_cdc_debezium_configs"
				partition_count = 1
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_offsets"
				partition_count = 25
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_statuses"
				partition_count = 5
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_group_2"
				partition_count = 16
				
				retention_description = {
					cleanup_policy = "Delete"
					retention_time_in_hours = 168
				}
				consumer_groups = [
					{
						name = "exos_onelake_etl"
					},
					{
						name = "SL-EXOS-Finance"
					},
					{
						name = "sl-exos-apt-appointment"
					},
					{
						name = "sl-exos-apt-appointmenthistory"
					},
					{
						name = "sl-exos-apt-proposedappointment"
					},
					{
						name = "sl-exos-cor-authtokendetail"
					},
					{
						name = "sl-exos-cor-vendorassignmenthistory"
					},
					{
						name = "sl-exos-cor-workorderappraisalacceptance"
					},
					{
						name = "sl-exos-cor-workorderappraisalattribute"
					},
					{
						name = "sl-exos-cor-workorderappraisalattributereason"
					},
					{
						name = "sl-exos-cor-workorderappraisalhistory"
					},
					{
						name = "sl-exos-cor-workorderclientfee"
					},
					{
						name = "sl-exos-cor-workordervendorfee"
					},
					{
						name = "sl-exos-dly-workorderdelay"
					},
					{
						name = "sl-exos-fup-vendorfollowup"
					},
					{
						name = "sl-exos-mst-workordermilestone"
					},
				]
			}
		]
	}
	cdcgroup3 = {
		name = "cdcgroup"
		numeric = "03"
		rg_ref = "data"
		sku = "Standard"
		capacity = {
			default = 1
			env_override = {
				perf = 4
				prod = 4
			}
		}
		minimum_tls_version = {
			default = 1.2
			env_override = {
			}
		}
		auto_inflate = false
		injections = {
			default_primary_connection_string = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP3ConnectionString"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP3ConnectionString"
				app_config_ref = "app"
			}
			default_secondary_connection_string = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP3ConnectionStringSecondary"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP3ConnectionStringSecondary"
				app_config_ref = "app"
			}
			default_primary_connection_string_adl = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP3ConnectionString"
				kv_ref = "adl"
			}
			default_secondary_connection_string_adl = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP3ConnectionStringSecondary"
				kv_ref = "adl"
			}	
		}
		network_acls = {
			default_action = "Deny"
			bypass = "None"
			ips = local.resource_firewall_with_services.ips
			subnet_ids = local.resource_firewall_with_services.subnet_ids
			subnet_id_refs = local.resource_firewall_with_services.subnet_id_refs
		}
		env_managed_private_endpoints_override = {
			dev2 = [ "922266bf-27b0-4ac8-b12f-05e8c1167a15" ]
			uat2 = [ "ce925de4-a469-45a0-b20a-c5619d80990d" ]
			perf = [ "a968f3db-e479-45db-a518-3c786e9a5fe6" ]
			stage = [ "5c69727e-bf2f-4edf-b0e6-15900f71443f" ]
			prod = [ "bdb165d5-087b-4ea5-aebe-0b634587282a" ]
		}
		hubs = [
			{
				name = "exos_cdc_debezium_configs"
				partition_count = 1
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_offsets"
				partition_count = 25
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_statuses"
				partition_count = 5
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_group_3"
				partition_count = 16
				
				retention_description = {
					cleanup_policy = "Delete"
					retention_time_in_hours = 168
				}
				consumer_groups = [
					{
						name = "exos_onelake_etl"
					},
					{
						name = "SL-EXOS-Finance"
					},
					{
						name = "sl-exos-ar-generalledger"
					},
					{
						name = "sl-exos-ar-generalledgerline"
					},
					{
						name = "sl-exos-ar-invoicelineitem"
					},
					{
						name = "sl-exos-ar-invoicelineitemmilestone"
					},
					{
						name = "sl-exos-ar-invoiceworkorder"
					},
					{
						name = "sl-exos-ar-workorderreference"
					},
					{
						name = "sl-exos-cor-workordertask"
					},					
					{
						name = "sl-exos-cor-workordertaskhistory"
					},
					{
						name = "sl-exos-cor-workorderupdate"
					},
					{
						name = "sl-exos-nte-workordernote"
					},
					{
						name = "sl-exos-orderdelaydbdly-workorderdelay"
					},
					{
						name = "sl-exos-pay-workorderpayment"
					},
					{
						name = "sl-exos-pra-workorderprovideraction"
					},
					{
						name = "sl-exos-ful-desktopvendoracknowledgement"
					},
					{
						name = "sl-exos-trk-workorderproductchange"
					},
					{
						name = "sl-exos-cor-workorderinspectiontracking"
					},
				]
			}
		]
	}
	cdcgroup4 = {
		name = "cdcgroup"
		numeric = "04"
		rg_ref = "data"
		sku = "Standard"
		capacity = {
			default = 1
			env_override = {
				perf = 4
				prod = 4
			}
		}
		minimum_tls_version = {
			default = 1.2
			env_override = {
			}
		}
		auto_inflate = false
		injections = {
			default_primary_connection_string = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP4ConnectionString"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP4ConnectionString"
				app_config_ref = "app"
			}
			default_secondary_connection_string = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP4ConnectionStringSecondary"
				kv_ref = "app"
				app_config_name = "ExosMacro:EventHub:AMQP4ConnectionStringSecondary"
				app_config_ref = "app"
			}
			default_primary_connection_string_adl = {
				attr = "default_primary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP4ConnectionString"
				kv_ref = "adl"
			}
			default_secondary_connection_string_adl = {
				attr = "default_secondary_connection_string"
				kv_name = "ExosMacro--EXOS--EventHub--AMQP4ConnectionStringSecondary"
				kv_ref = "adl"
			}	
		}
		network_acls = {
			default_action = "Deny"
			bypass = "None"
			ips = local.resource_firewall_with_services.ips
			subnet_ids = local.resource_firewall_with_services.subnet_ids
			subnet_id_refs = local.resource_firewall_with_services.subnet_id_refs
		}
		env_managed_private_endpoints_override = {
			dev2 = [ "fd060171-ee61-43c0-8a0c-afce05f4bbef"	]
			uat2 = [ "30b3df41-0171-4c29-b678-541897c7888c" ]
			perf = [ "120a7b75-e077-422c-a68b-a80cb5c40442" ]
			stage = [ "53b06917-05d1-4101-9e52-c1d13bb01d2c" ]
			prod = [ "08de9e27-814c-4e25-aea2-5e1469152a57" ]
		}
		hubs = [
			{
				name = "exos_cdc_debezium_configs"
				partition_count = 1
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_offsets"
				partition_count = 25
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_debezium_statuses"
				partition_count = 5
				
				retention_description = {
					cleanup_policy = "Compact"
					tombstone_retention_time_in_hours = 24
				}
			},
			{
				name = "exos_cdc_group_4"
				partition_count = 16
				
				retention_description = {
					cleanup_policy = "Delete"
					retention_time_in_hours = 168
				}
				consumer_groups = [
					{
						name = "exos_onelake_etl"
					},
					{
						name = "SL-EXOS-Finance"
					},
					{
						name = "sl-exos-ap-invoicelineitem"
					},
					{
						name = "sl-exos-ap-invoicelineitemmilestone"
					},
					{
						name = "sl-exos-ap-invoiceworkorder"
					},
					{
						name = "sl-exos-cor-workorderclientfeecap"
					},
					{
						name = "sl-exos-cor-workorderclientservice"
					},
					{
						name = "sl-exos-cor-workorderduedateoverride"
					},
					{
						name = "sl-exos-cor-workorderprovideroverride"
					},
					{
						name = "sl-exos-qc-specialreviewrequest"
					},
					{
						name = "sl-exos-qc-workorderqualitycontrol"
					},
					{
						name = "sl-exos-qc-workorderqualitycontrolattribute"
					},
					{
						name = "sl-exos-qc-workorderqualitycontrolavmresponse"
					},
					{
						name = "sl-exos-qc-workorderqualitycontrolsubmission"
					},
					{
						name = "sl-exos-qc-workorderqualitycontrolsubmissiondetail"
					},
					{
						name = "sl-exos-req-request"
					},
					{
						name = "sl-exos-req-requestdispute"
					},
					{
						name = "sl-exos-orj-workorderreject"
					},
					{
						name = "sl-exos-orj-workorderrejectcausedby"
					},
					{
						name = "sl-exos-orj-workorderrejectnote"
					},
				]
			}
		]
	}
}

diag_event_hub_consumer_groups = {
	xsiam_consumer_group = {
		name = "xsiam_consumer_group"
		user_metadata = null
		deploy_in = {
			envs = ["sandbox", "dev2", "uat2", "perf", "stage", "prod"]
		}
	}
}

diag_event_hub_auth_rules = {
	cortex_xsiam = {
      name   = "cortex"
      listen = true
      send   = true
      manage = false
    }
}
}