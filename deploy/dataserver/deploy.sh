# Sync for deployment and run the deployment script
MC=org-dc
rsync -avz -e "ssh" --rsync-path="sudo rsync" root bootstrap.sh $MC:/vagrant
ssh $MC "sudo bash /vagrant/bootstrap.sh"
