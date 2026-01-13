locals {
	diag_event_hub_auth_rules_iterator = { for value in [for rule_key, rule_value in local.diag_event_hub_auth_rules : {
		auth_rule_name = rule_value.name
		listen = lookup(rule_value, "listen", false)
		send = lookup(rule_value, "send", false)
		manage = lookup(rule_value, "manage", false)
		rule_key = rule_key
		deploy_in = lookup(rule_value, "deploy_in", {})
		}] : value.auth_rule_name => value
		if length(value.deploy_in) == 0
		|| (
		length(value.deploy_in) > 0
		&& contains(lookup(value.deploy_in, "applications", [var.app_ref]), var.app_ref)
		&& (
			(lookup(value.deploy_in, "mgs", null) == null && lookup(value.deploy_in, "envs", null) == null)
			|| contains(coalesce(lookup(value.deploy_in, "mgs", []), [local.my_mg_ref]), local.my_mg_ref)
			|| contains(coalesce(lookup(value.deploy_in, "envs", []), [local.my_env_short]), local.my_env_short)
		)
		)
	}
}

resource "azurerm_eventhub_authorization_rule" "auth_rule" {
	for_each = local.diag_event_hub_auth_rules_iterator

	provider = azurerm.common

	name = "${each.value.auth_rule_name}_rule"
	namespace_name = data.terraform_remote_state.common.outputs.event_hub_diag_logging["${local.basic["local"].env_short}_${local.basic["local"].region_short}"].name
	eventhub_name = data.terraform_remote_state.common.outputs.event_hub_diag_logging["${local.basic["local"].env_short}_${local.basic["local"].region_short}"].name
	resource_group_name = "rg-log-common-${local.basic["local"].region_short}-01"

	listen = each.value.listen
	send   = each.value.send
	manage = each.value.manage
}

resource "null_resource" "diag_event_hub_auth_rule_key_rotation" {
	for_each = local.diag_event_hub_auth_rules_iterator

	triggers = {
	credentials_keeper = local.my_env.keepers.credentials
	}

	provisioner "local-exec" {
	command = <<EOT
		/usr/bin/az eventhubs eventhub authorization-rule keys renew --subscription $SUBSCRIPTION_ID --resource-group $RG_NAME --namespace-name $NAMESPACE_NAME --eventhub-name $EVENTHUB_NAME --name $AUTH_RULE_NAME --key PrimaryKey > /dev/null || exit 1;
		/usr/bin/az eventhubs eventhub authorization-rule keys renew --subscription $SUBSCRIPTION_ID --resource-group $RG_NAME --namespace-name $NAMESPACE_NAME --eventhub-name $EVENTHUB_NAME --name $AUTH_RULE_NAME --key SecondaryKey > /dev/null || exit 1;
	EOT

	environment = {
		SUBSCRIPTION_ID = data.azurerm_subscription.common.subscription_id
		RG_NAME = "rg-log-common-${local.basic["local"].region_short}-01"
		NAMESPACE_NAME = data.terraform_remote_state.common.outputs.event_hub_diag_logging["${local.basic["local"].env_short}_${local.basic["local"].region_short}"].name
		EVENTHUB_NAME = data.terraform_remote_state.common.outputs.event_hub_diag_logging["${local.basic["local"].env_short}_${local.basic["local"].region_short}"].name
		AUTH_RULE_NAME = "${each.value.auth_rule_name}_rule"
	}
	}

	depends_on = [azurerm_eventhub_authorization_rule.auth_rule]
}

data "azurerm_eventhub_authorization_rule" "auth_rule" {
	for_each = local.diag_event_hub_auth_rules_iterator

	provider = azurerm.common

	name = "${each.value.auth_rule_name}_rule"
	namespace_name = data.terraform_remote_state.common.outputs.event_hub_diag_logging["${local.basic["local"].env_short}_${local.basic["local"].region_short}"].name
	eventhub_name = data.terraform_remote_state.common.outputs.event_hub_diag_logging["${local.basic["local"].env_short}_${local.basic["local"].region_short}"].name
	resource_group_name = "rg-log-common-${local.basic["local"].region_short}-01"

	depends_on = [null_resource.diag_event_hub_auth_rule_key_rotation]
}

resource "azurerm_key_vault_secret" "eventhub_auth_primary_rule_keys" {
	for_each = local.diag_event_hub_auth_rules_iterator

	key_vault_id = azurerm_key_vault.env["app"].id
	name = "${each.key}-primary-key"
	value = data.azurerm_eventhub_authorization_rule.auth_rule[each.key].primary_key
}

resource "azurerm_key_vault_secret" "eventhub_auth_rule_secondary_keys" {
	for_each  = local.diag_event_hub_auth_rules_iterator

	key_vault_id = azurerm_key_vault.env["app"].id
	name = "${each.key}-secondary-key"
	value = data.azurerm_eventhub_authorization_rule.auth_rule[each.key].secondary_key
}

resource "azurerm_key_vault_secret" "eventhub_auth_rule_primary_connection_strings" {
	for_each = local.diag_event_hub_auth_rules_iterator

	key_vault_id = azurerm_key_vault.env["app"].id
	name = "${each.key}-primary-connection-string"
	value = data.azurerm_eventhub_authorization_rule.auth_rule[each.key].primary_connection_string
}

resource "azurerm_key_vault_secret" "eventhub_auth_rule_secondary_connection_strings" {
	for_each = local.diag_event_hub_auth_rules_iterator

	key_vault_id = azurerm_key_vault.env["app"].id
	name = "${each.key}-secondary-connection-string"
	value = data.azurerm_eventhub_authorization_rule.auth_rule[each.key].secondary_connection_string
}