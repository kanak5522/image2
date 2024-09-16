provider "aws" {
  region = "eu-west-1"
}


resource "aws_instance" "kanak1" {
  instance_type = "t2.micro"
  ami           = "ami-0fa8fe6f147dc938b"
  tags = {
    Name = "knkuser"
  }
}

resource "aws_instance" "knkchandel" {
  instance_type = "t2.micro"
  ami           = "ami-0fa8fe6f147dc938b"
  tags = {
    Name = "knkchan"
  }
}
