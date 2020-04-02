resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_service_account" "external_dns" {
  account_id   = "external-dns"
  display_name = "Kubernetes external-dns service account"
}

resource "google_project_iam_binding" "external_dns" {
  role               = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.external_dns.email}",
  ]

  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_service_account_key" "external_dns" {
  service_account_id = google_service_account.external_dns.name
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "external-dns-service-account"
    namespace = "kube-system"
  }

  data = {
    "credentials.json" = base64decode(google_service_account_key.external_dns.private_key)
  }
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "2.20.10"
  namespace  = "kube-system"

  set {
    name  = "provider"
    value = "google"
  }

  set {
    name  = "google.project"
    value = var.google_project
  }

  set {
    name  = "google.serviceAccountSecret"
    value = kubernetes_secret.external_dns.metadata[0].name
  }

  set {
    name  = "google.serviceAccountSecretKey"
    value = "credentials.json"
  }
}