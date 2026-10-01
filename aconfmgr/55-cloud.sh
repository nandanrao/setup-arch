# Containers, Kubernetes, cloud CLIs

AddPackage aws-cli # Universal Command Line Interface for Amazon Web Services
AddPackage docker # Pack, ship and run any application as a lightweight container
AddPackage docker-compose # Fast, isolated development environments using Docker
AddPackage eksctl # Command line tool for creating clusters on Amazon EKS
AddPackage helm # The Kubernetes Package Manager
AddPackage kubectl # A command line tool for communicating with a Kubernetes API server
AddPackage kubectx # Utility to manage and switch between kubectl contexts and Kubernetes namespaces
AddPackage minio-client # Replacement for ls, cp, mkdir, diff and rsync commands for filesystems and object storage
AddPackage rclone # rsync for cloud storage
AddPackage terraform # HashiCorp tool for building and updating infrastructure as code idempotently
AddPackage --foreign circleci-cli-bin # CircleCI's new command-line application.
AddPackage --foreign google-cloud-cli # A core set of command-line tools for the Google Cloud Platform. Includes only gcloud core (with beta and alpha commands), gcloud-crc32c and man pages
AddPackage --foreign google-cloud-sdk-gke-gcloud-auth-plugin # A google-cloud-sdk component that provides a kubectl authentication plugin for GKE.
AddPackage --foreign googleworkspace-cli-bin # One CLI for all of Google Workspace
CopyFile /etc/profile.d/google-cloud-cli.sh 755
CreateLink /etc/systemd/system/multi-user.target.wants/docker.service /usr/lib/systemd/system/docker.service
