# faucet-config
This repository has become the main configuration repo for my whole master thesis project, not just the faucet controller.
Therefore, it is now the main entrypoint for my thesis project, DistriMUD.
For an in depth explanation of the DistriMUD architecture, I refer to: see TODO TUE link when published.

Multiple other repositories are needed to run the whole project. These should be cloned in the parent directory of this repo.
To setup the Faucet/MUDManager:
```
├── faucet              Cloned from https://github.com/WoutervanHoof/faucet
├── faucet-config       This repo https://github.com/WoutervanHoof/faucet-config
└── mud-manager         Cloned from https://github.com/WoutervanHoof/mud-manager (currently private, will be public after publication)
```

To build the demo application for the nRF52840 or nRF52833 to act as FTDs or MTDs: see https://github.com/WoutervanHoof/mt-cli
This repo overrides the normal openthread library with my version: https://github.com/WoutervanHoof/openthread
This openthread fork includes the DistriMUD functionality for sharing MUD URLs inside a Thread network.

Finally, for deploying a border router, see https://github.com/WoutervanHoof/otbr-posix
This is a clone of the normal openthread border router repo, but with a MUD Forwarder service.
For running the demo environment, build the docker container image for the border router. Be sure to update the name of the image in the `./scripts/run_demo.sh` script with your name.


The directory sturcture of this repo is as follows:
```
.
├── docker              Contains docker overrides for Faucet as well as the MUD Manager.
├── mudfiles            Contains MUD files used by the mudfileserver (see docker-compose.yaml), rebuild to update fileserver container.
├── scripts             Contains setup scripts for demo environment, see ./scripts/README.md for further explanations.
│   └── experiments     Contains scripts for running my experiments, see ./scripts/experiments/README.md for further explanations.
└── volumes             Directory containing volumes mounted in Faucet, set environment variable FAUCET_HOME=/PATH/TO/REPO/faucet-config/volumes
    ├── etc
    │   └── faucet      Contains config files for Faucet, see ./volumes/etc/faucet/README.md for further explanations.
```