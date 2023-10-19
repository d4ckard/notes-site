# Motes

Motes ("Markdown" + "Notes") is a set of scripts and configurations for easily managing and sharing notes written in Markdown on the web. It aims to be simple, easy to use, and provide you with full ownership over all of your notes. Using Motes, you can share your obscure, plain text notes with anyone in seconds, allowing them to view your notes as beautiful HTML documents.

## Motivation

I have long been drawn to the idea of writing notes and similar documents in plain text and keeping them in an easy to transform format on my own computer.

The downside of this approach is that it makes your workflow incompatible with everyone else who is using WYSIWYG and cloud-based solutions.

In my personal workflow, Motes allows me to share my notes with others in a nice format, while keeping full control over the documents themselves. There is no middle-man involved who, once broke, will loose all my data.

## Installation

To install the scripts locally, you have to clone this repository and then run the `install.sh` script. It will make all the scripts and the Pandoc template they used available on your computer. Notable dependencies include [pandoc](https://pandoc.org/installing.html), and [qrencode](https://fukuchi.org/works/qrencode/). Make sure you have them installed and in your `PATH`. It's safe to assume that all other programs the scripts use are already installed. If they're not, you'll get an error message telling you what is missing. If you want to use [Mermaid](http://mermaid.js.org/) to embed diagrams in your notes, you need to install [mermaid-filter](https://github.com/raghur/mermaid-filter) too. It's optional though.

Here is what the installation should look like:

``` shellsession
~$ git clone https://github.com/d4ckard/motes.git
Cloning into 'motes'...
remote: Enumerating objects: 72, done.
remote: Counting objects: 100% (72/72), done.
remote: Compressing objects: 100% (54/54), done.
remote: Total 72 (delta 33), reused 52 (delta 16), pack-reused 0
Receiving objects: 100% (72/72), 16.47 KiB | 1.27 MiB/s, done.
Resolving deltas: 100% (33/33), done.
~$ cd motes
~/motes$ ./install.sh
+ cp motes.html /home/thasso/.local/share/pandoc/templates/
+ cp motes-build /home/thasso/bin/
+ cp motes-convert /home/thasso/bin/
+ cp motes-preview /home/thasso/bin/
+ cp motes-push /home/thasso/bin/
+ cp motes-share /home/thasso/bin
+ set +x

All scripts were installed successfully!

Set MOTES_URL to the URL where your notes can be found and
export it in your configuration file of choice (e.g. .bashrc).

See the commentary in motes.el if you want to find out how to
use the scripts you just installed with Emacs.
```

The `motes-share` script generates QR codes that link to the online version of a given note. To do so, it needs the URL that points to the root of your online notes. For example, if you're hosting your notes on `https://example.com/`, then you should `export MOTES_URL="https://example.com/"`. `motes-share` will append the path to the note inside the Git repository that's tracking the notes to that URL.

The commentary in `motes.el` explains how you can configure Emacs to use Motes.

## Usage

Motes expects you to track your notes using Git. The share mechanism works based on the assumption that pushing your notes triggers them to be built using `motes-build`, and uploaded to some web site.

The built-in solution is to use GitHub pages and GitHub actions for that purpose. It's easy to implement the same behavior in ten lines of Bash as a Git hook, too.

The following steps will allow you to use Motes with GitHub pages and GitHub actions.

1. Create a repository for your notes on GitHub. It can be private, but links to your HTML notes will be public.

2. In the repositoy's settings tab go to "Pages". Under the "Build and Deployment" header, select "GitHub Actions" as the source. Next, choose "Static HTML" as the type of action you want to use.

3. Copy the following action into the online editor that GitHub will open. At the time of writing this, the only important part that was changed from the default is the job that is executed to build the site.

``` yaml
name: Deploy notes to GitHub Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["main"]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment, skipping runs queued between the run in-progress and latest queued.
# However, do NOT cancel in-progress runs as we want to allow these production deployments to complete.
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      # Build the notes found in this repository
      - name: Build the site
        uses: d4ckard/motes@v1
        with:
          from: ${{ github.repository }}
          to: 'site'

      # Configure, upload, and deploy the site on GitHub Pages.
      - name: Setup Pages
        uses: actions/configure-pages@v3
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v2
        with:
          path: 'site'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v2
```

4. Click the "Commit changes" button to add the action to your repository. Now you're done! Any time you push some notes to this repository, a web site with all your notes accessible as pretty HTML documents will be deployed.

After GitHub is done building your site for the first time, go back to "Pages" in the settings tab. There you'll see it say "Your site is live at", followed by a link. **That link is what you should export as `MOTES_URL`!**

You can checkout [this example repository](https://github.com/d4ckard/motes-example) to see how a repository might look after following all the above steps. The `MOTES_URL` for that repository is `https://thasso.xyz/motes-example/`. The HTML version of the `hello.md` file in the repository's root can be found [here](https://thasso.xyz/motes-example/hello.html). I'd encourage you to check out the [source of page `hello.md`](https://github.com/d4ckard/motes-example/blob/main/hello.md?plain=1), to see how to write notes for Motes.

## Scripts

The following scripts are included with Motes. Working with Motes, you'll find yourself using `motes-preview`, and `motes-share` most frequently.

`motes-build` takes an input directory and an output directory. It will recursively go through the entire input directory, convert all notes (`.md` files) in this directory to HTML documents using Pandoc, and then place them in the output directory. The directory structure of the input directory is preserved. All `*.pdf`, `*.jpg`, and `*.png` files are copied too.

For example, running `motes-build notes/ site/` will populate the `site/` directory with the contents of `notes/` as follows:

```
notes
├── foo
│   ├── bar
│   │   └── baz.md
│   ├── blah.md
│   └── something.jpg
├── ignored.c
├── important.pdf
└── wee.md
```

```
site
├── foo
│   ├── bar
│   │   └── baz.html
│   ├── blah.html
│   └── something.jpg
├── important.pdf
└── wee.html
```

`motes-convert` converts a single Markdown document to HTML. It takes the name of an input file (`.md`) and the name of an output file (`.html`) as mandatory arguments.

`motes-push` is simply a mercy-less git command that adds everything in the current directory, creates a commit, and pushes that commit. This can be dangerous in some cases, but is mostly OK for working with personal notes. You can also pass `motes-push` a single argument that will be used as the commit message.

`motes-preview` is really fun! It only requires the name of a Markdown document as its only argument, and it will convert that document and open it in your browser to preview. The output HTML document is automatically created in `/tmp/`, and deleted once the scrip ends. `motes-preview` also watches the given file for changes and updates the output document under the same name every time the input changes.

`motes-share` also requires the name of a Markdown document as its only argument. If there are any local changes, `motes-share` will run `motes-push` to synchronize them with the remote. Based on the URL in `MOTES_URL` (see [usage](#usage)), it then displays a QR code that links to the online HTML version of the given Markdown document. It also prints the link itself in case you just want to copy it.

## Feedback

I'd be happy to get your feedback if you try to use Motes yourselves. Feel free to [send me an email](mailto:d4kd@proton.me) or [open an issue](https://github.com/d4ckard/motes/issues) if you have suggestions or find some mistake. I'm happy to answer any questions on how to use Motes, and improve the explanations found here.
