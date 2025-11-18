locals {

az_sql_system_mi_ids = {
	sandbox_eus2 = "52825bf3-0023-474a-9f63-c288039e285f"
	sbx11_eus2 = "f04bd0dd-167b-4912-b2e4-5681e01224b0"
	dev2_eus2 = "85b67755-450d-458a-860f-f4d4a6cdd665"
	perf_eus2 = "3fa02605-dc55-44a1-aac9-e0b1676ae54b"
	perf_wus2 = "d4986b9d-165f-4b15-9052-1f7ffc27dab8"
	uat2_eus2 = "a0553b6f-7805-4f8e-a694-4f4141102fee"
	stage_eus2 = "e5997245-47fe-4864-98b2-7329ceed31ec"
	prod_eus2 = "dd8184f6-810c-482e-8dab-5ec3da8b2629"
	prod_wus2 = "81e82997-054a-4ba7-b9bb-6e7c49c7f09a"
}

# flag to allow trusted services for SQL
az_sql_allow_trusted_services = [ "uat2", "stage", "prod"]

az_sql_network_rules = {
	ip_ranges = concat(
		contains( local.az_sql_allow_trusted_services, local.my_env_short) ? [
			# This allows Azure trusted services bypass
			"0.0.0.0-0.0.0.0",
		] : [],
		local.resource_firewall_with_services.ip_ranges,
	)
	subnet_ids = distinct(concat(
		local.resource_firewall_with_services.subnet_ids,
	))
	subnet_id_refs = distinct(concat(
		local.resource_firewall_with_services.subnet_id_refs,
		["win_ssrs"]
	))
	service_tags = [
		"DataFactory.EastUS2",
		"DataFactory.WestUS2",
		"PowerBI.EastUS2", 
		"PowerQueryOnline.EastUS2", 
	]
	# Manual override
	service_ip_ranges = {
		powerqueryonline_eastus2 = [
			"20.36.150.44-20.36.150.45",
			"20.41.0.68-20.41.0.71",
			"20.65.1.124-20.65.1.125",
			"20.98.195.176-20.98.195.183",
			"52.179.200.128-52.179.200.129",
			"104.208.207.40-104.208.207.47",
			"104.208.207.48-104.208.207.63"
		]
	}
}

maintence-window-time = local.site_type == "primary" ? "SQL_EastUS2_DB_2" : "SQL_WestUS2_DB_2"

az_sql_instance_names = { for k, v in local.az_sql_instances : k => lower("sql-${v.name}-${local.basic["local"].env_short}-${local.basic["local"].region_short}-${v.numeric}") }

az_sql_instances = {
	app = {
		name = "app"
		numeric = "01"
		elastic_pool_spec = {
			default = "default"
			mg_override = {
				prod = "prod"
			}
			env_override = {
				dev = "minimal"
				dev2 = "minimal"
				dev3 = "minimal"
				perf = "prod"
				uat2 = "minimal"
				uat3 = "minimal"
				uat4 = "prod"
			}
		}
		retention_spec = {
			default = "default"
			env_override = {
				prod = "prod"
			}
		}
		default_state_spec = {
			default = "default"
		}
		db_spec = {
			default = "default"
			env_override = {
				perf = "default"
			}
		}
	}
}

az_sql_elastic_pool_specs = {
	default = {
		pool1 = {
			name = "pool1"
			license_type = "BasePrice"
			max_size_gb = 2048
			zone_redundant = false
			
			sku = {
				name = "GP_Gen5"
				tier = "GeneralPurpose"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool2 = {
			name = "pool2"
			license_type = "BasePrice"
			max_size_gb = 3072
			zone_redundant = false
			
			sku = {
				name = "GP_Gen5"
				tier = "GeneralPurpose"
				family = "Gen5"
				capacity = 18
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 18
			}
		}
		pool12 = {
			name = "pool12"
			license_type = "BasePrice"
			max_size_gb = 756  # Changed from 1024 to 756 to comply with Azure limits
			zone_redundant = false
			
			sku = {
				name = "GP_Gen5"
				tier = "GeneralPurpose"
				family = "Gen5"
				capacity = 4
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 4
			}
		}
	}

	minimal = {
		pool1 = {
			name = "pool1"
			license_type = "BasePrice"
			max_size_gb = 2048
			zone_redundant = false
			
			sku = {
				name = "GP_Gen5"
				tier = "GeneralPurpose"
				family = "Gen5"
				capacity = 8
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 8
			}
		}
		pool12 = {
			name = "pool12"
			license_type = "BasePrice"
			max_size_gb = 756
			zone_redundant = false
			
			sku = {
				name = "GP_Gen5"
				tier = "GeneralPurpose"
				family = "Gen5"
				capacity = 4
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 4
			}
		}
	}	
	prod = {
		pool1 = {
			name = "pool1"
			license_type = "BasePrice"
			max_size_gb = 1536
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool2 = {
			name = "pool2"
			license_type = "BasePrice"
			max_size_gb = 4096
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 24
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 24
			}
		}
		pool3 = {
			name = "pool3"
			license_type = "BasePrice"
			max_size_gb = 3584
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 24
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 24
			}
		}
		pool4 = {
			name = "pool4"
			license_type = "BasePrice"
			max_size_gb = 1536
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool5 = {
			name = "pool5"
			license_type = "BasePrice"
			max_size_gb = 1536
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 24
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 24
			}
		}
		pool6 = {
			name = "pool6"
			license_type = "BasePrice"
			max_size_gb = 1536
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool7 = {
			name = "pool7"
			license_type = "BasePrice"
			max_size_gb = 1536
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool8 = {
			name = "pool8"
			license_type = "BasePrice"
			max_size_gb = 3072
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool9 = {
			name = "pool9"
			license_type = "BasePrice"
			max_size_gb = 3072
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool10 = {
			name = "pool10"
			license_type = "BasePrice"
			max_size_gb = 3072
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
		pool11 = {
			name = "pool11"
			license_type = "BasePrice"
			max_size_gb = 101
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 8
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 8
			}
		}
		pool12 = {
			name = "pool12"
			license_type = "BasePrice"
			max_size_gb = 756  # Changed from 1024 to 756 to comply with Azure limits
			zone_redundant = false
			
			sku = {
				name = "GP_Gen5"
				tier = "GeneralPurpose"
				family = "Gen5"
				capacity = 4
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 4
			}
		}
		pool13 = {
			name = "pool13"
			license_type = "BasePrice"
			max_size_gb = 1536
			zone_redundant = false
			
			sku = {
				name = "BC_Gen5"
				tier = "BusinessCritical"
				family = "Gen5"
				capacity = 12
			}
			
			per_database_settings = {
				min_capacity = 0
				max_capacity = 12
			}
		}
	}
}

az_sql_retention_policies = {
	default = {
		weekly = "PT0S"
		monthly = "PT0S"
		yearly = "PT0S"
		week_of_year = null
	}
	prod = {
		weekly = "P4W"
		monthly = "P12M"
		yearly = "P10Y"
		week_of_year = "1"
	}
}

az_sql_default_state_specs = {
	default = {
		ignore_local_logins = []
		add_local_logins = [
			"bi-exos-app-01",
			"bi-exos-app-02",
			"debezium-exos-app-01",
			"pbiemb-exos-app-01",
			"pbiemb-exos-app-02",
			"reporting-exos-app-01",
			"reporting-exos-app-02",
			"svc-exos-app-01",
			"svc-exos-app-02",
			"svc-exos-auctionworx-01",
			"svc-exos-sql-auto-01",
			"sql-maintenance-exos-app-01",
			"sql-maintenance-exos-app-02",
		]
		ignore_users = [
			"dbo",
			"guest",
			"INFORMATION_SCHEMA",
			"sys",
			"cdc",
		]
		ignore_roles = [
			"db_accessadmin",
			"db_backupoperator",
			"db_datareader",
			"db_datawriter",
			"db_ddladmin",
			"db_denydatareader",
			"db_denydatawriter",
			"db_owner",
			"db_securityadmin",
			"dbmanager",
			"loginmanager",
			"public",
		]
		add_roles = [
			{
				name = "db_executor"
				grants = [ "EXECUTE", "VIEW DEFINITION", "SHOWPLAN" ]
			},
			{
				name = "db_writerplus"
				grants = [ "VIEW DATABASE STATE" ]
			},
			{
				name = "db_enccolumn"
				grants = [ "VIEW ANY COLUMN MASTER KEY DEFINITION", "VIEW ANY COLUMN ENCRYPTION KEY DEFINITION" ]
			}
		]
		ignore_role_assignments = [
			{
				identity_name = "dbo"
				roles = [ "db_owner" ]
			},
			{
				identity_name = "cdc"
				roles = [ "db_owner" ]
			}
		]
		add_role_assginments = [
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].reader
				roles = [ "db_datareader" ]
				local = false
			},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].writer
				roles = [ "db_datareader", "db_datawriter", "db_executor" ]
				local = false
			},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].writerplus
				roles = [ "db_datareader", "db_datawriter", "db_executor", "db_writerplus" ]
				local = false
			},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].owner
				roles = [ "db_owner" ]
				local = false
			},
			{
				identity_name = "svc-exos-app-01"
				roles = [ "db_datareader", "db_datawriter" ]
				local = true
			},
			{
				identity_name = "svc-exos-app-02"
				roles = [ "db_datareader", "db_datawriter" ]
				local = true
			},
			{
				identity_name = "svc-exos-sql-auto-01"
				roles = [ "db_datareader" ]
				local = true
			},
			{
				identity_name = "sql-maintenance-exos-app-01"
				roles = [ "db_ddladmin", "db_datareader", "db_datawriter", "db_executor", "db_writerplus" ]
				local = true
			},
			{
				identity_name = "sql-maintenance-exos-app-02"
				roles = [ "db_ddladmin", "db_datareader", "db_datawriter", "db_executor", "db_writerplus" ]
				local = true
			}
		]
		master_db = {
			role_assignments = [
				{
					identity_name = local.az_sql_env_grants[local.my_mg_ref].owner
					roles = [ "dbmanager" ]
					local = false
				},
				{
					identity_name = "sql-maintenance-exos-app-01"
					roles = [ "dbmanager" ]
					local = true
				},
				{
					identity_name = "sql-maintenance-exos-app-02"
					roles = [ "dbmanager" ]
					local = true
				},
			]
		}
	}
}

