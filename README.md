## Install your FHEM Configuration Git

In your FHEM directory, enter the following command:

````
git clone https://github.com/jpawlowski/fhem-config.tmpl tmp; mv tmp/* tmp/.git* .; rmdir tmp
````

Afterwards edit fhem.git.cfg to enter your own Git remote repository with optional credentials.
You may then initially run `fhem.git.sh push` to upload the initial configuration.
Please note that the remote Git needs to be completely new/empty at this point.

Afterwards you may clone your configuration to every local computer, change your configuration files and push them back to the remote repository. Running `fhem.git.sh pull` on your FHEM server will then fetch all changes.

NOTE: Changes you made locally on your FHEM server will silently be overwritten. If you would like to keep changes you saved from within FHEM you need to run `fhem.git.sh push` to commit those changes and push them to the remote repository.
At the moment this script does not take care about merging conflicts so you should not make changes to your configuration on 2 different places. Otherwise you will need to manually resolve the merge conflict.

### Security Info
The two files fhem.git.cfg and db.conf will initially be downloaded to your FHEM server but changed you do to them will be kept local and not pushed back to the remote repository.
This will ensure privacy of your Git and database credentials.