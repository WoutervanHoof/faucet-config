# faucet-config
This repository has become the main configuration repo for my whole master thesis project, not just the faucet controller.
Therefore, it is now the main entrypoint for my thesis project, DistriMUD.

Multiple other repositories are needed to run the whole project. These should be cloned in the parent directory of this repo.
TODO


The directory sturcture of this repo is as follows:
.
├── docker              Contains docker overrides for Faucet as well as the MUD Manager.
├── mudfiles            Contains MUD files used by the mudfileserver (see docker-compose.yaml), rebuild to update fileserver container.
├── scripts             Contains setup scripts for demo environment, see ./scripts/README.md for further explanations.
│   └── experiments     Contains scripts for running my experiments, see ./scripts/experiments/README.md for further explanations.
└── volumes             Directory containing volumes mounted in Faucet, set environment variable FAUCET_HOME=/PATH/TO/REPO/faucet-config/volumes
    ├── etc
    │   └── faucet      Contains config files for Faucet, see ./volumes/etc/faucet/README.md for further explanations.