az_sql_db_specs = {
	default = {
		accountspayabledb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool10"
				}
				mg_override = {
					prod = "pool10"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ap"
					source_name = "InvoiceLineItem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ap"
					source_name = "InvoiceLineItemMilestone"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ap"
					source_name = "InvoiceWorkOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		accountsreceivabledb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool10"
				}
				mg_override = {
					prod = "pool10"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ar"
					source_name = "GeneralLedger"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ar"
					source_name = "GeneralLedgerLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ar"
					source_name = "InvoiceLineItem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ar"
					source_name = "InvoiceLineItemMilestone"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ar"
					source_name = "InvoiceWorkOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ar"
					source_name = "WorkOrderReference"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cfg"
					source_name = "BillingGroupClientAssociations"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cfg"
					source_name = "BillingGroups"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "GeneralLedgerType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		apidocdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		auctionsdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		auctionsalesforcereportingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "500"
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "svc-exos-app-01"
						roles = [ "db_datareader", "db_datawriter", "db_enccolumn" ]
						local = true
					},
					{
						identity_name = "svc-exos-app-02"
						roles = [ "db_datareader", "db_datawriter", "db_enccolumn" ]
						local = true
					},
					{
						identity_name = "bi-exos-app-01"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
					{
						identity_name = "bi-exos-app-02"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
					{
						identity_name = "pbiemb-exos-app-01"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
					{
						identity_name = "pbiemb-exos-app-02"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				],
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_team_group", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_team_group
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "data_analysis_group", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].data_analysis_group
						roles = [ "db_owner" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_service_account", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_service_account2", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account2
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
			)
		}
		auctionworxdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "svc-exos-auctionworx-01"
					roles = [ "db_datareader", "db_datawriter", "db_executor" ]
					local = true
				},
			]
		}
		automationreportingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "100"
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "bi-exos-app-01"
						roles = [ "db_datareader" ]
						local = true
					},
			    ],
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_team_group", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_team_group
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_service_account", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_service_account2", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account2
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
			)
		}
		barcodedb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		bulkorderdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Blk"
					source_name = "BulkFile"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Blk"
					source_name = "BulkFileOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		cddataextractworkflowdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool8"
				}
				mg_override = {
					prod = "pool8"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cew"
					source_name = "Submission"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cew"
					source_name = "SubmissionTracking"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cew"
					source_name = "SubmissionRequestDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		celrepositorydb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		checkprintingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool9"
				}
				mg_override = {
					prod = "pool9"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
				  {
					  identity_name = "debezium-exos-app-01"
					  roles = [ "db_datareader" ]
					  local = true
				  },

				],
			)
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "ref"
					source_name = "subsystem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		clientnotificationdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		clientreportdeliverydb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool7"
				}
				mg_override = {
					prod = "pool7"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		closingdisclosuredb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool8"
				}
				mg_override = {
					prod = "pool8"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					perf = "400"
				}
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "AutomationRequest"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "AutomationRequestProcessLog"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "Charge"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ChargeSum"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ClosingDisclosure"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		disbursementdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool9"
				}
				mg_override = {
					prod = "pool9"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "AdvanceFeeLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "BankTransferLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "Deposit"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DepositBatch"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DepositOrderAssignment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "Disbursement"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DisbursementBook"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DisbursementLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DisbursementLineDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DisbursementTag"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "Prefund"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ReissueRequest"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ResearchRequest"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ResearchRequestDisbursementLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "WireFileGroupLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "WireFileGroupLineAssignment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "WireOut"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "WireOutHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "BankTransactionType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "DisbursementLineStatus"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "DisbursementLineType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "HoldReason"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "TransactionReason"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		docfulfillmentdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		docgenconfigdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		docgendb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool6"
					uat4 = "pool6"
				}
				mg_override = {
					prod = "pool6"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		docextractiondb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "100"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		docprepdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool9"
				}
				mg_override = {
					prod = "pool9"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "Bundle"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "BundleLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		documentauditdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool8"
				}
				mg_override = {
					prod = "pool8"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "DocAudit"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DocAuditDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DocAuditDocumentReject"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DocAuditOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "DocAuditPackageTask"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ERecordingDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "MPD"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "MPDDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "MPDDocumentReject"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "MPDWorkOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RecDisbursement"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RecDisbursementBook"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RecDisbursementLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RecordingFeePayment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RecWireOut"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RecWireOutHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RFCDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "RFCDocumentFee"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "BankTransfer"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "DocAuditPackageTaskType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		enterprisereportingdb = {
			pool = {
				default = "pool1"
				env_override = {
					qa = "pool2"
					qa2 = "pool2"
					perf = "pool3"
					uat4 = "pool3"
				}
				mg_override = {
					prod = "pool3"
				}
			}
			max_db_size = {
				default = "500"
				env_override = {
					qa = "3072"
					qa2 = "3072"
					perf = "3025"
					uat3 = "500"
					uat4 = "3000"
				}
				mg_override = {
					nonprod = "800"
					prod = "3537"
				}
			}
			additional_roles = [
				{
					name = "db_external_executor"
					grants = [ "EXECUTE ANY EXTERNAL ENDPOINT" ]
				}
			]
			additional_role_assginments = concat(
				[
					{
						identity_name = "svc-exos-app-01"
						roles = [ "db_datareader", "db_datawriter", "db_enccolumn" ]
						local = true
					},
					{
						identity_name = "svc-exos-app-02"
						roles = [ "db_datareader", "db_datawriter", "db_enccolumn" ]
						local = true
					},
					{
						identity_name = "bi-exos-app-01"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
								{
						identity_name = "bi-exos-app-02"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
					{
						identity_name = "pbiemb-exos-app-01"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
								{
						identity_name = "pbiemb-exos-app-02"
						roles = [ "db_datareader", "db_executor" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				],
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_team_group", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_team_group
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "data_analysis_group", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].data_analysis_group
						roles = [ "db_owner" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_service_account", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account
						roles = [ "db_datareader", "db_executor" ]
						local = false
					},
				]),
				lookup(local.az_sql_env_grants[local.my_mg_ref], "bi_service_account2", null) == null ? [] : ([
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account2
						roles = [ "db_datareader", "db_executor", "db_denydatawriter", "db_external_executor" ]
						local = false
					},
				]),
			)
		}
		etedatadb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool6"
					uat4 = "pool6"
				}
				mg_override = {
					prod = "pool6"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		exosapparchivedb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool3"
					uat4 = "pool3"
				}
				mg_override = {
					prod = "pool3"
				}	
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		exosarchivedb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool3"
					uat4 = "pool3"
				}
				mg_override = {
					prod = "pool3"
				}
			}
            max_db_size = {
                default = "250"
                env_override = {
                    prod = "320"
                }
            }
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_team_group
						roles = [ "db_datareader" ]
						local = false
					},
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account
						roles = [ "db_datareader" ]
						local = false
					},
					{
						identity_name = local.az_sql_env_grants[local.my_mg_ref].bi_service_account2
						roles = [ "db_datareader" ]
						local = false
					}
				]
			)
		}
		exosintegrationdb = {
			pool = {
				default = "pool1"
				mg_override = {
					prod = "pool7"
				}
				env_override = {
					perf = "pool7"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		exosreportingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool10"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool10"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					qa = "550"
					qa2 = "550"
					perf = "1000"
					uat4 = "800"
				}
				mg_override = {
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = []
		}
		expresspasstrackingdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		feedbackdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
				{
					identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
					roles = [ "db_datareader" ]
					local = false
				}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Fdb"
					source_name = "FeedbackSubmission"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Fdb"
					source_name = "FeedbackSubmissionDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		fieldservicesdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool1"
				}
				mg_override = {
					prod = "pool1"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					qa2 = "500"
				}
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				],
			)
		}
		fsbulkorderdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool1"
				}
				mg_override = {
					prod = "pool1"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					qa2 = "500"
				}
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				],
			)
		}
		fsdocumentdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool1"
				}
				mg_override = {
					prod = "pool1"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					qa2 = "500"
				}
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				],
			)
		}
		ictconfigdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = []
		}
		instanttitledb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					nonprod = "500"
					prod = "500"
				}
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ref"
					source_name = "DocumentStatus"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		instanttitlerequestdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		legacydefaultdatadb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool13"
				}
				mg_override = {
					prod = "pool13"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "svc-exos-app-01"
					roles = [ "db_executor" ]
					local = true
				},
				{
					identity_name = "svc-exos-app-02"
					roles = [ "db_executor" ]
					local = true
				}
			]
		}
		messagingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = []
		}
		ofacpartydb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		onempcartdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempedwdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempcartdbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempedwdbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempmessagedbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onemporderdbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempproductdbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempsearchdbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempwidgetdbclt02 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempcartdbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempedwdbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempmessagedbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onemporderdbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempproductdbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempsearchdbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempwidgetdbclt03 = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempmessagedb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		onemporderdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		onempproductdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		onempsearchdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		onempwidgetdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		onemphealthcheckdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool4"
					uat4 = "pool4"
				}
				mg_override = {
					prod = "pool4"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
			]
		}
		orderdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool5"
					uat4 = "pool5"
				}
				mg_override = {
					prod = "pool5"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					qa = "500"
					qa2 = "500"
				}
				mg_override = {
					nonprod = "1000"
					prod = "1250"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				    {
					    identity_name = "debezium-exos-app-01"
					    roles = [ "db_datareader" ]
					    local = true
				    },
					{
						identity_name = "EXOS-OneLake-Dev"
						roles = [ "db_datareader" ]
						local = false
					}
				],
			)
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Apt"
					source_name = "Appointment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Apt"
					source_name = "AppointmentHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Apt"
					source_name = "ProposedAppointment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cnt"
					source_name = "OrderStakeholder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cnt"
					source_name = "StakeHolder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cnt"
					source_name = "StakeholderContactMethod"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "Asset"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "AuthTokenDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "Loan"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "Order"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "VendorAssignmentHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderAppraisal"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderAppraisalAttribute"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderAppraisalAttributeReason"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderAppraisalHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClientFee"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClientFeeCap"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClientService"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClosing"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClosingAcceptance"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClosingHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClosingInspectionTracking"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderClosingTaskAssignment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderConsumerAudit"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderDeliveryDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderDueDateOverride"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderProviderOverride"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderQuote"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTask"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTaskAssignment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTaskComment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTaskHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTaskTracking"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTitle"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTitleHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderTitleTaskAssignment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderUpdate"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderVendorFee"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderVirtualClose"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cor"
					source_name = "WorkOrderVirtualCloseAttorney"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Dly"
					source_name = "WorkOrderDelay"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Mst"
					source_name = "WorkOrderMilestone"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Pra"
					source_name = "WorkOrderProviderAction"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "Milestone"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "StakeholderType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "TransactionType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "WorkOrderStatus"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Trk"
					source_name = "WorkOrderProductChange"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		orderdelaydb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
				  {
					  identity_name = "debezium-exos-app-01"
					  roles = [ "db_datareader" ]
					  local = true
				  },
				  {
					  identity_name = "EXOS-OneLake-Dev"
					  roles = [ "db_datareader" ]
					  local = false
				  }

				],
			)
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Dly"
					source_name = "WorkOrderDelay"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		orderdocumentdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "debezium-exos-app-01"
						roles = [ "db_datareader" ]
						local = true
				  	},
				  	{
						identity_name = "EXOS-OneLake-Dev"
						roles = [ "db_datareader" ]
						local = false
				  	}

				],
			)
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Doc"
					source_name = "WorkOrderDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		orderfollowupdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}

			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Fup"
					source_name = "VendorFollowup"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		ordernotedb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					nonprod = "1000"
					prod = "1000"
				}
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}

			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Nte"
					source_name = "WorkOrderNote"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		orderorchestratordb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool9"
				}
				mg_override = {
					prod = "pool9"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}

			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "WorkOrderClosing"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "WorkOrderTask"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "WorkOrderTracking"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "His"
					source_name = "WorkOrderTrackingHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "his"
					source_name = "WorkOrderClosingHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "SubSystem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "TrackingItem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "TrackingItemSubSystem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "TrackingStatus"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		orderqualitycontroldb = {
			pool = {
				default = "pool1"
				mg_override = {
					prod = "pool7"
				}
				env_override = {
					perf = "pool7"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					prod = "1000"
				}
				env_override = {
					perf = "750"
					uat4 = "500"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "debezium-exos-app-01"
						roles = [ "db_datareader" ]
						local = true
					},

				],
			)
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ful"
					source_name = "DesktopVendorAcknowledgement"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "SpecialReviewRequest"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "WorkOrderQualityControl"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "WorkOrderQualityControlAttribute"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "WorkOrderQualityControlAVMResponse"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "WorkOrderQualityControlSubmission"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "WorkOrderQualityControlSubmissionDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Qc"
					source_name = "WorkOrderQualityControlPropertyResearch"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		orderqualitycontrolworkflowdb = {
			pool = {
				default = "pool1"
				mg_override = {
					prod = "pool7"
				}
				env_override = {
					perf = "pool7"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [	]
		}
		orderqualitycontrolintegrationdb = {
			pool = {
				default = "pool1"
				mg_override = {
					prod = "pool7"
				}
				env_override = {
					perf = "pool7"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "reporting-exos-app-01"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "reporting-exos-app-02"
					roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
					local = true
				},
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}

			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ref"
					source_name = "SubmissionCommentType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "intaci"
					source_name = "WorkOrderQualityControlACISubmisison"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmission"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionAnalysis"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionAttribute"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionCMA"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionComment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionCompareCommon"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionCompareListing"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionCompareSales"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionCompareUnit"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionContractor"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionCostApproach"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionImprovement"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionListAndSalesHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionMarketCondition"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionNeighorhood"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionPCR"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionPriorReport"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionPUD"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionRentIncomeUnit"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionRepair"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionRepairItem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "IntVal"
					source_name = "IntgOrderReportSubmissionSite"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		orderrejectdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool10"
				}
				mg_override = {
					prod = "pool10"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}

			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ref"
					source_name = "CausedBy"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "RejectCode"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "RejectType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Orj"
					source_name = "WorkOrderReject"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Orj"
					source_name = "WorkOrderRejectCausedBy"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Orj"
					source_name = "WorkOrderRejectNote"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		orderrequestdb = {
			pool = {
				default = "pool1"
				mg_override = {
					prod = "pool7"
				}
				env_override = {
					perf = "pool7"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = concat(
				[
					{
						identity_name = "reporting-exos-app-01"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
					{
						identity_name = "reporting-exos-app-02"
						roles = [ "db_datareader", "db_executor", "db_datawriter", "db_ddladmin" ]
						local = true
					},
				    {
					   identity_name = "debezium-exos-app-01"
					   roles = [ "db_datareader" ]
					   local = true
				    },
					{
						identity_name = "EXOS-OneLake-Dev"
						roles = [ "db_datareader" ]
						local = false
					}
				],
			)
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Req"
					source_name = "Request"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Req"
					source_name = "RequestDispute"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		ordertrackingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
				env_override = {
					qa = "500"
					qa2 = "500"
					uat2 = "1000"
					uat3 = "1000"
				}
				mg_override = {
					nonprod = "1500"
					prod = "2250"
				}
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Trk"
					source_name = "WorkOrderTracking"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		paymentdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Pay"
					source_name = "WorkOrderPayment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
			]
		}
		prepayprocessingdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [	]
		}
		productworktrackingdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		propertyinfodb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool10"
				}
				mg_override = {
					prod = "pool10"
				}
			}
			max_db_size = {
				default = "250"
				mg_override = {
					nonprod = "500"
					prod = "500"
				}
			}
			additional_roles = []
			additional_role_assginments = concat(
				[],
			)
		}
		pythonbridgedb  = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		rfcdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Ref"
					source_name = "State"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		shipmenttrackingdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool9"
				}
				mg_override = {
					prod = "pool9"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "ShipmentTracking"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ShipmentTrackingLine"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "Carrier"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		titlecurativeconfigdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titlecurativedb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}				
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cur"
					source_name = "CurativeDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "CurativeItem"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "CurativeOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "CurativeOrderActionLog"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "CurativeOrderNote"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "LienHolder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "PayOffLender"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cur"
					source_name = "Property"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "CurativeStatusType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "ResolutionReasonType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
				source_schema = "cur"
				source_name = "Stakeholder"
				filegroup_name = "PRIMARY"
				supports_net_changes = 0
				},
				{
				source_schema = "wsd"
				source_name = "DeedData"
				filegroup_name = "PRIMARY"
				supports_net_changes = 0
				}
			]
		}
		titledataaggregatordb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
				env_override = {
					perf = "350"
					uat4 = "350"
				}
				mg_override = {
					prod = "350"
				}
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titledatadb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool6"
					uat4 = "pool6"
				}
				mg_override = {
					prod = "pool6"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Tdc"
					source_name = "Judgment"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Tdc"
					source_name = "Mortgage"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Tdc"
					source_name = "Subordination"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Tdc"
					source_name = "TitleData"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Tdc"
					source_name = "TitleDeed"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		titledocumentdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [	
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Doc"
					source_name = "TitleDocument"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		titleexamconfigdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titlefeedb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titleintegrationdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titleintegrationorderdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titleinvoicedb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool6"
					uat4 = "pool6"
				}
				mg_override = {
					prod = "pool6"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Inv"
					source_name = "TitleInvoice"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Inv"
					source_name = "TitleInvoiceDiscount"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Inv"
					source_name = "TitleInvoiceEndorsement"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Inv"
					source_name = "TitleInvoiceExtension"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Inv"
					source_name = "TitleInvoiceFeeDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Inv"
					source_name = "TitlePolicy"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		titleparagraphconfigdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titleparagraphdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool6"
					uat4 = "pool6"
				}
				mg_override = {
					prod = "pool6"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Prg"
					source_name = "TitleParagraph"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		titlepolicydb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "tpl"
					source_name = "TitlePolicy"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		titleratedb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "svc-exos-app-01"
					roles = [ "db_executor" ]
					local = true
				},
				{
					identity_name = "svc-exos-app-02"
					roles = [ "db_executor" ]
					local = true
				}
			]
		}
		titlerequestdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
					uat4 = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titlesubmissionruledb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		titleunderwriterconfigdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		treasurydb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool9"
				}
				mg_override = {
					prod = "pool9"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Cls"
					source_name = "BAIFileGroup"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "BAIFileGroupTransaction"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "BookTransaction"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ReconciliationDetail"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "ReconciliationSummary"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Cls"
					source_name = "TrialBalance"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "His"
					source_name = "BookTransactionStatusHistory"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "BookSourceType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "BookTransactionStatus"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "BookTransactionType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Ref"
					source_name = "FundType"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		vendorautomationdb = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool2"
				}
				mg_override = {
					prod = "pool2"
				}
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		vestingdataextractiondb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		virtualcloseorderbatchdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
			{
				identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
				roles = [ "db_datareader" ]
				local = false
			}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Vbo"
					source_name = "BatchFile"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Vbo"
					source_name = "BatchFileOrder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Vbo"
					source_name = "BatchFileOrderErrorList"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Vbo"
					source_name = "BatchFileOrderStakeHolder"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		workflowdb = {
			pool = {
				default = "pool1"
			}
			max_db_size = {
				default = "250"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		AgenticDB = {
			pool = {
				default = "pool12"
			}
			max_db_size = {
				default = "756"
			}
			additional_roles = []
			additional_role_assginments = [
				{
					identity_name = "debezium-exos-app-01"
					roles = [ "db_datareader" ]
					local = true
				},
				{
					identity_name = local.az_sql_env_grants[local.my_mg_ref].onelake_app
					roles = [ "db_datareader" ]
					local = false
				}
			]
			cdc_enabled = true
			cdc_retention = 1440
			cdc_tables = [
				{
					source_schema = "Aai"
					source_name = "AgenticAIRequest"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Aai"
					source_name = "AgenticAITask"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				},
				{
					source_schema = "Aai"
					source_name = "RequestTrackingLog"
					filegroup_name = "PRIMARY"
					supports_net_changes = 0
				}
			]
		}
		CommunicationAutomationAIDB = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "100"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		WebAutomationDB = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "100"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		IntentAnalysisDB = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "100"
			}
			additional_roles = []
			additional_role_assginments = []
		}
		ExosAutomationReportingDB = {
			pool = {
				default = "pool1"
				env_override = {
					perf = "pool11"
				}
				mg_override = {
					prod = "pool11"
				}
			}
			max_db_size = {
				default = "100"
			}
			additional_roles = []
			additional_role_assginments = []
		}
	}
}

