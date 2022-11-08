#!/bin/bash
# ufw setup script
# Written by AJR 2022

function pause_continue {
    # create user prompt with autocontinue and use $'STRING\n' to create new line
    read -p $'Press [ENTER] to continue (will continue automatically in 5s)\n' -t 5
}

# output to log file (appended) as well as screen
echo "Script started: $(date)" > ufw_setup.log
echo "-->> Setting up uncomplicated firewall (ufw)" | tee -a ufw_setup.log;

echo "-->> Install ufw" | tee -a ufw_setup.log; pause_continue
sudo apt-get install ufw -y | tee -a ufw_setup.log

echo "-->> Enable and start ufw" | tee -a ufw_setup.log; pause_continue
sudo ufw enable ufw | tee -a ufw_setup.log

echo "-->> Add rule to allow SSH (22)" | tee -a ufw_setup.log; pause_continue
sudo ufw allow ssh | tee -a ufw_setup.log

echo "-->> Add rule to allow http (80) and https (443)" | tee -a ufw_setup.log; pause_continue
sudo ufw allow 'WWW Full' | tee -a ufw_setup.log

echo "-->> Add rule to allow outgoing traffic" | tee -a ufw_setup.log; pause_continue
sudo ufw default allow outgoing | tee -a ufw_setup.log

echo "-->> Add rule to deny incoming traffic by default (apart from on previous ports)" | tee -a ufw_setup.log; pause_continue
sudo ufw default deny incoming | tee -a ufw_setup.log

echo "-->> Show added rules - CONFIRM SSH IS SHOWING" | tee -a ufw_setup.log; pause_continue
sudo ufw show added | tee -a ufw_setup.log

echo "-->> Reload ufw now new rules added" | tee -a ufw_setup.log; pause_continue
sudo ufw reload | tee -a ufw_setup.log

echo "-->> Show numbered status of opened ports" | tee -a ufw_setup.log; pause_continue
sudo ufw status numbered | tee -a ufw_setup.log

echo "-->> Switch on ufw logging" | tee -a ufw_setup.log; pause_continue
sudo ufw logging on | tee -a ufw_setup.log

echo "-->> Show all ports opened on system" | tee -a ufw_setup.log; pause_continue
sudo ss -atpu | tee -a ufw_setup.log

echo "-->> ufw setup complete - see $PWD/ufw_setup.log for log file"
echo "Script completed: $(date)" >> ufw_setup.log