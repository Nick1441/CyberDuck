module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc" # Try to avoid general names. Make it more relevent.

  # Choose an uncommon IP Address range to make IP address collisions more uncommon in the future
  # For VPC peerings, external private connections etc
  # /24 and /27 chosen to have enough space for resources but not too large to overuse IP Address space

  cidr = "10.0.175.0/24"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]          #Doesnt Match provider on other TF?
  private_subnets = ["10.0.1.0/27", "10.0.2.0/27", "10.0.3.0/27"]       #Seems Fine.
  public_subnets  = ["10.0.101.0/27", "10.0.102.0/27", "10.0.103.0/27"] # Also fine, but look into if we even want a private subnet or Public, 
  #if the info is coming from EC2, subnets would mean the EC2 also needs to be in the same one?
  # e.g. Ec2 which is store website would be in public, so RDS might be in private? Depends on situation

  enable_nat_gateway = true
  enable_vpn_gateway = true # Look into these, do you need these? Internet Gateway if Ec2 instances in same VPC, these, not sure about!

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
} #Please remove the terraform one, it has no need to be here and shows its copied and pasted :D 
# These tags are simple Env one is good! 

resource "aws_db_instance" "default" { #names, Get a convention and use it! default doesnt look good! 
  allocated_storage    = 100
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro" # This is a small one, which is best if youre deploying, but not really the best for a store maybe?
  username             = "foo"         #Not even gunna say about these...... See line 40 for a cool approach which would beef it out!
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az             = true # This will deploy and create in multi AZ zones https://aws.amazon.com/rds/ha/
}

# This is a cool idea. Would help keep items secure, and show off some other functions. Do Not need to do this, is overkill, but also cool and secure!

resource "random_password" "RDS_password" { # https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password  (Change Name)
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "DB_secret" { # (Think of better name)
  name = "DB_secret"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.DB_secret.id
  secret_string = <<EOF
   {
    "username": "admin",
    "password": "${random_password.RDS_password.result}"
   }
EOF
}

# This could then look something like! Wow! A new password which ISNT HARDCODED!!!!!!!!!! Very important... Nothing like that should be hardcoded. 
# Also sends this to secret manager in AWS to be stored!
resource "aws_db_instance" "default2" {
  allocated_storage    = 100
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = random_password.RDS_password.result
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az             = true
}