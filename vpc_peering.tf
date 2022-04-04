data "aws_caller_identity" "current" {}

resource "aws_vpc_peering_connection" "mgmt-to-prod" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = aws_vpc.prod-vpc.id
  vpc_id        = aws_vpc.mgmt-vpc.id
  auto_accept   = true
}

resource "aws_route" "mgmt-to-prod-route" {
  route_table_id            = aws_route_table.mgmt-public-rt.id
  destination_cidr_block    = aws_vpc.prod-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-prod.id
}

resource "aws_route" "prod-public-to-mgmt-route" {
  route_table_id            = aws_route_table.prod-public-rt.id
  destination_cidr_block    = aws_vpc.mgmt-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-prod.id
}

resource "aws_route" "prod-private-1-to-mgmt-route" {
  route_table_id            = aws_route_table.prod-private-rt[0].id
  destination_cidr_block    = aws_vpc.mgmt-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-prod.id
}

resource "aws_route" "prod-private-2-to-mgmt-route" {
  route_table_id            = aws_route_table.prod-private-rt[1].id
  destination_cidr_block    = aws_vpc.mgmt-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-prod.id
}

resource "aws_route" "prod-private-3-to-mgmt-route" {
  route_table_id            = aws_route_table.prod-private-rt[2].id
  destination_cidr_block    = aws_vpc.mgmt-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-prod.id
}

resource "aws_vpc_peering_connection" "mgmt-to-dev" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = aws_vpc.dev-vpc.id
  vpc_id        = aws_vpc.mgmt-vpc.id
  auto_accept   = true
}

resource "aws_route" "mgmt-to-dev-route" {
  route_table_id            = aws_route_table.mgmt-public-rt.id
  destination_cidr_block    = aws_vpc.dev-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-dev.id
}

resource "aws_route" "dev-public-to-mgmt-route" {
  route_table_id            = aws_route_table.dev-public-rt.id
  destination_cidr_block    = aws_vpc.mgmt-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-dev.id
}

resource "aws_route" "dev-private-to-mgmt-route" {
  route_table_id            = aws_route_table.dev-private-rt.id
  destination_cidr_block    = aws_vpc.mgmt-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mgmt-to-dev.id
}
