//Creating Key
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

//Generating Key-Value Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "ec2key"
  public_key = "${tls_private_key.tls_key.public_key_openssh}"

  depends_on = [
    tls_private_key.tls_key
  ]
}

//Saving Private Key PEM File
resource "local_file" "key-file" {
  content  = "${tls_private_key.tls_key.private_key_pem}"
  filename = "ec2key.pem"

  depends_on = [
    tls_private_key.tls_key
  ]
}

//Creating Security Group
resource "aws_security_group" "web-SG" {
  name        = "testec2-SG"
  description = "EC2 Security Group"

  //Adding Rules to Security Group 
  ingress {
    description = "SSH Rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP Rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


//Launching EC2 Instance
resource "aws_instance" "web" {
  ami             = "${var.ami_id}"
  instance_type   = "${var.ami_type}"
  key_name        = "${aws_key_pair.generated_key.key_name}"
  security_groups = ["${aws_security_group.web-SG.name}","default"]

  //Labelling the Instance
  tags = {
    Name = "testec2"
  }

  //Change Root volume size & type
    root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
  }

}

//Creating EBS Volume
resource "aws_ebs_volume" "testec2-vol" {
  availability_zone = "${aws_instance.web.availability_zone}"
  size              = var.external_volume_size
  type              = var.external_volume_type
  tags = {
    Name = "testec2-ebs"
  }
}

//Attaching EBS Volume to a Instance
resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.testec2-vol.id}"
  instance_id  = "${aws_instance.web.id}"
  force_detach = true
  
  depends_on = [
    aws_instance.web,
    aws_ebs_volume.testec2-vol
  ]
}

//Creating EBS Snapshot
resource "aws_ebs_snapshot" "ebs_snapshot" {
  volume_id   = "${aws_ebs_volume.testec2-vol.id}"
  description = "Snapshot of our EBS volume"
  
  tags = {
    env = "Production"
  }

  depends_on = [
    aws_volume_attachment.ebs_att
  ]
} 