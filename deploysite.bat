SETLOCAL

SET DISTRIBUTION_ID=E30DHETRR7Z2LT
SET BUCKET_NAME=www.open-seo.org

hugo -v 

:: Copy over pages - not static js/img/css/downloads
::--profile lauf
aws s3 sync --acl "public-read" --sse "AES256" public/ s3://%BUCKET_NAME%/blog/ --exclude 'img' --exclude 'js' --exclude 'downloads' --exclude 'css' --exclude 'post'

:: Ensure static files are set to cache forever - cache for a month --cache-control "max-age=2592000"
aws s3 sync --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/img/ s3://%BUCKET_NAME%/blog/img/
aws s3 sync --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/css/ s3://%BUCKET_NAME%/blog/css/
aws s3 sync --cache-control "max-age=2592000" --acl "public-read" --sse "AES256" public/js/ s3://%BUCKET_NAME%/blog/js/

:: Downloads binaries, not part of repo - cache at edge for a year --cache-control "max-age=31536000"
aws s3 sync --cache-control "max-age=31536000" --acl "public-read" --sse "AES256"  static/downloads/ s3://%BUCKET_NAME%/blog/downloads/

:: Invalidate landing page so everything sees new post - warning, first 1K/mo free, then 1/2 cent ea
aws cloudfront create-invalidation --distribution-id %DISTRIBUTION_ID% --paths /blog/index.html /blog/

ENDLOCAL

:: aws cloudfront create-invalidation --distribution-id E3JG7JYL1VAP9X --paths /index.html /