# GRCC Web Applications Classes
For Grand Rapids Community College's Web Applications I &amp; II (CIS 241 &amp; CIS 247) classes. 

This repository will help students in the creation of a web server with PHP support in Amazon Web Services (AWS) using a provided shell script.

## Check Your DNS Records
_The Domain Name System (DNS) is the phonebook of the Internet. Humans access information online through domain names, like nytimes.com or espn.com. Web browsers interact through Internet Protocol (IP) addresses. DNS translates domain names to IP addresses so browsers can load Internet resources. The process of updating the servers so that web browsers can find a site is called propagation. Officially, it can take up to 72 hours for a DNS entry to propagate, but often only takes 30 minutes or a few hours at most._

Before you begin, check to make sure your DNS records have been set up correctly:

1. Go to [DNSchecker.org](https://dnschecker.org/)
2. In the box under DNS Check, enter your domain name and press <kbd>Enter</kbd> or press the search button.
3. You will get a green check mark if your domain has been added to the DNS server. Once you see green check marks, you are ready to continue.
    - If you aren't getting green check marks, double check your instructions on how to setup your DNS records.

*Note that Certbot will not be able to create an SSL certificate for a site it is unable to find, so be sure your domain name has propagated before running this script.*

## Getting the Script Onto Your Server
**FIRST:** Connect to your server console via SSH (Terminal, WinSCP, Putty, etc.) or the AWS Connect function.

### METHOD 1: Download the Script (Recommended)
#### Using WinSCP
If you are using WinSCP, you can [download `install-lamp-secure.sh` from this repository](install-lamp-secure.sh?raw=1) and use the WinSCP GUI to upload the file to ec2-user's personal home directory. This will make it easy to locate when you need to run it in a minute. Once you've uploaded the script file, click on the `Open session in PuTTY` button and move on to [Running the Script](#running-the-script)

#### Using the Terminal
By default, when you SSH into your server as `ec2-user`, you will be at the `ec2-user` home directory, which will be noted with a tilde (~).

Download `install-lamp-secure.sh` from this repository using the following command:
```
wget https://github.com/christopherpowers1/grcc-webapplications/raw/main/install-lamp-secure.sh
```

### METHOD 2: Use `nano` to Create the Script
If you prefer, you can create the script using the built-in text editor in Linux called Nano. ([How to Use Nano (external)](https://linuxize.com/post/how-to-use-nano-text-editor/)) 

1. On your Linux terminal screen, verify you are in the `ec2-user` home directory `~` by entering: 
```
cd ~
```
2. Create a new file using `nano` called `install-lamp-secure.sh`:
```
sudo nano install-lamp-secure.sh
```

3. Open this on GitHub in a new tab: [install-lamp-secure.sh](./install-lamp-secure.sh) (right click to open in new tab).
4. Copy the script by clicking the copy button in the upper right corner next to the <kbd>Raw</kbd> button or select all of the text in the code box and press <kbd>Ctrl + C</kbd> to copy.
5. Back in 'nano', paste the script into the text editor.
6. Save the file by pressing <kbd>Ctrl + X</kbd> then press <kbd>y</kbd> then <kbd>Enter</kbd> to confirm the save, then <kbd>Enter</kbd> to accept the file name.

You're now ready to run the script.

## Running the Script
### ==READ THIS FIRST==
Watch what the script is doing as it runs. The script will display pertinent information as it goes along. At several points, it will pause and either give you information or ask you for information. 

It will ask you to check to see if your server is running. AT THAT POINT, IF YOUR SERVER IS NOT RUNNING, DO NOT CONTINUE UNTIL IT IS WORKING. The Domain Name Server (DNS) needs to be able to resolve before Certbot can register your domain for the SSL certificate. See the [Check Your DNS Records](#check-your-dns-records) section at the top of this readme file for details.

You will also be prompted for the domain name you will be using for the class. Be sure to include the TLD portion because what you enter will be used in Certbot to register the domain for SSL certification. For example: `your-domain.xyz` not `your-domain`

### Actually Run the Script
(If you aren't already, connect to your server using SSH or the AWS Connect function.)

Verify you are in the `ec2-user` home directory `~`:
```
cd ~
```

To run the script, we will use the bash command:
```
bash install-lamp-secure.sh
```

If your script doesn't run, you may need to make it executable:
```
chmod +x install-lamp-secure.sh
```


