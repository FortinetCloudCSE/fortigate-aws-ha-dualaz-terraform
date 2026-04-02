Content-Type: multipart/mixed; boundary="==Boundary=="
MIME-Version: 1.0

--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system vdom-exception
edit 1
set object system.interface
next
edit 2
set object router.static
next
end
config system settings
set allow-subnet-overlap enable
end
config system global
set hostname Fgt1
set admintimeout 60
end
%{ if private_ec2_api == "true" }
config system dns
set primary 169.254.169.253
unset secondary
unset protocol
unset server-select-method
end
%{ endif }
config system interface
edit port1
set mode static
set ip ${fgt1_public_ip}
set allowaccess https ping ssh fgfm
set alias public
next
edit port2
set mode static
set ip ${fgt1_private_ip}
set allowaccess ping
set alias private
next
edit port3
set mode static
set ip ${fgt1_hamgmt_ip}
set allowaccess https ping ssh
set alias hamgmt
next
end
config router static
edit 1
set device port1
set gateway ${public_subnet_intrinsic_router_ip}
next
edit 2
set device port2
set dst ${vpc_cidr}
set gateway ${private_subnet_intrinsic_router_ip}
next
edit 3
set device port2
set dst 10.0.0.0/8
set gateway ${private_subnet_intrinsic_router_ip}
next
edit 4
set device port2
set dst 172.16.0.0/12
set gateway ${private_subnet_intrinsic_router_ip}
next
edit 5
set device port2
set dst 192.166.0.0/16
set gateway ${private_subnet_intrinsic_router_ip}
next
end

config firewall policy
edit 1
set name "egress_access"
set srcintf "port2"
set dstintf "port1"
set srcaddr "all"
set dstaddr "all"
set action accept
set schedule "always"
set service "ALL"
set logtraffic all
set nat enable
next
edit 2
set name "east-west_access"
set srcintf "port2"
set dstintf "port2"
set srcaddr "all"
set dstaddr "all"
set action accept
set schedule "always"
set service "ALL"
set logtraffic all
next
end

config system sdn-connector
edit "aws-instance-role"
set status enable
set type aws
set use-metadata-iam enable
set alt-resource-ip enable
next
end

config system ha
set group-name group1
set mode a-p
set hbdev port3 50
set session-pickup enable
set ha-mgmt-status enable
config ha-mgmt-interface
edit 1
set interface port3
set gateway ${hamgmt_subnet_intrinsic_router_ip}
next
end
set override disable
set priority 255
set unicast-hb enable
set unicast-hb-peerip ${fgt2_hamgmt_ip}
set ha-uptime-diff-margin 60
set route-ttl 30
set password ${ha_pass}
end

%{ if license_type == "byol" }
--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${file(license_file)}
%{ endif }
%{ if license_type == "flex" }
--==Boundary==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN: ${license_token}
%{ endif }
--==Boundary==--