az_sql_env_grants = {
	sandbox = {
		reader = "Azure-App_sql_reader_dev-EXOS"
		writer = "Azure-App_sql_writer_dev-EXOS"
		writerplus = "Azure-App_sql_writerplus_dev-EXOS"
		owner = "Azure-App_sql_owner_dev-EXOS"
		bi_team_group = "Azure-App_BI-EXOS"
		bi_service_account = "SVC-PreProdBI@svclnk.com"
		bi_service_account2 = "SVC-PreProdBI2@svclnk.com"
		data_analysis_group = "Azure-App_DataAnalysis-EXOS"
		onelake_app = "EXOS-OneLake-Dev" 
	}	
	dev = {
		reader = "Azure-App_sql_reader_dev-EXOS"
		writer = "Azure-App_sql_writer_dev-EXOS"
		writerplus = "Azure-App_sql_writerplus_dev-EXOS"
		owner = "Azure-App_sql_owner_dev-EXOS"
		bi_team_group = "Azure-App_BI-EXOS"
		bi_service_account = "SVC-PreProdBI@svclnk.com"
		bi_service_account2 = "SVC-PreProdBI2@svclnk.com"
		data_analysis_group = "Azure-App_DataAnalysis-EXOS"
		onelake_app = "EXOS-OneLake-Dev"
	}
	nonprod = {
		reader = "Azure-App_sql_reader_non-prod-EXOS"
		writer = "Azure-App_sql_writer_non-prod-EXOS"
		writerplus = "Azure-App_sql_writerplus_non-prod-EXOS"
		owner = "Azure-App_sql_owner_non-prod-EXOS"
		bi_team_group = "Azure-App_BI-EXOS"
		bi_service_account = "SVC-PreProdBI@svclnk.com"
		bi_service_account2 = "SVC-PreProdBI2@svclnk.com"
		onelake_app = "EXOS-OneLake-Dev"
	}
	prod = {
		reader = "Azure-App_sql_reader_prod-EXOS"
		writer = "Azure-App_sql_writer_prod-EXOS"
		writerplus = "Azure-App_sql_writerplus_prod-EXOS"
		owner = "Azure-App_sql_owner_prod-EXOS"
		bi_team_group = "Azure-App_BI-EXOS"
		bi_service_account = "SVC-ProdBI@svclnk.com"
		bi_service_account2 = "SVC-ProdBI2@svclnk.com"
		onelake_app = "EXOS-OneLake-Prod"
	}
}

