Resource_limit
==============

For limiting the resources for a user in linux system

1. Change the user to be root
2. Run the script install_grsec.sh 
3. During script running Kernel configuration  steps need to be followed as below
   a. Scroll down and select Security options and hit enter
   b. Type space bar twice for enabling Grsecurity and scroll down and select Customize Configuration  and hit enter 
   c. Scrolldown and select KernelAuditing  and hit enter 
   d. scrolldown for exec  logging and type spacebar
   e. scrolldown for Resource logging and type spacebar   
   f. scrolldown for fork failure logging and type spacebar
   g. By using right arrowkey hit enter on save and then ok
   h. select exit and hit enter repeat  only step h  4 times  
4. Compiling Kernel will take around 15 minutes
5. After completion of script execution reboot the system.
6. Now set the user limit and run forkbomb, check the log /var/log/kern.log 
