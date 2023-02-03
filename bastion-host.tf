resource "aws_instance" "deen-bastion" {
  ami                    = lookup(var.AMIS, var.AWS_REGION)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deenkey.key_name
  subnet_id              = module.vpc.public_subnets[0]
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.deen-bastion-sg.id]

  tags = {
    Name    = "deen-bastion"
    Project = "deen"
  }

  provisioner "file" {
    content     = templatefile("templates/db-deploy.tmpl", { rds-endpoint = aws_db_instance.deen-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/deen-dbdeploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install --reinstall mysql-server-8.0 -y",
      "sudo service mysql status",
      "chmod +x /tmp/deen-dbdeploy.sh",
      "sudo /tmp/deen-dbdeploy.sh"
    ]
  }

  connection {
    user        = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }
  depends_on = [aws_db_instance.deen-rds]
}
