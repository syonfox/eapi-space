#!/bin/bash
set -e

MOD_DIR="$(pwd)"

RELEASE_FILE="$1"

GIT_REPO="/home/user/Games/pioneer"
REPO_URL="https://github.com/syonfox/pioneer"

REPO_MOD="https://github.com/syonfox/eapi-space" ; # todo get info from this release as well


# ------------------------------------------------------------
# Validate input
# ------------------------------------------------------------

if [ -z "$RELEASE_FILE" ]; then
    echo "Usage: $0 <release-zip-file>"
    exit 1
fi

if [ ! -f "$RELEASE_FILE" ]; then
    echo "Error: File not found: $RELEASE_FILE"
    exit 1
fi


# ------------------------------------------------------------
# Git information
# ------------------------------------------------------------

cd "$GIT_REPO"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
FULL_COMMIT=$(git rev-parse HEAD)
COMMIT=$(git rev-parse --short HEAD)

COMMIT_URL="$REPO_URL/commit/$FULL_COMMIT"
BRANCH_URL="$REPO_URL/tree/$BRANCH"

AUTHOR=$(git log -1 --format="%an")
MESSAGE=$(git log -1 --format="%s")


# ------------------------------------------------------------
# Release information
# ------------------------------------------------------------

DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")

FILENAME=$(basename "$RELEASE_FILE")
RELEASE_NAME="${FILENAME%.zip}"

FILE_SIZE=$(du -h "$RELEASE_FILE" | cut -f1)
SHA256=$(sha256sum "$RELEASE_FILE" | awk '{print $1}')


# ------------------------------------------------------------
# Output paths
# ------------------------------------------------------------

RELEASE_DIR="$MOD_DIR/_foxi/web/release"

mkdir -p "$RELEASE_DIR"

PAGE_NAME="${RELEASE_NAME}.html"

PAGE_PATH="$RELEASE_DIR/$PAGE_NAME"
LATEST_PATH="$RELEASE_DIR/latest.html"


# ------------------------------------------------------------
# Generate release page
# ------------------------------------------------------------

cat > "$PAGE_PATH" <<EOF
<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<title>$RELEASE_NAME - Pioneer Mod Release</title>

<meta name="description"
      content="Pioneer mod release $RELEASE_NAME">

<meta property="og:title"
      content="$RELEASE_NAME">

<meta property="og:type"
      content="website">


<link rel="stylesheet" href="../style.css">
<link rel="stylesheet" href="./css/style.css">

</head>


<body class="release-page">


<header class="release-header">

<h1>Pioneer Mod Release</h1>

<p class="release-name">
$RELEASE_NAME
</p>

</header>



<main class="release-container">


<section class="release-card">

<h2>Release Information</h2>


<dl class="release-info">


<dt>Release</dt>
<dd>$RELEASE_NAME</dd>


<dt>Date</dt>
<dd>$DATE $TIME</dd>


<dt>File Size</dt>
<dd>$FILE_SIZE</dd>


<dt>SHA256</dt>
<dd>
<code>$SHA256</code>
</dd>


</dl>

</section>




<section class="download-card">

<h2>Downloads</h2>


<a class="download-button mirror"
   href="./mirror/$FILENAME">

Download Mirror

</a>



<a class="download-button github"
   href="$REPO_URL/blob/main/_release/$FILENAME">

GitHub Download

</a>


</section>




<section class="github-card">

<h2>GitHub Integration</h2>


<dl class="release-info">


<dt>Repository</dt>

<dd>
<a href="$REPO_URL">
$REPO_URL
</a>
</dd>



<dt>Branch</dt>

<dd>
<a href="$BRANCH_URL">
$BRANCH
</a>
</dd>



<dt>Commit</dt>

<dd>
<a href="$COMMIT_URL">
$COMMIT
</a>
</dd>



<dt>Author</dt>

<dd>
$AUTHOR
</dd>



<dt>Message</dt>

<dd>
$MESSAGE
</dd>


</dl>


</section>




<section class="release-card">


<h2>Build Information</h2>


<p>
This release was automatically generated.
</p>


<p>
Source commit:
<a href="$COMMIT_URL">
$FULL_COMMIT
</a>
</p>


</section>



</main>



<footer class="release-footer">

Generated automatically on $DATE $TIME

</footer>



</body>

</html>
EOF



# ------------------------------------------------------------
# Update latest release link
# ------------------------------------------------------------

ln -sf "$PAGE_NAME" "$LATEST_PATH"


echo
echo "Release page created:"
echo "  $PAGE_PATH"

echo
echo "Latest release:"
echo "  $LATEST_PATH -> $PAGE_NAME"

echo
echo "SHA256:"
echo "  $SHA256"