PST_to_Maildir
==============

Migration from .pst to Maildir

This repository contains all tools which could be useful during migration i.e. from Microsoft Outlook .pst file to Dovecot maildir.

# Prerequisites

The shell script uses `readpst` command, that can be installed for example with `apt install pst-utils`. For example:
```
~$ readpst -V
ReadPST / LibPST v0.6.71
Little Endian implementation being used.
```

The perl file can be interpreted with Perl v5.26.1 or compatible.
