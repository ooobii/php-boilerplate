# PHP Boilerplate Virtual Machine
This repository acts as a template to easily create development environments for PHP applications that use a PostgreSQL backend.

## Software & Requirements
The following software is **required** on the host machine:
  - Machine Management: [Vagrant](https://www.vagrantup.com/)
  - Host Provider: [VirtualBox](https://www.virtualbox.org/)

The following runs _within_ the virtual machine that is created by Vagrant & hosted by VirtualBox:
  - Base Operating System: [Ubuntu 20.04 LTS](https://wiki.ubuntu.com/FocalFossa/ReleaseNotes?_ga=2.207412563.1314535857.1647823762-132093480.1647178546)
  - Web Hosting Service: [Apache2](https://httpd.apache.org/)
  - Web Hosting Processor: [PHP 7.3](https://www.php.net/) (_**UNSUPPORTED!**_)
  - Database Management Service: [PostgreSQL](https://www.postgresql.org/)


## Create Your Own Repository
To use this template repository, you can click the green "Use this template" button at the top of the page, or run the following command
in the GitHub CLI:
```
gh repo create <YourRepoName> --template ooobii/php-boilerplate
```



## Using this Repository
### Step 1: `env` Configuration.
The virtual machine requires a few details to be provided in order for it to be provisioned. These details should be created in a `.env` file in the root of your repository. You can clone the `env.example` file to get started quickly.

Here is an outline of the settings required to be set in the `.env` file:
#### Git Details
| **Variable** | **Description**                                                           |
|--------------|---------------------------------------------------------------------------|
| `GIT_NAME`   | The username to apply for Git commits made within the machine.            |
| `GIT_EMAIL`  | The email associated to the user that creates commits within the machine. |

#### Apache Configuration
| **Variable**  | **Description**                                                                                                                                                         |
|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PHP_VERSION` | The version of PHP that should be installed. <br> Must be an available version moniker from [The PHP repository](https://launchpad.net/~ondrej/+archive/ubuntu/php).    |
| `SITE_URL`    | The hostname / DNS name that the machine will check for when responding to web requests.                                                                                |

#### Database Configuration
| **Variable** | **Description**                                                      |
|--------------|----------------------------------------------------------------------|
| `DB_USER`    | Username created in the Postgres database instance.                  |
| `DB_PASS`    | Password used to authenticate as the newly created user in Postgres. |
| `DB_NAME`    | The database / catalog name to be created in Postgres.               |


### Step 2: Confirm Machine IP Address Assignment
After the `.env` file has been configured, you're ready to setup the Vagrant machine for use.

Take a look at the `Vagrantfile` file, and take note of the IP address that will be assigned to this machine. By default, the machine is configured to use the following IP address:
```
config.vm.network "private_network", ip: "192.168.56.100"
```

To use a custom IP address, feel free to edit the value assigned to `ip` on this line.


### Step 3: Provision the Vagrant Machine
Once you confirm that the IP address & port assignments meet your needs, you're ready to provision the VM for use! You can execute the following command to initialize the machine:
```
vagrant up
```

When you execute this command for the first time, your machine will need to "provision" itself - by downloading & installing packages from various `apt` sources and by configuring its services for use. This may take a few minutes, but after you run it the first time, you won't need to wait nearly as long.

Once this command completes, the virtual machine will be up and running! You can navigate to either `http://localhost:8080/` or `http://<SITE_URL>/` to view the hosted contents contained within the `/src` folder.

To stop the VM after it's started running, execute the following command:
```
vagrant halt
```



## Customizing the Machine
### Application Source Code
Files you modify within the `/src` folder of this repository will take immediate effect within the virtual machine - without the need to restart it to apply changes. This folder is "mounted" in the machine as a live directory.


### Hardware Allocation
The virtual machine by default is allocated the following resources from the host machine:
  - 2 CPU cores.
  - 1024MB of RAM (1GB).
  - 10GB of disk space.

To allocate additional CPU/RAM, you can modify the values assigned to the specific provider you're using for the virtual machine (VirtualBox by default).

To update the disk size, modify the following line in the `Vagrantfile` to fit your needs:
```
config.vm.disk :disk, size:"10GB", primary: true
```


### Provisioning
If you have any additional scripts / commands to run during the virtual machine provisioning phase, you can alter the `Vagrantfile` to make sure your scripts / commands are run.

There are 2 sections for provisioning in this repository's `Vagrantfile`: one is for Windows and one is for Unix-based systems - since path separators are handled differently. If you have an additional shell script that needs to be executed, make sure you add it to the `/build` folder, and create a `config.vm.provision` declaration to each of the system types (using appropriate path declaration).

It is recommended to **not** modify the `provision-vm.sh` script directly, and instead create your own that builds on top of the commands executed. This makes merging updates to this template into your personal repository easier in the future.


### Discarding your VM
If you'd like to destroy the virtual machine and start from scratch, you can execute the following command:
```
vagrant destroy
```

**Note:** This will **NOT** destroy any source code that you've written within the `/src` directory, but it **WILL** destroy any additional configuration that you've made within the machine that is not contained within a build script (e.g. modification of a `/etc/` file, packages installed after provisioning, etc.). Make sure that if you install any additional applications or make configuration changes within the machine, that you've written a provisioning script that can recover these changes, that this script has been saved to the `/build` directory, and the script is listed in the provisioning section of the `Vagrant` file!