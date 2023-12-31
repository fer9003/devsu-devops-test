# DevOps Assessment

[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/fullpipeline.png "Pipeline")](https://devopstest-imagenes-fm.s3.amazonaws.com/fullpipeline.png)

## Infraestructura como código:
Siguiendo buenas prácticas se centralizó el state de terraform en un bucket S3 y se utilizó una DynamoDB table para bloquear el state en caso de intentos de provisionamiento simultaneo.
El proyecto Terraform está estructurado usando módulos, los cuales detallo a continuación:

1. Módulo networking: Contiene los manifiestos que permiten provisionar los componentes de red "VPC, Subnet, Route Table, Internet Gateway" que serán utilizados por el módulo jenkins y módulo jenkins-node.
2. Módulo jenkins: Contiene los manifiestos para el provisionamiento del servidor Jenkins, se utiliza un local provisioner para ejecutar automáticamente un playbook de ansible el cual configura el servidor con los paquetes necesarios "git, docker, docker-compose, etc" y despliega el contenedor de jenkins mediante un docker compose.
3. Módulo jenkins-node: Contiene los manifiestos para el provisionamiento de una instancia ec2 la cual actuará como un runner de jenkins para la ejecución de ciertos jobs "distribuir la carga", este runner es configurado con una label de nombre local para referenciar en la pipeline los jobs que se desea ejecutar con este runner.
4. Módulo EKS cluster: Contiene los manifiestos para el provisionamiento de vpc, subnets, nodegroup, cluster eks, AWS load balancer controller, roles, etc, se utiliza el provider helm para automatizar la instalación del AWS load balancer controller.

## SONARQUBE
Este servidor se ejecuto en una VM vagrant local "disminuir costos del ambiente", se expone a través de ngrok en el puerto 9000 para que pueda ser interconectado con el servidor de Jenkins.

## CICD
El pipeline contiene los siguientes stages:
1. Git Clone
2. Test Unitario
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/Unittestlogs.png "UnitTEst")](https://devopstest-imagenes-fm.s3.amazonaws.com/Unittestlogs.png)

3. SAST "En el escaneo se encuentra BUGS en el codigo, se recomienda mejorar el codigo."
   
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/sonarqube_bugs.png "SAST")](https://devopstest-imagenes-fm.s3.amazonaws.com/sonarqube_bugs.png)

4. Container Image Scan / OPA Dockerfile
Es recomendable realizar escaneos a las imagenes que se usan para contenerizar las aplicaciones para descartar vulnerabilidades, de igual manera se ejecuta un test que valida la configuracion del Dockerfile con el fin de encontrar y corregir patrones de configuracion negativos.
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/containerimagescan.png "ConatinerScan")](https://devopstest-imagenes-fm.s3.amazonaws.com/containerimagescan.png)

5. Docker Build and Push
Se crea la custom image en base al Dockerfile, se coloca un tag a la imagen y se realiza un push al repositorio en DockerHub.
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/dockerbuildandpush.png "ConatinerScan")](https://devopstest-imagenes-fm.s3.amazonaws.com/dockerbuildandpush.png)

6. Deploy to Dev K8s
Despliegue utilizando la helmchart para ambiente de desarrollo.
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/deploydevk8s.png "DeployDev")](https://devopstest-imagenes-fm.s3.amazonaws.com/deploydevk8s.png)

7. Integration Test "solamente se colocó el stage para que se visualice que es necesario"

8. Promote to Production: Aprobación manual para llevar los cambios a Producción.
Es recomendable colocar aprobacion manual para llevar los cambios a produccion.
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/promotetoprod.png "Promote")](https://devopstest-imagenes-fm.s3.amazonaws.com/promotetoprod.png)

9. Deploy to Production k8s
 Despliegue utilizando la helmchart para ambiente de produccion.
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/deployprodk8s.png "Deployk8s")](https://devopstest-imagenes-fm.s3.amazonaws.com/deployprodk8s.png)


## HELM CHARTS
Utilice helm charts para realizar el despliegue de la aplicación en ambiente de desarrollo y producción "usando namespaces" debido a que es fácil de mantener en el tiempo y óptimo para actualizar nuevos cambios.

## INGRESS
Se crearon 2 ingress un por ambiente como punto de entrada a el cluster EKS, de esta manera se puede redireccionar basado en reglas de enrutamiento a los services en este caso al service msvc-node-svc.

[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/ingressAWS.png "Ingress")](https://devopstest-imagenes-fm.s3.amazonaws.com/ingressAWS.png)

## Subdminios y certificado SSL
Genere un certificado SSL mediante el servicio de AWS ACM para garantizar que las comunicaciones estén encriptadas, En el custom domain sandboxenv.site cree registros de tipo CNAME que apunten a los Ingress de cada ambiente.


### SSL
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/sslcert2.png "SSL")](https://devopstest-imagenes-fm.s3.amazonaws.com/sslcert2.png)

Desarrollo:
dev-nodeapp.sandboxenv.site

Producción:
nodeapp.sandboxenv.site


## Pruebas de funcionamiento

### Creación de Usuario mediante método POST
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/testapp2.png "TestApp")](https://devopstest-imagenes-fm.s3.amazonaws.com/testapp2.png)

### Consultar el usuario creado mediante método GET
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/testapp3.png "TestApp2")](https://devopstest-imagenes-fm.s3.amazonaws.com/testapp3.png)

### Consulta Desde el Navegador
[![Image](https://devopstest-imagenes-fm.s3.amazonaws.com/testapp.png "TestApp3")](https://devopstest-imagenes-fm.s3.amazonaws.com/testapp.png)

### Opciones de mejora
1. Implementar HPA "Horizontal Pod Autoscaling" 
2. Refactorizar el código para aislar la BD de la aplicación, la BD se podría ejecutar en un contenedor separado.
3. Corregir algunos bugs que arroja la app "resultado de la ejecución de SAST"