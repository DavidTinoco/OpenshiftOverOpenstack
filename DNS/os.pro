$TTL		86400
@			IN		SOA	dns.opens.pro.	root.opens.pro. (
			0	; Serial
			3600	; Refresh
			600	; Retry
			86400	; Expire
			600 )	; Negative Cache
$ORIGIN	opens.pro.
@			IN		NS	dns.opens.pro.
dns			IN		A	"ip del dns"
ldap			IN		A	"ip del ldap"
master-0		IN		A	"ip del master"
app-node-0		IN		A	"ip del nodo 0"
app-node-1		IN		A	"ip del nodo 1"
infra-node-0		IN		A	"ip del nodo infra"
*.apps.opens.pro.	IN		A	"ip del nodo infra"
openshift		IN		A	"up del master"
