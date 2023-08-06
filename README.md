# k8s-configs
I am moving things over from docker compose to k8s.  Starting with a k3s cluster running traefik and cloudflared for ingress and longhorn for storage.

## Things I have installed so far.
Sysdig https://sysdig.com  - used for monitoring and security

### scripts directory
This will be any scripts I use for backup, etc. 

*backuppods.sh* - script to backup pod contents using kubectl cp

### portainer directory
Everyone needs portainer
portainer-deployment.yaml is the manifest for installing portainer. 
portainer-ingress.yaml is the manifest to get ingress setup through traefik
portainer-pvc.yaml is the volume claim to get a volume allocated from longhorn

### dnloads directory
Here I will have things like Cloudflare tunnel, sonarr, radarr, etc.

Using the NFS mount within the container for all data access, video files, etc.  

Using Longhorn for all config folders.   have snapshots with longhorn configured as well as backup to NFS share.


