## CLI commands
- `./compose.sh hydra exec hydra /root/Hydra/bin/./hydra-cli help`: See all comands
- `./compose.sh hydra exec hydra /root/Hydra/bin/./hydra-cli getstakinginfo`
- `./compose.sh hydra exec hydra /root/Hydra/bin/./hydra-cli getblockcount`
- `./compose.sh hydra exec hydra /root/Hydra/bin/./hydra-cli walletpassphrase "my pass phrase" 99999999 true`: Unlock wallet for staking

### Cleanup history
If you use password via CLI, you may want to clean your history e.g.:
- `history`: Show history with line numbers
- `history -d 1234`: Number is the line of the history to delete
