# Server configuration (IaC)

## Git strategy

Once you have implemented a change make a pull request to have the pipeline implement your changes.

## Environment information

### Root

The root terraform config sets up all providers and creates the kubernetes cluster

### Modules

Consists of reusable terraform modules

### Environments

All separate environments, this will be things such as devops, test, staging, and prod
They are separated using namespaces, and will be prioritized through the PriorityClass kubernetes kind.

#### Production

The production environment is where the final product will be deploy. This means that all services will be running in
this environment.

#### Staging

The staging environment will mirror the production environment. No main image will be deployed to production before
being tested in the staging environment.

#### Test

The test environment is seen as our test playground. This will not have all the services running at the same time.
Instead, this environment will only have deployments that will need testing in the given situation.  
An example could be if you deploy three services to view if a camunda process is working together as intended.  
This environment will change all the time.

## Examples

### Deployment and services

To be able to deploy a service in Kubernetes you will need two abstraction layers called deployments and services.
Deployment is where you define which image should run as well how many replication you would like of this image. A
service then created as an abstraction around deployments so it can function as a loadbalancer to the different
replicas.   
This can be made by following the examples below:  
*Note this is in terraform and not a yaml example*  
**Deployment**

```terraform  
resource "kubernetes_deployment" "camunda" {
  metadata {
    namespace = local.namespace
    name      = "camunda"
    labels    = {
      app = "camunda"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "camunda"
      }
    }
    template {
      metadata {
        labels = {
          app = "camunda"
        }
      }
      spec {
        priority_class_name = local.priority
        container {
          name  = "camunda"
          image = "tobiaszimmer/exam-camunda-server:main-0.0.3"
          env {
            name  = "CAMUNDA_ADMIN_USERNAME"
            value = var.camunda_admin_user
          }
          env {
            name  = "CAMUNDA_ADMIN_PASSWORD"
            value = var.camunda_admin_password
          }
          #... if you need more environments put them here ... 
        }
      }
    }
  }
}  
```  

*Services*

```terraform
resource "kubernetes_service" "camunda" {
  metadata {
    namespace = local.namespace
    name      = "camunda"
  }
  spec {
    selector = {
      # Note (app = "camunda") is a direct reference to the deployments (app = "camunda")
      app = "camunda"
    }
    port {
      port        = 8080
      target_port = "8080"
    }
  }
}
```  

#### Databases

In Kubernetes you will need to make a persistence volume claim which will claim a specific amount of GB storage on our
cloud provider (Digital Ocean).  
This is where all our data is persisted in our current setup.  
The following is an example of a persistence volume claim:

```terraform
resource "kubernetes_persistent_volume_claim" "camunda_volume" {
  metadata {
    # name has to be unique. "postgresql-camunda-data"
    name      = "postgresql-camunda-data"
    namespace = local.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
  }
}
```

Now you will have to make a database which is connected to the persistence volume claim.  
If you need to make further configuration look a the following
link [Postgres configuration](https://github.com/bitnami/charts/tree/main/bitnami/postgresql/#installing-the-chart).  
The following is an example of how to make a database.

```terraform
resource "helm_release" "camunda_postgres" {
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  name       = "postgres-camunda"
  namespace  = local.namespace

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
  set {
    name  = "primary.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.camunda_volume.metadata.0.name
  }
  set {
    name  = "auth.enablePostgresUser"
    value = "false"
  }
  set {
    name  = "auth.username"
    value = "database user" # var.camunda_postgres_user
  }
  set {
    name  = "auth.password"
    value = "database password" # var.camunda_postgres_user_password
  }
  set {
    name  = "auth.database"
    value = "name of you database" # var.camunda_postgres_db
  }
  set {
    name  = "architecture"
    value = "standard"
  }
  set {
    name  = "primary.priorityClassName"
    value = local.priority
  }
  set {
    name  = "primary.persistence.size"
    value = "3Gi"
  }
}
```

### Networking

All traffic to our Kubernetes cluster is handled through a loadbalancer called Ingress. This can be found in
the `networking.tf` file which is included in all modules. To define a new endpoint for Ingress you will have to create
a new certificate.

```yaml
dnsNames:
  - ${format("api.staging.%s", var.website)}
  - ${format("camunda.staging.%s", var.website)}
  - ${format("YOUR_SUBDOMAIN_NAME.ENVIRONMENT.%s", var.website)}
```  

To add your subdomain name you will also have to add it to the host. Which is done in the following way:

```terraform
tls {
  hosts = [
    format("api.staging.%s", var.website),
    format("camunda.staging.%s", var.website),
    format("YOUR_SUBDOMAIN_NAME.ENVIRONMENT.%s", var.website)
  ]
  secret_name = local.secret_name
}
```

Now define the Ingress rule for that subdomain.

```terraform
 rule {
  host = format("YOUR_SUBDOMAIN_NAME.ENVIRONMENT.%s", var.website)
  http {
    path {
      backend {
        service {
          name = "NAME_OF_YOUR_KUBERNETES_SERVICE" # This references the name of the service you previously have created
          port {
            number = 8080 # Use a port that the Kubernetes service is exposing
          }
        }
      }
      path_type = "Prefix"
      path      = "/"
    }
  }
}
```  

For the last step you will need to add you subdomain in the root `main.tf` file.

```terraform
module "domain" {
  source     = "./modules/domain"
  domain     = var.website
  subdomains = [
    "build",
    "api.staging",
    "api.test",
    "api",
    "camunda.staging",
    "camunda.test",
    "camunda",
    "YOUR_SUBDOMAIN_NAME.ENVIRONMENT"
  ]
  target_ip = module.staging.load_balancer_ip
  ttl_sec   = 300
}
```  

### Security

To not have variables in plain text we use terraform cloud to inject variables into our terraform files. All variables
coming from the cloud are defined in the root directories `variables.tf` file.  
When setting up a database for production are staging environment you will need to use the explained approach.
*Note: remember to install terraform plugin in your IDE*

1. Go to [terraform cloud](https://app.terraform.io/app/team-rocket/workspaces/team-rocket/variables) in the Team Rocket
   workspace.
2. Add your variable here in plain text, so we all can see them.
3. Add the newly created variable in the root variables.tf.
4. Add the same variable in the environment/YOUR_ENVIRONMENT/variables.tf.
5. Add the variable in the root main.tf file to the environment you will be using this variable in. If you are using
   IntelliJ this will be the module which is screaming at you in yellow text.
6. Use the variable by typing var.YOUR_VARIABLE_NAME.

### Scripts

Provides scripts to allow running scripts in all terraform modules.
Example:

```bash
sh scripts/execute.sh validate
```

This will run the validate.sh script in all modules. 
