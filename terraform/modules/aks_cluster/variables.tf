variable "location" {
    type = string
    description = "Azure location of the EKS cluster."
}

variable "k8s_version" {
    type= string
    description = "Version of Kubernetes to use."
    default = "1.28.9"
}
