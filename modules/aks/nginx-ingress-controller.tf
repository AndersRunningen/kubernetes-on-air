resource "helm_release" "nginx_ingress_controller" {
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  namespace  = "kube-system"
  version    = "9.3.18"
  timeout    = 600

  set {
    name  = "publishService.enabled"
    value = true
  }
}