az_sql_my_elastic_pool_spec = { for k, v in local.az_sql_instances : k => (
	# First check if there is an environment override
	lookup(lookup(v.elastic_pool_spec, "env_override", {}), local.my_env_short, null) != null ? v.elastic_pool_spec.env_override[local.my_env_short] :
	# Then check if there is a management group override
	lookup(lookup(v.elastic_pool_spec, "mg_override", {}), local.my_mg_ref, null) != null ? v.elastic_pool_spec.mg_override[local.my_mg_ref] :
	# Finally, use the default
	v.elastic_pool_spec.default
)}

az_sql_my_default_state_spec = { for k, v in local.az_sql_instances : k => (
	# First check if there is an environment override
	lookup(lookup(v.default_state_spec, "env_override", {}), local.my_env_short, null) != null ? v.default_state_spec.env_override[local.my_env_short] :
	# Then check if there is a management group override
	lookup(lookup(v.default_state_spec, "mg_override", {}), local.my_mg_ref, null) != null ? v.default_state_spec.mg_override[local.my_mg_ref] :
	# Finally, use the default
	v.default_state_spec.default
)}

az_sql_my_db_spec = { for k, v in local.az_sql_instances : k => (
	# First check if there is an environment override
	lookup(lookup(v.db_spec, "env_override", {}), local.my_env_short, null) != null ? v.db_spec.env_override[local.my_env_short] :
	# Then check if there is a management group override
	lookup(lookup(v.db_spec, "mg_override", {}), local.my_mg_ref, null) != null ? v.db_spec.mg_override[local.my_mg_ref] :
	# Finally, use the default
	v.elastic_pool_spec.default
)}

}