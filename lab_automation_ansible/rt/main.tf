resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = [var.route]
    content {
      cidr_block = lookup(route.value, "cidr_block", null)
      gateway_id = lookup(route.value, "gateway_id", null)
    }
  }

  tags = {
    "Name" = var.name
  }
}