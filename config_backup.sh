#!/bin/bash
 
zmcontrol -v > zimbra_version.txt
zmlocalconfig -s > localconfig.txt
zmprov gacf  > gacf.txt
zmprov gs $(zmhostname)  > $(zmhostname).txt
for dom in $(zmprov -l gad); do zmprov gd "$dom" > $dom.txt; done
postconf > postconf.txt
