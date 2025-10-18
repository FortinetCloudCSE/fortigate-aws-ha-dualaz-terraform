output "fgt1_id" {
  value = aws_instance.fgt1.id
}

output "fgt2_id" {
  value = aws_instance.fgt2.id
}

output "cluster_eip_public_ip" {
  value = aws_eip.cluster_eip.public_ip
}

output "fgt1_hamgmt_ip" {
  value = var.only_private_ec2_api == "false" ? aws_eip.fgt1_hamgmt_eip[0].public_ip : "${element("${split("/", var.fgt1_hamgmt_ip)}", 0)}"
}

output "fgt2_hamgmt_ip" {
  value = var.only_private_ec2_api == "false" ? aws_eip.fgt2_hamgmt_eip[0].public_ip : "${element("${split("/", var.fgt2_hamgmt_ip)}", 0)}"
}

output "fgt1_eni1_id" {
  value = aws_network_interface.fgt1_eni1.id
}