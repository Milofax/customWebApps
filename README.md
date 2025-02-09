> mkdir temp
> git clone git@github.com:Milofax/my-dot-configs.git temp
> mv temp/.git ./
> rm -rf temp
> git checkout .
> git submodule update --init --recursive
> git submodule update --recursive --remote

Um in Zukunft die Submodule aktuell zu halten:

> git submodule update --recursive --remote
> git submodule update --recursive
# customWebApps
