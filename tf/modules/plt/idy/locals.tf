locals {
  rndPrefix = substr(random_uuid.rnd.result, 0, 8)
  deploy_bastion = true
  deploy_aaa = true
  deploy_law = true
}