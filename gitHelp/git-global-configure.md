Create an Identity for Git
To begin with, you first need to set up a default identity (username and email address) for every commit you make on your system. There are two ways to do this. You can either set a global identity so that all the commits you push go through the same identity or set a per-repository identity to use separate identities for different projects.

To set a global identity, open the terminal and run the below commands:

git config --global user.name "your_name"
git config --global user.email "your_email_address"
If you want to set up your default identity for a particular repository, first head over to the directory which contains the repository. Use the ls command to list directories (and sub-directories) and the cd command to go into them.

Once you're in the repository, run the following commands in the terminal:

git config user.name "your_name"
git config user.email "your_email_address"
