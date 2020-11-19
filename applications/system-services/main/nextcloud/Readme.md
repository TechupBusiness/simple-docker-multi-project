
After setting up everything (import and link all data, please see also files_external extension) run the following commands:

```
./compose.sh nextcloud exec -u 1000 app /bin/sh
```
and then inside of the shell:
```
./occ app:install previewgenerator
./occ preview:generate-all
```
