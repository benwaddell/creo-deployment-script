#### ***This repo does not contain any proprietary, sensitive, or confidential information.***

# creo-deployment-script

This is a Windows batch script that I created to automate the deployment of our company's engineering software. Prior to this script, new installations and software upgrades were done manually by IT support. Installation times took upwards of one hour per workstation. As the company grew, this quickly became a problem.

## What was the goal of this project?

The goal was to completely automate the entire installation process, and to have it run as a background process completely invisible to the end-user. This script allowed us to save hundred of hours in support time, ensured consistent installations, and provided easy, efficient deployments while allowing the end-users to continue working entirely uninterrupted. 

## How It Works

The script first determines which the local file server from which to retrieve the installation files and sets script variables.

Then it checks to see if Creo is already installed. If Creo is not installed, the installation will proceed, otherwise the installation is cancelled.

If the installation proceeds, installation files are copied from the file server to a temporary location on the workstation. This script was later bundled with the installation software and adapted for use as a single executable installation file, for use outside of the network file servers.

The script then checks to see if the prerequisite .Net Framework is installed, and installs it if necessary.

Creo is then installed and config files created by the Engineering team are then copied over to the appropriate directories.

The script then removes the temporary installation files and exits.

The entire process is logged to a central file server to see which computers received the software successfully, and what the progress of the deployment was in the event of an error.