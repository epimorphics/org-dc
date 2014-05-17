# Sync for deployment and run the deployment script
MC=#TOO set machine
rsync -avz -e "ssh" --rsync-path="sudo rsync" org-dc bootstrap.sh target/*.war $MC:/vagrant
ssh $MC "sudo sh /vagrant/bootstrap.sh"
