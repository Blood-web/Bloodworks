% bssh(1) | bssh usage documentation

# NAME
**bssh** — Library and console command for linux networking using classic methods.

# SYNOPSIS
|    `$ bssh MODE [-h | --help ]`

# DESCRIPTION

 Bssh is a tiered clinux comunication application,
 - BloodBash* is a representation of the bash specific files in the bloodweb 'c' file system structure

 Bssh as the name implies, uses built in ssh methods for managing these structures, including, but not limited to
    • Rsync (Keeping full and partial clones up to date)
    • ssh (Moving between nodes)
    • scp (one-off targeted copies (Typically Exipremental.. Rsync preferred))


 Bssh also reserves the following keys:
    • P (Production)
    • D (Development)
    • L (Live-Development)
    • V (Test)
    • M (Mobile)

    ## These keys typically represent ssh ports to Linux based devices ( RaspberryPi, MircoBit, ect.. )


# COMMONS
## Variables:
 -ssh_log: true | *  # logs ssh interaction
 -all_ssh_Akeys="" # letters
 -ssh_nodes="" # name@ip

## Functions  
  • $(key) # node reference
  • ssh_to # quick ssh to bloodweb nodes	

   
# APPLICATION - creates the following keys:

declare -Agx BSSH_[a_key]=(
    -A Associative Array -g Modify at global -x mark for export
-   [name]                     =     'bash-user'
-   [ip]                       =     '192.168.1.666'
-   [a_key]                    =     'A' # Alpha-key USED IN NAME, duplicates return err
-   [port]                  =(port#) #else unused // assumed 22

    :Externals && Internals created via main mutation

-    [ssh]                   =   name@ip
-    [a_key]		     :   echo $name@$ip      ## Get the full address
-   _[a_key]                 :   ssh SSH_[ssh] $@    ## Quick ssh (args passable)
    
)

