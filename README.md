# lazyvpn
## DESCRIPTION
<p>lazyVPN is a <strong>shell</strong> script dedicated to automatically install and setup <strong>OpenVPN</strong> server in one process.</p>
<p>It's based and tested on <strong>Ubuntu</strong> Server 14.04 and intended to be used on VPS/VDS run in <strong>OpenVZ</strong> containers.</p>
<p>Current version is just <strong>an alpha</strong> and has quite dirty code but it does what it was designed for: fast and simple install and deploy <strong>private</strong> VPN server.</p>
## INSTALLATION
<p>Step 0: download whole "lazyvpn" directory and upload it to /home directory on your VPS/VDS [server]</p>
<p>Step 1: set lazy.sh executable - run in ssh console "cd /home/lazyvpn && chmod +x lazy.sh"<br>
<ul><li>Some hint #1: update your system before OpenVPN installation - "apt-get update"</li>
<li>Some hint #2: it would be nice idea to add OpenVPN repository to system's repo list - lookup here https://community.openvpn.net/openvpn/wiki/OpenvpnSoftwareRepos</li></ul></p>
<p>Step 2: Run the script - in ssh "./lazy.sh" and follow dialogs on screen. That's it! :)</p>
## OTHER INFO
### Release Info
<ul><li>v0.1: 
<ul><li>this version can automatically create one user only called "client". If you want to create more users just edit source, replace "client" string and run the script again</li>
<li>since this version designed to be run on fresh server instance without openvpn installed it could be useful to run "/etc/init.d/openvpn stop && apt-get purge openvpn && rm -rf /etc/openvpn/" to completely uninstall previous openvpn package</li></ul>
</li></ul>
### Licensing
<p>You gotta be kidding me if you're interested in license issues of the script ;) It's just a tool designed for my purposes so you're free to use it in any kinds. And yeah, you know about "as is" rule and no responsibility of course.</p>

