ssh-keygen -t rsa -b 4096 -C "nigel.okeefe@gmail.com" 

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo "Now fetching the ssh key to copy to the keyboard."
xclip -sel clip < ~/.ssh/id_rsa.pub

echo "Opening github on firefox so you can setup that side"
firefox https://github.com/settings/keys &

