# Creation of k8s Service Accounts, Roles, and bindings
# First, create the trifacta-job-runner SA
# This is responsible for launching pods on the cluster
resource "kubernetes_service_account_v1" "trifacta-job-runner" {
  metadata {
    name = "trifacta-job-runner"
    namespace = "default"
  }
}

/*
# If required, you can create a k8s SA separately
resource "kubernetes_service_account_v1" "pod-sa" {
  metadata {
    name = "trifacta-pod-sa"
    namespace = "default"
  }
}
*/

# Create role for trifacta-job-runner
resource "kubernetes_role" "trifacta-job-runner-role" {
  metadata {
    name = "trifacta-job-runner-role"
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    verbs          = ["create", "delete", "list", "get"]
  }
  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    verbs          = ["get", "create", "delete"]
  }
  rule {
    api_groups     = [""]
    resources      = ["pods", "configmaps", "services"]
    verbs          = ["list", "get", "create", "delete"]
  }
  rule {
    api_groups     = [""]
    resources      = ["pods/log", "pods/portforward"]
    verbs          = ["get", "list", "create"]
  }
  rule {
    api_groups     = ["batch"]
    resources      = ["jobs"]
    verbs          = ["get", "create", "delete", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts"]
    verbs          = ["list", "get"]
  }
}

# Create cluster role for trifacta-job-runner
resource "kubernetes_cluster_role" "node-list-role" {
  metadata {
    name = "node-list-role"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list"]
  }
}

# Bind role to trifacta-job-runner SA
resource "kubernetes_role_binding_v1" "trifacta-job-runner-rb" {
    metadata {
    name      = "trifacta-job-runner-rb"
    namespace = "default"
    }
    role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "trifacta-job-runner-role"
    }
    subject {
    kind      = "ServiceAccount"
    name      = "trifacta-job-runner"
    namespace = "default"
    }
}
# Bind cluster role to trifacta-job-runner SA
resource "kubernetes_cluster_role_binding_v1" "trifacta-job-runner-cluster-binding" {
  metadata {
    name = "node-list-rb"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "node-list-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "trifacta-job-runner"
    namespace = "default"
  }
}

# Create token as secret for trifacta-job-runner
resource "kubernetes_secret_v1" "trifacta-job-runner-secret" {
  metadata {
    name = "trifacta-job-runner-token"
    annotations = {
      "kubernetes.io/service-account.name" = "trifacta-job-runner"
    }
  }

  type = "kubernetes.io/service-account-token"
}

# Output token for trifacta-job-runner for input into Dataprep config
output "trifacta_job_runner_token" {
  value = kubernetes_secret_v1.trifacta-job-runner-secret.data.token
  sensitive = true
}

