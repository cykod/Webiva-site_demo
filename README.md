Module for launching Demo sites on Webiva.org
=============================================


You'll ened to configure site images in the Content admin section.

Also:

config/defaults.yml needs to have added to it:

  editor_login: true


And you'll need a cron to harvest domains, something along the lines of:

# m h  dom mon dow   command
*/10 * * * * cd /var/webiva/current;   rake cms:domain_runner DOMAIN_ID=1 CLASS=SiteDemoDomain METHOD=harvest_domains


Where DOMAIN_ID is the master domain that has the module activated.
