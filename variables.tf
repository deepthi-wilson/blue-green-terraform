variable "region" {}
variable "application_name" {}
variable "application_environment" {}
variable "vpc_id" {}
variable "ec2_instance_type" {}
variable "key_name" {}
variable "blue_count" {}
variable "green_count" {}
variable "deployment" {}
 locals{
    traffic_dict = {
        full_blue = {
            blue =100,
            green =0
        },
           full_green = {
            green =100,
            blue =0
        },
           half_way = {
            green =50,
            blue =50
        },
         greener = {
             green = 75,
             blue =25
         }
    }
    }
