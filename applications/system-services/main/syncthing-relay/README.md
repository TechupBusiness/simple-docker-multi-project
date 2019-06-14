
Check your docker logs to connect to your relay server (replace `0.0.0.0` with your docker hosts public ip address):
```
syncthing-relay_1  | 2019/06/14 16:52:22 main.go:149: strelaysrv  (go1.12.6 linux-amd64) @ 1970-01-01 00:00:00 UTC
syncthing-relay_1  | 2019/06/14 16:52:22 main.go:155: Connection limit 838860
syncthing-relay_1  | 2019/06/14 16:52:22 main.go:168: Failed to load keypair. Generating one, this might take a while...
syncthing-relay_1  | 2019/06/14 16:52:22 main.go:244: URI: relay://0.0.0.0:22156/?id=36ZVZR7-T2FOPB7-AB7LI57-THIC4A7-H6JOCUA-6POEI3N-UZ7X6FZ-ZYKEOQR&pingInterval=1m0s&networkTimeout=2m0s&sessionLimitBps=0&globalLimitBps=0&statusAddr=&providedBy=
```