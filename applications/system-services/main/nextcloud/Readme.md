
# Nextcloud

## Pregenerate thumbnails for images
After setting up everything (import and link all data, please see also files_external extension) run the following commands:

```
./compose.sh nextcloud exec -u 1000 app /bin/sh
```
and then inside of the shell:
```
./occ app:install previewgenerator
./occ preview:generate-all
```

## Upgrade nextcloud
Nextcloud must be upgraded step by step:
Before you can upgrade to the next major release, Nextcloud upgrades to the latest point release.

Then run the upgrade again to upgrade to the next major release’s latest point release.

You cannot skip major releases. Please re-run the upgrade until you have reached the highest available (or applicable) release.

Example: 18.0.5 -> 18.0.11 -> 19.0.5 -> 20.0.2

1. Stop cron container `./compose.sh nextcloud stop cron`
1. Update to the next version that can be used according to docs, using `./project.sh nextcloud` and change `NEXTCLOUD_VERSION` to your version (including fpm and alpine)
1. `./compose.sh nextcloud build app`
1. Update from an build: `./compose.sh nextcloud up -d  --no-deps --force-recreate app`
1. Check logs `./compose.sh nextcloud logs -f app`, if it doesnt show that its updating automatically (e.g. errors like php not found) you need to trigger the update manually
    1. `./compose.sh nextcloud exec -u 1000 app /bin/sh`
    1. `./occ upgrade`
1. Build and recreate cron container `./compose.sh nextcloud build cron` followed by `./compose.sh nextcloud up -d  --no-deps --force-recreate cron`
1. Check if there is something to do for you afterwards https://yourdomain.com/settings/admin/overview