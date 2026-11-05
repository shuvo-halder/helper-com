sudo apt update
sudo apt install cloud-guest-utils
sudo growpart /dev/vda 3



sudo pvresize /dev/vda3


sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
or,
sudo resize2fs /dev/vda2
