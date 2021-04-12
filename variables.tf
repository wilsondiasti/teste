# Variáveis de acesso AWS
variable "access_key-iam_wilson" {
    type = string
    default = "AKIAWJETW6TU7D6SZNF4"
}
variable "secret_key-iam_wilson" {
    type = string
    default = "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"
}

# ========================================================== #

# Demais variáveis
variable "region" {
     default = "us-east-1"
}
variable "availabilityZone" {
     default = "us-east-1a"
}
variable "availabilityZone2" {
     default = "us-east-1b"
}
variable "instanceTenancy" {
    default = "default"
}
variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}
variable "vpcCIDRblock" {
    default = "1.2.0.0/16"
}
variable "publicsCIDRblock" {
    default = "1.2.3.0/24"
}
variable "publicsCIDRblockpublic2" {
    default = "1.2.8.0/24"
}
variable "privatesCIDRblock_front" {
    default = "1.2.4.0/24"
}
variable "privatesCIDRblock_back" {
    default = "1.2.5.0/24"
}
variable "privatesCIDRblock_db" {
    default = "1.2.6.0/24"
}
variable "publicdestCIDRblock" {
    default = "0.0.0.0/0"
}
variable "mapPublicIP" {
    default = true
}
variable "localdestCIDRblock" {
    default = "1.2.0.0/16"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}