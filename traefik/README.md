# traefik config

Add traefik to repo:
helm repo add traefik https://helm.traefik.io/traefik


Command to install traefik using helm
helm install traefik traefik/traefik --namespace=traefik --values=values.yaml

Command to upgrade traefik
helm upgrade traefik traefik/traefik --namespace=traefik --values=values.yaml
