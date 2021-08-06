
###############################################################################################
######            If not using EC2 Intance Profile substitute below options         ###########
###############################################################################################

provider "aws" {
 #access_key = "${var.access_key}"
 #secret_key = "${var.secret_key}"
 region     = "${var.region}"


# assume_role {
#     role_arn = "arn:aws:iam::${var.account_id}:role/EC2-Instance-Role"
#     session_name = "assume_role"
# }
}
