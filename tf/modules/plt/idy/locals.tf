locals {
  rndPrefix = substr(random_uuid.rnd.result, 0, 8)
  deploy_bastion = false
}