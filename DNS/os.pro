$TTL		86400
@		IN		SOA	dns.opens.pro.	root.opens.pro. (
				0	; Serial
				3600	; Refresh
				600	; Retry
				86400	; Expire
				600 )	; Negative Cache
$ORIGIN	opens.pro.
@			IN		NS	dns.opens.pro.
dns			IN		A	172.22.200.136
ldap			IN		A	172.22.200.136
master-0		IN		A	10.0.1.5
app-node-0		IN		A	10.0.1.3
app-node-1		IN		A	10.0.1.13
infra-node-0		IN		A	10.0.1.7
*.apps.opens.pro.	IN		A	172.22.201.204
openshift		IN		A	172.22.201.193
