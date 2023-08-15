locals {
  rndPrefix = substr(random_uuid.rnd.result, 0, 8)
  deploy_bastion = true
  deploy_aaa = true
  deploy_law = true
  link_aaa_law = true
  imperative_dcra = false
  test_mde = false
  adds_1 = "Install-WindowsFeature AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools"
  dns_2 = "Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools"
  mods_3 = "Import-Module -Name ADDSDeployment, DnsServer"
  forest_4 = "Install-ADDSForest -DomainName ${var.domain.fqdn} -DomainNetbiosName ${var.domain.netbios} -DomainMode ${var.domain.mode} -ForestMode ${var.domain.mode} -DatabasePath ${var.domain.database_path} -SysvolPath ${var.domain.sysvol_path} -LogPath ${var.domain.log_path} -NoRebootOnCompletion:$false -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString ${var.pw} -AsPlainText -Force)"
  powershell = "${local.adds_1}; ${local.dns_2}; ${local.mods_3}; ${local.forest_4}"
  updateDNS = "Set-DnsClientGlobalSetting -SuffixSearchList ${var.domain.fqdn} -PassThru -Confirm:$false -Verbose"
  clearDNS = "Clear-DnsClientCache -Confirm:$false"
  registerDNS = "Register-DnsClient -Confirm:$false"
  join = "Add-Computer -DomainName ${var.domain.fqdn} -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList adsadmin@${var.domain.fqdn}, (ConvertTo-SecureString -String ${var.pw} -AsPlainText -Force)) -Restart"
  promote = "Install-ADDSDomainController -DomainName ${var.domain.fqdn} -SafeModeAdministratorPassword (ConvertTo-SecureString ${var.pw} -AsPlainText -Force) -NoGlobalCatalog:$false -InstallDns:$true -Force:$true -NoRebootOnCompletion:$false -Force:$true"
  joinServer = "${local.updateDNS}; ${local.clearDNS}; ${local.registerDNS}; ${local.join}"
  promoteDC = "${local.promote}"
}