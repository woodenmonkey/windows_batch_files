# Windows Batch Files

**This repo contains a collection of batch files I've written over the years to streamline various workflows.**

## Batch files in `cmd-files/`

* `TurnOffEDP.cmd` — manage Endpoint Detection/EDP configuration and audit logging.
* `acle.cmd` — manage Application Container loopback exemptions and Edge exemptions.
* `aclocalhost.cmd` — add or remove localhost loopback exemptions for specified packages.
* `ad.cmd` — change directory to local or roaming AppData.
* `adl.cmd` — change directory into the user downloads tree.
* `admin.cmd` — add the current user to the local Administrators group.
* `adoc.cmd` — change directory to the user Documents folder.
* `alldown.cmd` — remotely shut down a list of machines.
* `analog.cmd` — process analog logs and copy report output.
* `as.cmd` — open an administrative shell at `C:\`.
* `atmp.cmd` — change directory to the current user Temp folder.
* `batchcopy.cmd` — copy selected batch files from `%SYSTEMROOT%` to a remote admin share.
* `batchcopyall.cmd` — copy all `.cmd` and `.txt` files from `%SYSTEMROOT%` to a remote admin share.
* `bigparse.cmd` — parse `ex09*` files and append results to a count file.
* `bigsparse.cmd` — parse `ex09*` files and run the `lc` parser on each.
* `bigsparsed.cmd` — parse `ex09*` files and run the `lcd` parser on each.
* `brutal.cmd` — create large files from a list for testing or stress exercises.
* `build.cmd` — Windows build checker and release-media validator.
* `cvl.cmd` — select between IE and Spartan/Edge modes.
* `daf.cmd` — prompt before timestamping a batch of files.
* `dbg.cmd` — launch WinDbg against the specified dump or executable.
* `dd.cmd` — rename a file with a current date/time prefix.
* `demosetup.cmd` — add a demo host entry to the system hosts file.
* `df.cmd` — build a datetime string for use in scripts.
* `dfa.cmd` — change directory to the dumpfiles folder.
* `dhcp.cmd` — set all network interfaces to use DHCP.
* `dl.cmd` — change directory into the user Downloads folder.
* `do.cmd` — query remote hosts for system uptime.
* `doc.cmd` — change directory to the local Documents folder.
* `docopy.cmd` — copy a file to each host listed in an input file.
* `dologgedon.cmd` — run `psloggedon` against hosts listed in an input file.
* `dologoff.cmd` — force logoff remote hosts listed in an input file.
* `doping.cmd` — ping each host listed in an input file.
* `dorestart.cmd` — remotely restart machines listed in an input file.
* `dotime.cmd` — build a timestamp string from the current date and time.
* `down.cmd` — shut down the local machine.
* `dt.cmd` — change directory into the user Desktop folder.
* `edge.cmd` — inspect Edge browser processes and related task manager state.
* `elc.cmd` — search message logs for SMTP EHLO/FROM/DATA/QUIT markers.
* `elcg.cmd` — similar EHLO/FROM/DATA/QUIT scanning with alternate filter values.
* `etm.cmd` — launch the Edge Task Manager for the current CPU architecture.
* `exmap.cmd` — map standard network shares to fixed drive letters.
* `findchrome.cmd` — detect whether Chrome is currently running.
* `findie.cmd` — detect whether Internet Explorer is currently running.
* `fixbootname.cmd` — set the Windows boot entry description.
* `fixwifi.cmd` — disable and re-enable the wireless interface.
* `fwoff.cmd` — disable the Windows firewall.
* `fwon.cmd` — enable the Windows firewall with exceptions.
* `fwsec.cmd` — enable the Windows firewall with exceptions disabled.
* `getcounts.cmd` — count directories under a release share and log results.
* `hosts.cmd` — open the system hosts file in Notepad.
* `intreset.cmd` — disable and re-enable network interfaces to reset them.
* `ke.cmd` — prompt to kill `explorer.exe`.
* `killbing.cmd` — terminate Bing-related processes.
* `killchrome.cmd` — terminate Chrome processes.
* `killie.cmd` — terminate Internet Explorer processes.
* `latency.cmd` — build a timestamp string for logging latency or diagnostics.
* `lc.cmd` — count EHLO/FROM occurrences in a file.
* `lcd.cmd` — count EHLO/FROM occurrences in a file with case-insensitive matching.
* `localbits.cmd` — mirror a network share to `C:\local` via `robocopy`.
* `machinesync.cmd` — sync backup content from a drive or update system scripts.
* `motw.cmd` — add/read/delete Zone.Identifier mark-of-the-web metadata.
* `netoff.cmd` — disable all network interfaces.
* `neton.cmd` — re-enable all network interfaces.
* `netreset.cmd` — reset network interfaces by disabling and re-enabling them.
* `newbuild.cmd` — query Windows build and branch information from the registry.
* `open.cmd` — grant `ALL APPLICATION PACKAGES` access to a file using `icacls`.
* `p.cmd` — set file ACLs using `cacls` and an approval file.
* `pinghosts.cmd` — open multiple persistent ping windows for specified hosts.
* `pmap.cmd` — map network shares to drive letters.
* `ps.cmd` — simplify the console prompt to `>`.
* `purge.cmd` — print a humorous warning message.
* `ra.cmd` — add static routes for common internal networks.
* `rcmd.cmd` — launch a command shell using `runas /netonly`.
* `rdp.cmd` — launch Remote Desktop to the specified host.
* `restart.cmd` — restart the local machine or remote hosts.
* `robobackup.cmd` — back up selected user and system folders with `robocopy`.
* `se.cmd` — check whether Microsoft Edge is running.
* `servicedetails.cmd` — display service configuration details for services in `ServiceList.txt`.
* `so.cmd` — check whether Outlook is running.
* `split_csv_with_header.cmd` — split a CSV file into smaller files while preserving the header.
* `split_csv_with_header_powershell.cmd` — split a CSV file using PowerShell while preserving the header.
* `static.cmd` — prompt to set a static IP address on all interfaces.
* `sticksync.cmd` — sync user documents to backup storage on a removable drive.
* `stop.cmd` — stop listed services and kill CCM-related processes.
* `theyallfalldown.cmd` — shut down many domain computers via `dsquery` and `shutdown`.
* `tmp.cmd` — change directory to the system temp folder.
* `unmap.cmd` — disconnect all mapped network drives.
* `unstop.cmd` — start services listed in `ServiceList.txt`.
* `up.cmd` — change directory to the user profile root.
* `updatelocals.cmd` — mirror a shared code path to `C:\local`.
* `uptime.cmd` — show system boot time.
* `var.cmd` — echo a target variable.
* `vhd.cmd` — read, write, and rename VHD metadata entries.
* `volspace.cmd` — collect remote disk information from domain servers and open the report.
* `whoson.cmd` — query who is logged on across a set of domain computers.
* `win.cmd` — change directory to `%SYSTEMROOT%`.

## Supporting text files
* Mostly lists
* `batchlist.txt`
* `robobackup.txt`
* `servicelist.txt`
* `slist.txt`
* `thoseservices.txt`
