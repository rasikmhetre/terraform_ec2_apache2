provider "aws"{
  region = "us-east-2"
}

resource "aws_vpc" "web_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "web_subnet" {
  cidr_block = "10.0.0.0/24" 
  vpc_id = "${aws_vpc.web_vpc.id}"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.web_vpc.id}"
}

resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.web_vpc.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
}
}

resource "aws_route_table_association" "ra" {
  subnet_id = "${aws_subnet.web_subnet.id}"
  route_table_id = "${aws_route_table.route.id}"
}
resource "aws_security_group" "web_sg" {
  name = "web security group"
  description = "security group is for web"
  vpc_id = "${aws_vpc.web_vpc.id}"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 } 
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_instance" "webserver" {
  instance_type = "t2.micro"
  ami = "ami-0c55b159cbfafe1f0"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.web_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/root/ec2/awsshop.pem")}"
}
  provisioner "file"  {
    source = "/root/ec2/run.sh"
    destination = "/tmp/run.sh"
}
  provisioner "remote-exec"  {

    inline = ["sudo chmod +x /tmp/run.sh",
               "sudo sh /tmp/run.sh"]

}
}
