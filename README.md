# Introducción

## ¿Qué es OpenShift?

OpenShift es una PaaS que, haciendo uso de **kubernetes**,  permite desplegar fácilmente aplicaciones en contenedores

## Descripción del proyecto

En éste proyecto se desplegará un clúster de **OpenShift** para poder lanzar aplicaciones y servicios sobre él.

## Objetivos a alcanzar

Tener un clúster de **Openshift** totalmente funcional desplegado automáticamente sobre **OpenStack**, cuyos volúmenes los proporcionará el componente **Cinder** de **OpenStack** y los usuarios estarán sincronizados en un servidor **LDAP**.

# Proceso de instalación
Para realizar la instalación de OpenShift sobre OpenStack trabajaremos sobre un entorno virtual de python con las siguientes dependencias instaladas:

* Ansible version >= 2.4.1
* Jinja2 version >= 2.10
* Shade version >= 1.26
* Python-jmespath
* Python-dns
* Python-openstackclient
* Python-heatclient

Entonces clonamos el repositorio de OpenShift Origin, activamos la rama de la versión 3.9 y creamos el directorio que funcionará como inventario.
~~~
git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible
git checkout release-3.9
mkdir -p inventory/group_vars
~~~
Dentro de **group_vars** crearemos dos yaml que definirán nuestro entorno y la configuración de nuestro clúster. 
Del fichero [**all.yml**](https://github.com/DavidTinoco/OpenshiftOverOpenstack/blob/master/Provision/all.yml) tomará los valores para la pila de **OpenStack Heat** Y del fichero [**OSEv3.yml**](https://github.com/DavidTinoco/OpenshiftOverOpenstack/blob/master/Provision/OSEv3.yml) se tomará la configuración del clúster y donde definiremos la configuración de acceso a nuestro **OpenStack**.

Más adelante se detallarán algunos de estos parámetro un poco más en profundidad.

Ahora, desde nuestro proyecto de OpenStack crearemos un volumen igual al tamaño que hemos definido en el inventario OSEv3.yml y definimos el ID del volumen en la variable `openshift_hosted_registry_storage_openstack_volumeID`.

Procedemos, entonces a la comprobación de los prerrequisitos y al aprovisionamiento de las instancias de OpenStack desde el propio playbook.
~~~
ansible-playbook -i ~/openshift-ansible/inventory \ 
-i ~/openshift-ansible/playbooks/openstack/inventory.py \
~/openshift-ansible/playbooks/openstack/openshift-cluster/prerequisites.yml
ansible-playbook -i ~/openshift-ansible/inventory \ 
-i ~/openshift-ansible/playbooks/openstack/inventory.py \
~/openshift-ansible/playbooks/openstack/openshift-cluster/provision.yml
~~~
Una vez estén las instancias creadas añadiremos a nuestro servidor DNS los [registros](https://github.com/DavidTinoco/OpenshiftOverOpenstack/blob/master/DNS/os.pro) de cada máquina, y recargamos la zona.

Necesitaremos añadir a cada instancia el certificado de nuestro Horizon y modificar su hostname eliminando el “.novalocal” que añade OpenStack al crear la instancia.

~~~
scp ~/openshift/gonzalonazareno.crt openshift@IPFlotante:~/
ssh openshift@IPFlotante
sudo su -
update-ca-trust enable
cp /home/openshift/gonzalonazareno.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
hostnamectl set-hostname `hostname --short`.opens.pro
~~~

# Parámetros destacados de los inventarios
Valores a destacar en el inventario **OSEv3.yml**

`openshift_master_default_subdomain: "apps.opens.pro"` \
Es el dominio que usarán, por defecto, las aplicaciones que despleguemos sobre OpenShift, necesitaremos de un registro wildcard en nuestro dns que apunte hacia nuestro nodo de infraestructuras.

`openshift_master_cluster_public_hostname: "openshift.opens.pro"` \
Éste será el nombre desde el cuál será accesible desde fuera de nuestro proyecto el panel web, deberemos tener un registro en nuestro dns que apunte hacia nuestro máster

`openshift_disable_check: disk_availability,memory_availability,docker_storage` \
Ésto sólo será necesario si el escenario que vamos a montar no cumple con los requisitos mínimos de instalación de OpenShift

`openshift_hosted_registry_storage_openstack_volumeID: 4528-2-8dsd8-sds45` \
Es necesario crear, previamente a iniciar la instalación, un volumen para el registro de OpenShift y plasmarlo aquí.

Valores a destacar en el inventario all.yml

`openshift_openstack_dns_nameservers: ["172.22.200.136"]` \
Es necesario que el DNS lo administremos nosotros, ya que será necesario añadir registros para que, tanto la instalación, como el acceso a los servicios, funcionen correctamente.

`openshift_openstack_subnet_cidr: "10.0.1.0/24"` \
`openshift_openstack_pool_start: "10.0.1.2"` \
`openshift_openstack_pool_end: "10.0.1.240"`\
Ésta red la creará automáticamente en el aprovisionamiento del escenario, y estará conectada, mediante un router, también creado en la misma pila a nuestra ext-net.

`ansible_user: openshift`
`openshift_openstack_user: openshift`\
Importante que estos dos valores coincidan, ya que será con el usuario que se realizará la instalación, no tiene por qué ser el usuario de la imagen, ya que lo crea automáticamente en el aprovisionamiento de instancias.
