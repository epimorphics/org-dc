# Manual sync to deployed instance
rsync -avz -e "ssh" --rsync-path="sudo rsync" org-dc/ TODO:/opt/org-dc/
