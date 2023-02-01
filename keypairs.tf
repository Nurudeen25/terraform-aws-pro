resource "aws_key_pair" "deenkey" {
  key_name   = "deenkey"
  public_key = file(var.PUB_KEY_PATH)
}